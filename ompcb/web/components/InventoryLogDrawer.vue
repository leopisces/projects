<template>
  <el-drawer
    :model-value="visible"
    :title="title"
    direction="rtl"
    size="560px"
    @update:model-value="(v) => emit('update:visible', v)"
    @open="onOpen"
  >
    <!-- 改用全局 .ui-target：sunken 底 + 左 2px 蓝条对应用户刚点中的那一行，
         批量撤销时不会误以为在改另一个元件。 -->
    <div v-if="item" class="ui-target">
      <div class="ui-target-name">{{ item.name || item.mfr_pn || item.supplier_pn || '—' }}</div>
      <div class="ui-target-meta ui-target-meta-row">
        <span v-if="item.package">{{ item.package }}</span>
        <span v-if="item.supplier_pn">{{ item.supplier_pn }}</span>
        <span>当前库存 {{ item.stock }}</span>
      </div>
    </div>

    <div class="log-actions">
      <div class="log-actions-hint ui-hint">
        <template v-if="selectedRevocable.length">
          已选 {{ selectedRevocable.length }} 条，共补回 {{ selectedQty }} 件
        </template>
        <template v-else>勾选出库记录可批量撤销</template>
      </div>
      <div class="log-actions-right">
        <el-button
          v-if="inventoryId && hasLogs"
          type="danger"
          size="small"
          :loading="deletingAll"
          @click="confirmDeleteAll"
        >全部删除</el-button>
        <el-button
          type="warning"
          size="small"
          :disabled="!selectedRevocable.length"
          :loading="bulkRevoking"
          @click="confirmBulkRevoke"
        >撤销所选{{ selectedRevocable.length ? `（${selectedRevocable.length}）` : '' }}</el-button>
      </div>
    </div>

    <el-table
      ref="tableRef"
      v-loading="loading"
      :data="logs"
      border
      stripe
      size="small"
      row-key="id"
      empty-text="暂无出入库记录"
      @selection-change="onSelectionChange"
    >
      <!-- 不可撤销的行（入库/盘点/初始/已撤销/撤销单）复选框置灰 -->
      <el-table-column type="selection" width="40" :selectable="canRevoke" />
      <el-table-column prop="created_at" label="时间" width="150" class-name="col-num" />
      <el-table-column prop="type" label="类型" width="80" align="center">
        <template #default="{ row }">
          <el-tag :type="typeTagType(row.type)" size="small" effect="light">{{ row.type }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="delta" label="变动" width="80" align="right" header-align="right" class-name="col-num">
        <template #default="{ row }">
          <span :class="deltaClass(row.delta)">{{ row.delta > 0 ? '+' + row.delta : row.delta }}</span>
        </template>
      </el-table-column>
      <el-table-column prop="stock_after" label="变动后" width="80" align="right" header-align="right" class-name="col-num" />
      <el-table-column prop="remark" label="事由" min-width="120" show-overflow-tooltip>
        <template #default="{ row }">
          <span :title="row.remark || ''">{{ row.remark || '—' }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="86" align="center">
        <template #default="{ row }">
          <!-- 只有未撤销的出库可撤销；撤销单自身与已撤销行只显示标记 -->
          <el-button
            v-if="canRevoke(row)"
            link
            type="primary"
            size="small"
            :loading="revokingId === row.id"
            @click="confirmRevoke(row)"
          >撤销</el-button>
          <el-tag v-else-if="row.revoked_by_log_id" type="info" size="small" effect="plain">已撤销</el-tag>
          <el-tag v-else-if="row.revokes_log_id" type="success" size="small" effect="plain">撤销单</el-tag>
          <span v-else class="muted">—</span>
        </template>
      </el-table-column>
    </el-table>

    <div class="log-footer-note ui-hint">最多显示最近 200 条</div>
  </el-drawer>
</template>

<script setup>
import { computed, ref, watch } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { revokeStockOut, revokeStockOutBulk, deleteLogsByInventory } from '../api.js';

const props = defineProps({
  visible: { type: Boolean, default: false },
  item: { type: Object, default: null },
  logs: { type: Array, default: () => [] },
  loading: { type: Boolean, default: false },
});

const emit = defineEmits(['update:visible', 'refresh', 'revoked']);

const title = computed(() => `出入库流水（${props.logs.length} 条）`);

const revokingId = ref(null);
const tableRef = ref(null);
const selected = ref([]);
const bulkRevoking = ref(false);

// selectable 已挡住不可撤的行，这里再筛一遍：logs 是 prop，
// 父组件重取后换了新数组，残留的旧勾选可能已经被撤过了。
const selectedRevocable = computed(() => selected.value.filter(canRevoke));
const selectedQty = computed(() =>
  selectedRevocable.value.reduce((a, r) => a + Math.abs(r.delta), 0)
);

// 流水换了一批就清空勾选，避免拿旧行去撤
watch(() => props.logs, () => clearSelection());

// 从流水记录中提取 product_id（只有绑了产品的出库才有）
// 同一产品多条流水的 product_id 应一致，取第一个有效的即可
const productId = computed(() => {
  for (const log of props.logs) {
    if (log.product_id) return log.product_id
  }
  return null
})

// 当前元件的库存记录 ID
const inventoryId = computed(() => props.item?.id || null)

// 是否有可删除的流水（至少有一条记录才显示删除按钮）
const hasLogs = computed(() => props.logs.length > 0)

const deletingAll = ref(false)

function onSelectionChange(val) {
  selected.value = val || [];
}

function clearSelection() {
  selected.value = [];
  tableRef.value?.clearSelection?.();
}

function onOpen() {
  clearSelection();
  emit('refresh');
}

function typeTagType(type) {
  switch (type) {
    case '入库': return 'success';
    case '出库': return 'warning';
    case '盘点': return 'primary';
    case '初始': return 'info';
    default:     return 'info';
  }
}

function deltaClass(delta) {
  if (delta > 0) return 'delta-in';
  if (delta < 0) return 'delta-out';
  return 'delta-flat';
}

// --- 撤销出库 --------------------------------------------------------------
// 撤销不删原记录：服务端追加一条反向入库，两行都留在流水里。
// 所以撤销单自身（revokes_log_id 非空）与已被撤销的行都不再给按钮。

function canRevoke(row) {
  return row.type === '出库' && !row.revoked_by_log_id && !row.revokes_log_id;
}

async function confirmRevoke(row) {
  const qty = Math.abs(row.delta);
  const who = props.item?.name || props.item?.mfr_pn || props.item?.supplier_pn || '该元件';
  let remark = '';
  try {
    const res = await ElMessageBox.prompt(
      `将为「${who}」补回 ${qty} 件。原出库记录会保留，另生成一条入库流水。`,
      '撤销出库',
      {
        confirmButtonText: '确认撤销',
        cancelButtonText: '取消',
        inputPlaceholder: '撤销原因（可留空）',
        inputValue: '',
        inputValidator: () => true,
        type: 'warning',
      }
    );
    remark = String(res.value ?? '').trim();
  } catch {
    return;
  }

  revokingId.value = row.id;
  try {
    const res = await revokeStockOut(row.id, { remark });
    ElMessage.success(`已撤销：补回 ${res.delta} 件，当前库存 ${res.stockAfter}`);
    // 流水与台账都变了，交给父组件统一重取（抽屉头部的当前库存也依赖它）
    emit('revoked', res);
    emit('refresh');
  } catch (e) {
    ElMessage.error(e.message);
  } finally {
    revokingId.value = null;
  }
}

/**
 * 批量撤销当前勾选的出库。
 * 后端单事务但会逐行跳过不合格的（比如刚被别处撤过），所以要如实汇报 skipped。
 */
async function confirmBulkRevoke() {
  const targets = selectedRevocable.value;
  if (!targets.length) return;

  const who = props.item?.name || props.item?.mfr_pn || props.item?.supplier_pn || '该元件';
  let remark = '';
  try {
    const res = await ElMessageBox.prompt(
      `将为「${who}」撤销 ${targets.length} 条出库，共补回 ${selectedQty.value} 件。` +
        `原出库记录全部保留，另生成 ${targets.length} 条入库流水。`,
      '批量撤销出库',
      {
        confirmButtonText: `确认撤销 ${targets.length} 条`,
        cancelButtonText: '取消',
        inputPlaceholder: '撤销原因（可留空，将写入每条流水）',
        inputValue: '',
        inputValidator: () => true,
        type: 'warning',
      }
    );
    remark = String(res.value ?? '').trim();
  } catch {
    return;
  }

  bulkRevoking.value = true;
  try {
    const res = await revokeStockOutBulk(targets.map(r => r.id), { remark });
    if (res.skipped > 0) {
      ElMessage.warning(
        `已撤销 ${res.revoked} 条（补回 ${res.totalQty} 件），跳过 ${res.skipped} 条`
      );
      console.warn('[ompcb] 批量撤销跳过明细:', res.errors);
    } else {
      ElMessage.success(`已撤销 ${res.revoked} 条，补回 ${res.totalQty} 件`);
    }
    clearSelection();
    emit('revoked', res);
    emit('refresh');
  } catch (e) {
    ElMessage.error(e.message);
  } finally {
    bulkRevoking.value = false;
  }
}

// --- 全部删除 --------------------------------------------------------------
// 删除该产品关联的全部出入库流水（库存数量不受影响）

async function confirmDeleteAll() {
  if (!inventoryId.value) return;

  const who = props.item?.name || props.item?.mfr_pn || props.item?.supplier_pn || '该元件';
  const count = props.logs.length;

  try {
    await ElMessageBox.confirm(
      `将删除「${who}」的全部 ${count} 条出入库记录。\n\n` +
        '此操作不可恢复，删除后流水记录将无法查看。库存数量不受影响。',
      '全部删除出入库记录',
      {
        confirmButtonText: '确认删除',
        cancelButtonText: '取消',
        type: 'danger',
      }
    );
  } catch {
    return;
  }

  deletingAll.value = true;
  try {
    const res = await deleteLogsByInventory(inventoryId.value);
    ElMessage.success(res.message || `已删除 ${res.deleted} 条出入库记录`);
    clearSelection();
    emit('refresh');
  } catch (e) {
    ElMessage.error(e.message);
  } finally {
    deletingAll.value = false;
  }
}
</script>

<style scoped>
/* .ui-target 自带 padding / 边 / 左 2px 蓝条 / 圆角 / 字号阶梯，
   这里只补一个局部的 flex，让"封装 / 料号 / 库存"三段并排展示。 */
.ui-target-meta-row {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  font-family: var(--font-mono);
}

.log-actions {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  margin-bottom: 8px;
  flex-wrap: wrap;
}
.log-actions-hint {
  flex: 1 1 auto;
  min-width: 0;
}
.log-actions-right {
  display: flex;
  gap: 8px;
  flex: 0 0 auto;
}

/* 右下角脚注：与正文 hint 同一字号阶梯，仅在排版上贴右。 */
.log-footer-note { text-align: right; margin-top: 8px; }
</style>
