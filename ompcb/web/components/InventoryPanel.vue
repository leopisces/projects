<template>
  <div class="panel-body">
    <!-- 工具栏 -->
    <div class="app-toolbar">
      <!-- placeholder 直接给示例而不是罗列字段：空格分词是个"不写出来就没人会用"的功能，
           示例比"名称 / 封装 / 料号…"更能让人一眼看懂可以两段一起打。
           完整可搜字段放 title 里，鼠标悬停可见，不挤占框宽。 -->
      <el-input
        v-model="query.q"
        placeholder="搜索，空格可组合：1uF C0603"
        title="可搜名称 / 封装 / 料号 / 制造商 / 供应商 / 位置 / 备注；用空格分隔多个条件，需同时满足"
        clearable
        size="small"
        style="width: 280px"
        @input="onSearchInput"
        @clear="reload(1)"
        @keyup.enter="reload(1)"
      />
      <el-select
        v-model="query.status"
        placeholder="全部状态"
        clearable
        size="small"
        style="width: 130px"
        @change="reload(1)"
      >
        <el-option v-for="s in STATUS_OPTIONS" :key="s" :label="s" :value="s" />
      </el-select>
      <el-select
        v-model="query.location"
        placeholder="全部位置"
        clearable
        filterable
        size="small"
        style="width: 130px"
        @change="reload(1)"
      >
        <el-option v-for="loc in locationOptions" :key="loc" :label="loc || '(空)'" :value="loc" />
      </el-select>
      <el-select
        v-model="query.hasLocation"
        placeholder="是否归位"
        clearable
        size="small"
        style="width: 120px"
        @change="reload(1)"
      >
        <el-option label="有位置" value="1" />
        <el-option label="无位置" value="0" />
      </el-select>
      <el-select
        v-model="query.inStock"
        placeholder="全部库存"
        clearable
        size="small"
        style="width: 110px"
        @change="reload(1)"
      >
        <el-option label="有货 (>0)" value="1" />
        <el-option label="零库存 (=0)" value="0" />
      </el-select>

      <span class="toolbar-spacer" />

      <el-button type="primary" size="small" @click="openCreate">新增元件</el-button>
      <!-- 批量删除：勾选后才出现。删除不可恢复，配两步确认。 -->
      <el-button
        v-if="selectedRows.length > 0"
        type="danger"
        size="small"
        :loading="bulkDeleting"
        @click="confirmBulkDelete"
      >批量删除（{{ selectedRows.length }}）</el-button>
      <!-- 库位管理：5×5 货架网格，可看每格放了什么、可合并/拆分格子 -->
      <el-button size="small" @click="gridVisible = true">库位管理</el-button>
      <!-- 未使用：列出已用范围内空出来的格子（如已用 A11~A13/A15 则空 A14），
           方便新元件挑位置时优先填补空档而不是一路往后排。 -->
      <el-button size="small" @click="freeLocVisible = true">未使用</el-button>
      <el-button size="small" @click="bulkVisible = true">批量导入</el-button>
      <el-button size="small" :loading="exporting" @click="exportCsv">导出 CSV</el-button>
      <el-button size="small" :loading="loading" @click="reload()">刷新</el-button>
    </div>

    <!-- 汇总条 -->
    <InventoryStatsStrip :stats="stats" :loading="statsLoading" />

    <!-- 表格 -->
    <main class="app-table">
      <div class="table-wrap" style="overflow-x: auto;">
        <InventoryTable
          ref="tableRef"
          :rows="rows"
          :loading="loading"
          @sort-change="onSortChange"
          @edit="openEdit"
          @delete="confirmDelete"
          @move="openMove"
          @logs="openLogs"
          @selection-change="onSelectionChange"
        />
      </div>
    </main>

    <!-- 分页 -->
    <footer class="app-footer">
      <el-pagination
        v-model:current-page="query.page"
        v-model:page-size="query.pageSize"
        :total="total"
        :page-sizes="[20, 50, 100, 200]"
        size="small"
        background
        layout="total, sizes, prev, pager, next, jumper"
        @current-change="fetchList"
        @size-change="reload(1)"
      />
    </footer>

    <!-- 新增 / 编辑 -->
    <InventoryFormDialog
      v-model:visible="formVisible"
      :mode="formMode"
      :source="formSource"
      :saving="saving"
      @save="handleSave"
    />

    <!-- 出入库 -->
    <StockMoveDialog
      v-model:visible="moveVisible"
      :item="moveItem"
      :default-type="moveType"
      :submitting="moving"
      @submit="handleMove"
    />

    <!-- 流水抽屉 -->
    <InventoryLogDrawer
      v-model:visible="logsVisible"
      :item="logsItem"
      :logs="logsList"
      :loading="logsLoading"
      @refresh="fetchLogs"
      @revoked="handleRevoked"
    />

    <!-- 库位管理（5×5 货架网格，可合并/拆分） -->
    <LocationGridDialog v-model:visible="gridVisible" />

    <!-- 未使用库位 -->
    <FreeLocationDialog v-model:visible="freeLocVisible" />

    <!-- 批量导入 -->
    <BulkImportDialog
      v-model:visible="bulkVisible"
      :submitting="importing"
      title="批量导入库存（粘贴 Excel TSV）"
      :cols="BULK_COLS"
      :header-hints="['name', '名称']"
      :numeric-cols="['stock']"
      :required-any-of="['name', 'supplier_pn', 'mfr_pn']"
      :placeholder="BULK_PLACEHOLDER"
      allow-upsert
      replace-warning="覆盖模式会清空整个库存台账，连同全部出入库流水一起删除。"
      @submit="handleBulkImport"
    />
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { confirmDestructive } from '../confirm.js'
import InventoryTable from './InventoryTable.vue'
import InventoryFormDialog from './InventoryFormDialog.vue'
import InventoryStatsStrip from './InventoryStatsStrip.vue'
import StockMoveDialog from './StockMoveDialog.vue'
import InventoryLogDrawer from './InventoryLogDrawer.vue'
import FreeLocationDialog from './FreeLocationDialog.vue'
import LocationGridDialog from './LocationGridDialog.vue'
import BulkImportDialog from './BulkImportDialog.vue'
import {
  listInventory,
  getInventoryStats,
  getInventoryItem,
  listInventoryLocations,
  createInventory,
  updateInventory,
deleteInventory,
  moveStock,
  listItemLogs,
  bulkImportInventory,
  bulkDeleteInventory,
} from '../api.js'

const emit = defineEmits(['total-change'])

// 状态只有两种，且由库存量派生（库存 > 0 正常，否则缺货），不可手工录入
const STATUS_OPTIONS = ['正常', '缺货']

// CSV 导出列（含中文表头）。状态是派生值，导出时作为快照一并给出
const CSV_COLS = [
  ['name', '名称'], ['package', '封装'], ['mfr_pn', '制造商料号'],
  ['mfr', '制造商'], ['supplier', '供应商'], ['supplier_pn', '供应商料号'],
  ['stock', '库存'], ['status', '状态'], ['location', '位置'], ['remark', '备注']
]

// 批量粘贴的列顺序。不含 status：状态由库存量派生，导入时不接受该字段
const BULK_COLS = [
  'name', 'package', 'mfr_pn', 'mfr', 'supplier', 'supplier_pn', 'stock', 'location', 'remark'
]

const BULK_PLACEHOLDER =
  '示例：\n1MΩ\tR0402\t0402WGF1004TCE\tUNI-ROYAL(厚声)\tLCSC\tC26083\t2\tA15\t'

const query = reactive({
  q: '',
  status: '',
  location: '',
  // 归位与否，与上面按具体位置筛选是两个维度：'' 全部 / '1' 有位置 / '0' 无位置。
  // 空串时 api.js 的 request() 会自动把它从 query string 里剔掉，不参与筛选。
  hasLocation: '',
  inStock: '',
  page: 1,
  pageSize: 50,
  sortBy: 'name',
  sortOrder: 'asc'
})

const rows = ref([])
const total = ref(0)
const loading = ref(false)
const stats = ref({})
const statsLoading = ref(false)
const locationOptions = ref([])

const formVisible = ref(false)
const formMode = ref('create')
const formSource = ref(null)
const saving = ref(false)

const moveVisible = ref(false)
const moveItem = ref(null)
const moveType = ref('入库')
const moving = ref(false)

const logsVisible = ref(false)
const logsItem = ref(null)
const logsList = ref([])
const logsLoading = ref(false)

const bulkVisible = ref(false)
const importing = ref(false)
const exporting = ref(false)

// 勾选与批量删除
const tableRef = ref(null)
const selectedRows = ref([])
const bulkDeleting = ref(false)

// 未使用库位弹框。数据在 @open 时拉取，不常驻——库位变动后重开自然是新的。
const freeLocVisible = ref(false)

// 库位管理弹框（货架网格 + 合并）。同样 @open 拉取。
const gridVisible = ref(false)

// --- 数据加载 --------------------------------------------------------------

async function fetchList() {
  loading.value = true
  try {
    // 有搜索时回落第一页
    const data = await listInventory({ ...query })
    rows.value = data.list || []
    total.value = data.total || 0
    emit('total-change', total.value)
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    loading.value = false
  }
}

async function fetchStats() {
  statsLoading.value = true
  try {
    stats.value = await getInventoryStats()
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    statsLoading.value = false
  }
}

async function fetchLocations() {
  try {
    const locs = await listInventoryLocations()
    locationOptions.value = locs || []
  } catch { /* 不影响主流程 */ }
}

function reload(page) {
  if (page) query.page = page
  return Promise.all([fetchList(), fetchStats()])
}

let searchTimer = null
function onSearchInput() {
  clearTimeout(searchTimer)
  searchTimer = setTimeout(() => reload(1), 300)
}

function onSortChange({ prop, order }) {
  query.sortBy = prop || 'name'
  query.sortOrder = order === 'descending' ? 'desc' : 'asc'
  reload(1)
}

// --- 新增 / 编辑 ----------------------------------------------------------

function openCreate() {
  formMode.value = 'create'
  formSource.value = null
  formVisible.value = true
}

function openEdit(row) {
  formMode.value = 'edit'
  formSource.value = row
  formVisible.value = true
}

async function handleSave(payload) {
  saving.value = true
  try {
    if (formMode.value === 'edit' && formSource.value) {
      await updateInventory(formSource.value.id, payload)
      ElMessage.success('已保存修改')
    } else {
      await createInventory(payload)
      ElMessage.success('已新增元件')
    }
    formVisible.value = false
    await reload()
    fetchLocations()
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    saving.value = false
  }
}

async function confirmDelete(row) {
  const who = row.name || row.mfr_pn || row.supplier_pn
  // 删元件会级联清掉它的全部出入库流水，账目直接消失，所以走两步确认
  const okToDelete = await confirmDestructive({
    title: '删除元件',
    firstMessage:
      `确认删除「${who}」？当前库存 ${row.stock} 件，` +
      '该元件的所有出入库流水也将一并清除。',
    firstConfirm: '继续删除',
    secondMessage:
      `最后确认：删除「${who}」后，它的库存记录与全部出入库流水都无法找回。确定继续吗？`,
    secondConfirm: '确认删除，不可恢复',
  })
  if (!okToDelete) return

  try {
    await deleteInventory(row.id)
    ElMessage.success('已删除')
    if (rows.value.length === 1 && query.page > 1) query.page--
    await reload()
    fetchLocations()
  } catch (e) {
    ElMessage.error(e.message)
  }
}

// --- 勾选与批量删除 --------------------------------------------------------

function onSelectionChange(rows) {
  selectedRows.value = rows || []
}

/**
 * 批量删除勾选的元件。
 *
 * 与单条删除同等谨慎（两步确认）：删元件会级联清掉它的全部出入库流水，
 * 账目直接消失且不可恢复。批量时后果放大 N 倍，所以确认框里要给出
 * 具体条数、连带清掉的库存件数，并列出前几个名字让人能核对勾对了没有。
 */
async function confirmBulkDelete() {
  const targets = selectedRows.value
  if (!targets.length) return

  const names = targets.slice(0, 5).map(r => r.name || r.mfr_pn || r.supplier_pn || `#${r.id}`)
  const nameList = names.join('、') + (targets.length > 5 ? ` 等 ${targets.length} 项` : '')
  const totalStock = targets.reduce((a, r) => a + (Number(r.stock) || 0), 0)
  // 有库存的元件被删掉意味着账面上的实物凭空消失，值得单独点出来
  const withStock = targets.filter(r => Number(r.stock) > 0).length

  const stockNote = withStock > 0
    ? `其中 ${withStock} 项仍有库存（共 ${totalStock} 件），删除后这些账面数量一并消失。`
    : '这些元件当前库存均为 0。'

  const okToDelete = await confirmDestructive({
    title: `批量删除 ${targets.length} 项元件`,
    firstMessage:
      `即将删除：${nameList}。\n\n${stockNote}` +
      '每项元件的所有出入库流水也会被一并清除。',
    firstConfirm: `继续删除 ${targets.length} 项`,
    secondMessage:
      `最后确认：这 ${targets.length} 项的库存记录与全部出入库流水都无法找回。确定继续吗？`,
    secondConfirm: '确认删除，不可恢复',
  })
  if (!okToDelete) return

  bulkDeleting.value = true
  try {
    const res = await bulkDeleteInventory(targets.map(r => r.id))
    const logNote = res.logsRemoved > 0 ? `，连带清除 ${res.logsRemoved} 条流水` : ''
    ElMessage.success(`已删除 ${res.deleted} 项元件${logNote}`)

    // 勾选的行已不存在，必须清掉——reserve-selection 会跨重取保留选中
    tableRef.value?.clearSelection?.()
    selectedRows.value = []

    // 删光当前页时回退一页，避免停在空页
    if (rows.value.length === res.deleted && query.page > 1) query.page--
    await reload()
    fetchLocations()
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    bulkDeleting.value = false
  }
}

// --- 出入库 ----------------------------------------------------------------

function openMove(row, defaultType) {
  moveItem.value = row
  moveType.value = defaultType
  moveVisible.value = true
}

async function handleMove(payload) {
  moving.value = true
  try {
    // payload 已由 StockMoveDialog 按需装好：未绑定出库只带 {type,qty,remark}，
    // 绑定时才会带 productId/materialId。moveStock 再据此决定是否放入 body。
    const res = await moveStock(moveItem.value.id, payload)
    ElMessage.success(`${payload.type}成功：${payload.qty} 件，当前库存 ${res.stockAfter}`)
    moveVisible.value = false
    await reload()
    fetchLocations()
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    moving.value = false
  }
}

// --- 流水查看 --------------------------------------------------------------

function openLogs(row) {
  logsItem.value = row
  logsList.value = []
  logsVisible.value = true
}

async function fetchLogs() {
  if (!logsItem.value?.id) return
  logsLoading.value = true
  try {
    const data = await listItemLogs(logsItem.value.id)
    logsList.value = data.list || []
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    logsLoading.value = false
  }
}

/**
 * 撤销出库后：库存已变，主表与汇总要重取；
 * 抽屉头部的"当前库存"读的是 logsItem，单条撤销时接口直接回传了最新台账，
 * 批量撤销没有单个 item，就自己按 id 重取一次。
 */
async function handleRevoked(res) {
  if (res?.item) {
    logsItem.value = res.item
  } else if (logsItem.value?.id) {
    try {
      logsItem.value = await getInventoryItem(logsItem.value.id)
    } catch { /* 头部库存刷新失败不阻塞主流程，下面的 reload 仍会更新主表 */ }
  }
  await reload()
}

// --- 批量导入 --------------------------------------------------------------

async function handleBulkImport({ rows: parsed, mode }) {
  if (!parsed?.length) {
    ElMessage.warning('没有解析到有效数据')
    return
  }
  importing.value = true
  try {
    const res = await bulkImportInventory(parsed, mode)
    ElMessage.success(
      `导入完成：新增 ${res.inserted} 条，合并 ${res.updated || 0} 条，跳过 ${res.skipped} 条`
    )
    if (res.errors?.length) {
      console.warn('[ompcb] 库存导入跳过明细:', res.errors)
    }
    bulkVisible.value = false
    await reload(1)
    fetchLocations()
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    importing.value = false
  }
}

// --- 导出 CSV --------------------------------------------------------------

function csvCell(v) {
  const s = v === null || v === undefined ? '' : String(v)
  return /[",\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s
}

async function exportCsv() {
  exporting.value = true
  try {
    const data = await listInventory({ ...query, page: 1, pageSize: 500 })
    const list = data.list || []
    if (!list.length) {
      ElMessage.warning('当前筛选结果为空')
      return
    }
    const lines = [CSV_COLS.map(([, label]) => csvCell(label)).join(',')]
    for (const row of list) {
      lines.push(CSV_COLS.map(([key]) => csvCell(row[key])).join(','))
    }
    const blob = new Blob(['\uFEFF' + lines.join('\r\n')], { type: 'text/csv;charset=utf-8;' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    const ts = new Date().toISOString().slice(0, 10)
    a.href = url
    a.download = `ompcb-库存台账-${ts}.csv`
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

onMounted(() => {
  reload()
  fetchLocations()
})

// 供 App.vue 在切回本页时刷新（库存可能已被 BOM 页的批量出库改变）
defineExpose({
  refresh: () => {
    reload()
    fetchLocations()
  }
})
</script>