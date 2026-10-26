<template>
  <el-dialog
    :model-value="visible"
    :title="title"
    width="640px"
    :close-on-click-modal="false"
    :close-on-press-escape="!saving"
    :show-close="!saving"
    @update:model-value="(v) => emit('update:visible', v)"
    @open="onOpen"
    @closed="onClosed"
  >
    <el-form
      ref="formRef"
      :model="form"
      :rules="rules"
      label-width="92px"
      label-position="right"
      class="material-form"
      @submit.prevent
    >
      <el-row :gutter="12">
        <el-col :span="8">
          <el-form-item label="序号" prop="seq">
            <el-input-number v-model="form.seq" :min="0" :step="1" controls-position="right" style="width:100%" />
          </el-form-item>
        </el-col>
        <el-col :span="16">
          <el-form-item label="名称" prop="name">
            <el-input v-model="form.name" placeholder="如 1MΩ、100nF" maxlength="120" show-word-limit />
          </el-form-item>
        </el-col>
      </el-row>

      <el-form-item label="位号" prop="designator">
        <el-input v-model="form.designator" placeholder="如 R1,R32,R33（逗号分隔）" />
      </el-form-item>

      <el-row :gutter="12">
        <el-col :span="14">
          <el-form-item label="封装" prop="package">
            <el-input v-model="form.package" placeholder="如 R0402、C0402" />
          </el-form-item>
        </el-col>
        <el-col :span="10">
          <el-form-item label="数量" prop="qty">
            <el-input-number v-model="form.qty" :min="0" :step="1" controls-position="right" style="width:100%" />
          </el-form-item>
        </el-col>
      </el-row>

      <el-form-item label="制造商料号" prop="mfr_pn">
        <el-input v-model="form.mfr_pn" placeholder="填写后自动关联库存（关联依据）" />
        <div class="ui-hint">库存、状态、位置靠这个料号关联，留空则无法匹配库存</div>
      </el-form-item>

      <el-row :gutter="12">
        <el-col :span="12">
          <el-form-item label="制造商" prop="mfr">
            <el-input v-model="form.mfr" placeholder="如 UNI-ROYAL(厚声)" />
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="供应商" prop="supplier">
            <el-input v-model="form.supplier" placeholder="如 LCSC" />
          </el-form-item>
        </el-col>
      </el-row>

      <el-form-item label="供应商料号" prop="supplier_pn">
        <el-input v-model="form.supplier_pn" placeholder="如 C26083" />
      </el-form-item>

      <el-form-item label="备注" prop="remark">
        <el-input v-model="form.remark" type="textarea" :rows="2" />
      </el-form-item>
    </el-form>

    <!-- 库存信息只读展示：这几项属于库存台账，不在 BOM 里维护 -->
    <div class="ui-panel inv-linked">
      <div class="inv-linked-head">
        <span class="inv-linked-title">库存关联信息</span>
        <span class="inv-linked-note">按制造商料号自动匹配 · 如需修改请到「库存台账」</span>
      </div>

      <div v-if="!linkedMfrPn" class="inv-linked-empty">
        填写制造商料号后才能关联库存
      </div>
      <div v-else-if="!linked" class="inv-linked-empty is-warn">
        库存台账中查无此料号（{{ linkedMfrPn }}）
      </div>
      <div v-else class="ui-sumstrip inv-linked-grid">
        <div class="ui-sumcell">
          <span class="ui-sumlabel">状态</span>
          <el-tag :type="statusTagType(linked.status)" size="small" effect="light">
            {{ linked.status || '—' }}
          </el-tag>
        </div>
        <div class="ui-sumcell">
          <span class="ui-sumlabel">库存</span>
          <span class="ui-sumvalue">{{ linked.stock }}</span>
        </div>
        <div class="ui-sumcell">
          <span class="ui-sumlabel">位置</span>
          <span class="ui-sumvalue">{{ linked.location || '—' }}</span>
        </div>
        <div class="ui-sumcell">
          <span class="ui-sumlabel">缺料</span>
          <span
            class="ui-sumvalue"
            :class="shortage > 0 ? 'is-short' : 'is-ok'"
          >{{ shortage > 0 ? `-${shortage}` : '足' }}</span>
        </div>
      </div>
    </div>

    <template #footer>
      <el-button @click="cancel" :disabled="saving">取消</el-button>
      <el-button type="primary" :loading="saving" @click="submit">保存</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { computed, reactive, ref } from 'vue';

const props = defineProps({
  visible: { type: Boolean, default: false },
  mode: { type: String, default: 'create' },     // 'create' | 'edit'
  source: { type: Object, default: null },       // existing row when editing
  saving: { type: Boolean, default: false },
});

const emit = defineEmits(['update:visible', 'save']);

const title = computed(() => (props.mode === 'edit' ? '编辑 BOM 明细' : '新增 BOM 明细'));

// BOM 自有字段。刻意不含 status / stock / location —— 那三项属于库存台账
const blankForm = () => ({
  seq: 0,
  name: '',
  designator: '',
  package: '',
  qty: 0,
  mfr_pn: '',
  mfr: '',
  supplier: '',
  supplier_pn: '',
  remark: '',
});

const form = reactive(blankForm());
const formRef = ref(null);

const rules = {
  name: [
    { required: true, message: '名称不能为空', trigger: 'blur' },
    { max: 120, message: '长度不能超过 120', trigger: 'blur' },
  ],
};

// 编辑时展示后端 JOIN 出来的库存匹配结果（新增时还没有）
const linkedMfrPn = computed(() => form.mfr_pn.trim() || props.source?.mfr_pn || '');
const linked = computed(() => {
  const s = props.source;
  if (!s || !s.inventory_id) return null;
  // 料号被改过后旧的匹配结果就不再可信
  if (form.mfr_pn.trim() !== (s.mfr_pn ?? '')) return null;
  return { status: s.status, stock: s.stock, location: s.location };
});

const shortage = computed(() => {
  if (!linked.value) return 0;
  const diff = Number(form.qty || 0) - Number(linked.value.stock || 0);
  return diff > 0 ? diff : 0;
});

// 状态只有两种：正常（绿=安全）/ 缺货（红=要处理）
function statusTagType(status) {
  return status === '缺货' ? 'danger' : 'success';
}

function fillFromSource() {
  const s = props.source;
  if (!s) {
    Object.assign(form, blankForm());
    return;
  }
  form.seq         = Number(s.seq ?? 0);
  form.name        = s.name ?? '';
  form.designator  = s.designator ?? '';
  form.package     = s.package ?? '';
  form.qty         = Number(s.qty ?? 0);
  form.mfr_pn      = s.mfr_pn ?? '';
  form.mfr         = s.mfr ?? '';
  form.supplier    = s.supplier ?? '';
  form.supplier_pn = s.supplier_pn ?? '';
  form.remark      = s.remark ?? '';
}

function onOpen() {
  fillFromSource();
  formRef.value?.clearValidate?.();
}

function onClosed() {
  Object.assign(form, blankForm());
  formRef.value?.clearValidate?.();
}

function cancel() {
  if (props.saving) return;
  emit('update:visible', false);
}

async function submit() {
  if (!formRef.value) return;
  try {
    await formRef.value.validate();
  } catch {
    return; // validation surfaced inline
  }
  // 只提交 BOM 自有字段；status/stock/location 由库存台账维护
  emit('save', {
    seq: form.seq || 0,
    name: form.name.trim(),
    designator: form.designator.trim(),
    package: form.package.trim(),
    qty: form.qty || 0,
    mfr_pn: form.mfr_pn.trim(),
    mfr: form.mfr.trim(),
    supplier: form.supplier.trim(),
    supplier_pn: form.supplier_pn.trim(),
    remark: form.remark.trim(),
  });
}
</script>

<style scoped>
/* 关联信息块：外壳交给全局 .ui-panel，只保留与表单的 4px 间距 */
.inv-linked { margin-top: 4px; }

/* 标题行：原来是 accent-soft 顶栏，放进 .ui-panel 后改成纯文字标题，
   让 .ui-target 类的色块语义(信号条)不被到处稀释 */
.inv-linked-head {
  display: flex;
  align-items: baseline;
  gap: 8px;
  margin-bottom: 10px;
}
.inv-linked-title {
  font-size: var(--fs-sm);
  font-weight: 600;
  color: var(--c-text);
}
.inv-linked-note {
  font-size: var(--fs-meta);
  color: var(--c-text-3);
}
.inv-linked-empty {
  font-size: var(--fs-sm);
  color: var(--c-text-3);
  line-height: 1.5;
}
.inv-linked-empty.is-warn {
  color: var(--c-warn);
  background: var(--c-warn-soft);
  padding: 8px 10px;
  border-radius: 3px;
}

/* 数字列用等宽，跟 .stat-value 对齐——密集工具的"数字"就该是 mono */
.ui-sumvalue { font-family: var(--font-mono); }
</style>
