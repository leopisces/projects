<script setup>
import { computed, ref } from 'vue'
import { state, entriesByDay, removeEntry, dayLabel, timeOf, updateEntry } from '../store.js'
import { DIMENSIONS, dimById } from '../dimensions.js'
import PhotoStrip from './PhotoStrip.vue'
import PhotoViewer from './PhotoViewer.vue'

const filter = ref('all') // all | negative
const editing = ref(null)
const viewing = ref(null) // { ids, start }

const groups = computed(() => {
  if (filter.value === 'all') return entriesByDay.value
  return entriesByDay.value
    .map((g) => ({ ...g, items: g.items.filter((e) => e.negative) }))
    .filter((g) => g.items.length)
})

const total = computed(() => state.entries.length)

function startEdit(e) {
  editing.value = { id: e.id, dimension: e.dimension, base: e.base, challenge: e.challenge }
}

function saveEdit() {
  const cur = editing.value
  if (!cur) return
  const entry = state.entries.find((x) => x.id === cur.id)
  const negative = Boolean(entry?.negative)
  updateEntry(cur.id, {
    dimension: cur.dimension,
    base: negative ? 0 : Number(cur.base) || 0,
    challenge: negative ? 1 : Number(cur.challenge) || 1,
    points: negative ? 0 : Math.round((Number(cur.base) || 0) * (Number(cur.challenge) || 1)),
  })
  editing.value = null
}
</script>

<template>
  <div>
    <div class="section-title">
      <span>流水</span>
      <span class="mini">共 {{ total }} 条</span>
    </div>

    <div class="seg">
      <button class="seg-btn" :class="{ active: filter === 'all' }" @click="filter = 'all'">全部</button>
      <button class="seg-btn" :class="{ active: filter === 'negative' }" @click="filter = 'negative'">
        只看负向
      </button>
    </div>

    <div v-if="!groups.length" class="empty">还没有记录</div>

    <div v-for="g in groups" :key="g.key" class="day-group">
      <div class="day-head">
        <span>{{ dayLabel(g.key) }}</span>
        <span>
          +{{ g.points }}
          <span v-if="g.negative" class="tag neg" style="margin-left: 6px">负向 {{ g.negative }}</span>
        </span>
      </div>

      <div v-for="e in g.items" :key="e.id" class="entry" :class="{ faded: !e.counted || e.negative }">
        <span class="dot" :style="{ background: dimById(e.dimension).color }" />
        <div class="info">
          <div class="name">{{ e.text }}</div>
          <div class="meta">
            {{ timeOf(e.ts) }} · {{ dimById(e.dimension).name }}
            <span v-if="e.source === 'rule'" class="tag">本地估算</span>
            <span v-if="e.negative" class="tag neg">负向</span>
            <span v-else-if="!e.counted" class="tag">不计分</span>
          </div>
          <div v-if="e.reason" class="reason">{{ e.reason }}</div>

          <PhotoStrip
            v-if="e.photoIds?.length"
            :ids="e.photoIds"
            :size="56"
            @open="viewing = { ids: e.photoIds, start: $event }"
          />

          <div v-if="editing && editing.id === e.id" class="edit-box">
            <div class="dim-picker">
              <button
                v-for="d in DIMENSIONS"
                :key="d.id"
                class="dim-btn"
                :class="{ active: editing.dimension === d.id }"
                :style="{ '--dim': d.color }"
                @click="editing.dimension = d.id"
              >
                {{ d.icon }}{{ d.name }}
              </button>
            </div>
            <div class="field" style="margin-top: 8px">
              <input v-model.number="editing.base" class="input num" type="number" min="0" max="20" />
              <input v-model.number="editing.challenge" class="input num" type="number" step="0.1" />
              <button class="btn primary" @click="saveEdit">保存</button>
            </div>
          </div>
        </div>
        <span class="delta earn">{{ e.counted && !e.negative ? `+${e.points}` : '0' }}</span>
        <button class="del" @click="startEdit(e)">✎</button>
        <button class="del" @click="removeEntry(e.id)">✕</button>
      </div>
    </div>

    <PhotoViewer v-if="viewing" :ids="viewing.ids" :start="viewing.start" @close="viewing = null" />
  </div>
</template>
