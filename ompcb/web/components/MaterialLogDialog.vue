<template>
  <el-dialog
    :model-value="visible"
    title="领料流水"
    width="720px"
    :close-on-click-modal="false"
    :close-on-press-escape="!bulkRevoking && revokingId === null"
    :show-close="!bulkRevoking && revokingId === null"
    @update:model-value="(v) => emit('update:visible', v)"
    @open="onOpen"
    @closed="onClosed"
  >
    <!-- 目标 BOM 行：与 StockMoveDialog / InventoryLogDrawer 同一套 .ui-target 语言，
         让人确认自己正在看哪一行的流水 -->
    <div v-if="material" class="ui-target">
      <div class="ui-target-name">{{ material.name || material.mfr_pn || '—' }}</div>
      <div class="ui-target-meta ui-target-meta-row">
        <span v-if="material.designator">位号 {{ material.designator }}</span>
        <span v-if="material.package">{{ material.package }}</span>
        <span v-if="material.mfr_pn">{{ material.mfr_pn }}</span>
        <span>已焊接 {{ material.solderedQty ?? 0 }}</span>
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
      max-height="380"
      empty-text="该 BOM 行还没有领料记录"
      @selection-change="onSelectionChange"
    >
      <!-- 不可撤销的行（已撤销 / 撤销单）复选框置灰 -->
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
      <el-table-column prop="stock_after" label="变动后库存" width="96" align="right" header-align="right" class-name="col-num" />
      <el-table-column prop="remark" label="事由" min-width="130" show-overflow-tooltip>
        <template #default="{ row }">
          <span :title="row.remark || ''">{{ row.remark || '—' }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="86" align="center">
        <template #default="{ row }">
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

    <!-- 合计：出库减去撤销补回的，正好等于表格里的「已焊接」。
         写出来是为了让人能对上账——两个数不一致时立刻能看出来。 -->
    <div class="log-foot ui-hint">
      共 {{ logs.length }} 条：领出 {{ outQty }} 件，撤销补回 {{ inQty }} 件，净已焊接 {{ outQty - inQty }} 件
      <span v-if="truncated" class="log-foot-warn">（仅显示最近 {{ PAGE_SIZE }} 条）</span>
    </div>

    <template #footer>
      <el-button @click="close" :disabled="bulkRevoking || revokingId !== null">关闭</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { computed, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { listMaterialLogs, revokeStockOut, revokeStockOutBulk, deleteLogsByProduct } from '../api.js'

// 单个 BOM 行的领料次数不会太多，一页拉完省掉分页交互。
// 真超了就在页脚如实说明被截断，不假装这就是全部。
const PAGE_SIZE = 200

const props = defineProps({
  visible: { type: Boolean, default: false },
  /** BOM 行对象；允许为 null（弹框常驻挂载，首次渲染还没选中行） */
  material: { type: Object, default: null },
})

const emit = defineEmits(['update:visible', 'revoked'])

const logs = ref([])
const loading = ref(false)
const total = ref(0)
const revokingId = ref(null)
const bulkRevoking = ref(false)
const deletingAll = ref(false)
const tableRef = ref(null)
const selected = ref([])

const truncated = computed(() => total.value > logs.value.length)

// 出库量与撤销补回量。用流水自身求和而不是读 material.solderedQty：
// 撤销之后本地的 material 对象还是旧的（父组件重取列表才会更新），
// 拿它算会让页脚与表格里刚变化的数字对不上。
const outQty = computed(() =>
  logs.value.filter(l => l.delta < 0).reduce((a, l) => a - l.delta, 0)
)
const inQty = computed(() =>
  logs.value.filter(l => l.delta > 0).reduce((a, l) => a + l.delta, 0)
)

const selectedRevocable = computed(() => selected.value.filter(canRevoke))
const selectedQty = computed(() =>
  selectedRevocable.value.reduce((a, r) => a + Math.abs(r.delta), 0)
)

// --- 加载 ------------------------------------------------------------------

async function fetchLogs() {
  const id = props.material?.id
  if (!id) {
    logs.value = []
    total.value = 0
    return
  }
  loading.value = true
  try {
    const data = await listMaterialLogs(id, { pageSize: PAGE_SIZE })
    // 弹框可能已被关掉或切到别的行，回来的结果就不该再灌进去
    if (props.material?.id !== id) return
    logs.value = data.list || []
    total.value = data.total || 0
  } catch (e) {
    ElMessage.error(e.message)
    logs.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

function onOpen() {
  clearSelection()
  fetchLogs()
}

function onClosed() {
  logs.value = []
  total.value = 0
  clearSelection()
}

function close() {
  if (bulkRevoking.value || revokingId.value !== null) return
  emit('update:visible', false)
}

function onSelectionChange(val) {
  selected.value = val || []
}

function clearSelection() {
  selected.value = []
  tableRef.value?.clearSelection?.()
}

// --- 展示辅助 --------------------------------------------------------------

function typeTagType(type) {
  switch (type) {
    case '入库': return 'success'
    case '出库': return 'warning'
    case '盘点': return 'primary'
    case '初始': return 'info'
    default:     return 'info'
  }
}

function deltaClass(delta) {
  if (delta > 0) return 'delta-in'
  if (delta < 0) return 'delta-out'
  return 'delta-flat'
}

// --- 撤销 ------------------------------------------------------------------
// 撤销不删原记录：服务端追加一条反向入库并继承同一 material_id，
// 使「已焊接」的 -SUM(delta) 聚合能如实归零。所以撤销单自身
// 与已被撤销的行都不再给按钮（与 InventoryLogDrawer 同一套判定）。

function canRevoke(row) {
  return row.type === '出库' && !row.revoked_by_log_id && !row.revokes_log_id
}

function who() {
  return props.material?.name || props.material?.mfr_pn || '该物料'
}

async function confirmRevoke(row) {
  const qty = Math.abs(row.delta)
  let remark = ''
  try {
    const res = await ElMessageBox.prompt(
      `将为「${who()}」补回 ${qty} 件，该行已焊接数同时减少 ${qty}。` +
        '原出库记录会保留，另生成一条入库流水。',
      '撤销出库',
      {
        confirmButtonText: '确认撤销',
        cancelButtonText: '取消',
        inputPlaceholder: '撤销原因（可留空）',
        inputValue: '',
        inputValidator: () => true,
        type: 'warning',
      }
    )
    remark = String(res.value ?? '').trim()
  } catch {
    return
  }

  revokingId.value = row.id
  try {
    const res = await revokeStockOut(row.id, { remark })
    ElMessage.success(`已撤销：补回 ${res.delta} 件，当前库存 ${res.stockAfter}`)
    await fetchLogs()
    // 库存与已焊接都变了，让父组件重取列表
    emit('revoked', res)
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    revokingId.value = null
  }
}

async function confirmBulkRevoke() {
  const targets = selectedRevocable.value
  if (!targets.length) return

  let remark = ''
  try {
    const res = await ElMessageBox.prompt(
      `将为「${who()}」撤销 ${targets.length} 条出库，共补回 ${selectedQty.value} 件，` +
        `该行已焊接数同时减少 ${selectedQty.value}。原出库记录全部保留。`,
      '批量撤销出库',
      {
        confirmButtonText: `确认撤销 ${targets.length} 条`,
        cancelButtonText: '取消',
        inputPlaceholder: '撤销原因（可留空，将写入每条流水）',
        inputValue: '',
        inputValidator: () => true,
        type: 'warning',
      }
    )
    remark = String(res.value ?? '').trim()
  } catch {
    return
  }

  bulkRevoking.value = true
  try {
    const res = await revokeStockOutBulk(targets.map(r => r.id), { remark })
    if (res.skipped > 0) {
      ElMessage.warning(
        `已撤销 ${res.revoked} 条（补回 ${res.totalQty} 件），跳过 ${res.skipped} 条`
      )
      console.warn('[ompcb] 批量撤销跳过明细:', res.errors)
    } else {
      ElMessage.success(`已撤销 ${res.revoked} 条，补回 ${res.totalQty} 件`)
    }
    clearSelection()
    await fetchLogs()
    emit('revoked', res)
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    bulkRevoking.value = false
  }
}

// --- 全部删除 --------------------------------------------------------------
// 删除该产品关联的全部出入库流水（库存数量不受影响）

async function confirmDeleteAll() {
  const productId = props.material?.product_id
  if (!productId) return

  const who = props.material?.name || props.material?.mfr_pn || '该产品'

  try {
    await ElMessageBox.confirm(
      `将删除「${who}」的全部出入库记录。\n\n` +
        '此操作不可恢复，删除后流水记录将无法查看。库存数量不受影响。',
      '全部删除出入库记录',
      {
        confirmButtonText: '确认删除',
        cancelButtonText: '取消',
        type: 'danger',
      }
    )
  } catch {
    return
  }

  deletingAll.value = true
  try {
    const res = await deleteLogsByProduct(productId)
    ElMessage.success(res.message || `已删除 ${res.deleted} 条出入库记录`)
    clearSelection()
    await fetchLogs()
    emit('revoked', res)
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    deletingAll.value = false
  }
}
</script>

<style scoped>
/* .ui-target 自带 padding / 左 2px 蓝条 / 字号阶梯，这里只补 flex 让 meta 并排 */
.ui-target { margin-bottom: 14px; }
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

/* 页脚合计：让「领出 − 补回 = 已焊接」这条账能被人工核对 */
.log-foot {
  margin-top: 10px;
  text-align: right;
}
.log-foot-warn {
  color: var(--c-warn);
}
</style>