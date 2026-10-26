// test/bom-display.test.js — 绑定行的四列显示口径
//
// 纯函数测试，不起服务、不碰数据库（同 designator.test.js）。
//
// 这里锁的是**读取侧口径**，与 bom-products.test.js 里的「绑定原值快照」
// 互补：那边验后端存了什么（src_* 快照、bound_at、绝不把 i.* 写进 BOM），
// 这边验前端把这些列合并成用户看到的什么。
//
// 为什么值得单测：表格渲染与 CSV 导出共用这一套函数。若哪天有人在
// MaterialTable.vue 里就地改了显示逻辑而漏了 CSV（或反之），
// 界面与导出就会不一致 —— 而这类 bug 在 UI 上完全看不出来。
import test from 'node:test'
import assert from 'node:assert/strict'
import { BOUND_FIELDS, isBound, boundValue, sourceValue } from '../web/bom-display.js'

/** 造一行 listMaterials 形状的数据；只关心这四列相关的字段 */
function row(overrides = {}) {
  return {
    mfr_pn: 'BOM-PN',
    mfr: 'BOM厂商',
    supplier: 'BOM供应商',
    supplier_pn: 'BOM-SPN',
    inventory_mfr_pn: 'INV-PN',
    inventory_mfr: 'INV厂商',
    inventory_supplier: 'INV供应商',
    inventory_supplier_pn: 'INV-SPN',
    src_mfr_pn: '',
    src_mfr: '',
    src_supplier: '',
    src_supplier_pn: '',
    bound_at: null,
    ...overrides
  }
}

const KEYS = Object.keys(BOUND_FIELDS)

test('绑定显示：isBound 判定', async (t) => {
  await t.test('bound_at 为 NULL / 空串 / 空格 都算未绑定', () => {
    assert.equal(isBound(row({ bound_at: null })), false)
    assert.equal(isBound(row({ bound_at: undefined })), false)
    assert.equal(isBound(row({ bound_at: '' })), false)
    assert.equal(isBound(row({ bound_at: '   ' })), false)
  })

  await t.test('bound_at 有时间戳算已绑定', () => {
    assert.equal(isBound(row({ bound_at: '2026-09-01 10:00:00' })), true)
  })

  await t.test('row 为空不抛异常', () => {
    assert.equal(isBound(null), false)
    assert.equal(isBound(undefined), false)
  })
})

test('绑定显示：未绑定的行完全按原样', async (t) => {
  // 关键口径：按料号自动 JOIN 到的行也会带 inventory_*，但那是系统推断，
  // 不是用户意图，绝不能改写显示值。否则导入完还没绑过任何东西，
  // 表格里的制造商就已经和 Excel 里不一样了。
  await t.test('四列都返回 BOM 自有值，即便 inventory_* 有值', () => {
    const r = row({ bound_at: null })
    assert.equal(boundValue(r, 'mfr_pn'), 'BOM-PN')
    assert.equal(boundValue(r, 'mfr'), 'BOM厂商')
    assert.equal(boundValue(r, 'supplier'), 'BOM供应商')
    assert.equal(boundValue(r, 'supplier_pn'), 'BOM-SPN')
  })

  await t.test('未绑定行没有原值可言，sourceValue 一律空', () => {
    const r = row({ bound_at: null, src_mfr: '不该被读到' })
    for (const key of KEYS) {
      assert.equal(sourceValue(r, key), '')
    }
  })
})

test('绑定显示：已绑定的行取库存值', async (t) => {
  const bound = { bound_at: '2026-09-01 10:00:00' }

  await t.test('四列全部换成库存值', () => {
    const r = row(bound)
    assert.equal(boundValue(r, 'mfr_pn'), 'INV-PN')
    assert.equal(boundValue(r, 'mfr'), 'INV厂商')
    assert.equal(boundValue(r, 'supplier'), 'INV供应商')
    assert.equal(boundValue(r, 'supplier_pn'), 'INV-SPN')
  })

  await t.test('库存值为空则回退 BOM 自有值', () => {
    // 台账里 supplier / supplier_pn 经常没填，显示成空等于凭空丢信息
    const r = row({ ...bound, inventory_supplier: '', inventory_supplier_pn: null })
    assert.equal(boundValue(r, 'supplier'), 'BOM供应商')
    assert.equal(boundValue(r, 'supplier_pn'), 'BOM-SPN')
    // 其余两列不受影响
    assert.equal(boundValue(r, 'mfr'), 'INV厂商')
  })

  await t.test('库存值是纯空格也视为空并回退', () => {
    const r = row({ ...bound, inventory_mfr: '   ' })
    assert.equal(boundValue(r, 'mfr'), 'BOM厂商')
  })

  await t.test('两边都空则返回空串，由调用方决定占位符', () => {
    const r = row({ ...bound, inventory_mfr: '', mfr: '' })
    assert.equal(boundValue(r, 'mfr'), '')
  })
})

test('绑定显示：原导入值来自 src_* 快照', async (t) => {
  const bound = { bound_at: '2026-09-01 10:00:00' }

  await t.test('返回快照值，而不是当前 BOM 值', () => {
    // 绑定会覆盖 mfr_pn，所以 row.mfr_pn 已经是库存料号了；
    // 「原导入值」只能从 src_mfr_pn 拿
    const r = row({ ...bound, mfr_pn: 'INV-PN', src_mfr_pn: '导入时的料号' })
    assert.equal(sourceValue(r, 'mfr_pn'), '导入时的料号')
    assert.notEqual(sourceValue(r, 'mfr_pn'), r.mfr_pn)
  })

  await t.test('快照为空返回空串（不回退，也不猜）', () => {
    // 两种情况都归这里：导入时本来就空 / 加快照列之前就绑过的老数据。
    // 回退成当前值会把"库存值"谎报成"原导入值"，比显示不出来更糟。
    const r = row({ ...bound, src_mfr: '' })
    assert.equal(sourceValue(r, 'mfr'), '')
  })

  await t.test('四列各取各自的快照列，不串位', () => {
    const r = row({
      ...bound,
      src_mfr_pn: 'S-PN',
      src_mfr: 'S-MFR',
      src_supplier: 'S-SUP',
      src_supplier_pn: 'S-SPN'
    })
    assert.equal(sourceValue(r, 'mfr_pn'), 'S-PN')
    assert.equal(sourceValue(r, 'mfr'), 'S-MFR')
    assert.equal(sourceValue(r, 'supplier'), 'S-SUP')
    assert.equal(sourceValue(r, 'supplier_pn'), 'S-SPN')
  })
})

test('绑定显示：非这四列的字段原样透传', async (t) => {
  // CSV 导出对所有列无脑调用 boundValue，所以其余列必须等价于 row[key]
  const bound = { bound_at: '2026-09-01 10:00:00' }

  await t.test('name / package / remark 等不受绑定影响', () => {
    const r = { ...row(bound), name: '1MΩ', package: 'R0402', remark: '备注' }
    assert.equal(boundValue(r, 'name'), '1MΩ')
    assert.equal(boundValue(r, 'package'), 'R0402')
    assert.equal(boundValue(r, 'remark'), '备注')
  })

  await t.test('数字列转成字符串但不改值', () => {
    // csvCell 自己会 String()，这里只要保证数字不被吞成空
    const r = { ...row(bound), qty: 0, stock: 12, shortage: 3 }
    assert.equal(boundValue(r, 'qty'), '0')
    assert.equal(boundValue(r, 'stock'), '12')
    assert.equal(boundValue(r, 'shortage'), '3')
  })

  await t.test('缺失的列返回空串', () => {
    assert.equal(boundValue(row(bound), 'location'), '')
    assert.equal(sourceValue(row(bound), 'location'), '')
  })
})

test('绑定显示：BOUND_FIELDS 映射与后端别名一致', () => {
  // selectWithStock 里的别名是 inventory_<列名>，快照列是 src_<列名>。
  // 手写映射容易串位，这里按规则反推校验一遍。
  for (const [key, field] of Object.entries(BOUND_FIELDS)) {
    assert.equal(field.inv, `inventory_${key}`, `${key} 的库存别名不符合命名规则`)
    assert.equal(field.src, `src_${key}`, `${key} 的快照列不符合命名规则`)
    assert.ok(field.label, `${key} 缺中文标签`)
  }
  // 只有这四列参与合并 —— 多了就意味着有人把库存数据往 BOM 别的列上搬
  assert.deepEqual(
    Object.keys(BOUND_FIELDS).sort(),
    ['mfr', 'mfr_pn', 'supplier', 'supplier_pn']
  )
})
