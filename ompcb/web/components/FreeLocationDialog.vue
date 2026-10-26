<template>
  <el-dialog
    :model-value="visible"
    title="未使用库位"
    width="540px"
    :close-on-click-modal="false"
    :close-on-press-escape="true"
    :show-close="true"
    @update:model-value="(v) => emit('update:visible', v)"
    @open="onOpen"
  >
    <template v-if="loading">
      <div class="free-loading">正在计算未使用库位…</div>
    </template>

    <template v-else-if="result">
      <!-- 一个网格库位都没有：说明还没开始用 {层}{行}{列} 编址，
           空位无从算起。明说原因并给出格式示例，比显示"共 0 个空位"有用。 -->
      <div v-if="result.layers.length === 0" class="free-blank">
        <div class="free-blank-title">还没有网格库位</div>
        <div class="free-blank-text">
          库位按「层 + 行 + 列」编址，如 <code>A15</code> 表示 A 层第 1 行第 5 列。
          先给元件填上这样的位置，这里就会列出中间空出来的格子。
        </div>
        <div v-if="result.unparsed?.length" class="free-blank-text">
          当前有 {{ result.unparsed.length }} 个库位不是这个格式：{{ result.unparsed.slice(0, 5).join('、') }}{{ result.unparsed.length > 5 ? ' 等' : '' }}
        </div>
      </div>

      <template v-else>
        <!-- 按层分行：A 层一行、B 层一行……不同层的空位绝不挤在同一排。
             层号虽然已在 A14 这个编号里，但混排时视觉上分不出层的边界，
             找「B 层还有哪儿空」得逐个念编号。每层独占一行才能一眼扫完。
             层标签只给一个字母（A/B/F），不写「A 层 / 行1~1 · 列1~5」那种冗余抬头。 -->
        <div class="free-layers">
          <div v-for="L in layersWithFree" :key="L.layer" class="free-layer-row">
            <div class="free-layer-tag">{{ L.layer }}</div>
            <div class="free-layer-cells">
              <div
                v-for="loc in L.free"
                :key="loc"
                class="free-cell"
                @click="copyLocation(loc)"
                :title="`点击复制 ${loc}`"
              >
                {{ loc }}
              </div>
            </div>
          </div>
        </div>

        <!-- 计数与口径退到方块之后：先给答案，再解释范围。
             口径必须留着——否则会被问「为什么不列 A21」。 -->
        <div class="free-foot">
          共 {{ result.total }} 个空位<span v-if="result.maxLocation">，当前用到 {{ result.maxLocation }}</span>；
          只列已用范围内空出来的格子，不凭空提议新行或新层。
          <span v-if="result.unparsed?.length" class="free-foot-warn">
            另有 {{ result.unparsed.length }} 个非网格库位未参与计算。
          </span>
        </div>
      </template>
    </template>

    <template #footer>
      <el-button @click="emit('update:visible', false)">关闭</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { computed, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { listFreeLocations } from '../api.js'

defineProps({
  visible: { type: Boolean, default: false },
})

const emit = defineEmits(['update:visible'])

const loading = ref(false)
const result = ref(null)

/**
 * 有空位的层，按层序排列。
 *
 * 后端已按「层序 → 行 → 列」把每层的 free 排好，这里只过滤掉没有空位的层——
 * 某层已满时列一个空行出来只会让人以为渲染坏了。
 */
const layersWithFree = computed(() =>
  (result.value?.layers || []).filter(L => L.free?.length > 0)
)

async function onOpen() {
  loading.value = true
  result.value = null
  try {
    const data = await listFreeLocations()
    result.value = data
  } catch (e) {
    ElMessage.error('获取未使用库位失败：' + e.message)
  } finally {
    loading.value = false
  }
}

/** 点击空位直接复制到剪贴板，方便填到编辑框里 */
async function copyLocation(loc) {
  // clipboard API 在非 HTTPS/非 localhost 下不可用，失败就明说，
  // 静默无反应会让人以为点击坏了
  try {
    await navigator.clipboard.writeText(loc)
    ElMessage.success(`已复制 ${loc}`)
  } catch {
    ElMessage.warning(`当前环境无法自动复制，请手动记下 ${loc}`)
  }
}
</script>

<style scoped>
.free-loading {
  padding: 32px 0;
  text-align: center;
  color: var(--c-text-3);
  font-size: var(--fs-sm);
}

/* 尚无网格库位时的空态 */
.free-blank {
  padding: 24px 4px;
  text-align: center;
}
.free-blank-title {
  font-size: var(--fs-base);
  font-weight: 600;
  color: var(--c-text-2);
  margin-bottom: 8px;
}
.free-blank-text {
  font-size: var(--fs-sm);
  color: var(--c-text-3);
  line-height: 1.7;
}
.free-blank-text code {
  padding: 1px 5px;
  border-radius: 2px;
  background: var(--c-sunken-2);
  border: 1px solid var(--c-border-2);
  font-family: var(--font-mono);
  color: var(--c-accent);
}

/* 按层分行：每层一条，层标签在左、空位方块在右。
   不同层不共享一个流式容器，所以 A 层剩 1 格时 B 层也不会被拉上来同排。 */
.free-layers {
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.free-layer-row {
  display: flex;
  align-items: flex-start;
  gap: 10px;
}
/* 层标签：只给字母，编号里已含层信息，写「A 层」是重复 */
.free-layer-tag {
  flex: 0 0 auto;
  width: 26px;
  height: 26px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 3px;
  background: var(--c-sunken-2);
  border: 1px solid var(--c-border-2);
  font-family: var(--font-mono);
  font-size: var(--fs-sm);
  font-weight: 600;
  color: var(--c-text-2);
}
/* 同层内的方块横向铺、超宽换行，但换行仍在本层的行内 */
.free-layer-cells {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  flex: 1;
}
.free-cell {
  display: flex;
  align-items: center;
  justify-content: center;
  min-width: 46px;
  height: 26px;
  padding: 0 6px;
  font-family: var(--font-mono);
  font-size: var(--fs-sm);
  font-weight: 600;
  color: var(--c-accent);
  background: var(--c-accent-soft);
  border: 1px solid var(--c-accent-border);
  border-radius: 3px;
  cursor: pointer;
  user-select: none;
  transition: background 0.1s, border-color 0.1s, color 0.1s;
}
.free-cell:hover {
  background: var(--c-accent);
  color: #fff;
  border-color: var(--c-accent);
}

/* 计数与口径：退到方块之后，弱化色。
   先给答案（方块），再解释范围。 */
.free-foot {
  margin-top: 14px;
  padding-top: 10px;
  border-top: 1px solid var(--c-border-2);
  font-size: var(--fs-micro);
  color: var(--c-text-3);
  line-height: 1.6;
}
.free-foot-warn {
  color: var(--c-warn);
}
</style>