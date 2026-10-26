import express from 'express'
import { db } from '../db/index.js'
import { buildKeywordFilter, foldedColumn } from '../search.js'

const router = express.Router()

// BOM 自身的可编辑列。
// 刻意不含 status / stock / location：按业务约定这三项属于库存台账，
// BOM 页面通过 mfr_pn 动态关联 inventory 获取，不在 BOM 里重复维护。
// materials 表中的同名旧列保留不动，只是不再由接口写入，避免破坏历史数据。
//
// 同样刻意不含 src_mfr_pn / src_mfr / src_supplier / src_supplier_pn / bound_at：
// 那 5 列是「手动绑定前的原导入值快照」与绑定标记（见 db/migrate-materials-bind.js）。
// 下面的 normalize() 会把这份列表里的每一列都写成 String(raw ?? '')，
// 加进来会让每次批量导入都把快照清空、绑定标记抹掉，功能静默失效。
// 它们只由 POST /:id/bind 写入，由 PUT /:id 与 bulk replace 显式重置。
const EDITABLE_COLUMNS = [
  'product_id',
  'seq',
  'name',
  'designator',
  'package',
  'qty',
  'mfr_pn',
  'mfr',
  'supplier',
  'supplier_pn',
  'remark'
]

// 数值列，统一走 Number() 兜底
const NUMERIC_COLUMNS = new Set(['seq', 'qty'])

// 模糊搜索覆盖的列（均为 BOM 自有列）
const SEARCH_COLUMNS = [
  'name',
  'designator',
  'package',
  'mfr_pn',
  'mfr',
  'supplier_pn',
  'remark'
]

// 排序白名单：绝不把用户输入直接拼进 SQL
const SORTABLE_COLUMNS = new Set([
  // BOM 自有列
  'seq',
  'name',
  'designator',
  'package',
  'qty',
  'mfr_pn',
  'mfr',
  'supplier',
  'supplier_pn',
  'updated_at',
  'id',
  // 库存动态带出的列
  'status',
  'stock',
  'location',
  // 派生列
  'required',
  'shortage',
  'solderedQty'
])

// status / stock / location 来自 inventory，排序时要加 i. 前缀
const INVENTORY_SORTS = new Set(['status', 'stock', 'location'])

// 派生列在 SELECT 里已有别名（required / shortage / solderedQty），
// 排序时直接用别名，不能加 m. 或 i. 前缀——那些表里并没有这些列。
const DERIVED_SORTS = new Set(['required', 'shortage', 'solderedQty'])

// 库存状态只有两种，由库存量派生（与 routes/inventory.js 保持一致）：
//   stock <= 0 → 缺货 / stock > 0 → 正常
// 未匹配到库存的 BOM 行没有状态，为 NULL。
const INV_STATUS_EXPR = "CASE WHEN i.id IS NULL THEN NULL WHEN i.stock > 0 THEN '正常' ELSE '缺货' END"

const MAX_PAGE_SIZE = 500

/**
 * 归一化入参：POST / PUT / bulk 三处共用，避免逻辑重复。
 * @param {object} input 原始请求体
 * @param {boolean} partial true 时只处理 input 中实际出现的键（供 PUT 局部更新）
 */
function normalize(input = {}, { partial = false } = {}) {
  const out = {}
  for (const col of EDITABLE_COLUMNS) {
    if (partial && !Object.prototype.hasOwnProperty.call(input, col)) continue

    const raw = input[col]
    if (col === 'product_id') {
      // 产品归属：无效值一律写 null，不能兜底成 0（0 不是有效产品）
      const n = Number(raw)
      out[col] = Number.isFinite(n) && n > 0 ? Math.floor(n) : null
    } else if (NUMERIC_COLUMNS.has(col)) {
      const n = Number(raw)
      out[col] = Number.isFinite(n) && n > 0 ? Math.floor(n) : 0
    } else {
      out[col] = String(raw ?? '').trim()
    }
  }
  return out
}

/** 把 SQLite 唯一约束冲突翻译成 409 + 中文消息 */
function isUniqueViolation(err) {
  return err && (err.code === 'SQLITE_CONSTRAINT_UNIQUE' || err.code === 'SQLITE_CONSTRAINT_PRIMARYKEY')
}

function conflictMessage(designator) {
  return `位号 ${designator || ''} 在该产品下已被占用`.replace(/\s+/g, ' ').trim()
}

const findById = db.prepare('SELECT * FROM materials WHERE id = ?')
const productExists = db.prepare('SELECT 1 FROM products WHERE id = ?')

// 制作套数：缺料按"做 N 套"计算，默认 1 套
const DEFAULT_SETS = 1
const MAX_SETS = 9999

function parseSets(raw) {
  const n = Number(raw)
  if (!Number.isFinite(n) || n < 1) return DEFAULT_SETS
  return Math.min(Math.floor(n), MAX_SETS)
}

// 缺料口径（sets = 制作套数）：
//   需求量 = 本板用量 × 套数
//   缺料   = 需求量 − 可用库存，最小为 0
// 没有制造商料号、或库存台账里查无此料，都视为可用库存 0 → 按全缺算，
// 这样"未匹配"的行也能算出要买多少，不再是 NULL。
function shortageExpr(sets) {
  return `MAX(m.qty * ${sets} - COALESCE(i.stock, 0), 0)`
}

// 焊接进度筛选的合法取值。放成白名单：solderState 会参与拼 SQL，
// 必须先命中白名单才允许进入 soldStateExpr。
const SOLDER_STATES = new Set(['unfinished', 'done', 'over'])

// 已焊接量的自包含标量子查询。
// 之所以不复用 selectWithStock 里那个 LEFT JOIN 别名 s.solderedQty：
// 列表和分页 COUNT 共用同一份 whereSql，而 COUNT 查询只 join 了 inventory，
// 没有 soldered 派生表，引用别名会直接 SQL 报错。
//
// 口径与列表列完全一致：-SUM(delta)，出库为负、撤销补偿入库为正，净额自动归零。
const SOLDERED_SCALAR = `(
  SELECT COALESCE(-SUM(l.delta), 0)
  FROM inventory_log l
  WHERE l.material_id = m.id
)`

/**
 * 焊接进度筛选条件。基准是 required（用量 × 套数），不是单板用量——
 * 领料按套领，做 2 套时领满 2×qty 才算焊完。因此结果随套数变化。
 *
 *   unfinished 未焊完：已焊接 < 需求（含完全没领过的 0）
 *   done       已焊完：已焊接 = 需求
 *   over       超领  ：已焊接 > 需求（补料/损耗/误操作）
 *
 * 注意 qty=0 的行：需求为 0，没领过时 0 = 0 判为「已焊完」而非「未焊完」，
 * 符合直觉（不需要的料确实不用焊）。
 */
function soldStateExpr(state, sets) {
  const required = `m.qty * ${sets}`
  if (state === 'unfinished') return `${SOLDERED_SCALAR} < ${required}`
  if (state === 'over') return `${SOLDERED_SCALAR} > ${required}`
  return `${SOLDERED_SCALAR} = ${required}` // done
}

// 同规格候选数：台账里「名称 + 封装」都与本行相同、且能作为关联依据（料号非空）
// 的库存记录有几条。用于列表里提示「这行有别的同规格料可以选」，
// 否则用户得逐行点开弹框才知道有没有，功能等于藏起来了。
//
// 与 mfr_pn 关联是两个独立维度：本行可能已关联某个料号，但同规格还有另一个
// 库存充足的替代料号 —— 那才是这个提示最有价值的场景（缺料时换替代品）。
//
// 口径必须与 GET /api/inventory/match 完全一致，否则列表提示 N 条、
// 点开弹框却是另一个数，比没有提示更糟：
//   - 两侧都过 foldedColumn 做等价字符归一（Ω 的两种码点）
//   - 封装为空时只比名称（结构件常不填封装）
//   - 排除料号为空的记录：它们绑不上（JOIN 有 mfr_pn <> '' 守卫）
//
// 写成标量子查询而不是 JOIN：列表与分页 COUNT 共用同一份 whereSql，
// COUNT 查询只 join 了 inventory，引用派生表别名会直接 SQL 报错
// （与 SOLDERED_SCALAR 同样的理由）。
const SAME_SPEC_SCALAR = `(
  SELECT COUNT(*)
  FROM inventory sc
  WHERE TRIM(sc.mfr_pn) <> ''
    AND ${foldedColumn('sc.name')} = ${foldedColumn('m.name')}
    AND (TRIM(m.package) = '' OR ${foldedColumn('sc.package')} = ${foldedColumn('m.package')})
)`

// 同规格里「就是本行当前关联料号」的条数。
//
// 前端要算的是「有几条可以换过去」，等于 sameSpecCount 减掉当前料号占的条数。
// 必须由后端精确给出而不能让前端猜 1：mfr_pn 没有唯一约束，同一料号在台账里
// 可能有多条记录（README「注意」一节），前端拿不到这个明细，
// 猜错会让角标数字与弹框实际列出的条数不一致。
const SAME_SPEC_CURRENT_SCALAR = `(
  SELECT COUNT(*)
  FROM inventory sc
  WHERE TRIM(sc.mfr_pn) <> ''
    AND sc.mfr_pn = m.mfr_pn
    AND ${foldedColumn('sc.name')} = ${foldedColumn('m.name')}
    AND (TRIM(m.package) = '' OR ${foldedColumn('sc.package')} = ${foldedColumn('m.package')})
)`

// BOM 行 → 库存的动态关联：按制造商料号匹配，不落库。
// 库存改动后 BOM 页立刻反映，无需维护任何关联关系。
//
// 字段归属（按业务约定）：
//   BOM 自有：序号 / 名称 / 位号 / 封装 / 数量 / 制造商料号 / 制造商 / 供应商 / 供应商料号 / 备注
//   库存动态带出：状态 status / 库存 stock / 位置 location
//   计算得出：已焊接量 solderedQty / 同规格候选数 sameSpecCount
//
// 已焊接量必须先按 material_id 在派生表里聚合好，再 LEFT JOIN 到 materials：
// inventory.mfr_pn 没有唯一约束，多个库存行可能共享同一 mfr_pn，
// 若直接把 inventory_log 拼进现有的 materials × inventory 连接，
// 聚合和会被行数放大而重复计数。
// 关键不变量：material_id 只出现在"出库"行及其撤销补偿的"入库"行；
// 盘点/初始/普通入库行绝没有 material_id，否则 -SUM(delta) 会被污染。
function selectWithStock(sets) {
  return `
  SELECT m.id, m.product_id, m.seq, m.name, m.designator, m.package, m.qty,
         m.mfr_pn, m.mfr, m.supplier, m.supplier_pn, m.remark,
         m.created_at, m.updated_at,
         m.src_mfr_pn, m.src_mfr, m.src_supplier, m.src_supplier_pn, m.bound_at,
         i.id          AS inventory_id,
         ${INV_STATUS_EXPR} AS status,
         i.stock       AS stock,
         i.location    AS location,
         i.name        AS inventory_name,
         i.mfr_pn      AS inventory_mfr_pn,
         i.mfr         AS inventory_mfr,
         i.supplier    AS inventory_supplier,
         i.supplier_pn AS inventory_supplier_pn,
         COALESCE(s.solderedQty, 0) AS solderedQty,
         ${SAME_SPEC_SCALAR}    AS sameSpecCount,
         ${SAME_SPEC_CURRENT_SCALAR} AS sameSpecCurrentCount,
         ${sets}                AS sets,
         m.qty * ${sets}        AS required,
         ${shortageExpr(sets)}  AS shortage
  FROM materials m
  LEFT JOIN inventory i
    ON m.mfr_pn <> '' AND i.mfr_pn = m.mfr_pn
  LEFT JOIN (
    SELECT material_id, COALESCE(-SUM(delta), 0) AS solderedQty
    FROM inventory_log
    WHERE material_id IS NOT NULL
    GROUP BY material_id
  ) s ON s.material_id = m.id
`
}

// 单条查询固定按 1 套返回；列表/汇总走各自的 sets 参数
const findByIdWithStock = db.prepare(`${selectWithStock(DEFAULT_SETS)} WHERE m.id = ?`)

// ---------------------------------------------------------------------------
// GET /  列表：产品筛选 + 搜索 + 状态/匹配筛选 + 服务端排序分页
//        每行附带按 mfr_pn 动态匹配到的库存、位置、状态与缺料数
// ---------------------------------------------------------------------------
router.get('/', (req, res, next) => {
  try {
    const where = []
    const params = []

    // 制作套数：缺料 = 用量 × 套数 − 库存
    const sets = parseSets(req.query.sets)

    // 产品筛选：BOM 属于某个产品，前端切换产品时传 productId
    const productId = Number(req.query.productId)
    if (Number.isFinite(productId) && productId > 0) {
      where.push('m.product_id = ?')
      params.push(Math.floor(productId))
    }

    // 关键词按空格分词：词间 AND、列间 OR，所以「名称 + 封装」这类
    // 跨列组合（如 `04381.25WR F0603`）能查到。单词行为与以前一致。
    const keywordFilter = buildKeywordFilter(req.query.q, SEARCH_COLUMNS, 'm.')
    if (keywordFilter) {
      where.push(keywordFilter.sql)
      params.push(...keywordFilter.params)
    }

    // 状态来自库存台账且是派生值，用表达式过滤
    const statusFilter = String(req.query.status ?? '').trim()
    if (statusFilter) {
      where.push(`${INV_STATUS_EXPR} = ?`)
      params.push(statusFilter)
    }

    // matchState: matched 已匹配库存 / unmatched 未匹配 / shortage 缺料
    // 缺料判定随套数变化，未匹配的行也算缺料（可用库存视为 0）
    const matchState = String(req.query.matchState ?? '').trim()
    if (matchState === 'matched') where.push('i.id IS NOT NULL')
    else if (matchState === 'unmatched') where.push("(m.mfr_pn = '' OR i.id IS NULL)")
    else if (matchState === 'shortage') where.push(`${shortageExpr(sets)} > 0`)

    // solderState: unfinished 未焊完 / done 已焊完 / over 超领
    // 基准是 required（用量 × 套数）而不是单板用量：领料本来就是按套领的，
    // 做 2 套时领满 2×qty 才算焊完。所以这个筛选结果会随工具栏套数变化，
    // 与缺料筛选同理。
    //
    // 这里用自包含的标量子查询而不是 selectWithStock 里那个 LEFT JOIN 别名：
    // 下面的 COUNT 查询只 join 了 inventory，没有 soldered 派生表，
    // 引用 s.solderedQty 会直接报错，两个查询共用 whereSql 就必须自包含。
    const solderState = String(req.query.solderState ?? '').trim()
    if (SOLDER_STATES.has(solderState)) {
      where.push(`${soldStateExpr(solderState, sets)}`)
    }

    const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : ''

    // 排序列必须命中白名单后才允许插入 SQL
    const rawSort = String(req.query.sortBy)
    const sortBy = SORTABLE_COLUMNS.has(rawSort) ? rawSort : 'seq'
    const sortOrder = String(req.query.sortOrder).toLowerCase() === 'desc' ? 'DESC' : 'ASC'
    const orderExpr =
      DERIVED_SORTS.has(sortBy)
        ? sortBy
        : sortBy === 'status'
          ? INV_STATUS_EXPR
          : INVENTORY_SORTS.has(sortBy)
            ? `i.${sortBy}`
            : `m.${sortBy}`

    const page = Math.max(1, Number(req.query.page) || 1)
    const rawSize = Number(req.query.pageSize) || 50
    const pageSize = Math.min(Math.max(1, rawSize), MAX_PAGE_SIZE)
    const offset = (page - 1) * pageSize

    const { total } = db
      .prepare(
        `SELECT COUNT(*) AS total
         FROM materials m
         LEFT JOIN inventory i ON m.mfr_pn <> '' AND i.mfr_pn = m.mfr_pn
         ${whereSql}`
      )
      .get(...params)

    const list = db
      .prepare(
        `${selectWithStock(sets)} ${whereSql}
         ORDER BY ${orderExpr} ${sortOrder}, m.id ASC
         LIMIT ? OFFSET ?`
      )
      .all(...params, pageSize, offset)

    res.json({ list, total, page, pageSize, sets })
  } catch (err) {
    next(err)
  }
})

// ---------------------------------------------------------------------------
// GET /stats  汇总（必须注册在 /:id 之前，否则会被参数路由吞掉）
//   传 productId 时只统计该产品；传 sets 指定制作套数（默认 1 套）。
//   库存与缺料一律按 mfr_pn 动态匹配库存台账：
//     需求量 = 用量 × 套数，缺料 = 需求量 − 库存（未匹配的库存按 0 算）
// ---------------------------------------------------------------------------
router.get('/stats', (req, res, next) => {
  try {
    const productId = Number(req.query.productId)
    const scoped = Number.isFinite(productId) && productId > 0
    const whereProduct = scoped ? 'WHERE m.product_id = ?' : ''
    const args = scoped ? [Math.floor(productId)] : []
    const sets = parseSets(req.query.sets)
    const shortSql = shortageExpr(sets)

    const base = db
      .prepare(
        `SELECT COUNT(*) AS total,
                COALESCE(SUM(m.qty), 0) AS totalQty,
                COALESCE(SUM(m.qty * ${sets}), 0) AS totalRequired
         FROM materials m ${whereProduct}`
      )
      .get(...args)

    const statusCounts = db
      .prepare(
        `SELECT COALESCE(${INV_STATUS_EXPR}, '未匹配') AS status, COUNT(*) AS count
         FROM materials m
         LEFT JOIN inventory i ON m.mfr_pn <> '' AND i.mfr_pn = m.mfr_pn
         ${whereProduct}
         GROUP BY COALESCE(${INV_STATUS_EXPR}, '未匹配')
         ORDER BY count DESC, status ASC`
      )
      .all(...args)

    const match = db
      .prepare(
        `SELECT
           COALESCE(SUM(CASE WHEN i.id IS NOT NULL THEN 1 ELSE 0 END), 0) AS matchedLines,
           COALESCE(SUM(CASE WHEN m.mfr_pn = '' OR i.id IS NULL THEN 1 ELSE 0 END), 0) AS unmatchedLines,
           COALESCE(SUM(CASE WHEN ${shortSql} > 0 THEN 1 ELSE 0 END), 0) AS shortage,
           COALESCE(SUM(${shortSql}), 0) AS shortageQty,
           COALESCE(SUM(CASE WHEN i.id IS NOT NULL THEN i.stock ELSE 0 END), 0) AS totalStock
         FROM materials m
         LEFT JOIN inventory i ON m.mfr_pn <> '' AND i.mfr_pn = m.mfr_pn
         ${whereProduct}`
      )
      .get(...args)

    // 未匹配的行里，真正"能建进台账"的料号种数。
    // 与 unmatchedLines 刻意分开：后者是行数且含无料号的行，
    // 而建档按 mfr_pn 去重、且跳过空料号 —— 直接拿行数展示会和实际建出的条数对不上。
    const { adoptableKinds } = db
      .prepare(
        `SELECT COUNT(*) AS adoptableKinds FROM (
           SELECT m.mfr_pn
           FROM materials m
           ${scoped ? 'WHERE m.product_id = ? AND' : 'WHERE'} m.mfr_pn <> ''
             AND NOT EXISTS (SELECT 1 FROM inventory i WHERE i.mfr_pn = m.mfr_pn)
           GROUP BY m.mfr_pn
         )`
      )
      .get(...args)

    // 无制造商料号的行：建档建不了（关联依据就是它），单独告知
    const { noPnLines } = db
      .prepare(
        `SELECT COUNT(*) AS noPnLines FROM materials m
         ${scoped ? 'WHERE m.product_id = ? AND' : 'WHERE'} m.mfr_pn = ''`
      )
      .get(...args)

    // 已焊接统计同样先按 material_id 聚合，再 LEFT JOIN，避免 inventory 行重复导致 double count
    const soldered = db
      .prepare(
        `SELECT
           COALESCE(SUM(CASE WHEN s.solderedQty > 0 THEN 1 ELSE 0 END), 0) AS solderedLines,
           COALESCE(SUM(s.solderedQty), 0) AS solderedQty
         FROM materials m
         LEFT JOIN (
           SELECT material_id, COALESCE(-SUM(delta), 0) AS solderedQty
           FROM inventory_log
           WHERE material_id IS NOT NULL
           GROUP BY material_id
         ) s ON s.material_id = m.id
         ${whereProduct}`
      )
      .get(...args)

    res.json({ ...base, ...match, adoptableKinds, noPnLines, ...soldered, statusCounts, sets })
  } catch (err) {
    next(err)
  }
})

// ---------------------------------------------------------------------------
// GET /usage  某个制造商料号被哪些产品的哪些 BOM 行用到
//   查询串传料号（?mfrPn=...）而不是放路径参数：料号里可能有 / 与 #
//   （如 'ABC/1.5' ），放路径就得双重编码，容易在某一环被解掉。
//   注册在 /:id 之前，否则 'usage' 会被参数路由当成 id 吞掉。
//
// 给库存关联弹框用：一条库存料号可能被多个产品的 BOM 同时引用，
// 换料号之前需要知道「这个料现在谁在用、用了多少」，否则是在盲改。
//
// 按产品聚合成两层（产品 → 该产品下的 BOM 行）而不是平铺行列表：
// 用户的问题是「哪些产品会受影响」，产品是主语。真实数据里单个料号
// 最多跨 2 个产品、2 行 BOM，所以不分页也不限条数。
//
// 已领量口径与列表列完全一致：-SUM(delta) 净额（出库为负、撤销补偿为正），
// 不能按 type='出库' 过滤 —— 已撤销的出库会被算成已领。
// ---------------------------------------------------------------------------
router.get('/usage', (req, res, next) => {
  try {
    const mfrPn = String(req.query.mfrPn ?? '').trim()
    // 空料号会 JOIN 上所有无料号的 BOM 行，语义上是「查所有没料号的」，不是本意
    if (!mfrPn) return res.status(400).json({ error: '制造商料号不能为空' })

    const rows = db
      .prepare(
        `SELECT m.id, m.seq, m.name, m.designator, m.package, m.qty,
                m.bound_at,
                p.id   AS product_id,
                p.code AS product_code,
                p.name AS product_name,
                ${SOLDERED_SCALAR} AS solderedQty
         FROM materials m
         LEFT JOIN products p ON p.id = m.product_id
         WHERE m.mfr_pn = ?
         ORDER BY p.code ASC, m.seq ASC, m.id ASC`
      )
      .all(mfrPn)

    // 按产品分组。Map 保序，上面已按 product code 排过，所以分组顺序稳定。
    const byProduct = new Map()
    for (const r of rows) {
      // product_id 理论上非空（migrateProducts 已把历史行归入默认产品），
      // 但 LEFT JOIN 仍可能因数据异常拿到 null，单独归一组而不是丢掉 ——
      // 丢掉会让「用量合计」和 BOM 页对不上。
      const key = r.product_id ?? 0
      if (!byProduct.has(key)) {
        byProduct.set(key, {
          product_id: r.product_id,
          product_code: r.product_code ?? '(无归属产品)',
          product_name: r.product_name ?? '',
          lines: [],
          qty: 0,          // 该产品下这个料号的单板用量合计
          solderedQty: 0   // 已领（已焊接）合计
        })
      }
      const g = byProduct.get(key)
      g.lines.push({
        id: r.id,
        seq: r.seq,
        name: r.name,
        designator: r.designator,
        package: r.package,
        qty: r.qty,
        solderedQty: r.solderedQty,
        // 这一行本身是不是手动绑定过来的 —— 说明它当前的料号是绑定结果而非导入值
        bound: Boolean(r.bound_at)
      })
      g.qty += Number(r.qty) || 0
      g.solderedQty += Number(r.solderedQty) || 0
    }

    const products = [...byProduct.values()]
    res.json({
      mfrPn,
      products,
      productCount: products.length,
      lineCount: rows.length,
      totalQty: products.reduce((s, p) => s + p.qty, 0),
      totalSolderedQty: products.reduce((s, p) => s + p.solderedQty, 0)
    })
  } catch (err) {
    next(err)
  }
})

// ---------------------------------------------------------------------------
// GET /:id  单条（带库存动态关联）
// ---------------------------------------------------------------------------
router.get('/:id', (req, res, next) => {
  try {
    const row = findByIdWithStock.get(Number(req.params.id))
    if (!row) return res.status(404).json({ error: '物料不存在' })
    res.json(row)
  } catch (err) {
    next(err)
  }
})

// ---------------------------------------------------------------------------
// POST /  新增（必须指定所属产品）
// ---------------------------------------------------------------------------
router.post('/', (req, res, next) => {
  try {
    const data = normalize(req.body)
    if (!data.name) return res.status(400).json({ error: '名称不能为空' })
    if (!data.product_id) return res.status(400).json({ error: '请先选择所属产品' })
    if (!productExists.get(data.product_id)) {
      return res.status(400).json({ error: '所属产品不存在' })
    }

    const info = db
      .prepare(
        `INSERT INTO materials (${EDITABLE_COLUMNS.join(', ')})
         VALUES (${EDITABLE_COLUMNS.map(() => '?').join(', ')})`
      )
      .run(...EDITABLE_COLUMNS.map(c => data[c]))

    res.status(201).json(findByIdWithStock.get(info.lastInsertRowid))
  } catch (err) {
    if (isUniqueViolation(err)) {
      return res.status(409).json({ error: conflictMessage(req.body?.designator) })
    }
    next(err)
  }
})

// ---------------------------------------------------------------------------
// PUT /:id  局部更新：只写请求体里实际出现的字段
//   status / stock / location 不属于 BOM，改这些请去库存台账
// ---------------------------------------------------------------------------
router.put('/:id', (req, res, next) => {
  try {
    const id = Number(req.params.id)
    const current = findById.get(id)
    if (!current) return res.status(404).json({ error: '物料不存在' })

    const patch = normalize(req.body, { partial: true })
    const keys = Object.keys(patch)
    if (keys.length === 0) return res.status(400).json({ error: '没有需要更新的字段' })

    if (Object.prototype.hasOwnProperty.call(patch, 'name') && !patch.name) {
      return res.status(400).json({ error: '名称不能为空' })
    }
    if (Object.prototype.hasOwnProperty.call(patch, 'product_id')) {
      if (!patch.product_id) return res.status(400).json({ error: '所属产品不能为空' })
      if (!productExists.get(patch.product_id)) {
        return res.status(400).json({ error: '所属产品不存在' })
      }
    }

    // 手改 mfr_pn 就意味着这行不再是「绑定」的结果：料号是关联库存的唯一依据，
    // 用户自己改了它，就不该再按绑定态显示库存字段。把绑定标记与快照一起清掉，
    // 让这行干净地回到「未绑定的导入行」。
    // 只在料号真的变了时才清 —— 编辑弹窗会把四个字段整体提交，
    // 只改了制造商/供应商（不影响匹配）时不该误清绑定态。
    // 变量名避开 sets：本文件里 sets 一律指「制作套数」。
    const assignments = keys.map(k => `${k} = ?`)
    const values = keys.map(k => patch[k])
    if (Object.prototype.hasOwnProperty.call(patch, 'mfr_pn') && patch.mfr_pn !== current.mfr_pn) {
      assignments.push(
        "src_mfr_pn = ''",
        "src_mfr = ''",
        "src_supplier = ''",
        "src_supplier_pn = ''",
        'bound_at = NULL'
      )
    }

    db.prepare(`UPDATE materials SET ${assignments.join(', ')} WHERE id = ?`).run(...values, id)

    res.json(findByIdWithStock.get(id))
  } catch (err) {
    if (isUniqueViolation(err)) {
      return res.status(409).json({ error: conflictMessage(req.body?.designator) })
    }
    next(err)
  }
})

// ---------------------------------------------------------------------------
// POST /:id/bind  把某条库存记录的制造商料号绑定到 BOM 行
//
// 为什么要独立端点而不复用 PUT /:id：两者都会写 mfr_pn，但语义相反 ——
// 绑定要留原值快照，手改要清掉快照。走同一个端点就分不出是谁在改，
// 手改会被误当成绑定（反之亦然）。
//
// 三条硬约束（改动前务必读，来自设计评审）：
//   1. 只写 mfr_pn，绝不把库存的 mfr/supplier/supplier_pn 写进 BOM 那三列。
//      那样会永久毁掉原导入值，也等于把库存数据存进 BOM（违背核心设计 §1）。
//      表格里显示库存值是渲染层的事，靠 selectWithStock 带出的 i.* 完成。
//   2. 快照只在「首次绑定」（bound_at IS NULL）时写。重复绑定保留最初的原导入值，
//      否则第二次绑定会把上一次绑上的库存料号当成"原值"存进去，越绑越偏。
//   3. 快照只从 m.* 抄，绝不从 i.* 抄。
//
// 刻意**不**限制目标库存量。曾考虑「库存必须 > 50 才能绑」（理由是换个本身也
// 缺货的替代品等于没解决问题），但绑不绑是使用者的判断：先绑上再采购、
// 或明知不够也要先记录关联，都是合理用法。后端不替人做这个决定，
// 弹框里只做提示（见 InventoryMatchDialog.vue 的库存偏低标注）。
// ---------------------------------------------------------------------------
router.post('/:id/bind', (req, res, next) => {
  try {
    const id = Number(req.params.id)
    const row = findById.get(id)
    if (!row) return res.status(404).json({ error: '物料不存在' })

    const mfrPn = String(req.body?.mfr_pn ?? '').trim()
    // 空料号绑不上：JOIN 有 mfr_pn <> '' 守卫，绑了等于没绑，还会擦掉原有料号
    if (!mfrPn) return res.status(400).json({ error: '制造商料号不能为空' })

    // 该料号在台账里必须真实存在，否则绑完还是「未匹配」，等于什么也没做
    const exists = db.prepare('SELECT 1 FROM inventory WHERE mfr_pn = ?').get(mfrPn)
    if (!exists) return res.status(400).json({ error: '库存台账里没有这个制造商料号' })

    const firstBind = !row.bound_at
    // 是否同时删除旧库存记录（由前端确认框传来）
    const deleteOld = !!req.body?.deleteOld

    const bind = db.transaction(() => {
      // 换绑时：旧库存记录是否删除由用户决定。
      // 删除不可恢复（库存 + 流水一起清），所以必须由前端弹确认框、
      // 用户明确点「确认删除」后才传 deleteOld=true 过来。
      // 不删除则旧记录保留原样，只是不再被这行 BOM 关联。
      if (deleteOld && row.mfr_pn && row.mfr_pn !== mfrPn) {
        // 先清外键依赖（流水），再删库存记录
        const oldItem = db.prepare('SELECT id FROM inventory WHERE mfr_pn = ?').get(row.mfr_pn)
        if (oldItem) {
          db.prepare('DELETE FROM inventory_log WHERE inventory_id = ?').run(oldItem.id)
          db.prepare('DELETE FROM inventory WHERE id = ?').run(oldItem.id)
        }
      }

      if (firstBind) {
        // 首次绑定：把绑定前的四个字段原样留档，再覆盖 mfr_pn
        db.prepare(
          `UPDATE materials
           SET src_mfr_pn = mfr_pn,
               src_mfr = mfr,
               src_supplier = supplier,
               src_supplier_pn = supplier_pn,
               bound_at = datetime('now', 'localtime'),
               mfr_pn = ?
           WHERE id = ?`
        ).run(mfrPn, id)
      } else {
        // 重复绑定：只换料号，快照保持首次那份（那才是"原导入的信息"）
        db.prepare(
          `UPDATE materials
           SET mfr_pn = ?, bound_at = datetime('now', 'localtime')
           WHERE id = ?`
        ).run(mfrPn, id)
      }
    })
    bind()

    res.json({ ...findByIdWithStock.get(id), firstBind })
  } catch (err) {
    next(err)
  }
})

// ---------------------------------------------------------------------------
// DELETE /by-product/:productId  清空某产品的全部 BOM 明细（保留产品本身）
//   注册在 /:id 之前，否则 'by-product' 会被参数路由当成 id 吞掉。
//
//   与 DELETE /products/:id?withBom=1 的区别：那个连产品一起删，这个只清明细，
//   产品、编号、备注都留着，适合「这版 BOM 作废，重新导一份」。
//
//   刻意不删 inventory_log：
//     - 已领出去的料是真的领走了，不该因为删 BOM 就凭空退回库存
//     - 流水带 product_id，产品级领料history 仍然可查
//   代价是这些流水的 material_id 会悬空（该列无外键），行级「已焊接」进度
//   永久丢失且无法重建 —— 重新导入会生成新 id，对不回去。
//   所以要把已领料行数一并返回，让前端在确认框里把后果说清楚。
// ---------------------------------------------------------------------------
router.delete('/by-product/:productId', (req, res, next) => {
  try {
    const productId = Number(req.params.productId)
    if (!Number.isFinite(productId) || productId <= 0) {
      return res.status(400).json({ error: '产品参数无效' })
    }
    if (!productExists.get(productId)) {
      return res.status(404).json({ error: '产品不存在' })
    }

    // 删之前先数：删完就查不到了，而前端要用这个数字给出反馈
    const { c: solderedLines } = db
      .prepare(
        `SELECT COUNT(*) AS c FROM materials m
         WHERE m.product_id = ?
           AND EXISTS (SELECT 1 FROM inventory_log l WHERE l.material_id = m.id)`
      )
      .get(productId)

    // 单事务：要么整份清空，要么什么都不动，不留下删一半的 BOM
    const clear = db.transaction(() => {
      return db.prepare('DELETE FROM materials WHERE product_id = ?').run(productId).changes
    })

    // 明细本来就为空时 removed=0，不报错 —— 幂等，重复点没有副作用
    res.json({ ok: true, productId, removed: clear(), solderedLines })
  } catch (err) {
    next(err)
  }
})

// ---------------------------------------------------------------------------
// DELETE /:id
// ---------------------------------------------------------------------------
router.delete('/:id', (req, res, next) => {
  try {
    const id = Number(req.params.id)
    const info = db.prepare('DELETE FROM materials WHERE id = ?').run(id)
    if (info.changes === 0) return res.status(404).json({ error: '物料不存在' })
    res.json({ ok: true, id })
  } catch (err) {
    next(err)
  }
})

// ---------------------------------------------------------------------------
// POST /bulk  批量导入：单事务；空名称行跳过而不是整批失败
//   必须指定 productId，导入的行全部归入该产品。
//   mode='replace' 按位号（designator）在本产品内做增删改 reconciliation：
//     - 位号已存在 → 更新该行，保留原 id（BOM 行与历史出库的 material_id 绑定不丢）
//     - 位号不存在 → 插入
//     - 已有位号未出现在导入数据 → 删除
//   空位号的处理：空字符串也是一位有效 key（UNIQUE(product_id, designator)），
//   但多个空位号行无法区分身份；若导入数据里出现重复空位号，只有第一条能
//   匹配/插入成功，其余会因唯一约束冲突被跳过并汇报，避免静默丢数据。
//   mode='append' 保持原有追加语义不变。
// ---------------------------------------------------------------------------
router.post('/bulk', (req, res, next) => {
  try {
    const { rows, mode = 'append' } = req.body || {}
    if (!Array.isArray(rows)) return res.status(400).json({ error: 'rows 必须是数组' })

    const rawPid = Number(req.body?.productId)
    if (!Number.isFinite(rawPid) || rawPid <= 0) {
      return res.status(400).json({ error: '请先选择要导入到哪个产品' })
    }
    const productId = Math.floor(rawPid)
    if (!productExists.get(productId)) {
      return res.status(400).json({ error: '所属产品不存在' })
    }

    const insert = db.prepare(
      `INSERT INTO materials (${EDITABLE_COLUMNS.join(', ')})
       VALUES (${EDITABLE_COLUMNS.map(() => '?').join(', ')})`
    )

    let inserted = 0
    let updated = 0
    let skipped = 0
    let removed = 0
    const errors = []

    const run = db.transaction(() => {
      if (mode === 'replace') {
        // 按位号建立现有行映射，用于后续 reconcile；绝不影响其他产品。
        const existingRows = db
          .prepare('SELECT id, designator FROM materials WHERE product_id = ?')
          .all(productId)
        const existingByDesignator = new Map()
        for (const row of existingRows) {
          // 同一位号在库中理论上不会重复（有唯一约束），万一有也以后出现者为准
          existingByDesignator.set(row.designator, row.id)
        }

        // replace 会用导入值覆盖 mfr_pn，此前的绑定就作废了 —— 必须同时清掉
        // 绑定快照与标记，否则 hover 显示的"原导入值"是这次重导之前的旧快照，
        // 与当前 mfr_pn 对不上，成了误导信息。
        // 这些列不在 EDITABLE_COLUMNS 里（那会让 normalize 把它们清成空值），
        // 所以必须在这里显式重置。重导 = BOM 重置，重新绑定即可。
        const updateAll = db.prepare(
          `UPDATE materials SET ${EDITABLE_COLUMNS.map(c => `${c} = ?`).join(', ')},
                 src_mfr_pn = '', src_mfr = '', src_supplier = '', src_supplier_pn = '',
                 bound_at = NULL
           WHERE id = ?`
        )

        rows.forEach((raw, i) => {
          // 行内自带的 product_id 一律忽略，统一归到本次导入的目标产品
          const data = normalize({ ...raw, product_id: productId })
          if (!data.name) {
            skipped++
            errors.push({ row: i + 1, error: '名称为空，已跳过' })
            return
          }

          const key = data.designator
          try {
            if (existingByDesignator.has(key)) {
              const id = existingByDesignator.get(key)
              // 先消耗掉这个位号，即使更新失败也不应把该行当作"已消失"删除
              existingByDesignator.delete(key)
              updateAll.run(...EDITABLE_COLUMNS.map(c => data[c]), id)
              updated++
            } else {
              insert.run(...EDITABLE_COLUMNS.map(c => data[c]))
              inserted++
            }
          } catch (err) {
            skipped++
            errors.push({
              row: i + 1,
              error: isUniqueViolation(err) ? conflictMessage(data.designator) : err.message
            })
          }
        })

        // 导入完成后仍留在 map 里的就是本次没出现的位号，按 replace 语义删除
        for (const id of existingByDesignator.values()) {
          db.prepare('DELETE FROM materials WHERE id = ?').run(id)
          removed++
        }
      } else {
        rows.forEach((raw, i) => {
          // 行内自带的 product_id 一律忽略，统一归到本次导入的目标产品
          const data = normalize({ ...raw, product_id: productId })
          if (!data.name) {
            skipped++
            errors.push({ row: i + 1, error: '名称为空，已跳过' })
            return
          }
          try {
            insert.run(...EDITABLE_COLUMNS.map(c => data[c]))
            inserted++
          } catch (err) {
            skipped++
            errors.push({
              row: i + 1,
              error: isUniqueViolation(err) ? conflictMessage(data.designator) : err.message
            })
          }
        })
      }
    })

    run()
    res.json({ inserted, updated, skipped, removed, errors })
  } catch (err) {
    next(err)
  }
})

// ---------------------------------------------------------------------------
// POST /issue  按产品批量出库（领料）
//   body: { productId, sets?, remark? }
//
//   逐行需求 = 用量 × 套数。只出库存完全够的行；不够的整行跳过不动库存，
//   避免"扣了一半料却装不出板"。跳过的行原样返回，便于据此下采购单。
//   全部变动在单个事务里完成，库存与流水一起写。
// ---------------------------------------------------------------------------
router.post('/issue', (req, res, next) => {
  try {
    const rawPid = Number(req.body?.productId)
    if (!Number.isFinite(rawPid) || rawPid <= 0) {
      return res.status(400).json({ error: '请先选择产品' })
    }
    const productId = Math.floor(rawPid)
    if (!productExists.get(productId)) {
      return res.status(400).json({ error: '产品不存在' })
    }

    const sets = parseSets(req.body?.sets)
    const remark = String(req.body?.remark ?? '').trim()
      || `${sets} 套领料`

    // 取该产品全部 BOM 行 + 当前库存快照
    const rows = db
      .prepare(
        `SELECT m.id, m.seq, m.name, m.designator, m.qty, m.mfr_pn,
                i.id AS inventory_id, i.stock AS stock
         FROM materials m
         LEFT JOIN inventory i ON m.mfr_pn <> '' AND i.mfr_pn = m.mfr_pn
         WHERE m.product_id = ?
         ORDER BY m.seq ASC, m.id ASC`
      )
      .all(productId)

    if (rows.length === 0) {
      return res.status(400).json({ error: '该产品还没有 BOM 明细' })
    }

    const updateStock = db.prepare('UPDATE inventory SET stock = ? WHERE id = ?')
    const insertLog = db.prepare(
      `INSERT INTO inventory_log (inventory_id, product_id, material_id, type, delta, stock_after, remark)
       VALUES (?, ?, ?, '出库', ?, ?, ?)`
    )

    const issued = []   // 成功出库的行
    const skipped = []  // 库存不足/未匹配，整行跳过

    const run = db.transaction(() => {
      // 同一个料号可能被多行 BOM 引用（不同位号用同一元件），
      // 必须累计扣减，否则会超发。这里按 inventory_id 记住已扣掉的量。
      const consumed = new Map()

      for (const r of rows) {
        const required = r.qty * sets

        if (!r.inventory_id) {
          skipped.push({
            id: r.id,
            seq: r.seq,
            name: r.name,
            designator: r.designator,
            mfr_pn: r.mfr_pn,
            required,
            stock: null,
            shortage: required,
            reason: r.mfr_pn ? '库存台账中查无此料号' : '没有制造商料号，无法关联库存'
          })
          continue
        }

        const used = consumed.get(r.inventory_id) ?? 0
        const available = (Number(r.stock) || 0) - used

        if (required <= 0) continue

        if (available < required) {
          skipped.push({
            id: r.id,
            seq: r.seq,
            name: r.name,
            designator: r.designator,
            mfr_pn: r.mfr_pn,
            required,
            stock: available,
            shortage: required - available,
            reason: '库存不足，整行未出库'
          })
          continue
        }

        const after = available - required
        updateStock.run(after, r.inventory_id)
        // 出库行必须绑定到 BOM 清单的具体行（material_id），产品才能知道这行料已领用焊接。
        // 撤销出库时，补偿入库行会继承同一 material_id，使 -SUM(delta) 自动归零。
        insertLog.run(r.inventory_id, productId, r.id, -required, after, remark)
        consumed.set(r.inventory_id, used + required)

        issued.push({
          id: r.id,
          seq: r.seq,
          name: r.name,
          designator: r.designator,
          mfr_pn: r.mfr_pn,
          issued: required,
          stockAfter: after
        })
      }
    })

    run()

    res.json({
      sets,
      remark,
      bomLines: rows.length,
      issuedLines: issued.length,
      skippedLines: skipped.length,
      issuedQty: issued.reduce((a, x) => a + x.issued, 0),
      shortageQty: skipped.reduce((a, x) => a + x.shortage, 0),
      issued,
      skipped
    })
  } catch (err) {
    next(err)
  }
})

export default router
