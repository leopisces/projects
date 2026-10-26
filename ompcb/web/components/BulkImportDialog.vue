<template>
  <el-dialog
    :model-value="visible"
    :title="title"
    width="720px"
    :close-on-click-modal="false"
    :close-on-press-escape="!submitting"
    :show-close="!submitting"
    @update:model-value="(v) => emit('update:visible', v)"
    @open="onOpen"
    @closed="onClosed"
  >
    <!-- 两种来源：选 .xlsx 文件，或粘贴 TSV。
         文件解析出的行与粘贴解析出的行结构完全一致，后续预览/模式/提交共用一套。
         仅当调用方传了 fileParser 时才显示文件入口——库存台账没有 xlsx 模板，
         给它显示一个选不出东西的按钮只会让人困惑。 -->
    <div v-if="fileParser" class="bulk-source">
      <div
        class="bulk-drop"
        :class="{ 'is-over': dragOver, 'is-loaded': fileName }"
        @click="pickFile"
        @dragover.prevent="dragOver = true"
        @dragleave.prevent="dragOver = false"
        @drop.prevent="onDrop"
      >
        <template v-if="fileName">
          <div class="bulk-drop-name">{{ fileName }}</div>
          <div class="bulk-drop-hint">
            已解析 {{ fileRowCount }} 条{{ fileErrors.length ? ` · ${fileErrors.length} 行被跳过` : '' }}
            — 点击可重新选择
          </div>
        </template>
        <template v-else>
          <div class="bulk-drop-name">选择 .xlsx 文件，或拖到此处</div>
          <div class="bulk-drop-hint">支持嘉立创 / AD 导出的标准 BOM（表头为 Name / Designator / Quantity 等）</div>
        </template>
      </div>
      <input
        ref="fileInputRef"
        type="file"
        accept=".xlsx,.xls"
        class="bulk-file-input"
        @change="onFileChange"
      />
      <!-- 被跳过的行要如实列出：静默丢数据比报错更糟 -->
      <div v-if="fileErrors.length" class="bulk-file-errors">
        <div v-for="(e, i) in fileErrors.slice(0, 5)" :key="i" class="bulk-file-error">
          {{ typeof e === 'string' ? e : `第 ${e.row} 行：${e.error}` }}
        </div>
        <div v-if="fileErrors.length > 5" class="bulk-file-error">
          …另有 {{ fileErrors.length - 5 }} 条
        </div>
      </div>

      <div class="bulk-or">或粘贴 TSV</div>
    </div>

    <div class="bulk-paste-textarea">
      <p class="ui-hint hint">
        直接从 Excel 复制 TAB 分隔的行粘贴到下方。第一行若为表头（<code>{{ headerHintText }}</code>）会自动跳过。
        列顺序：<code>{{ colText }}</code>。
      </p>
      <el-input
        v-model="raw"
        type="textarea"
        :rows="fileParser ? 6 : 10"
        resize="vertical"
        :placeholder="placeholder"
        @input="onRawInput"
      />
    </div>

    <div class="preview-row">
      <div class="preview-meta">
        <el-tag :type="previewType" size="small">
          {{ previewCount > 0 ? `解析到 ${previewCount} 条` : '尚未解析到有效行' }}
        </el-tag>
        <span v-if="fileName" class="header-note">来自文件 {{ fileName }}</span>
        <span v-else-if="headerDetected" class="header-note">已自动跳过表头</span>
      </div>
      <el-radio-group v-model="mode" size="small">
        <el-radio-button label="append">追加</el-radio-button>
        <el-radio-button v-if="allowUpsert" label="upsert">合并库存</el-radio-button>
        <el-radio-button label="replace">覆盖</el-radio-button>
      </el-radio-group>
    </div>

    <template #footer>
      <el-button @click="cancel" :disabled="submitting">取消</el-button>
      <el-button
        type="primary"
        :loading="submitting"
        :disabled="previewCount === 0"
        @click="submit"
      >导入 {{ previewCount }} 条</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { computed, ref } from 'vue';
import { confirmDestructive } from '../confirm.js';

const props = defineProps({
  visible: { type: Boolean, default: false },
  submitting: { type: Boolean, default: false },
  title: { type: String, default: '批量导入（粘贴 Excel TSV）' },
  // BOM 默认列（保持原有行为不变）；库存台账通过 props 传自己的列定义。
  // 注意：defineProps 会被提升到 setup() 外部，default 里不能引用局部常量，
  // 所以这些数组必须内联写在这里。
  cols: {
    type: Array,
    default: () => [
      'seq', 'name', 'designator', 'package', 'qty',
      'mfr_pn', 'mfr', 'supplier', 'supplier_pn',
      'status', 'stock', 'location',
    ],
  },
  // 表头首格命中这些值时视为表头行并跳过
  headerHints: { type: Array, default: () => ['seq', '序号'] },
  // 需要按整数解析的列名
  numericCols: { type: Array, default: () => ['seq', 'qty', 'stock'] },
  // 至少要有一个非空才算有效行
  requiredAnyOf: { type: Array, default: () => ['name'] },
  placeholder: {
    type: String,
    default: '示例：\n1\t1MΩ\tR1,R32\tR0402\t2\t0402WGF1004TCE\tUNI-ROYAL(厚声)\tLCSC\tC26083\t',
  },
  allowUpsert: { type: Boolean, default: false },
  // replace（覆盖）模式会清空现有数据，属于不可恢复操作，导入前要二次确认。
  // 但"清空什么"因调用方而异（BOM 只清当前产品，库存清整个台账连流水），
  // 组件自己猜不出来，所以由调用方给出准确描述。
  replaceWarning: {
    type: String,
    default: '覆盖模式会先清空现有数据再导入。',
  },
  /**
   * xlsx 文件解析函数。调用方传此 prop 时显示文件选择入口。
   * 签名：(ArrayBuffer) => { rows: object[], errors: Array<{row,error}> }
   *
   * 刻意不传整体依赖：库存台账没有 xlsx 模板，给它显示文件入口只会让人困惑。
   * 而 BOM 调用方用 `parseXlsxBom`，纯函数可被测试锁定。
   */
  fileParser: { type: Function, default: null },
});

const emit = defineEmits(['update:visible', 'submit']);

const raw = ref('');
const mode = ref('append');
const headerDetected = ref(false);

// 文件选择状态
const fileInputRef = ref(null);
const fileName = ref('');
const fileRows = ref([]);
const fileErrors = ref([]);
const dragOver = ref(false);

const fileRowCount = computed(() => fileRows.value.length);

// --- parsing ---------------------------------------------------------------

function parseRaw(text) {
  if (!text) return { rows: [], headerDetected: false };
  const lines = text.replace(/\r\n?/g, '\n').split('\n').filter(l => l.length);
  if (!lines.length) return { rows: [], headerDetected: false };

  const cols = props.cols;
  const numeric = new Set(props.numericCols);
  const hints = props.headerHints.map(h => String(h).toLowerCase());

  const out = [];
  let detected = false;
  for (let i = 0; i < lines.length; i++) {
    const cells = lines[i].split('\t');
    if (i === 0) {
      const first = (cells[0] || '').trim().toLowerCase();
      if (hints.includes(first)) {
        detected = true;
        continue;
      }
    }
    const row = {};
    for (let c = 0; c < cols.length; c++) {
      const v = (cells[c] ?? '').trim();
      if (numeric.has(cols[c])) {
        const n = parseInt(v, 10);
        row[cols[c]] = Number.isFinite(n) ? n : 0;
      } else {
        row[cols[c]] = v;
      }
    }
    // 至少一个标识字段非空才收
    if (!props.requiredAnyOf.some(k => row[k])) continue;
    out.push(row);
  }
  return { rows: out, headerDetected: detected };
}

const parsed = computed(() => parseRaw(raw.value));

/**
 * 最终要导入的行。
 *
 * 文件与粘贴互斥而非相加：两边都有数据时无法判断用户的意图
 * （是想合并，还是忘了清掉上一次的？），静默相加会导入意料之外的条数。
 * 选了文件就以文件为准，粘贴框留着只是方便对照/临时补充——
 * 想用粘贴就先清掉文件。
 */
const effectiveRows = computed(() =>
  fileRows.value.length > 0 ? fileRows.value : parsed.value.rows
);

const previewCount = computed(() => effectiveRows.value.length);
const previewType = computed(() => (previewCount.value > 0 ? 'success' : 'info'));

const colText = computed(() => props.cols.join(' · '));
const headerHintText = computed(() => props.headerHints.join(' / '));

// --- 文件选择 --------------------------------------------------------------

function pickFile() {
  if (props.submitting) return;
  fileInputRef.value?.click();
}

function onDrop(e) {
  dragOver.value = false;
  if (props.submitting) return;
  const file = e.dataTransfer?.files?.[0];
  if (file) readFile(file);
}

function onFileChange(e) {
  const file = e.target.files?.[0];
  if (file) readFile(file);
  // 清掉 input 的值，让同一个文件可以再选一次（改了内容后重新导入）
  e.target.value = '';
}

async function readFile(file) {
  if (!props.fileParser) return;
  try {
    const buf = await file.arrayBuffer();
    const res = props.fileParser(buf);
    fileRows.value = res?.rows || [];
    fileErrors.value = res?.errors || [];
    fileName.value = file.name;
    // 文件解析出 0 行时也保留文件名与 errors：用户需要看到"为什么是 0 条"
  } catch (err) {
    fileRows.value = [];
    fileErrors.value = [`文件解析失败：${err?.message || err}`];
    fileName.value = file.name;
  }
}

function clearFile() {
  fileName.value = '';
  fileRows.value = [];
  fileErrors.value = [];
}

function onRawInput() {
  headerDetected.value = parseRaw(raw.value).headerDetected;
}

function onOpen() {
  raw.value = '';
  mode.value = 'append';
  headerDetected.value = false;
  clearFile();
}

function onClosed() {
  raw.value = '';
  headerDetected.value = false;
  clearFile();
}

function cancel() {
  if (props.submitting) return;
  emit('update:visible', false);
}

async function submit() {
  if (previewCount.value === 0) return;

  // 覆盖模式先清空再导入，清掉的数据找不回来，所以要两步确认。
  // 追加/合并不破坏现有数据，直接放过。
  if (mode.value === 'replace') {
    const okToReplace = await confirmDestructive({
      title: '覆盖导入',
      firstMessage: `${props.replaceWarning}即将导入 ${previewCount.value} 条新数据。`,
      firstConfirm: '继续覆盖',
      secondMessage:
        `最后确认：被清空的数据无法找回，只会保留这次导入的 ${previewCount.value} 条。确定继续吗？`,
      secondConfirm: '确认覆盖，不可恢复',
    });
    if (!okToReplace) return;
  }

  // 同时给出 raw 与已解析的 rows：调用方可各取所需。
  // rows 走 effectiveRows，来源可能是文件也可能是粘贴。
  emit('submit', { raw: raw.value, rows: effectiveRows.value, mode: mode.value });
}
</script>

<style scoped>
/* 段落级提示：字号/颜色/行高交给全局 .ui-hint，本地只负责把段落推开 */
.hint { margin: 0 0 8px 0; }
.hint code {
  font-family: var(--font-mono);
  background: var(--c-sunken-2);
  padding: 0 4px;
  border-radius: 2px;
  color: var(--c-text-2);
}
.preview-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 12px;
}
.preview-meta {
  display: flex;
  align-items: center;
  gap: 8px;
}
.header-note {
  font-size: var(--fs-sm);
  color: var(--c-text-3);
}

/* --- 文件选择区 --- */
.bulk-source {
  margin-bottom: 14px;
}

/* 拖放区：虚线框是"可拖入"的通用视觉语言，比一个孤立的按钮更能说明可拖拽 */
.bulk-drop {
  padding: 16px 14px;
  text-align: center;
  border: 1px dashed var(--c-border);
  border-radius: 4px;
  background: var(--c-sunken-2);
  cursor: pointer;
  transition: border-color 0.12s, background 0.12s;
}
.bulk-drop:hover,
.bulk-drop.is-over {
  border-color: var(--c-accent);
  background: var(--c-accent-soft);
}
/* 已选中文件：实线 + 成功色，与"待选择"状态明确区分 */
.bulk-drop.is-loaded {
  border-style: solid;
  border-color: var(--c-success-border, var(--c-accent-border));
  background: var(--c-success-soft, var(--c-accent-soft));
}
.bulk-drop-name {
  font-size: var(--fs-table);
  color: var(--c-text);
  font-weight: 600;
}
.bulk-drop-hint {
  margin-top: 4px;
  font-size: var(--fs-micro);
  color: var(--c-text-3);
}

/* 原生 file input 藏起来，点击由拖放区代理 */
.bulk-file-input {
  display: none;
}

/* 被跳过的行：如实列出，静默丢数据比报错更糟 */
.bulk-file-errors {
  margin-top: 8px;
  padding: 6px 10px;
  border-radius: 3px;
  background: var(--c-warn-soft);
  border: 1px solid var(--c-warn-border);
}
.bulk-file-error {
  font-size: var(--fs-micro);
  color: var(--c-warn);
  line-height: 1.6;
}

/* "或粘贴 TSV" 分隔线 */
.bulk-or {
  margin: 12px 0 0;
  text-align: center;
  font-size: var(--fs-micro);
  color: var(--c-text-3);
}
</style>
