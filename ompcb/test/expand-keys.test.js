// test/expand-keys.test.js — el-table 展开行 key 同步
//
// 纯函数测试，不起服务、不碰数据库（同 designator.test.js / bom-display.test.js）。
//
// 这个文件是为一个真实 bug 建的回归锁：库存关联弹框的明细「点开后收不回去」。
// 成因是把 expand-change 的第二个参数当成布尔值 —— 它实际是「当前所有已展开行
// 的数组」（element-plus/es/components/table/src/store/expand.mjs:26），
// 数组恒为真，于是只会不断 add、永远删不掉。
//
// 为什么值得单测：这个 bug 在代码上完全合理（`if (expanded) … else …` 看不出问题），
// 只有真去点一下才会发现，而项目没有组件测试。锁在纯函数层是最便宜的防线。
import test from 'node:test'
import assert from 'node:assert/strict'
import { toExpandKeys, isRowExpanded } from '../web/expand-keys.js'

test('展开 key 同步：以已展开行数组为唯一事实来源', async (t) => {
  await t.test('取出各行的 key', () => {
    assert.deepEqual(toExpandKeys([{ id: 3 }, { id: 7 }]), [3, 7])
  })

  await t.test('顺序按组件给的数组，不重排', () => {
    // 顺序是 el-table 内部的展开顺序，重排没有意义也可能与 UI 不一致
    assert.deepEqual(toExpandKeys([{ id: 9 }, { id: 2 }, { id: 5 }]), [9, 2, 5])
  })

  await t.test('空数组 = 全部收起', () => {
    // 这是修复的核心：收起最后一行时组件给的是 []，必须原样变成 []
    assert.deepEqual(toExpandKeys([]), [])
  })

  await t.test('布尔值/undefined/null 一律当作没有展开行', () => {
    // 万一将来换成树形表格（那边发的是布尔），也不能把 true 解释成"展开了某行"
    assert.deepEqual(toExpandKeys(true), [])
    assert.deepEqual(toExpandKeys(false), [])
    assert.deepEqual(toExpandKeys(undefined), [])
    assert.deepEqual(toExpandKeys(null), [])
  })

  await t.test('去重，且丢掉没有 key 的行', () => {
    // 无 key 的行进不了 expand-row-keys（el-table 按 key 找行），留着只会让计数失真
    assert.deepEqual(toExpandKeys([{ id: 1 }, { id: 1 }, {}, { id: null }, { id: 2 }]), [1, 2])
  })

  await t.test('支持自定义 key 字段', () => {
    assert.deepEqual(toExpandKeys([{ mfr_pn: 'A' }, { mfr_pn: 'B' }], 'mfr_pn'), ['A', 'B'])
  })

  await t.test('key 为 0 不能被当成空值丢掉', () => {
    assert.deepEqual(toExpandKeys([{ id: 0 }]), [0])
  })
})

test('展开态判定：这一行在不在已展开数组里', async (t) => {
  await t.test('在数组里 = 展开', () => {
    assert.equal(isRowExpanded([{ id: 3 }, { id: 7 }], { id: 7 }), true)
  })

  await t.test('不在数组里 = 收起（这是本次修复要保住的行为）', () => {
    // 点收起时组件给的数组已不含该行；旧代码在这里会误判成"展开"并重复请求
    assert.equal(isRowExpanded([{ id: 3 }], { id: 7 }), false)
    assert.equal(isRowExpanded([], { id: 7 }), false)
  })

  await t.test('第二个参数不是数组时一律按收起处理', () => {
    assert.equal(isRowExpanded(true, { id: 7 }), false)
    assert.equal(isRowExpanded(undefined, { id: 7 }), false)
  })

  await t.test('行本身缺 key 时按收起处理，不抛异常', () => {
    assert.equal(isRowExpanded([{ id: 7 }], {}), false)
    assert.equal(isRowExpanded([{ id: 7 }], null), false)
    assert.equal(isRowExpanded([{ id: 7 }], undefined), false)
  })

  await t.test('key 为 0 的行能被正确判定', () => {
    assert.equal(isRowExpanded([{ id: 0 }], { id: 0 }), true)
  })

  await t.test('自定义 key 字段', () => {
    assert.equal(isRowExpanded([{ mfr_pn: 'A' }], { mfr_pn: 'A' }, 'mfr_pn'), true)
    assert.equal(isRowExpanded([{ mfr_pn: 'A' }], { mfr_pn: 'B' }, 'mfr_pn'), false)
  })
})

test('展开 key 同步：完整的点开→再点开→收起序列', () => {
  // 模拟 el-table 依次发出的载荷，确认 key 列表能一路跟上（尤其最后能回到空）
  let keys = toExpandKeys([{ id: 1 }])
  assert.deepEqual(keys, [1], '点开第一行')

  keys = toExpandKeys([{ id: 1 }, { id: 2 }])
  assert.deepEqual(keys, [1, 2], '再点开第二行')

  keys = toExpandKeys([{ id: 2 }])
  assert.deepEqual(keys, [2], '收起第一行')

  keys = toExpandKeys([])
  assert.deepEqual(keys, [], '收起最后一行 —— 旧实现在这一步永远删不掉')
})
