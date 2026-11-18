<script setup>
/**
 * 开屏封面（像素游戏风）。
 * 原生 splash 只有底色 + 宝石，这一层接管后补齐文字与动效，
 * 约 2.8s 后阶梯淡出，随后由父组件卸载（不占内存、不拦交互）。
 */
import { onMounted, ref } from 'vue'
import gemUrl from '../assets/gem.svg'

const emit = defineEmits(['done'])
const out = ref(false)
const bar = ref(false)
const tip = ref(false)

onMounted(() => {
  setTimeout(() => (bar.value = true), 260)
  setTimeout(() => (tip.value = true), 1700)
  setTimeout(() => (out.value = true), 2300)
  setTimeout(() => emit('done'), 2800)
})
</script>

<template>
  <div class="splash" :class="{ out }">
    <div class="splash-mark">
      <img :src="gemUrl" class="splash-gem" alt="" />
    </div>
    <div class="splash-title">成长账本</div>
    <div class="splash-sub">自我成长 · 超越昨天的自己</div>
    <div class="splash-bar" :class="{ run: bar }"><i /></div>
    <div class="splash-hint" :class="{ on: tip }">PRESS START</div>
    <div class="splash-ver">v0.1 · 离线可用</div>
  </div>
</template>
