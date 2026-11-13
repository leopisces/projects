<script setup>
import { nextTick, ref, watch } from 'vue'
import LogPage from './components/LogPage.vue'
import HistoryPage from './components/HistoryPage.vue'
import CalendarPage from './components/CalendarPage.vue'
import StatsPage from './components/StatsPage.vue'
import MinePage from './components/MinePage.vue'
import PixelIcon from './components/PixelIcon.vue'
import SplashScreen from './components/SplashScreen.vue'
import { state, totalValue, levelInfo, todayValue, todayCount, streak, goalPercent } from './store.js'

const tabs = [
  { id: 'log', sprite: 'log', label: '记录' },
  { id: 'history', sprite: 'history', label: '流水' },
  { id: 'calendar', sprite: 'calendar', label: '日历' },
  { id: 'stats', sprite: 'stats', label: '统计' },
  { id: 'mine', sprite: 'mine', label: '我的' },
]
const tab = ref('log')
const booting = ref(true)
const mainEl = ref(null)
// 切 tab 时回到顶部，免得停留在上一页的滚动位置
watch(tab, () => {
  nextTick(() => {
    if (mainEl.value) mainEl.value.scrollTop = 0
  })
})
</script>

<template>
  <div class="app">
    <header class="topbar">
      <div class="label-row">
        <span class="label"><PixelIcon name="gem" :size="11" class="lbl-ic" />累计成长值</span>
        <span class="level-badge"><PixelIcon name="star" :size="10" class="badge-ic" />Lv.{{ levelInfo.level }}</span>
      </div>
      <div class="balance-row">
        <span class="bal-ic"><PixelIcon name="gem" :size="24" /></span>
        <span :key="totalValue" class="balance-num">{{ totalValue }}</span>
        <span class="balance-unit">{{ state.settings.unit }}</span>
      </div>
      <div class="progress">
        <div class="progress-fill" :style="{ width: `${levelInfo.percent}%` }" />
      </div>
      <div class="progress-hint">距 Lv.{{ levelInfo.level + 1 }} 还差 {{ levelInfo.remain }}</div>
      <div class="chips">
        <span class="chip k-green"><PixelIcon name="bolt" :size="10" /><b>+{{ todayValue }}</b></span>
        <span class="chip k-blue"><PixelIcon name="log" :size="10" />记录 <b>{{ todayCount }}</b> 笔</span>
        <span class="chip k-orange"><PixelIcon name="flame" :size="10" />连续 <b>{{ streak }}</b> 天</span>
        <span class="chip k-yellow" :class="{ done: goalPercent >= 100 }">
          <PixelIcon name="target" :size="10" />目标 <b>{{ goalPercent }}%</b>
        </span>
      </div>
    </header>

    <main ref="mainEl" class="main">
      <Transition name="page" mode="out-in">
        <LogPage v-if="tab === 'log'" key="log" />
        <HistoryPage v-else-if="tab === 'history'" key="history" />
        <CalendarPage v-else-if="tab === 'calendar'" key="calendar" />
        <StatsPage v-else-if="tab === 'stats'" key="stats" />
        <MinePage v-else key="mine" />
      </Transition>
    </main>

    <nav class="tabbar">
      <div class="tabbar-inner">
        <button
          v-for="t in tabs"
          :key="t.id"
          class="tab"
          :class="{ active: tab === t.id }"
          @click="tab = t.id"
        >
          <span class="tab-icon"><PixelIcon :name="t.sprite" :size="18" /></span>
          <span>{{ t.label }}</span>
        </button>
      </div>
    </nav>

    <SplashScreen v-if="booting" @done="booting = false" />
  </div>
</template>
