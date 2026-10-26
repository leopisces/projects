// 已焊接量追溯：出库绑定到 BOM 行、撤销回退、replace 保 id 等回归测试
import { test, before, after, describe } from 'node:test'
import assert from 'node:assert/strict'
import { createTestServer } from './helpers.js'

let srv
let call

before(async () => {
  srv = await createTestServer()
  call = srv.call
})

after(() => srv?.cleanup())

let uid = 0
function uniq(prefix) {
  return `${prefix}_${Date.now()}_${++uid}`
}

async function makeProduct(code, name = '') {
  const { status, data } = await call('/api/products', {
    method: 'POST',
    body: { code, name }
  })
  assert.equal(status, 201, `创建产品 ${code} 失败: ${data?.error}`)
  return data
}

async function makeInventory(body) {
  const { status, data } = await call('/api/inventory', {
    method: 'POST',
    body
  })
  assert.equal(status, 201, `创建库存失败: ${data?.error}`)
  return data
}

async function makeMaterial(body) {
  const { status, data } = await call('/api/materials', {
    method: 'POST',
    body
  })
  assert.equal(status, 201, `创建 BOM 行失败: ${data?.error}`)
  return data
}

async function bulkReplace(productId, rows) {
  const { status, data } = await call('/api/materials/bulk', {
    method: 'POST',
    body: { productId, mode: 'replace', rows }
  })
  assert.equal(status, 200, `批量替换失败: ${data?.error}`)
  return data
}

async function getMaterial(id) {
  const { status, data } = await call(`/api/materials/${id}`)
  assert.equal(status, 200)
  return data
}

async function outboundLogs(productId) {
  const { data } = await call(`/api/inventory/logs?productId=${productId}&type=出库`)
  return data.list
}

describe('按 BOM 行出库与 material_id 绑定', () => {
  test('/issue 每行出库写入自己的 material_id，共享 mfr_pn 也分别绑定', async () => {
    const p = await makeProduct(uniq('P_ISSUE'))
    const pn = uniq('MFR_SHARED')
    const inv = await makeInventory({
      name: '共享料号元件',
      supplier_pn: uniq('S_ISSUE'),
      mfr_pn: pn,
      stock: 100
    })

    const m1 = await makeMaterial({
      product_id: p.id,
      name: 'R1 电阻',
      designator: 'R1',
      qty: 3,
      mfr_pn: pn
    })
    const m2 = await makeMaterial({
      product_id: p.id,
      name: 'R2 电阻',
      designator: 'R2',
      qty: 5,
      mfr_pn: pn
    })

    const issue = await call('/api/materials/issue', {
      method: 'POST',
      body: { productId: p.id, sets: 2, remark: '按套领料' }
    })
    assert.equal(issue.status, 200)
    assert.equal(issue.data.issuedLines, 2)
    assert.equal(issue.data.issuedQty, 3 * 2 + 5 * 2)

    const after = (await call(`/api/inventory/${inv.id}`)).data
    assert.equal(after.stock, 100 - issue.data.issuedQty, '同一库存行应按累计量扣减')

    const row1 = await getMaterial(m1.id)
    const row2 = await getMaterial(m2.id)
    assert.equal(row1.solderedQty, 3 * 2, '第一行焊接量 = 用量 × 套数')
    assert.equal(row2.solderedQty, 5 * 2, '第二行焊接量 = 用量 × 套数')

    const logs = (await call(`/api/inventory/${inv.id}/logs`)).data.list
      .filter(l => l.type === '出库')
    assert.equal(logs.length, 2, '应产生两条出库流水')

    const ids = new Set(logs.map(l => l.material_id))
    assert.equal(ids.size, 2, '两条流水应分别绑定不同 material_id')
    assert.ok(ids.has(m1.id))
    assert.ok(ids.has(m2.id))
    for (const l of logs) {
      assert.equal(l.product_id, p.id)
      assert.equal(l.inventory_id, inv.id)
    }
    const deltas = logs.map(l => l.delta).sort((a, b) => a - b)
    assert.deepEqual(deltas, [-(3 * 2), -(5 * 2)].sort((a, b) => a - b))
  })
})

describe('撤销出库后焊接量归零', () => {
  test('单条撤销使 solderedQty 回到出库前', async () => {
    const p = await makeProduct(uniq('P_REVOKE_SINGLE'))
    const pn = uniq('MFR_REVOKE_S')
    const inv = await makeInventory({
      name: '撤销单条测试料',
      supplier_pn: uniq('S_REVOKE_S'),
      mfr_pn: pn,
      stock: 100
    })
    const m = await makeMaterial({
      product_id: p.id,
      name: '待撤销料',
      designator: 'C1',
      qty: 4,
      mfr_pn: pn
    })

    await call('/api/materials/issue', {
      method: 'POST',
      body: { productId: p.id }
    })
    assert.equal((await getMaterial(m.id)).solderedQty, 4)

    const [log] = await outboundLogs(p.id)
    const revoke = await call(`/api/inventory/logs/${log.id}/revoke`, {
      method: 'POST',
      body: { remark: '测单撤' }
    })
    assert.equal(revoke.status, 200)

    assert.equal((await getMaterial(m.id)).solderedQty, 0, '撤销后焊接量应回到 0')
    const stats = (await call(`/api/materials/stats?productId=${p.id}`)).data
    assert.equal(stats.solderedQty, 0)
    assert.equal(stats.solderedLines, 0)
  })

  test('批量撤销使全部焊接量回到出库前', async () => {
    const p = await makeProduct(uniq('P_REVOKE_BULK'))
    const pn = uniq('MFR_REVOKE_B')
    const inv = await makeInventory({
      name: '撤销批量测试料',
      supplier_pn: uniq('S_REVOKE_B'),
      mfr_pn: pn,
      stock: 100
    })
    const m1 = await makeMaterial({
      product_id: p.id,
      name: '批量行1',
      designator: 'R1',
      qty: 2,
      mfr_pn: pn
    })
    const m2 = await makeMaterial({
      product_id: p.id,
      name: '批量行2',
      designator: 'R2',
      qty: 3,
      mfr_pn: pn
    })

    await call('/api/materials/issue', {
      method: 'POST',
      body: { productId: p.id }
    })
    assert.equal((await getMaterial(m1.id)).solderedQty, 2)
    assert.equal((await getMaterial(m2.id)).solderedQty, 3)

    const logs = await outboundLogs(p.id)
    const bulk = await call('/api/inventory/logs/revoke-bulk', {
      method: 'POST',
      body: { logIds: logs.map(l => l.id) }
    })
    assert.equal(bulk.status, 200)
    assert.equal(bulk.data.revoked, 2)

    assert.equal((await getMaterial(m1.id)).solderedQty, 0)
    assert.equal((await getMaterial(m2.id)).solderedQty, 0)
    const stats = (await call(`/api/materials/stats?productId=${p.id}`)).data
    assert.equal(stats.solderedQty, 0)
    assert.equal(stats.solderedLines, 0)
  })
})

describe('出库绑定参数的不变量守卫', () => {
  test('非出库类型携带绑定参数被拒绝', async () => {
    const p = await makeProduct(uniq('P_GUARD'))
    const pn = uniq('MFR_GUARD')
    const inv = await makeInventory({
      name: '守卫测试料',
      supplier_pn: uniq('S_GUARD'),
      mfr_pn: pn,
      stock: 100
    })
    const m = await makeMaterial({
      product_id: p.id,
      name: '守卫行',
      designator: 'G1',
      qty: 1,
      mfr_pn: pn
    })

    const inbound = await call(`/api/inventory/${inv.id}/move`, {
      method: 'POST',
      body: { type: '入库', qty: 1, productId: p.id, materialId: m.id }
    })
    assert.equal(inbound.status, 400, '入库不能带 materialId')

    const count = await call(`/api/inventory/${inv.id}/move`, {
      method: 'POST',
      body: { type: '盘点', qty: 100, productId: p.id, materialId: m.id }
    })
    assert.equal(count.status, 400, '盘点不能带 materialId')

    const countProductOnly = await call(`/api/inventory/${inv.id}/move`, {
      method: 'POST',
      body: { type: '盘点', qty: 100, productId: p.id }
    })
    assert.equal(countProductOnly.status, 400, '盘点不能带 productId')
  })

  test('出库绑定缺少 productId 或被指向错误行时拒绝', async () => {
    const p = await makeProduct(uniq('P_BIND'))
    const p2 = await makeProduct(uniq('P_BIND2'))
    const pn = uniq('MFR_BIND')
    const inv = await makeInventory({
      name: '绑定校验料',
      supplier_pn: uniq('S_BIND'),
      mfr_pn: pn,
      stock: 100
    })
    const mOk = await makeMaterial({
      product_id: p.id,
      name: '正确行',
      designator: 'B1',
      qty: 1,
      mfr_pn: pn
    })
    const mOtherProduct = await makeMaterial({
      product_id: p2.id,
      name: '他产品行',
      designator: 'B1',
      qty: 1,
      mfr_pn: pn
    })
    const mMismatch = await makeMaterial({
      product_id: p.id,
      name: '料号不匹配行',
      designator: 'B2',
      qty: 1,
      mfr_pn: uniq('MFR_OTHER')
    })

    const noProduct = await call(`/api/inventory/${inv.id}/move`, {
      method: 'POST',
      body: { type: '出库', qty: 1, materialId: mOk.id }
    })
    assert.equal(noProduct.status, 400, 'materialId 必须同时带 productId')

    const wrongProduct = await call(`/api/inventory/${inv.id}/move`, {
      method: 'POST',
      body: { type: '出库', qty: 1, productId: p.id, materialId: mOtherProduct.id }
    })
    assert.equal(wrongProduct.status, 400, 'material 必须属于指定产品')

    const wrongPn = await call(`/api/inventory/${inv.id}/move`, {
      method: 'POST',
      body: { type: '出库', qty: 1, productId: p.id, materialId: mMismatch.id }
    })
    assert.equal(wrongPn.status, 400, 'material.mfr_pn 必须与库存行一致')
  })
})

describe('未绑定出库保持向后兼容', () => {
  test('普通出库不传 productId/materialId 时两列均为 NULL', async () => {
    const inv = await makeInventory({
      name: '兼容测试料',
      supplier_pn: uniq('S_COMPAT'),
      stock: 50
    })

    const move = await call(`/api/inventory/${inv.id}/move`, {
      method: 'POST',
      body: { type: '出库', qty: 5, remark: '样品/损耗' }
    })
    assert.equal(move.status, 200)
    assert.equal(move.data.stock, 45)

    const [log] = (await call(`/api/inventory/${inv.id}/logs`)).data.list
    assert.equal(log.type, '出库')
    assert.equal(log.delta, -5)
    assert.equal(log.product_id, null)
    assert.equal(log.material_id, null)
  })
})

describe('同 mfr_pn 多库存行时不重复计数', () => {
  test('两个库存行同 mfr_pn 不会把 solderedQty 算成两倍', async () => {
    const p = await makeProduct(uniq('P_DOUBLE'))
    const pn = uniq('MFR_DOUBLE')
    const invA = await makeInventory({
      name: '双行库存 A',
      supplier_pn: uniq('S_DBL_A'),
      mfr_pn: pn,
      stock: 100
    })
    const invB = await makeInventory({
      name: '双行库存 B',
      supplier_pn: uniq('S_DBL_B'),
      mfr_pn: pn,
      stock: 100
    })
    const m = await makeMaterial({
      product_id: p.id,
      name: '双行 BOM 行',
      designator: 'R1',
      qty: 3,
      mfr_pn: pn
    })

    const move = await call(`/api/inventory/${invA.id}/move`, {
      method: 'POST',
      body: { type: '出库', qty: 3, productId: p.id, materialId: m.id }
    })
    assert.equal(move.status, 200)

    const row = await getMaterial(m.id)
    assert.equal(row.solderedQty, 3, '焊接量不应因同料号多库存行而翻倍')

    const stats = (await call(`/api/materials/stats?productId=${p.id}`)).data
    assert.equal(stats.solderedLines, 1)
    assert.equal(stats.solderedQty, 3)
  })
})

describe('replace 批量导入保留 id 与焊接进度', () => {
  test('replace 按位号 reconciles 且未改动行的焊接量保留', async () => {
    const p = await makeProduct(uniq('P_REPLACE'))
    const p2 = await makeProduct(uniq('P_REPLACE_ISO'))
    const pn = uniq('MFR_REPLACE')
    const inv = await makeInventory({
      name: 'replace 测试料',
      supplier_pn: uniq('S_REPLACE'),
      mfr_pn: pn,
      stock: 100
    })

    await bulkReplace(p.id, [
      { seq: 1, name: 'A 旧', designator: 'A1', qty: 2, mfr_pn: pn },
      { seq: 2, name: 'B 旧', designator: 'A2', qty: 3, mfr_pn: pn }
    ])

    const rowsFirst = (await call(`/api/materials?productId=${p.id}&pageSize=100`)).data.list
    const a1 = rowsFirst.find(r => r.designator === 'A1')
    const a2 = rowsFirst.find(r => r.designator === 'A2')
    assert.ok(a1 && a2)

    // 对 A1 做一次绑定出库，后续验证它 survive replace
    const bound = await call(`/api/inventory/${inv.id}/move`, {
      method: 'POST',
      body: { type: '出库', qty: 2, productId: p.id, materialId: a1.id }
    })
    assert.equal(bound.status, 200)
    assert.equal((await getMaterial(a1.id)).solderedQty, 2)

    // 另一个产品的同位号行，验证不会被 replace 波及
    const iso = await makeMaterial({
      product_id: p2.id,
      name: '隔离行',
      designator: 'A1',
      qty: 9,
      mfr_pn: pn
    })

    await bulkReplace(p.id, [
      { seq: 1, name: 'A 新', designator: 'A1', qty: 5, mfr_pn: pn },
      { seq: 3, name: 'C 新', designator: 'A3', qty: 7, mfr_pn: pn }
    ])

    const a1After = await getMaterial(a1.id)
    assert.equal(a1After.id, a1.id, 'A1 位号保留原 id')
    assert.equal(a1After.name, 'A 新', 'A1 字段已更新')
    assert.equal(a1After.qty, 5)
    assert.equal(a1After.solderedQty, 2, '替换后 A1 的焊接进度应保留')

    const gone = await call(`/api/materials/${a2.id}`)
    assert.equal(gone.status, 404, 'A2 位号已消失，应被删除')

    const rowsAfter = (await call(`/api/materials?productId=${p.id}&pageSize=100`)).data.list
    const a3 = rowsAfter.find(r => r.designator === 'A3')
    assert.ok(a3, 'A3 新位号应被插入')
    assert.notEqual(a3.id, a1.id, '新位号应拿到新 id')

    const isoAfter = await getMaterial(iso.id)
    assert.equal(isoAfter.id, iso.id, '其他产品的 BOM 行不应被 replace 影响')
  })
})

describe('BOM 焊接统计', () => {
  test('/materials/stats 正确统计焊接行数与件数并按产品隔离', async () => {
    const pa = await makeProduct(uniq('P_STAT_A'))
    const pb = await makeProduct(uniq('P_STAT_B'))
    const pnA = uniq('MFR_STAT_A')
    const pnB = uniq('MFR_STAT_B')

    const invA = await makeInventory({
      name: '统计料 A',
      supplier_pn: uniq('S_STAT_A'),
      mfr_pn: pnA,
      stock: 100
    })
    const invB = await makeInventory({
      name: '统计料 B',
      supplier_pn: uniq('S_STAT_B'),
      mfr_pn: pnB,
      stock: 100
    })

    const ma1 = await makeMaterial({
      product_id: pa.id,
      name: 'A 焊接行',
      designator: 'R1',
      qty: 2,
      mfr_pn: pnA
    })
    await makeMaterial({
      product_id: pa.id,
      name: 'A 未焊行',
      designator: 'R2',
      qty: 3,
      mfr_pn: pnA
    })
    const mb1 = await makeMaterial({
      product_id: pb.id,
      name: 'B 焊接行',
      designator: 'R1',
      qty: 5,
      mfr_pn: pnB
    })

    const moveA = await call(`/api/inventory/${invA.id}/move`, {
      method: 'POST',
      body: { type: '出库', qty: 2, productId: pa.id, materialId: ma1.id }
    })
    assert.equal(moveA.status, 200)

    const moveB = await call(`/api/inventory/${invB.id}/move`, {
      method: 'POST',
      body: { type: '出库', qty: 5, productId: pb.id, materialId: mb1.id }
    })
    assert.equal(moveB.status, 200)

    const statsA = (await call(`/api/materials/stats?productId=${pa.id}`)).data
    assert.equal(statsA.solderedLines, 1, '产品 A 只有一行被焊接')
    assert.equal(statsA.solderedQty, 2, '产品 A 只统计 R1 的 2 件')

    const statsB = (await call(`/api/materials/stats?productId=${pb.id}`)).data
    assert.equal(statsB.solderedLines, 1)
    assert.equal(statsB.solderedQty, 5)

    // 空产品应返回 0，进一步验证按产品隔离
    const pc = await makeProduct(uniq('P_STAT_C'))
    await makeMaterial({
      product_id: pc.id,
      name: 'C 未焊行',
      designator: 'R1',
      qty: 9,
      mfr_pn: pnA
    })
    const statsC = (await call(`/api/materials/stats?productId=${pc.id}`)).data
    assert.equal(statsC.solderedLines, 0)
    assert.equal(statsC.solderedQty, 0)

    // 全局统计至少包含 A + B 的结果（测试运行时还可能包含同文件其他产品的数据）
    const statsAll = (await call('/api/materials/stats')).data
    assert.ok(statsAll.solderedLines >= 2, '全局焊接行数不少于 A+B')
    assert.ok(statsAll.solderedQty >= 7, '全局焊接件数不少于 A+B')
    assert.ok(statsAll.solderedLines > statsA.solderedLines, '全局统计不应被单个产品限制')
    assert.ok(statsAll.solderedQty > statsA.solderedQty)
  })
})

describe('按已焊接量排序', () => {
  // solderedQty 是 SELECT 里的派生别名，materials 表并没有这一列。
  // 排序时必须走别名分支（DERIVED_SORTS），若误加 m. 前缀会直接 SQL 报错 500。
  // 这条测试就是钉住这个：往 SORTABLE_COLUMNS 加派生列却忘了同步 DERIVED_SORTS 会被抓出来。
  test('sortBy=solderedQty 升降序均正确且不报 SQL 错', async () => {
    const p = await makeProduct(uniq('P_SORT'))
    const pn = uniq('MFR_SORT')
    await makeInventory({
      name: '排序测试料',
      supplier_pn: uniq('S_SORT'),
      mfr_pn: pn,
      stock: 1000
    })

    // 三行同料号、不同用量 → 领料后焊接量必然是 1 / 5 / 9，顺序可辨
    const mLow = await makeMaterial({
      product_id: p.id, name: '少量行', designator: 'R1', qty: 1, mfr_pn: pn
    })
    const mMid = await makeMaterial({
      product_id: p.id, name: '中量行', designator: 'R2', qty: 5, mfr_pn: pn
    })
    const mHigh = await makeMaterial({
      product_id: p.id, name: '多量行', designator: 'R3', qty: 9, mfr_pn: pn
    })
    // 未领料行：焊接量 0，用来验证 0 也参与排序而不是被过滤掉
    const mZero = await makeMaterial({
      product_id: p.id, name: '未领行', designator: 'R4', qty: 7, mfr_pn: ''
    })

    await call('/api/materials/issue', {
      method: 'POST',
      body: { productId: p.id }
    })

    const listBy = async order => {
      const { status, data } = await call(
        `/api/materials?productId=${p.id}&sortBy=solderedQty&sortOrder=${order}&pageSize=50`
      )
      // 500 就意味着 orderExpr 拼出了 m.solderedQty
      assert.equal(status, 200, `按 solderedQty ${order} 排序不应报错: ${data?.error}`)
      return data.list
    }

    const desc = await listBy('desc')
    const asc = await listBy('asc')

    const descQty = desc.map(r => r.solderedQty)
    const ascQty = asc.map(r => r.solderedQty)

    // 断言"有序"这个不变量，而不是写死某个具体排列
    assert.deepEqual(
      descQty,
      [...descQty].sort((a, b) => b - a),
      '降序结果应按 solderedQty 单调不增'
    )
    assert.deepEqual(
      ascQty,
      [...ascQty].sort((a, b) => a - b),
      '升序结果应按 solderedQty 单调不减'
    )

    // 升降序必须真的方向相反，否则说明排序参数根本没生效（静默回退成 seq）
    assert.equal(desc[0].id, mHigh.id, '降序第一行应是焊接量最多的')
    assert.equal(asc[0].solderedQty, 0, '升序第一行应是焊接量 0 的')
    assert.notEqual(desc[0].id, asc[0].id, '升降序首行不应相同')

    // 四行都在结果里，0 值行没被聚合 JOIN 吃掉
    const ids = new Set(desc.map(r => r.id))
    for (const m of [mLow, mMid, mHigh, mZero]) {
      assert.ok(ids.has(m.id), `排序结果应包含 BOM 行 ${m.designator}`)
    }
    assert.equal(desc.find(r => r.id === mZero.id).solderedQty, 0)
  })
})

describe('按焊接进度筛选', () => {
  // 构造一个产品：三行同料号，领 1 套后分别处于 未焊完 / 已焊完 / 超领 三种状态
  async function makeProgressFixture() {
    const p = await makeProduct(uniq('P_FILTER'))
    const pn = uniq('MFR_FILTER')
    const inv = await makeInventory({
      name: '进度筛选料',
      supplier_pn: uniq('S_FILTER'),
      mfr_pn: pn,
      stock: 1000
    })
    const mDone = await makeMaterial({
      product_id: p.id, name: '正好焊完', designator: 'R1', qty: 2, mfr_pn: pn
    })
    const mOver = await makeMaterial({
      product_id: p.id, name: '会被超领', designator: 'R2', qty: 2, mfr_pn: pn
    })
    // 无料号 → 领料时会被跳过，焊接量恒为 0，稳定处于「未焊完」
    const mUnfin = await makeMaterial({
      product_id: p.id, name: '领不到料', designator: 'R3', qty: 4, mfr_pn: ''
    })

    // 领 1 套：mDone 与 mOver 各得 2 件，mUnfin 因无料号被跳过
    await call('/api/materials/issue', { method: 'POST', body: { productId: p.id } })
    // 再给 mOver 单独绑定出库 1 件 → 3 > 2，进入「超领」
    const move = await call(`/api/inventory/${inv.id}/move`, {
      method: 'POST',
      body: { type: '出库', qty: 1, remark: '补料', productId: p.id, materialId: mOver.id }
    })
    assert.equal(move.status, 200, `补料出库失败: ${move.data?.error}`)

    assert.equal((await getMaterial(mDone.id)).solderedQty, 2)
    assert.equal((await getMaterial(mOver.id)).solderedQty, 3)
    assert.equal((await getMaterial(mUnfin.id)).solderedQty, 0)
    return { p, mDone, mOver, mUnfin }
  }

  async function filterBy(productId, solderState, sets) {
    const qs = new URLSearchParams({ productId, solderState, pageSize: '50' })
    if (sets != null) qs.set('sets', String(sets))
    const { status, data } = await call(`/api/materials?${qs}`)
    assert.equal(status, 200, `solderState=${solderState} 筛选报错: ${data?.error}`)
    return data
  }

  test('unfinished / done / over 三种筛选各自命中正确的行', async () => {
    const { p, mDone, mOver, mUnfin } = await makeProgressFixture()

    const unfin = await filterBy(p.id, 'unfinished')
    const unfinIds = unfin.list.map(r => r.id)
    assert.ok(unfinIds.includes(mUnfin.id), '未焊完应含焊接量 0 的行')
    assert.ok(!unfinIds.includes(mDone.id), '未焊完不应含已焊完的行')
    assert.ok(!unfinIds.includes(mOver.id), '未焊完不应含超领的行')

    const done = await filterBy(p.id, 'done')
    const doneIds = done.list.map(r => r.id)
    assert.ok(doneIds.includes(mDone.id), '已焊完应含焊接量 = 需求的行')
    assert.ok(!doneIds.includes(mOver.id), '已焊完不应含超领的行')
    assert.ok(!doneIds.includes(mUnfin.id))

    const over = await filterBy(p.id, 'over')
    const overIds = over.list.map(r => r.id)
    assert.deepEqual(overIds, [mOver.id], '超领应只含焊接量 > 需求的行')

    // 三种状态互斥且并集为全部行
    const all = await filterBy(p.id, '')
    assert.equal(
      unfin.list.length + done.list.length + over.list.length,
      all.total,
      '三种进度互斥且应覆盖全部 BOM 行'
    )
  })

  test('分页 total 与 list 一致（COUNT 查询同样带 solderState 条件）', async () => {
    // COUNT 走的是独立 SQL 且没有 soldered 派生表的 JOIN，
    // 若筛选条件没同步进去，total 会退化成不筛选的总数。
    const { p, mOver } = await makeProgressFixture()

    const over = await filterBy(p.id, 'over')
    assert.equal(over.total, 1, 'total 必须反映筛选后的条数，而不是全部行数')
    assert.equal(over.list.length, over.total, 'list 长度应与 total 一致')
    assert.equal(over.list[0].id, mOver.id)

    const all = await filterBy(p.id, '')
    assert.ok(all.total > over.total, '不筛选时总数应大于超领筛选的总数')
  })

  test('判定基准是需求（用量 × 套数），改套数会改变归类', async () => {
    const { p, mDone } = await makeProgressFixture()

    // 1 套时 mDone 焊接量 2 = 需求 2 → 已焊完
    const done1 = await filterBy(p.id, 'done', 1)
    assert.ok(done1.list.map(r => r.id).includes(mDone.id), '1 套时应判为已焊完')

    // 2 套时需求变 4，焊接量仍是 2 → 未焊完
    const done2 = await filterBy(p.id, 'done', 2)
    assert.ok(!done2.list.map(r => r.id).includes(mDone.id), '2 套时不应再判为已焊完')
    const unfin2 = await filterBy(p.id, 'unfinished', 2)
    assert.ok(unfin2.list.map(r => r.id).includes(mDone.id), '2 套时应判为未焊完')
  })

  test('非法 solderState 视为不筛选，不报错也不误伤', async () => {
    const { p } = await makeProgressFixture()
    const all = await filterBy(p.id, '')
    const bogus = await filterBy(p.id, 'DROP TABLE materials')
    assert.equal(bogus.total, all.total, '未命中白名单的值应被忽略而非拼进 SQL')

    // 确认表还在（白名单确实拦住了）
    const still = await call(`/api/materials?productId=${p.id}`)
    assert.equal(still.status, 200)
  })
})

describe('按 BOM 行查流水（materialId 筛选）', () => {
  /**
   * 造一条绑定出库过的 BOM 行。
   * 同一库存记录上另做一次「未绑定出库」与一次入库，
   * 用来验证它们不会混进该 BOM 行的流水。
   */
  async function makeLogFixture() {
    const p = await makeProduct(uniq('P_MATLOG'))
    const pn = uniq('PN_MATLOG')
    const inv = await makeInventory({ name: '流水测试件', mfr_pn: pn, stock: 50 })
    const m = await makeMaterial({
      product_id: p.id,
      name: '流水测试件',
      designator: 'R1,R2',
      qty: 2,
      mfr_pn: pn
    })

    // 绑定该 BOM 行的两次出库
    await call(`/api/inventory/${inv.id}/move`, {
      method: 'POST',
      body: { type: '出库', qty: 2, remark: '第一次领料', productId: p.id, materialId: m.id }
    })
    await call(`/api/inventory/${inv.id}/move`, {
      method: 'POST',
      body: { type: '出库', qty: 1, remark: '补料', productId: p.id, materialId: m.id }
    })
    // 噪声：未绑定出库 + 入库，都不该出现在该 BOM 行的流水里
    await call(`/api/inventory/${inv.id}/move`, {
      method: 'POST',
      body: { type: '出库', qty: 1, remark: '样品（不绑BOM行）' }
    })
    await call(`/api/inventory/${inv.id}/move`, {
      method: 'POST',
      body: { type: '入库', qty: 5, remark: '到货' }
    })

    return { p, inv, m }
  }

  async function materialLogs(materialId) {
    const { status, data } = await call(`/api/inventory/logs?materialId=${materialId}`)
    assert.equal(status, 200)
    return data
  }

  test('只返回绑定该 BOM 行的流水，未绑定出库与入库不混入', async () => {
    const { m } = await makeLogFixture()
    const res = await materialLogs(m.id)

    // 两次绑定出库，噪声的未绑定出库与入库都不该在内
    assert.equal(res.total, 2, '应只含绑定该 BOM 行的 2 条出库')
    assert.ok(
      res.list.every(l => l.material_id === m.id),
      '每条流水的 material_id 都必须是该 BOM 行'
    )
    assert.ok(
      res.list.every(l => l.type === '出库'),
      '入库/盘点/初始不带 material_id，不该出现'
    )
    assert.ok(
      !res.list.some(l => String(l.remark).includes('不绑BOM行')),
      '未绑定出库不该混进来'
    )
  })

  test('流水聚合与表格 solderedQty 同口径', async () => {
    // 弹框页脚的「领出 − 补回」必须等于表格里的已焊接数，
    // 两者不一致是最难被发现的一类账目 bug。
    const { m } = await makeLogFixture()
    const res = await materialLogs(m.id)

    const net = res.list.reduce((a, l) => a - l.delta, 0)
    const mat = await getMaterial(m.id)
    assert.equal(net, mat.solderedQty, '流水净额应等于 solderedQty')
  })

  test('撤销后补偿行同样归入该 BOM 行，净额随之减少', async () => {
    const { m } = await makeLogFixture()
    const before = await materialLogs(m.id)
    const target = before.list.find(l => l.type === '出库' && !l.revoked_by_log_id)
    const qty = Math.abs(target.delta)

    const rev = await call(`/api/inventory/logs/${target.id}/revoke`, {
      method: 'POST',
      body: { remark: '领错了' }
    })
    assert.equal(rev.status, 200, `撤销失败: ${rev.data?.error}`)

    const after = await materialLogs(m.id)
    // 撤销不删原行，另加一条补偿入库，所以条数 +1
    assert.equal(after.total, before.total + 1, '撤销应追加补偿行而非删除原行')

    const compensation = after.list.find(l => l.revokes_log_id === target.id)
    assert.ok(compensation, '补偿行应能在该 BOM 行的流水里查到')
    assert.equal(
      compensation.material_id,
      m.id,
      '补偿行必须继承同一 material_id，否则已焊接无法归零'
    )
    assert.equal(compensation.type, '入库')

    // 净额与 solderedQty 同步减少
    const netAfter = after.list.reduce((a, l) => a - l.delta, 0)
    const matAfter = await getMaterial(m.id)
    assert.equal(netAfter, matAfter.solderedQty, '撤销后两者仍须一致')

    const netBefore = before.list.reduce((a, l) => a - l.delta, 0)
    assert.equal(netAfter, netBefore - qty, `净额应减少 ${qty}`)
  })

  test('没领过料的 BOM 行返回空流水而不是报错', async () => {
    const p = await makeProduct(uniq('P_NOLOG'))
    const m = await makeMaterial({
      product_id: p.id,
      name: '没领过的件',
      designator: 'C1',
      qty: 1,
      mfr_pn: uniq('PN_NOLOG')
    })

    const res = await materialLogs(m.id)
    assert.equal(res.total, 0)
    assert.deepEqual(res.list, [])
  })

  test('非法 materialId 视为不筛选，不报错也不拼进 SQL', async () => {
    const all = await call('/api/inventory/logs')
    const bogus = await call('/api/inventory/logs?materialId=DROP TABLE inventory_log')
    assert.equal(bogus.status, 200)
    assert.equal(bogus.data.total, all.data.total, '非法值应被忽略')

    // 确认表还在
    const still = await call('/api/inventory/logs')
    assert.equal(still.status, 200)
  })
})
