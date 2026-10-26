<template>
  <el-dialog
    :model-value="visible"
    :title="pickMode ? '选择库位' : '库位管理'"
    width="760px"
    :close-on-click-modal="false"
    :close-on-press-escape="!busy"
    :show-close="!busy"
    @update:model-value="(v) => emit('update:visible', v)"
    @open="onOpen"
    @closed="onClosed"
  >
    <!-- 层切换 -->
    <div class="grid-toolbar">
      <el-select
        v-model="currentLayer"
        size="small"
        style="width: 120px"
        @change="fetchGrid"
      >
        <el-option
          v-for="L in allLayers"
          :key="L"
          :label="`${L} 层${layerUsage[L] ? ` (${layerUsage[L]})` : ''}`"
          :value="L"
        />
      </el-select>

      <span class="grid-toolbar-hint">
        <template v-if="pickMode">点击格子选为库位</template>
        <template v-else-if="!mergeMode">点击格子查看存放的料</template>
        <template v-else-if="selecting">
          已选 {{ selectedCells.length }} 格 —— 再点一格可扩展范围
        </template>
        <template v-else>点两格圈出要打通的范围</template>
      </span>

      <span class="toolbar-spacer" />

      <template v-if="!pickMode">
        <!-- 合并模式默认关闭：合并会改动货架结构并自动改写料的库位，
             不该被一次误点触发。开启后格子才进入可选状态。 -->
        <el-button
          size="small"
          :type="mergeMode ? 'warning' : 'default'"
          :plain="mergeMode"
          @click="toggleMergeMode"
        >{{ mergeMode ? '退出合并' : '合并格子' }}</el-button>
        <el-button
          v-if="mergeMode && selecting"
          size="small"
          @click="clearSelection"
        >清空选择</el-button>
        <el-button
          v-if="mergeMode"
          type="warning"
          size="small"
          :loading="merging"
          :disabled="selectedCells.length < 2"
          @click="confirmMerge"
        >合并{{ selectedCells.length >= 2 ? ` ${selectedCells.length} 格` : '' }}</el-button>
      </template>
      <el-button size="small" :loading="loading" @click="fetchGrid">刷新</el-button>
    </div>

    <!-- 网格 -->
    <div v-loading="loading" class="grid-wrap">
      <table v-if="layer" class="loc-grid">
        <thead>
          <tr>
            <th class="loc-corner"></th>
            <th v-for="c in cols" :key="c" class="loc-head">{{ c }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="r in rows" :key="r">
            <th class="loc-head loc-head-row">{{ r }}</th>
            <template v-for="c in cols" :key="c">
              <td
                v-if="!cellAt(r, c).swallowed"
                class="loc-cell"
                :class="cellClass(cellAt(r, c))"
                :rowspan="cellAt(r, c).rowSpan"
                :colspan="cellAt(r, c).colSpan"
                :title="cellTitle(cellAt(r, c))"
                @click="onCellClick(cellAt(r, c))"
              >
                <div class="loc-code">{{ cellAt(r, c).code }}</div>
                <div v-if="cellAt(r, c).itemCount > 0" class="loc-items">
                  <span class="loc-count">{{ cellAt(r, c).itemCount }} 种</span>
                  <span class="loc-stock">{{ cellAt(r, c).totalStock }} 件</span>
                </div>
                <div v-else class="loc-empty">空</div>
                <!-- 合并区域给个角标；拆分入口只在合并模式下出现，
                     避免只想看看的时候误点「拆」。 -->
                <span v-if="cellAt(r, c).mergeId && !pickMode" class="loc-merge-badge">
                  合
                  <el-button
                    v-if="mergeMode"
                    link
                    type="danger"
                    size="small"
                    class="loc-unmerge"
                    :loading="unmergingId === cellAt(r, c).mergeId"
                    @click.stop="confirmUnmerge(cellAt(r, c))"
                  >拆</el-button>
                </span>
              </td>
            </template>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- 当前层概况 -->
    <div v-if="layer" class="grid-foot ui-hint">
      {{ layer.layer }} 层：已用 {{ layer.usedCount }} 格，空 {{ layer.freeCount }} 格，合并 {{ layer.merges.length }} 处
      <span v-if="unparsed.length" class="grid-foot-warn">
        · 另有 {{ unparsed.length }} 条料的库位不在网格内（{{ unparsed.slice(0, 3).map(u => u.location).join('、') }}{{ unparsed.length > 3 ? ' 等' : '' }}）
      </span>
    </div>

    <!-- 选中格子的料清单 -->
    <div v-if="detailCell && detailCell.items.length" class="grid-detail">
      <div class="grid-detail-title">{{ detailCell.code }} 存放的料</div>
      <div class="grid-detail-list">
        <div v-for="it in detailCell.items" :key="it.id" class="grid-detail-item">
          <span class="grid-detail-name">{{ it.name || it.mfr_pn || `#${it.id}` }}</span>
          <span v-if="it.package" class="grid-detail-pkg">{{ it.package }}</span>
          <span class="grid-detail-stock">{{ it.stock }}</span>
        </div>
      </div>
    </div>

    <template #footer>
      <el-button @click="close" :disabled="busy">{{ pickMode ? '取消' : '关闭' }}</el-button>
      <el-button
        v-if="pickMode"
        type="primary"
        :disabled="!pickedCode"
        @click="confirmPick"
      >
        选定{{ pickedCode ? ` ${pickedCode}` : '' }}
      </el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { computed, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getLocationGrid, mergeLocations, unmergeLocations } from '../api.js'

const props = defineProps({
  visible: { type: Boolean, default: false },
  /**
   * 选位置模式：点格子即选中，确认后 emit('pick', code)。
   * 此模式下不显示合并/拆分操作——选库位时误触合并会改动货架结构。
   */
  pickMode: { type: Boolean, default: false },
  /** 选位置模式下的初始层；不传则用已用层的第一层 */
  initialLocation: { type: String, default: '' },
})

const emit = defineEmits(['update:visible', 'pick'])

const loading = ref(false)
const merging = ref(false)
const unmergingId = ref(null)

const allLayers = ref([])
const layerUsage = ref({})   // layer -> '3/25' 之类的用量摘要
const currentLayer = ref('A')
const layer = ref(null)      // 当前层的网格数据
const unparsed = ref([])
const rows = ref(5)
const cols = ref(5)

// 合并选择：记录起点与终点，形成矩形
const anchor = ref(null)     // { row, col }
const focus = ref(null)      // { row, col }

/**
 * 合并模式开关。
 *
 * 默认关闭 —— 点格子只看详情。合并会改动货架物理结构并自动改写料的库位，
 * 误触代价高，所以要求显式开启才能选范围。
 */
const mergeMode = ref(false)

// 选位置模式下点中的格子
const pickedCode = ref('')
const detailCell = ref(null)

const busy = computed(() => merging.value || unmergingId.value !== null)
const selecting = computed(() => anchor.value !== null)

/** 当前选中的矩形范围 */
const range = computed(() => {
  if (!anchor.value) return null
  const f = focus.value || anchor.value
  return {
    startRow: Math.min(anchor.value.row, f.row),
    startCol: Math.min(anchor.value.col, f.col),
    endRow: Math.max(anchor.value.row, f.row),
    endCol: Math.max(anchor.value.col, f.col),
  }
})

/** 选中范围覆盖的格子编号 */
const selectedCells = computed(() => {
  const r = range.value
  if (!r) return []
  const out = []
  for (let row = r.startRow; row <= r.endRow; row++) {
    for (let col = r.startCol; col <= r.endCol; col++) {
      out.push(`${currentLayer.value}${row}${col}`)
    }
  }
  return out
})

// ---------- 数据 ----------

function cellAt(row, col) {
  return (
    layer.value?.cells.find(c => c.row === row && c.col === col) || {
      code: `${currentLayer.value}${row}${col}`,
      row,
      col,
      swallowed: false,
      mergeId: null,
      rowSpan: 1,
      colSpan: 1,
      items: [],
      itemCount: 0,
      totalStock: 0,
    }
  )
}

async function fetchGrid() {
  loading.value = true
  clearSelection()
  detailCell.value = null
  try {
    const data = await getLocationGrid(currentLayer.value)
    rows.value = data.rows || 5
    cols.value = data.cols || 5
    allLayers.value = data.allLayers || []
    unparsed.value = data.unparsed || []
    layer.value = data.layers?.[0] || null
  } catch (e) {
    ElMessage.error(e.message)
    layer.value = null
  } finally {
    loading.value = false
  }
}

/** 拉一次全局概况，给层下拉标注每层用量 */
async function fetchUsage() {
  try {
    const data = await getLocationGrid()
    const usage = {}
    for (const L of data.layers || []) {
      usage[L.layer] = `${L.usedCount} 用`
    }
    layerUsage.value = usage
    if (!allLayers.value.length) allLayers.value = data.allLayers || []
    return data
  } catch {
    return null
  }
}

async function onOpen() {
  pickedCode.value = ''
  detailCell.value = null
  mergeMode.value = false   // 每次打开都回到「只看」状态
  clearSelection()

  const overview = await fetchUsage()

  // 选位置模式带了当前库位，就直接跳到它所在的层
  const init = String(props.initialLocation || '').trim().toUpperCase()
  if (init && /^[A-Z][1-5][1-5]$/.test(init)) {
    currentLayer.value = init[0]
    pickedCode.value = init
  } else {
    // 否则用已用层的第一层，没有已用层就 A 层
    currentLayer.value = overview?.layers?.[0]?.layer || 'A'
  }
  await fetchGrid()
}

function onClosed() {
  layer.value = null
  mergeMode.value = false
  clearSelection()
  pickedCode.value = ''
  detailCell.value = null
}

function close() {
  if (busy.value) return
  emit('update:visible', false)
}

// ---------- 交互 ----------

function clearSelection() {
  anchor.value = null
  focus.value = null
}

function onCellClick(cell) {
  // 选位置模式：点即选，不做合并
  if (props.pickMode) {
    pickedCode.value = cell.code
    detailCell.value = cell.itemCount > 0 ? cell : null
    return
  }

  // 默认（非合并模式）：点格子只是查看详情。
  // 合并是改动货架物理结构的操作，误触代价高（会自动改写料的库位），
  // 所以必须先显式开启「合并模式」才能选范围。
  if (!mergeMode.value) {
    detailCell.value = cell.itemCount > 0 ? cell : null
    return
  }

  // 已合并的格子不参与新的合并选择——要先拆开
  if (cell.mergeId) {
    detailCell.value = cell.itemCount > 0 ? cell : null
    return
  }

  if (!anchor.value) {
    anchor.value = { row: cell.row, col: cell.col }
    focus.value = { row: cell.row, col: cell.col }
    detailCell.value = cell.itemCount > 0 ? cell : null
    return
  }

  // 第二次点击定终点
  focus.value = { row: cell.row, col: cell.col }
}

/** 退出合并模式时清掉未提交的选择，避免残留状态跟着下次进入 */
function toggleMergeMode() {
  mergeMode.value = !mergeMode.value
  if (!mergeMode.value) clearSelection()
}

function cellClass(cell) {
  const cls = []
  if (cell.itemCount > 0) cls.push('is-used')
  else cls.push('is-free')
  if (cell.mergeId) cls.push('is-merged')
  if (props.pickMode && pickedCode.value === cell.code) cls.push('is-picked')
  if (!props.pickMode && selectedCells.value.includes(cell.code)) cls.push('is-selected')
  return cls
}

function cellTitle(cell) {
  const parts = [cell.code]
  if (cell.mergeId) parts.push(`合并区域（横跨 ${cell.colSpan} 列、纵跨 ${cell.rowSpan} 行）`)
  if (cell.itemCount > 0) {
    parts.push(`${cell.itemCount} 种料，共 ${cell.totalStock} 件`)
    parts.push(cell.items.slice(0, 5).map(i => i.name || i.mfr_pn).join('、'))
  } else {
    parts.push('空格')
  }
  return parts.join('\n')
}

// ---------- 合并 / 拆分 ----------

async function confirmMerge() {
  const r = range.value
  if (!r || selectedCells.value.length < 2) return

  const primary = `${currentLayer.value}${r.startRow}${r.startCol}`
  const swallowed = selectedCells.value.filter(c => c !== primary)
  // 被吞并格里有料时要说清「库位会被自动改写」，这是不可逆的数据变更
  const affected = swallowed
    .map(code => layer.value?.cells.find(c => c.code === code))
    .filter(c => c && c.itemCount > 0)
  const movedCount = affected.reduce((a, c) => a + c.itemCount, 0)

  let remark = ''
  try {
    const tail = movedCount > 0
      ? `\n\n${swallowed.join('、')} 里的 ${movedCount} 种料，库位会自动改成 ${primary}。`
      : ''
    const res = await ElMessageBox.prompt(
      `将把 ${selectedCells.value.join('、')} 打通成一个大格，主格为 ${primary}。${tail}`,
      '合并库位',
      {
        confirmButtonText: '确认合并',
        cancelButtonText: '取消',
        inputPlaceholder: '备注（如「放排母包」，可留空）',
        inputValue: '',
        inputValidator: () => true,
        type: movedCount > 0 ? 'warning' : 'info',
      }
    )
    remark = String(res.value ?? '').trim()
  } catch {
    return
  }

  merging.value = true
  try {
    const res = await mergeLocations({
      layer: currentLayer.value,
      startRow: r.startRow,
      startCol: r.startCol,
      endRow: r.endRow,
      endCol: r.endCol,
      remark,
    })
    const moved = res?.moved || 0
    ElMessage.success(
      moved > 0 ? `已合并，${moved} 条料的库位改为 ${res.primary}` : `已合并为 ${res.primary}`
    )
    await Promise.all([fetchGrid(), fetchUsage()])
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    merging.value = false
  }
}

async function confirmUnmerge(cell) {
  if (!cell.mergeId) return
  try {
    await ElMessageBox.confirm(
      `将取消 ${cell.code} 的合并（恢复隔板）。\n\n` +
        '格子里的料库位保持不变，仍记在主格上——拆开隔板后它们物理上还在原处，' +
        '之后可按实际摆放逐条调整。',
      '取消合并',
      { type: 'warning', confirmButtonText: '确认拆分', cancelButtonText: '取消' }
    )
  } catch {
    return
  }

  unmergingId.value = cell.mergeId
  try {
    await unmergeLocations(cell.mergeId)
    ElMessage.success('已取消合并')
    await Promise.all([fetchGrid(), fetchUsage()])
  } catch (e) {
    ElMessage.error(e.message)
  } finally {
    unmergingId.value = null
  }
}

// ---------- 选位置 ----------

function confirmPick() {
  if (!pickedCode.value) return
  emit('pick', pickedCode.value)
  emit('update:visible', false)
}
</script>

<style scoped>
.grid-toolbar {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 12px;
}
.grid-toolbar-hint {
  font-size: var(--fs-micro);
  color: var(--c-text-3);
}
.toolbar-spacer {
  flex: 1;
}

.grid-wrap {
  min-height: 260px;
}

/* 货架网格：table 而不是 CSS grid —— 合并要用 rowspan/colspan，
   那是 table 的原生能力，CSS grid 得手算每格的起止行列，代码复杂且易错。 */
.loc-grid {
  border-collapse: collapse;
  width: 100%;
  table-layout: fixed;
}
.loc-corner,
.loc-head {
  padding: 4px;
  text-align: center;
  font-size: var(--fs-micro);
  font-weight: 600;
  color: var(--c-text-3);
  background: var(--c-sunken-2);
  border: 1px solid var(--c-border-2);
}
.loc-corner {
  width: 32px;
}
.loc-head-row {
  width: 32px;
}

.loc-cell {
  height: 66px;
  padding: 4px;
  text-align: center;
  vertical-align: middle;
  border: 1px solid var(--c-border);
  cursor: pointer;
  position: relative;
  transition: background 0.1s, border-color 0.1s;
}
.loc-cell:hover {
  border-color: var(--c-accent);
}

.loc-code {
  font-family: var(--font-mono);
  font-size: var(--fs-sm);
  font-weight: 600;
  color: var(--c-text-2);
}

/* 空格淡化、有料的用 accent 底：一眼扫出哪儿还能放 */
.loc-cell.is-free {
  background: var(--c-sunken);
}
.loc-cell.is-free .loc-code {
  color: var(--c-muted);
}
.loc-cell.is-used {
  background: var(--c-accent-soft);
}

.loc-empty {
  margin-top: 2px;
  font-size: var(--fs-micro);
  color: var(--c-muted);
}
.loc-items {
  margin-top: 2px;
  display: flex;
  flex-direction: column;
  gap: 1px;
  font-size: var(--fs-micro);
}
.loc-count {
  color: var(--c-accent);
  font-weight: 600;
}
.loc-stock {
  color: var(--c-text-3);
  font-family: var(--font-mono);
}

/* 合并区域：紫色边，与 BOM 表里「绑定值」同一套紫色语义（都表示"这格不是原样"） */
.loc-cell.is-merged {
  border: 2px solid var(--c-bind, var(--c-accent));
  background: var(--c-bind-soft, var(--c-accent-soft));
}
.loc-merge-badge {
  position: absolute;
  top: 2px;
  right: 2px;
  display: inline-flex;
  align-items: center;
  gap: 2px;
  padding: 0 3px;
  border-radius: 2px;
  background: var(--c-bind, var(--c-accent));
  color: #fff;
  font-size: var(--fs-micro);
  line-height: 14px;
}
.loc-unmerge {
  padding: 0;
  height: auto;
  min-height: 0;
  color: #fff !important;
}

/* 合并选择中的格子 */
.loc-cell.is-selected {
  outline: 2px solid var(--c-warn);
  outline-offset: -2px;
  background: var(--c-warn-soft);
}
/* 选位置模式下选中的格子 */
.loc-cell.is-picked {
  outline: 2px solid var(--c-success, var(--c-accent));
  outline-offset: -2px;
}

.grid-foot {
  margin-top: 10px;
}
.grid-foot-warn {
  color: var(--c-warn);
}

/* 选中格子的料清单 */
.grid-detail {
  margin-top: 12px;
  padding-top: 10px;
  border-top: 1px solid var(--c-border-2);
}
.grid-detail-title {
  font-size: var(--fs-sm);
  font-weight: 600;
  color: var(--c-text-2);
  margin-bottom: 6px;
}
.grid-detail-list {
  display: flex;
  flex-wrap: wrap;
  gap: 4px 8px;
}
.grid-detail-item {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  padding: 1px 6px;
  border-radius: 2px;
  background: var(--c-sunken-2);
  border: 1px solid var(--c-border-2);
  font-size: var(--fs-micro);
}
.grid-detail-name {
  color: var(--c-text-2);
}
.grid-detail-pkg {
  color: var(--c-text-3);
  font-family: var(--font-mono);
}
.grid-detail-stock {
  color: var(--c-accent);
  font-family: var(--font-mono);
  font-weight: 600;
}
</style>