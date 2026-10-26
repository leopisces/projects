// test/location.test.js — 库位编址解析与空位计算
//
// 纯函数测试，不起服务、不碰数据库，与 designator.test.js 同一套模式。
//
// 断言原则遵循 test/README.md：不硬编码种子数据的具体条数。
// 这里全部用例都自带输入，不依赖库里现有的 4 条库位数据。
import test from 'node:test'
import assert from 'node:assert/strict'
import {
  normalizeLocation,
  parseLocation,
  formatLocation,
  findFreeLocations,
  allocateFreeCells,
  validateMerge,
  getMergeCells,
  resolveCell,
  allLayerCells,
  allGridCells,
  GRID_ROWS,
  GRID_COLS,
  LAYERS
} from '../web/location.js'

test('库位归一', async (t) => {
  await t.test('小写转大写', () => {
    assert.equal(normalizeLocation('a15'), 'A15')
  })

  await t.test('空白被去掉（半角/全角）', () => {
    assert.equal(normalizeLocation(' A 1 5 '), 'A15')
    assert.equal(normalizeLocation('A\u30001\u30005'), 'A15')
  })

  await t.test('全角字符转半角', () => {
    assert.equal(normalizeLocation('Ａ１５'), 'A15')
  })

  await t.test('空值安全', () => {
    assert.equal(normalizeLocation(null), '')
    assert.equal(normalizeLocation(undefined), '')
    assert.equal(normalizeLocation('   '), '')
  })
})

test('库位解析', async (t) => {
  await t.test('A15 = A 层 1 行 5 列', () => {
    assert.deepEqual(parseLocation('A15'), { layer: 'A', row: 1, col: 5 })
  })

  await t.test('行是纵向、列是横向：A11/A21/A31 同列不同行', () => {
    assert.deepEqual(parseLocation('A11'), { layer: 'A', row: 1, col: 1 })
    assert.deepEqual(parseLocation('A21'), { layer: 'A', row: 2, col: 1 })
    assert.deepEqual(parseLocation('A31'), { layer: 'A', row: 3, col: 1 })
  })

  await t.test('归一后再解析，写法不规范也认得', () => {
    assert.deepEqual(parseLocation(' a15 '), { layer: 'A', row: 1, col: 5 })
    assert.deepEqual(parseLocation('Ａ１５'), { layer: 'A', row: 1, col: 5 })
  })

  await t.test('自由文本库位返回 null，不是错误', () => {
    // 历史数据/特殊存放点可能这么写，它们是合法库位值，只是不参与网格计算
    assert.equal(parseLocation('抽屉3-格5'), null)
    assert.equal(parseLocation('待入库'), null)
    assert.equal(parseLocation('A1-B2'), null)
  })

  await t.test('行列不接受 0：格子从 1 开始编号', () => {
    assert.equal(parseLocation('A01'), null)
    assert.equal(parseLocation('A10'), null)
  })

  await t.test('位数必须是 2：多一位少一位都判定为非网格', () => {
    // A1 缺列、A111 有歧义（1行11列还是11行1列？），一律不猜
    assert.equal(parseLocation('A1'), null)
    assert.equal(parseLocation('A111'), null)
  })

  await t.test('formatLocation 与 parseLocation 互逆', () => {
    const cell = { layer: 'C', row: 4, col: 5 }
    assert.equal(formatLocation(cell), 'C45')
    assert.deepEqual(parseLocation(formatLocation(cell)), cell)
  })
})

test('空位计算', async (t) => {
  await t.test('用户给的例子：已用 A11/A12/A13/A15 → 空 A14', () => {
    const res = findFreeLocations(['A11', 'A12', 'A13', 'A15'])
    assert.deepEqual(res.free, ['A14'])
    assert.equal(res.maxLocation, 'A15')
  })

  await t.test('范围是已用行列围成的矩形，不凭空造新行', () => {
    // 只用过第 1 行，就不该提议 A21——那是扩容决定，该由人来做
    const res = findFreeLocations(['A11', 'A13'])
    assert.deepEqual(res.free, ['A12'])
    assert.ok(!res.free.includes('A21'))
  })

  await t.test('多行时矩形按各自最大值围', () => {
    // 已用 A11 A13 A22 → 行 1..2、列 1..3 → 空 A12 A21 A23
    const res = findFreeLocations(['A11', 'A13', 'A22'])
    assert.deepEqual(res.free, ['A12', 'A21', 'A23'])
  })

  await t.test('不凭空造没启用的层', () => {
    const res = findFreeLocations(['A11', 'A12'])
    assert.ok(!res.free.some(loc => loc.startsWith('B')))
  })

  await t.test('每层各自算行列上界，互不牵连', () => {
    // A 层用到 2 行 2 列，B 层只用到 1 行 2 列
    // B 层不该被 A 层的边界要求补满 2×2
    const res = findFreeLocations(['A11', 'A22', 'B11', 'B12'])
    const bFree = res.free.filter(loc => loc.startsWith('B'))
    assert.deepEqual(bFree, [])   // B 层 1 行 1..2 列全满
    const aFree = res.free.filter(loc => loc.startsWith('A'))
    assert.deepEqual(aFree, ['A12', 'A21'])
  })

  await t.test('全满时没有空位', () => {
    const res = findFreeLocations(['A11', 'A12', 'A21', 'A22'])
    assert.deepEqual(res.free, [])
  })

  await t.test('单个库位没有空位（1×1 矩形已被占满）', () => {
    const res = findFreeLocations(['A11'])
    assert.deepEqual(res.free, [])
    assert.equal(res.maxLocation, 'A11')
  })

  await t.test('空输入安全', () => {
    const res = findFreeLocations([])
    assert.deepEqual(res.free, [])
    assert.equal(res.maxLocation, '')
    assert.deepEqual(res.layers, [])
  })

  await t.test('接受对象数组（台账行直接传进来）', () => {
    const res = findFreeLocations([
      { location: 'A11', name: '1MΩ' },
      { location: 'A13', name: '100nF' }
    ])
    assert.deepEqual(res.free, ['A12'])
  })

  await t.test('未填位置的行被忽略，不影响计算', () => {
    const res = findFreeLocations(['A11', '', '  ', 'A13', null])
    assert.deepEqual(res.free, ['A12'])
  })

  await t.test('自由文本库位单独归入 unparsed，不污染网格', () => {
    const res = findFreeLocations(['A11', 'A13', '抽屉3-格5'])
    assert.deepEqual(res.free, ['A12'])
    assert.deepEqual(res.unparsed, ['抽屉3-格5'])
  })

  await t.test('写法不规范的库位与规范的视为同一格，不重复计入', () => {
    // 'a11' 和 'A11' 是同一格，不该因大小写差异让 A11 显示为空位
    const res = findFreeLocations(['a11', 'A12', 'A13'])
    assert.ok(!res.free.includes('A11'))
    assert.deepEqual(res.free, [])
  })

  await t.test('分层信息如实反映每层用量', () => {
    const res = findFreeLocations(['A11', 'A12', 'B11'])
    assert.equal(res.layers.length, 2)
    const [a, b] = res.layers
    assert.equal(a.layer, 'A')
    assert.equal(a.maxRow, 1)
    assert.equal(a.maxCol, 2)
    assert.equal(a.usedCount, 2)
    assert.equal(b.layer, 'B')
    assert.equal(b.usedCount, 1)
  })

  await t.test('层按字母序排列，maxLocation 取最大层', () => {
    const res = findFreeLocations(['B11', 'A11', 'C12'])
    assert.deepEqual(res.layers.map(l => l.layer), ['A', 'B', 'C'])
    assert.equal(res.maxLocation, 'C12')
  })
})

test('网格常量与枚举', async (t) => {
  await t.test('每层固定 5×5，共 26 层', () => {
    assert.equal(GRID_ROWS, 5)
    assert.equal(GRID_COLS, 5)
    assert.equal(LAYERS.length, 26)
    assert.equal(LAYERS[0], 'A')
    assert.equal(LAYERS[25], 'Z')
  })

  await t.test('allLayerCells 按行序铺满一层 25 格', () => {
    const cells = allLayerCells('A')
    assert.equal(cells.length, 25)
    // 行内从左到右，跨行时行号递增
    assert.equal(cells[0], 'A11')
    assert.equal(cells[4], 'A15')
    assert.equal(cells[5], 'A21')
    assert.equal(cells[24], 'A55')
  })

  await t.test('allGridCells 覆盖 26 层共 650 格且无重复', () => {
    const all = allGridCells()
    assert.equal(all.length, 26 * 25)
    assert.equal(new Set(all).size, all.length, '不应有重复格子')
  })

  await t.test('行列超出 1~5 一律判定为非网格库位', () => {
    // 网格是 5×5，A16 / A61 都不存在
    assert.equal(parseLocation('A16'), null)
    assert.equal(parseLocation('A61'), null)
    assert.equal(parseLocation('A66'), null)
    // 边界内的仍然有效
    assert.deepEqual(parseLocation('A55'), { layer: 'A', row: 5, col: 5 })
  })
})

test('合并校验', async (t) => {
  await t.test('横向合并两格合法', () => {
    assert.deepEqual(validateMerge('A', 1, 1, 1, 2), { ok: true })
  })

  await t.test('纵向合并两格合法', () => {
    assert.deepEqual(validateMerge('A', 1, 1, 2, 1), { ok: true })
  })

  await t.test('矩形块合并合法', () => {
    assert.deepEqual(validateMerge('A', 2, 2, 3, 4), { ok: true })
  })

  await t.test('单格不需要合并', () => {
    const res = validateMerge('A', 1, 1, 1, 1)
    assert.equal(res.ok, false)
    assert.ok(res.error.includes('单格'))
  })

  await t.test('超出网格边界被拒绝', () => {
    assert.equal(validateMerge('A', 1, 1, 6, 1).ok, false)
    assert.equal(validateMerge('A', 1, 1, 1, 6).ok, false)
    assert.equal(validateMerge('A', 0, 1, 2, 1).ok, false)
  })

  await t.test('方向颠倒被拒绝（必须左上到右下）', () => {
    const res = validateMerge('A', 3, 1, 1, 1)
    assert.equal(res.ok, false)
    assert.ok(res.error.includes('左上'))
  })

  await t.test('与已有合并重叠被拒绝', () => {
    const existing = [{ layer: 'A', startRow: 1, startCol: 1, endRow: 1, endCol: 2 }]
    // A11~A12 已合并，再合 A12~A13 会重叠在 A12
    const res = validateMerge('A', 1, 2, 1, 3, existing)
    assert.equal(res.ok, false)
    assert.ok(res.error.includes('重叠'))
  })

  await t.test('紧邻但不重叠的合并允许', () => {
    const existing = [{ layer: 'A', startRow: 1, startCol: 1, endRow: 1, endCol: 2 }]
    // A11~A12 已合并，A13~A14 紧邻但不重叠
    assert.deepEqual(validateMerge('A', 1, 3, 1, 4, existing), { ok: true })
  })

  await t.test('不同层的相同坐标不算重叠', () => {
    const existing = [{ layer: 'A', startRow: 1, startCol: 1, endRow: 1, endCol: 2 }]
    // 跨层无物理关系，B 层同坐标可自由合并
    assert.deepEqual(validateMerge('B', 1, 1, 1, 2, existing), { ok: true })
  })
})

test('合并覆盖的格子', async (t) => {
  await t.test('横向合并覆盖同行连续格', () => {
    assert.deepEqual(getMergeCells('A', 1, 1, 1, 3), ['A11', 'A12', 'A13'])
  })

  await t.test('纵向合并覆盖同列连续格', () => {
    assert.deepEqual(getMergeCells('A', 1, 1, 3, 1), ['A11', 'A21', 'A31'])
  })

  await t.test('矩形合并覆盖整块', () => {
    assert.deepEqual(getMergeCells('A', 1, 1, 2, 2), ['A11', 'A12', 'A21', 'A22'])
  })
})

test('合并后库位归属（位置自动更新的依据）', async (t) => {
  const merges = [
    { layer: 'A', startRow: 1, startCol: 1, endRow: 1, endCol: 2, primary: 'A11' }
  ]

  await t.test('被吞并的格子解析为主格', () => {
    // A12 被 A11 吞并，放在 A12 的料库位应算作 A11
    assert.equal(resolveCell('A12', merges), 'A11')
  })

  await t.test('主格解析为自身', () => {
    assert.equal(resolveCell('A11', merges), 'A11')
  })

  await t.test('未被合并的格子保持原样', () => {
    assert.equal(resolveCell('A13', merges), 'A13')
    assert.equal(resolveCell('A21', merges), 'A21')
  })

  await t.test('不同层同坐标不受影响', () => {
    assert.equal(resolveCell('B12', merges), 'B12')
  })

  await t.test('自由文本库位原样返回', () => {
    assert.equal(resolveCell('抽屉3-格5', merges), '抽屉3-格5')
  })

  await t.test('无合并时一律返回原格', () => {
    assert.equal(resolveCell('A12', []), 'A12')
  })
})

test('空位计算考虑合并', async (t) => {
  await t.test('被合并吞掉的格子不算空位', () => {
    // A11~A13 合并成一个大格（主格 A11），料放在 A11。
    // A12/A13 已不是独立库位，不该出现在空位里。
    const merges = [
      { layer: 'A', startRow: 1, startCol: 1, endRow: 1, endCol: 3, primary: 'A11' }
    ]
    const res = findFreeLocations(['A11', 'A15'], merges)
    assert.ok(!res.free.includes('A12'), 'A12 已被合并，不是空位')
    assert.ok(!res.free.includes('A13'), 'A13 已被合并，不是空位')
    assert.deepEqual(res.free, ['A14'], '只有 A14 是真空位')
  })

  await t.test('放在被吞并格里的料算到主格头上', () => {
    // 历史数据可能还写着 A12（合并前存的），它应被视为占用 A11
    const merges = [
      { layer: 'A', startRow: 1, startCol: 1, endRow: 1, endCol: 2, primary: 'A11' }
    ]
    const res = findFreeLocations(['A12', 'A13'], merges)
    // A12 归到 A11，所以 A11 被占；A12 被合并吞掉
    assert.ok(!res.free.includes('A11'), 'A11 应被视为已占用')
    assert.ok(!res.free.includes('A12'), 'A12 被合并吞掉')
  })

  await t.test('合并不影响其他层的空位计算', () => {
    const merges = [
      { layer: 'A', startRow: 1, startCol: 1, endRow: 1, endCol: 2, primary: 'A11' }
    ]
    const res = findFreeLocations(['A11', 'A13', 'B11', 'B13'], merges)
    const bFree = res.free.filter(l => l.startsWith('B'))
    assert.deepEqual(bFree, ['B12'], 'B 层不受 A 层合并影响')
  })
})

test('自动分配空位', async (t) => {
  await t.test('从 A11 开始按货架顺序分配', () => {
    // 顺序即货架的自然顺序：同行从左到右填满再换行，一层填满再开下一层。
    // 这样新建的料在货架上是连续一片，找料时不用跳着找。
    const res = allocateFreeCells([], 3)
    assert.deepEqual(res.cells, ['A11', 'A12', 'A13'])
    assert.equal(res.enough, true)
  })

  await t.test('跳过已占用的格子', () => {
    const res = allocateFreeCells(['A11', 'A13'], 3)
    assert.deepEqual(res.cells, ['A12', 'A14', 'A15'])
  })

  await t.test('一行填满后换到下一行', () => {
    const res = allocateFreeCells(['A11', 'A12', 'A13', 'A14'], 3)
    assert.deepEqual(res.cells, ['A15', 'A21', 'A22'])
  })

  await t.test('一层填满后开下一层', () => {
    // A 层 25 格全占，下一个应是 B11
    const full = allLayerCells('A')
    const res = allocateFreeCells(full, 2)
    assert.deepEqual(res.cells, ['B11', 'B12'])
  })

  await t.test('台账空着时也能分配（与 findFreeLocations 的关键差异）', () => {
    // findFreeLocations 只看「已用范围内」，台账空时返回空集；
    // 自动分配必须真能分出位置，所以走全网格。
    assert.deepEqual(findFreeLocations([]).free, [])
    const res = allocateFreeCells([], 1)
    assert.deepEqual(res.cells, ['A11'])
  })

  await t.test('接受对象数组（台账行直接传进来）', () => {
    const res = allocateFreeCells([{ location: 'A11' }, { location: 'A12' }], 2)
    assert.deepEqual(res.cells, ['A13', 'A14'])
  })

  await t.test('未归位的行不占位置', () => {
    const res = allocateFreeCells([{ location: '' }, { location: '  ' }, { location: 'A11' }], 2)
    assert.deepEqual(res.cells, ['A12', 'A13'])
  })

  await t.test('写法不规范的已占用库位同样被认出', () => {
    // 'a11' 与 'A11' 是同一格，不该把 A11 重复分配出去
    const res = allocateFreeCells(['a11', ' A 1 2 '], 2)
    assert.deepEqual(res.cells, ['A13', 'A14'])
  })

  await t.test('自由文本库位不占网格位置', () => {
    // 「抽屉3-格5」不在网格内，不影响网格分配
    const res = allocateFreeCells(['抽屉3-格5'], 2)
    assert.deepEqual(res.cells, ['A11', 'A12'])
  })

  await t.test('被合并吞掉的非主格不参与分配', () => {
    // A11~A13 合并，主格 A11。A12/A13 已不是独立库位，不能分给别的料。
    const merges = [
      { layer: 'A', startRow: 1, startCol: 1, endRow: 1, endCol: 3, primary: 'A11' }
    ]
    const res = allocateFreeCells([], 3, merges)
    // A11 是主格且空着，可分；A12/A13 被吞掉，跳到 A14
    assert.deepEqual(res.cells, ['A11', 'A14', 'A15'])
  })

  await t.test('落在合并区内的已占库位归到主格，主格不被重复分配', () => {
    const merges = [
      { layer: 'A', startRow: 1, startCol: 1, endRow: 1, endCol: 2, primary: 'A11' }
    ]
    // 料记在 A12（合并前存的），归到 A11 → A11 已占用
    const res = allocateFreeCells(['A12'], 2, merges)
    assert.ok(!res.cells.includes('A11'), 'A11 已被占用，不该再分配')
    assert.ok(!res.cells.includes('A12'), 'A12 被合并吞掉，不是独立库位')
    assert.deepEqual(res.cells, ['A13', 'A14'])
  })

  await t.test('请求数超过剩余时分到几个算几个，并如实汇报不够', () => {
    // 不整批失败：分到的先用上，剩下的留空由人工处理，比全失败有用
    const almostFull = allGridCells().slice(0, 26 * 25 - 2)
    const res = allocateFreeCells(almostFull, 5)
    assert.equal(res.cells.length, 2, '只剩 2 格就只分 2 个')
    assert.equal(res.enough, false)
    assert.equal(res.available, 2)
  })

  await t.test('网格占满时返回空数组而不报错', () => {
    const res = allocateFreeCells(allGridCells(), 3)
    assert.deepEqual(res.cells, [])
    assert.equal(res.enough, false)
    assert.equal(res.available, 0)
  })

  await t.test('请求 0 个返回空数组且视为够分', () => {
    const res = allocateFreeCells([], 0)
    assert.deepEqual(res.cells, [])
    assert.equal(res.enough, true)
  })

  await t.test('分配结果无重复', () => {
    const res = allocateFreeCells([], 100)
    assert.equal(new Set(res.cells).size, res.cells.length)
  })
})
