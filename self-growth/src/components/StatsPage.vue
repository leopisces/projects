<script setup>
import { computed, ref } from 'vue'
import {
  state,
  totalValue,
  levelInfo,
  streak,
  activeDays,
  recentDays,
  dimensionTotals,
  dimensionTotalsBetween,
  monthStats,
  entriesOfDay,
  negativeStats,
  timeOf,
  dayLabel,
} from '../store.js'
import { DIMENSIONS, dimById } from '../dimensions.js'

// ---------------- 能力图 ----------------
const windowDays = ref(30)
const WINDOWS = [
  { days: 7, label: '本周' },
  { days: 30, label: '近30天' },
  { days: 90, label: '近90天' },
  { days: 0, label: '全部' },
]

const DAY_MS = 24 * 3600 * 1000
const cur = computed(() => dimensionTotals(windowDays.value))
const prev = computed(() => {
  const d = windowDays.value
  if (!d) return DIMENSIONS.map((x) => ({ ...x, points: 0 }))
  const now = Date.now()
  return dimensionTotalsBetween(now - 2 * d * DAY_MS, now - d * DAY_MS)
})

const dimMax = computed(() => Math.max(1, ...cur.value.map((d) => d.points), ...prev.value.map((d) => d.points)))
const compareRows = computed(() =>
  cur.value.map((d, i) => ({
    ...d,
    prev: prev.value[i].points,
    delta: d.points - prev.value[i].points,
  })),
)
const balance = computed(() => {
  const total = cur.value.reduce((s, d) => s + d.points, 0)
  if (!total) return null
  const sorted = [...cur.value].sort((a, b) => b.points - a.points)
  const top = sorted[0]
  const low = sorted[sorted.length - 1]
  const share = Math.round((top.points / total) * 100)
  return { top, low, share, total }
})

// 雷达几何
const SIZE = 250
const CX = SIZE / 2
const CY = SIZE / 2 + 4
const R = 86

function axisPoint(i, ratio) {
  const angle = (Math.PI * 2 * i) / 5 - Math.PI / 2
  return [CX + Math.cos(angle) * R * ratio, CY + Math.sin(angle) * R * ratio]
}
const grid = computed(() =>
  [0.25, 0.5, 0.75, 1].map((r) => DIMENSIONS.map((_, i) => axisPoint(i, r).join(',')).join(' ')),
)
const axisLines = computed(() =>
  DIMENSIONS.map((_, i) => {
    const [x, y] = axisPoint(i, 1)
    return { x2: x, y2: y }
  }),
)
const poly = (list) =>
  list.map((d, i) => axisPoint(i, Math.max(d.points / dimMax.value, 0.04)).join(',')).join(' ')
const curShape = computed(() => poly(cur.value))
const prevShape = computed(() => poly(prev.value))
const labels = computed(() =>
  DIMENSIONS.map((d, i) => {
    const [x, y] = axisPoint(i, 1.3)
    return { ...d, x, y }
  }),
)

// ---------------- 月度账本 ----------------
const cursor = ref({ y: new Date().getFullYear(), m: new Date().getMonth() })
const month = computed(() => monthStats(cursor.value.y, cursor.value.m))
const heatMax = computed(() => Math.max(1, ...month.value.days.map((d) => d.points)))
const picked = ref(null)
const pickedEntries = computed(() => (picked.value ? entriesOfDay(picked.value) : []))

const WEEK_LABELS = ['一', '二', '三', '四', '五', '六', '日']
const blanks = computed(() => Array.from({ length: month.value.leading }, (_, i) => i))

function shiftMonth(step) {
  const d = new Date(cursor.value.y, cursor.value.m + step, 1)
  cursor.value = { y: d.getFullYear(), m: d.getMonth() }
  picked.value = null
}

function heat(d) {
  if (!d.points) return 0
  return 0.14 + 0.86 * (d.points / heatMax.value)
}

function pick(d) {
  if (d.isFuture || (!d.count && !d.negative)) return
  picked.value = picked.value === d.key ? null : d.key
}

// ---------------- 近 14 天 ----------------
const days = computed(() => recentDays(14))
const dayMax = computed(() => Math.max(1, ...days.value.map((d) => d.points)))
const weekSum = computed(() => dimensionTotals(7).reduce((s, d) => s + d.points, 0))
const monthSum = computed(() => dimensionTotals(30).reduce((s, d) => s + d.points, 0))
const todaySum = computed(() => dimensionTotals(1).reduce((s, d) => s + d.points, 0))
</script>

<template>
  <div>
    <div class="kpi-grid">
      <div class="kpi">
        <div class="kpi-num">{{ totalValue }}</div>
        <div class="kpi-label">累计 {{ state.settings.unit }}</div>
      </div>
      <div class="kpi">
        <div class="kpi-num">Lv.{{ levelInfo.level }}</div>
        <div class="kpi-label">距下一级 {{ levelInfo.remain }}</div>
      </div>
      <div class="kpi">
        <div class="kpi-num">{{ streak }}</div>
        <div class="kpi-label">连续天数</div>
      </div>
      <div class="kpi">
        <div class="kpi-num">{{ activeDays }}</div>
        <div class="kpi-label">总记录天数</div>
      </div>
    </div>

    <!-- 能力图 -->
    <div class="section-title">
      <span>能力图</span>
      <span class="mini">实线本期 · 虚线上期</span>
    </div>
    <div class="seg">
      <button
        v-for="w in WINDOWS"
        :key="w.days"
        class="seg-btn"
        :class="{ active: windowDays === w.days }"
        @click="windowDays = w.days"
      >
        {{ w.label }}
      </button>
    </div>

    <div class="card radar-card">
      <svg :viewBox="`0 0 ${SIZE} ${SIZE}`" class="radar">
        <polygon v-for="(g, i) in grid" :key="`g${i}`" :points="g" fill="none" stroke="#2a3441" stroke-width="1" />
        <line
          v-for="(l, i) in axisLines"
          :key="`l${i}`"
          :x1="CX"
          :y1="CY"
          :x2="l.x2"
          :y2="l.y2"
          stroke="#2a3441"
          stroke-width="1"
        />
        <polygon
          v-if="windowDays !== 0"
          :points="prevShape"
          fill="none"
          stroke="#6e7681"
          stroke-width="1.5"
          stroke-dasharray="4 3"
        />
        <polygon :points="curShape" fill="rgba(63,185,80,0.16)" stroke="#3fb950" stroke-width="2" />
        <text
          v-for="l in labels"
          :key="l.id"
          :x="l.x"
          :y="l.y"
          text-anchor="middle"
          dominant-baseline="middle"
          fill="#8b98a5"
          font-size="10"
        >
          {{ l.name }}
        </text>
      </svg>
      <div v-if="!balance" class="empty" style="padding: 0 0 6px">这个区间还没有数据</div>
      <div v-else class="weak-hint">
        目前最偏 <b>{{ balance.top.name }}</b>（占 {{ balance.share }}%），最空 <b>{{ balance.low.name }}</b>。
      </div>
    </div>

    <div class="card">
      <div v-for="d in compareRows" :key="d.id" class="rank">
        <span class="rank-name">{{ d.icon }} {{ d.name }}</span>
        <div class="rank-bar">
          <div class="rank-fill" :style="{ width: `${(d.points / dimMax) * 100}%`, background: d.color }" />
        </div>
        <span class="rank-pts">{{ d.points }}</span>
        <span class="rank-delta" :class="d.delta > 0 ? 'up' : d.delta < 0 ? 'down' : ''">
          {{ d.delta > 0 ? '+' : '' }}{{ windowDays === 0 ? '-' : d.delta }}
        </span>
      </div>
    </div>

    <!-- 月度账本 -->
    <div class="section-title">
      <span>月度账本</span>
      <span class="mini">{{ month.total }} {{ state.settings.unit }}</span>
    </div>
    <div class="card">
      <div class="month-head">
        <button class="nav-btn" @click="shiftMonth(-1)">‹</button>
        <span class="month-title">{{ month.year }} 年 {{ month.month + 1 }} 月</span>
        <button class="nav-btn" @click="shiftMonth(1)">›</button>
      </div>

      <div class="cal">
        <span v-for="w in WEEK_LABELS" :key="w" class="cal-week">{{ w }}</span>
        <span v-for="b in blanks" :key="`b${b}`" class="cal-cell blank" />
        <button
          v-for="d in month.days"
          :key="d.key"
          class="cal-cell"
          :class="{ today: d.isToday, future: d.isFuture, picked: picked === d.key, neg: d.negative }"
          :style="{ '--heat': heat(d) }"
          @click="pick(d)"
        >
          <span class="cal-day">{{ d.day }}</span>
          <span v-if="d.points" class="cal-points">{{ d.points }}</span>
          <span v-if="d.negative" class="cal-neg">·</span>
        </button>
      </div>

      <div class="sum-grid">
        <div class="sum-cell"><b>{{ month.total }}</b><span>本月得分</span></div>
        <div class="sum-cell"><b>{{ month.activeDays }}</b><span>记分天数</span></div>
        <div class="sum-cell"><b>{{ month.avg }}</b><span>日均</span></div>
        <div class="sum-cell"><b>{{ month.best ? month.best.points : 0 }}</b><span>最高一天</span></div>
        <div class="sum-cell"><b>{{ month.goalHit }}</b><span>达标天数</span></div>
        <div class="sum-cell"><b>{{ month.negative }}</b><span>负向次数</span></div>
      </div>
      <div v-if="month.best && month.best.points" class="weak-hint">
        最高是 {{ month.best.day }} 日（{{ month.best.points }}），记分日平均 {{ month.avgActive }}。
      </div>
    </div>

    <div v-if="picked" class="card day-detail">
      <div class="day-head">
        <span>{{ dayLabel(picked) }}</span>
        <span>
          +{{ pickedEntries.reduce((s, e) => s + (e.counted ? e.points : 0), 0) }}
          <button class="del" @click="picked = null">✕</button>
        </span>
      </div>
      <div v-for="e in pickedEntries" :key="e.id" class="entry" :class="{ faded: !e.counted || e.negative }">
        <span class="dot" :style="{ background: dimById(e.dimension).color }" />
        <div class="info">
          <div class="name">{{ e.text }}</div>
          <div class="meta">
            {{ timeOf(e.ts) }} · {{ dimById(e.dimension).name }}
            <span v-if="e.negative" class="tag neg">负向</span>
            <span v-else-if="!e.counted" class="tag">不计分</span>
          </div>
        </div>
        <span class="delta earn">{{ e.counted && !e.negative ? `+${e.points}` : '0' }}</span>
      </div>
    </div>

    <div class="section-title"><span>近 14 天</span></div>
    <div class="card">
      <div class="bars">
        <div v-for="d in days" :key="d.key" class="bar-col">
          <div class="bar-stack">
            <div
              class="bar earn"
              :style="{ height: `${(d.points / dayMax) * 100}%`, opacity: d.isToday ? 1 : 0.75 }"
              :title="`${d.label} ${d.points}`"
            />
          </div>
          <span class="bar-label">{{ d.label }}</span>
        </div>
      </div>
      <div class="sum-row">
        <span>今天 <b>{{ todaySum }}</b></span>
        <span>本周 <b>{{ weekSum }}</b></span>
        <span>本月 <b>{{ monthSum }}</b></span>
      </div>
    </div>

    <div class="section-title"><span>等级进度</span></div>
    <div class="card">
      <div class="level-line">
        <span>Lv.{{ levelInfo.level }}</span>
        <span class="mini">{{ totalValue }} / {{ levelInfo.nextAt }}</span>
        <span>Lv.{{ levelInfo.level + 1 }}</span>
      </div>
      <div class="progress" style="margin-top: 8px">
        <div class="progress-fill" :style="{ width: `${levelInfo.percent}%` }" />
      </div>
      <div class="weak-hint">递增曲线：第 n 级需要 100 × (n−1) × n ÷ 2 累计值，越往后越慢。</div>
    </div>

    <div class="section-title"><span>负向标记</span></div>
    <div class="card">
      <div class="sum-row">
        <span>近 30 天 <b>{{ negativeStats.recent }}</b></span>
        <span>累计 <b>{{ negativeStats.total }}</b></span>
      </div>
      <div v-for="(n, i) in negativeStats.reasons" :key="i" class="neg-line">· {{ n.text }}</div>
      <div v-if="!negativeStats.total" class="weak-hint">还没有负向记录，挺好。</div>
      <div v-else class="weak-hint">只标记不扣分，用来回看是哪一维被挤掉了。</div>
    </div>
  </div>
</template>
