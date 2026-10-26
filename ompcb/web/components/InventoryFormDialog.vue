<template>
  <el-dialog
    :model-value="visible"
    :title="title"
    width="620px"
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
        <el-col :span="14">
          <el-form-item label="名称" prop="name">
            <el-input v-model="form.name" placeholder="如 1MΩ、100nF" maxlength="120" show-word-limit />
          </el-form-item>
        </el-col>
        <el-col :span="10">
          <el-form-item label="封装" prop="package">
            <el-input v-model="form.package" placeholder="如 R0402" />
          </el-form-item>
        </el-col>
      </el-row>

      <el-form-item label="制造商料号" prop="mfr_pn">
        <el-input v-model="form.mfr_pn" placeholder="如 0402WGF1004TCE" />
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
        <el-input v-model="form.supplier_pn" placeholder="如 C26083（唯一，可留空）" />
      </el-form-item>

      <el-row :gutter="12">
        <el-col :span="12">
          <el-form-item :label="mode === 'edit' ? '当前库存' : '初始库存'" prop="stock">
            <el-input-number
              v-if="mode === 'create'"
              v-model="form.stock" :min="0" :step="1" controls-position="right" style="width:100%"
            />
            <div v-else class="ui-panel stock-readonly">
              <span class="stock-readonly-value">{{ form.stock }}</span>
              <span class="stock-readonly-hint">库存请用「入库 / 出库」调整</span>
            </div>
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <!-- 状态完全由库存量决定，不可录入 -->
          <el-form-item label="状态">
            <div class="status-derived">
              <el-tag :type="derivedStatus === '缺货' ? 'danger' : 'success'" size="small" effect="light">
                {{ derivedStatus }}
              </el-tag>
              <span class="status-derived-hint">库存 &gt; 0 为正常，否则缺货</span>
            </div>
          </el-form-item>
        </el-col>
      </el-row>

      <el-form-item label="位置" prop="location">
        <!-- 库位从网格里点选，不手打：手打会写出 a15 / Ａ15 / A155 这类
             与网格对不上的值，位置筛选就会裂项、精确筛选漏料。
             仍保留只读输入框是为了能看清当前值，也便于清空。 -->
        <div class="loc-field">
          <el-input
            :model-value="form.location"
            readonly
            placeholder="点击右侧按钮从货架选位置"
            class="loc-input"
            @click="gridVisible = true"
          />
          <el-button size="small" @click="gridVisible = true">
            {{ form.location ? '换位置' : '选位置' }}
          </el-button>
          <el-button
            v-if="form.location"
            size="small"
            @click="clearLocation"
          >清空</el-button>
        </div>
      </el-form-item>

      <!-- 库位占用提示。只提醒不拦保存：一个格子放多种料在硬件仓储里是常态，
           硬校验会天天误报。写法不统一（variants > 1）才是真问题——
           会让位置筛选下拉裂项、精确筛选漏料，所以那种提级为告警色。 -->
      <div v-if="locationHint" class="loc-hint" :class="{ 'is-warn': locationHintWarn }">
        <div class="loc-hint-text">{{ locationHint }}</div>
        <div v-if="locationOccupants.length" class="loc-hint-list">
          <span v-for="o in locationOccupants" :key="o.id" class="loc-hint-item">
            {{ o.name || o.mfr_pn || `#${o.id}` }}
            <span class="loc-hint-stock">{{ o.stock }}</span>
          </span>
        </div>
      </div>

      <el-form-item label="备注" prop="remark">
        <el-input v-model="form.remark" type="textarea" :rows="2" />
      </el-form-item>
    </el-form>

    <template #footer>
      <el-button @click="cancel" :disabled="saving">取消</el-button>
      <el-button type="primary" :loading="saving" @click="submit">保存</el-button>
    </template>

    <!-- 从货架网格选库位 -->
    <LocationGridDialog
      v-model:visible="gridVisible"
      pick-mode
      :initial-location="form.location"
      @pick="onLocationPicked"
    />
  </el-dialog>
</template>

<script setup>
import { computed, reactive, ref } from 'vue';
import { checkLocationOccupants } from '../api.js';
import LocationGridDialog from './LocationGridDialog.vue';

const props = defineProps({
  visible: { type: Boolean, default: false },
  mode: { type: String, default: 'create' },     // 'create' | 'edit'
  source: { type: Object, default: null },
  saving: { type: Boolean, default: false },
});

const emit = defineEmits(['update:visible', 'save']);

const title = computed(() => (props.mode === 'edit' ? '编辑库存元件' : '新增库存元件'));

const blankForm = () => ({
  name: '',
  package: '',
  mfr_pn: '',
  mfr: '',
  supplier: '',
  supplier_pn: '',
  stock: 0,
  location: '',
  remark: '',
});

const form = reactive(blankForm());
const formRef = ref(null);

// 状态由库存量派生，不是可录入字段
const derivedStatus = computed(() => (Number(form.stock) > 0 ? '正常' : '缺货'));

// 名称/供应商料号/制造商料号至少填一项——与后端校验保持一致
const atLeastOneId = () => Boolean(
  form.name.trim() || form.supplier_pn.trim() || form.mfr_pn.trim()
);

const identityValidator = (rule, value, callback) => {
  if (atLeastOneId()) return callback();
  callback(new Error('名称、供应商料号、制造商料号至少填一项'));
};

const rules = {
  name: [
    { validator: identityValidator, trigger: 'blur' },
    { max: 120, message: '长度不能超过 120', trigger: 'blur' },
  ],
};

// ---------------------------------------------------------------------------
// 库位占用提示
//
// 库位改为从网格点选后，写法不统一（a15 / Ａ15）已不可能发生——
// 网格只产出规范的 {层}{行}{列}。所以这里只剩一件事要说：
// 这格已经有别的料了。共用一格在硬件仓储里是常态，因此只提醒不拦保存。
// ---------------------------------------------------------------------------

const gridVisible = ref(false);
const locationOccupants = ref([]);
const locationChecking = ref(false);

const locationHint = computed(() => {
  const loc = form.location.trim();
  if (!loc) return '';           // 未填位置不提示：未归位的料很多，提示无意义
  if (locationChecking.value) return '正在检查该库位…';

  const n = locationOccupants.value.length;
  if (n === 0) return '该库位当前为空';
  return `该库位已放 ${n} 种料，确认要共用这一格吗？`;
});

// 共用一格通常是正常的，不提级为告警
const locationHintWarn = computed(() => false);

/** 从网格选定库位后：回填并检查占用 */
function onLocationPicked(code) {
  form.location = code;
  locationChecking.value = true;
  checkLocation(code);
}

function clearLocation() {
  form.location = '';
  resetLocationHint();
}

async function checkLocation(loc) {
  // 编辑时必须排除自身，否则永远提示"这格已有 1 种料"（就是它自己）
  const excludeId = props.mode === 'edit' ? props.source?.id : undefined;
  try {
    const res = await checkLocationOccupants(loc, { excludeId });
    // 用户可能已经又换了位置，回来的结果就不该再灌进去
    if (form.location.trim() !== loc) return;
    locationOccupants.value = res?.list || [];
  } catch {
    // 检查失败不阻塞录入：这只是个提示，接口挂了也该能存
    locationOccupants.value = [];
  } finally {
    if (form.location.trim() === loc) locationChecking.value = false;
  }
}

function resetLocationHint() {
  locationOccupants.value = [];
  locationChecking.value = false;
}

function fillFromSource() {
  const s = props.source;
  if (!s) {
    Object.assign(form, blankForm());
    return;
  }
  form.name        = s.name ?? '';
  form.package     = s.package ?? '';
  form.mfr_pn      = s.mfr_pn ?? '';
  form.mfr         = s.mfr ?? '';
  form.supplier    = s.supplier ?? '';
  form.supplier_pn = s.supplier_pn ?? '';
  form.stock       = Number(s.stock ?? 0);
  form.location    = s.location ?? '';
  form.remark      = s.remark ?? '';
}

function onOpen() {
  fillFromSource();
  resetLocationHint();
  formRef.value?.clearValidate?.();
  // 编辑已有位置的记录时立刻检查一次：用户是来改库位的，
  // 得让他一进来就看到这格现在的占用情况，而不是等他敲一下才提示。
  const loc = form.location.trim();
  if (loc) {
    locationChecking.value = true;
    checkLocation(loc);
  }
}

function onClosed() {
  Object.assign(form, blankForm());
  resetLocationHint();
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
    return;
  }

  // 不提交 status：它由库存量派生，后端也不接受这个字段
  const payload = {
    name: form.name.trim(),
    package: form.package.trim(),
    mfr_pn: form.mfr_pn.trim(),
    mfr: form.mfr.trim(),
    supplier: form.supplier.trim(),
    supplier_pn: form.supplier_pn.trim(),
    location: form.location.trim(),
    remark: form.remark.trim(),
  };
  // 编辑时不提交 stock：库存只能通过出入库变动，保证流水与库存一致
  if (props.mode === 'create') payload.stock = form.stock || 0;

  emit('save', payload);
}
</script>

<style scoped>
/* 库存只读：复用 .ui-panel 凹面，保留 flex 让数值+提示排成一行 */
.stock-readonly {
  display: flex;
  align-items: baseline;
  gap: 8px;
}
.stock-readonly-value {
  font-family: var(--font-mono);
  font-size: var(--fs-lg);
  font-weight: 600;
  color: var(--c-text);
}
.stock-readonly-hint {
  font-size: var(--fs-sm);
  color: var(--c-text-3);
}

/* 状态是派生值，展示成"标签 + 规则说明"而不是可编辑控件 */
.status-derived {
  display: flex;
  align-items: center;
  gap: 8px;
  width: 100%;
}
.status-derived-hint {
  font-size: var(--fs-meta);
  color: var(--c-text-3);
}

/* 库位选择：只读输入框 + 选/清空按钮并排 */
.loc-field {
  display: flex;
  align-items: center;
  gap: 8px;
  width: 100%;
}
.loc-field .loc-input {
  flex: 1;
}
/* 只读但可点：光标提示这里能点开网格，而不是像禁用字段那样不可交互 */
.loc-field .loc-input :deep(.el-input__inner) {
  cursor: pointer;
  font-family: var(--font-mono);
}

/* 库位占用提示。缩进对齐到 label-width，让它读起来附属于「位置」字段。
   默认弱化色——共用一格通常是正常的，不该像报错那样抢注意力。 */
.loc-hint {
  margin: -14px 0 16px 92px;
  padding: 0 2px;
  font-size: 12px;
  color: var(--c-text-3);
  line-height: 1.5;
}
/* 写法不统一才是真会导致筛选漏料的问题，提级为告警色 */
.loc-hint.is-warn {
  color: var(--c-warn);
}

/* 占用者列表：名称 + 库存，横向排开，多了自动换行 */
.loc-hint-list {
  display: flex;
  flex-wrap: wrap;
  gap: 4px 8px;
  margin-top: 4px;
}
.loc-hint-item {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 0 5px;
  border-radius: 2px;
  background: var(--c-sunken-2);
  border: 1px solid var(--c-border-2);
  font-size: var(--fs-micro);
  color: var(--c-text-2);
}
.loc-hint-stock {
  font-family: var(--font-mono);
  color: var(--c-text-3);
}
</style>
