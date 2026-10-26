<template>
  <div class="stats-strip" v-loading="loading">
    <!-- 主指标：元件种数 / 总库存件数 —— 库存台账的体量入口，给更宽的 cell -->
    <div class="stat is-primary">
      <div class="stat-label"><IconKinds class="stat-icon" />元件种类</div>
      <div class="stat-value" :class="{ 'is-zero': !stats.total }">
        {{ stats.total ?? '—' }}
      </div>
    </div>
    <div class="stat is-primary">
      <div class="stat-label"><IconStock class="stat-icon" />总库存件数</div>
      <div class="stat-value" :class="{ 'is-zero': !stats.totalStock }">
        {{ stats.totalStock ?? '—' }}
      </div>
    </div>

    <!-- 派生指标：有货 / 零库存 是从种数和库存推出来的，权重略低 -->
    <div class="stat">
      <div class="stat-label"><IconInStock class="stat-icon" />有货种类</div>
      <div class="stat-value" :class="{ 'is-zero': !stats.inStockKinds }">
        {{ stats.inStockKinds ?? '—' }}
      </div>
    </div>
    <!-- 零库存本身是告警：>0 用 is-warn 染色（与 BOM 缺料共用同种橙色），=0 用 is-zero 静音。
         这条 cell 的「要处理」信号比有货种类重要，宽度次之。 -->
    <div class="stat is-alert" :class="{ 'is-warn': (stats.zeroStockKinds || 0) > 0 }">
      <div class="stat-label"><IconZeroStock class="stat-icon" />零库存种类</div>
      <div class="stat-value" :class="{ 'is-zero': !(stats.zeroStockKinds || 0) }">
        {{ stats.zeroStockKinds ?? '—' }}
      </div>
    </div>

    <!-- 已用存放位置：派生但有 spark 要画，给到 is-primary 的宽度让 spark 有空间展开；
         0 用 is-zero 静音，数字+「个」单位用 stat-unit 尾随。 -->
    <div class="stat is-primary">
      <div class="stat-label"><IconLocation class="stat-icon" />已用存放位置</div>
      <div class="stat-row">
        <div class="stat-value" :class="{ 'is-zero': !locationTotal }">
          {{ locationTotal ?? '—' }}<span v-if="locationTotal != null" class="stat-unit">个</span>
        </div>
        <!-- 位置占用分布：柱高按各位置元件种类数归一，只取前 12 个最满的。
             各位置元件数全相等时会退化成一排等高栅栏（假分布），此时不画。 -->
        <svg
          v-if="spark.length"
          class="stat-spark"
          :viewBox="`0 0 ${spark.length * 4 - 1} 14`"
          width="100%"
          height="14"
          preserveAspectRatio="none"
        >
          <rect
            v-for="(b, i) in spark"
            :key="b.location"
            :x="i * 4"
            :y="14 - b.h"
            width="3"
            :height="b.h"
            fill="currentColor"
          >
            <title>{{ b.location }}：{{ b.count }} 种</title>
          </rect>
        </svg>
      </div>
    </div>

    <!-- 库存健康度：绿=有货 / 橙=零库存。贴在整条底部，不占文字行高 -->
    <div v-if="ratioTotal > 0" class="stats-ratio">
      <span class="stats-ratio-in" :style="{ width: inPct + '%' }" />
      <span class="stats-ratio-zero" :style="{ width: 100 - inPct + '%' }" />
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue';
import IconKinds from './icons/IconKinds.vue';
import IconStock from './icons/IconStock.vue';
import IconInStock from './icons/IconInStock.vue';
import IconZeroStock from './icons/IconZeroStock.vue';
import IconLocation from './icons/IconLocation.vue';

const props = defineProps({
  stats: {
    type: Object,
    required: true,
    // { total, totalStock, inStockKinds, zeroStockKinds, statusCounts, locationCounts }
  },
  loading: { type: Boolean, default: false },
});

// 最多画 12 根，再多在 100px 宽度里就糊成一片了
const SPARK_MAX = 12;

const locationTotal = computed(() => props.stats.locationCounts?.length ?? null);

/**
 * locationCounts 后端已按 count 降序返回，直接取前 N 个。
 * 柱高按最大值归一到 3~14px：给个 3px 保底，否则占用极少的位置会矮到看不见。
 */
const spark = computed(() => {
  const list = (props.stats.locationCounts || []).slice(0, SPARK_MAX);
  if (list.length < 2) return [];
  const nums = list.map(x => Number(x.count) || 0);
  const max = Math.max(...nums, 1);
  const min = Math.min(...nums);
  // 全都一样高（常见：每个位置各放 1 种）时画出来就是一排等高栅栏，
  // 看着像分布其实没信息量。这种情况干脆不画。
  if (max === min) return [];
  return list.map(x => {
    const count = Number(x.count) || 0;
    return { location: x.location, count, h: Math.max(3, Math.round((count / max) * 14)) };
  });
});

const ratioTotal = computed(
  () => (Number(props.stats.inStockKinds) || 0) + (Number(props.stats.zeroStockKinds) || 0)
);

const inPct = computed(() =>
  ratioTotal.value ? ((Number(props.stats.inStockKinds) || 0) / ratioTotal.value) * 100 : 0
);
</script>

<style scoped>
/* 单元权重：主指标（元件种数 / 总库存 / 已用存放位置）拿更多空间，
   派生指标（有货 / 零库存）保持 flex:1。已用存放位置是次主指标但要装 spark，
   一起给 1.2 留出 spark 伸展空间。比例之和决定每格实际宽度。 */
.stat.is-primary { flex: 1.2 1 0; }
.stat.is-alert   { flex: 1.1 1 0; }
</style>
