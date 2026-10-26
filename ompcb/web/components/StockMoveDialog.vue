<template>
  <el-dialog
    :model-value="visible"
    :title="title"
    width="480px"
    :close-on-click-modal="false"
    :close-on-press-escape="!submitting"
    :show-close="!submitting"
    @update:model-value="(v) => emit('update:visible', v)"
    @open="onOpen"
    @closed="onClosed"
  >
    <div v-if="item" class="ui-target">
      <div class="ui-target-name">{{ item.name || item.mfr_pn || item.supplier_pn || '—' }}</div>
      <div class="ui-target-meta">
        <span v-if="item.package">{{ item.package }}</span>
        <span v-if="item.supplier_pn">{{ item.supplier_pn }}</span>
        <span v-if="item.location">位置 {{ item.location }}</span>
      </div>
    </div>

    <el-form label-width="82px" label-position="right" @submit.prevent>
      <el-form-item label="操作类型">
        <el-radio-group v-model="type" size="small">
          <el-radio-button label="入库" />
          <el-radio-button label="出库" />
          <el-radio-button label="盘点" />
        </el-radio-group>
      </el-form-item>

      <el-form-item :label="qtyLabel">
        <el-input-number
          v-model="qty"
          :min="type === '盘点' ? 0 : 1"
          :max="type === '出库' ? currentStock : undefined"
          :step="1"
          controls-position="right"
          style="width: 100%"
        />
      </el-form-item>

      <el-form-item label="事由">
        <el-input v-model="remark" placeholder="如 领用做样板 / 立创到货" maxlength="200" />
      </el-form-item>

      <!-- 出库可绑定到产品 + BOM 行（追溯已焊接进度），仅 type='出库' 显示。
           默认不绑，样品/损耗/调拨等无产品归属的出库保持原样不强制填写。
           不传 productId/materialId 走原有的未绑定出库分支，与老调用字节级一致。 -->
      <template v-if="type === '出库'">
        <el-form-item label="绑定产品">
          <el-select
            v-model="productId"
            placeholder="不绑定（样品/损耗/调拨请留空）"
            clearable
            filterable
            size="small"
            style="width: 100%"
            :loading="productsLoading"
            :disabled="!canBind"
            @change="onProductChange"
          >
            <el-option
              v-for="p in products"
              :key="p.id"
              :label="p.name ? `${p.code} · ${p.name}` : p.code"
              :value="p.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item v-if="productId" label="绑定 BOM 行">
          <el-select
            v-model="materialId"
            placeholder="选 BOM 行（仅列出与本元件料号匹配的行）"
            clearable
            filterable
            size="small"
            style="width: 100%"
            :loading="materialsLoading"
            :disabled="!canBind"
          >
            <el-option
              v-for="m in matchedMaterials"
              :key="m.id"
              :label="materialLabel(m)"
              :value="m.id"
            />
          </el-select>
        </el-form-item>
        <div v-if="!canBind" class="move-binding-hint">
          库存台账行没有制造商料号，无法与 BOM 行匹配；留空即可按未绑定出库处理
        </div>
        <div v-else-if="productId && !materialsLoading && matchedMaterials.length === 0" class="move-binding-hint">
          该产品下没有与本元件（料号 {{ item?.mfr_pn || '—' }}）匹配的 BOM 行
        </div>
        <div v-else-if="qtyFillHint" class="move-binding-hint" :class="{ 'is-warn': qtyFillClamped }">
          {{ qtyFillHint }}
        </div>
      </template>
    </el-form>

    <div class="ui-panel move-preview" :class="{ 'is-invalid': !valid }">
      <span class="move-preview-label">变动后库存</span>
      <span class="move-preview-flow">
        <span class="from">{{ currentStock }}</span>
        <span class="arrow">→</span>
        <span class="to">{{ previewStock }}</span>
        <span class="delta" :class="deltaClass">{{ deltaText }}</span>
      </span>
    </div>
    <div v-if="!valid" class="move-error">{{ invalidReason }}</div>

    <template #footer>
      <el-button @click="cancel" :disabled="submitting">取消</el-button>
      <el-button type="primary" :loading="submitting" :disabled="!valid" @click="submit">
        确认{{ type }}
      </el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { computed, ref, watch } from 'vue';
import { listProducts, listMaterials } from '../api.js';
import { countDesignators } from '../designator.js';

const props = defineProps({
  visible: { type: Boolean, default: false },
  item: { type: Object, default: null },
  defaultType: { type: String, default: '入库' },   // '入库' | '出库' | '盘点'
  submitting: { type: Boolean, default: false },
});

const emit = defineEmits(['update:visible', 'submit']);

const type = ref('入库');
const qty = ref(1);
const remark = ref('');

// 出库绑定：默认 null（不绑定），后端对未绑定出库完全保持原行为。
// 仅当用户在 UI 里真正选了一个值时才把对应键放进 submit body（详见 onSubmit）。
const productId = ref(null);
const materialId = ref(null);

const products = ref([]);
const productsLoading = ref(false);
const materials = ref([]);
const materialsLoading = ref(false);

const currentStock = computed(() => Number(props.item?.stock ?? 0));

// mfr_pn 是台账与 BOM 的唯一关联依据；空了就永远绑不上。
// 不可绑的场景：item 没有 mfr_pn 时直接禁掉两个下拉并提示，
// 而不是让用户选了再被后端 400 退回来。
const canBind = computed(() => !!(props.item?.mfr_pn && String(props.item.mfr_pn).trim()));

// 选中的产品下、与本元件 mfr_pn 匹配的 BOM 行。空 mfr_pn 时返回空数组。
const matchedMaterials = computed(() => {
  const pn = String(props.item?.mfr_pn || '').trim();
  if (!pn) return [];
  return materials.value.filter(m => m.mfr_pn === pn);
});

const title = computed(() => {
  if (type.value === '盘点') return '库存盘点';
  return type.value === '出库' ? '出库登记' : '入库登记';
});

const qtyLabel = computed(() => (type.value === '盘点' ? '实盘库存' : `${type.value}数量`));

const previewStock = computed(() => {
  const n = Math.max(0, Math.floor(Number(qty.value) || 0));
  if (type.value === '入库') return currentStock.value + n;
  if (type.value === '出库') return currentStock.value - n;
  return n; // 盘点：直接以实盘数为准
});

const delta = computed(() => previewStock.value - currentStock.value);

const deltaText = computed(() => {
  if (delta.value === 0) return '无变化';
  return delta.value > 0 ? `+${delta.value}` : String(delta.value);
});

const deltaClass = computed(() => {
  if (delta.value > 0) return 'is-in';
  if (delta.value < 0) return 'is-out';
  return 'is-flat';
});

const invalidReason = computed(() => {
  const n = Math.floor(Number(qty.value) || 0);
  if (type.value !== '盘点' && n <= 0) return '出入库数量必须大于 0';
  if (previewStock.value < 0) return `库存不足：当前 ${currentStock.value}，无法出库 ${n}`;
  return '';
});

const valid = computed(() => invalidReason.value === '');

// --- 按位号个数自动填出库数量 ---
//
// 位号（如 `R1,R32`）个数就是这块板上要焊几个，等于领料数量。
// 手动数 27 个 C 位号再敲进去既慢又容易错，所以选中 BOM 行后直接填好。
//
// 只在「选中 BOM 行」这一个时机填，之后用户改数字不再覆盖——
// 自动填是省事，不是强制；实际领料可能有损耗备件等正当偏差。

/** 当前选中的 BOM 行对象 */
const selectedMaterial = computed(
  () => matchedMaterials.value.find(m => m.id === materialId.value) || null
);

/** 选中行的位号个数；无选中或位号为空时为 0 */
const designatorCount = computed(() => countDesignators(selectedMaterial.value?.designator));

// 自动填入后被 el-input-number 的 :max="currentStock" clamp 掉的情况。
// Element Plus 的 verifyValue 会把超 max 的值静默压回 max 并回写 modelValue，
// 若不明说，用户会以为「按位号填好了」而不知道其实只填到了库存上限。
const qtyFillClamped = ref(false);

const qtyFillHint = computed(() => {
  if (!materialId.value) return '';
  const n = designatorCount.value;
  if (n === 0) {
    // 位号为空的 BOM 行填不出数量，保持用户当前输入，明说原因避免以为功能坏了
    return '该 BOM 行没有填位号，出库数量未自动填入，请手动确认';
  }
  if (qtyFillClamped.value) {
    return `该行位号 ${n} 个，但库存只有 ${currentStock.value}，已按库存上限填入；差额需采购后再领`;
  }
  return `已按该行位号个数自动填入 ${n}（位号：${selectedMaterial.value?.designator || '—'}）`;
});

// 选中/切换 BOM 行时填数量。清空选择（materialId=null）时不动 qty：
// 用户可能已经手动调过数字，取消绑定不该顺手把它改回 1。
watch(materialId, (id) => {
  if (!id) {
    qtyFillClamped.value = false;
    return;
  }
  const n = designatorCount.value;
  if (n <= 0) {
    // 位号为空：填不出有意义的数量，保持原值（出库最小值是 1，填 0 反而非法）
    qtyFillClamped.value = false;
    return;
  }
  // 超出库存时先压到库存上限，让 qtyFillHint 能如实说明，
  // 而不是让 el-input-number 静默 clamp 之后用户毫不知情。
  qtyFillClamped.value = n > currentStock.value;
  qty.value = qtyFillClamped.value ? currentStock.value : n;
});

// --- 切回入库/盘点时清掉绑定状态：避免 stale productId/materialId 跟着下一次出库走。
//     切到出库则不动，等用户在 UI 里选；onOpen 会在 dialog 打开时根据 defaultType 重置。 ---
watch(type, (t) => {
  qty.value = t === '盘点' ? currentStock.value : 1;
  if (t !== '出库') {
    productId.value = null;
    materialId.value = null;
    qtyFillClamped.value = false;
  }
});

function onOpen() {
  type.value = props.defaultType || '入库';
  qty.value = type.value === '盘点' ? currentStock.value : 1;
  remark.value = '';
  // 每次开窗都清空绑定：上次的选中与本次的 item 不一定匹配。
  productId.value = null;
  materialId.value = null;
  materials.value = [];
  qtyFillClamped.value = false;
  // 产品列表只拉一次（条目数与产品台账同量级，对话框高频打开不重复打接口）。
  if (products.value.length === 0) loadProducts();
}

function onClosed() {
  qty.value = 1;
  remark.value = '';
  productId.value = null;
  materialId.value = null;
  materials.value = [];
  qtyFillClamped.value = false;
}

async function loadProducts() {
  productsLoading.value = true;
  try {
    const data = await listProducts();
    products.value = data.list || [];
  } catch {
    // 拉产品失败：保持空数组，下拉显示「无数据」但不阻塞出库（未绑定也能提交）
  } finally {
    productsLoading.value = false;
  }
}

async function loadMaterials(pid) {
  if (!pid) {
    materials.value = [];
    return;
  }
  materialsLoading.value = true;
  try {
    const data = await listMaterials({ productId: pid, pageSize: 500 });
    materials.value = data.list || [];
  } catch {
    materials.value = [];
  } finally {
    materialsLoading.value = false;
  }
}

// 产品换了：BOM 行集合变了，旧的 materialId 必然失效，必须清掉再异步拉新行。
function onProductChange(v) {
  materialId.value = null;
  loadMaterials(v);
}

function materialLabel(m) {
  // 位号是硬件人最常用的识别符（同一料号可能占多行不同位号），其次是名称。
  // 没有位号时退化成纯名称。
  const code = m.designator || '';
  const name = m.name || '';
  if (code && name) return `${code} · ${name}`;
  return code || name || `BOM #${m.id}`;
}

function cancel() {
  if (props.submitting) return;
  emit('update:visible', false);
}

function submit() {
  if (!valid.value) return;
  // 严格只把用户实际选了的键带上；materialId=0/null/undefined 一律不带。
  // 这样默认（未绑定）出库发出的 body 仍是 { type, qty, remark }，与改造前一致。
  const payload = {
    type: type.value,
    qty: Math.max(0, Math.floor(Number(qty.value) || 0)),
    remark: remark.value.trim(),
  };
  if (type.value === '出库' && productId.value) {
    payload.productId = productId.value;
    if (materialId.value) payload.materialId = materialId.value;
  }
  emit('submit', payload);
}
</script>

<style scoped>
/* 目标横幅：复用全局 .ui-target；表单前 14px 间距由本地补，不动全局 */
.ui-target { margin-bottom: 14px; }

/* meta 多段(封装/供应商料号/位置)用 flex 排，加 mono 让料号对得齐 */
.ui-target-meta {
  display: flex;
  gap: 10px;
  font-family: var(--font-mono);
}

/* 变动预览：外壳交给 .ui-panel，保留 flex 让 label | flow 两端对齐 */
.move-preview {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
/* 非法态用 warn 配色覆盖 .ui-panel 默认皮肤，不动 .ui-panel 本体 */
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
/* "变动后库存"是这个 dialog 的视觉核心：--fs-lg + 600 撑住，delta 芯片退到次要 */
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
.delta.is-in   { color: var(--c-success); background: var(--c-success-soft); }
.delta.is-out  { color: var(--c-warn); background: var(--c-warn-soft); }
.delta.is-flat { color: var(--c-text-3); background: var(--c-sunken-2); }
.move-error {
  margin-top: 6px;
  font-size: var(--fs-sm);
  color: var(--c-warn);
}

/* 绑定可用性提示：解释为什么下拉是空的，避免让用户对着「无数据」发愣。
   也承载「已按位号 N 个自动填入」的数量来源说明。 */
.move-binding-hint {
  margin: -8px 0 12px 0;
  padding: 0 2px;
  font-size: 12px;
  color: var(--c-text-3);
  line-height: 1.5;
}
/* 位号个数超过库存、数量被压到库存上限时提级为告警色：
   这时填入值 ≠ 位号个数，属于需要用户注意的偏差，不能跟普通说明同色。 */
.move-binding-hint.is-warn {
  color: var(--c-warn);
}
</style>
