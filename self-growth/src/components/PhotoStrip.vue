<script setup>
import { onBeforeUnmount, ref, watch } from 'vue'
import { acquire, release } from '../photos.js'

const props = defineProps({
  ids: { type: Array, default: () => [] },
  size: { type: Number, default: 56 },
  removable: { type: Boolean, default: false },
})
const emit = defineEmits(['open', 'remove'])

/** id -> objectURL；组件卸载或 ids 变化时把不再需要的全部 release */
const urls = ref({})

async function sync() {
  const next = {}
  for (const id of props.ids) {
    if (urls.value[id]) {
      next[id] = urls.value[id]
      continue
    }
    const url = await acquire(id)
    if (url) next[id] = url
  }
  // 释放本次不再出现的
  for (const id of Object.keys(urls.value)) {
    if (!props.ids.includes(id)) release(id)
  }
  urls.value = next
}

watch(() => props.ids.join('|'), sync, { immediate: true })

onBeforeUnmount(() => {
  for (const id of props.ids) release(id)
  urls.value = {}
})
</script>

<template>
  <div v-if="ids.length" class="photo-strip">
    <div v-for="(id, i) in ids" :key="id" class="photo-thumb" :style="{ width: `${size}px`, height: `${size}px` }">
      <img v-if="urls[id]" :src="urls[id]" alt="" @click="emit('open', i)" />
      <div v-else class="photo-loading" />
      <button v-if="removable" class="photo-x" @click.stop="emit('remove', i)">✕</button>
    </div>
  </div>
</template>
