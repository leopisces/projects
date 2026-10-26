<template>
  <el-dialog
    :model-value="visible"
    title="库存关联"
    width="min(1380px, 96vw)"
    top="6vh"
    :close-on-click-modal="false"
    :close-on-press-escape="!binding"
    :show-close="!binding"
    @update:model-value="(v) => emit('update:visible', v)"
    @open="onOpen"
    @closed="onClosed"
  >
    <!-- 当前操作的 BOM 行：明确「我在给哪一行找料」 -->
    <div v-if="row" class="ui-target">
      <div class="ui-target-name">{{ row.name || '—' }}</div>
      <div class="ui-target-meta">
        <span v-if="row.package">{{ row.package }}</span>
        <span v-if="row.designator">位号 {{ row.designator }}</span>
        <span v-if="row.mfr_pn">当前料号 {{ row.mfr_pn }}</span>
        <span v-else class="is-short">当前无制造商料号</span>
      </div>
    </div>

    <div class="match-hint ui-hint">
      按<strong>名称 + 封装</strong>完全相同在库存台账里查找。绑定会把所选记录的制造商料号写入本
      BOM 行 —— 台账与 BOM 始终只靠料号关联，不额外存对应关系。<br />
      点每行左侧箭头可展开<strong>明细</strong>：看这个料号当前被哪些产品的 BOM 用到、各用多少。
    </div>

    <el-table
      v-loading="loading"
      :data="candidates"
      border
      stripe
      size="small"
      class="match-table"
      row-key="id"
      :expand-row-keys="expandedKeys"
      @expand-change="onExpandChange"
    >
      <template #empty>
        <div class="match-empty">
          <EmptyBoard />
          <!-- 空态必须解释「为什么空」和「接下来该干什么」，否则用户以为功能坏了。
               三种成因的处置办法完全不同，所以分开写。 -->
          <div class="match-empty-text">
            <template v-if="loading">正在查询…</template>
            <!-- 同规格只有已绑的那一条：绝不能说「没有同规格元件」——明明有，
                 只是被排除了。说错会让人以为数据丢了，跑去库存台账白找一趟。 -->
            <template v-else-if="currentCount > 0">
              同名同封装的库存记录只有当前已关联的
              <strong>{{ row.mfr_pn }}</strong> 这一条，没有其他可换的选择。
            </template>
            <template v-else-if="!row?.mfr_pn">
              台账里没有名称与封装都相同的元件，且本行没有制造商料号。<br />
              这类行（多为结构件，如 CPU、外壳、连接器）通常无需关联库存。<br />
              若确实要管库存，请先到<strong>库存台账</strong>手工建立记录并填写制造商料号。
            </template>
            <template v-else>
              台账里没有名称与封装都相同的元件。<br />
              本行已有制造商料号 <strong>{{ row.mfr_pn }}</strong
              >，可在库存台账为它建档入库后自动关联，无需在此绑定。
            </template>
          </div>
        </div>
      </template>

      <!-- 明细：这条库存料号当前被哪些产品的 BOM 用到。
           一条库存可能被多个产品同时引用，换料号前得知道会影响谁。
           用展开行而不是二级弹框：弹框里再开弹框会丢掉「我正在挑候选」的上下文，
           展开让「候选 → 谁在用它」留在同一视线内，收起就回到原状。
           懒加载：只在展开时才请求，否则打开弹框就要为每条候选各发一个请求。 -->
      <el-table-column type="expand">
        <template #default="{ row: cand }">
          <div class="usage-panel">
            <div v-if="usageOf(cand).loading" class="usage-state">正在查询关联产品…</div>
            <div v-else-if="usageOf(cand).error" class="usage-state is-short">
              查询失败：{{ usageOf(cand).error }}
            </div>
            <!-- 台账里有、但没有任何 BOM 在用：这是有效信息（可以放心换），
                 不是错误，所以中性色。 -->
            <div v-else-if="!usageOf(cand).products.length" class="usage-state">
              暂无产品的 BOM 用到该料号。
            </div>
            <template v-else>
              <div class="usage-head">
                <strong>{{ usageOf(cand).productCount }}</strong> 个产品 /
                <strong>{{ usageOf(cand).lineCount }}</strong> 行 BOM 用到，
                单板合计 <strong>{{ usageOf(cand).totalQty }}</strong>
                <span v-if="usageOf(cand).totalSolderedQty > 0">
                  已领 <strong>{{ usageOf(cand).totalSolderedQty }}</strong>
                </span>
              </div>
              <!-- 产品是主语：用户问的是「哪些产品会受影响」。
                   真实数据里单个料号最多跨 2 个产品、2 行，所以不分页不折叠。 -->
              <div
                v-for="p in usageOf(cand).products"
                :key="p.product_id ?? p.product_code"
                class="usage-product"
              >
                <div class="usage-product-head">
                  <span class="usage-code">{{ p.product_code }}</span>
                  <span v-if="p.product_name" class="usage-pname">{{ p.product_name }}</span>
                  <span class="usage-sum">
                    用量 {{ p.qty }}
                    <template v-if="p.solderedQty > 0"> · 已领 {{ p.solderedQty }}</template>
                  </span>
                </div>
                <div v-for="ln in p.lines" :key="ln.id" class="usage-line">
                  <span class="usage-seq">#{{ ln.seq }}</span>
                  <span class="usage-name">{{ ln.name || '—' }}</span>
                  <span class="usage-desig">{{ ln.designator || '—' }}</span>
                  <span class="usage-qty">×{{ ln.qty }}</span>
                  <!-- 已领 0 是「还没领过」，中性信息，弱化显示 -->
                  <span :class="['usage-sold', { 'is-zero': !ln.solderedQty }]">
                    已领 {{ ln.solderedQty }}
                  </span>
                  <!-- 这行的料号本身就是绑来的：说明它当前料号是绑定结果而非导入值 -->
                  <el-tooltip
                    v-if="ln.bound"
                    content="该 BOM 行的料号是手动绑定的结果，不是导入原值"
                    placement="top"
                  >
                    <span class="usage-bound">绑</span>
                  </el-tooltip>
                </div>
              </div>
            </template>
          </div>
        </template>
      </el-table-column>

      <el-table-column prop="name" label="名称" min-width="140" show-overflow-tooltip />
      <el-table-column prop="package" label="封装" width="100" show-overflow-tooltip />
      <el-table-column prop="mfr_pn" label="制造商料号" min-width="190" class-name="col-pn" show-overflow-tooltip>
        <template #default="{ row: cand }">
          <span v-if="cand.mfr_pn">{{ cand.mfr_pn }}</span>
          <!-- 料号是唯一关联依据，空了就绑不上（后端 JOIN 有 mfr_pn <> '' 守卫） -->
          <el-tooltip v-else content="该记录没有制造商料号，无法作为关联依据" placement="top">
            <span class="pn-warn">缺料号</span>
          </el-tooltip>
        </template>
      </el-table-column>
      <!-- 制造商：绑定后 BOM 表格的「制造商」列显示的就是这里的值（核心设计 §1.5），
           挑候选时看不到它就等于不知道换过去会显示成什么。宽度够了才补上。 -->
      <el-table-column prop="mfr" label="制造商" min-width="130" show-overflow-tooltip>
        <template #default="{ row: cand }">{{ cand.mfr || '—' }}</template>
      </el-table-column>
      <el-table-column prop="stock" label="库存" width="82" align="right" header-align="right" class-name="col-num">
        <template #default="{ row: cand }">
          <span :class="{ 'is-short': !cand.stock }">{{ cand.stock }}</span>
          <!-- 库存偏低只提示、不禁用：换个本身也没几个的料通常解决不了缺料，
               但绑不绑是使用者的判断（先绑上再采购也是合理用法）。 -->
          <el-tooltip
            v-if="cand.stock > 0 && isLowStock(cand)"
            :content="`库存不高于 ${minBindStock}，换过去可能仍然缺料。仍可绑定，请自行判断。`"
            placement="top"
          >
            <span class="stock-low-flag">低</span>
          </el-tooltip>
        </template>
      </el-table-column>
      <el-table-column prop="status" label="状态" width="80" align="center">
        <template #default="{ row: cand }">
          <el-tag :type="cand.stock > 0 ? 'success' : 'danger'" size="small" effect="light">
            {{ cand.status }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="location" label="位置" width="100" show-overflow-tooltip>
        <template #default="{ row: cand }">{{ cand.location || '—' }}</template>
      </el-table-column>
      <el-table-column prop="supplier_pn" label="供应商料号" min-width="130" class-name="col-pn" show-overflow-tooltip>
        <template #default="{ row: cand }">{{ cand.supplier_pn || '—' }}</template>
      </el-table-column>

      <el-table-column label="操作" width="160" fixed="right" align="center">
        <template #default="{ row: cand }">
          <div class="op-cell">
            <!-- 电气参数：调 DeepSeek 对比 BOM 原始料号与候选料号的电气差异。
                 有料号才能对比；同一料号对比自己没意义。 -->
            <el-button
              v-if="cand.mfr_pn && cand.mfr_pn !== row?.mfr_pn"
              link
              type="info"
              size="small"
              :loading="specLoadingPn === cand.mfr_pn"
              :disabled="binding"
              @click="loadSpec(cand)"
            >
              电气参数
            </el-button>
            <!-- 当前已关联的那条不在 candidates 里（已过滤），所以这里不必再判「当前关联」。
                 无料号：绑了等于写空串，会被 JOIN 守卫忽略，还会擦掉原有料号 -->
            <el-tooltip
              v-if="!cand.mfr_pn"
              content="该记录缺制造商料号，无法绑定"
              placement="top"
            >
              <span class="muted">不可绑定</span>
            </el-tooltip>
            <el-button
              v-else
              link
              type="primary"
              size="small"
              :loading="bindingPn === cand.mfr_pn"
              :disabled="binding"
              @click="onBind(cand)"
            >
              绑定
            </el-button>
          </div>
        </template>
      </el-table-column>
    </el-table>

    <!-- AI 电气参数对比报告 -->
    <div v-if="specPanel" class="spec-panel">
      <div class="spec-panel-head">
        <span class="spec-panel-title">
          电气参数对比：{{ specPanel.bom_mfr_pn }} vs {{ specPanel.cand_mfr_pn }}
        </span>
        <el-tag
          v-if="specPanel.risk_level"
          :type="riskTagType(specPanel.risk_level)"
          size="small"
          effect="light"
        >
          {{ riskLabel(specPanel.risk_level) }}
        </el-tag>
        <el-button link type="info" size="small" class="spec-close" @click="specPanel = null">
          收起
        </el-button>
      </div>

      <!-- AI 分析中 -->
      <div v-if="specLoading" class="spec-loading">
        <div class="spec-loading-icon">
          <svg viewBox="0 0 24 24" width="20" height="20" class="spin-icon">
            <circle cx="12" cy="12" r="10" fill="none" stroke="currentColor" stroke-width="2" stroke-dasharray="40 20" />
          </svg>
        </div>
        <div class="spec-loading-text">AI 正在分析元件电气参数…</div>
        <div class="spec-loading-hint">首次查询需要几秒，结果会缓存，后续秒回</div>
      </div>

      <!-- AI 分析失败 -->
      <div v-else-if="specError" class="spec-error">
        <span class="spec-error-text">{{ specError }}</span>
        <el-button link type="primary" size="small" @click="retrySpec">重试</el-button>
      </div>

      <!-- 对比结果 -->
      <template v-else-if="specPanel.spec && !specPanel.parse_error">
        <!-- 基本信息双栏 -->
        <div class="spec-params-grid">
          <div class="spec-col">
            <div class="spec-col-header">BOM 料号：{{ specPanel.spec.bom_mfr_pn }}</div>
            <div v-for="(v, k) in (specPanel.spec.bom_params || {})" :key="'b-'+k" class="spec-param-row">
              <span class="spec-param-label">{{ paramLabel(k) }}</span>
              <span class="spec-param-value">{{ v || '—' }}</span>
            </div>
          </div>
          <div class="spec-col">
            <div class="spec-col-header">候选料号：{{ specPanel.spec.cand_mfr_pn }}</div>
            <div v-for="(v, k) in (specPanel.spec.cand_params || {})" :key="'c-'+k" class="spec-param-row">
              <span class="spec-param-label">{{ paramLabel(k) }}</span>
              <span class="spec-param-value">{{ v || '—' }}</span>
            </div>
          </div>
        </div>

        <!-- 参考单价 -->
        <div v-if="specPanel.spec.bom_price || specPanel.spec.cand_price" class="spec-price-row">
          <span class="spec-price-label">参考单价</span>
          <span class="spec-price-bom">BOM：¥{{ specPanel.spec.bom_price || '—' }}</span>
          <span class="spec-price-arrow">→</span>
          <span class="spec-price-cand">候选：¥{{ specPanel.spec.cand_price || '—' }}</span>
        </div>

        <!-- 差异列表 -->
        <div v-if="specPanel.spec.differences?.length" class="spec-diffs">
          <div class="spec-diffs-title">参数差异</div>
          <div v-for="(d, i) in specPanel.spec.differences" :key="i" class="spec-diff-row">
            <span class="spec-diff-param">{{ d.param }}</span>
            <span class="spec-diff-bom">{{ d.bom_value }}</span>
            <span class="spec-diff-arrow">→</span>
            <span class="spec-diff-cand">{{ d.cand_value }}</span>
            <el-tag
              :type="impactType(d.impact)"
              size="small"
              effect="light"
              class="spec-diff-impact"
            >
              {{ d.impact }}
            </el-tag>
          </div>
        </div>

        <!-- 综合建议 -->
        <div v-if="specPanel.spec.recommendation" class="spec-recommendation">
          <div class="spec-rec-title">综合建议</div>
          <div class="spec-rec-text">{{ specPanel.spec.recommendation }}</div>
        </div>
        <div v-if="specPanel.spec.notes" class="spec-notes">
          {{ specPanel.spec.notes }}
        </div>
      </template>

      <!-- AI 返回了无法解析的内容 -->
      <div v-else-if="specPanel.spec?.raw_response" class="spec-raw">
        <div class="spec-raw-label">AI 返回内容（格式异常）：</div>
        <pre class="spec-raw-text">{{ specPanel.spec.raw_response }}</pre>
      </div>
    </div>

    <!-- 已关联的那条被排除在列表外，但要让人知道它存在，否则会以为台账里少了一条 -->
    <div v-if="currentCount > 0" class="ui-hint match-current">
      当前已关联 <strong>{{ row.mfr_pn }}</strong>，该记录不在上表中。
    </div>

    <!-- 共用料号会让 BOM 行在列表里重复出现（mfr_pn 无唯一约束），提前说清楚 -->
    <div v-if="sharedPnCandidates.length" class="match-warn ui-hint">
      注意：<strong>{{ sharedPnCandidates.map(c => c.mfr_pn).join('、') }}</strong>
      在台账里对应多条记录。绑定后本 BOM 行会同时关联它们，列表中会重复显示该行。
    </div>

    <template #footer>
      <el-button @click="cancel" :disabled="binding">关闭</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { computed, ref } from 'vue';
import EmptyBoard from './EmptyBoard.vue';
import { listMaterialUsage, fetchComponentSpec } from '../api.js';
import { toExpandKeys, isRowExpanded } from '../expand-keys.js';

const props = defineProps({
  visible: { type: Boolean, default: false },
  // 当前 BOM 行。名称/封装用于查候选，mfr_pn 用于标注「当前关联」与空态文案
  row: { type: Object, default: null },
  list: { type: Array, default: () => [] },
  loading: { type: Boolean, default: false },
  binding: { type: Boolean, default: false },
  // 库存「偏低」的提示阀值，由后端 /inventory/match 带出（见 server/bind-rules.js）。
  // 不在前端硬编码：阀值写两份，改一处漏一处就会两边说法不一致。
  minBindStock: { type: Number, default: 0 },
});

const emit = defineEmits(['update:visible', 'bind']);

// 正在绑定的料号，用来只给被点的那一行转圈，而不是整表一起转
const bindingPn = ref('');

/**
 * 可绑定的候选：排除本行当前已关联的那条记录。
 *
 * 它列出来也只能显示「当前关联」而无法点击，白占一行；把它排除掉，
 * 表里剩下的每一条都是「可以换过去的选择」，这才是这个弹框要回答的问题。
 *
 * 按 mfr_pn 而不是 inventory_id 判断：BOM 与台账本来就只靠料号关联，
 * 同一料号在台账里可能有多条记录（mfr_pn 无唯一约束），它们对 BOM 而言
 * 是同一个关联目标，都该一并排除。
 */
const candidates = computed(() => {
  const current = props.row?.mfr_pn;
  if (!current) return props.list;
  return props.list.filter(c => c.mfr_pn !== current);
});

/** 被排除掉的「当前已关联」记录条数，用于区分空态成因 */
const currentCount = computed(() => props.list.length - candidates.value.length);

/** 料号在台账里对应多条记录的候选（去重后用于底部警告） */
const sharedPnCandidates = computed(() => {
  const seen = new Set();
  return candidates.value.filter(c => {
    if (!(Number(c.mfrPnKinds) > 1) || !c.mfr_pn || seen.has(c.mfr_pn)) return false;
    seen.add(c.mfr_pn);
    return true;
  });
});

/**
 * 库存是否偏低（仅提示，不影响能否绑定）。
 *
 * 换一个本身也没几个的料通常解决不了缺料，值得提醒一句 —— 但绑不绑是使用者
 * 的判断：先绑上再采购、或明知不够也要先记录关联，都是合理用法。
 * 所以这里只标注，绑定按钮照常可点。
 *
 * minBindStock 为 0（后端没带出来）时不提示，避免把所有候选都标成偏低。
 */
function isLowStock(cand) {
  if (!(props.minBindStock > 0)) return false;
  return (Number(cand?.stock) || 0) <= props.minBindStock;
}

// --- 电气参数对比报告 --------------------------------------------------------

/** 当前展开的报告面板（同时只展示一份），null = 收起 */
const specPanel = ref(null)
/** 正在查询的料号（控制 loading 按钮） */
const specLoadingPn = ref('')
/** AI 分析中 */
const specLoading = ref(false)
/** 分析失败的错误信息 */
const specError = ref('')

/**
 * 加载两个料号的电气参数对比。
 *
 * 先查后端缓存表，有就秒回；没有则调 DeepSeek API 分析（首次需要几秒）。
 * 结果按 (bom_mfr_pn, cand_mfr_pn) 缓存，同一对料号只调一次 AI。
 *
 * 点同一个候选的「电气参数」按钮：如果面板已展开就收起，否则展开新报告。
 */
async function loadSpec(cand) {
  const bomPn = props.row?.mfr_pn
  const candPn = cand.mfr_pn
  if (!bomPn || !candPn) return

  // 点已展开的同一个候选：收起面板
  if (specPanel.value?.cand_mfr_pn === candPn && specPanel.value?.bom_mfr_pn === bomPn) {
    specPanel.value = null
    return
  }

  // 先显示面板骨架 + loading 态，让用户知道「在查了」
  specPanel.value = { bom_mfr_pn: bomPn, cand_mfr_pn: candPn, spec: null }
  specLoadingPn.value = candPn
  specLoading.value = true
  specError.value = ''

  try {
    const res = await fetchComponentSpec(bomPn, candPn, props.row?.name, props.row?.package)
    if (res.spec === null && res.source === 'same') {
      specPanel.value = null
      return
    }
    specPanel.value = res
  } catch (e) {
    specError.value = e.message || '查询失败'
  } finally {
    specLoadingPn.value = ''
    specLoading.value = false
  }
}

/** 重试上一次失败的查询 */
function retrySpec() {
  if (!specPanel.value) return
  const candPn = specPanel.value.cand_mfr_pn
  const cand = candidates.value.find(c => c.mfr_pn === candPn)
  if (cand) loadSpec(cand)
}

/** 风险等级 → el-tag 颜色 */
function riskTagType(level) {
  if (level === 'high') return 'danger'
  if (level === 'medium') return 'warning'
  return 'success'
}

/** 风险等级 → 中文标签 */
function riskLabel(level) {
  if (level === 'high') return '不兼容'
  if (level === 'medium') return '需确认'
  return '可替换'
}

/** 差异影响 → el-tag 颜色 */
function impactType(impact) {
  if (impact?.includes('不可')) return 'danger'
  if (impact?.includes('需')) return 'warning'
  return 'success'
}

/** 参数 key → 中文标签 */
function paramLabel(key) {
  const map = {
    description: '描述', voltage: '电压', current: '电流',
    power: '功率', tolerance: '精度', package: '封装',
    temperature_range: '温度范围', other_params: '其他参数'
  }
  return map[key] || key
}

// --- 明细：该料号被哪些产品用到 --------------------------------------------
// 展开行的数据，按料号缓存（不是按 inventory id）：BOM 与台账只靠料号关联，
// 同一料号的多条库存记录展开后看到的必然是同一份产品用量。

/** 当前展开的行 key（el-table 的 row-key 用的是 inventory.id） */
const expandedKeys = ref([]);
/** mfr_pn → { loading, error, products, productCount, lineCount, totalQty, totalSolderedQty } */
const usageCache = ref({});

const EMPTY_USAGE = {
  loading: false,
  error: '',
  products: [],
  productCount: 0,
  lineCount: 0,
  totalQty: 0,
  totalSolderedQty: 0,
};

/** 模板里取这条候选的明细状态；没有则给一份空壳，避免模板里到处判空 */
function usageOf(cand) {
  return usageCache.value[cand?.mfr_pn] || EMPTY_USAGE;
}

/**
 * 展开/收起。
 *
 * 展开态一律以 el-table 给的「已展开行数组」为准，绝不自己推断 ——
 * 见 web/expand-keys.js 里记的坑（第二个参数是数组不是布尔，
 * 当布尔用会导致点开后收不回去）。
 *
 * 只在展开且未缓存时才发请求：否则打开弹框就得为每条候选各发一个请求，
 * 而多数时候用户只想看其中一条。
 */
async function onExpandChange(cand, expandedRows) {
  // expand-row-keys 是受控的，得自己同步
  expandedKeys.value = toExpandKeys(expandedRows);

  const pn = cand?.mfr_pn;
  // 无料号的候选绑不上，也没有可查的关联（JOIN 有 mfr_pn <> '' 守卫）
  if (!pn) return;
  // 本次是收起：不请求
  if (!isRowExpanded(expandedRows, cand)) return;

  // 已有结果（含"查过是空的"）就不再请求；失败过则允许重试
  const cached = usageCache.value[pn];
  if (cached && !cached.error) return;

  usageCache.value = { ...usageCache.value, [pn]: { ...EMPTY_USAGE, loading: true } };
  try {
    const res = await listMaterialUsage(pn);
    usageCache.value = {
      ...usageCache.value,
      [pn]: {
        loading: false,
        error: '',
        products: res?.products || [],
        productCount: Number(res?.productCount) || 0,
        lineCount: Number(res?.lineCount) || 0,
        totalQty: Number(res?.totalQty) || 0,
        totalSolderedQty: Number(res?.totalSolderedQty) || 0,
      },
    };
  } catch (e) {
    // 失败留在面板里而不弹 ElMessage：错误信息应该出现在展开的那一行旁边，
    // 全局提示会飘走，用户不知道是哪条候选查失败了
    usageCache.value = {
      ...usageCache.value,
      [pn]: { ...EMPTY_USAGE, error: e.message || '未知错误' },
    };
  }
}

function onBind(cand) {
  bindingPn.value = cand.mfr_pn;
  // 把整条候选交出去，父组件需要 mfr_pn 回填、也需要名称等信息拼提示语
  emit('bind', cand);
}

/** 每次打开都清掉上次的展开态与缓存：库存和 BOM 可能已经变了 */
function resetPanel() {
  bindingPn.value = ''
  expandedKeys.value = []
  usageCache.value = {}
  // 电气参数报告也要清：BOM 行可能已经变了，上次的对比结果不再适用
  specPanel.value = null
  specLoadingPn.value = ''
  specLoading.value = false
  specError.value = ''
}

function onOpen() {
  resetPanel();
}

function onClosed() {
  resetPanel();
}

function cancel() {
  if (props.binding) return;
  emit('update:visible', false);
}
</script>

<style scoped>
/* 这个弹框比项目里其他弹框宽（其余是 620–720px 的表单弹框）：
   它装的是一张 8 列的候选表 + 可展开的用量明细，列宽合计约 900px，
   820px 时必然横向滚动 —— 挑候选要横着拖才能看到「操作」列，很难用。
   宽度写在 width 属性上（min(1180px, 94vw)，小屏退回视口宽度不溢出屏幕）；
   表格高度跟着视口算而不是写死 320px，大屏能一次多看几条候选。

   :deep 是必须的：.el-dialog__body 属于 el-dialog 自己的模板，
   scoped 样式默认加不到子组件内部的元素上。 */
/* 候选表的高度上限跟着视口走，而不是写死 320px —— 大屏能一次多看几条候选。
   减去的 240px 是标题 + 目标行 + 提示 + 底部按钮 + 内边距的大致占位。
   只限上限、不设固定高：候选通常只有 1-2 条，固定高会留一大片空白。

   两个坑都踩过：
   1. 不能用 el-table 的 max-height 属性 —— 它只接受数字或 px 串，
      给 calc() 会被静默丢弃（实测 computed max-height 变成 none，等于没上限）。
   2. `:deep(.match-table .el-…)` 也不行。scoped 会编译成
      `[data-v-xxx] .match-table .el-table__body-wrapper`，要求 scope 属性在
      **祖先**上；而 .match-table 本身就是那个带 scope 属性的元素，不是它的后代，
      选择器永远匹配不上。正确写法是 scope 类在前、:deep 只包住子组件内部那段。 */
.match-table :deep(.el-table__body-wrapper) {
  max-height: calc(88vh - 240px);
  overflow-y: auto;
}
.match-hint {
  margin: 10px 0;
}

.match-warn {
  margin-top: 10px;
  color: var(--c-warn);
}

/* 「当前已关联 X，不在上表中」——中性说明，不是警告，别染色 */
.match-current {
  margin-top: 10px;
}

/* 弹框主体限制高度，超出滚动——电气参数对比面板内容多时不能撑出窗体 */
:deep(.el-dialog) {
  display: flex;
  flex-direction: column;
  max-height: calc(88vh - 120px);
}
:deep(.el-dialog__body) {
  flex: 1;
  min-height: 0;
  overflow-y: auto;
}

.match-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  padding: 28px 0;
}

/* 空态是这个弹框最常见的状态（结构件行必然为空），所以文案要能读、
   行高放宽、宽度收住不要拉成一行长句 */
.match-empty-text {
  max-width: 440px;
  font-size: var(--fs-table);
  color: var(--c-text-3);
  line-height: 1.7;
  text-align: center;
}

.op-cell .muted {
  font-size: var(--fs-sm);
}

/* 库存偏低角标。用 warn 而非 danger：这是「可能解决不了问题」的提醒，
   不是错误 —— 绑定依然允许。与缺料同色系是刻意的，语义相近（都是量不够）。 */
.stock-low-flag {
  margin-left: 4px;
  padding: 0 3px;
  font-size: var(--fs-micro);
  line-height: 14px;
  border-radius: 2px;
  background: var(--c-warn-soft);
  color: var(--c-warn);
  border: 1px solid var(--c-warn-border);
  cursor: help;
}

/* --- 展开的明细面板：该料号被哪些产品用到 -------------------------------- */
/* 展开区要明显区别于表格行本身（下沉底色 + 内缩），否则会被读成又一行候选 */
.usage-panel {
  padding: 8px 12px 10px 44px;
  background: var(--c-sunken);
  font-size: var(--fs-sm);
}

/* loading / 空 / 错误 三种状态共用：都是一句话，不需要各写一套 */
.usage-state {
  color: var(--c-text-3);
  padding: 2px 0;
}

.usage-head {
  color: var(--c-text-2);
  padding-bottom: 6px;
  margin-bottom: 6px;
  border-bottom: 1px dashed var(--c-border);
}

.usage-product + .usage-product {
  margin-top: 8px;
  padding-top: 8px;
  border-top: 1px dashed var(--c-border);
}

.usage-product-head {
  display: flex;
  align-items: baseline;
  gap: 8px;
  margin-bottom: 3px;
}

/* 产品编号是这块面板的主语，给等宽字体 + 加重，方便和 BOM 页的产品下拉对上 */
.usage-code {
  font-family: var(--font-mono);
  font-weight: 600;
  color: var(--c-text);
}
.usage-pname {
  color: var(--c-text-3);
}
/* 该产品的合计推到右边，与逐行明细的列区分开 */
.usage-sum {
  margin-left: auto;
  color: var(--c-text-2);
  font-variant-numeric: tabular-nums;
}

/* 逐行明细用固定列宽而不是表格：只有 1-2 行，套一张 el-table 太重，
   而且嵌套表格在展开区里会带来双层边框和滚动条 */
.usage-line {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 2px 0 2px 10px;
  color: var(--c-text-2);
}
.usage-seq {
  min-width: 34px;
  font-family: var(--font-mono);
  color: var(--c-muted);
}
.usage-name {
  min-width: 90px;
}
.usage-desig {
  flex: 1;
  font-family: var(--font-mono);
  color: var(--c-text-3);
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
}
.usage-qty {
  min-width: 44px;
  text-align: right;
  font-variant-numeric: tabular-nums;
}
.usage-sold {
  min-width: 62px;
  text-align: right;
  font-variant-numeric: tabular-nums;
}
/* 已领 0 = 还没领过，中性信息，弱化（与 BOM 表的 soldered-zero 同口径） */
.usage-sold.is-zero {
  color: var(--c-muted);
}

/* 该 BOM 行的料号本身是绑来的。与 BOM 表头的「绑」角标同一套视觉语言。 */
.usage-bound {
  flex: 0 0 auto;
  min-width: 14px;
  padding: 0 3px;
  font-size: var(--fs-micro);
  line-height: 14px;
  text-align: center;
  border-radius: 2px;
  color: var(--c-accent);
  border: 1px solid var(--c-accent-border);
  cursor: help;
}

/* ===== 电气参数对比报告面板 ===== */
.spec-panel {
  margin-top: 12px;
  border: 1px solid var(--c-border);
  border-radius: 6px;
  padding: 10px 14px;
  background: var(--c-bg-soft, #f9fafb);
  font-size: 12px;
}
.spec-panel-head {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 10px;
}
.spec-panel-title {
  font-weight: 600;
  font-size: 12px;
}
.spec-close {
  margin-left: auto;
}

/* AI 分析中：居中旋转图标 + 提示文字 */
.spec-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  padding: 20px 0;
}
.spec-loading-icon {
  color: var(--c-accent);
}
.spin-icon {
  animation: spin 1s linear infinite;
}
@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}
.spec-loading-text {
  font-size: var(--fs-sm);
  color: var(--c-text-2);
}
.spec-loading-hint {
  font-size: var(--fs-xs);
  color: var(--c-muted);
}

/* 错误 */
.spec-error {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 0;
  color: var(--c-danger);
  font-size: var(--fs-sm);
}

/* 参数双栏对比 */
.spec-params-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  margin-bottom: 12px;
}
.spec-col {
  border: 1px solid var(--c-border);
  border-radius: 4px;
  padding: 8px 10px;
  background: var(--c-bg, #fff);
}
.spec-col-header {
  font-weight: 600;
  font-size: var(--fs-xs);
  color: var(--c-text-2);
  margin-bottom: 6px;
  padding-bottom: 4px;
  border-bottom: 1px solid var(--c-border-light, #eee);
}
.spec-param-row {
  display: flex;
  justify-content: space-between;
  padding: 2px 0;
  font-size: var(--fs-xs);
}
.spec-param-label {
  color: var(--c-text-3);
}
.spec-param-value {
  font-family: var(--font-mono);
  color: var(--c-text);
  text-align: right;
  max-width: 60%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  word-break: break-word;
}

/* 参考单价 */
.spec-price-row {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 10px;
  margin-bottom: 12px;
  background: var(--c-bg, #fff);
  border: 1px solid var(--c-border);
  border-radius: 4px;
  font-size: var(--fs-xs);
  flex-wrap: wrap;
}
.spec-price-label {
  font-weight: 600;
  color: var(--c-text-2);
  min-width: 56px;
}
.spec-price-bom,
.spec-price-cand {
  font-family: var(--font-mono);
  color: var(--c-text);
}
.spec-price-arrow {
  color: var(--c-muted);
}

/* 差异列表 */
.spec-diffs {
  margin-bottom: 10px;
}
.spec-diffs-title {
  font-weight: 600;
  font-size: var(--fs-xs);
  color: var(--c-text-2);
  margin-bottom: 4px;
}
.spec-diff-row {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 3px 0;
  font-size: var(--fs-xs);
  flex-wrap: wrap;
}
.spec-diff-param {
  min-width: 70px;
  color: var(--c-text-3);
}
.spec-diff-bom,
.spec-diff-cand {
  font-family: var(--font-mono);
}
.spec-diff-arrow {
  color: var(--c-muted);
}
.spec-diff-impact {
  margin-left: auto;
  word-break: break-word;
}

/* 综合建议 */
.spec-recommendation {
  background: var(--c-bg, #fff);
  border: 1px solid var(--c-border);
  border-radius: 4px;
  padding: 8px 10px;
  margin-bottom: 6px;
}
.spec-rec-title {
  font-weight: 600;
  font-size: var(--fs-xs);
  color: var(--c-text-2);
  margin-bottom: 4px;
}
.spec-rec-text {
  font-size: var(--fs-xs);
  line-height: 1.5;
  word-break: break-word;
}
.spec-notes {
  font-size: var(--fs-xs);
  color: var(--c-text-3);
  line-height: 1.5;
  word-break: break-word;
}

/* AI 返回了无法解析的内容 */
.spec-raw {
  font-size: var(--fs-xs);
}
.spec-raw-label {
  color: var(--c-text-3);
  margin-bottom: 4px;
}
.spec-raw-text {
  background: var(--c-bg, #fff);
  border: 1px solid var(--c-border);
  border-radius: 4px;
  padding: 8px;
  font-family: var(--font-mono);
  font-size: var(--fs-xs);
  white-space: pre-wrap;
  word-break: break-all;
  max-height: 300px;
  overflow-y: auto;
}
</style>
