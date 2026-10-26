<template>
  <div class="product-bar">
    <span class="product-bar-label">产品</span>

    <el-select
      :model-value="modelValue"
      placeholder="选择产品"
      filterable
      size="small"
      style="width: 260px"
      :loading="loading"
      @update:model-value="(v) => emit('update:modelValue', v)"
    >
      <el-option
        v-for="p in products"
        :key="p.id"
        :label="p.name ? `${p.code} · ${p.name}` : p.code"
        :value="p.id"
      >
        <div class="product-option">
          <span class="product-option-code">{{ p.code }}</span>
          <span class="product-option-meta">
            BOM {{ p.bomLines }} 行
            <template v-if="p.shortageLines > 0">
              · <span class="is-short">缺 {{ p.shortageLines }}</span>
            </template>
          </span>
        </div>
      </el-option>
    </el-select>

    <!-- 当前产品的 BOM 概览。
         sunken 底 + 1px 边 + 数字走 mono；和下方 .stats-strip 同语系但明显更轻
         （字号小、没有 hero 数字、没有比例条），不抢注意力。 -->
    <div v-if="current" class="product-meta">
      <span class="meta-item">BOM <b>{{ current.bomLines }}</b> 行</span>
      <span class="meta-sep">·</span>
      <span class="meta-item">已关联库存 <b>{{ current.matchedLines }}</b></span>
      <template v-if="current.unmatchedLines > 0">
        <span class="meta-sep">·</span>
        <span class="meta-item is-muted">未匹配 <b>{{ current.unmatchedLines }}</b></span>
      </template>
      <template v-if="current.shortageLines > 0">
        <span class="meta-sep">·</span>
        <span class="meta-item is-short">缺料 <b>{{ current.shortageLines }}</b></span>
      </template>
    </div>

    <span class="product-bar-spacer" />

    <el-button size="small" :disabled="!current" @click="emit('view-logs')">出入库记录</el-button>
    <el-button size="small" type="primary" plain @click="openCreate">新建产品</el-button>
    <el-button size="small" :disabled="!current" @click="openRename">重命名</el-button>
    <!-- 清空明细：保留产品、只删 BOM。没有明细时禁用——两步确认走一遍却删 0 条没意义 -->
    <el-tooltip
      :content="hasBom ? '删除该产品的全部 BOM 明细，保留产品本身' : '该产品下暂无 BOM 明细'"
      placement="top"
    >
      <el-button
        size="small"
        type="warning"
        plain
        :disabled="!current || !hasBom"
        :loading="clearing"
        @click="confirmClear"
      >
        清空明细
      </el-button>
    </el-tooltip>
    <el-button size="small" type="danger" plain :disabled="!current" @click="confirmDelete">
      删除产品
    </el-button>

    <!-- 新建 / 重命名 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogMode === 'create' ? '新建产品' : '重命名产品'"
      width="460px"
      :close-on-click-modal="false"
      @closed="resetDialog"
    >
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="82px"
        label-position="right"
        @submit.prevent
      >
        <el-form-item label="产品编号" prop="code">
          <el-input v-model="form.code" placeholder="如 AGB_CPU_03" maxlength="60" show-word-limit />
        </el-form-item>
        <el-form-item label="产品名称" prop="name">
          <el-input v-model="form.name" placeholder="选填，如 AGB 主板" maxlength="120" />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" :rows="2" />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="dialogVisible = false" :disabled="submitting">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="submitDialog">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { computed, reactive, ref } from 'vue';
import { ElMessage } from 'element-plus';
import { confirmDestructive } from '../confirm.js';
import { createProduct, updateProduct, deleteProduct, clearProductMaterials } from '../api.js';

const props = defineProps({
  modelValue: { type: [Number, String, null], default: null },
  products: { type: Array, default: () => [] },
  loading: { type: Boolean, default: false },
});

const emit = defineEmits(['update:modelValue', 'changed', 'view-logs']);

const current = computed(() => props.products.find(p => p.id === props.modelValue) || null);

const hasBom = computed(() => Number(current.value?.bomLines) > 0);

const clearing = ref(false);

const dialogVisible = ref(false);
const dialogMode = ref('create');
const submitting = ref(false);
const formRef = ref(null);
const form = reactive({ code: '', name: '', remark: '' });

const rules = {
  code: [
    { required: true, message: '产品编号不能为空', trigger: 'blur' },
    { max: 60, message: '长度不能超过 60', trigger: 'blur' },
  ],
};

function resetDialog() {
  form.code = '';
  form.name = '';
  form.remark = '';
  formRef.value?.clearValidate?.();
}

function openCreate() {
  dialogMode.value = 'create';
  resetDialog();
  dialogVisible.value = true;
}

function openRename() {
  if (!current.value) return;
  dialogMode.value = 'rename';
  form.code = current.value.code ?? '';
  form.name = current.value.name ?? '';
  form.remark = current.value.remark ?? '';
  dialogVisible.value = true;
}

async function submitDialog() {
  if (!formRef.value) return;
  try {
    await formRef.value.validate();
  } catch {
    return;
  }

  submitting.value = true;
  try {
    const payload = {
      code: form.code.trim(),
      name: form.name.trim(),
      remark: form.remark.trim(),
    };

    if (dialogMode.value === 'create') {
      const created = await createProduct(payload);
      ElMessage.success(`已创建产品 ${created.code}`);
      dialogVisible.value = false;
      // 新建后自动切到该产品，方便马上导入 BOM
      emit('changed', created.id);
    } else {
      await updateProduct(current.value.id, payload);
      ElMessage.success('已保存产品信息');
      dialogVisible.value = false;
      emit('changed', current.value.id);
    }
  } catch (e) {
    ElMessage.error(e.message);
  } finally {
    submitting.value = false;
  }
}

/**
 * 清空当前产品的全部 BOM 明细（产品本身保留）。
 *
 * 后果必须在确认框里说全，尤其是「焊接进度不可重建」这条：
 * BOM 行与领料流水靠 material_id 绑定，删行后流水的 material_id 悬空，
 * 重新导入生成的是新 id，对不回去 —— 这跟 replace 导入刻意按位号保留 id
 * 恰好相反，用户很可能以为「删了重导就行」。
 */
async function confirmClear() {
  const p = current.value;
  if (!p || !hasBom.value) return;

  const lines = Number(p.bomLines) || 0;
  const ok = await confirmDestructive({
    title: '清空 BOM 明细',
    firstMessage:
      `将删除产品「${p.code}」下的全部 ${lines} 条 BOM 明细，产品本身保留。\n\n` +
      '已领出的库存不会退回，出入库流水也会保留（仍可按产品追溯）。',
    firstConfirm: `继续清空（${lines} 条）`,
    secondMessage:
      `最后确认：「${p.code}」的 ${lines} 条明细将被删除且无法找回。\n\n` +
      '注意：这些行的「已焊接」进度会永久丢失 —— 重新导入 BOM 会生成新的行，' +
      '无法与原有领料记录重新对应上。',
    secondConfirm: '确认清空，不可恢复',
  });
  if (!ok) return;

  clearing.value = true;
  try {
    const res = await clearProductMaterials(p.id);
    // 如实报出影响面，别只说"已清空"——用户该知道牵动了多少领料记录
    const extra = res?.solderedLines > 0 ? `，其中 ${res.solderedLines} 行曾领料` : '';
    ElMessage.success(`已清空 ${res?.removed ?? 0} 条明细${extra}`);
    // 产品还在，仍选中它；父组件据此刷新列表与汇总
    emit('changed', p.id);
  } catch (e) {
    ElMessage.error(e.message);
  } finally {
    clearing.value = false;
  }
}

async function confirmDelete() {
  const p = current.value;
  if (!p) return;

  // 复用上面的 hasBom computed，不再声明同名局部变量遮蔽它
  const withBom = hasBom.value;

  // 有 BOM 时删除会连带整份明细，是不可恢复的批量毁坏，走两步确认
  const okToDelete = await confirmDestructive({
    title: '删除产品',
    firstMessage: withBom
      ? `产品「${p.code}」下有 ${p.bomLines} 条 BOM 明细，删除产品会连同这些明细一并删除。`
      : `确认删除产品「${p.code}」？该产品下暂无 BOM 明细。`,
    firstConfirm: withBom ? `继续删除（含 ${p.bomLines} 条明细）` : '继续删除',
    secondMessage: withBom
      ? `最后确认：删除后「${p.code}」及其 ${p.bomLines} 条 BOM 明细都无法找回。确定继续吗？`
      : `最后确认：删除产品「${p.code}」后无法找回。确定继续吗？`,
    secondConfirm: '确认删除，不可恢复',
  });
  if (!okToDelete) return;

  try {
    // 带 BOM 时后端要求显式确认，这里把用户的确认传下去
    await deleteProduct(p.id, { withBom });
    ElMessage.success('已删除产品');
    emit('changed', null);
  } catch (e) {
    ElMessage.error(e.message);
  }
}
</script>

<style scoped>
.product-bar {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  background: var(--c-surface);
  border-bottom: 1px solid var(--c-border);
  flex: 0 0 auto;
}
.product-bar-label {
  font-size: var(--fs-sm);
  font-weight: 600;
  color: var(--c-text-2);
}
.product-bar-spacer { flex: 1; }

/* inline 概览：sunken 底 + 1px 边 + 数字走 mono。和下方 .stats-strip 同语系
   但明显更轻（字号小、没有 hero 数字、没有比例条），不抢注意力。 */
.product-meta {
  display: flex;
  align-items: baseline;
  gap: 5px;
  padding: 2px 8px;
  font-size: var(--fs-sm);
  color: var(--c-text-3);
  background: var(--c-sunken);
  border: 1px solid var(--c-border);
  border-radius: 3px;
}
.product-meta b {
  font-family: var(--font-mono);
  color: var(--c-text);
  font-weight: 600;
}
.meta-sep { color: var(--c-border-2); }
/* 未匹配本身不是告警，只是还没接上库存；数字留灰，不上 warn / red。 */
.meta-item.is-muted b { color: var(--c-text-3); }
/* 缺料沿用全局 .is-short（--c-danger，红色 = 硬性缺口）。
   b 元素继承父级 color，数字也跟着变红，不需要再单独覆盖。 */

.product-option {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}
.product-option-code { font-weight: 500; }
.product-option-meta {
  font-size: var(--fs-meta);
  color: var(--c-text-3);
}
</style>
