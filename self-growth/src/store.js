import { computed, reactive, watch } from 'vue'
import { Capacitor } from '@capacitor/core'
import { DIMENSIONS } from './dimensions.js'
import { localConfig } from './local-config.js'

// APK 里没有 vite 反代，直接走绝对地址，由 CapacitorHttp 原生通道绕开 CORS
const NATIVE = Capacitor.isNativePlatform()
const NATIVE_API_BASE = 'https://api.deepseek.com/v1'

export function uid() {
  if (globalThis.crypto?.randomUUID) return globalThis.crypto.randomUUID()
  return `${Date.now()}-${Math.random().toString(16).slice(2)}`
}

/** 本地时区的 YYYY-MM-DD */
export function dayKey(ts = Date.now()) {
  const d = new Date(ts)
  const p = (n) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())}`
}

function defaultSettings() {
  return {
    unit: 'GV',
    startValue: 0,
    dailyGoal: 20,
    dailySoftCap: 60, // 单日软提示线（体系设计 §3.2）
    sameKindCap: 3, // 同类单日计分次数上限
    useLLM: true,
    // 浏览器走 /llm-proxy（vite 反代），APK 走绝对地址（CapacitorHttp 原生请求）
    apiBase: NATIVE ? NATIVE_API_BASE : localConfig.apiBase || NATIVE_API_BASE,
    apiKey: localConfig.apiKey || '',
    model: localConfig.model || 'deepseek-chat',
    rulebookOverride: '', // 自定义评分规则（空 = 用 public/rulebook.md）
  }
}

function defaultState() {
  return { version: 2, settings: defaultSettings(), entries: [] }
}

function normalize(src) {
  const base = defaultState()
  const s = src && typeof src === 'object' ? src : {}
  const settings = { ...base.settings, ...(s.settings || {}) }

  // 老数据迁移：模型没配过（或还指着方舟默认地址）时，用本地私有配置补上
  if (localConfig.apiKey) {
    if (!settings.apiKey) settings.apiKey = localConfig.apiKey
    if (!settings.model) settings.model = localConfig.model
    if (!settings.apiBase || settings.apiBase.includes('volces')) settings.apiBase = localConfig.apiBase
  }
  // APK 里不能留相对路径（没反代）
  if (NATIVE && (!settings.apiBase || settings.apiBase.startsWith('/'))) settings.apiBase = NATIVE_API_BASE

  return {
    version: 2,
    settings,
    entries: (Array.isArray(s.entries) ? s.entries : []).map((e) => ({
      id: e.id || uid(),
      ts: Number(e.ts) || Date.now(),
      text: String(e.text || e.name || ''),
      dimension: DIMENSIONS.some((d) => d.id === e.dimension) ? e.dimension : 'mind',
      kind: String(e.kind || '未归类'),
      base: Number(e.base) || 0,
      challenge: Number(e.challenge) || 1,
      points: Number(e.points) || 0,
      negative: Boolean(e.negative),
      counted: e.counted !== false,
      reason: String(e.reason || ''),
      source: e.source === 'rule' ? 'rule' : 'llm',
      note: String(e.note || ''),
    })),
  }
}

function load() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (!raw) return defaultState()
    return normalize(JSON.parse(raw))
  } catch (err) {
    console.warn('[成长账本] 本地数据读取失败，已回退默认数据', err)
    return defaultState()
  }
}

export const state = reactive(load())

let persistTimer = null
watch(
  state,
  () => {
    clearTimeout(persistTimer)
    persistTimer = setTimeout(() => {
      try {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(state))
      } catch (err) {
        console.warn('[成长账本] 保存失败', err)
      }
    }, 120)
  },
  { deep: true },
)

// ---------------- 成长值 / 等级 ----------------

const sumPoints = (list) => list.reduce((s, e) => s + (e.counted ? Number(e.points || 0) : 0), 0)

/** 累计成长值（含起始值） */
export const totalValue = computed(
  () => Number(state.settings.startValue || 0) + sumPoints(state.entries),
)

/** 等级曲线（体系设计 §4）：第 n 级所需累计值 = 100 × (n-1) × n / 2 */
export function levelThreshold(n) {
  return (100 * (n - 1) * n) / 2
}

export const level = computed(() => {
  let n = 1
  while (levelThreshold(n + 1) <= totalValue.value) n += 1
  return n
})

export const levelInfo = computed(() => {
  const cur = level.value
  const curBase = levelThreshold(cur)
  const nextAt = levelThreshold(cur + 1)
  const span = nextAt - curBase || 1
  return {
    level: cur,
    curBase,
    nextAt,
    remain: Math.max(0, nextAt - totalValue.value),
    percent: Math.min(100, Math.round(((totalValue.value - curBase) / span) * 100)),
  }
})

// ---------------- 今日 / 连续 / 目标 ----------------

const countedToday = computed(() => state.entries.filter((e) => dayKey(e.ts) === dayKey()))

export const todayValue = computed(() => sumPoints(countedToday.value))
export const todayCount = computed(() => countedToday.value.length)
export const todayNegative = computed(() => countedToday.value.filter((e) => e.negative).length)
export const goalPercent = computed(() => {
  const goal = Number(state.settings.dailyGoal) || 0
  if (goal <= 0) return 0
  return Math.min(100, Math.round((todayValue.value / goal) * 100))
})
export const overSoftCap = computed(
  () => Number(state.settings.dailySoftCap) > 0 && todayValue.value > Number(state.settings.dailySoftCap),
)

/** 连续天数：当天有计分记录才算；今天还没记就从昨天开始数 */
export const streak = computed(() => {
  const days = new Set(
    state.entries.filter((e) => e.counted && e.points > 0).map((e) => dayKey(e.ts)),
  )
  const cursor = new Date()
  cursor.setHours(12, 0, 0, 0)
  if (!days.has(dayKey(cursor.getTime()))) cursor.setDate(cursor.getDate() - 1)
  let n = 0
  while (days.has(dayKey(cursor.getTime()))) {
    n += 1
    cursor.setDate(cursor.getDate() - 1)
  }
  return n
})

export const activeDays = computed(
  () => new Set(state.entries.filter((e) => e.counted && e.points > 0).map((e) => dayKey(e.ts))).size,
)

/** 最近 N 天（升序，含今天） */
export function recentDays(count = 14) {
  const out = []
  const cursor = new Date()
  cursor.setHours(12, 0, 0, 0)
  for (let i = count - 1; i >= 0; i -= 1) {
    const d = new Date(cursor)
    d.setDate(d.getDate() - i)
    const key = dayKey(d.getTime())
    const list = state.entries.filter((e) => dayKey(e.ts) === key)
    out.push({
      key,
      label: `${d.getMonth() + 1}/${d.getDate()}`,
      points: sumPoints(list),
      isToday: i === 0,
    })
  }
  return out
}

/** 各维度累计（可限定天数） */
export function dimensionTotals(days = 0) {
  return dimensionTotalsBetween(days > 0 ? Date.now() - days * 24 * 3600 * 1000 : 0, Infinity)
}

/** 各维度累计（指定时间区间，用于「本期 vs 上期」对比） */
export function dimensionTotalsBetween(fromTs, toTs = Infinity) {
  const map = new Map(DIMENSIONS.map((d) => [d.id, 0]))
  for (const e of state.entries) {
    if (!e.counted || e.points <= 0 || e.ts < fromTs || e.ts >= toTs) continue
    map.set(e.dimension, (map.get(e.dimension) || 0) + e.points)
  }
  return DIMENSIONS.map((d) => ({ ...d, points: map.get(d.id) || 0 }))
}

/**
 * 月度账本（像账本一样按天看当月得分）
 * @param {number} year
 * @param {number} month 0-11
 */
export function monthStats(year, month) {
  const daysInMonth = new Date(year, month + 1, 0).getDate()
  const firstWeekday = (new Date(year, month, 1).getDay() + 6) % 7 // 周一=0
  const byDay = new Map()
  for (const e of state.entries) {
    const key = dayKey(e.ts)
    if (!byDay.has(key)) byDay.set(key, [])
    byDay.get(key).push(e)
  }

  const days = []
  for (let d = 1; d <= daysInMonth; d += 1) {
    const key = `${year}-${String(month + 1).padStart(2, '0')}-${String(d).padStart(2, '0')}`
    const list = byDay.get(key) || []
    const points = sumPoints(list)
    days.push({
      key,
      day: d,
      points,
      count: list.filter((e) => e.counted).length,
      negative: list.filter((e) => e.negative).length,
      isToday: key === dayKey(),
      isFuture: key > dayKey(),
    })
  }

  const scored = days.filter((d) => d.points > 0)
  const total = scored.reduce((s, d) => s + d.points, 0)
  const goal = Number(state.settings.dailyGoal) || 0
  const now = new Date()
  const isCurrentMonth = now.getFullYear() === year && now.getMonth() === month
  const elapsed = isCurrentMonth ? now.getDate() : daysInMonth
  const best = days.reduce((m, d) => (d.points > (m?.points || 0) ? d : m), null)

  return {
    year,
    month,
    days,
    leading: firstWeekday,
    total,
    activeDays: scored.length,
    avg: elapsed > 0 ? Math.round((total / elapsed) * 10) / 10 : 0,
    avgActive: scored.length ? Math.round((total / scored.length) * 10) / 10 : 0,
    best,
    negative: days.reduce((s, d) => s + d.negative, 0),
    goalHit: goal > 0 ? scored.filter((d) => d.points >= goal).length : 0,
    goal,
  }
}

/** 某一天的记录（升序） */
export function entriesOfDay(key) {
  return state.entries.filter((e) => dayKey(e.ts) === key).sort((a, b) => a.ts - b.ts)
}

/** 负向统计：总次数 + 近 30 天次数 */
export const negativeStats = computed(() => {
  const from = Date.now() - 30 * 24 * 3600 * 1000
  const list = state.entries.filter((e) => e.negative)
  return {
    total: list.length,
    recent: list.filter((e) => e.ts >= from).length,
    reasons: list.slice(-5).map((e) => ({ text: e.text, ts: e.ts })),
  }
})

// ---------------- 写入 ----------------

/**
 * 写入一条打分结果（体系设计 §3.2 / §5）
 * draft 来自 scoreWithLLM 或 localScore：{dimension, kind, base, challenge, points, negative, reason, source}
 */
export function addScoredEntry(text, draft) {
  const cap = Math.max(1, Number(state.settings.sameKindCap) || 3)
  const today = dayKey()
  const sameKindToday = state.entries.filter(
    (e) => e.counted && dayKey(e.ts) === today && e.kind === draft.kind,
  ).length
  const counted = !draft.negative && sameKindToday < cap

  const entry = {
    id: uid(),
    ts: Date.now(),
    text,
    dimension: draft.dimension,
    kind: draft.kind,
    base: draft.base,
    challenge: draft.challenge,
    points: draft.negative ? 0 : draft.points,
    negative: Boolean(draft.negative),
    counted,
    reason: draft.reason || '',
    source: draft.source || 'llm',
    note: '',
  }
  state.entries.push(entry)
  return entry
}

export function updateEntry(id, patch) {
  const e = state.entries.find((x) => x.id === id)
  if (!e) return
  Object.assign(e, patch)
}

export function removeEntry(id) {
  const idx = state.entries.findIndex((e) => e.id === id)
  if (idx >= 0) state.entries.splice(idx, 1)
}

/** 按日分组（日期倒序，日内倒序） */
export const entriesByDay = computed(() => {
  const groups = new Map()
  for (const e of [...state.entries].sort((a, b) => b.ts - a.ts)) {
    const key = dayKey(e.ts)
    if (!groups.has(key)) groups.set(key, [])
    groups.get(key).push(e)
  }
  return [...groups.entries()]
    .sort((a, b) => (a[0] < b[0] ? 1 : -1))
    .map(([key, items]) => ({
      key,
      items,
      points: sumPoints(items),
      negative: items.filter((e) => e.negative).length,
    }))
})

// ---------------- 格式化 ----------------

export function timeOf(ts) {
  const d = new Date(ts)
  const p = (n) => String(n).padStart(2, '0')
  return `${p(d.getHours())}:${p(d.getMinutes())}`
}

export function dayLabel(key) {
  const today = dayKey()
  const y = new Date()
  y.setDate(y.getDate() - 1)
  if (key === today) return '今天'
  if (key === dayKey(y.getTime())) return '昨天'
  const [yy, mm, dd] = key.split('-').map(Number)
  const d = new Date(yy, mm - 1, dd)
  const week = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'][d.getDay()]
  return `${mm}月${dd}日 ${week}`
}

// ---------------- 备份 ----------------

export function exportData() {
  const blob = new Blob([JSON.stringify(state, null, 2)], { type: 'application/json' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `成长账本-${dayKey()}.json`
  a.click()
  URL.revokeObjectURL(url)
}

export function importData(text) {
  const parsed = JSON.parse(text)
  if (!parsed || !Array.isArray(parsed.entries)) throw new Error('文件格式不对：缺少 entries 数组')
  Object.assign(state, normalize(parsed))
}

export function resetAll() {
  localStorage.removeItem(STORAGE_KEY)
  Object.assign(state, defaultState())
}
