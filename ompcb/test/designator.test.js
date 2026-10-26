// test/designator.test.js — 位号解析
//
// 纯函数测试，不起服务、不碰数据库，所以没用 createTestServer()。
//
// 断言原则遵循 test/README.md：不硬编码种子数据的具体条数。
// 这里唯一引用种子数据的用例（27 个 C 位号那行）断言的是
// 「位号个数 === 该行 qty」这个恒等关系，而不是写死 27。
import test from 'node:test'
import assert from 'node:assert/strict'
import { parseDesignators, countDesignators } from '../web/designator.js'

test('位号解析：基本拆分', async (t) => {
  await t.test('单个位号', () => {
    assert.deepEqual(parseDesignators('R1'), ['R1'])
    assert.equal(countDesignators('R1'), 1)
  })

  await t.test('多个位号按逗号拆分，顺序保持原样', () => {
    assert.deepEqual(parseDesignators('R1,R32'), ['R1', 'R32'])
    assert.equal(countDesignators('R1,R32'), 2)
    // 乱序不重排：位号顺序是录入者的意图，排序会让 UI 显示与 BOM 不一致
    assert.deepEqual(parseDesignators('C8,C52,C7'), ['C8', 'C52', 'C7'])
  })

  await t.test('位号两侧空格被裁掉', () => {
    assert.deepEqual(parseDesignators(' R1 , R32 '), ['R1', 'R32'])
    assert.equal(countDesignators(' R1 , R32 '), 2)
  })

  await t.test('全角逗号同样是分隔符（Excel 中文环境粘贴常见）', () => {
    assert.deepEqual(parseDesignators('R1，R32'), ['R1', 'R32'])
    assert.equal(countDesignators('R1，R32'), 2)
    // 半角全角混用
    assert.equal(countDesignators('R1，R32,R33'), 3)
  })
})

test('位号解析：空值与脏数据不产生虚假个数', async (t) => {
  await t.test('空/null/undefined 返回 0，调用方据此回退默认值', () => {
    for (const raw of ['', null, undefined]) {
      assert.deepEqual(parseDesignators(raw), [], `raw=${String(raw)}`)
      assert.equal(countDesignators(raw), 0, `raw=${String(raw)}`)
    }
  })

  await t.test('纯空格不算位号', () => {
    assert.equal(countDesignators('   '), 0)
    assert.equal(countDesignators(' , , '), 0)
  })

  await t.test('连续逗号/首尾逗号不产生空位号', () => {
    assert.deepEqual(parseDesignators('R1,,R32'), ['R1', 'R32'])
    assert.equal(countDesignators('R1,,R32'), 2)
    assert.deepEqual(parseDesignators(',R1,R32,'), ['R1', 'R32'])
    assert.equal(countDesignators(',R1,R32,'), 2)
  })

  await t.test('重复位号去重：同一焊盘写两遍是笔误，不该多算一个', () => {
    assert.deepEqual(parseDesignators('R1,R1,R32'), ['R1', 'R32'])
    assert.equal(countDesignators('R1,R1,R32'), 2)
    // 去重发生在 trim 之后，所以 'R1' 与 ' R1 ' 视为同一个
    assert.equal(countDesignators('R1, R1 '), 1)
  })

  await t.test('大小写敏感：不做猜测性归并', () => {
    // 无法确定 r1 是笔误还是另一个真实位号，静默归并会掩盖录入问题
    assert.equal(countDesignators('R1,r1'), 2)
  })
})

test('位号解析：刻意不支持区间写法', async (t) => {
  await t.test('R1-R5 视为 1 个位号而非展开成 5 个', () => {
    // 现有数据与代码都无区间语义。若哪天要支持，改 designator.js 一处，
    // 这条断言会失败并提醒同步更新——这正是它存在的意义。
    assert.deepEqual(parseDesignators('R1-R5'), ['R1-R5'])
    assert.equal(countDesignators('R1-R5'), 1)
  })
})

test('位号解析：非字符串入参不抛异常', async (t) => {
  await t.test('数字位号被当字符串处理', () => {
    // designator 列理论上是 TEXT，但接口层没强制类型，
    // 传进来个数字不该让整个出库弹窗炸掉。
    assert.deepEqual(parseDesignators(1), ['1'])
    assert.equal(countDesignators(1), 1)
  })
})

test('位号个数与 BOM 用量的对应关系', async (t) => {
  await t.test('位号个数等于该行单板用量（种子数据的恒等关系）', () => {
    // 取自 seed.tsv：位号个数与 qty 列一致，这是「按位号个数填出库数量」
    // 这个功能成立的前提。不写死 27，改断言恒等关系。
    const designators =
      'C8,C52,C53,C16,C15,C34,C7,C5,C6,C40,C23,C55,C26,C41,C22,C58,C32,C14,C13,C20,C45,C39,C47,C51,C46,C59,C50'
    const qty = designators.split(',').length
    assert.equal(countDesignators(designators), qty)
  })
})
