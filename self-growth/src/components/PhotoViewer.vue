<script setup>
import { computed, onBeforeUnmount, ref, watch } from 'vue'
import { acquire, release } from '../photos.js'
import PixelIcon from './PixelIcon.vue'

/**
 * 全屏看图：点遮罩 / ✕ 关闭，左右按钮或 ← → 键翻页。
 * 所有图片的 objectURL 在组件卸载时统一释放。
 */
const props = defineProps({
  ids: { type: Array, default: () => [] },
  start: { type: Number, default: 0 },
})
const emit = defineEmits(['close'])

const index = ref(0)
const urls = ref({})

const current = computed(() => props.ids[index.value] || '')
const hasPrev = computed(() => index.value > 0)
const hasNext = computed(() => index.value < props.ids.length - 1)

async function load() {
  const next = {}
  for (const id of props.ids) {
    const url = await acquire(id)
    if (url) next[id] = url
  }
  urls.value = next
}

function onKey(e) {
  if (e.key === 'Escape') emit('close')
  else if (e.key === 'ArrowLeft') step(-1)
  else if (e.key === 'ArrowRight') step(1)
}

function step(d) {
  const next = index.value + d
  if (next >= 0 && next < props.ids.length) index.value = next
}

watch(
  () => props.ids,
  async (ids) => {
    for (const id of Object.keys(urls.value)) release(id)
    urls.value = {}
    if (ids.length) await load()
  },
  { immediate: true },
)

watch(
  () => props.start,
  (v) => {
    index.value = Math.min(Math.max(0, v), Math.max(0, props.ids.length - 1))
  },
  { immediate: true },
)

if (typeof window !== 'undefined') window.addEventListener('keydown', onKey)
onBeforeUnmount(() => {
  if (typeof window !== 'undefined') window.removeEventListener('keydown', onKey)
  for (const id of Object.keys(urls.value)) release(id)
  urls.value = {}
})
</script>

<template>
  <div class="photo-viewer" @click.self="emit('close')">
    <button class="pv-close" @click="emit('close')"><PixelIcon name="close" :size="14" /></button>
    <div class="pv-count" v-if="ids.length > 1">{{ index + 1 }} / {{ ids.length }}</div>

    <button v-if="hasPrev" class="pv-nav prev" @click.stop="step(-1)"><PixelIcon name="left" :size="20" /></button>
    <img v-if="urls[current]" class="pv-img" :src="urls[current]" alt="" @click.stop />
    <div v-else class="pv-loading">加载中…</div>
    <button v-if="hasNext" class="pv-nav next" @click.stop="step(1)"><PixelIcon name="right" :size="20" /></button>
  </div>
</template>
