<template>
  <el-drawer
    :model-value="visible"
    :title="`${productCode || '全部'} · 出入库记录`"
    direction="rtl"
    size="1000px"
    @update:model-value="(v) => emit('update:visible', v)"
    @open="onOpen"
  >
    <div class="logs-body">
      <!-- 工具栏拆成两行：
           第一行放"筛选用"的控件（搜索 / 类型 / 日期 / 快捷范围），
           第二行放"看哪一段 + 接下来做什么"（范围 + 撤销/导出/刷新）。
           原来是一条长龙，1000px 抽屉里 8 个控件会糊在一起；
           分行后每一组都是一个有节奏的段落。 -->
      <div class="logs-toolbar">
        <div class="logs-cluster">
          <el-input
            v-model="query.q"
            placeholder="搜索，空格可组合"
            title="可搜元件名 / 封装 / 料号 / 事由；用空格分隔多个条件，需同时满足"
            clearable
            size="small"
            style="width: 210px"
            @input="onSearchInput"
            @clear="reload(1)"
            @keyup.enter="reload(1)"
          />
          <el-select
            v-model="query.type"
            placeholder="全部类型"
            clearable
            size="small"
            style="width: 112px"
            @change="reload(1)"
          >
            <el-option v-for="t in TYPE_OPTIONS" :key="t" :label="t" :value="t" />
          </el-select>
          <el-date-picker
            v-model="dateRange"
            type="daterange"
            size="small"
            unlink-panels
            range-separator="至"
            start-placeholder="开始"
            end-placeholder="结束"
            value-format="YYYY-MM-DD"
            style="width: 218px"
            @change="onDateChange"
          />
          <el-button-group>
            <el-button size="small" @click="setQuickRange(0)">今天</el-button>
            <el-button size="small" @click="setQuickRange(7)">7 天</el-button>
            <el-button size="small" @click="setQuickRange(30)">30 天</el-button>
          </el-button-group>
        </div>
      </div>

      <div class="logs-meta-row">
        <div class="logs-scope">
          <el-radio-group v-model="scope" size="small" @change="onScopeChange">
            <el-radio-button label="product">只看「{{ productCode }}」领料</el-radio-button>
            <el-radio-button label="all">全部出入库</el-radio-button>
          </el-radio-group>
          <span v-if="scope === 'product'" class="ui-hint">
            仅含批量出库产生的记录；手工单件出入库不归属产品
          </span>
        </div>
        <span class="toolbar-spacer" />
        <div class="logs-cluster">
          <el-button
            v-if="productId && total > 0"
            type="danger"
            size="small"
            :loading="deletingAll"
            @click="confirmDeleteAll"
          >全部删除</el-button>
          <el-button
            type="warning"
            size="small"
            :disabled="!selectedRevocable.length"
            :loading="bulkRevoking"
            @click="confirmBulkRevoke"
          >撤销所选{{ selectedRevocable.length ? `（${selectedRevocable.length}）` : '' }}</el-button>
          <el-button size="small" :loading="exporting" @click="exportCsv">导出</el-button>
          <el-button size="small" :loading="loading" @click="reload()">刷新</el-button>
        </div>
      </div>

      <!-- 汇总：沿用全局 .ui-sumstrip / .ui-sumcell，跟页面级 .stats-strip 同语言。
           in/out 用 .delta-in / .delta-out（自带 mono + 颜色），其余计数保持 sans。 -->
      <div class="ui-sumstrip logs-summary" v-loading="loading">
        <div class="ui-sumcell">
          <span class="ui-sumlabel">记录数</span>
          <span class="ui-sumvalue">{{ total }}</span>
        </div>
        <div class="ui-sumcell">
          <span class="ui-sumlabel">入库总量</span>
          <span class="ui-sumvalue delta-in">{{ summary.inQty ?? '—' }}</span>
        </div>
        <div class="ui-sumcell">
          <span class="ui-sumlabel">出库总量</span>
          <span class="ui-sumvalue delta-out">{{ summary.outQty ?? '—' }}</span>
        </div>
        <div class="ui-sumcell">
          <span class="ui-sumlabel">涉及元件</span>
          <span class="ui-sumvalue">{{ summary.itemKinds ?? '—' }}</span>
        </div>
        <div class="ui-sumcell logs-sumtypes">
          <span class="ui-sumlabel">类型</span>
          <span class="type-chips">
            <el-tag
              v-for="t in summary.typeCounts || []"
              :key="t.type"
              :type="typeTagType(t.type)"
              size="small"
              effect="light"
            >{{ t.type }} {{ t.count }}</el-tag>
            <span v-if="!(summary.typeCounts || []).length" class="ui-sumvalue">—</span>
          </span>
        </div>
      </div>

      <!-- 表格 -->
      <div class="logs-table">
        <el-table
          ref="tableRef"
          v-loading="loading"
          :data="rows"
          border
          stripe
          size="small"
          height="100%"
          row-key="id"
          empty-text="没有符合条件的出入库记录"
          @selection-change="onSelectionChange"
        >
          <!-- 表头全选只覆盖当前页；不可撤销的行由 selectable 置灰 -->
          <el-table-column type="selection" width="40" :selectable="canRevoke" />
          <el-table-column prop="created_at" label="时间" width="148" class-name="col-num" />
          <el-table-column prop="type" label="类型" width="76" align="center">
            <template #default="{ row }">
              <el-tag :type="typeTagType(row.type)" size="small" effect="light">{{ row.type }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="状态" width="72" align="center">
            <template #default="{ row }">
              <el-tag v-if="row.revoked_by_log_id" type="info" size="small" effect="plain">已撤销</el-tag>
              <el-tag v-else-if="row.revokes_log_id" type="success" size="small" effect="plain">撤销单</el-tag>
              <span v-else class="muted">—</span>
            </template>
          </el-table-column>
          <el-table-column v-if="scope === 'all'" prop="product_code" label="产品" width="120" show-overflow-tooltip>
            <template #default="{ row }">
              <span v-if="row.product_code">{{ row.product_code }}</span>
              <span v-else class="muted">手工</span>
            </template>
          </el-table-column>
          <el-table-column prop="name" label="元件" min-width="130" show-overflow-tooltip>
            <template #default="{ row }">
              <span :title="row.name || ''">{{ row.name || '（元件已删除）' }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="mfr_pn" label="制造商料号" min-width="150" show-overflow-tooltip>
            <template #default="{ row }">{{ row.mfr_pn || '—' }}</template>
          </el-table-column>
          <el-table-column prop="delta" label="变动" width="82" align="right" header-align="right" class-name="col-num">
            <template #default="{ row }">
              <span :class="deltaClass(row.delta)">{{ row.delta > 0 ? '+' + row.delta : row.delta }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="stock_after" label="变动后" width="78" align="right" header-align="right" class-name="col-num" />
          <el-table-column prop="location" label="位置" min-width="90" show-overflow-tooltip>
            <template #default="{ row }">{{ row.location || '—' }}</template>
          </el-table-column>
          <el-table-column prop="remark" label="事由" min-width="130" show-overflow-tooltip>
            <template #default="{ row }">
              <span :title="row.remark || ''">{{ row.remark || '—' }}</span>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="72" align="center" fixed="right">
            <template #default="{ row }">
              <!-- 只有未撤销的出库才能撤销：入库/盘点/初始没有"原值"可回退 -->
              <el-button
                v-if="canRevoke(row)"
                link
                type="primary"
                size="small"
                :loading="revokingId === row.id"
                @click="confirmRevoke(row)"
              >撤销</el-button>
              <span v-else class="muted">—</span>
            </template>
          </el-table-column>
        </el-table>
      </div>

      <!-- 分页 -->
      <div class="logs-footer">
        <el-pagination
          v-model:current-page="query.page"
          v-model:page-size="query.pageSize"
          :total="total"
          :page-sizes="[20, 50, 100]"
          size="small"
          background
          layout="total, sizes, prev, pager, next"
          @current-change="fetchList"
          @size-change="reload(1)"
        />
      </div>
    </div>
  </el-drawer>
</template>

<script setup>
import { computed, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { listInventoryLogs, revokeStockOut, revokeStockOutBulk, deleteLogsByProduct } from '../api.js'

const props = defineProps({
  visible: { type: Boolean, default: false },
  productId: { type: [Number, String, null], default: null },
  productCode: { type: String, default: '' },
})

const emit = defineEmits(['update:visible', 'revoked'])

const TYPE_OPTIONS = ['入库', '出库', '盘点', '初始']

const CSV_COLS = [
  ['created_at', '时间'], ['type', '类型'], ['product_code', '产品'],
  ['name', '元件'], ['package', '封装'], ['mfr_pn', '制造商料号'],
  ['supplier_pn', '供应商料号'], ['delta', '变动'],
  ['stock_after', '变动后库存'], ['location', '位置'], ['remark', '事由'],
  ['revoke_state', '撤销状态']
]

// product: 只看该产品的领料；all: 全部出入库
const scope = ref('product')

const query = reactive({
  q: '',
  type: '',
  from: '',
  to: '',
  page: 1,
  pageSize: 50
})

const dateRange = ref(null)
const rows = ref([])
const total = ref(0)
const summary = ref({})
const loading = ref(false)
const exporting = ref(false)
const revokingId = ref(null)
const tableRef = ref(null)
const selected = ref([])
const bulkRevoking = ref(false)
const deletingAll = ref(false)

// 勾选里真正可撤的行。selectable 已经挡住了不可撤的，这里再过一遍：
// 翻页/刷新后 selection 可能残留旧行，宁可多筛一次。
const selectedRevocable = computed(() => selected.value.filter(canRevoke))

function buildParams(extra = {}) {
  const p = { ...query, ...extra }
  if (scope.value === 'product' && props.productId) p.productId = props.productId
  return p
}

async function fetchList() {
  loading.value = true
  try {
    const data = await listInventoryLogs(buildParams())
    rows.value = data.list || []
    total.value = data.total || 0
    summary.value = {
      inQty: data.inQty,
      outQty: data.outQty,
      itemKinds: data.itemKinds,
      typeCounts: data.typeCounts
    }
    // 数据换了一批，旧勾选没有意义（也可能已被别人撤销）
    clearSelection()
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    loading.value = false
  }
}

function onSelectionChange(val) {
  selected.value = val || []
}

function clearSelection() {
  selected.value = []
  tableRef.value?.clearSelection?.()
}

function reload(page) {
  if (page) query.page = page
  return fetchList()
}

function onOpen() {
  // 每次打开重置筛选，默认看当前产品的全部领料记录
  scope.value = props.productId ? 'product' : 'all'
  query.q = ''
  query.type = ''
  query.from = ''
  query.to = ''
  query.page = 1
  dateRange.value = null
  fetchList()
}

function onScopeChange() {
  reload(1)
}

let searchTimer = null
function onSearchInput() {
  clearTimeout(searchTimer)
  searchTimer = setTimeout(() => reload(1), 300)
}

function onDateChange(val) {
  query.from = val?.[0] ?? ''
  query.to = val?.[1] ?? ''
  reload(1)
}

/** days=0 只看今天 */
function setQuickRange(days) {
  const fmt = (d) =>
    `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
  const end = new Date()
  const start = new Date()
  if (days > 0) start.setDate(start.getDate() - (days - 1))
  const range = [fmt(start), fmt(end)]
  dateRange.value = range
  query.from = range[0]
  query.to = range[1]
  reload(1)
}

function typeTagType(type) {
  switch (type) {
    case '入库': return 'success'
    case '出库': return 'warning'
    case '盘点': return 'primary'
    case '初始': return 'info'
    default:     return 'info'
  }
}

function deltaClass(delta) {
  if (delta > 0) return 'delta-in'
  if (delta < 0) return 'delta-out'
  return 'delta-flat'
}

// --- 撤销出库 --------------------------------------------------------------
// 撤销不是删除：服务端会追加一条反向入库，原出库记录留在流水里。
// 所以撤销单本身（revokes_log_id 非空）和已撤销过的行都不再提供按钮。

function canRevoke(row) {
  return row.type === '出库' && !row.revoked_by_log_id && !row.revokes_log_id
}

function revokeState(row) {
  if (row.revoked_by_log_id) return '已撤销'
  if (row.revokes_log_id) return '撤销单'
  return ''
}

async function confirmRevoke(row) {
  const qty = Math.abs(row.delta)
  const who = row.name || row.mfr_pn || row.supplier_pn || '该元件'
  let remark = ''
  try {
    const res = await ElMessageBox.prompt(
      `将为「${who}」补回 ${qty} 件（当前记录出库 ${qty}）。原出库记录会保留，另生成一条入库流水。`,
      '撤销出库',
      {
        confirmButtonText: '确认撤销',
        cancelButtonText: '取消',
        inputPlaceholder: '撤销原因（可留空）',
        inputValue: '',
        inputValidator: () => true,
        type: 'warning'
      }
    )
    remark = String(res.value ?? '').trim()
  } catch {
    return
  }

  revokingId.value = row.id
  try {
    const res = await revokeStockOut(row.id, { remark })
    ElMessage.success(`已撤销：补回 ${res.delta} 件，当前库存 ${res.stockAfter}`)
    await fetchList()
    // 库存已变，通知外层刷新 BOM 的缺料计算与库存页
    emit('revoked', res)
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    revokingId.value = null
  }
}

/**
 * 批量撤销：只处理当前页勾选的行。
 * 后端是单事务但会逐行跳过不合格的（比如别人刚撤过），所以要如实汇报 skipped。
 */
async function confirmBulkRevoke() {
  const targets = selectedRevocable.value
  if (!targets.length) return

  const totalQty = targets.reduce((a, r) => a + Math.abs(r.delta), 0)
  const kinds = new Set(targets.map(r => r.inventory_id)).size

  let remark = ''
  try {
    const res = await ElMessageBox.prompt(
      `将撤销 ${targets.length} 条出库，涉及 ${kinds} 种元件，共补回 ${totalQty} 件。` +
        `原出库记录全部保留，另生成 ${targets.length} 条入库流水。`,
      '批量撤销出库',
      {
        confirmButtonText: `确认撤销 ${targets.length} 条`,
        cancelButtonText: '取消',
        inputPlaceholder: '撤销原因（可留空，将写入每条流水）',
        inputValue: '',
        inputValidator: () => true,
        type: 'warning'
      }
    )
    remark = String(res.value ?? '').trim()
  } catch {
    return
  }

  bulkRevoking.value = true
  try {
    const res = await revokeStockOutBulk(targets.map(r => r.id), { remark })
    if (res.skipped > 0) {
      ElMessage.warning(
        `已撤销 ${res.revoked} 条（补回 ${res.totalQty} 件），跳过 ${res.skipped} 条`
      )
      console.warn('[ompcb] 批量撤销跳过明细:', res.errors)
    } else {
      ElMessage.success(`已撤销 ${res.revoked} 条，补回 ${res.totalQty} 件`)
    }
    await fetchList()
    emit('revoked', res)
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    bulkRevoking.value = false
  }
}

// --- 全部删除 --------------------------------------------------------------
// 仅在 product 模式下可删（all 模式删的是全局流水，破坏性过大且语义模糊）

async function confirmDeleteAll() {
  if (!props.productId) return

  try {
    await ElMessageBox.confirm(
      `将删除「${props.productCode || '该产品'}」的全部 ${total.value} 条出入库记录。\n\n` +
        '此操作不可恢复，删除后流水记录将无法查看。库存数量不受影响。',
      '全部删除出入库记录',
      {
        confirmButtonText: '确认删除',
        cancelButtonText: '取消',
        type: 'danger',
      }
    )
  } catch {
    return
  }

  deletingAll.value = true
  try {
    const res = await deleteLogsByProduct(props.productId)
    ElMessage.success(res.message || `已删除 ${res.deleted} 条出入库记录`)
    await fetchList()
    emit('revoked', res)
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    deletingAll.value = false
  }
}

function csvCell(v) {
  const s = v === null || v === undefined ? '' : String(v)
  return /[",\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s
}

async function exportCsv() {
  exporting.value = true
  try {
    // 导当前筛选下的全部结果，不只当前页
    const data = await listInventoryLogs(buildParams({ page: 1, pageSize: 500 }))
    const list = data.list || []
    if (!list.length) {
      ElMessage.warning('当前筛选结果为空')
      return
    }
    const lines = [CSV_COLS.map(([, l]) => csvCell(l)).join(',')]
    for (const row of list) {
      lines.push(
        CSV_COLS.map(([k]) => csvCell(k === 'revoke_state' ? revokeState(row) : row[k])).join(',')
      )
    }
    const blob = new Blob(['\uFEFF' + lines.join('\r\n')], { type: 'text/csv;charset=utf-8;' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    const ts = new Date().toISOString().slice(0, 10)
    const who = scope.value === 'product' ? props.productCode : '全部'
    a.href = url
    a.download = `ompcb-出入库记录-${who}-${ts}.csv`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
    ElMessage.success(`已导出 ${list.length} 条`)
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    exporting.value = false
  }
}
</script>

<style scoped>
/* 抽屉内部竖向布局，只有表格滚动 */
.logs-body {
  display: flex;
  flex-direction: column;
  height: 100%;
  min-height: 0;
}

/* 工具栏：拆成"筛选" + "范围/操作"两行，每行再用 .logs-cluster 把同组控件归到一起。
   原来是一条长龙，1000px 抽屉里 8 个控件会糊在一起；分行后每一组都是
   一个有节奏的段落，缩窗时也不会突然挤成一坨。 */
.logs-toolbar,
.logs-meta-row {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px;
  flex: 0 0 auto;
}
.logs-toolbar { padding-bottom: 6px; }
.logs-meta-row { padding-bottom: 8px; }
.logs-meta-row .toolbar-spacer { flex: 1; }

/* "簇"：同一语义目的的控件包在一起，沿用 toolbar 的 8px gap 节奏。 */
.logs-cluster {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px;
}

.logs-scope {
  display: flex;
  align-items: center;
  gap: 10px;
  min-width: 0;
}

/* 汇总：类型 cell 里 tag 行可能比单数字高一截，给它多一点水平空间。 */
.logs-sumtypes { flex: 1.8; }
.type-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  padding-top: 1px;
}
/* 全局 .ui-sumvalue 没带 mono；stats-strip 的 .stat-value 是 mono，
   这里的汇总条要对齐它的"工程表"质感，给所有数字补上等宽字体。 */
.logs-summary .ui-sumvalue { font-family: var(--font-mono); }

.logs-table {
  flex: 1 1 auto;
  min-height: 0;
}
.logs-footer {
  display: flex;
  justify-content: flex-end;
  padding-top: 8px;
  flex: 0 0 auto;
}
</style>
