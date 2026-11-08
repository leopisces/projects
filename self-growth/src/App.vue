<script setup>
import { ref } from 'vue'
import LogPage from './components/LogPage.vue'
import HistoryPage from './components/HistoryPage.vue'
import StatsPage from './components/StatsPage.vue'
import MinePage from './components/MinePage.vue'
import { state, totalValue, levelInfo, todayValue, todayCount, streak, goalPercent } from './store.js'

const tabs = [
  { id: 'log', icon: '✍️', label: '记录' },
  { id: 'history', icon: '📜', label: '流水' },
  { id: 'stats', icon: '📈', label: '统计' },
  { id: 'mine', icon: '🙋', label: '我的' },
]
const tab = ref('log')
</script>

<template>
  <div class="app">
    <header class="topbar">
      <div class="label-row">
        <span class="label">累计成长值</span>
        <span class="level-badge">Lv.{{ levelInfo.level }}</span>
      </div>
      <div class="balance-row">
        <span class="balance-num">{{ totalValue }}</span>
        <span class="balance-unit">{{ state.settings.unit }}</span>
      </div>
      <div class="progress">
        <div class="progress-fill" :style="{ width: `${levelInfo.percent}%` }" />
      </div>
      <div class="progress-hint">距 Lv.{{ levelInfo.level + 1 }} 还差 {{ levelInfo.remain }}</div>
      <div class="chips">
        <span class="chip earn">今日 <b>+{{ todayValue }}</b></span>
        <span class="chip">记录 <b>{{ todayCount }}</b> 笔</span>
        <span class="chip">连续 <b>{{ streak }}</b> 天</span>
        <span class="chip" :class="{ done: goalPercent >= 100 }">目标 <b>{{ goalPercent }}%</b></span>
      </div>
    </header>

    <main class="main">
      <LogPage v-if="tab === 'log'" />
      <HistoryPage v-else-if="tab === 'history'" />
      <StatsPage v-else-if="tab === 'stats'" />
      <MinePage v-else />
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
          <span class="tab-icon">{{ t.icon }}</span>
          <span>{{ t.label }}</span>
        </button>
      </div>
    </nav>
  </div>
</template>
