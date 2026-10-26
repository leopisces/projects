// BOM 产品化 + 按制造商料号动态关联库存
import { test, before, after, describe } from 'node:test'
import assert from 'node:assert/strict'
import { createTestServer } from './helpers.js'

let srv
let call
/** 默认产品（由 migrate-products.js 从种子数据自动归集） */
let product

before(async () => {
  srv = await createTestServer()
  call = srv.call
  const { data } = await call('/api/products')
  product = data.list.find(p => p.code === 'AGB_CPU_03')
})

after(() => srv?.cleanup())

describe('产品', () => {
  test('种子数据自动归入默认产品 AGB_CPU_03', () => {
    assert.ok(product, '默认产品应存在')
    assert.equal(product.bomLines, 75, 'BOM 应有 75 行')
  })

  test('产品汇总带匹配与缺料统计', () => {
    // 具体匹配数取决于种子数据与库存台账，不硬编码；
    // 关键是"匹配 + 未匹配 = 总行数"这个恒等关系必须成立。
    assert.ok(product.matchedLines > 0, '应有能匹配到库存的行')
    assert.ok(product.unmatchedLines > 0, '应有无料号/查无此料的行')
    assert.equal(
      product.matchedLines + product.unmatchedLines,
      product.bomLines,
      '匹配 + 未匹配 必须等于 BOM 总行数'
    )
  })

  test('新建产品', async () => {
    const { status, data } = await call('/api/products', {
      method: 'POST',
      body: { code: 'P_NEW', name: '新产品' }
    })
    assert.equal(status, 201)
    assert.equal(data.code, 'P_NEW')
  })

  test('产品编号重复返回 409', async () => {
    const { status } = await call('/api/products', { method: 'POST', body: { code: 'P_NEW' } })
    assert.equal(status, 409)
  })

  test('产品编号为空返回 400', async () => {
    const { status } = await call('/api/products', { method: 'POST', body: { name: '没编号' } })
    assert.equal(status, 400)
  })

  test('重命名产品', async () => {
    const created = (await call('/api/products', { method: 'POST', body: { code: 'P_RENAME' } })).data
    const { status, data } = await call(`/api/products/${created.id}`, {
      method: 'PUT',
      body: { code: 'P_RENAMED', name: '改过名' }
    })
    assert.equal(status, 200)
    assert.equal(data.code, 'P_RENAMED')
  })
})

describe('BOM 字段归属', () => {
  test('BOM 自有 10 个字段', async () => {
    const { data } = await call(`/api/materials?productId=${product.id}&pageSize=1&sortBy=seq`)
    const row = data.list[0]
    for (const f of [
      'seq', 'name', 'designator', 'package', 'qty',
      'mfr_pn', 'mfr', 'supplier', 'supplier_pn', 'remark'
    ]) {
      assert.ok(f in row, `BOM 应自带字段 ${f}`)
    }
  })

  test('状态/库存/位置由库存台账动态带出', async () => {
    const { data } = await call(`/api/materials?productId=${product.id}&matchState=matched&pageSize=1`)
    const row = data.list[0]
    assert.notEqual(row.inventory_id, null, '匹配上的行应有 inventory_id')
    assert.equal(typeof row.stock, 'number', '库存来自 inventory')
    assert.equal(typeof row.status, 'string', '状态来自 inventory')
    assert.equal(typeof row.location, 'string', '位置来自 inventory')
  })

  test('未匹配到库存时状态/库存/位置为 null', async () => {
    const { data } = await call(`/api/materials?productId=${product.id}&matchState=unmatched&pageSize=1`)
    const row = data.list[0]
    assert.equal(row.inventory_id, null)
    assert.equal(row.stock, null, '查无此料则无库存值')
    assert.equal(row.status, null)
  })

  test('PUT 不能改 status/stock/location（这些属于库存台账）', async () => {
    const row = (await call(`/api/materials?productId=${product.id}&pageSize=1`)).data.list[0]
    const { status } = await call(`/api/materials/${row.id}`, {
      method: 'PUT',
      body: { status: '缺货', stock: 9999, location: '伪造位置' }
    })
    assert.equal(status, 400, '只传库存字段应报"没有需要更新的字段"')
  })
})

describe('按 mfr_pn 动态关联库存', () => {
  test('库存变动后 BOM 立即反映，无需维护关联', async () => {
    const row = (await call(`/api/materials?productId=${product.id}&matchState=matched&pageSize=1`)).data.list[0]
    const before = row.stock

    const mv = await call(`/api/inventory/${row.inventory_id}/move`, {
      method: 'POST',
      body: { type: '入库', qty: 7, remark: '联动测试' }
    })
    assert.equal(mv.status, 200)

    const after = (await call(`/api/materials/${row.id}`)).data
    assert.equal(after.stock, before + 7, 'BOM 行应读到最新库存')

    // 还原
    await call(`/api/inventory/${row.inventory_id}/move`, {
      method: 'POST',
      body: { type: '出库', qty: 7 }
    })
    const restored = (await call(`/api/materials/${row.id}`)).data
    assert.equal(restored.stock, before, '还原后 BOM 同步还原')
  })

  test('缺料按套数计算：需求 = 用量 × 套数', async () => {
    const { data } = await call(`/api/materials?productId=${product.id}&matchState=matched&pageSize=500`)
    for (const row of data.list) {
      const expected = Math.max(row.qty - row.stock, 0)
      assert.equal(row.shortage, expected, `${row.name} 单套缺料应为 ${expected}`)
      assert.equal(row.required, row.qty, '1 套时需求量等于用量')
    }
  })

  test('未匹配或库里没有的行也要算缺料（可用库存按 0）', async () => {
    const { data } = await call(`/api/materials?productId=${product.id}&matchState=unmatched&pageSize=500`)
    assert.ok(data.list.length > 0, '应存在未匹配的行')
    for (const row of data.list) {
      assert.equal(row.stock, null, '未匹配则没有库存值')
      assert.equal(
        row.shortage,
        row.qty,
        `${row.name} 未匹配到库存，应按全缺算（不能是 null）`
      )
      assert.notEqual(row.shortage, null, '缺料不能为 null，否则无法知道要买多少')
    }
  })

  test('matchState 三种筛选口径正确', async () => {
    const matched = (await call(`/api/materials?productId=${product.id}&matchState=matched&pageSize=500`)).data
    const unmatched = (await call(`/api/materials?productId=${product.id}&matchState=unmatched&pageSize=500`)).data
    const shortage = (await call(`/api/materials?productId=${product.id}&matchState=shortage&pageSize=500`)).data

    assert.ok(matched.list.every(x => x.inventory_id !== null))
    assert.ok(unmatched.list.every(x => x.inventory_id === null))
    assert.ok(shortage.list.every(x => x.shortage > 0))
    assert.equal(matched.total + unmatched.total, 75, '匹配+未匹配应等于总行数')
  })

  test('可按库存与缺料排序（JOIN 派生列）', async () => {
    const asc = (await call(`/api/materials?productId=${product.id}&sortBy=shortage&sortOrder=desc&pageSize=5`)).data
    assert.equal(asc.list.length, 5)
    const shortages = asc.list.map(x => x.shortage ?? -1)
    const sorted = [...shortages].sort((a, b) => b - a)
    assert.deepEqual(shortages, sorted, 'shortage 降序应生效')
  })

  test('非法排序列安全回落，不报错', async () => {
    const { status } = await call(
      `/api/materials?productId=${product.id}&sortBy=stock;DROP TABLE materials--`
    )
    assert.equal(status, 200)
  })
})

describe('制作套数（缺料算法）', () => {
  test('默认按 1 套算', async () => {
    const { data } = await call(`/api/materials?productId=${product.id}&pageSize=1`)
    assert.equal(data.sets, 1)
    assert.equal(data.list[0].required, data.list[0].qty)
  })

  test('sets=10 时需求量翻 10 倍', async () => {
    const { data } = await call(`/api/materials?productId=${product.id}&sets=10&pageSize=500`)
    assert.equal(data.sets, 10)
    for (const row of data.list) {
      assert.equal(row.required, row.qty * 10, `${row.name} 需求量应为用量×10`)
      const available = row.stock ?? 0
      assert.equal(
        row.shortage,
        Math.max(row.qty * 10 - available, 0),
        `${row.name} 缺料应为 需求−库存`
      )
    }
  })

  test('套数越多缺料项越多（不会变少）', async () => {
    const one = (await call(`/api/materials/stats?productId=${product.id}&sets=1`)).data
    const ten = (await call(`/api/materials/stats?productId=${product.id}&sets=10`)).data
    assert.ok(ten.shortage >= one.shortage, '缺料项数不应随套数增加而减少')
    assert.ok(ten.shortageQty > one.shortageQty, '缺料总数应随套数增加')
    assert.equal(ten.totalRequired, one.totalQty * 10, '总需求应为总用量×10')
  })

  test('缺料筛选随套数变化', async () => {
    const one = (await call(`/api/materials?productId=${product.id}&matchState=shortage&sets=1&pageSize=500`)).data
    const ten = (await call(`/api/materials?productId=${product.id}&matchState=shortage&sets=10&pageSize=500`)).data
    assert.ok(ten.total >= one.total, '套数增加后缺料行不应减少')
    assert.ok(one.list.every(x => x.shortage > 0))
    assert.ok(ten.list.every(x => x.shortage > 0))
  })

  test('汇总的缺料总数等于逐行缺料之和', async () => {
    const sets = 7
    const stats = (await call(`/api/materials/stats?productId=${product.id}&sets=${sets}`)).data
    const rows = (await call(`/api/materials?productId=${product.id}&sets=${sets}&pageSize=500`)).data.list
    const sum = rows.reduce((acc, r) => acc + (r.shortage || 0), 0)
    assert.equal(stats.shortageQty, sum, '汇总与逐行必须一致')
    assert.equal(stats.shortage, rows.filter(r => r.shortage > 0).length, '缺料项数应一致')
  })

  test('非法套数回落为 1', async () => {
    for (const bad of ['0', '-5', 'abc', '']) {
      const { data } = await call(`/api/materials?productId=${product.id}&sets=${bad}&pageSize=1`)
      assert.equal(data.sets, 1, `sets=${bad} 应回落为 1`)
    }
  })

  test('套数上限保护', async () => {
    const { data } = await call(`/api/materials?productId=${product.id}&sets=999999&pageSize=1`)
    assert.ok(data.sets <= 9999, `套数应被限制在上限内，实际 ${data.sets}`)
  })
})

describe('产品隔离', () => {
  let pidA
  let pidB

  before(async () => {
    pidA = (await call('/api/products', { method: 'POST', body: { code: 'ISO_A' } })).data.id
    pidB = (await call('/api/products', { method: 'POST', body: { code: 'ISO_B' } })).data.id
  })

  test('不同产品可使用相同位号', async () => {
    const a = await call('/api/materials', {
      method: 'POST',
      body: { product_id: pidA, name: '电阻A', designator: 'R1', qty: 1 }
    })
    const b = await call('/api/materials', {
      method: 'POST',
      body: { product_id: pidB, name: '电阻B', designator: 'R1', qty: 1 }
    })
    assert.equal(a.status, 201)
    assert.equal(b.status, 201, '不同产品用同一位号 R1 不应冲突')
  })

  test('同产品内位号重复返回 409', async () => {
    const { status } = await call('/api/materials', {
      method: 'POST',
      body: { product_id: pidA, name: '重复', designator: 'R1', qty: 1 }
    })
    assert.equal(status, 409)
  })

  test('新增必须指定产品', async () => {
    const { status, data } = await call('/api/materials', {
      method: 'POST',
      body: { name: '没产品', qty: 1 }
    })
    assert.equal(status, 400)
    assert.match(data.error, /产品/)
  })

  test('指定不存在的产品返回 400', async () => {
    const { status } = await call('/api/materials', {
      method: 'POST',
      body: { product_id: 999999, name: '幽灵产品', qty: 1 }
    })
    assert.equal(status, 400)
  })

  test('列表按产品隔离', async () => {
    const a = (await call(`/api/materials?productId=${pidA}&pageSize=100`)).data
    const b = (await call(`/api/materials?productId=${pidB}&pageSize=100`)).data
    assert.ok(a.list.every(x => x.product_id === pidA))
    assert.ok(b.list.every(x => x.product_id === pidB))
  })
})

describe('批量导入', () => {
  let pid

  before(async () => {
    pid = (await call('/api/products', { method: 'POST', body: { code: 'BULK_P' } })).data.id
  })

  test('导入到指定产品，空名称行跳过', async () => {
    const { status, data } = await call('/api/materials/bulk', {
      method: 'POST',
      body: {
        productId: pid,
        mode: 'append',
        rows: [
          { seq: 1, name: '电容', designator: 'C1', qty: 5, mfr_pn: 'CL05B104KB54PNC' },
          { seq: 2, name: '', designator: 'X9', qty: 1 }
        ]
      }
    })
    assert.equal(status, 200)
    assert.equal(data.inserted, 1)
    assert.equal(data.skipped, 1)
  })

  test('导入的行自动按 mfr_pn 匹配到库存', async () => {
    const { data } = await call(`/api/materials?productId=${pid}&pageSize=100`)
    const c1 = data.list.find(x => x.designator === 'C1')
    assert.notEqual(c1.inventory_id, null, 'CL05B104KB54PNC 应匹配到库存')
    assert.equal(typeof c1.stock, 'number')
  })

  test('未指定 productId 返回 400', async () => {
    const { status } = await call('/api/materials/bulk', {
      method: 'POST',
      body: { rows: [{ name: 'X' }] }
    })
    assert.equal(status, 400)
  })

  test('mode=replace 只清空本产品，不影响其他产品', async () => {
    const otherBefore = (await call(`/api/materials?productId=${product.id}&pageSize=1`)).data.total

    const { data } = await call('/api/materials/bulk', {
      method: 'POST',
      body: {
        productId: pid,
        mode: 'replace',
        rows: [{ seq: 1, name: '替换后唯一行', designator: 'R99', qty: 1 }]
      }
    })
    assert.equal(data.inserted, 1)
    assert.ok(data.removed >= 1, 'replace 应清掉本产品旧行')

    const mine = (await call(`/api/materials?productId=${pid}&pageSize=100`)).data
    assert.equal(mine.total, 1, '本产品只剩替换后的 1 行')

    const otherAfter = (await call(`/api/materials?productId=${product.id}&pageSize=1`)).data.total
    assert.equal(otherAfter, otherBefore, '其他产品 BOM 绝不能被 replace 波及')
  })
})

describe('删除产品', () => {
  test('带 BOM 的产品默认拒绝删除', async () => {
    const pid = (await call('/api/products', { method: 'POST', body: { code: 'DEL_GUARD' } })).data.id
    await call('/api/materials', {
      method: 'POST',
      body: { product_id: pid, name: '挡删除', designator: 'D1', qty: 1 }
    })

    const { status, data } = await call(`/api/products/${pid}`, { method: 'DELETE' })
    assert.equal(status, 409)
    assert.equal(data.bomLines, 1)
  })

  test('withBom=1 连同 BOM 一起删除', async () => {
    const pid = (await call('/api/products', { method: 'POST', body: { code: 'DEL_FORCE' } })).data.id
    await call('/api/materials', {
      method: 'POST',
      body: { product_id: pid, name: '一起删', designator: 'D2', qty: 1 }
    })

    const { status, data } = await call(`/api/products/${pid}?withBom=1`, { method: 'DELETE' })
    assert.equal(status, 200)
    assert.equal(data.removedBom, 1)

    const gone = await call(`/api/products/${pid}`)
    assert.equal(gone.status, 404)
  })

  test('空产品可直接删除', async () => {
    const pid = (await call('/api/products', { method: 'POST', body: { code: 'DEL_EMPTY' } })).data.id
    const { status } = await call(`/api/products/${pid}`, { method: 'DELETE' })
    assert.equal(status, 200)
  })
})

describe('BOM 汇总', () => {
  test('按产品统计匹配与缺料', async () => {
    const { data } = await call(`/api/materials/stats?productId=${product.id}`)
    assert.equal(data.total, 75)
    assert.equal(
      data.matchedLines + data.unmatchedLines,
      data.total,
      '匹配 + 未匹配 必须等于总行数'
    )
    assert.equal(typeof data.totalQty, 'number')
    assert.ok(Array.isArray(data.statusCounts))
  })

  test('未匹配的行在状态分布里归为"未匹配"', async () => {
    const { data } = await call(`/api/materials/stats?productId=${product.id}`)
    const unmatched = data.statusCounts.find(s => s.status === '未匹配')
    assert.ok(unmatched, '应有"未匹配"分组')

    // statusCounts 的"未匹配"只统计 JOIN 不上库存的行；
    // unmatchedLines 还额外包含"有料号但库存里查无此料"的情况，
    // 两者在语义上一致，这里直接比对以防口径漂移。
    assert.equal(unmatched.count, data.unmatchedLines, '两处未匹配口径应一致')
  })

  test('状态分布各组之和等于总行数', async () => {
    const { data } = await call(`/api/materials/stats?productId=${product.id}`)
    const sum = data.statusCounts.reduce((acc, s) => acc + s.count, 0)
    assert.equal(sum, data.total)
  })
})

describe('BOM 关键词检索', () => {
  test('名称 + 封装组合检索（空格分词，跨列 AND）', async () => {
    // 种子第 19 行：名称 04381.25WR / 封装 F0603，分处两列。
    const { status, data } = await call(
      `/api/materials?productId=${product.id}&q=${encodeURIComponent('04381.25WR F0603')}&pageSize=50`
    )
    assert.equal(status, 200)
    assert.ok(data.total >= 1, '「名称 封装」组合应能查到')
    assert.ok(data.list.every(r => r.package.includes('F0603')), '每行都应命中封装词')
  })

  test('位号 + 封装组合检索', async () => {
    // 分词是通用机制，不限于「名称+封装」这一种组合
    const { data } = await call(
      `/api/materials?productId=${product.id}&q=${encodeURIComponent('F1 F0603')}&pageSize=50`
    )
    assert.ok(data.total >= 1)
  })

  test('组合检索结果 ⊆ 单词检索结果', async () => {
    const one = (await call(`/api/materials?productId=${product.id}&q=F0603&pageSize=500`)).data
    const two = (
      await call(
        `/api/materials?productId=${product.id}&q=${encodeURIComponent('F0603 04381.25WR')}&pageSize=500`
      )
    ).data
    assert.ok(two.total <= one.total, 'AND 语义必须收窄结果')
    assert.ok(two.total >= 1)
  })

  test('组合检索与产品筛选叠加，不越过产品边界', async () => {
    const { data } = await call(
      `/api/materials?productId=${product.id}&q=${encodeURIComponent('04381.25WR F0603')}&pageSize=50`
    )
    assert.ok(data.list.every(r => r.product_id === product.id), '不应返回其他产品的行')
  })

  test('分页 total 与列表长度口径一致（COUNT 与列表共用 where）', async () => {
    const { data } = await call(
      `/api/materials?productId=${product.id}&q=${encodeURIComponent('F0603')}&pageSize=500`
    )
    assert.equal(data.list.length, data.total, 'COUNT 与列表必须用同一份 WHERE')
  })
})


// 同规格提示：BOM 列表里状态列的角标数字，必须与点开弹框后实际能选的条数一致。
// 这是最容易悄悄漂移的地方——两边口径由不同 SQL 算出，一旦不一致，
// 「提示有 2 条可选、点开只有 1 条」比完全不提示更让人困惑。
describe('同规格库存提示', () => {
  let specProduct

  before(async () => {
    specProduct = (await call('/api/products', {
      method: 'POST',
      body: { code: 'SPEC_TEST', name: '同规格测试' }
    })).data
  })

  /** 建一条库存 */
  function mkInv(body) {
    return call('/api/inventory', { method: 'POST', body })
  }

  /** 取指定位号的 BOM 行 */
  async function bomRow(designator) {
    const { data } = await call(`/api/materials?productId=${specProduct.id}&pageSize=200`)
    return data.list.find(r => r.designator === designator)
  }

  test('同规格有多个料号时，可选数 = 总数 - 当前料号占的条数', async () => {
    await mkInv({ name: 'SPEC_R', package: 'R0402', mfr_pn: 'SPEC_PN_A', supplier_pn: 'C_SP_A', stock: 0 })
    await mkInv({ name: 'SPEC_R', package: 'R0402', mfr_pn: 'SPEC_PN_B', supplier_pn: 'C_SP_B', stock: 50 })

    await call('/api/materials', {
      method: 'POST',
      body: {
        product_id: specProduct.id,
        name: 'SPEC_R', package: 'R0402', designator: 'RS1', qty: 1,
        mfr_pn: 'SPEC_PN_A'
      }
    })

    const row = await bomRow('RS1')
    assert.equal(row.sameSpecCount, 2, '同规格共 2 条')
    assert.equal(row.sameSpecCurrentCount, 1, '当前料号占 1 条')

    // 前端角标 = sameSpecCount - sameSpecCurrentCount
    const badge = row.sameSpecCount - row.sameSpecCurrentCount
    assert.equal(badge, 1, '应提示还有 1 条可换')

    // 与弹框实际列出的条数对齐：弹框排除当前料号
    const match = (await call(
      `/api/inventory/match?name=${encodeURIComponent(row.name)}&package=${encodeURIComponent(row.package)}`
    )).data
    const dialogRows = match.list.filter(c => c.mfr_pn !== row.mfr_pn)
    assert.equal(badge, dialogRows.length, '角标数字必须等于弹框实际可选条数')
  })

  test('同一料号占多条库存时也能正确扣除（mfr_pn 无唯一约束）', async () => {
    await mkInv({ name: 'SPEC_DUP', package: 'C0402', mfr_pn: 'SPEC_DUP_PN', supplier_pn: 'C_SD_1', stock: 3 })
    await mkInv({ name: 'SPEC_DUP', package: 'C0402', mfr_pn: 'SPEC_DUP_PN', supplier_pn: 'C_SD_2', stock: 4 })
    await mkInv({ name: 'SPEC_DUP', package: 'C0402', mfr_pn: 'SPEC_OTHER', supplier_pn: 'C_SD_3', stock: 9 })

    await call('/api/materials', {
      method: 'POST',
      body: {
        product_id: specProduct.id,
        name: 'SPEC_DUP', package: 'C0402', designator: 'CD1', qty: 1,
        mfr_pn: 'SPEC_DUP_PN'
      }
    })

    const row = await bomRow('CD1')
    assert.equal(row.sameSpecCount, 3, '同规格共 3 条')
    assert.equal(row.sameSpecCurrentCount, 2, '当前料号占 2 条（前端猜 1 就会算错）')

    const badge = row.sameSpecCount - row.sameSpecCurrentCount
    const match = (await call(
      `/api/inventory/match?name=SPEC_DUP&package=C0402`
    )).data
    const dialogRows = match.list.filter(c => c.mfr_pn !== row.mfr_pn)
    assert.equal(badge, dialogRows.length, '共享料号场景下角标仍须与弹框一致')
    assert.equal(badge, 1)
  })

  test('未关联的行：可选数就是同规格总数', async () => {
    await call('/api/materials', {
      method: 'POST',
      body: {
        product_id: specProduct.id,
        name: 'SPEC_R', package: 'R0402', designator: 'RS2', qty: 1,
        mfr_pn: ''
      }
    })
    const row = await bomRow('RS2')
    assert.equal(row.inventory_id, null, '空料号不该关联上库存')
    assert.equal(row.sameSpecCurrentCount, 0, '没有当前料号，不扣除')
    assert.equal(row.sameSpecCount, 2, '同规格 2 条全部可选')
  })

  test('料号为空的库存记录不计入可选（绑不上）', async () => {
    await mkInv({ name: 'SPEC_NOPN', package: 'R0603', supplier_pn: 'C_NOPN', stock: 8 })
    await call('/api/materials', {
      method: 'POST',
      body: {
        product_id: specProduct.id,
        name: 'SPEC_NOPN', package: 'R0603', designator: 'RN1', qty: 1
      }
    })
    const row = await bomRow('RN1')
    assert.equal(row.sameSpecCount, 0, '缺料号的库存不能作为关联依据，不该提示可选')
  })

  test('台账里没有同规格时不提示', async () => {
    await call('/api/materials', {
      method: 'POST',
      body: {
        product_id: specProduct.id,
        name: 'SPEC_NONE_XYZ', package: 'NONE', designator: 'RX9', qty: 1
      }
    })
    const row = await bomRow('RX9')
    assert.equal(row.sameSpecCount, 0)
  })

  test('分页 COUNT 不受同规格标量子查询影响', async () => {
    const { data } = await call(`/api/materials?productId=${specProduct.id}&pageSize=500`)
    assert.equal(data.list.length, data.total, '标量子查询不该让行数翻倍')
  })
})

// 清空产品明细：删掉整份 BOM 但保留产品本身。
// 这是不可恢复的批量删除，重点验证「只删该动的」——别牵连产品、库存、流水和其他产品。
describe('清空产品明细', () => {
  let victim
  let bystander

  before(async () => {
    victim = (await call('/api/products', {
      method: 'POST',
      body: { code: 'CLEAR_VICTIM', name: '待清空', remark: '备注要保留' }
    })).data
    bystander = (await call('/api/products', {
      method: 'POST',
      body: { code: 'CLEAR_BYSTANDER', name: '不该受影响' }
    })).data

    for (const d of ['V1', 'V2', 'V3']) {
      await call('/api/materials', {
        method: 'POST',
        body: { product_id: victim.id, name: '待删元件', package: 'R0402', designator: d, qty: 2 }
      })
    }
    await call('/api/materials', {
      method: 'POST',
      body: { product_id: bystander.id, name: '旁观元件', package: 'C0402', designator: 'B1', qty: 1 }
    })
  })

  test('清空前确认有明细', async () => {
    const { data } = await call(`/api/materials?productId=${victim.id}&pageSize=100`)
    assert.equal(data.total, 3)
  })

  test('清空后明细归零，产品本身完整保留', async () => {
    const invBefore = (await call('/api/inventory/stats')).data

    const { status, data } = await call(`/api/materials/by-product/${victim.id}`, {
      method: 'DELETE'
    })
    assert.equal(status, 200)
    assert.equal(data.removed, 3, '应删掉 3 条')

    const after = (await call(`/api/materials?productId=${victim.id}&pageSize=100`)).data
    assert.equal(after.total, 0, '明细应清空')

    // 产品必须还在，且字段没被动过——这是与「删产品」的本质区别
    const prod = (await call(`/api/products/${victim.id}`)).data
    assert.equal(prod.code, 'CLEAR_VICTIM', '产品应保留')
    assert.equal(prod.remark, '备注要保留', '产品字段不该被改动')

    // 删 BOM 绝不能碰库存：已领出的料不会凭空退回
    const invAfter = (await call('/api/inventory/stats')).data
    assert.equal(invAfter.totalStock, invBefore.totalStock, '库存总件数必须不变')
    assert.equal(invAfter.total, invBefore.total, '库存种类数必须不变')
  })

  test('其他产品的明细不受影响', async () => {
    const { data } = await call(`/api/materials?productId=${bystander.id}&pageSize=100`)
    assert.equal(data.total, 1, '旁观产品的明细必须还在')
  })

  test('重复清空是幂等的，不报错', async () => {
    const { status, data } = await call(`/api/materials/by-product/${victim.id}`, {
      method: 'DELETE'
    })
    assert.equal(status, 200)
    assert.equal(data.removed, 0, '已经空了，删 0 条')
  })

  test('产品不存在返回 404', async () => {
    const { status } = await call('/api/materials/by-product/999999', { method: 'DELETE' })
    assert.equal(status, 404)
  })

  test('非法产品参数返回 400', async () => {
    const { status } = await call('/api/materials/by-product/0', { method: 'DELETE' })
    assert.equal(status, 400)
  })

  test('by-product 不会被 /:id 参数路由吞掉', async () => {
    // 路由注册顺序错了的话，'by-product' 会被当成 id 传给 DELETE /:id 而返回 404「物料不存在」
    const { status, data } = await call(`/api/materials/by-product/${bystander.id}`, {
      method: 'DELETE'
    })
    assert.equal(status, 200)
    assert.ok('removed' in data, '应命中 by-product 端点而非 /:id')
    assert.equal(data.removed, 1)
  })

  test('已领料行数随响应返回，供前端提示后果', async () => {
    // 建一行、领一次料，再清空，检查 solderedLines 有没有如实报出来
    const p = (await call('/api/products', {
      method: 'POST',
      body: { code: 'CLEAR_SOLDER', name: '含领料记录' }
    })).data
    await call('/api/materials', {
      method: 'POST',
      body: {
        product_id: p.id, name: '领过的料', package: 'R0402',
        designator: 'S1', qty: 1, mfr_pn: 'CLEAR_PN_1'
      }
    })
    await call('/api/inventory', {
      method: 'POST',
      body: { name: '领过的料', package: 'R0402', mfr_pn: 'CLEAR_PN_1', supplier_pn: 'C_CL_1', stock: 10 }
    })

    const bomRow = (await call(`/api/materials?productId=${p.id}&pageSize=10`)).data.list[0]
    const invRow = (await call('/api/inventory?q=CLEAR_PN_1&pageSize=10')).data.list[0]
    await call(`/api/inventory/${invRow.id}/move`, {
      method: 'POST',
      body: { type: '出库', qty: 1, productId: p.id, materialId: bomRow.id }
    })

    const logsBefore = (await call('/api/inventory/logs?pageSize=500')).data.total

    const { data } = await call(`/api/materials/by-product/${p.id}`, { method: 'DELETE' })
    assert.equal(data.solderedLines, 1, '应报出 1 行已领料')

    // 流水绝不能被删：料是真领走了，产品级历史仍要可查
    const logsAfter = (await call('/api/inventory/logs?pageSize=500')).data.total
    assert.equal(logsAfter, logsBefore, '出入库流水不该被删除')

    // 库存也不该退回
    const inv = (await call('/api/inventory?q=CLEAR_PN_1&pageSize=10')).data.list[0]
    assert.equal(inv.stock, 9, '已领出的料不该退回库存')
  })
})

// 绑定快照：绑定会覆盖 mfr_pn，原导入值要留一份供表格 hover 查看。
// 这里锁住设计评审列出的三条硬约束，它们都是「不锁就会悄悄坏掉」的类型。
describe('绑定原值快照', () => {
  let bp
  let invA
  let invB

  before(async () => {
    bp = (await call('/api/products', {
      method: 'POST',
      body: { code: 'BIND_SNAP', name: '绑定快照测试' }
    })).data

    invA = (await call('/api/inventory', {
      method: 'POST',
      body: {
        name: 'SNAP_R', package: 'R0402', mfr_pn: 'SNAP_PN_A',
        mfr: '库存制造商A', supplier: '库存供应商A', supplier_pn: 'C_SNAP_A', stock: 10
      }
    })).data
    invB = (await call('/api/inventory', {
      method: 'POST',
      body: {
        name: 'SNAP_R', package: 'R0402', mfr_pn: 'SNAP_PN_B',
        mfr: '库存制造商B', supplier: '库存供应商B', supplier_pn: 'C_SNAP_B', stock: 20
      }
    })).data
  })

  async function mkRow(designator, extra = {}) {
    return (await call('/api/materials', {
      method: 'POST',
      body: {
        product_id: bp.id, name: 'SNAP_R', package: 'R0402', designator, qty: 1,
        mfr_pn: '原导入料号', mfr: '原导入制造商',
        supplier: '原导入供应商', supplier_pn: '原导入供应商料号',
        ...extra
      }
    })).data
  }

  async function getRow(id) {
    return (await call(`/api/materials/${id}`)).data
  }

  test('首次绑定：快照留下原导入值，mfr_pn 换成库存料号', async () => {
    const row = await mkRow('SN1')
    const res = (await call(`/api/materials/${row.id}/bind`, {
      method: 'POST',
      body: { mfr_pn: 'SNAP_PN_A' }
    })).data

    assert.equal(res.mfr_pn, 'SNAP_PN_A', 'mfr_pn 应换成绑定的库存料号')
    assert.equal(res.src_mfr_pn, '原导入料号', '快照要留住原料号')
    assert.equal(res.src_mfr, '原导入制造商')
    assert.equal(res.src_supplier, '原导入供应商')
    assert.equal(res.src_supplier_pn, '原导入供应商料号')
    assert.ok(res.bound_at, 'bound_at 应被设置')
    assert.equal(res.firstBind, true)
  })

  test('绑定绝不把库存的 制造商/供应商 写进 BOM 三列（阻塞项2）', async () => {
    const row = await mkRow('SN2')
    await call(`/api/materials/${row.id}/bind`, { method: 'POST', body: { mfr_pn: 'SNAP_PN_A' } })
    const after = await getRow(row.id)

    // 这三列必须仍是 BOM 自己的原导入值：写成库存值会永久毁掉原始信息
    assert.equal(after.mfr, '原导入制造商', 'BOM 的 mfr 不该被库存值覆盖')
    assert.equal(after.supplier, '原导入供应商', 'BOM 的 supplier 不该被覆盖')
    assert.equal(after.supplier_pn, '原导入供应商料号', 'BOM 的 supplier_pn 不该被覆盖')

    // 库存值通过 JOIN 带出来给前端渲染用，不落到 BOM 列上
    assert.equal(after.inventory_mfr, '库存制造商A', '库存制造商要能带出来供显示')
    assert.equal(after.inventory_supplier, '库存供应商A')
    assert.equal(after.inventory_supplier_pn, 'C_SNAP_A')
  })

  test('重复绑定：快照保持首次的原导入值，不被上一次绑的料号覆盖', async () => {
    const row = await mkRow('SN3')
    await call(`/api/materials/${row.id}/bind`, { method: 'POST', body: { mfr_pn: 'SNAP_PN_A' } })
    const res2 = (await call(`/api/materials/${row.id}/bind`, {
      method: 'POST',
      body: { mfr_pn: 'SNAP_PN_B' }
    })).data

    assert.equal(res2.mfr_pn, 'SNAP_PN_B', '料号应换成第二次绑的')
    assert.equal(res2.src_mfr_pn, '原导入料号', '快照必须还是最初导入的值，不能变成 SNAP_PN_A')
    assert.equal(res2.firstBind, false)
  })

  test('原料号为空的行（结构件）也能正确记录绑定态', async () => {
    // 这是最关键的场景：靠「src_* 非空」推断绑定态会把这类行误判成未绑定
    const row = await mkRow('SN4', { mfr_pn: '', mfr: '', supplier: '', supplier_pn: '' })
    const res = (await call(`/api/materials/${row.id}/bind`, {
      method: 'POST',
      body: { mfr_pn: 'SNAP_PN_A' }
    })).data

    assert.equal(res.src_mfr_pn, '', '原来就是空，快照也是空')
    assert.ok(res.bound_at, '但 bound_at 必须有值，否则无法识别为已绑定')
  })

  test('手改 mfr_pn 清掉绑定态与快照', async () => {
    const row = await mkRow('SN5')
    await call(`/api/materials/${row.id}/bind`, { method: 'POST', body: { mfr_pn: 'SNAP_PN_A' } })

    await call(`/api/materials/${row.id}`, { method: 'PUT', body: { mfr_pn: '手工改的料号' } })
    const after = await getRow(row.id)

    assert.equal(after.mfr_pn, '手工改的料号')
    assert.equal(after.src_mfr_pn, '', '手改料号后快照应清空')
    assert.equal(after.bound_at, null, '手改料号后绑定标记应清空')
  })

  test('只改制造商/供应商（不改料号）不误清绑定态', async () => {
    const row = await mkRow('SN6')
    await call(`/api/materials/${row.id}/bind`, { method: 'POST', body: { mfr_pn: 'SNAP_PN_A' } })

    // 编辑弹窗会整体提交四个字段，其中 mfr_pn 没变
    await call(`/api/materials/${row.id}`, {
      method: 'PUT',
      body: { mfr_pn: 'SNAP_PN_A', mfr: '改过的制造商' }
    })
    const after = await getRow(row.id)

    assert.ok(after.bound_at, '料号没变，绑定态应保留')
    assert.equal(after.src_mfr_pn, '原导入料号', '快照应保留')
    assert.equal(after.mfr, '改过的制造商', '制造商确实被改了')
  })

  test('bulk replace 重导后重置快照与绑定态（阻塞项3）', async () => {
    const row = await mkRow('SN7')
    await call(`/api/materials/${row.id}/bind`, { method: 'POST', body: { mfr_pn: 'SNAP_PN_A' } })

    // 按位号重导：行 id 保留，但 mfr_pn 被导入值覆盖，旧快照就对不上了
    await call('/api/materials/bulk', {
      method: 'POST',
      body: {
        productId: bp.id,
        mode: 'replace',
        rows: [{ name: 'SNAP_R', package: 'R0402', designator: 'SN7', qty: 1, mfr_pn: '重导料号' }]
      }
    })

    const after = await getRow(row.id)
    assert.equal(after.id, row.id, 'replace 应按位号保留行 id')
    assert.equal(after.mfr_pn, '重导料号')
    assert.equal(after.src_mfr_pn, '', '重导后快照必须重置，否则 hover 显示过期信息')
    assert.equal(after.bound_at, null, '重导后绑定标记必须重置')
  })

  test('bulk 导入不会把快照列写成空值（src_* 不在 EDITABLE_COLUMNS，阻塞项1）', async () => {
    const row = await mkRow('SN8')
    await call(`/api/materials/${row.id}/bind`, { method: 'POST', body: { mfr_pn: 'SNAP_PN_A' } })

    // append 模式导入别的行，不该动到已绑定行的快照
    await call('/api/materials/bulk', {
      method: 'POST',
      body: {
        productId: bp.id, mode: 'append',
        rows: [{ name: '无关元件', package: 'C0402', designator: 'SN99', qty: 1 }]
      }
    })

    const after = await getRow(row.id)
    assert.equal(after.src_mfr_pn, '原导入料号', 'append 导入不该影响其他行的快照')
    assert.ok(after.bound_at)
  })

  test('绑定空料号被拒绝', async () => {
    const row = await mkRow('SN10')
    const { status } = await call(`/api/materials/${row.id}/bind`, {
      method: 'POST',
      body: { mfr_pn: '' }
    })
    assert.equal(status, 400)
  })

  test('绑定台账里不存在的料号被拒绝', async () => {
    const row = await mkRow('SN11')
    const { status } = await call(`/api/materials/${row.id}/bind`, {
      method: 'POST',
      body: { mfr_pn: 'NOT_IN_INVENTORY_XYZ' }
    })
    assert.equal(status, 400, '绑了也匹配不上，应直接拒绝')
  })

  test('绑定不存在的物料返回 404', async () => {
    const { status } = await call('/api/materials/999999/bind', {
      method: 'POST',
      body: { mfr_pn: 'SNAP_PN_A' }
    })
    assert.equal(status, 404)
  })

  test('绑定后列表接口带出快照与库存字段供渲染', async () => {
    // 自建独立行：前面的 bulk replace 用例会按 replace 语义删掉未出现的位号，
    // 依赖那些残留行会让本用例随执行顺序飘。
    const row = await mkRow('SN20')
    await call(`/api/materials/${row.id}/bind`, { method: 'POST', body: { mfr_pn: 'SNAP_PN_A' } })

    const { data } = await call(`/api/materials?productId=${bp.id}&pageSize=200`)
    const r = data.list.find(x => x.designator === 'SN20')
    assert.ok(r, '应能在列表里找到刚建的行')
    for (const f of ['src_mfr_pn', 'src_mfr', 'src_supplier', 'src_supplier_pn', 'bound_at',
                     'inventory_mfr', 'inventory_supplier', 'inventory_supplier_pn']) {
      assert.ok(f in r, `列表应带出 ${f}`)
    }
    assert.equal(r.src_mfr_pn, '原导入料号')
    assert.equal(r.inventory_mfr, '库存制造商A')
  })

  // 库存量不作为绑定的准入条件：绑不绑由使用者判断（曾实现过 >50 的硬守卫，
  // 按业务要求撤掉）。这条用例锁住"撤掉了"，防止将来有人顺手加回来。
  test('库存很少的料号也允许绑定（不做库存准入限制）', async () => {
    const lean = (await call('/api/inventory', {
      method: 'POST',
      body: { name: 'SNAP_R', package: 'R0402', mfr_pn: 'SNAP_PN_LEAN', supplier_pn: 'C_LEAN', stock: 1 }
    })).data
    assert.equal(lean.stock, 1)

    const row = await mkRow('SN21')
    const res = await call(`/api/materials/${row.id}/bind`, {
      method: 'POST',
      body: { mfr_pn: 'SNAP_PN_LEAN' }
    })
    assert.equal(res.status, 200, '库存只有 1 也该允许绑定')
    assert.equal(res.data.mfr_pn, 'SNAP_PN_LEAN')
  })

  test('GET /match 带出 minBindStock 供前端标注库存偏低', async () => {
    const { data } = await call('/api/inventory/match?name=SNAP_R&package=R0402')
    assert.ok(Number(data.minBindStock) > 0, '应带出提示阀值，前端不该硬编码')
    // 只是提示：库存不足的候选仍要列出来，过滤掉会变成"查无此料"，是误导
    assert.ok(
      data.list.some(c => c.mfr_pn === 'SNAP_PN_LEAN'),
      '库存偏低的候选也必须出现在列表里'
    )
  })
})

// 库存关联弹框的「明细」：一条库存料号可能被多个产品的 BOM 同时引用，
// 换料号前要知道会影响谁。
describe('料号用量明细 GET /materials/usage', () => {
  let pa
  let pb

  before(async () => {
    pa = (await call('/api/products', {
      method: 'POST', body: { code: 'USAGE_A', name: '用量测试A' }
    })).data
    pb = (await call('/api/products', {
      method: 'POST', body: { code: 'USAGE_B', name: '用量测试B' }
    })).data

    await call('/api/inventory', {
      method: 'POST',
      body: { name: 'USAGE_R', package: 'R0402', mfr_pn: 'USAGE_PN', supplier_pn: 'C_USAGE', stock: 500 }
    })

    // 同一料号：A 产品 2 行、B 产品 1 行 —— 跨产品聚合的最小可信场景
    await call('/api/materials', {
      method: 'POST',
      body: { product_id: pa.id, seq: 1, name: 'USAGE_R', designator: 'UA1', package: 'R0402', qty: 2, mfr_pn: 'USAGE_PN' }
    })
    await call('/api/materials', {
      method: 'POST',
      body: { product_id: pa.id, seq: 2, name: 'USAGE_R', designator: 'UA2', package: 'R0402', qty: 3, mfr_pn: 'USAGE_PN' }
    })
    await call('/api/materials', {
      method: 'POST',
      body: { product_id: pb.id, seq: 1, name: 'USAGE_R', designator: 'UB1', package: 'R0402', qty: 5, mfr_pn: 'USAGE_PN' }
    })
  })

  test('按产品聚合，用量与行数正确', async () => {
    const { status, data } = await call('/api/materials/usage?mfrPn=USAGE_PN')
    assert.equal(status, 200)
    assert.equal(data.productCount, 2, '应跨 2 个产品')
    assert.equal(data.lineCount, 3, '共 3 行 BOM 用到')
    assert.equal(data.totalQty, 10, '单板用量合计 2+3+5')

    const a = data.products.find(p => p.product_code === 'USAGE_A')
    const b = data.products.find(p => p.product_code === 'USAGE_B')
    assert.equal(a.lines.length, 2)
    assert.equal(a.qty, 5, 'A 产品用量 2+3')
    assert.equal(b.lines.length, 1)
    assert.equal(b.qty, 5)
    // 产品名要带出来：弹框里只显示编号的话，用户得回 BOM 页对一遍才知道是哪块板
    assert.equal(a.product_name, '用量测试A')
  })

  test('已领量按净额聚合，撤销出库后归零', async () => {
    const inv = (await call('/api/inventory?q=USAGE_PN&pageSize=10')).data.list[0]
    const line = (await call(`/api/materials?productId=${pa.id}&q=UA1&pageSize=10`)).data.list[0]

    const move = await call(`/api/inventory/${inv.id}/move`, {
      method: 'POST',
      body: { type: '出库', qty: 4, productId: pa.id, materialId: line.id }
    })
    assert.equal(move.status, 200)

    let usage = (await call('/api/materials/usage?mfrPn=USAGE_PN')).data
    let a = usage.products.find(p => p.product_code === 'USAGE_A')
    assert.equal(a.solderedQty, 4, '出库后已领 4')
    assert.equal(usage.totalSolderedQty, 4)

    // 撤销：口径必须是 -SUM(delta) 净额，按 type='出库' 过滤会把已撤销的算成已领。
    // 流水接口返回 { list, total }，不是裸数组。
    const logs = (await call(`/api/inventory/${inv.id}/logs`)).data.list
    const outLog = logs.find(l => l.type === '出库' && l.material_id === line.id)
    assert.ok(outLog, '应能找到刚才那条出库流水')

    const revoke = await call(`/api/inventory/logs/${outLog.id}/revoke`, { method: 'POST' })
    assert.equal(revoke.status, 200, '撤销应成功')

    usage = (await call('/api/materials/usage?mfrPn=USAGE_PN')).data
    a = usage.products.find(p => p.product_code === 'USAGE_A')
    assert.equal(a.solderedQty, 0, '撤销后已领应回到 0（净额口径）')
    assert.equal(usage.totalSolderedQty, 0)
  })

  test('料号为空返回 400（否则会 JOIN 上所有无料号的行）', async () => {
    const { status } = await call('/api/materials/usage?mfrPn=')
    assert.equal(status, 400)
    const missing = await call('/api/materials/usage')
    assert.equal(missing.status, 400)
  })

  test('没有任何 BOM 用到的料号返回空结果而非 404', async () => {
    // "台账里有、但没人用"是有效信息（可以放心换），不是错误
    const { status, data } = await call('/api/materials/usage?mfrPn=NOBODY_USES_THIS_PN')
    assert.equal(status, 200)
    assert.deepEqual(data.products, [])
    assert.equal(data.productCount, 0)
    assert.equal(data.lineCount, 0)
    assert.equal(data.totalQty, 0)
  })

  test("路由注册在 /:id 之前，'usage' 不会被当成 id", async () => {
    const { status, data } = await call('/api/materials/usage?mfrPn=USAGE_PN')
    assert.equal(status, 200)
    assert.ok('products' in data, '返回的应是用量结构，不是单条物料')
    assert.ok(!('designator' in data), '不该返回 id=NaN 的单条查询结果')
  })

  test('标出该 BOM 行的料号是否为手动绑定所得', async () => {
    const { data } = await call('/api/materials/usage?mfrPn=USAGE_PN')
    const line = data.products.flatMap(p => p.lines).find(l => l.designator === 'UB1')
    assert.equal(line.bound, false, '导入的行不是绑定来的')

    // 换成绑定过来的行再看
    const target = (await call(`/api/materials?productId=${pb.id}&q=UB1&pageSize=10`)).data.list[0]
    await call(`/api/materials/${target.id}/bind`, { method: 'POST', body: { mfr_pn: 'USAGE_PN' } })
    const after = (await call('/api/materials/usage?mfrPn=USAGE_PN')).data
    const bound = after.products.flatMap(p => p.lines).find(l => l.designator === 'UB1')
    assert.equal(bound.bound, true, '绑定过的行应标出来')
  })
})

