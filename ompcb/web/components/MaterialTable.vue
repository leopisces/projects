<template>
  <el-table
    v-loading="loading"
    :data="rows"
    border
    stripe
    size="small"
    height="100%"
    :row-class-name="rowClassName"
    :cell-class-name="cellClassName"
    @sort-change="(payload) => emit('sort-change', payload)"
    empty-text="该产品下暂无 BOM 明细"
  >
    <template #empty>
      <div class="mat-empty">
        <EmptyBoard />
        <div class="mat-empty-text">该产品下暂无 BOM 明细</div>
      </div>
    </template>
    <!-- ===== BOM 自有字段 ===== -->
    <el-table-column
      prop="seq" label="序号" width="70" align="right" header-align="right"
      sortable="custom" class-name="col-num col-seq"
    />
    <el-table-column
      prop="name" label="名称" min-width="140" sortable="custom" class-name="col-truncate"
      show-overflow-tooltip
    >
      <template #default="{ row }">
        <span :title="row.name || ''">{{ row.name || '—' }}</span>
      </template>
    </el-table-column>
    <el-table-column
      prop="designator" label="位号" min-width="140"
      class-name="col-truncate" show-overflow-tooltip
    >
      <template #default="{ row }">
        <span :title="row.designator || ''">{{ row.designator || '—' }}</span>
      </template>
    </el-table-column>
    <el-table-column
      prop="package" label="封装" min-width="140"
      class-name="col-truncate" show-overflow-tooltip
    >
      <template #default="{ row }">
        <span :title="row.package || ''">{{ row.package || '—' }}</span>
      </template>
    </el-table-column>
    <el-table-column
      prop="mfr_pn" label="制造商料号" min-width="150"
      class-name="col-truncate col-pn"
    >
      <template #header>
        <span class="inv-header">
          制造商料号
          <el-tooltip :content="BOUND_HEADER_TIP" placement="top">
            <span class="inv-badge bind">绑</span>
          </el-tooltip>
        </span>
      </template>
      <template #default="{ row }">
        <span class="pn-cell" :title="cellTitle(row, 'mfr_pn')">
          {{ display(row, 'mfr_pn') }}
          <!-- 料号是关联库存的唯一依据，缺了就永远匹配不上 -->
          <el-tooltip v-if="!row.mfr_pn" content="没有制造商料号，无法关联库存" placement="top">
            <span class="pn-warn">无料号</span>
          </el-tooltip>
        </span>
      </template>
    </el-table-column>
    <el-table-column
      prop="mfr" label="制造商" min-width="130"
      class-name="col-truncate"
    >
      <template #header>
        <span class="inv-header">
          制造商
          <el-tooltip :content="BOUND_HEADER_TIP" placement="top">
            <span class="inv-badge bind">绑</span>
          </el-tooltip>
        </span>
      </template>
      <template #default="{ row }">
        <span :title="cellTitle(row, 'mfr')">{{ display(row, 'mfr') }}</span>
      </template>
    </el-table-column>
    <el-table-column
      prop="supplier" label="供应商" width="80"
      class-name="col-truncate"
    >
      <template #header>
        <span class="inv-header">
          供应商
          <el-tooltip :content="BOUND_HEADER_TIP" placement="top">
            <span class="inv-badge bind">绑</span>
          </el-tooltip>
        </span>
      </template>
      <template #default="{ row }">
        <span :title="cellTitle(row, 'supplier')">{{ display(row, 'supplier') }}</span>
      </template>
    </el-table-column>
    <el-table-column
      prop="supplier_pn" label="供应商料号" min-width="95"
      class-name="col-truncate col-pn"
    >
      <template #header>
        <span class="inv-header">
          供应商料号
          <el-tooltip :content="BOUND_HEADER_TIP" placement="top">
            <span class="inv-badge bind">绑</span>
          </el-tooltip>
        </span>
      </template>
      <template #default="{ row }">
        <span :title="cellTitle(row, 'supplier_pn')">{{ display(row, 'supplier_pn') }}</span>
      </template>
    </el-table-column>

    <!-- ===== 用量 vs 库存 对比区：数量紧挨库存，方便一眼看出够不够 ===== -->
    <el-table-column
      prop="qty" label="数量" width="104" align="right" header-align="right"
      sortable="custom" class-name="col-num col-compare"
    >
      <template #header>
        <span class="inv-header">
          数量
          <el-tooltip content="单板用量（BOM 自有）" placement="top">
            <span class="inv-badge bom">需</span>
          </el-tooltip>
        </span>
      </template>
    </el-table-column>
    <!-- 已焊接紧挨数量：一眼对比「单板要几个」与「已经领用焊掉几个」。
         仅展示绝对件数，不算比率——套数是计划输入而非承诺目标，
         领了 2 套后把套数改成 5，比率会从 100% 掉到 40%，而现实中什么都没发生。
         0 在硬件领料语境里是「还没领过」，中性信息，不该像缺料那样报警。 -->
    <el-table-column
      prop="solderedQty" label="已焊接" width="124" align="right" header-align="right"
      sortable="custom" class-name="col-num col-compare"
    >
      <template #header>
        <span class="inv-header">
          已焊接
          <!-- 算：值由 inventory_log 按 material_id 聚合得出（出库即视为已焊接）。
               不是 BOM 自有（需）也不是库存台账直接带出（库）—— 是衍生计算列。 -->
          <el-tooltip content="按 BOM 行累计已出库件数（出库即视为已焊接）" placement="top">
            <span class="inv-badge calc">算</span>
          </el-tooltip>
        </span>
      </template>
      <template #default="{ row }">
        <span :class="{ 'soldered-zero': Number(row.solderedQty) === 0 }">
          {{ row.solderedQty ?? 0 }}
        </span>
      </template>
    </el-table-column>
    <!-- 只做 1 套时需求量等于数量，没必要多占一列 -->
    <el-table-column
      v-if="sets > 1"
      prop="required" label="需求" width="110" align="right" header-align="right"
      sortable="custom" class-name="col-num col-compare"
    >
      <template #header>
        <span class="inv-header">
          需求
          <el-tooltip :content="`做 ${sets} 套的总需求 = 数量 × ${sets}`" placement="top">
            <span class="inv-badge calc">×{{ sets }}</span>
          </el-tooltip>
        </span>
      </template>
      <template #default="{ row }">
        <span class="required-value">{{ row.required ?? row.qty }}</span>
      </template>
    </el-table-column>
    <el-table-column
      prop="stock" label="库存" width="80" align="right" header-align="right"
      sortable="custom" class-name="col-num col-compare col-from-inventory"
    >
      <template #default="{ row }">
        <span v-if="row.inventory_id" :class="{ 'stock-low': isShort(row) }">{{ row.stock }}</span>
        <!-- 库里没有这个料，可用库存就是 0，不该显示成"—"让人以为未知 -->
        <el-tooltip v-else content="库存台账里没有这个料号，可用库存按 0 计算" placement="top">
          <span class="stock-none">0</span>
        </el-tooltip>
      </template>
    </el-table-column>
    <el-table-column
      prop="shortage" label="缺料" width="108" align="right" header-align="right"
      sortable="custom" class-name="col-num col-compare"
    >
      <template #header>
        <span class="inv-header">
          缺料
          <el-tooltip :content="`需要采购的数量 = 数量 × ${sets} − 库存`" placement="top">
            <span class="inv-badge calc">算</span>
          </el-tooltip>
        </span>
      </template>
      <template #default="{ row }">
        <span v-if="Number(row.shortage) > 0" class="shortage-value is-short">-{{ row.shortage }}</span>
        <span v-else class="shortage-ok is-ok">足</span>
      </template>
    </el-table-column>

    <!-- ===== 其余库存动态关联字段 ===== -->
    <el-table-column
      prop="status" label="状态" width="112" align="center" sortable="custom"
      class-name="col-from-inventory"
    >
      <template #header>
        <span class="inv-header">
          状态
          <el-tooltip content="来自库存台账：库存 > 0 正常，否则缺货。点击单元格可查看同规格库存并绑定" placement="top">
            <span class="inv-badge">库</span>
          </el-tooltip>
        </span>
      </template>
      <template #default="{ row }">
        <!-- 状态文本可点：打开弹框看台账里同名同封装的记录及其库存，可回填料号建立关联。
             已匹配行也允许点——同规格常有多个料号（如 100nF/C0402 两种），
             缺料时看有没有替代品是真实需求。 -->
        <span class="cell-link" @click="emit('inspect-stock', row)">
          <el-tag v-if="row.inventory_id" :type="statusTagType(row.status)" size="small" class="status-tag" effect="light">
            {{ row.status || '—' }}
          </el-tag>
          <span v-else class="unmatched-text">未匹配</span>
          <!-- 有同规格可选时给个角标，否则这功能藏在单元格里没人知道能点。
               只在「有别的料号可换」时才显示：已关联的那条不算可选项，
               数字必须和弹框里实际列出的条数一致，否则比不提示更让人困惑。 -->
          <span v-if="selectableSpecCount(row) > 0" class="spec-badge">
            {{ selectableSpecCount(row) }}
          </span>
        </span>
      </template>
    </el-table-column>
    <el-table-column
      prop="location" label="位置" min-width="80" sortable="custom"
      class-name="col-truncate col-from-inventory" show-overflow-tooltip
    >
      <template #header>
        <span class="inv-header">
          位置
          <el-tooltip content="来自库存台账（按制造商料号匹配）" placement="top">
            <span class="inv-badge">库</span>
          </el-tooltip>
        </span>
      </template>
      <template #default="{ row }">
        <span v-if="row.inventory_id" :title="row.location || ''">{{ row.location || '—' }}</span>
        <span v-else class="unmatched-text">—</span>
      </template>
    </el-table-column>

    <el-table-column
      prop="remark" label="备注" min-width="80"
      class-name="col-truncate" show-overflow-tooltip
    >
      <template #default="{ row }">
        <span :title="row.remark || ''">{{ row.remark || '—' }}</span>
      </template>
    </el-table-column>
    <el-table-column label="操作" width="165" fixed="right" align="center">
      <template #default="{ row }">
        <div class="op-cell">
          <!-- 出库：数量按位号个数默认填好（见 MaterialIssueDialog）。
               未关联台账的行出不了库——出库要扣的是台账里那条记录的库存，
               没关联就没有扣减对象。tooltip 套在 span 上：el-button
               disabled 时自身不触发悬浮事件。 -->
          <el-tooltip :content="issueTip(row)" placement="top">
            <span>
              <el-button
                link
                type="warning"
                size="small"
                :disabled="!canIssue(row)"
                @click="emit('issue', row)"
              >
                出库
              </el-button>
            </span>
          </el-tooltip>
          <!-- 流水：该行的领料记录，可撤销。已焊接为 0 时没有任何流水可看，
               但仍允许点开——用户需要确认"确实一次都没领过"，
               弹框里的空态比禁用按钮更能回答这个问题。 -->
          <el-button link type="info" size="small" @click="emit('logs', row)">流水</el-button>
          <el-button link type="primary" size="small" @click="emit('edit', row)">编辑</el-button>
          <el-button link type="danger" size="small" @click="emit('delete', row)">删除</el-button>
        </div>
      </template>
    </el-table-column>
  </el-table>
</template>

<script setup>
import EmptyBoard from './EmptyBoard.vue';
import { BOUND_FIELDS, isBound, boundValue, sourceValue } from '../bom-display.js';
import { countDesignators } from '../designator.js';

defineProps({
  rows: { type: Array, required: true },
  loading: { type: Boolean, default: false },
  sets: { type: Number, default: 1 },   // 制作套数，影响需求列与缺料口径
});

const emit = defineEmits(['sort-change', 'edit', 'delete', 'inspect-stock', 'issue', 'logs']);

// ---------------------------------------------------------------------------
// 绑定后的四列显示：库存值优先，hover 看原导入值。
// 口径本身与理由都在 web/bom-display.js（CSV 导出共用同一套，不能各自实现）。
// 这里只负责把口径翻译成"表格里长什么样"。
// ---------------------------------------------------------------------------

const BOUND_HEADER_TIP =
  '手动绑定过库存的行，这一列显示所绑定库存记录的值；鼠标悬停可看导入时的原值';

/** 单元格文本。空值统一显示 '—'，与其他列一致 */
function display(row, key) {
  return boundValue(row, key) || '—';
}

/**
 * 单元格 hover 文本。
 *
 * 未绑定行保持原行为（只回显自身值，给被截断的长文本用）。
 * 绑定行则说明"现在显示的是库存值、原来导入的是什么"，因为原值除此之外
 * 界面上无处可见 —— 它只存在 src_* 快照里。
 * 原值为空显示"（无原始记录）"：可能本来就空，也可能是加快照列之前
 * 就绑定过的老数据（原值已永久丢失），两者都不做猜测。
 */
function cellTitle(row, key) {
  if (!isBound(row)) return boundValue(row, key);
  const origin = sourceValue(row, key) || '（无原始记录）';
  return `当前（库存）：${display(row, key)}\n导入原值：${origin}`;
}

/**
 * 给绑定行的这四列挂样式：
 *   col-from-inventory —— 左侧细线，与状态/库存/位置列同一套「来自库存」语言
 *   col-bound          —— 紫色字，一眼看出这格显示的不是 BOM 原始导入值
 * 用 cell-class-name 而不是列的 class-name：同一列里绑定与未绑定的行混在一起，
 * 出处逐行而异，整列标记会把未绑定的行也说成来自库存。
 */
function cellClassName({ row, column }) {
  const key = column?.property;
  if (!key || !BOUND_FIELDS[key]) return '';
  return isBound(row) ? 'col-from-inventory col-bound' : '';
}

// 状态只有两种：正常（绿=安全）/ 缺货（红=要处理）
function statusTagType(status) {
  return status === '缺货' ? 'danger' : 'success';
}

function isShort(row) {
  return Number(row?.shortage) > 0;
}

// ---------------------------------------------------------------------------
// 行级出库可用性
//
// 出库扣的是「台账里那条记录」的库存，所以两个硬前提：
//   1. 关联到了台账（inventory_id）—— 否则没有扣减对象
//   2. 台账库存 > 0 —— 否则必然被后端以「库存不足」400 退回
// 两者都不满足时禁用而非隐藏：按钮消失会让人以为功能不存在，
// 禁用 + tooltip 才能说清「为什么这行不能出库、该怎么办」。
//
// 位号为空不禁用：那只是数量填不出来（对话框里会提示手动确认），
// 不代表这行不能领料——结构件常不写位号但照样要出库。
// ---------------------------------------------------------------------------

function canIssue(row) {
  return !!row?.inventory_id && Number(row?.stock) > 0;
}

/** 出库按钮的悬停提示：可用时说明数量口径，不可用时说明原因与出路 */
function issueTip(row) {
  if (!row?.inventory_id) {
    return '该行未关联库存台账，无法出库；请先点状态列绑定料号，或用工具栏「未匹配建档」';
  }
  if (Number(row?.stock) <= 0) {
    return '台账库存为 0，无可出库数量；请先入库或盘点录入实际数量';
  }
  const n = countDesignators(row?.designator);
  if (n <= 0) {
    return '该行没有填位号，出库数量需手动确认';
  }
  return `按位号个数出库（${n} 个），可在弹框中调整`;
}

/**
 * 可选的同规格库存条数 —— 即弹框里实际会列出的行数。
 *
 * sameSpecCount 是台账里同名同封装且料号非空的总条数，其中包含本行当前
 * 已关联的那条（它在弹框里被排除，因为绑了也不会变）。所以要减掉
 * sameSpecCurrentCount，让角标数字与弹框列表条数严格一致；
 * 不一致的提示比没有提示更糟。
 *
 * 两个数都由后端用同一套口径算出（含 Ω 归一、封装为空只比名称），
 * 前端不做任何推断。
 */
function selectableSpecCount(row) {
  const total = Number(row?.sameSpecCount) || 0;
  const current = Number(row?.sameSpecCurrentCount) || 0;
  return Math.max(0, total - current);
}

/** 状态列的悬停提示：明确告诉用户点了会发生什么 */
function matchTip(row) {
  const n = selectableSpecCount(row);
  if (n > 0) {
    return `台账里有 ${n} 条同名同封装的其他料号可选，点击查看并绑定`;
  }
  return '点击查看同名同封装的库存记录';
}

// 缺料行淡黄提示；未匹配到库存的行淡灰，两者视觉上要能区分
function rowClassName({ row }) {
  if (isShort(row)) return 'row-shortage';
  if (!row?.inventory_id) return 'row-unmatched';
  return '';
}
</script>

<style scoped>
/* 表头标记：区分"这列是 BOM 自己的"还是"来自库存台账/算出来的"
   库=accent 来自库存、算=warn 推导结果、需=sunken BOM 自己的字段；都是「出处」标记。
   绑=另立一枚：这四列本身是 BOM 自有字段，只有「手动绑定过」的那些行才显示库存值，
   出处逐行而异。若沿用「库」会与「整列都来自库存」的既有含义冲突。 */
.inv-header {
  display: inline-flex;
  align-items: center;
  gap: 4px;
}
.inv-badge {
  display: inline-block;
  min-width: 14px;
  padding: 0 3px;
  font-size: var(--fs-micro);
  line-height: 14px;
  text-align: center;
  border-radius: 2px;
  background: var(--c-accent-soft);
  color: var(--c-accent);
  border: 1px solid var(--c-accent-border);
  font-weight: 600;
  cursor: help;
}
.inv-badge.bom {
  background: var(--c-sunken-2);
  color: var(--c-text-2);
  border-color: var(--c-border-2);
}
.inv-badge.calc {
  background: var(--c-warn-soft);
  color: var(--c-warn);
  border-color: var(--c-warn-border);
}
/* 绑：紫色，与单元格里的绑定值同色 —— 表头说明「这列可能显示绑定值」，
   单元格的紫字指出「就是这一格」。同色才能让人把两者连起来。
   不用「库」的蓝：那是「整列都来自库存」的既有含义，这四列是逐行而异。 */
.inv-badge.bind {
  background: var(--c-bind-soft);
  color: var(--c-bind);
  border-color: var(--c-bind-border);
}

.unmatched-text {
  color: var(--c-muted);
  font-size: var(--fs-sm);
}

.stock-low {
  color: var(--c-warn);
  font-weight: 600;
}
/* 库里没这个料：显示 0 但用弱化色，区别于"真的有 0 件库存" */
.stock-none {
  color: var(--c-muted);
  cursor: help;
}

.required-value {
  font-weight: 600;
  color: var(--c-text);
}

/* 缺料/满足的色用全局 .is-short / .is-ok 提供，这里只保留字重和尺寸
   —— 颜色走 token，行内 class 同时挂本地与全局两枚以保留可读性 */
.shortage-value {
  font-weight: 600;
}
.shortage-ok {
  font-size: var(--fs-sm);
}

/* 已焊接 0：跟 stock-none 同样当作「中性信息」弱化。
   不报警——只是这一行还没被任何出库领过，不代表有问题。 */
.soldered-zero {
  color: var(--c-muted);
}

.pn-cell {
  display: inline-flex;
  align-items: center;
  gap: 6px;
}
.pn-warn {
  flex: 0 0 auto;
  font-size: var(--fs-micro);
  padding: 0 4px;
  line-height: 15px;
  border-radius: 2px;
  background: var(--c-sunken-2);
  color: var(--c-text-3);
  border: 1px solid var(--c-border-2);
  cursor: help;
}

.mat-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  padding: 28px 0;
}
.mat-empty-text {
  font-size: var(--fs-table);
  color: var(--c-text-3);
}

/* 可点击的单元格文本。项目里原本没有这类样式（操作列一律用 el-button link，
   带 tooltip 的静态文本用 cursor: help），所以这里新建一个。
   刻意不给下划线或强调色：状态列里的 tag 本身已有颜色语义，
   再叠一层强调会打乱表格的视觉层级。只在 hover 时用背景色给出可点提示。 */
.cell-link {
  display: inline-flex;
  align-items: center;
  cursor: pointer;
  padding: 1px 5px;
  margin: -1px -5px;
  border-radius: 3px;
  transition: background-color 0.12s ease;
}
.cell-link:hover {
  background: var(--c-accent-soft);
}
.cell-link:hover .unmatched-text {
  color: var(--c-accent);
}

/* 同规格可选料号的角标。用 accent 而非 warn：这是「有更多选择」的机会提示，
   不是「有问题要处理」的告警——缺料告警已经由缺料列和行底色负责了。
   数字紧跟在状态后面，让「状态 + 还有几个替代」一眼读完。 */
.spec-badge {
  margin-left: 4px;
  min-width: 15px;
  height: 15px;
  padding: 0 3px;
  border-radius: 8px;
  background: var(--c-accent);
  color: #fff;
  font-family: var(--font-mono);
  font-size: var(--fs-micro);
  line-height: 15px;
  text-align: center;
}

/* 操作列按钮紧凑排列：默认 el-button 间距太大，4 个按钮塞不进 165px。
   用负 margin 把按钮间的空白吃掉，视觉上仍保持可点击区域。 */
.op-cell {
  display: inline-flex;
  gap: 0;
}
.op-cell .el-button {
  margin-left: 0;
  padding: 0 4px;
}
.op-cell .el-button + .el-button {
  margin-left: 2px;
}
</style>
