<template>
  <div class="panel-body">
    <!-- 产品选择：BOM 归属某个产品 -->
    <ProductSelectBar
      v-model="currentProductId"
      :products="products"
      :loading="productsLoading"
      @changed="onProductChanged"
      @view-logs="logsVisible = true"
    />

    <!-- 工具栏 -->
    <div class="app-toolbar">
      <!-- 同库存台账：用示例暴露空格分词能力，完整字段列表进 title -->
      <el-input
        v-model="query.q"
        placeholder="搜索，空格可组合：1uF C0603"
        title="可搜名称 / 位号 / 封装 / 料号 / 制造商 / 备注；用空格分隔多个条件，需同时满足"
        clearable
        size="small"
        style="width: 260px"
        :disabled="!currentProductId"
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
        :disabled="!currentProductId"
        @change="reload(1)"
      >
        <el-option v-for="s in STATUS_OPTIONS" :key="s" :label="s" :value="s" />
      </el-select>
      <el-select
        v-model="query.matchState"
        placeholder="全部关联"
        clearable
        size="small"
        style="width: 130px"
        :disabled="!currentProductId"
        @change="reload(1)"
      >
        <el-option label="已关联库存" value="matched" />
        <el-option label="未匹配库存" value="unmatched" />
        <el-option label="缺料" value="shortage" />
      </el-select>
      <!-- 焊接进度：判定基准是需求（用量 × 套数）而非单板用量，
           领料按套领，做 2 套时领满 2×用量才算焊完。所以改套数会影响本筛选结果。 -->
      <el-select
        v-model="query.solderState"
        placeholder="全部进度"
        clearable
        size="small"
        style="width: 130px"
        :disabled="!currentProductId"
        @change="reload(1)"
      >
        <el-option label="未焊完" value="unfinished" />
        <el-option label="已焊完" value="done" />
        <el-option label="超领" value="over" />
      </el-select>

      <!-- 制作套数：缺料 = 用量 × 套数 − 库存 -->
      <div class="sets-field">
        <span class="sets-label">制作</span>
        <el-input-number
          v-model="query.sets"
          :min="1"
          :max="9999"
          :step="1"
          size="small"
          controls-position="right"
          style="width: 96px"
          :disabled="!currentProductId"
          @change="onSetsChange"
        />
        <span class="sets-label">套</span>
      </div>

      <span class="toolbar-spacer" />

      <el-button type="primary" size="small" :disabled="!currentProductId" @click="openCreate">
        新增明细
      </el-button>
      <el-button size="small" :disabled="!currentProductId" @click="bulkVisible = true">
        Excel 导入
      </el-button>
      <!-- 未匹配的料先建进台账（库存 0），之后入库/盘点再录实际数量。
           tooltip 套在 span 上：el-button 处于 disabled 时自身不触发悬浮事件 -->
      <el-tooltip :content="adoptTip" placement="top">
        <span>
          <el-button
            size="small"
            :disabled="!currentProductId || adoptableKinds === 0"
            :loading="adopting"
            @click="confirmAdoptUnmatched"
          >
            未匹配建档{{ adoptableKinds > 0 ? `（${adoptableKinds}）` : '' }}
          </el-button>
        </span>
      </el-tooltip>
      <el-button
        size="small"
        type="warning"
        plain
        :disabled="!currentProductId || total === 0"
        @click="openIssue"
      >
        批量出库
      </el-button>
      <el-button size="small" :loading="exporting" :disabled="!currentProductId" @click="exportCsv">
        导出 CSV
      </el-button>
      <el-button size="small" :loading="loading" @click="reload()">刷新</el-button>
    </div>

    <!-- 汇总条 -->
    <BomStatsStrip :stats="stats" :sets="query.sets" :loading="statsLoading" />

    <!-- 表格 -->
    <main class="app-table">
      <div class="table-wrap">
        <div v-if="!currentProductId && !productsLoading" class="bom-empty">
          <EmptyBoard />
          <div class="bom-empty-text">还没有产品，先新建一个产品再添加 BOM</div>
        </div>
        <MaterialTable
          v-else
          :rows="rows"
          :loading="loading"
          :sets="query.sets"
          @sort-change="onSortChange"
          @edit="openEdit"
          @delete="confirmDelete"
          @issue="openRowIssue"
          @logs="openRowLogs"
          @inspect-stock="openStockMatch"
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
    <MaterialFormDialog
      v-model:visible="formVisible"
      :mode="formMode"
      :source="formSource"
      :saving="saving"
      @save="handleSave"
    />

    <!-- 批量导入：可选 .xlsx 文件（嘉立创/AD 标准 BOM），也可粘贴 TSV -->
    <BulkImportDialog
      v-model:visible="bulkVisible"
      :submitting="importing"
      :title="`导入 BOM 到「${currentProductCode}」`"
      :cols="BULK_COLS"
      :header-hints="['seq', '序号']"
      :numeric-cols="['seq', 'qty']"
      :required-any-of="['name']"
      :placeholder="BULK_PLACEHOLDER"
      :file-parser="parseXlsxBom"
      :replace-warning="`覆盖模式会先清空「${currentProductCode}」现有的 ${total} 条 BOM 明细（其他产品不受影响）。`"
      @submit="handleBulkImport"
    />

    <!-- 单行出库（按位号个数领料）。
         不挂 v-if：dialog 靠 @open 按位号填数量，若随 visible 一起挂载，
         挂载时 model-value 已是 true，@open 不一定触发，数量就填不上。
         与 InventoryPanel 里 StockMoveDialog 的用法一致——常驻挂载，内部按 material 判空。
         套数不参与出库逻辑：只传 material，不传 sets。 -->
    <MaterialIssueDialog
      v-model:visible="rowIssueVisible"
      :material="rowIssueTarget"
      :submitting="rowIssuing"
      @submit="handleRowIssue"
    />

    <!-- 单行领料流水（可撤销）。同样常驻挂载：靠 @open 拉数据。 -->
    <MaterialLogDialog
      v-model:visible="rowLogVisible"
      :material="rowLogTarget"
      @revoked="reloadAll"
    />

    <!-- 批量出库（领料） -->
    <BulkIssueDialog
      v-model:visible="issueVisible"
      :product-code="currentProductCode"
      :bom-lines="total"
      :default-sets="query.sets"
      :submitting="issuing"
      :result="issueResult"
      @submit="handleIssue"
    />

    <!-- 出入库记录（按产品查） -->
    <LogsDrawer
      v-model:visible="logsVisible"
      :product-id="currentProductId"
      :product-code="currentProductCode"
      @revoked="reloadAll"
    />

    <!-- 状态列点开：同名同封装的库存记录，可回填料号建立关联 -->
    <InventoryMatchDialog
      v-model:visible="matchVisible"
      :row="matchRow"
      :list="matchList"
      :loading="matchLoading"
      :binding="binding"
      :min-bind-stock="matchMinBindStock"
      @bind="handleBind"
    />
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import MaterialTable from './MaterialTable.vue'
import EmptyBoard from './EmptyBoard.vue'
import MaterialFormDialog from './MaterialFormDialog.vue'
import MaterialIssueDialog from './MaterialIssueDialog.vue'
import MaterialLogDialog from './MaterialLogDialog.vue'
import BulkImportDialog from './BulkImportDialog.vue'
import BulkIssueDialog from './BulkIssueDialog.vue'
import LogsDrawer from './LogsDrawer.vue'
import InventoryMatchDialog from './InventoryMatchDialog.vue'
import BomStatsStrip from './BomStatsStrip.vue'
import ProductSelectBar from './ProductSelectBar.vue'
import {
  listMaterials,
  getStats,
  createMaterial,
  updateMaterial,
  deleteMaterial,
  bulkImport,
  issueMaterials,
  moveStock,
  listProducts,
  adoptUnmatchedToInventory,
  bindMaterialToInventory,
  matchInventoryByNamePackage
} from '../api.js'
import { boundValue } from '../bom-display.js'
import { parseXlsxBom } from '../xlsx-import.js'

const emit = defineEmits(['total-change'])

// 库存状态只有两种，由库存量派生：库存 > 0 正常，否则缺货
const STATUS_OPTIONS = ['正常', '缺货']

// 批量粘贴的列顺序 —— 只含 BOM 自有字段。
// 状态/库存/位置不在其中：它们由库存台账按制造商料号动态关联。
const BULK_COLS = [
  'seq', 'name', 'designator', 'package', 'qty',
  'mfr_pn', 'mfr', 'supplier', 'supplier_pn', 'remark'
]

const BULK_PLACEHOLDER =
  '示例：\n1\t1MΩ\tR1,R32\tR0402\t2\t0402WGF1004TCE\tUNI-ROYAL(厚声)\tLCSC\tC26083\t'

// CSV 导出：BOM 自有列 + 库存动态关联出来的列（导出快照便于对外沟通）
//
// 制造商料号/制造商/供应商/供应商料号 四列与表格显示口径一致（走 boundValue）：
// 手动绑定过的行导出所绑定库存记录的值。导出是拿去下单/对外沟通的，
// 必须和用户在界面上看到、确认过的那份一致；两边不一致是最难被发现的一类 bug。
// 原导入值只在界面 hover 可见，刻意不进 CSV —— 同一概念出两列会让收到表格的人
// 不知道该按哪一列下单。
const CSV_COLS = [
  ['seq', '序号'], ['name', '名称'], ['designator', '位号'], ['package', '封装'],
  ['mfr_pn', '制造商料号'], ['mfr', '制造商'], ['supplier', '供应商'],
  ['supplier_pn', '供应商料号'], ['remark', '备注'],
  ['qty', '单板用量'], ['required', '需求量'], ['stock', '库存'], ['shortage', '缺料'],
  ['status', '状态(库存)'], ['location', '位置(库存)']
]

const products = ref([])
const productsLoading = ref(false)
const currentProductId = ref(null)

const currentProductCode = computed(
  () => products.value.find(p => p.id === currentProductId.value)?.code ?? ''
)

const query = reactive({
  q: '',
  status: '',
  matchState: '',
  solderState: '',   // 焊接进度：unfinished 未焊完 / done 已焊完 / over 超领
  sets: 1,          // 制作套数：缺料 = 用量 × 套数 − 库存
  page: 1,
  pageSize: 50,
  sortBy: 'seq',
  sortOrder: 'asc'
})

const rows = ref([])
const total = ref(0)
const loading = ref(false)

const stats = ref({})
const statsLoading = ref(false)

const formVisible = ref(false)
const formMode = ref('create')
const formSource = ref(null)
const saving = ref(false)

const bulkVisible = ref(false)
const importing = ref(false)
const exporting = ref(false)

const issueVisible = ref(false)
const issuing = ref(false)
const issueResult = ref(null)

// 单行出库（按位号个数领料）
const rowIssueVisible = ref(false)
const rowIssueTarget = ref(null)
const rowIssuing = ref(false)

// 单行领料流水（可撤销）
const rowLogVisible = ref(false)
const rowLogTarget = ref(null)

const logsVisible = ref(false)

// 状态列点开的「库存关联」弹框
const matchVisible = ref(false)
const matchRow = ref(null)
const matchList = ref([])
const matchLoading = ref(false)
// 库存「偏低」的提示阀值，由 /inventory/match 带出（见 server/bind-rules.js）。
// 不在前端写死：阀值写两份，改一处漏一处就会两边说法不一致。
const matchMinBindStock = ref(0)
const binding = ref(false)

const adopting = ref(false)

// 真正能建档的料号种数。刻意不用 unmatchedLines：
// 后者是行数、且含无制造商料号的行，而建档按料号去重并跳过空料号，
// 拿行数显示会和实际建出的条数对不上（例如 16 行未匹配其实只能建 1 种）。
const adoptableKinds = computed(() => Number(stats.value?.adoptableKinds) || 0)
const noPnLines = computed(() => Number(stats.value?.noPnLines) || 0)

const adoptTip = computed(() => {
  if (adoptableKinds.value > 0) {
    const tail = noPnLines.value > 0
      ? `；另有 ${noPnLines.value} 行无制造商料号，无法建档`
      : ''
    return `把 ${adoptableKinds.value} 种未匹配的物料建进库存台账，库存记 0，实际数量之后用入库/盘点录入${tail}`
  }
  if (noPnLines.value > 0) {
    return `没有可建档的料号：未匹配的 ${noPnLines.value} 行都没有制造商料号，台账靠它关联，建了也对不上`
  }
  return '当前产品的 BOM 已全部匹配到库存台账'
})

// --- 产品 ------------------------------------------------------------------

async function fetchProducts({ preferId } = {}) {
  productsLoading.value = true
  try {
    const data = await listProducts()
    products.value = data.list || []

    // 选中优先级：指定的 > 当前仍存在的 > 第一个
    const ids = products.value.map(p => p.id)
    if (preferId && ids.includes(preferId)) currentProductId.value = preferId
    else if (!ids.includes(currentProductId.value)) currentProductId.value = ids[0] ?? null
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    productsLoading.value = false
  }
}

/**
 * 产品增删改后重新拉取产品列表（下拉里的行数/缺料数也要更新）。
 * 若选中的产品因此变化，watch 会自动重新查询 BOM；
 * 没变化（例如只是重命名）则这里显式刷一次。
 */
async function onProductChanged(preferId) {
  const before = currentProductId.value
  await fetchProducts({ preferId: preferId ?? undefined })
  if (currentProductId.value === before) await reload(1)
}

// 切换产品必须重新查询 BOM：下拉只改了 currentProductId，
// 不 watch 的话表格还停在上一个产品的数据上。
watch(currentProductId, (id, prev) => {
  if (id === prev) return
  // 换产品后旧的搜索/筛选条件不再适用，一并清掉避免"切过去是空的"
  query.q = ''
  query.status = ''
  query.matchState = ''
  query.solderState = ''
  reload(1)
})

// --- 数据加载 --------------------------------------------------------------

async function fetchList() {
  if (!currentProductId.value) {
    rows.value = []
    total.value = 0
    emit('total-change', 0)
    return
  }
  loading.value = true
  try {
    const data = await listMaterials({ ...query, productId: currentProductId.value })
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
  if (!currentProductId.value) {
    stats.value = {}
    return
  }
  statsLoading.value = true
  try {
    stats.value = await getStats({ productId: currentProductId.value, sets: query.sets })
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    statsLoading.value = false
  }
}

/** 重新加载列表与汇总；传 page 时跳到指定页 */
function reload(page) {
  if (page) query.page = page
  return Promise.all([fetchList(), fetchStats()])
}

/** BOM 变动后产品下拉里的行数/缺料数也要跟着更新 */
async function reloadAll() {
  await Promise.all([reload(), fetchProducts({ preferId: currentProductId.value })])
}

// 搜索防抖 300ms
let searchTimer = null
function onSearchInput() {
  clearTimeout(searchTimer)
  searchTimer = setTimeout(() => reload(1), 300)
}

// 服务端排序
function onSortChange({ prop, order }) {
  query.sortBy = prop || 'seq'
  query.sortOrder = order === 'descending' ? 'desc' : 'asc'
  reload(1)
}

/** 套数变化：缺料要整体重算，筛选"缺料"时命中行也会变，所以回第一页 */
function onSetsChange(val) {
  const n = Number(val)
  query.sets = Number.isFinite(n) && n >= 1 ? Math.floor(n) : 1
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
      await updateMaterial(formSource.value.id, payload)
      ElMessage.success('已保存修改')
    } else {
      // 新增必须带产品归属
      await createMaterial({ ...payload, product_id: currentProductId.value })
      ElMessage.success('已新增 BOM 明细')
    }
    formVisible.value = false
    await reloadAll()
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    saving.value = false
  }
}

/** 点状态列：查台账里同名同封装的记录 */
async function openStockMatch(row) {
  matchRow.value = row
  matchList.value = []
  matchVisible.value = true
  matchLoading.value = true
  try {
    const res = await matchInventoryByNamePackage(row.name, row.package)
    // 弹框可能已被关掉或切到别的行，回来的结果就不该再灌进去
    if (matchRow.value?.id !== row.id) return
    matchList.value = res?.list || []
    matchMinBindStock.value = Number(res?.minBindStock) || 0
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    matchLoading.value = false
  }
}

/**
 * 绑定：把所选库存记录的制造商料号回填到 BOM 行。
 *
 * 不新增关联表 —— 台账与 BOM 始终只靠 mfr_pn 动态 JOIN（见 README 核心设计 §1），
 * 回填后关联立刻生效，也没有需要额外维护的状态。
 *
 * 走专用的 /bind 接口而不是通用 PUT：后端据此在首次绑定时把原导入的
 * 料号/制造商/供应商留一份快照（表格 hover 显示原值），而手工改料号则相反 ——
 * 要清掉快照。两者都写 mfr_pn，共用一个接口就分不出是谁在改。
 *
 * 已焊接进度不受影响：它按 material_id 聚合，与 mfr_pn 无关。但改料号会让
 * 「已焊接件数」与新关联的库存不再是同一个料，所以有进度的行要先问一句。
 */
async function handleBind(candidate) {
  const row = matchRow.value
  if (!row || !candidate?.mfr_pn) return

  const soldered = Number(row.solderedQty) || 0
  const hasOld = row.mfr_pn && row.mfr_pn !== candidate.mfr_pn
  let deleteOld = false

  // 需要弹确认的情况：有旧库存记录（可能要删除）或有已焊接进度
  if (hasOld || soldered > 0) {
    const lines = []
    if (soldered > 0) {
      lines.push(`本行已领料 ${soldered} 件（按原料号 ${row.mfr_pn} 记录）。改绑后已焊接件数不变，但它记的是原料号的领用，与新关联的库存不再是同一个料。`)
    }
    if (hasOld) {
      lines.push(`当前已关联库存「${row.mfr_pn}」，绑定新料号后该旧记录不再被本行关联。`)
    }

    try {
      await ElMessageBox.confirm(
        lines.join('\n'),
        '绑定确认',
        {
          type: 'warning',
          confirmButtonText: hasOld ? '绑定并删除旧记录' : '确认绑定',
          cancelButtonText: hasOld ? '只绑定，保留旧记录' : '取消',
          distinguishCancelAndClose: true
        }
      )
      // confirm → 用户点了「绑定并删除旧记录」
      deleteOld = hasOld
    } catch (e) {
      if (e === 'close') return // 点 X → 取消绑定
      // cancel → 用户点了「只绑定，保留旧记录」，deleteOld 保持 false
    }
  }

  binding.value = true
  try {
    await bindMaterialToInventory(row.id, candidate.mfr_pn, deleteOld ? { deleteOld: true } : {})
    const suffix = deleteOld ? `，旧记录「${row.mfr_pn}」已删除` : ''
    ElMessage.success(`已绑定到 ${candidate.mfr_pn}${suffix}`)
    matchVisible.value = false
    await reloadAll()
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    binding.value = false
  }
}

async function confirmDelete(row) {
  try {
    await ElMessageBox.confirm(
      `确认删除「${row.name}」${row.designator ? `（位号 ${row.designator}）` : ''}？`,
      '删除确认',
      { type: 'warning', confirmButtonText: '删除', cancelButtonText: '取消' }
    )
  } catch {
    return // 用户取消
  }
  try {
    await deleteMaterial(row.id)
    ElMessage.success('已删除')
    // 删掉当前页最后一条时回退一页，避免停在空页
    if (rows.value.length === 1 && query.page > 1) query.page--
    await reloadAll()
  } catch (e) {
    ElMessage.error(e.message)
  }
}

// --- 批量导入 --------------------------------------------------------------

async function handleBulkImport({ rows: parsed, mode }) {
  if (!parsed?.length) {
    ElMessage.warning('没有解析到有效数据')
    return
  }
  if (!currentProductId.value) {
    ElMessage.warning('请先选择产品')
    return
  }

  // 覆盖模式的二次确认由 BulkImportDialog 统一处理（见 replace-warning），
  // 这里不再重复弹窗，否则要点三次。

  importing.value = true
  try {
    const res = await bulkImport(parsed, mode, currentProductId.value)
    const parts = [`新增 ${res.inserted} 条`]
    if (res.removed) parts.push(`清除 ${res.removed} 条`)
    if (res.skipped) parts.push(`跳过 ${res.skipped} 条`)
    ElMessage.success(`导入完成：${parts.join('，')}`)
    if (res.errors?.length) {
      console.warn('[ompcb] 导入跳过明细:', res.errors)
    }
    bulkVisible.value = false
    await reloadAll()
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    importing.value = false
  }
}

// --- 批量出库（领料）------------------------------------------------------

function openIssue() {
  issueResult.value = null   // 清掉上次结果，弹窗回到确认视图
  issueVisible.value = true
}

async function handleIssue({ sets, remark }) {
  issuing.value = true
  try {
    const res = await issueMaterials({
      productId: currentProductId.value,
      sets,
      remark
    })
    // 赋值后弹窗自动切到结果视图，不关闭——用户要看跳过了哪些
    issueResult.value = res

    if (res.issuedLines === 0) {
      ElMessage.warning(`没有任何行出库：${res.skippedLines} 行库存不足`)
    } else if (res.skippedLines > 0) {
      ElMessage.warning(`出库 ${res.issuedLines} 行，${res.skippedLines} 行因缺料跳过`)
    } else {
      ElMessage.success(`全部出库成功：${res.issuedLines} 行，共 ${res.issuedQty} 件`)
    }

    // 库存变了，BOM 页的库存/缺料列要刷新
    await reloadAll()
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    issuing.value = false
  }
}

// --- 单行出库（按位号个数领料）--------------------------------------------

function openRowIssue(row) {
  rowIssueTarget.value = row
  rowIssueVisible.value = true
}

async function handleRowIssue({ inventoryId, qty, productId, materialId, remark }) {
  rowIssuing.value = true
  try {
    const res = await moveStock(inventoryId, {
      type: '出库',
      qty,
      productId,
      materialId,
      remark,
    })
    ElMessage.success(`已出库 ${qty} 件，剩余库存 ${res?.stockAfter ?? '—'}`)
    // 不清 rowIssueTarget：弹框由 v-if 挂载，立刻置 null 会在关闭动画途中卸载，
    // @closed 收不到、下次打开时 el-dialog 的过渡状态也是脏的。
    // 留着即可，下次 openRowIssue 会整体替换成新的行对象。
    rowIssueVisible.value = false
    // 库存/缺料/已焊接三列都变了，且产品下拉里的缺料数也要跟着更新
    await reloadAll()
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    rowIssuing.value = false
  }
}

// --- 单行领料流水 ----------------------------------------------------------
// 撤销由弹框内部完成（走 /logs/:id/revoke），撤销后 @revoked 触发 reloadAll：
// 库存、缺料、已焊接三列都会变，产品下拉里的缺料数也要跟着更新。

function openRowLogs(row) {
  rowLogTarget.value = row
  rowLogVisible.value = true
}

// --- 未匹配物料建档 --------------------------------------------------------
// 把 BOM 里未匹配到台账的料按制造商料号建进库存，库存一律 0。
// 建档 ≠ 入库：手头到底有几个得靠入库/盘点如实录，不能凭 BOM 猜。

async function confirmAdoptUnmatched() {
  if (!currentProductId.value || adoptableKinds.value === 0) return

  const tail = noPnLines.value > 0
    ? `另有 ${noPnLines.value} 行没有制造商料号，会跳过（台账靠它关联，建了也对不上）。`
    : ''

  try {
    await ElMessageBox.confirm(
      `将把「${currentProductCode.value}」BOM 中未匹配的 ${adoptableKinds.value} 种物料建进库存台账，` +
        `库存记为 0，实际数量之后用入库或盘点录入。${tail}`,
      '未匹配物料建档',
      {
        type: 'info',
        confirmButtonText: `建档 ${adoptableKinds.value} 种`,
        cancelButtonText: '取消'
      }
    )
  } catch {
    return
  }

  adopting.value = true
  try {
    const res = await adoptUnmatchedToInventory(currentProductId.value)

    if (res.inserted === 0) {
      // 一条都没建：要么本来就没有可建的，要么全被跳过了
      const why = []
      if (res.skipped > 0) why.push(`${res.skipped} 个料号因供应商料号冲突跳过`)
      if (res.skippedNoPn > 0) why.push(`${res.skippedNoPn} 行无制造商料号`)
      ElMessage.warning(why.length ? `未建任何记录：${why.join('，')}` : '没有需要建档的未匹配料号')
    } else {
      const extra = []
      if (res.skipped > 0) extra.push(`${res.skipped} 个跳过`)
      if (res.skippedNoPn > 0) extra.push(`${res.skippedNoPn} 行无料号`)
      const suffix = extra.length ? `（${extra.join('，')}）` : ''
      ElMessage.success(`已建档 ${res.inserted} 种元件，库存均为 0${suffix}`)
    }

    if (res.errors?.length) {
      console.warn('[ompcb] 建档跳过明细:', res.errors)
    }

    // 台账变了，BOM 的匹配状态/库存/缺料列都要重算
    await reloadAll()
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    adopting.value = false
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
    // 导出当前筛选条件下的全部结果，而不只是当前页
    const data = await listMaterials({
      ...query,
      productId: currentProductId.value,
      page: 1,
      pageSize: 500
    })
    const list = data.list || []
    if (!list.length) {
      ElMessage.warning('当前筛选结果为空')
      return
    }

    const lines = [CSV_COLS.map(([, label]) => csvCell(label)).join(',')]
    for (const row of list) {
      // boundValue 对非绑定列、非绑定行都原样返回 row[key]，可以无脑套用
      lines.push(CSV_COLS.map(([key]) => csvCell(boundValue(row, key))).join(','))
    }

    // 前置 BOM，保证 Excel 正确识别 UTF-8 中文
    const blob = new Blob(['\uFEFF' + lines.join('\r\n')], {
      type: 'text/csv;charset=utf-8;'
    })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    const ts = new Date().toISOString().slice(0, 10)
    a.href = url
    a.download = `ompcb-${currentProductCode.value || 'BOM'}-${query.sets}套-${ts}.csv`
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

onMounted(async () => {
  await fetchProducts()
  // 首次拉到产品时 watch 已触发查询；一个产品都没有时也要清空表格
  if (!currentProductId.value) await reload()
})
</script>

<style scoped>
/* 制作套数：和工具栏其他控件对齐 */
.sets-field {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  padding: 0 8px;
  border-left: 1px solid var(--c-border);
}
.sets-label {
  font-size: 12px;
  color: var(--c-text-2);
  white-space: nowrap;
}

/* 没有产品时的空状态：与表格内的空状态视觉语言保持一致 */
.bom-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 10px;
  height: 100%;
  padding: 28px 0;
}
.bom-empty-text {
  font-size: 12.5px;
  color: var(--c-text-3);
}
</style>
