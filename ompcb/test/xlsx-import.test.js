// test/xlsx-import.test.js — xlsx BOM 解析
//
// 纯函数测试，不起服务、不碰数据库，与 designator/location 同一套模式。
// 测试用的 xlsx 在内存里用 SheetJS 现造，不依赖桌面上的模板文件——
// 那个文件不在仓库里，CI 或换台机器就跑不了。
//
// 造出的表头与真实模板完全一致（实测 A1:I38、36 条数据 + 1 空行）。
import test from 'node:test'
import assert from 'node:assert/strict'
import * as XLSX from 'xlsx'
import { parseXlsxBom } from '../web/xlsx-import.js'

/** 用二维数组造一个 xlsx 的 ArrayBuffer */
function makeXlsx(aoa) {
  const ws = XLSX.utils.aoa_to_sheet(aoa)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'Sheet1')
  return XLSX.write(wb, { type: 'array', bookType: 'xlsx' })
}

// 真实模板的表头（嘉立创/AD 导出的标准英文表头）
const HEADER = [
  'No.', 'Name', 'Designator', 'Footprint', 'Quantity',
  'Manufacturer Part', 'Manufacturer', 'Supplier', 'Supplier Part'
]

test('xlsx BOM 解析：标准模板', async (t) => {
  await t.test('表头按名称映射到 BOM 字段', () => {
    const buf = makeXlsx([
      HEADER,
      ['1', '10uF', 'C1,C10,C11', 'C0402', '3', 'HGC0402R5106M100NTEJ', 'Chinocera(华瓷)', 'LCSC', 'C7472949']
    ])
    const { rows, errors } = parseXlsxBom(buf)
    assert.equal(errors.length, 0)
    assert.equal(rows.length, 1)
    assert.deepEqual(rows[0], {
      seq: 1,
      name: '10uF',
      designator: 'C1,C10,C11',
      package: 'C0402',
      qty: 3,
      mfr_pn: 'HGC0402R5106M100NTEJ',
      mfr: 'Chinocera(华瓷)',
      supplier: 'LCSC',
      supplier_pn: 'C7472949'
    })
  })

  await t.test('末尾空行被跳过（SheetJS 的 blankrows:false 对此无效，必须自己挡）', () => {
    // 真实模板 A1:I38 就是 36 条数据 + 末尾一个空行，
    // 不挡住会导入一条名称为空的垃圾数据
    const buf = makeXlsx([
      HEADER,
      ['1', '10uF', 'C1', 'C0402', '1', 'PN1', 'MFR', 'LCSC', 'C1'],
      ['', '', '', '', '', '', '', '', '']
    ])
    const { rows, errors } = parseXlsxBom(buf)
    assert.equal(rows.length, 1, '空行不该产出数据')
    assert.equal(errors.length, 0, '空行是正常的表格留白，不该报成错误')
  })

  await t.test('中间空行同样跳过，不打断后续行', () => {
    const buf = makeXlsx([
      HEADER,
      ['1', '10uF', 'C1', 'C0402', '1', 'PN1', 'MFR', 'LCSC', 'C1'],
      ['', '', '', '', '', '', '', '', ''],
      ['2', '100nF', 'C2', 'C0402', '1', 'PN2', 'MFR', 'LCSC', 'C2']
    ])
    const { rows } = parseXlsxBom(buf)
    assert.equal(rows.length, 2)
    assert.deepEqual(rows.map(r => r.name), ['10uF', '100nF'])
  })

  await t.test('列序不敏感：认表头名而非位置', () => {
    // 模板改了列序也该能解析，否则每次导出工具调整列就得改代码
    const buf = makeXlsx([
      ['Name', 'Quantity', 'Designator', 'No.'],
      ['10uF', '3', 'C1,C2,C3', '7']
    ])
    const { rows } = parseXlsxBom(buf)
    assert.equal(rows.length, 1)
    assert.equal(rows[0].name, '10uF')
    assert.equal(rows[0].qty, 3)
    assert.equal(rows[0].designator, 'C1,C2,C3')
    assert.equal(rows[0].seq, 7)
  })

  await t.test('表头大小写与标点差异都容错', () => {
    // 'Manufacturer Part' / 'manufacturer_part' / 'MANUFACTURERPART' 应等价
    const buf = makeXlsx([
      ['no', 'NAME', 'designator', 'footprint', 'quantity', 'manufacturer_part', 'MANUFACTURER', 'supplier', 'Supplier-Part'],
      ['1', '10uF', 'C1', 'C0402', '1', 'PN1', 'MFR', 'LCSC', 'C1']
    ])
    const { rows, errors } = parseXlsxBom(buf)
    assert.equal(errors.length, 0)
    assert.equal(rows.length, 1)
    assert.equal(rows[0].mfr_pn, 'PN1')
    assert.equal(rows[0].supplier_pn, 'C1')
  })

  await t.test('不认识的额外列被忽略，不影响已知列', () => {
    const buf = makeXlsx([
      [...HEADER, 'Price', 'Note'],
      ['1', '10uF', 'C1', 'C0402', '1', 'PN1', 'MFR', 'LCSC', 'C1', '0.05', '随便写']
    ])
    const { rows, errors } = parseXlsxBom(buf)
    assert.equal(errors.length, 0)
    assert.equal(rows.length, 1)
    assert.equal(rows[0].name, '10uF')
  })

  await t.test('单元格值两侧空格被裁掉', () => {
    const buf = makeXlsx([
      HEADER,
      ['1', '  10uF  ', ' C1,C2 ', ' C0402 ', '2', ' PN1 ', ' MFR ', ' LCSC ', ' C1 ']
    ])
    const { rows } = parseXlsxBom(buf)
    assert.equal(rows[0].name, '10uF')
    assert.equal(rows[0].designator, 'C1,C2')
    assert.equal(rows[0].mfr_pn, 'PN1')
  })
})

test('xlsx BOM 解析：异常与边界', async (t) => {
  await t.test('缺少必需列时明确报错而不是静默产出空数据', () => {
    // 没有 Name 列：与其导入一堆空名称的行，不如直接说清缺什么
    const buf = makeXlsx([
      ['No.', 'Designator', 'Quantity'],
      ['1', 'C1', '1']
    ])
    const { rows, errors } = parseXlsxBom(buf)
    assert.equal(rows.length, 0)
    assert.ok(errors.length > 0)
    assert.ok(String(errors[0]).includes('name'), '应指明缺的是哪一列')
  })

  await t.test('名称为空的行跳过并记入 errors', () => {
    const buf = makeXlsx([
      HEADER,
      ['1', '', 'C1', 'C0402', '1', 'PN1', 'MFR', 'LCSC', 'C1'],
      ['2', '100nF', 'C2', 'C0402', '1', 'PN2', 'MFR', 'LCSC', 'C2']
    ])
    const { rows, errors } = parseXlsxBom(buf)
    assert.equal(rows.length, 1, '只有有名称的那行进得来')
    assert.equal(rows[0].name, '100nF')
    assert.equal(errors.length, 1, '被跳过的行要如实汇报，不能静默丢')
    assert.ok(errors[0].row, '错误里要带行号，便于用户回表格核对')
  })

  await t.test('数量非法的行跳过并记入 errors', () => {
    const buf = makeXlsx([
      HEADER,
      ['1', '10uF', 'C1', 'C0402', 'abc', 'PN1', 'MFR', 'LCSC', 'C1'],
      ['2', '100nF', 'C2', 'C0402', '-5', 'PN2', 'MFR', 'LCSC', 'C2'],
      ['3', '1uF', 'C3', 'C0402', '2', 'PN3', 'MFR', 'LCSC', 'C3']
    ])
    const { rows, errors } = parseXlsxBom(buf)
    assert.equal(rows.length, 1)
    assert.equal(rows[0].name, '1uF')
    assert.equal(errors.length, 2)
  })

  await t.test('数量为 0 是合法的（占位料/暂不采购）', () => {
    // 0 与「非法值」不同：BOM 里确实会有暂不装配的行
    const buf = makeXlsx([
      HEADER,
      ['1', '10uF', 'C1', 'C0402', '0', 'PN1', 'MFR', 'LCSC', 'C1']
    ])
    const { rows, errors } = parseXlsxBom(buf)
    assert.equal(rows.length, 1)
    assert.equal(rows[0].qty, 0)
    assert.equal(errors.length, 0)
  })

  await t.test('只有表头没有数据时返回空数组而不报错', () => {
    const { rows, errors } = parseXlsxBom(makeXlsx([HEADER]))
    assert.deepEqual(rows, [])
    assert.equal(errors.length, 0)
  })

  await t.test('可选字段缺失时填空串，不影响导入', () => {
    // 只有 Name + Quantity 两个必需列
    const buf = makeXlsx([
      ['Name', 'Quantity'],
      ['结构件', '1']
    ])
    const { rows, errors } = parseXlsxBom(buf)
    assert.equal(errors.length, 0)
    assert.equal(rows.length, 1)
    assert.equal(rows[0].name, '结构件')
    assert.equal(rows[0].designator, '', '没有位号列时应为空串而不是 undefined')
    assert.equal(rows[0].package, '')
    assert.equal(rows[0].mfr_pn, '')
    assert.equal(rows[0].seq, 0)
  })

  await t.test('Ω / μ 等特殊字符原样保留', () => {
    // 这些字符是电子物料名称的常态，归一化归搜索层管，解析层不该改写数据
    const buf = makeXlsx([
      HEADER,
      ['1', '1kΩ', 'R1', 'R0402', '1', 'PN1', 'MFR', 'LCSC', 'C1'],
      ['2', '10μF', 'C1', 'C0402', '1', 'PN2', 'MFR', 'LCSC', 'C2']
    ])
    const { rows } = parseXlsxBom(buf)
    assert.equal(rows[0].name, '1kΩ')
    assert.equal(rows[1].name, '10μF')
  })

  await t.test('数量为小数时取整（Excel 里可能存成 2.0）', () => {
    const buf = makeXlsx([
      HEADER,
      ['1', '10uF', 'C1,C2', 'C0402', '2.0', 'PN1', 'MFR', 'LCSC', 'C1']
    ])
    const { rows } = parseXlsxBom(buf)
    assert.equal(rows[0].qty, 2)
  })
})

test('xlsx BOM 解析：与位号口径一致', async (t) => {
  await t.test('Quantity 与位号个数一致的模板能原样导入', async () => {
    // 实测真实模板 36 行全部满足 Quantity === 位号个数，
    // 这也是单行出库按位号计数的前提。解析不该改动任何一方。
    const { countDesignators } = await import('../web/designator.js')
    const buf = makeXlsx([
      HEADER,
      ['1', '10uF', 'C1,C10,C11', 'C0402', '3', 'PN1', 'MFR', 'LCSC', 'C1'],
      ['2', '100nF', 'C2,C7,C8,C12,C14,C23', 'C0402', '6', 'PN2', 'MFR', 'LCSC', 'C2']
    ])
    const { rows } = parseXlsxBom(buf)
    for (const r of rows) {
      assert.equal(countDesignators(r.designator), r.qty, `${r.name} 的位号个数应等于数量`)
    }
  })
})
