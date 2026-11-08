<script setup>
import { computed, ref } from 'vue'
import { state, monthStats, entriesOfDay, dayLabel, timeOf, dimensionTotals, levelInfo } from '../store.js'
import { dimById } from '../dimensions.js'

const cursor = ref({ y: new Date().getFullYear(), m: new Date().getMonth() })
const month = computed(() => monthStats(cursor.value.y, cursor.value.m))
const open = ref([]) // 展开的日期 key
const picked = ref(null) // 日历上选中的日期 key

const WEEK_LABELS = ['一', '二', '三', '四', '五', '六', '日']
const blanks = computed(() => Array.from({ length: month.value.leading }, (_, i) => i))

const goal = computed(() => Math.max(1, Number(state.settings.dailyGoal) || 20))
const isThisMonth = computed(() => {
  const now = new Date()
  return cursor.value.y === now.getFullYear() && cursor.value.m === now.getMonth()
})

function shiftMonth(step) {
  const d = new Date(cursor.value.y, cursor.value.m + step, 1)
  cursor.value = { y: d.getFullYear(), m: d.getMonth() }
  picked.value = null
  open.value = []
}

function goToday() {
  const now = new Date()
  cursor.value = { y: now.getFullYear(), m: now.getMonth() }
  picked.value = null
  open.value = []
}

/** 按「日目标」的完成度分 5 档上色，比按当月最大值稳定 */
function heatLevel(d) {
  if (!d.points) return 0
  const r = d.points / goal.value
  if (r < 0.5) return 1
  if (r < 1) return 2
  if (r < 1.5) return 3
  return 4
}

function toggle(key) {
  picked.value = key
  open.value = open.value.includes(key) ? open.value.filter((k) => k !== key) : [...open.value, key]
}

function pick(d) {
  if (d.isFuture || (!d.count && !d.negative)) {
    picked.value = null
    return
  }
  toggle(d.key)
}

function weekdayOf(key) {
  return dayLabel(key).replace(/^\d+月\d+日\s*/, '')
}

const dayTotal = (items) =>
  items.reduce((s, e) => s + (e.counted && !e.negative ? Number(e.points || 0) : 0), 0)

/** 账本式列表：本月有记录的每天一行，倒序，点开看条目 */
const ledger = computed(() =>
  month.value.days
    .filter((d) => d.count || d.negative)
    .map((d) => {
      const items = entriesOfDay(d.key)
      return { ...d, items, total: dayTotal(items) }
    })
    .reverse(),
)

const yearTotal = computed(() => dimensionTotals(365).reduce((s, d) => s + d.points, 0))
const daysInMonth = computed(() => month.value.days.length)
</script>

<template>
  <div>
    <div class="section-title">
      <span>每日得分</span>
      <span class="mini">Lv.{{ levelInfo.level }} · 近一年 {{ yearTotal }}</span>
    </div>

    <div class="card">
      <div class="month-head">
        <button class="nav-btn" @click="shiftMonth(-1)">‹</button>
        <span class="month-title">{{ month.year }} 年 {{ month.month + 1 }} 月</span>
        <button class="nav-btn" @click="shiftMonth(1)">›</button>
        <button v-if="!isThisMonth" class="btn ghost mini-btn" @click="goToday">回到本月</button>
      </div>

      <div class="cal">
        <span v-for="w in WEEK_LABELS" :key="w" class="cal-week">{{ w }}</span>
        <span v-for="b in blanks" :key="`b${b}`" class="cal-cell blank" />
        <button
          v-for="d in month.days"
          :key="d.key"
          class="cal-cell"
          :class="[
            `h${heatLevel(d)}`,
            { today: d.isToday, future: d.isFuture, picked: picked === d.key, neg: d.negative },
          ]"
          @click="pick(d)"
        >
          <span class="cal-day">{{ d.day }}</span>
          <span class="cal-points" :class="{ zero: !d.points }">{{ d.points || 0 }}</span>
        </button>
      </div>

      <div class="cal-legend">
        <span class="mini">少</span>
        <i v-for="n in 4" :key="n" class="cal-swatch" :class="`h${n}`" />
        <span class="mini">多</span>
        <span class="cal-legend-gap" />
        <span class="mini">目标 {{ goal }}/天</span>
      </div>

      <div class="sum-grid">
        <div class="sum-cell"><b>{{ month.total }}</b><span>本月得分</span></div>
        <div class="sum-cell"><b>{{ month.activeDays }}</b><span>记分天数</span></div>
        <div class="sum-cell"><b>{{ month.avg }}</b><span>日均</span></div>
        <div class="sum-cell"><b>{{ month.best ? month.best.points : 0 }}</b><span>最高一天</span></div>
        <div class="sum-cell"><b>{{ month.goalHit }}</b><span>达标天数</span></div>
        <div class="sum-cell"><b>{{ month.negative }}</b><span>负向次数</span></div>
      </div>
      <div class="weak-hint">
        {{ month.month + 1 }} 月共 {{ daysInMonth }} 天，达标 {{ month.goalHit }} 天
        <template v-if="month.best && month.best.points">
          ，最高 {{ month.best.day }} 日（{{ month.best.points }}）
        </template>
        。点日历或下面的日期都能展开明细。
      </div>
    </div>

    <div class="section-title">
      <span>{{ month.month + 1 }} 月账本</span>
      <span class="mini">{{ ledger.length }} 天有记录</span>
    </div>

    <div v-if="ledger.length" class="card ledger">
      <div v-for="d in ledger" :key="d.key" class="ledger-day">
        <button class="ledger-row" :class="{ active: picked === d.key }" @click="toggle(d.key)">
          <span class="l-date">{{ d.day }}<i>{{ weekdayOf(d.key) }}</i></span>
          <span class="l-meta">
            {{ d.count }} 笔
            <span v-if="d.negative" class="tag neg">负向 {{ d.negative }}</span>
          </span>
          <span class="l-total" :class="{ zero: !d.total }">{{ d.total }}</span>
          <span class="l-caret" :class="{ open: open.includes(d.key) }">›</span>
        </button>

        <div v-if="open.includes(d.key)" class="ledger-items">
          <div
            v-for="e in d.items"
            :key="e.id"
            class="entry"
            :class="{ faded: !e.counted || e.negative }"
          >
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
          <div class="ledger-sum">
            当日合计 <b>{{ d.total }}</b>
          </div>
        </div>
      </div>
    </div>
    <div v-else class="weak-hint" style="padding: 0 4px">这个月还没有记录。</div>
  </div>
</template>
