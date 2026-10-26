<template>
  <el-dialog
    :model-value="visible"
    title="出库登记"
    width="460px"
    :close-on-click-modal="false"
    :close-on-press-escape="!submitting"
    :show-close="!submitting"
    @update:model-value="(v) => emit('update:visible', v)"
    @open="material ? onOpen() : undefined"
    @closed="onClosed"
  >
    <template v-if="material">
      <!-- BOM 行信息 -->
      <div class="ui-target">
        <div class="ui-target-name">{{ material.name || '—' }}</div>
        <div class="ui-target-meta">
          <span v-if="material.designator">位号 {{ material.designator }}</span>
          <span v-if="material.package">{{ material.package }}</span>
          <span v-if="material.mfr_pn">{{ material.mfr_pn }}</span>
        </div>
      </div>

      <el-form label-width="82px" label-position="right" @submit.prevent>
        <el-form-item label="库存">
          <div class="stock-info">
            <span class="stock-value">{{ currentStock }}</span>
            <span class="stock-location" v-if="material.location">@ {{ material.location }}</span>
          </div>
        </el-form-item>

        <el-form-item label="位号个数">
          <span class="designator-count">{{ designatorCount }} 个</span>
          <span v-if="!material.designator" class="hint-text">（该行没有填位号）</span>
        </el-form-item>

        <el-form-item label="出库数量">
          <el-input-number
            v-model="qty"
            :min="1"
            :max="currentStock"
            :step="1"
            controls-position="right"
            style="width: 100%"
          />
        </el-form-item>

        <!-- 数量来源说明：位号个数 / 被库存压到上限 / 多套时的总需求 -->
        <div v-if="hint" class="issue-hint" :class="{ 'is-warn': hintWarn }">
          {{ hint }}
        </div>

        <el-form-item label="事由">
          <el-input v-model="remark" placeholder="如 领用焊接 / 补料" maxlength="200" />
        </el-form-item>
      </el-form>

      <!-- 变动预览：复用 .ui-panel 样式 -->
      <div class="ui-panel move-preview" :class="{ 'is-invalid': !valid }">
        <span class="move-preview-label">变动后库存</span>
        <span class="move-preview-flow">
          <span class="from">{{ currentStock }}</span>
          <span class="arrow">→</span>
          <span class="to">{{ previewStock }}</span>
          <span class="delta is-out">-{{ effectiveQty }}</span>
        </span>
      </div>
      <div v-if="!valid" class="move-error">{{ invalidReason }}</div>
    </template>

    <template #footer>
      <el-button @click="cancel" :disabled="submitting">取消</el-button>
      <el-button type="primary" :loading="submitting" :disabled="!valid" @click="submit">
        确认出库
      </el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { computed, ref } from 'vue'
import { countDesignators } from '../designator.js'

const props = defineProps({
  visible: { type: Boolean, default: false },
  /**
   * BOM 行对象（来自 selectWithStock，含 inventory_id / stock / designator / product_id 等）。
   * 允许为 null：本 dialog 常驻挂载（见 BomPanel 里的用法注释），
   * 首次渲染时还没有选中行。
   */
  material: { type: Object, default: null },
  submitting: { type: Boolean, default: false },
})

const emit = defineEmits(['update:visible', 'submit'])

const qty = ref(1)
const remark = ref('')

// ---------- 派生计算 ----------

const currentStock = computed(() => Number(props.material?.stock ?? 0))

const designatorCount = computed(() => countDesignators(props.material?.designator))

/** 实际用于预览的数量（用户当前输入） */
const effectiveQty = computed(() => Math.max(0, Math.floor(Number(qty.value) || 0)))

const previewStock = computed(() => currentStock.value - effectiveQty.value)

const valid = computed(() => {
  if (!props.material) return false
  const n = effectiveQty.value
  if (n <= 0) return false
  if (previewStock.value < 0) return false
  return true
})

const invalidReason = computed(() => {
  if (!props.material) return ''
  const n = effectiveQty.value
  if (n <= 0) return '出库数量必须大于 0'
  if (previewStock.value < 0) return `库存不足：当前 ${currentStock.value}，无法出库 ${n}`
  return ''
})

// ---------- 数量来源说明 ----------
//
// 出库数量只由位号个数决定，与工具栏的「制作 N 套」无关：
// 套数是需求量/缺料的计算参数（用量 × 套数），不是出库扣减依据。
// 想按套数一次领满请用工具栏「批量出库」，那里套数才参与扣减。

/**
 * 打开时按位号个数自动填入，但被库存上限压掉了。
 * 必须明说，否则用户会以为「按位号填好了」而不知实际只填到库存上限。
 */
const qtyClamped = ref(false)

const hint = computed(() => {
  if (!props.material) return ''
  const dc = designatorCount.value

  // 位号为空：填不出数量，说明原因避免以为功能坏了
  if (dc <= 0) {
    return '该行没有填位号，出库数量未自动填入，请手动确认'
  }

  // 位号个数超库存：数量被压到上限，填入值 ≠ 位号个数，必须点明
  if (qtyClamped.value) {
    return `该行位号 ${dc} 个，但库存只有 ${currentStock.value}，已按库存上限填入；差额需采购后再领。`
  }

  return `已按该行位号个数填入 ${dc}（位号：${props.material?.designator || '—'}）`
})

/** 位号为空、或数量被库存压掉时提级为告警色 */
const hintWarn = computed(() => designatorCount.value <= 0 || qtyClamped.value)

// ---------- 生命周期 ----------

function onOpen() {
  // 默认数量 = 位号个数（该行在单板上要焊几个），超库存时压到库存上限并由 hint 说明。
  // 没有位号时回退到 1：出库最小值是 1，填 0 反而非法。
  const dc = designatorCount.value
  if (dc > 0) {
    qtyClamped.value = dc > currentStock.value
    qty.value = qtyClamped.value ? currentStock.value : dc
  } else {
    qtyClamped.value = false
    qty.value = 1
  }
  remark.value = ''
}

function onClosed() {
  qty.value = 1
  remark.value = ''
  qtyClamped.value = false
}

function cancel() {
  if (props.submitting) return
  emit('update:visible', false)
}

function submit() {
  if (!valid.value || !props.material) return
  const payload = {
    inventoryId: props.material.inventory_id,
    qty: effectiveQty.value,
    productId: props.material.product_id,
    materialId: props.material.id,
    remark: remark.value.trim(),
  }
  emit('submit', payload)
}
</script>

<style scoped>
/* 目标横幅：与 StockMoveDialog 一致的间距 */
.ui-target { margin-bottom: 14px; }

/* meta 多段用 flex 排，mono 让料号对得齐 */
.ui-target-meta {
  display: flex;
  gap: 10px;
  font-family: var(--font-mono);
}

/* 库存信息行：数值 + 位置 */
.stock-info {
  display: flex;
  align-items: center;
  gap: 8px;
}
.stock-value {
  font-family: var(--font-mono);
  font-weight: 600;
  font-size: var(--fs-base);
}
.stock-location {
  font-size: var(--fs-sm);
  color: var(--c-text-3);
  font-family: var(--font-mono);
}

/* 位号个数 */
.designator-count {
  font-family: var(--font-mono);
  font-weight: 600;
}
.hint-text {
  font-size: var(--fs-sm);
  color: var(--c-text-3);
  margin-left: 4px;
}

/* 套数提示：复用 StockMoveDialog 的移动绑定提示样式 */
.issue-hint {
  margin: -8px 0 12px 0;
  padding: 0 2px;
  font-size: 12px;
  color: var(--c-text-3);
  line-height: 1.5;
}
.issue-hint.is-warn {
  color: var(--c-warn);
}

/* 变动预览 */
.move-preview {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.move-preview.is-invalid {
  background: var(--c-warn-soft);
  border-color: var(--c-warn-border);
}
.move-preview-label {
  font-size: var(--fs-sm);
  color: var(--c-text-3);
}
.move-preview-flow {
  display: flex;
  align-items: baseline;
  gap: 8px;
  font-family: var(--font-mono);
}
.move-preview-flow .from {
  color: var(--c-text-3);
}
.move-preview-flow .arrow {
  color: var(--c-muted);
}
.move-preview-flow .to {
  font-size: var(--fs-lg);
  font-weight: 600;
  color: var(--c-text);
}
.delta {
  font-size: var(--fs-sm);
  padding: 1px 5px;
  border-radius: 2px;
}
.delta.is-out {
  color: var(--c-warn);
  background: var(--c-warn-soft);
}
.move-error {
  margin-top: 6px;
  font-size: var(--fs-sm);
  color: var(--c-warn);
}
</style>