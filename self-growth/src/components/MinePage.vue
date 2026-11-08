<script setup>
import { computed, onMounted, ref } from 'vue'
import { state, exportData, importData, resetAll, totalValue, storageBackend } from '../store.js'
import { loadDefaultRulebook, resolveRulebook, clearRulebookCache } from '../rulebook.js'

const s = state.settings
const showKey = ref(false)
const ruleOpen = ref(false)
const ruleText = ref('')
const ruleLoading = ref(false)
const ruleMsg = ref('')
const importErr = ref('')
const fileInput = ref(null)

const hasOverride = computed(() => Boolean(String(s.rulebookOverride || '').trim()))

async function openRule() {
  ruleOpen.value = !ruleOpen.value
  if (!ruleOpen.value) return
  ruleLoading.value = true
  ruleText.value = await resolveRulebook(s.rulebookOverride)
  ruleLoading.value = false
}

async function saveRule() {
  s.rulebookOverride = ruleText.value
  ruleMsg.value = '已保存，下次打分立即生效'
  setTimeout(() => (ruleMsg.value = ''), 2500)
}

async function restoreRule() {
  s.rulebookOverride = ''
  clearRulebookCache()
  ruleLoading.value = true
  ruleText.value = await loadDefaultRulebook()
  ruleLoading.value = false
  ruleMsg.value = '已恢复为仓库内置版本'
  setTimeout(() => (ruleMsg.value = ''), 2500)
}

async function copyRule() {
  try {
    await navigator.clipboard.writeText(ruleText.value)
    ruleMsg.value = '已复制到剪贴板'
  } catch {
    ruleMsg.value = '复制失败，请手动选中'
  }
  setTimeout(() => (ruleMsg.value = ''), 2500)
}

function pickFile() {
  importErr.value = ''
  fileInput.value?.click()
}

async function onFile(e) {
  const file = e.target.files?.[0]
  if (!file) return
  try {
    importData(await file.text())
    importErr.value = ''
  } catch (err) {
    importErr.value = `导入失败：${err.message}`
  } finally {
    e.target.value = ''
  }
}

function doReset() {
  if (!confirm('会清空全部记录和设置，确定吗？')) return
  resetAll()
}

onMounted(() => {
  if (!s.unit) s.unit = 'GV'
})
</script>

<template>
  <div>
    <div class="section-title"><span>评分规则</span><span class="mini">AI 打分依据</span></div>
    <div class="card">
      <div class="rule-status">
        <span class="badge" :class="hasOverride ? 'custom' : 'default'">
          {{ hasOverride ? '使用自定义规则' : '使用内置规则' }}
        </span>
        <span class="mini">{{ ruleOpen ? `${ruleText.length} 字` : 'rulebook.md' }}</span>
      </div>
      <div class="weak-hint">
        这份文档就是模型的系统提示词。想改口径（比如某类事该归哪一维、多少分），直接改文字，不用动代码。
      </div>
      <div class="field" style="margin-top: 10px">
        <button class="btn ghost" @click="openRule">{{ ruleOpen ? '收起' : '查看 / 编辑规则' }}</button>
      </div>

      <div v-if="ruleOpen" style="margin-top: 10px">
        <div v-if="ruleLoading" class="empty">读取中…</div>
        <textarea v-else v-model="ruleText" class="compose-input rule-editor" rows="16" spellcheck="false" />
        <div class="field" style="margin-top: 8px; flex-wrap: wrap">
          <button class="btn primary" @click="saveRule">保存为自定义规则</button>
          <button class="btn ghost" @click="restoreRule">恢复内置版本</button>
          <button class="btn ghost" @click="copyRule">复制全文</button>
        </div>
        <div v-if="ruleMsg" class="hint-ok">{{ ruleMsg }}</div>
      </div>
    </div>

    <div class="section-title"><span>模型</span><span class="mini">OpenAI 兼容接口</span></div>
    <div class="card">
      <label class="row">
        <span>用 AI 打分</span>
        <input v-model="s.useLLM" type="checkbox" class="switch" />
      </label>
      <div class="weak-hint" v-if="!s.useLLM">关闭后走本地关键词估算，分数会粗糙一些。</div>
      <div class="field col">
        <label class="lab">接口地址</label>
        <input v-model="s.apiBase" class="input" placeholder="https://ark.cn-beijing.volces.com/api/v3" />
      </div>
      <div class="field col">
        <label class="lab">API Key</label>
        <div class="field">
          <input v-model="s.apiKey" class="input" :type="showKey ? 'text' : 'password'" placeholder="sk-..." />
          <button class="btn ghost" @click="showKey = !showKey">{{ showKey ? '隐藏' : '显示' }}</button>
        </div>
      </div>
      <div class="field col">
        <label class="lab">模型 ID</label>
        <input v-model="s.model" class="input" placeholder="如 doubao-seed-1-6-250615 / gpt-4o-mini" />
      </div>
      <div class="weak-hint">
        Key 只存在这台设备的浏览器里，不会上传别处。换成任何 OpenAI 兼容服务都能用。
      </div>
    </div>

    <div class="section-title"><span>记账设置</span></div>
    <div class="card">
      <div class="field col">
        <label class="lab">数值单位</label>
        <input v-model="s.unit" class="input" style="max-width: 120px" />
      </div>
      <div class="field col">
        <label class="lab">起始成长值</label>
        <input v-model.number="s.startValue" class="input num" type="number" />
      </div>
      <div class="field col">
        <label class="lab">每日目标</label>
        <input v-model.number="s.dailyGoal" class="input num" type="number" min="0" />
      </div>
      <div class="field col">
        <label class="lab">单日软提示线</label>
        <input v-model.number="s.dailySoftCap" class="input num" type="number" min="0" />
      </div>
      <div class="field col">
        <label class="lab">同类每日计分上限</label>
        <input v-model.number="s.sameKindCap" class="input num" type="number" min="1" />
      </div>
      <div class="weak-hint">
        软提示线只是提示，不封顶；同类上限防止「喝水 10 次」刷分，超出记为勤勉不计分。
      </div>
    </div>

    <div class="section-title"><span>数据</span><span class="mini">共 {{ totalValue }} · 离线本地</span></div>
    <div class="card">
      <div class="field" style="flex-wrap: wrap">
        <button class="btn ghost" @click="exportData">导出备份</button>
        <button class="btn ghost" @click="pickFile">导入备份</button>
        <button class="btn ghost danger" @click="doReset">清空数据</button>
      </div>
      <input ref="fileInput" type="file" accept="application/json" hidden @change="onFile" />
      <div class="weak-hint">
        存储：{{ storageBackend }} · 已记录 {{ state.entries.length }} 条
      </div>
      <div v-if="importErr" class="notice warn" style="margin-top: 10px">{{ importErr }}</div>
    </div>

    <div class="foot-note">成长账本 · 规则文档 public/rulebook.md · 数据只在这台设备</div>
  </div>
</template>
