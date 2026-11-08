<script setup>
import { computed, onUnmounted, ref } from 'vue'
import {
  state,
  todayValue,
  todayCount,
  todayNegative,
  overSoftCap,
  goalPercent,
  entriesByDay,
  dayKey,
  addScoredEntry,
  removeEntry,
  timeOf,
} from '../store.js'
import { DIMENSIONS, dimById, CHALLENGE_LEVELS } from '../dimensions.js'
import { scoreWithLLM, localScore, ScoreError } from '../llm.js'
import { resolveRulebook } from '../rulebook.js'

const text = ref('')
const phase = ref('idle') // idle | scoring | preview | saving
const draft = ref(null)
const errorMsg = ref('')
const toast = ref(null)
let toastTimer = null

const todayList = computed(() => {
  const g = entriesByDay.value.find((x) => x.key === dayKey())
  return g ? g.items : []
})

const suggestions = [
  '跑了 5 公里，最后 1 公里差点放弃',
  '读完一章《反脆弱》，记了笔记',
  '陪我妈去医院复查，等了一下午',
  '把拖欠两周的导出功能写完上线了',
  '收拾了桌面，把报销单归档了',
]

// 记账式快捷项：一点就入账，不再走预览（维度/类别由本地规则识别）
const presets = [
  { text: '早起', base: 3, challenge: 1 },
  { text: '运动 30 分钟', base: 4, challenge: 1.3 },
  { text: '读书 30 分钟', base: 4, challenge: 1 },
  { text: '写代码推进', base: 5, challenge: 1.3 },
  { text: '冥想 10 分钟', base: 2, challenge: 1 },
  { text: '整理收纳', base: 3, challenge: 1 },
]

function showToast(entry) {
  toast.value = { entry, counted: entry.counted }
  clearTimeout(toastTimer)
  toastTimer = setTimeout(() => {
    toast.value = null
  }, 4500)
}

function quickRecord(p) {
  const s = localScore(p.text)
  const points = Math.round(Number(p.base) * Number(p.challenge))
  const entry = addScoredEntry(p.text, { ...s, base: p.base, challenge: p.challenge, points })
  showToast(entry)
}

function useSuggestion(s) {
  text.value = s
  run()
}

async function run() {
  const content = text.value.trim()
  if (!content || phase.value === 'scoring') return
  errorMsg.value = ''
  phase.value = 'scoring'
  try {
    if (state.settings.useLLM) {
      const rulebook = await resolveRulebook(state.settings.rulebookOverride)
      draft.value = await scoreWithLLM(content, state.settings, { rulebook })
    } else {
      draft.value = localScore(content)
    }
  } catch (err) {
    const msg = err instanceof ScoreError ? err.message : err?.message || '打分失败'
    errorMsg.value = `模型打分失败（${msg}），已用本地规则估算，确认前可以手动改`
    draft.value = localScore(content)
  } finally {
    phase.value = 'preview'
  }
}

function setDimension(id) {
  if (draft.value) draft.value.dimension = id
}

function setChallenge(v) {
  if (draft.value) draft.value.challenge = v
}

const previewPoints = computed(() => {
  if (!draft.value) return 0
  if (draft.value.negative) return 0
  return Math.round((Number(draft.value.base) || 0) * (Number(draft.value.challenge) || 1))
})

function confirmEntry() {
  if (!draft.value) return
  const entry = addScoredEntry(text.value.trim(), { ...draft.value, points: previewPoints.value })
  showToast(entry)
  draft.value = null
  text.value = ''
  phase.value = 'idle'
}

function cancelPreview() {
  draft.value = null
  phase.value = 'idle'
}

function undo() {
  if (!toast.value) return
  removeEntry(toast.value.entry.id)
  toast.value = null
  clearTimeout(toastTimer)
}

onUnmounted(() => clearTimeout(toastTimer))
</script>

<template>
  <div>
    <div class="goal-card" :class="{ done: goalPercent >= 100 }">
      <div class="goal-text">
        <span v-if="goalPercent >= 100">🎉 今日目标已达成</span>
        <span v-else>今日 {{ todayValue }} / {{ state.settings.dailyGoal }} {{ state.settings.unit }}</span>
      </div>
      <div class="goal-bar">
        <div class="goal-fill" :style="{ width: `${goalPercent}%` }" />
      </div>
      <div class="goal-split">
        <span class="in">正向 {{ todayCount }} 笔</span>
        <span v-if="todayNegative" class="out">负向 {{ todayNegative }} 笔</span>
        <span class="net">净得 {{ todayValue }}</span>
      </div>
    </div>

    <div v-if="overSoftCap" class="notice">
      今天已经 {{ todayValue }} 分了，超过软提示线 {{ state.settings.dailySoftCap }}。记得是真的就好，不拦你。
    </div>

    <div class="section-title">
      <span>快捷记账</span>
      <span class="mini">一点就入账，可撤销</span>
    </div>

    <div class="quick-grid">
      <button v-for="p in presets" :key="p.text" class="quick-btn" @click="quickRecord(p)">
        <b>+{{ Math.round(p.base * p.challenge) }}</b>
        <span>{{ p.text }}</span>
      </button>
    </div>

    <div class="section-title">
      <span>刚刚做了什么？</span>
      <span class="mini">一句话就够</span>
    </div>

    <div class="compose">
      <textarea
        v-model="text"
        class="compose-input"
        rows="3"
        maxlength="200"
        placeholder="例：跑了 5 公里，最后 1 公里差点放弃"
        :disabled="phase === 'scoring'"
      />
      <div class="compose-foot">
        <span class="counter">{{ text.length }}/200</span>
        <button class="btn primary" :disabled="!text.trim() || phase === 'scoring'" @click="run">
          {{ phase === 'scoring' ? '打分中…' : '让 AI 打分' }}
        </button>
      </div>
    </div>

    <div v-if="phase === 'idle'" class="suggest">
      <span class="mini">没灵感？试试：</span>
      <button v-for="s in suggestions" :key="s" class="suggest-chip" @click="useSuggestion(s)">
        {{ s }}
      </button>
    </div>

    <div v-if="errorMsg" class="notice warn">{{ errorMsg }}</div>

    <!-- 打分结果预览 -->
    <div v-if="draft && phase !== 'scoring'" class="preview">
      <div class="preview-head">
        <div class="preview-score">
          <span class="num">{{ draft.negative ? '标记' : `+${previewPoints}` }}</span>
          <span class="unit">{{ draft.negative ? '负向 · 不计分' : state.settings.unit }}</span>
        </div>
        <div class="preview-reason">
          <span class="src">{{ draft.source === 'llm' ? 'AI 判定' : '本地估算' }}</span>
          {{ draft.reason }}
        </div>
      </div>

      <div class="preview-block">
        <div class="preview-label">维度</div>
        <div class="dim-picker">
          <button
            v-for="d in DIMENSIONS"
            :key="d.id"
            class="dim-btn"
            :class="{ active: draft.dimension === d.id }"
            :style="{ '--dim': d.color }"
            @click="setDimension(d.id)"
          >
            <span>{{ d.icon }}</span>{{ d.name }}
          </button>
        </div>
      </div>

      <div class="preview-block" v-if="!draft.negative">
        <div class="preview-label">基础分</div>
        <div class="score-picker">
          <input v-model.number="draft.base" class="input num" type="number" min="1" max="20" />
          <span class="mini">1–20</span>
        </div>
        <div class="preview-label" style="margin-top: 10px">挑战系数</div>
        <div class="dim-picker">
          <button
            v-for="c in CHALLENGE_LEVELS"
            :key="c.value"
            class="dim-btn"
            :class="{ active: draft.challenge === c.value }"
            @click="setChallenge(c.value)"
          >
            ×{{ c.value }} {{ c.label }}
          </button>
        </div>
      </div>

      <div class="kind-line">
        类别 <b>{{ draft.kind }}</b> · 今日已记 {{ todayCount }} 笔，同类别一天最多计分 {{ state.settings.sameKindCap }} 次
      </div>

      <div class="preview-actions">
        <button class="btn ghost" @click="cancelPreview">取消</button>
        <button class="btn primary" @click="confirmEntry">记入账本 +{{ previewPoints }}</button>
      </div>
    </div>

    <!-- 今日记录 -->
    <div class="section-title">
      <span>今天的记录</span>
      <span class="mini">{{ todayCount }} 笔<span v-if="todayNegative"> · 负向 {{ todayNegative }}</span></span>
    </div>

    <div v-if="!todayList.length" class="empty">还没有记录，写一句就开始了</div>

    <div v-for="e in todayList" :key="e.id" class="entry" :class="{ faded: !e.counted || e.negative }">
      <span class="dot" :style="{ background: dimById(e.dimension).color }" />
      <div class="info">
        <div class="name">{{ e.text }}</div>
        <div class="meta">
          {{ timeOf(e.ts) }} · {{ dimById(e.dimension).name }}
          <span v-if="e.negative" class="tag neg">负向</span>
          <span v-else-if="!e.counted" class="tag">勤勉 · 不计分</span>
          <span v-if="e.source === 'rule'" class="tag">本地估算</span>
        </div>
      </div>
      <span class="delta earn">{{ e.counted && !e.negative ? `+${e.points}` : '0' }}</span>
      <button class="del" @click="removeEntry(e.id)">✕</button>
    </div>

    <transition name="fade">
      <div v-if="toast" class="toast">
        <span v-if="toast.entry.negative">已记录负向行为（不计分）</span>
        <span v-else-if="!toast.counted">同类已达上限，记为勤勉 · 不计分</span>
        <span v-else>{{ dimById(toast.entry.dimension).name }} +{{ toast.entry.points }} {{ state.settings.unit }}</span>
        <button class="undo" @click="undo">撤销</button>
      </div>
    </transition>
  </div>
</template>
