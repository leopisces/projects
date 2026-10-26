<template>
  <div class="stats-strip" v-loading="loading">
    <!-- 主指标：BOM 行数 / 总需求（套×数量）—— 是这页的入口数据，给更宽的 cell -->
    <div class="stat is-primary">
      <div class="stat-label"><IconBomLines class="stat-icon" />BOM 明细</div>
      <div class="stat-value">
        {{ stats.total ?? '—' }}<span v-if="stats.total != null" class="stat-unit">条</span>
      </div>
    </div>
    <div class="stat is-primary">
      <div class="stat-label">
        <IconRequired class="stat-icon" />{{ sets > 1 ? `总需求 (${sets} 套)` : '总用量 (1 套)' }}
      </div>
      <div class="stat-value">{{ stats.totalRequired ?? stats.totalQty ?? '—' }}</div>
    </div>

    <!-- 派生指标：已关联 / 未匹配 是 BOM 与库存的命中情况，权重略低 -->
    <div class="stat">
      <div class="stat-label"><IconMatched class="stat-icon" />已关联库存</div>
      <div class="stat-value">
        {{ stats.matchedLines ?? '—' }}<span v-if="stats.matchedLines != null" class="stat-unit">行</span>
      </div>
    </div>
    <!-- 未匹配本身不是告警，是中性信息：0=全部命中(好)，>0=有漏匹配(可看)，
         把 0 用 is-muted 静音，把真实数字留给眼睛 -->
    <div class="stat" :class="{ 'is-muted': !stats.unmatchedLines }">
      <div class="stat-label"><IconUnmatched class="stat-icon" />未匹配库存</div>
      <div class="stat-value">
        {{ stats.unmatchedLines ?? '—' }}<span v-if="stats.unmatchedLines != null" class="stat-unit">行</span>
      </div>
    </div>

    <!-- 告警指标：缺料项 / 需采购总数 —— 用 is-warn 染色；0 时数字 is-zero 静音 -->
    <div class="stat is-alert" :class="{ 'is-warn': (stats.shortage || 0) > 0 }">
      <div class="stat-label"><IconShortage class="stat-icon" />缺料项</div>
      <div class="stat-value" :class="{ 'is-zero': !(stats.shortage || 0) }">{{ stats.shortage ?? '—' }}</div>
    </div>
    <div class="stat is-alert" :class="{ 'is-warn': (stats.shortageQty || 0) > 0 }">
      <div class="stat-label"><IconPurchase class="stat-icon" />需采购总数</div>
      <div class="stat-value" :class="{ 'is-zero': !(stats.shortageQty || 0) }">
        {{ stats.shortageQty ?? '—' }}<span v-if="stats.shortageQty != null" class="stat-unit">件</span>
      </div>
    </div>

    <!-- 已焊接：与缺料项/需采购总数同理，主值用「行数（项）」，再用次级文本展示总件数。
         0 在初装板/没领过料时是常态，不报警；用 is-muted 把它和未匹配那种中性信息放同一档。 -->
    <div class="stat" :class="{ 'is-muted': (stats.solderedLines || 0) === 0 }">
      <div class="stat-label"><IconSoldered class="stat-icon" />已焊接</div>
      <div class="stat-value">
        {{ stats.solderedLines ?? '—' }}
        <span v-if="(stats.solderedQty || 0) > 0" class="stat-sub">{{ stats.solderedQty }} 件</span>
      </div>
    </div>

    <!-- 备料健康度：绿=已关联且不缺料 / 橙=缺料 / 灰=未匹配到库存。
         三段合计为 BOM 总行数，贴在整条底部，不占文字行高 -->
    <div v-if="ratioTotal > 0" class="stats-ratio">
      <span class="stats-ratio-in" :style="{ width: pct(readyLines) + '%' }" />
      <span class="stats-ratio-zero" :style="{ width: pct(stats.shortage) + '%' }" />
      <span class="stats-ratio-idle" :style="{ width: pct(stats.unmatchedLines) + '%' }" />
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue';
import IconBomLines from './icons/IconBomLines.vue';
import IconRequired from './icons/IconRequired.vue';
import IconMatched from './icons/IconMatched.vue';
import IconUnmatched from './icons/IconUnmatched.vue';
import IconShortage from './icons/IconShortage.vue';
import IconPurchase from './icons/IconPurchase.vue';
import IconSoldered from './icons/IconSoldered.vue';

const props = defineProps({
  stats: {
    type: Object,
    required: true,
    // { total, totalQty, totalRequired, matchedLines, unmatchedLines,
    //   shortage, shortageQty, totalStock, statusCounts, sets }
  },
  sets: { type: Number, default: 1 },
  loading: { type: Boolean, default: false },
});

const ratioTotal = computed(() => Number(props.stats.total) || 0);

// 已关联里扣掉缺料的，才是真正「这行料备齐了」。缺料只在已关联行中统计，不会与未匹配重叠。
const readyLines = computed(() =>
  Math.max(0, (Number(props.stats.matchedLines) || 0) - (Number(props.stats.shortage) || 0))
);

function pct(n) {
  if (!ratioTotal.value) return 0;
  return ((Number(n) || 0) / ratioTotal.value) * 100;
}
</script>

<style scoped>
/* 单元权重：主指标（BOM 行数 / 总需求）拿更多横向空间，告警指标（缺料 / 需采购）次之，
   派生指标（已关联 / 未匹配）保持默认 flex:1。比例之和决定每格实际宽度。
   全局 .stat 是 flex:1 1 0，这里用更具体的 [data-v-xxx] 选择器覆盖。 */
.stat.is-primary { flex: 1.4 1 0; }
.stat.is-alert   { flex: 1.2 1 0; }

/* 已焊接的「X 件」次级文本：与主值同一行、字号小一档、低对比度。
   .stat.is-muted .stat-value 的静音由全局 styles.css 统一处理，这里不重复定义。
   注意：次级文本只展示件数，不参与 ratio 段——已焊接是行进度而不是行的状态分区，
   与 ready/shortage/unmatched 不在同一维度，硬塞进 stats-ratio 会破坏它的「合计 = total」不变式。 */
.stat-value .stat-sub {
  margin-left: 6px;
  font-size: var(--fs-meta);
  font-weight: 500;
  color: var(--c-text-3);
  font-family: var(--font-mono);
}
.stat.is-muted .stat-value .stat-sub {
  color: var(--c-muted);
}
</style>
