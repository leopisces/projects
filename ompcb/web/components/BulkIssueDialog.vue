<template>
  <el-dialog
    :model-value="visible"
    :title="done ? '出库结果' : '批量出库（领料）'"
    width="720px"
    :close-on-click-modal="false"
    :close-on-press-escape="!submitting"
    :show-close="!submitting"
    @update:model-value="(v) => emit('update:visible', v)"
    @open="onOpen"
    @closed="onClosed"
  >
    <!-- 出库前：确认范围与套数 -->
    <template v-if="!done">
      <div class="ui-target">
        <div class="ui-target-name">{{ productCode || '—' }}</div>
        <div class="ui-target-meta">整个产品的 {{ bomLines }} 条 BOM 明细</div>
      </div>

      <el-form label-width="82px" label-position="right" @submit.prevent>
        <el-form-item label="出库套数">
          <el-input-number
            v-model="sets"
            :min="1"
            :max="9999"
            :step="1"
            controls-position="right"
            style="width: 140px"
          />
          <span class="form-inline-hint">每行出库 = 用量 × {{ sets }}</span>
        </el-form-item>
        <el-form-item label="事由">
          <el-input v-model="remark" :placeholder="`默认：${sets} 套领料`" maxlength="200" />
        </el-form-item>
      </el-form>

      <el-alert type="warning" :closable="false" show-icon class="issue-rule">
        <template #title>库存不足的行会整行跳过</template>
        只出库存完全够的行。不够的不动库存（避免扣了一半料却装不出板），
        出库后会列出这些行，方便据此下采购单。
      </el-alert>
    </template>

    <!-- 出库后：结果汇总 + 明细 -->
    <template v-else>
      <div class="ui-sumstrip">
        <div class="ui-sumcell">
          <span class="ui-sumlabel">已出库</span>
          <span class="ui-sumvalue is-ok">{{ result.issuedLines }} 行</span>
        </div>
        <div class="ui-sumcell">
          <span class="ui-sumlabel">出库总数</span>
          <span class="ui-sumvalue">{{ result.issuedQty }}</span>
        </div>
        <div class="ui-sumcell" :class="{ 'is-warn': result.skippedLines > 0 }">
          <span class="ui-sumlabel">跳过（缺料）</span>
          <span class="ui-sumvalue">{{ result.skippedLines }} 行</span>
        </div>
        <div class="ui-sumcell" :class="{ 'is-warn': result.shortageQty > 0 }">
          <span class="ui-sumlabel">需采购总数</span>
          <span class="ui-sumvalue">{{ result.shortageQty }}</span>
        </div>
      </div>

      <el-tabs v-model="resultTab" class="result-tabs">
        <el-tab-pane :label="`缺料未出库 (${result.skippedLines})`" name="skipped">
          <el-table
            :data="result.skipped"
            border
            stripe
            size="small"
            max-height="300"
            empty-text="没有缺料，全部出库成功"
          >
            <el-table-column prop="seq" label="序号" width="62" align="right" class-name="col-num" />
            <el-table-column prop="name" label="名称" min-width="120" show-overflow-tooltip />
            <el-table-column prop="mfr_pn" label="制造商料号" min-width="140" show-overflow-tooltip>
              <template #default="{ row }">{{ row.mfr_pn || '—' }}</template>
            </el-table-column>
            <el-table-column prop="required" label="需求" width="70" align="right" class-name="col-num" />
            <el-table-column label="可用" width="70" align="right" class-name="col-num">
              <template #default="{ row }">{{ row.stock === null ? '0' : row.stock }}</template>
            </el-table-column>
            <el-table-column prop="shortage" label="缺" width="70" align="right" class-name="col-num">
              <template #default="{ row }">
                <span class="is-short">-{{ row.shortage }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="reason" label="原因" min-width="150" show-overflow-tooltip />
          </el-table>
        </el-tab-pane>

        <el-tab-pane :label="`已出库 (${result.issuedLines})`" name="issued">
          <el-table
            :data="result.issued"
            border
            stripe
            size="small"
            max-height="300"
            empty-text="没有任何行出库成功"
          >
            <el-table-column prop="seq" label="序号" width="62" align="right" class-name="col-num" />
            <el-table-column prop="name" label="名称" min-width="120" show-overflow-tooltip />
            <el-table-column prop="mfr_pn" label="制造商料号" min-width="150" show-overflow-tooltip>
              <template #default="{ row }">{{ row.mfr_pn || '—' }}</template>
            </el-table-column>
            <el-table-column prop="issued" label="出库" width="80" align="right" class-name="col-num">
              <template #default="{ row }">
                <span class="is-ok">-{{ row.issued }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="stockAfter" label="剩余库存" width="90" align="right" class-name="col-num" />
          </el-table>
        </el-tab-pane>
      </el-tabs>

      <div class="result-note">
        出库流水已记账，随时可点产品行的「出入库记录」按钮查询。
      </div>
    </template>

    <template #footer>
      <template v-if="!done">
        <el-button @click="cancel" :disabled="submitting">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="submit">
          确认出库 {{ sets }} 套
        </el-button>
      </template>
      <template v-else>
        <el-button v-if="result.skippedLines > 0" @click="exportShortage">导出缺料清单</el-button>
        <el-button type="primary" @click="emit('update:visible', false)">完成</el-button>
      </template>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, watch } from 'vue';

const props = defineProps({
  visible: { type: Boolean, default: false },
  productCode: { type: String, default: '' },
  bomLines: { type: Number, default: 0 },
  defaultSets: { type: Number, default: 1 },
  submitting: { type: Boolean, default: false },
  // 出库完成后由父组件把接口返回塞进来，非空即切到结果视图
  result: { type: Object, default: null },
});

const emit = defineEmits(['update:visible', 'submit']);

const sets = ref(1);
const remark = ref('');
const resultTab = ref('skipped');
const done = ref(false);

// result 由父组件在出库成功后赋值，这里自动切到结果视图，
// 避免父子之间用 ref 调方法的耦合
watch(
  () => props.result,
  (r) => {
    if (!r) return;
    done.value = true;
    // 有缺料先看缺料，否则看已出库
    resultTab.value = r.skippedLines > 0 ? 'skipped' : 'issued';
  }
);

function onOpen() {
  sets.value = props.defaultSets || 1;
  remark.value = '';
  resultTab.value = 'skipped';
  done.value = false;
}

function onClosed() {
  done.value = false;
  remark.value = '';
}

function cancel() {
  if (props.submitting) return;
  emit('update:visible', false);
}

function submit() {
  emit('submit', { sets: sets.value, remark: remark.value.trim() });
}

function csvCell(v) {
  const s = v === null || v === undefined ? '' : String(v);
  return /[",\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
}

/** 缺料清单导出成 CSV，直接拿去下单 */
function exportShortage() {
  const cols = [
    ['seq', '序号'], ['name', '名称'], ['designator', '位号'],
    ['mfr_pn', '制造商料号'], ['required', '需求'], ['stock', '可用库存'],
    ['shortage', '缺料'], ['reason', '原因'],
  ];
  const lines = [cols.map(([, l]) => csvCell(l)).join(',')];
  for (const row of props.result.skipped) {
    lines.push(cols.map(([k]) => csvCell(k === 'stock' && row[k] === null ? 0 : row[k])).join(','));
  }
  const blob = new Blob(['\uFEFF' + lines.join('\r\n')], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  const ts = new Date().toISOString().slice(0, 10);
  a.href = url;
  a.download = `ompcb-缺料清单-${props.productCode}-${props.result.sets}套-${ts}.csv`;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
}
</script>

<style scoped>
/* 套数旁边的内联提示：仅 token 字号，不换 .ui-hint(那个 11px 块级，跟 inline 场景不合) */
.form-inline-hint {
  margin-left: 10px;
  font-size: var(--fs-sm);
  color: var(--c-text-3);
}
.issue-rule { margin-top: 4px; }
/* el-alert 描述全局没动(只动了 .el-popper.is-dark)，12px 仍要靠这条压住 */
.issue-rule :deep(.el-alert__description) {
  font-size: var(--fs-sm);
  line-height: 1.5;
}

/* 表内"缺料/已出库"小数字：全局 .is-ok/.is-short 只管颜色，
   el-table cell 不继承 600，这里补 bold 才对得起告警/已落实的语义 */
.is-ok    { font-weight: 600; }
.is-short { font-weight: 600; }

/* dialog 里的 el-tabs 不在 .app-tabs 下，全局 .app-tabs>header{margin:0} 命中不到，
   仍要靠这条把 tabs header 跟下方表格收紧到 8px */
.result-tabs :deep(.el-tabs__header) { margin-bottom: 8px; }

.result-note {
  margin-top: 8px;
  font-size: var(--fs-sm);
  color: var(--c-text-3);
}

/* 数字列等宽，跟页面 stats-strip 一致 */
.ui-sumvalue { font-family: var(--font-mono); }
</style>
