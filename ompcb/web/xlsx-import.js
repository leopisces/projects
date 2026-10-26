// web/xlsx-import.js — 从 xlsx 文件读取 BOM 数据
//
// 纯函数，无 Vue 依赖，与 designator.js / location.js 同一套测试模式。
// 用 SheetJS 的 xlsx 库解析，输入是 ArrayBuffer 或 Uint8Array。
//
// 模板表头 → BOM 字段映射（实测 37 行数据，全部一致）：
//   No.             → seq
//   Name            → name
//   Designator      → designator
//   Footprint       → package
//   Quantity        → qty
//   Manufacturer Part → mfr_pn
//   Manufacturer    → mfr
//   Supplier        → supplier
//   Supplier Part   → supplier_pn
//
// 表头名称不区分大小写、冒号/空格/连字符都容错，所以
// 'Manufacturer Part' / 'ManufacturerPart' / 'manufacturer_part' 都能命中。
// 列序不敏感：认表头名而不是位置，即使模板改列序也能解析。

import * as XLSX from 'xlsx'

/** 英文表头 → BOM 字段，不区分大小写与标点符号差异 */
const HEADER_MAP = {
  'no': 'seq',
  '序号': 'seq',
  'name': 'name',
  '名称': 'name',
  'designator': 'designator',
  '位号': 'designator',
  'footprint': 'package',
  '封装': 'package',
  'quantity': 'qty',
  '数量': 'qty',
  'manufacturerpart': 'mfr_pn',
  '制造商料号': 'mfr_pn',
  'manufacturer': 'mfr',
  '制造商': 'mfr',
  'supplier': 'supplier',
  '供应商': 'supplier',
  'supplierpart': 'supplier_pn',
  '供应商料号': 'supplier_pn',
}

/**
 * 把表头字符串归一成比较键：去空格/连字符/下划线/冒号后转小写。
 * 这样 'Manufacturer Part' / 'ManufacturerPart' / 'manufacturer_part' 都归一为 'manufacturerpart'。
 */
function headerKey(raw) {
  return String(raw ?? '')
    .normalize('NFKC')
    .replace(/[\s\-_:.]+/g, '')
    .toLowerCase()
}

/**
 * 解析 xlsx 文件为 BOM 行数组。
 *
 * @param {ArrayBuffer|Uint8Array} data 文件二进制数据
 * @param {object} [options]
 * @param {number} [options.headerRow=1] 表头所在行号（1-based）
 * @returns {{ rows: Array<object>, errors: Array<{ row: number, error: string }>, total: number }}
 *   rows 每项含 { seq, name, designator, package, qty, mfr_pn, mfr, supplier, supplier_pn }
 *   total 是解析到的总行数（含被跳过的空行；不含表头）
 */
export function parseXlsxBom(data, { headerRow = 1 } = {}) {
  const wb = XLSX.read(data, { type: 'array', dense: false })
  const ws = wb.Sheets[wb.SheetNames[0]]
  if (!ws) return { rows: [], errors: [], total: 0 }

  // 用 SheetJS 的 sheet_to_json 把表头行当键，自动跳过空行
  const raw = XLSX.utils.sheet_to_json(ws, {
    header: 1,           // 关掉默认的 header 映射，我们要自己处理
    defval: '',
    blankrows: false,    // 跳过整行空白的
  })

  if (!raw.length || headerRow < 1 || headerRow > raw.length) {
    return { rows: [], errors: [], total: 0 }
  }

  // 解析表头
  const headerRowCells = raw[headerRow - 1] || []
  const colIndex = {} // BOM field -> column index
  const unmappedCols = [] // 表头里不认识的列名，记下来但不报错

  headerRowCells.forEach((cell, i) => {
    const key = headerKey(String(cell ?? ''))
    if (!key) return
    if (HEADER_MAP[key]) {
      colIndex[HEADER_MAP[key]] = i
    } else {
      unmappedCols.push({ col: i, header: String(cell) })
    }
  })

  // 检查必填列
  const required = ['name', 'qty']
  const missing = required.filter(f => colIndex[f] === undefined)
  if (missing.length) {
    return {
      rows: [],
      errors: missing.map(f => `缺少必需的列：${f}`),
      total: 0,
    }
  }

  // 解析数据行
  const rows = []
  const errors = []
  const dataStart = headerRow // 表头之后第一行就是数据

  for (let i = dataStart; i < raw.length; i++) {
    const cells = raw[i] || []
    const rowNum = i + 1

    // 跳过全空行（sheet_to_json 的 blankrows:false 已经做了，但双重保险）
    const hasValue = cells.some(c => String(c ?? '').trim() !== '')
    if (!hasValue) continue

    // 提取字段
    const name = String(cells[colIndex.name] ?? '').trim()
    const qtyRaw = String(cells[colIndex.qty] ?? '').trim()

    // 名称和数量是必填
    if (!name) {
      errors.push({ row: rowNum, error: '名称为空，已跳过' })
      continue
    }
    const qty = parseInt(qtyRaw, 10)
    if (isNaN(qty) || qty < 0) {
      errors.push({ row: rowNum, error: `数量无效: "${qtyRaw}"，已跳过` })
      continue
    }

    rows.push({
      seq: Number(cells[colIndex.seq]) || 0,
      name,
      designator: String(cells[colIndex.designator] ?? '').trim(),
      package: String(cells[colIndex.package] ?? '').trim(),
      qty,
      mfr_pn: String(cells[colIndex.mfr_pn] ?? '').trim(),
      mfr: String(cells[colIndex.mfr] ?? '').trim(),
      supplier: String(cells[colIndex.supplier] ?? '').trim(),
      supplier_pn: String(cells[colIndex.supplier_pn] ?? '').trim(),
    })
  }

  return { rows, errors, total: rows.length }
}