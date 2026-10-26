// web/location.js — 库位编址解析、空位计算与网格合并
//
// 库位是二维格架编号：{层}{行}{列}，如 `A15` = A 层第 1 行第 5 列。
//   - 层：单个字母 A~Z（A 层、B 层……）
//   - 行：1 位数字 1~5，纵向递增（A11 → A21 → A31 是往下走）
//   - 列：1 位数字 1~5，横向递增（A11 → A12 → A13 是往右走）
//
// 每层固定 5×5 = 25 格，26 层共 650 格。
// 行列各取 1 位而非自适应位数：`A111` 到底是 1 行 11 列还是 11 行 1 列无法判定，
// 位数自适应会引入歧义。
//
// 为什么单独成文件而不是塞进组件：
// 纯函数、无 Vue 依赖，`node:test` 能直接 import 断言，与 designator.js 同一套模式。

/** 每层的行数与列数。固定 5×5，改这里一处即可整体调整。 */
export const GRID_ROWS = 5
export const GRID_COLS = 5

/** 所有层号 A~Z */
export const LAYERS = Array.from({ length: 26 }, (_, i) => String.fromCharCode(65 + i))

/** 合法库位：单字母 + 行 + 列，行列均在 1..5 内 */
const LOCATION_RE = /^([A-Z])([1-5])([1-5])$/

/**
 * 归一化库位字面量：全角转半角、去空白、字母转大写。
 *
 * 只用于比较与解析，绝不改写用户存进库的原值——
 * 他写 `a 15` 就该原样保留，归一只是为了认出「这其实是 A15」。
 *
 * @param {string|null|undefined} raw
 * @returns {string} 归一后的字面量，无有效内容时为 ''
 */
export function normalizeLocation(raw) {
  return String(raw ?? '')
    .normalize('NFKC')
    .replace(/[\s\u3000]+/g, '')
    .toUpperCase()
}

/**
 * 解析库位成 { layer, row, col }。不符合 {层}{行}{列} 格式时返回 null。
 *
 * 返回 null 是正常情况而非错误：历史数据或特殊存放点可能写成
 * `抽屉3-格5`、`待入库` 这类自由文本，它们不参与网格空位计算，
 * 但仍是合法的库位值，不该被当成脏数据拒绝。
 *
 * @param {string|null|undefined} raw
 * @returns {{ layer: string, row: number, col: number } | null}
 */
export function parseLocation(raw) {
  const m = LOCATION_RE.exec(normalizeLocation(raw))
  if (!m) return null
  return { layer: m[1], row: Number(m[2]), col: Number(m[3]) }
}

/**
 * 由 { layer, row, col } 拼回库位字面量。
 * @returns {string} 如 'A15'
 */
export function formatLocation({ layer, row, col }) {
  return `${layer}${row}${col}`
}

/**
 * 生成某层所有格子，按行序排列。
 * 每行内从左到右，跨行时行号递增。
 * @returns {string[]} 如 ['A11','A12','A13','A14','A15','A21',...]
 */
export function allLayerCells(layer) {
  const out = []
  for (let r = 1; r <= GRID_ROWS; r++) {
    for (let c = 1; c <= GRID_COLS; c++) {
      out.push(formatLocation({ layer, row: r, col: c }))
    }
  }
  return out
}

/** 所有层所有格子，按层序、行、列排列 */
export function allGridCells() {
  return LAYERS.flatMap(allLayerCells)
}

// ---------------------------------------------------------------------------
// 合并（物理打通格子）
//
// 合并后，被吞并的格子不再独立存在，主格（左上角）代表整个区域。
// 原本放在被吞并格子里的料，location 统一改成主格号。
//
// 合并约束：
//   1. 只能在同一层内（跨层合并没有物理意义）
//   2. 必须是矩形，不能是 L 形或任意形状
//   3. 不能超出网格边界（1..5）
//   4. 不能与已有合并重叠
// ---------------------------------------------------------------------------

/**
 * 校验合并范围是否合法。
 *
 * @param {string} layer
 * @param {number} startRow
 * @param {number} startCol
 * @param {number} endRow
 * @param {number} endCol
 * @param {Array<{layer:string,startRow:number,startCol:number,endRow:number,endCol:number}>} [existingMerges]
 * @returns {{ ok: true } | { ok: false, error: string }}
 */
export function validateMerge(layer, startRow, startCol, endRow, endCol, existingMerges = []) {
  // 单格不需要合并
  if (startRow === endRow && startCol === endCol) {
    return { ok: false, error: '单格不需要合并' }
  }

  // 边界检查
  if (startRow < 1 || startRow > GRID_ROWS || endRow < 1 || endRow > GRID_ROWS) {
    return { ok: false, error: `行号必须在 1~${GRID_ROWS} 之间` }
  }
  if (startCol < 1 || startCol > GRID_COLS || endCol < 1 || endCol > GRID_COLS) {
    return { ok: false, error: `列号必须在 1~${GRID_COLS} 之间` }
  }

  // 方向必须正确（start 在左上，end 在右下）
  if (startRow > endRow || startCol > endCol) {
    return { ok: false, error: '合并范围必须从左上到右下' }
  }

  // 检查与已有合并重叠
  for (const m of existingMerges) {
    if (m.layer !== layer) continue
    // 两个矩形重叠检测：A 在 B 的左边/上边/右边/下边则无重叠
    if (endRow < m.startRow || startRow > m.endRow) continue
    if (endCol < m.startCol || startCol > m.endCol) continue
    return { ok: false, error: `与已有合并 ${formatLocation({ layer, row: m.startRow, col: m.startCol })}~${formatLocation({ layer, row: m.endRow, col: m.endCol })} 重叠` }
  }

  return { ok: true }
}

/**
 * 获取合并区域所覆盖的所有格子（含主格）。
 * @returns {string[]} 如 ['A11','A12']
 */
export function getMergeCells(layer, startRow, startCol, endRow, endCol) {
  const cells = []
  for (let r = startRow; r <= endRow; r++) {
    for (let c = startCol; c <= endCol; c++) {
      cells.push(formatLocation({ layer, row: r, col: c }))
    }
  }
  return cells
}

/**
 * 根据合并列表，解析一个格子的有效库位。
 * 如果格子被合并了，返回主格号；否则返回原格子。
 *
 * @param {string} cell 如 'A12'
 * @param {Array<{layer:string,startRow:number,startCol:number,endRow:number,endCol:number,primary:string}>} merges
 * @returns {string} 有效库位号
 */
export function resolveCell(cell, merges = []) {
  const p = parseLocation(cell)
  if (!p) return cell
  for (const m of merges) {
    if (m.layer !== p.layer) continue
    if (p.row >= m.startRow && p.row <= m.endRow && p.col >= m.startCol && p.col <= m.endCol) {
      return m.primary
    }
  }
  return cell
}

/**
 * 按顺序取出 count 个未占用的库位（供未匹配建档自动分配）。
 *
 * 与 findFreeLocations 的区别很关键：
 *   findFreeLocations —— 只列「已用范围内」空出来的格子，不凭空造新行/新层。
 *                        它回答的是「中间还有哪些空档」，给人看的。
 *   allocateFreeCells —— 从整个 26 层网格按 A11→A15→A21…→A55→B11… 顺序取，
 *                        因为自动分配必须真能分出位置来。台账空着的时候
 *                        「已用范围」是空集，用前者会一个都分不到。
 *
 * 顺序即货架的自然顺序：同一行从左到右填满再换下一行，一层填满再开下一层。
 * 这样新建的料在货架上是连续的一片，找料时不用跳着找。
 *
 * 被合并吞掉的格子（非主格）不参与分配 —— 它们已不是独立库位。
 * 合并主格若空着则可分配：那是个更大的格子，照样能放料。
 *
 * @param {Array<string|{location: string}>} used 已占用的库位
 * @param {number} count 需要分配几个
 * @param {Array<{layer:string,startRow:number,startCol:number,endRow:number,endCol:number,primary:string}>} merges
 * @returns {{ cells: string[], enough: boolean, available: number }}
 *   cells 实际分到的库位（可能少于 count）；enough 表示是否够分；
 *   available 是全网格剩余可用格数。不够时不报错——分到几个算几个，
 *   剩下的留空由人工处理，这比整批失败更有用。
 */
export function allocateFreeCells(used = [], count = 0, merges = []) {
  // 已占用：把落在合并区域里的库位归到主格，避免主格被重复分配
  const occupied = new Set()
  for (const item of used) {
    const raw = typeof item === 'string' ? item : item?.location
    const text = String(raw ?? '').trim()
    if (!text) continue
    const effective = resolveCell(text, merges)
    const p = parseLocation(effective)
    if (p) occupied.add(formatLocation(p))
  }

  // 被合并吞掉的非主格：不是独立库位，不能分
  const swallowed = new Set()
  for (const m of merges) {
    for (const c of getMergeCells(m.layer, m.startRow, m.startCol, m.endRow, m.endCol)) {
      if (c !== m.primary) swallowed.add(c)
    }
  }

  const pool = allGridCells().filter(c => !occupied.has(c) && !swallowed.has(c))
  const n = Math.max(0, Math.floor(Number(count) || 0))

  return {
    cells: pool.slice(0, n),
    enough: pool.length >= n,
    available: pool.length
  }
}

/**
 * 算出「已用范围内」还空着的库位（考虑合并）。
 *
 * 遍历固定网格所有格子，跳过被合并吞掉的格子。
 * 范围：已用过的层 × 已用行最大值 × 已用列最大值 围成的矩形。
 * 每层独立算上界，不凭空造新层/新行。
 *
 * 与 allocateFreeCells 的分工：这个给人看「中间还有哪些空档」，
 * 那个负责真的分出位置来（从全网格取，台账空着时也能分）。
 *
 * @param {Array<string|{location: string}>} used
 * @param {Array<{layer:string,startRow:number,startCol:number,endRow:number,endCol:number,primary:string}>} merges
 * @returns {{ free: string[], maxLocation: string, layers: Array<{layer:string, maxRow:number, maxCol:number, free:string[], usedCount:number}>, unparsed: string[] }}
 */
export function findFreeLocations(used = [], merges = []) {
  const unparsed = []
  const byLayer = new Map()

  for (const item of used) {
    const raw = typeof item === 'string' ? item : item?.location
    const text = String(raw ?? '').trim()
    if (!text) continue

    // 被合并吞掉的格子，它的料算到主格头上
    const effective = resolveCell(text, merges)
    const cell = parseLocation(effective)
    if (!cell) {
      unparsed.push(text)
      continue
    }
    if (!byLayer.has(cell.layer)) byLayer.set(cell.layer, new Set())
    byLayer.get(cell.layer).add(`${cell.row},${cell.col}`)
  }

  const layers = []
  const free = []

  for (const layer of LAYERS) {
    const cells = byLayer.get(layer)
    if (!cells) continue // 该层还没用过，跳过

    let maxRow = 0
    let maxCol = 0
    for (const key of cells) {
      const [r, c] = key.split(',').map(Number)
      if (r > maxRow) maxRow = r
      if (c > maxCol) maxCol = c
    }

    // 收集该层合并所吞掉的格子
    const mergedCells = new Set()
    for (const m of merges) {
      if (m.layer !== layer) continue
      for (const mc of getMergeCells(m.layer, m.startRow, m.startCol, m.endRow, m.endCol)) {
        const cp = parseLocation(mc)
        if (cp) mergedCells.add(`${cp.row},${cp.col}`)
      }
    }

    const layerFree = []
    for (let r = 1; r <= Math.min(maxRow, GRID_ROWS); r++) {
      for (let c = 1; c <= Math.min(maxCol, GRID_COLS); c++) {
        const key = `${r},${c}`
        if (cells.has(key)) continue
        if (mergedCells.has(key)) continue // 被合并吞掉的格子不算空位
        layerFree.push(formatLocation({ layer, row: r, col: c }))
      }
    }

    layers.push({ layer, maxRow, maxCol, free: layerFree, usedCount: cells.size })
    free.push(...layerFree)
  }

  let maxLocation = ''
  if (layers.length > 0) {
    const last = layers[layers.length - 1]
    maxLocation = formatLocation({ layer: last.layer, row: last.maxRow, col: last.maxCol })
  }

  return { free, maxLocation, layers, unparsed }
}
