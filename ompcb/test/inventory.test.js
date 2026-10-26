// 库存台账：出入库流水、唯一约束、级联删除
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

/** 取一个有库存的元件 */
async function pickInStock() {
  const { data } = await call('/api/inventory?inStock=1&pageSize=1&sortBy=id&sortOrder=asc')
  return data.list[0]
}

describe('台账初始化', () => {
  test('首次启动从 BOM 自动抽取台账', async () => {
    const { status, data } = await call('/api/inventory?pageSize=1')
    assert.equal(status, 200)
    assert.ok(data.total > 0, '应已从种子 BOM 抽取出台账')
  })

  test('汇总字段完整', async () => {
    const { data } = await call('/api/inventory/stats')
    for (const f of ['total', 'totalStock', 'inStockKinds', 'zeroStockKinds', 'statusCounts']) {
      assert.ok(f in data, `汇总应含 ${f}`)
    }
    assert.equal(data.inStockKinds + data.zeroStockKinds, data.total)
  })

  test('抽取时按料号去重（同料号库存相加）', async () => {
    // 种子数据里 K2-1102AQ-C4CW-01 出现两次（SW2/SW3），应合并为一行
    const { data } = await call('/api/inventory?q=K2-1102AQ&pageSize=10')
    assert.equal(data.total, 1, '重复料号应合并成一行')
  })
})

describe('出入库', () => {
  test('入库增加库存并落流水', async () => {
    const item = await pickInStock()
    const before = item.stock

    const { status, data } = await call(`/api/inventory/${item.id}/move`, {
      method: 'POST',
      body: { type: '入库', qty: 5, remark: '到货' }
    })
    assert.equal(status, 200)
    assert.equal(data.stock, before + 5)
    assert.equal(data.delta, 5)

    const logs = (await call(`/api/inventory/${item.id}/logs`)).data.list
    assert.equal(logs[0].type, '入库')
    assert.equal(logs[0].delta, 5)
    assert.equal(logs[0].stock_after, before + 5)
    assert.equal(logs[0].remark, '到货')
  })

  test('出库减少库存', async () => {
    const item = await pickInStock()
    const before = item.stock

    const { data } = await call(`/api/inventory/${item.id}/move`, {
      method: 'POST',
      body: { type: '出库', qty: 1, remark: '领用' }
    })
    assert.equal(data.stock, before - 1)
    assert.equal(data.delta, -1)
  })

  test('出库超过库存被拒绝', async () => {
    const item = await pickInStock()
    const { status, data } = await call(`/api/inventory/${item.id}/move`, {
      method: 'POST',
      body: { type: '出库', qty: item.stock + 1 }
    })
    assert.equal(status, 400)
    assert.match(data.error, /库存不足/)
  })

  test('盘点直接以实盘数为准', async () => {
    const item = await pickInStock()
    const { data } = await call(`/api/inventory/${item.id}/move`, {
      method: 'POST',
      body: { type: '盘点', qty: 42, remark: '年度盘点' }
    })
    assert.equal(data.stock, 42)
    assert.equal(data.stockAfter, 42)
  })

  test('盘点结果与账面一致时仍留痕（delta=0）', async () => {
    const item = await pickInStock()
    const { data } = await call(`/api/inventory/${item.id}/move`, {
      method: 'POST',
      body: { type: '盘点', qty: item.stock }
    })
    assert.equal(data.delta, 0)

    const logs = (await call(`/api/inventory/${item.id}/logs`)).data.list
    assert.equal(logs[0].type, '盘点')
    assert.equal(logs[0].delta, 0, 'delta=0 也要记录，留下盘点痕迹')
  })

  test('非法操作类型被拒绝', async () => {
    const item = await pickInStock()
    const { status } = await call(`/api/inventory/${item.id}/move`, {
      method: 'POST',
      body: { type: '瞎写', qty: 1 }
    })
    assert.equal(status, 400)
  })

  test('出入库数量必须大于 0', async () => {
    const item = await pickInStock()
    const { status } = await call(`/api/inventory/${item.id}/move`, {
      method: 'POST',
      body: { type: '入库', qty: 0 }
    })
    assert.equal(status, 400)
  })

  test('对不存在的元件出入库返回 404', async () => {
    const { status } = await call('/api/inventory/999999/move', {
      method: 'POST',
      body: { type: '入库', qty: 1 }
    })
    assert.equal(status, 404)
  })
})

describe('库存只能通过出入库变动', () => {
  test('PUT 无法直接改 stock', async () => {
    const item = await pickInStock()
    const { status } = await call(`/api/inventory/${item.id}`, {
      method: 'PUT',
      body: { stock: 99999 }
    })
    assert.equal(status, 400, 'stock 不在可编辑列里，应报"没有需要更新的字段"')

    const after = (await call(`/api/inventory/${item.id}`)).data
    assert.equal(after.stock, item.stock, '库存不应被 PUT 改动')
  })

  test('PUT 可以改位置等非库存字段', async () => {
    const item = await pickInStock()
    const { status, data } = await call(`/api/inventory/${item.id}`, {
      method: 'PUT',
      body: { location: 'A1-B2' }
    })
    assert.equal(status, 200)
    assert.equal(data.location, 'A1-B2')
  })
})

describe('新增与唯一约束', () => {
  test('新增带初始库存会落"初始"流水', async () => {
    const { status, data } = await call('/api/inventory', {
      method: 'POST',
      body: { name: '测试元件', supplier_pn: 'C_UNIQ_1', stock: 7 }
    })
    assert.equal(status, 201)
    assert.equal(data.stock, 7)

    const logs = (await call(`/api/inventory/${data.id}/logs`)).data.list
    assert.equal(logs[0].type, '初始')
    assert.equal(logs[0].delta, 7)
  })

  test('供应商料号重复返回 409', async () => {
    const { status } = await call('/api/inventory', {
      method: 'POST',
      body: { name: '重复料号', supplier_pn: 'C_UNIQ_1' }
    })
    assert.equal(status, 409)
  })

  test('空供应商料号允许多行（无立创编号场景）', async () => {
    const a = await call('/api/inventory', { method: 'POST', body: { name: '无编号A', supplier_pn: '' } })
    const b = await call('/api/inventory', { method: 'POST', body: { name: '无编号B', supplier_pn: '' } })
    assert.equal(a.status, 201)
    assert.equal(b.status, 201, '空料号不参与唯一约束')
  })

  test('名称/供应商料号/制造商料号全空被拒', async () => {
    const { status } = await call('/api/inventory', {
      method: 'POST',
      body: { location: '只填位置' }
    })
    assert.equal(status, 400)
  })
})

describe('删除与级联', () => {
  test('删除元件时流水一并清除', async () => {
    const created = (await call('/api/inventory', {
      method: 'POST',
      body: { name: '待删除', supplier_pn: 'C_DEL_1', stock: 3 }
    })).data

    const logsBefore = (await call(`/api/inventory/${created.id}/logs`)).data.list
    assert.ok(logsBefore.length > 0)

    const del = await call(`/api/inventory/${created.id}`, { method: 'DELETE' })
    assert.equal(del.status, 200)

    const after = await call(`/api/inventory/${created.id}/logs`)
    assert.equal(after.status, 404, '元件已删，流水应随之消失')
  })
})

describe('库存状态由库存量派生', () => {
  test('库存 > 0 时状态为正常', async () => {
    const item = await pickInStock()
    assert.ok(item.stock > 0)
    assert.equal(item.status, '正常')
  })

  test('库存归零后状态自动变缺货', async () => {
    const created = (await call('/api/inventory', {
      method: 'POST',
      body: { name: '状态派生测试', supplier_pn: 'C_DERIVE_1', stock: 5 }
    })).data
    assert.equal(created.status, '正常', '有库存应为正常')

    // 全部出库
    await call(`/api/inventory/${created.id}/move`, {
      method: 'POST',
      body: { type: '出库', qty: 5, remark: '清空' }
    })

    const after = (await call(`/api/inventory/${created.id}`)).data
    assert.equal(after.stock, 0)
    assert.equal(after.status, '缺货', '库存归零应自动变缺货')

    // 再入库应变回正常
    await call(`/api/inventory/${created.id}/move`, {
      method: 'POST',
      body: { type: '入库', qty: 2 }
    })
    const back = (await call(`/api/inventory/${created.id}`)).data
    assert.equal(back.status, '正常', '重新有货应变回正常')
  })

  test('新建时库存为 0 直接是缺货', async () => {
    const { data } = await call('/api/inventory', {
      method: 'POST',
      body: { name: '零库存新建', supplier_pn: 'C_DERIVE_2', stock: 0 }
    })
    assert.equal(data.stock, 0)
    assert.equal(data.status, '缺货')
  })

  test('status 不是可写字段，PUT 传它无效', async () => {
    const created = (await call('/api/inventory', {
      method: 'POST',
      body: { name: '状态不可写', supplier_pn: 'C_DERIVE_3', stock: 3 }
    })).data

    // 只传 status 应该被判定为"没有需要更新的字段"
    const only = await call(`/api/inventory/${created.id}`, {
      method: 'PUT',
      body: { status: '缺货' }
    })
    assert.equal(only.status, 400)

    // 混在其他字段里传，status 也不该生效
    await call(`/api/inventory/${created.id}`, {
      method: 'PUT',
      body: { status: '缺货', location: 'Z9' }
    })
    const after = (await call(`/api/inventory/${created.id}`)).data
    assert.equal(after.location, 'Z9', '其他字段正常更新')
    assert.equal(after.status, '正常', '状态仍按库存派生，不受传入值影响')
  })

  test('只有正常与缺货两种状态', async () => {
    const { data } = await call('/api/inventory?pageSize=500')
    const kinds = new Set(data.list.map(x => x.status))
    for (const k of kinds) {
      assert.ok(['正常', '缺货'].includes(k), `出现了意外状态: ${k}`)
    }
  })

  test('状态分布汇总只有两组且与库存有无一致', async () => {
    const { data } = await call('/api/inventory/stats')
    for (const s of data.statusCounts) {
      assert.ok(['正常', '缺货'].includes(s.status), `意外状态: ${s.status}`)
    }
    const normal = data.statusCounts.find(s => s.status === '正常')?.count ?? 0
    const short = data.statusCounts.find(s => s.status === '缺货')?.count ?? 0
    assert.equal(normal, data.inStockKinds, '正常数应等于有货种类数')
    assert.equal(short, data.zeroStockKinds, '缺货数应等于零库存种类数')
  })

  test('可按状态筛选', async () => {
    const normal = (await call('/api/inventory?status=正常&pageSize=500')).data
    assert.ok(normal.list.every(x => x.stock > 0 && x.status === '正常'))

    const short = (await call('/api/inventory?status=缺货&pageSize=500')).data
    assert.ok(short.list.every(x => x.stock <= 0 && x.status === '缺货'))
  })
})

describe('筛选与搜索', () => {
  test('inStock=0 只返回零库存', async () => {
    const { data } = await call('/api/inventory?inStock=0&pageSize=500')
    assert.ok(data.list.every(x => x.stock === 0))
  })

  test('inStock=1 只返回有货', async () => {
    const { data } = await call('/api/inventory?inStock=1&pageSize=500')
    assert.ok(data.list.every(x => x.stock > 0))
  })

  test('关键字搜索命中料号与名称', async () => {
    const { data } = await call('/api/inventory?q=100nF')
    assert.ok(data.total >= 1)
  })

  test('名称 + 封装组合检索（空格分词，跨列 AND）', async () => {
    // 种子里 04381.25WR 是名称、F0603 是封装，分别在两列。
    // 不分词的单串 LIKE 必然查不到，因为没有任何一列同时含这两段。
    const both = (await call('/api/inventory?q=04381.25WR F0603&pageSize=50')).data
    assert.ok(both.total >= 1, '「名称 封装」组合应能查到')
    assert.ok(
      both.list.every(x => x.name.includes('04381.25WR') || x.package.includes('04381.25WR')),
      '结果每行都应命中第一个词'
    )
    assert.ok(both.list.every(x => x.package.includes('F0603')), '结果每行都应命中封装词')

    // 顺序无关：用户记不住「名称在前还是封装在前」
    const reversed = (await call('/api/inventory?q=F0603 04381.25WR&pageSize=50')).data
    assert.equal(reversed.total, both.total, '词序不应影响结果')
  })

  test('组合检索是收窄而非放宽：结果 ⊆ 任一单词的结果', async () => {
    const pkgOnly = (await call('/api/inventory?q=F0603&pageSize=500')).data
    const combined = (await call('/api/inventory?q=F0603 04381.25WR&pageSize=500')).data
    assert.ok(combined.total <= pkgOnly.total, 'AND 语义必须让结果更少或相等')
    assert.ok(combined.total >= 1)
  })

  test('组合检索查无匹配时返回空而不是报错', async () => {
    // 两个词各自都存在，但没有同一行同时命中
    const { status, data } = await call('/api/inventory?q=F0603 K2-1102AQ&pageSize=50')
    assert.equal(status, 200)
    assert.equal(data.total, 0)
  })

  test('多余空格与全角空格不影响分词', async () => {
    const base = (await call('/api/inventory?q=04381.25WR F0603')).data
    const messy = (await call(`/api/inventory?q=${encodeURIComponent('  04381.25WR\u3000 F0603 ')}`)).data
    assert.equal(messy.total, base.total)
  })

  test('单词检索行为不变（原整串匹配仍命中）', async () => {
    // 名称里含空格的整串查询，分词后每个词仍命中同一列，结果不会丢
    const { data } = await call('/api/inventory?q=K2-1102AQ')
    assert.equal(data.total, 1)
  })

  // --- 等价字符归一 -------------------------------------------------------
  // Ω 有两个码点且肉眼完全一样：U+03A9(希腊 Omega) 与 U+2126(OHM SIGN)。
  // SQLite LIKE 按字节比，不归一的话用错码点就永远查不到，而用户看不出区别。
  describe('等价字符归一', () => {
    const OMEGA = '\u03A9' // U+03A9 希腊大写 Omega，常规输入法与种子数据用的
    const OHM = '\u2126' // U+2126 OHM SIGN，从 PDF / 立创商城复制时会带
    const MU = '\u03BC' // U+03BC 希腊小写 mu
    const MICRO = '\u00B5' // U+00B5 MICRO SIGN

    /** 建一条名称含指定欧姆码点的元件，返回 id */
    async function createOhm(char, pn) {
      const { data } = await call('/api/inventory', {
        method: 'POST',
        body: { name: `4.7k${char}`, package: 'R0402', supplier_pn: pn, stock: 5 }
      })
      return data.id
    }

    test('DB 存 U+03A9 时，用 U+2126 也能查到', async () => {
      await createOhm(OMEGA, 'C_OHM_A9')
      const { data } = await call(`/api/inventory?q=${encodeURIComponent(`4.7k${OHM}`)}&pageSize=10`)
      assert.ok(data.total >= 1, 'U+2126 应能查到 U+03A9 的数据')
    })

    test('DB 存 U+2126 时，用 U+03A9 也能查到（反向）', async () => {
      // 这个方向同样真实：批量导入可能把 PDF 里的 U+2126 写进库
      await createOhm(OHM, 'C_OHM_21')
      const { data } = await call(
        `/api/inventory?q=${encodeURIComponent(`4.7k${OMEGA}`)}&pageSize=10`
      )
      assert.ok(
        data.list.some(x => x.supplier_pn === 'C_OHM_21'),
        'U+03A9 应能查到 U+2126 的数据'
      )
    })

    test('两种欧姆码点检索结果完全一致', async () => {
      const a = (await call(`/api/inventory?q=${encodeURIComponent(`4.7k${OMEGA}`)}&pageSize=50`))
        .data
      const b = (await call(`/api/inventory?q=${encodeURIComponent(`4.7k${OHM}`)}&pageSize=50`)).data
      assert.equal(a.total, b.total, '两个码点必须等价，否则用户看不出为何结果不同')
      assert.ok(a.total >= 2, '前两个用例建的两条都该被查到')
    })

    test('μ 与 MICRO SIGN 等价（10μF 场景）', async () => {
      await call('/api/inventory', {
        method: 'POST',
        body: { name: `10${MU}F`, package: 'C0805', supplier_pn: 'C_MU_1', stock: 3 }
      })
      const viaMicro = (
        await call(`/api/inventory?q=${encodeURIComponent(`10${MICRO}F`)}&pageSize=10`)
      ).data
      assert.ok(viaMicro.list.some(x => x.supplier_pn === 'C_MU_1'), 'MICRO SIGN 应能查到 mu')
    })

    test('全角输入自动折半角', async () => {
      // 输入法没切回半角时打出 Ｒ０４０２，不该查不到
      const full = (await call(`/api/inventory?q=${encodeURIComponent('Ｒ０４０２')}&pageSize=500`))
        .data
      const half = (await call('/api/inventory?q=R0402&pageSize=500')).data
      assert.equal(full.total, half.total, '全角与半角应等价')
      assert.ok(half.total >= 1)
    })

    test('归一与分词叠加：变体码点 + 封装组合检索', async () => {
      const { data } = await call(
        `/api/inventory?q=${encodeURIComponent(`4.7k${OHM} R0402`)}&pageSize=10`
      )
      assert.ok(data.total >= 1, '变体码点也要能参与多词组合')
      assert.ok(data.list.every(x => x.package.includes('R0402')))
    })

    test('归一不影响中文厂商名检索（NFKC 不动汉字）', async () => {
      const { data } = await call(`/api/inventory?q=${encodeURIComponent('厚声')}&pageSize=50`)
      assert.ok(data.total >= 1, '中文厂商名不应被归一破坏')
    })
  })

  test('非法排序列安全回落', async () => {
    const { status } = await call('/api/inventory?sortBy=stock;DROP TABLE inventory--')
    assert.equal(status, 200)
  })

  test('位置去重列表', async () => {
    const { status, data } = await call('/api/inventory/locations')
    assert.equal(status, 200)
    assert.ok(Array.isArray(data))
    assert.ok(data.includes('A1-B2'), '前面 PUT 设置的位置应出现在列表里')
  })

  test('全局流水带元件名与料号', async () => {
    const { data } = await call('/api/inventory/logs?pageSize=5')
    assert.ok(data.list.length > 0)
    assert.ok('name' in data.list[0], '全局流水应 JOIN 出元件名')
  })
})

// GET /match：按名称+封装严格相等找候选库存，供 BOM 页「状态」列点开查看与绑定。
// 重点是它**不能**退化成模糊搜索，否则会给出错误候选让人误绑。
describe('名称+封装 严格匹配候选', () => {
  const OMEGA = '\u03A9'
  const OHM = '\u2126'

  test('严格相等命中，且返回库存量与位置', async () => {
    await call('/api/inventory', {
      method: 'POST',
      body: { name: 'MATCH_A', package: 'R0402', supplier_pn: 'C_MA_1', stock: 7, location: 'Z1' }
    })
    const { status, data } = await call('/api/inventory/match?name=MATCH_A&package=R0402')
    assert.equal(status, 200)
    assert.equal(data.total, 1)
    assert.equal(data.list[0].stock, 7, '要带出库存量')
    assert.equal(data.list[0].location, 'Z1', '要带出位置')
    assert.ok('status' in data.list[0], '要带出派生状态')
  })

  test('严格相等不误命子串（这正是不能复用 q 搜索的原因）', async () => {
    // MATCH_A 是 MATCH_ABC 的子串；LIKE '%MATCH_A%' 会把两条都捞出来
    await call('/api/inventory', {
      method: 'POST',
      body: { name: 'MATCH_ABC', package: 'R0402', supplier_pn: 'C_MA_2', stock: 1 }
    })
    const { data } = await call('/api/inventory/match?name=MATCH_A&package=R0402')
    assert.equal(data.total, 1, '只能命中完全相等的那条')
    assert.equal(data.list[0].supplier_pn, 'C_MA_1')
  })

  test('封装不同不算同规格', async () => {
    await call('/api/inventory', {
      method: 'POST',
      body: { name: 'MATCH_A', package: 'R0603', supplier_pn: 'C_MA_3', stock: 9 }
    })
    const { data } = await call('/api/inventory/match?name=MATCH_A&package=R0402')
    assert.equal(data.total, 1, 'R0603 那条不该出现在 R0402 的候选里')
  })

  test('名称含空格不被分词打散', async () => {
    // 模糊搜索会把 'AGB CPU' 拆成两个词，相等语义就没了
    await call('/api/inventory', {
      method: 'POST',
      body: { name: 'AGB CPU', package: 'QFN', supplier_pn: 'C_MA_SP', stock: 2 }
    })
    const { data } = await call(
      `/api/inventory/match?name=${encodeURIComponent('AGB CPU')}&package=QFN`
    )
    assert.equal(data.total, 1, '带空格的名称要整体相等匹配')
    assert.equal(data.list[0].supplier_pn, 'C_MA_SP')
  })

  test('Ω 两种码点在严格相等下互通', async () => {
    // 严格相等比模糊搜索更依赖归一：= 没有子串兜底
    await call('/api/inventory', {
      method: 'POST',
      body: { name: `8.2k${OMEGA}`, package: 'R0402', supplier_pn: 'C_MA_OHM', stock: 4 }
    })
    const viaOhm = (
      await call(
        `/api/inventory/match?name=${encodeURIComponent(`8.2k${OHM}`)}&package=R0402`
      )
    ).data
    assert.equal(viaOhm.total, 1, 'U+2126 应能严格匹配到 U+03A9 的记录')
  })

  test('mfrPnKinds 反映该料号对应几条库存', async () => {
    // 同一 mfr_pn 两条记录（mfr_pn 无唯一约束），回填后 BOM 行会重复出现
    await call('/api/inventory', {
      method: 'POST',
      body: { name: 'MATCH_DUP', package: 'C0402', mfr_pn: 'PN_DUP', supplier_pn: 'C_DUP_1', stock: 3 }
    })
    await call('/api/inventory', {
      method: 'POST',
      body: { name: 'MATCH_DUP', package: 'C0402', mfr_pn: 'PN_DUP', supplier_pn: 'C_DUP_2', stock: 5 }
    })
    const { data } = await call('/api/inventory/match?name=MATCH_DUP&package=C0402')
    assert.equal(data.total, 2)
    assert.ok(data.list.every(x => x.mfrPnKinds === 2), '共用料号的候选要标出 2')
  })

  test('封装为空时只按名称匹配（结构件常不填封装）', async () => {
    const { data } = await call('/api/inventory/match?name=MATCH_A')
    assert.ok(data.total >= 2, '不传 package 时 R0402 与 R0603 两条都应返回')
  })

  test('名称为空返回空列表而不是全表', async () => {
    const { status, data } = await call('/api/inventory/match?name=&package=R0402')
    assert.equal(status, 200)
    assert.equal(data.total, 0, '空名称绝不能把整个台账倒出来')
  })

  test('查无同规格时返回空列表而非报错', async () => {
    const { status, data } = await call('/api/inventory/match?name=NOPE_XYZ&package=NOPE')
    assert.equal(status, 200)
    assert.equal(data.total, 0)
    assert.ok(Array.isArray(data.list))
  })

  test('按库存降序排列，有货的候选排前面', async () => {
    const { data } = await call('/api/inventory/match?name=MATCH_DUP&package=C0402')
    assert.ok(data.list[0].stock >= data.list[1].stock, '库存多的应排前面')
  })
})

describe('批量导入', () => {
  test('upsert 模式按供应商料号合并库存', async () => {
    const created = (await call('/api/inventory', {
      method: 'POST',
      body: { name: '合并测试', supplier_pn: 'C_MERGE_1', stock: 10 }
    })).data

    const { data } = await call('/api/inventory/bulk', {
      method: 'POST',
      body: {
        mode: 'upsert',
        rows: [{ name: '合并测试', supplier_pn: 'C_MERGE_1', stock: 5 }]
      }
    })
    assert.equal(data.updated, 1, '应识别为已存在并合并')
    assert.equal(data.inserted, 0)

    const after = (await call(`/api/inventory/${created.id}`)).data
    assert.equal(after.stock, 15, '库存应累加 10 + 5')
  })

  test('rows 非数组返回 400', async () => {
    const { status } = await call('/api/inventory/bulk', {
      method: 'POST',
      body: { rows: 'not-an-array' }
    })
    assert.equal(status, 400)
  })
})

describe('批量删除', () => {
  /** 新建一条台账记录，返回它 */
  async function makeItem(suffix) {
    const { status, data } = await call('/api/inventory', {
      method: 'POST',
      body: {
        name: `批删测试_${suffix}`,
        mfr_pn: `BULKDEL_PN_${suffix}_${Date.now()}`,
        stock: 3
      }
    })
    assert.equal(status, 201, `建档失败: ${data?.error}`)
    return data
  }

  async function countItems() {
    const { data } = await call('/api/inventory?pageSize=1')
    return data.total
  }

  test('删除多条并级联清除各自的流水', async () => {
    const a = await makeItem('A')
    const b = await makeItem('B')

    // 给 a 造两条流水，删除后应一并消失
    await call(`/api/inventory/${a.id}/move`, {
      method: 'POST',
      body: { type: '入库', qty: 5, remark: '测试' }
    })
    await call(`/api/inventory/${a.id}/move`, {
      method: 'POST',
      body: { type: '出库', qty: 2, remark: '测试' }
    })

    const before = await countItems()
    const { status, data } = await call('/api/inventory/bulk-delete', {
      method: 'POST',
      body: { ids: [a.id, b.id] }
    })

    assert.equal(status, 200, `批量删除失败: ${data?.error}`)
    assert.equal(data.deleted, 2)
    assert.ok(data.logsRemoved >= 3, '应连带清除流水（含建档的初始流水）')
    assert.equal(await countItems(), before - 2)

    // 两条都查不到了
    assert.equal((await call(`/api/inventory/${a.id}`)).status, 404)
    assert.equal((await call(`/api/inventory/${b.id}`)).status, 404)

    // 流水也查不到了（外键级联）
    const { data: logs } = await call(`/api/inventory/${a.id}/logs`)
    assert.equal((logs.list || []).length, 0, '元件删除后其流水应一并清除')
  })

  test('含不存在的 id 时整批拒绝，一条都不删', async () => {
    // 删除不可恢复：勾了 N 条就该确切知道这 N 条的下场，
    // 悄悄跳过几条会让人以为删干净了。
    const item = await makeItem('KEEP')
    const before = await countItems()

    const { status, data } = await call('/api/inventory/bulk-delete', {
      method: 'POST',
      body: { ids: [item.id, 99999999] }
    })

    assert.equal(status, 404)
    assert.ok(String(data.error).includes('99999999'), '错误信息应指出哪些 id 不存在')
    assert.equal(await countItems(), before, '整批拒绝时条数不该变化')
    assert.equal((await call(`/api/inventory/${item.id}`)).status, 200, '该记录应仍然存在')
  })

  test('重复 id 去重后只删一次', async () => {
    const item = await makeItem('DUP')
    const before = await countItems()

    const { status, data } = await call('/api/inventory/bulk-delete', {
      method: 'POST',
      body: { ids: [item.id, item.id, item.id] }
    })

    assert.equal(status, 200)
    assert.equal(data.deleted, 1, '同一条重复传入只算一条')
    assert.equal(await countItems(), before - 1)
  })

  test('返回被删元件的库存与流水统计，供前端如实汇报', async () => {
    const a = await makeItem('STAT1')
    const b = await makeItem('STAT2')

    const { data } = await call('/api/inventory/bulk-delete', {
      method: 'POST',
      body: { ids: [a.id, b.id] }
    })

    // 两条各 3 件库存
    assert.equal(data.stockRemoved, 6, '应汇总被删元件的库存件数')
    assert.equal(data.details.length, 2)
    assert.ok(data.details.every(d => d.name), 'details 要带名称，便于前端展示删了什么')
  })

  test('ids 非数组返回 400', async () => {
    const { status } = await call('/api/inventory/bulk-delete', {
      method: 'POST',
      body: { ids: 'not-an-array' }
    })
    assert.equal(status, 400)
  })

  test('ids 为空数组返回 400', async () => {
    const { status } = await call('/api/inventory/bulk-delete', {
      method: 'POST',
      body: { ids: [] }
    })
    assert.equal(status, 400)
  })

  test('非法 id 被过滤后为空则返回 400', async () => {
    const { status } = await call('/api/inventory/bulk-delete', {
      method: 'POST',
      body: { ids: [0, -1, 'abc', null] }
    })
    assert.equal(status, 400)
  })

  test('超过单次上限返回 400 而不是硬删一大批', async () => {
    const { status, data } = await call('/api/inventory/bulk-delete', {
      method: 'POST',
      body: { ids: Array.from({ length: 501 }, (_, i) => i + 1) }
    })
    assert.equal(status, 400)
    assert.ok(String(data.error).includes('500'))
  })
})
