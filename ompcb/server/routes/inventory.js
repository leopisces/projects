import express from 'express'
import https from 'node:https'
import { db } from '../db/index.js'
import { buildKeywordFilter, foldedColumn, normalizeTerm } from '../search.js'
import { LOW_BIND_STOCK } from '../bind-rules.js'
// 库位网格解析：与前端共用同一份纯函数，规则由 test/location.test.js 锁定。
// 刻意不在 SQL 里重写空位计算——两处实现必然漂移。
import {
  findFreeLocations,
  allocateFreeCells,
  validateMerge,
  getMergeCells,
  formatLocation,
  allLayerCells,
  parseLocation,
  GRID_ROWS,
  GRID_COLS,
  LAYERS
} from '../../web/location.js'

const router = express.Router()

// 状态只有两种，且完全由库存量决定，不是可录入字段：
//   stock <= 0 → 缺货
//   stock >  0 → 正常
// 存成列必然会和 stock 不一致，所以一律用 SQL 派生。
const STATUS_EXPR = "CASE WHEN stock > 0 THEN '正常' ELSE '缺货' END"

// 可编辑列（不含 id / created_at / updated_at）
// stock 刻意不在此列：库存只能通过 /move 出入库变动，保证流水与库存永远一致
// status 也不在此列：它由 stock 派生，见 STATUS_EXPR
const EDITABLE_COLUMNS = [
  'name',
  'package',
  'mfr_pn',
  'mfr',
  'supplier',
  'supplier_pn',
  'location',
  'remark'
]

// 新建时允许直接给初始库存（会补一条"初始"流水）
const CREATE_COLUMNS = [...EDITABLE_COLUMNS, 'stock']

const NUMERIC_COLUMNS = new Set(['stock'])

// 模糊搜索覆盖的列
const SEARCH_COLUMNS = [
  'name',
  'package',
  'mfr_pn',
  'mfr',
  'supplier',
  'supplier_pn',
  'location',
  'remark'
]

// 流水检索覆盖的列。跨 inventory(i) 与 inventory_log(l) 两张表，
// 所以列名自带表前缀、不再另传 prefix。
// package 在此有意与列表页保持一致：流水里同样要能用「名称 封装」组合定位，
// 否则同一个搜索词在两个界面表现不同，会被当成 bug。
const LOG_SEARCH_COLUMNS = [
  'i.name',
  'i.package',
  'i.mfr_pn',
  'i.supplier_pn',
  'l.remark'
]

// 排序白名单：绝不把用户输入直接拼进 SQL
const SORTABLE_COLUMNS = new Set([
  'name',
  'package',
  'mfr_pn',
  'mfr',
  'supplier',
  'supplier_pn',
  'status',
  'stock',
  'location',
  'updated_at',
  'id'
])

// 出入库类型白名单
const MOVE_TYPES = new Set(['入库', '出库', '盘点'])

// 流水类型：除手工出入库外，还有建档/迁移时写入的"初始"
const LOG_TYPES = new Set(['入库', '出库', '盘点', '初始'])

const MAX_PAGE_SIZE = 500

// ---------------------------------------------------------------------------
// 库位归一：判断「用户写的这个库位是不是已经有料了」
//
// 库位是人手打的短编号，同一格常被写成好几种样子：
//   A1-B2 / a1-b2 / A1 - B2 / Ａ1-Ｂ2（全角）
// 存进去就是四条不同的 location，会让位置筛选下拉裂成四项、
// `location = ?` 精确筛选漏料、找料时"看着有却搜不到"。
//
// 所以比较时统一折叠掉三类差异：全角/兼容字符（NFKC）、所有空白、ASCII 大小写。
// 刻意**只用于比较**，绝不改写用户存进去的原值——他写 `抽屉3-格5` 就该原样保留，
// 归一只是为了找出"其实是同一格"的记录。
//
// JS 侧与 SQL 侧必须折叠出完全一样的结果，否则查不到本该查到的行，
// 提示静默失效。两边的对应关系：
//   NFKC          → SQL 无内置，靠入参在 JS 侧先归一（列侧全角字符无法在 SQL 里折，
//                   这是已知取舍：全角库位存进库后需靠字面写法列表 variants 暴露）
//   去空白        → REPLACE 掉空格 / TAB / 全角空格
//   ASCII 小写    → LOWER（SQLite 的 LOWER 只折 ASCII，与库位实际字符集吻合）
// ---------------------------------------------------------------------------

/** 库位比较键；空白或纯空格返回 ''（视为"未归位"，不参与占用判断） */
function locationKey(raw) {
  return String(raw ?? '')
    .normalize('NFKC')
    .replace(/[\s\u3000]+/g, '')
    .toLowerCase()
}

// SQL 侧同口径：去空格（半角/TAB/全角）后转小写。
// 与 locationKey 的差异仅在 NFKC——入参已在 JS 侧归一过，
// 列侧的全角写法由返回的 variants 列表兜底暴露给用户。
const LOCATION_KEY_EXPR = `LOWER(REPLACE(REPLACE(REPLACE(location, ' ', ''), char(9), ''), char(12288), ''))`


/**
 * 归一化入参。
 * @param {object} input 原始请求体
 * @param {{ partial?: boolean, columns?: string[] }} options
 *   partial=true 时只处理 input 中实际出现的键（供 PUT 局部更新）
 */
function normalize(input = {}, { partial = false, columns = CREATE_COLUMNS } = {}) {
  const out = {}
  for (const col of columns) {
    if (partial && !Object.prototype.hasOwnProperty.call(input, col)) continue

    const raw = input[col]
    if (NUMERIC_COLUMNS.has(col)) {
      const n = Number(raw)
      out[col] = Number.isFinite(n) && n > 0 ? Math.floor(n) : 0
    } else {
      out[col] = String(raw ?? '').trim()
    }
  }
  return out
}

function isUniqueViolation(err) {
  return err && (err.code === 'SQLITE_CONSTRAINT_UNIQUE' || err.code === 'SQLITE_CONSTRAINT_PRIMARYKEY')
}

function conflictMessage(supplierPn) {
  const pn = String(supplierPn ?? '').trim()
  return pn ? `供应商料号 ${pn} 已存在于台账中` : '供应商料号已存在于台账中'
}

// 查询一律用这个投影：status 由 stock 派生，覆盖表里的旧 status 列
const SELECT_ROW = `SELECT *, ${STATUS_EXPR} AS status FROM inventory`

const findById = db.prepare(`${SELECT_ROW} WHERE id = ?`)
const findMaterialById = db.prepare('SELECT * FROM materials WHERE id = ?')
const insertLog = db.prepare(
  `INSERT INTO inventory_log (inventory_id, type, delta, stock_after, remark)
   VALUES (?, ?, ?, ?, ?)`
)
// 撤销专用：固定 type='入库'，继承原出库的 product_id 与 material_id，
// 并写 revokes_log_id 指回被撤销的行。material_id 必须跟随撤销补偿行，
// 否则 -SUM(delta) 聚合无法抵消，撤销后的出库仍会被计入已焊接量。
const insertRevokeLog = db.prepare(
  `INSERT INTO inventory_log (inventory_id, product_id, material_id, type, delta, stock_after, remark, revokes_log_id)
   VALUES (?, ?, ?, '入库', ?, ?, ?, ?)`
)

// 单件绑定出库专用：固定 type='出库'，可写 product_id 与 material_id。
// 必须与通用 insertLog 分开：后者被 初始/入库/盘点/批量导入 复用，
//  widening 它会把 material_id 写到不允许的行，破坏"已焊接量"聚合不变式。
const insertBoundOutboundLog = db.prepare(
  `INSERT INTO inventory_log (inventory_id, product_id, material_id, type, delta, stock_after, remark)
   VALUES (?, ?, ?, '出库', ?, ?, ?)`
)

// 只绑产品、不绑 BOM 行的出库：写 product_id，不写 material_id。
const insertProductOutboundLog = db.prepare(
  `INSERT INTO inventory_log (inventory_id, product_id, type, delta, stock_after, remark)
   VALUES (?, ?, '出库', ?, ?, ?)`
)

// ---------------------------------------------------------------------------
// GET /  列表：搜索 + 状态/位置筛选 + 仅看有货 + 归位与否 + 服务端排序分页
// ---------------------------------------------------------------------------
router.get('/', (req, res, next) => {
  try {
    const where = []
    const params = []

    // 关键词按空格分词：词间 AND、列间 OR，所以「名称 + 封装」这类
    // 跨列组合（如 `04381.25WR F0603`）能查到。单词行为与以前一致。
    const keywordFilter = buildKeywordFilter(req.query.q, SEARCH_COLUMNS)
    if (keywordFilter) {
      where.push(keywordFilter.sql)
      params.push(...keywordFilter.params)
    }

    // 状态是派生值，筛选时要用表达式而不是列名
    const statusFilter = String(req.query.status ?? '').trim()
    if (statusFilter) {
      where.push(`${STATUS_EXPR} = ?`)
      params.push(statusFilter)
    }

    const locationFilter = String(req.query.location ?? '').trim()
    if (locationFilter) {
      where.push('location = ?')
      params.push(locationFilter)
    }

    // hasLocation=1 只看已归位的，=0 只看没填位置的。
    // 与上面按具体位置筛选是两个维度：那个问"在哪一格"，这个问"归没归位"。
    // 用 TRIM() 而不是 <> ''：location 是 NOT NULL DEFAULT ''，理论上不会有
    // NULL，但历史数据可能存进过纯空格，那种也该算「无位置」。
    const hasLocation = String(req.query.hasLocation ?? '').trim()
    if (hasLocation === '1') where.push("TRIM(location) <> ''")
    else if (hasLocation === '0') where.push("TRIM(location) = ''")

    // inStock=1 只看有货，=0 只看零库存（等价于状态"缺货"）
    const inStock = String(req.query.inStock ?? '').trim()
    if (inStock === '1') where.push('stock > 0')
    else if (inStock === '0') where.push('stock <= 0')

    const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : ''

    const rawSort = String(req.query.sortBy)
    const sortBy = SORTABLE_COLUMNS.has(rawSort) ? rawSort : 'name'
    const sortOrder = String(req.query.sortOrder).toLowerCase() === 'desc' ? 'DESC' : 'ASC'
    // 按状态排序等价于按库存有无排序
    const orderExpr = sortBy === 'status' ? STATUS_EXPR : sortBy

    const page = Math.max(1, Number(req.query.page) || 1)
    const rawSize = Number(req.query.pageSize) || 50
    const pageSize = Math.min(Math.max(1, rawSize), MAX_PAGE_SIZE)
    const offset = (page - 1) * pageSize

    const { total } = db
      .prepare(`SELECT COUNT(*) AS total FROM inventory ${whereSql}`)
      .get(...params)

    const list = db
      .prepare(
        `${SELECT_ROW} ${whereSql}
         ORDER BY ${orderExpr} ${sortOrder}, id ASC
         LIMIT ? OFFSET ?`
      )
      .all(...params, pageSize, offset)

    res.json({ list, total, page, pageSize })
  } catch (err) {
    next(err)
  }
})

// ---------------------------------------------------------------------------
// GET /stats  汇总（必须注册在 /:id 之前）
// ---------------------------------------------------------------------------
router.get('/stats', (req, res, next) => {
  try {
    const base = db
      .prepare(
        `SELECT COUNT(*) AS total,
                COALESCE(SUM(stock), 0) AS totalStock,
                COALESCE(SUM(CASE WHEN stock > 0  THEN 1 ELSE 0 END), 0) AS inStockKinds,
                COALESCE(SUM(CASE WHEN stock <= 0 THEN 1 ELSE 0 END), 0) AS zeroStockKinds
         FROM inventory`
      )
      .get()

    const statusCounts = db
      .prepare(
        `SELECT ${STATUS_EXPR} AS status, COUNT(*) AS count
         FROM inventory
         GROUP BY ${STATUS_EXPR}
         ORDER BY count DESC, status ASC`
      )
      .all()

    const locationCounts = db
      .prepare(
        `SELECT location, COUNT(*) AS count
         FROM inventory
         WHERE location <> ''
         GROUP BY location
         ORDER BY count DESC, location ASC`
      )
      .all()

    res.json({ ...base, statusCounts, locationCounts })
  } catch (err) {
    next(err)
  }
})

// ---------------------------------------------------------------------------
// GET /match  按「名称 + 封装」严格相等查候选库存（注册在 /:id 之前）
//
// 给 BOM 页的「状态」列用：点开后看这行料在台账里有哪些同规格记录、各有多少库存，
// 并可把某条的制造商料号回填到 BOM 行（前端的「绑定」）。
//
// 为什么不复用 GET / 的 q 搜索：那是**子串 + 跨列 OR + 空格分词**的模糊匹配
//   - LIKE '%AGB%' 会把 AGB_CPU_AGB 也命中，不是相等
//   - 每个词可落在任意列，q='100nF C0402' 会命中 name/package 互换的行
//   - 名称本身含空格时（如 'AGB CPU'）会被分词打散，相等语义彻底失效
// 所以这里必须是独立的严格相等端点。
//
// 但「严格相等」比模糊搜索更需要字符归一：`=` 没有子串兜底，
// 名称里一个 U+2126 欧姆记号就会让肉眼完全相同的两条判不相等。
// 因此两侧都过 foldedColumn / normalizeTerm，与搜索共用同一套口径。
//
// mfrPnKinds：该候选的制造商料号在台账里对应几条记录。
// >1 意味着回填这个料号后 BOM 行会同时 JOIN 上多条库存而在列表里重复出现
// （mfr_pn 没有唯一约束，见 README「注意」一节），前端据此给出警告。
//
// minBindStock：库存「偏低」的提示阀值（见 bind-rules.js）。随响应带出而不让
// 前端硬编码 50 —— 阀值写两份，改一处漏一处就会出现两边说法不一致。
// 只是提示：库存多少都能绑，绑不绑由使用者决定。
// 候选一条都不过滤：库存不足的记录仍要列出来（用户需要看到"台账里确实有，
// 只是不多"）。过滤掉就变成"查无此料"，是误导。
// ---------------------------------------------------------------------------
router.get('/match', (req, res, next) => {
  try {
    const name = normalizeTerm(req.query.name ?? '').trim()
    const pkg = normalizeTerm(req.query.package ?? '').trim()

    // 名称为空时不返回全表：那会把整个台账倒给前端，且「同规格」无从谈起
    if (!name) {
      return res.json({ list: [], total: 0, name, package: pkg, minBindStock: LOW_BIND_STOCK })
    }


    const foldedName = foldedColumn('name')
    const foldedPkg = foldedColumn('package')

    // 封装为空的 BOM 行按「只比名称」处理：结构件常常没填封装，
    // 强行要求 package = '' 相等会把本来能匹配上的同名元件也排除掉。
    const where = [`${foldedName} = ?`]
    const params = [name]
    if (pkg) {
      where.push(`${foldedPkg} = ?`)
      params.push(pkg)
    }

    const list = db
      .prepare(
        `SELECT *, ${STATUS_EXPR} AS status,
                (SELECT COUNT(*) FROM inventory x WHERE x.mfr_pn = inventory.mfr_pn) AS mfrPnKinds
         FROM inventory
         WHERE ${where.join(' AND ')}
         ORDER BY stock DESC, name ASC, id ASC`
      )
      .all(...params)

    res.json({ list, total: list.length, name, package: pkg, minBindStock: LOW_BIND_STOCK })
  } catch (err) {
    next(err)
  }
})

// ---------------------------------------------------------------------------
// GET /spec  按「BOM 料号 + 候选料号」查 AI 电气参数对比结果
//
// 查询参数：bom (BOM 行原始料号) + cand (候选库存料号) + name + package
//
// 先查 component_spec 表：有就直接返回（同一对料号只调一次 AI）。
// 没有则调 DeepSeek API 做对比分析，结果存表后返回。
//
// AI 返回的结构化 JSON 格式：
// {
//   bom_mfr_pn, cand_mfr_pn,
//   bom_params: { voltage, current, tolerance, ... },
//   cand_params: { voltage, current, tolerance, ... },
//   differences: [{ param, bom_value, cand_value, impact }],
//   compatible: true/false,
//   risk_level: "low" / "medium" / "high",
//   recommendation: "...",
//   notes: "..."
// }
// ---------------------------------------------------------------------------
router.get('/spec', async (req, res, next) => {
  try {
    const bomPn = String(req.query.bom ?? '').trim()
    const candPn = String(req.query.cand ?? '').trim()
    const bomName = String(req.query.name ?? '').trim()
    const bomPkg = String(req.query.package ?? '').trim()

    if (!bomPn || !candPn) {
      return res.status(400).json({ error: 'bom 和 cand 参数必填' })
    }
    // 同一料号对比自己没有意义
    if (bomPn === candPn) {
      return res.json({ spec: null, source: 'same', message: '两个料号相同，无需对比' })
    }

    // 1. 查缓存
    const cached = db
      .prepare('SELECT spec, source, created_at FROM component_spec WHERE bom_mfr_pn = ? AND cand_mfr_pn = ?')
      .get(bomPn, candPn)

    if (cached) {
      return res.json({
        spec: JSON.parse(cached.spec),
        source: cached.source,
        cached: true,
        created_at: cached.created_at
      })
    }

    // 2. 未命中 —— 调 DeepSeek API
    const apiKey = process.env.DEEPSEEK_API_KEY
    if (!apiKey) {
      return res.status(503).json({
        error: '未配置 DEEPSEEK_API_KEY 环境变量，无法进行 AI 对比分析'
      })
    }

    // 3. 调 DeepSeek
    const spec = await callDeepSeek(bomPn, candPn, bomName, bomPkg, apiKey)

    // 4. 存表缓存
    db.prepare(
      `INSERT OR REPLACE INTO component_spec (bom_mfr_pn, cand_mfr_pn, name, package, spec, source)
       VALUES (?, ?, ?, ?, ?, 'ai')`
    ).run(bomPn, candPn, bomName || null, bomPkg || null, JSON.stringify(spec))

    res.json({ spec, source: 'ai', cached: false })
  } catch (err) {
    next(err)
  }
})

/**
 * 调 DeepSeek API 对比两个电子元件的电气参数。
 *
 * Prompt 设计要点：
 *   - 只给料号，不给名称/封装（AI 自己的知识库里查，比我们描述更准确）
 *   - 要求返回严格 JSON，方便前端结构化展示
 *   - 覆盖核心电气参数：电压/电流/功率/精度/封装/温度范围等
 *   - 给出可替换性判断和风险等级
 */
async function callDeepSeek(bomPn, candPn, bomName, bomPkg, apiKey) {
  const nameHint = bomName ? `（名称：${bomName}）` : ''
  const pkgHint = bomPkg ? `（封装：${bomPkg}）` : ''

  const prompt = `你是一位资深电子元器件工程师。请对比以下两个料号的电气参数差异：

BOM 原始料号：${bomPn}${nameHint}${pkgHint}
候选库存料号：${candPn}

请查询这两个料号的数据手册（datasheet），对比它们的电气参数，并返回严格的 JSON 格式（不要包含 markdown 代码块标记）：

{
  "bom_mfr_pn": "${bomPn}",
  "cand_mfr_pn": "${candPn}",
  "bom_params": {
    "description": "元件描述",
    "voltage": "额定电压",
    "current": "额定电流",
    "power": "额定功率",
    "tolerance": "精度",
    "package": "封装",
    "temperature_range": "工作温度范围",
    "other_params": "其他关键参数"
  },
  "cand_params": {
    "description": "元件描述",
    "voltage": "额定电压",
    "current": "额定电流",
    "power": "额定功率",
    "tolerance": "精度",
    "package": "封装",
    "temperature_range": "工作温度范围",
    "other_params": "其他关键参数"
  },
  "bom_price": "BOM 料号的市场参考单价（元），仅供采购参考",
  "cand_price": "候选料号的市场参考单价（元），仅供采购参考",
  "differences": [
    {
      "param": "参数名",
      "bom_value": "BOM 料号的值",
      "cand_value": "候选料号的值",
      "impact": "这个差异对电路的影响（可忽略/需评估/不可替换）"
    }
  ],
  "compatible": true,
  "risk_level": "low",
  "recommendation": "综合建议（是否可直接替换、需要注意什么）",
  "notes": "其他需要说明的信息"
}

risk_level 取值规则：
- "low": 参数完全一致或差异可忽略，可直接替换
- "medium": 有差异但通常可替换，需工程师确认
- "high": 关键参数不兼容，不建议替换

如果无法查到某个料号的信息，在对应 params 的字段里填 "未查到"，differences 里说明原因。`

    const resp = await httpsPost({
    hostname: 'api.deepseek.com',
    path: '/v1/chat/completions',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${apiKey}`
    }
  }, JSON.stringify({
    model: 'deepseek-chat',
    messages: [{ role: 'user', content: prompt }],
    temperature: 0.1,
    max_tokens: 2000
  }))

  const body = JSON.parse(resp)
  const content = body?.choices?.[0]?.message?.content || ''

  // AI 可能会包 ```json ... ```，剥掉
  const cleaned = content.replace(/^```json\s*/i, '').replace(/\s*```$/i, '').trim()

  try {
    return JSON.parse(cleaned)
  } catch {
    // AI 返回的不是合法 JSON，把原文包一层返回
    return { raw_response: content, parse_error: true }
  }
}

/**
 * 最小化的 HTTPS POST 请求（不引入 axios/node-fetch）。
 * DeepSeek API 是 JSON POST，只需要这一个场景。
 */
function httpsPost(options, body) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      const chunks = []
      res.on('data', c => chunks.push(c))
      res.on('end', () => {
        const text = Buffer.concat(chunks).toString()
        if (res.statusCode >= 400) {
          reject(new Error(`DeepSeek API ${res.statusCode}: ${text}`))
        } else {
          resolve(text)
        }
      })
    })
    req.on('error', reject)
    req.write(body)
    req.end()
  })
}
// ---------------------------------------------------------------------------
router.get('/locations', (req, res, next) => {
  try {
    const rows = db
      .prepare("SELECT DISTINCT location FROM inventory WHERE location <> '' ORDER BY location ASC")
      .all()
    res.json(rows.map(r => r.location))
  } catch (err) {
    next(err)
  }
})

// ---------------------------------------------------------------------------
// GET /locations/occupants  查某个库位当前放了哪些料（供编辑弹框提示重复占用）
//   query: location（必填）, excludeId（可选，编辑自身时排除）
//
// 只是「提醒」而非校验：一个抽屉格放多种料在硬件仓储里是常态，
// 所以后端不拒绝重复库位，只如实回报占用情况，由前端展示给人判断。
//
// 归一化比较：库位是手打的短字符串，`A1-B2` / `a1-b2` / 全角 `Ａ1-Ｂ2`
// 指的是同一格，但存进去就是三条不同的 location，
// 会让筛选下拉裂成三项、`location = ?` 精确筛选漏料。
// 所以这里用「NFKC + 去空格 + 大小写无关」的口径找同格记录，
// 让用户在存进去之前就看到「你写的这个格子其实已经有料了」。
//
// 注册在 /:id 之前，否则 'locations' 会被当成 id 吃掉。
// 也必须在 /locations 之后——Express 按注册顺序匹配，
// /locations 是精确路径不会吞掉 /locations/occupants，但顺序放一起便于阅读。
// ---------------------------------------------------------------------------
router.get('/locations/occupants', (req, res, next) => {
  try {
    const raw = String(req.query.location ?? '')
    const key = locationKey(raw)

    // 空库位不算占用：未归位的料很多，提示「已有 40 种料没填位置」毫无意义
    if (!key) {
      return res.json({ location: raw.trim(), total: 0, list: [], variants: [] })
    }

    const excludeId = Number(req.query.excludeId)
    const hasExclude = Number.isFinite(excludeId) && excludeId > 0

    // 用 SQL 侧同口径归一：LOWER(REPLACE(...)) 去掉空格再折叠等价字符。
    // 这里只处理 ASCII 大小写（SQLite 的 LOWER 只折 ASCII），
    // 与 locationKey 的 toLowerCase 在库位这种场景下足够一致——
    // 库位是人手打的编号，实际只会出现字母数字与分隔符。
    const params = [key]
    let sql = `
      SELECT id, name, package, mfr_pn, supplier_pn, stock, location,
             ${STATUS_EXPR} AS status
      FROM inventory
      WHERE ${LOCATION_KEY_EXPR} = ?
    `
    if (hasExclude) {
      sql += ' AND id != ?'
      params.push(Math.floor(excludeId))
    }
    sql += ' ORDER BY stock DESC, name ASC, id ASC LIMIT 20'

    const list = db.prepare(sql).all(...params)

    // 该格实际出现过的字面写法。>1 说明同一格被写成了多种样子，
    // 前端据此额外提示「建议统一写法」——这是真正会造成筛选漏料的那种重复。
    const variantRows = db
      .prepare(
        `SELECT DISTINCT location FROM inventory
         WHERE ${LOCATION_KEY_EXPR} = ?${hasExclude ? ' AND id != ?' : ''}
         ORDER BY location ASC`
      )
      .all(...params)

    res.json({
      location: raw.trim(),
      total: list.length,
      list,
      variants: variantRows.map(r => r.location)
    })
  } catch (err) {
    next(err)
  }
})

// ---------------------------------------------------------------------------
// GET /locations/free  已用范围内还空着的库位（供「未使用」弹框）
//
// 库位是二维格架编号 {层}{行}{列}，如 A15 = A 层 1 行 5 列。
// 范围口径：已用过的层 × 该层已用行列最大值围成的矩形，见 web/location.js。
// 例：已用 A11/A12/A13/A15 → 空位 A14。
//
// 计算复用 web/location.js 的纯函数，不在 SQL 里重写一遍网格逻辑：
// 空位规则（矩形边界、每层独立上界、不凭空造新层）已被 test/location.test.js
// 锁住，两处实现必然漂移。这里只负责把已用库位喂进去。
//
// 注册在 /:id 之前，否则 'locations' 会被当成 id 吃掉。
// ---------------------------------------------------------------------------
router.get('/locations/free', (req, res, next) => {
  try {
    const rows = db
      .prepare("SELECT location FROM inventory WHERE TRIM(location) != ''")
      .all()

    // 必须把合并关系一起传进去：被合并吞掉的格子已不是独立库位，
    // 不传会把它们误报成空位，用户照着填就会撞进别人的大格里。
    const result = findFreeLocations(rows, listMerges())

    res.json({
      free: result.free,
      total: result.free.length,
      maxLocation: result.maxLocation,
      layers: result.layers,
      // 不符合 {层}{行}{列} 的库位（如「抽屉3-格5」）。
      // 它们是合法库位值，只是不参与网格计算，如实告知避免用户以为漏算了。
      unparsed: result.unparsed
    })
  } catch (err) {
    next(err)
  }
})

// ---------------------------------------------------------------------------
// 库位合并：读取当前所有合并区域
//
// primary 由 (start_row, start_col) 算出而不是存字段：存了就可能与范围不一致。
// ---------------------------------------------------------------------------
function listMerges() {
  return db
    .prepare('SELECT * FROM location_merge ORDER BY layer, start_row, start_col')
    .all()
    .map(m => ({
      id: m.id,
      layer: m.layer,
      startRow: m.start_row,
      startCol: m.start_col,
      endRow: m.end_row,
      endCol: m.end_col,
      remark: m.remark,
      primary: formatLocation({ layer: m.layer, row: m.start_row, col: m.start_col }),
      cells: getMergeCells(m.layer, m.start_row, m.start_col, m.end_row, m.end_col)
    }))
}

// ---------------------------------------------------------------------------
// GET /locations/grid  库位网格全景（供库位管理页）
//
// 返回每层 5×5 的格子状态：占用了哪些料、是否被合并、是否为合并主格。
// 只返回「有内容的层」+ 已用层，避免一次吐 26 层 650 格的空网格。
// 想看/启用其他层由前端按需请求（?layer=B）。
// ---------------------------------------------------------------------------
router.get('/locations/grid', (req, res, next) => {
  try {
    const merges = listMerges()

    // 台账里所有已归位的料
    const rows = db
      .prepare(
        `SELECT id, name, package, mfr_pn, supplier_pn, stock, location,
                ${STATUS_EXPR} AS status
         FROM inventory
         WHERE TRIM(location) != ''
         ORDER BY name`
      )
      .all()

    // 指定层则只看那一层；否则给出「已用层 ∪ 有合并的层」
    const wanted = String(req.query.layer ?? '').trim().toUpperCase()

    // 归属：被合并吞掉的格子，其料算到主格头上（与 resolveCell 同口径）
    const byCell = new Map() // 'A11' -> rows[]
    const unparsed = []
    for (const r of rows) {
      const cell = parseLocation(r.location)
      if (!cell) {
        unparsed.push(r)
        continue
      }
      // 找是否落在某个合并区域内
      const hit = merges.find(
        m =>
          m.layer === cell.layer &&
          cell.row >= m.startRow &&
          cell.row <= m.endRow &&
          cell.col >= m.startCol &&
          cell.col <= m.endCol
      )
      const key = hit ? hit.primary : formatLocation(cell)
      if (!byCell.has(key)) byCell.set(key, [])
      byCell.get(key).push(r)
    }

    const usedLayers = new Set()
    for (const key of byCell.keys()) {
      const p = parseLocation(key)
      if (p) usedLayers.add(p.layer)
    }
    for (const m of merges) usedLayers.add(m.layer)

    const layerList = wanted
      ? (LAYERS.includes(wanted) ? [wanted] : [])
      : LAYERS.filter(l => usedLayers.has(l))

    const layers = layerList.map(layer => {
      const layerMerges = merges.filter(m => m.layer === layer)

      // 被合并吞掉（非主格）的格子集合
      const swallowed = new Set()
      for (const m of layerMerges) {
        for (const c of m.cells) {
          if (c !== m.primary) swallowed.add(c)
        }
      }

      const cells = allLayerCells(layer).map(code => {
        const p = parseLocation(code)
        const merge = layerMerges.find(
          m =>
            p.row >= m.startRow && p.row <= m.endRow && p.col >= m.startCol && p.col <= m.endCol
        )
        const items = byCell.get(code) || []
        return {
          code,
          row: p.row,
          col: p.col,
          // swallowed 的格子在网格里不单独渲染（被主格的 rowspan/colspan 盖住）
          swallowed: swallowed.has(code),
          mergeId: merge?.id ?? null,
          // 主格要知道自己横跨/纵跨几格，前端据此设 colspan/rowspan
          rowSpan: merge && code === merge.primary ? merge.endRow - merge.startRow + 1 : 1,
          colSpan: merge && code === merge.primary ? merge.endCol - merge.startCol + 1 : 1,
          items,
          itemCount: items.length,
          totalStock: items.reduce((a, r) => a + (Number(r.stock) || 0), 0)
        }
      })

      return {
        layer,
        rows: GRID_ROWS,
        cols: GRID_COLS,
        merges: layerMerges,
        cells,
        usedCount: cells.filter(c => !c.swallowed && c.itemCount > 0).length,
        freeCount: cells.filter(c => !c.swallowed && c.itemCount === 0).length
      }
    })

    res.json({
      layers,
      allLayers: LAYERS,
      rows: GRID_ROWS,
      cols: GRID_COLS,
      merges,
      // 不符合 {层}{行}{列} 的库位（如「抽屉3-格5」），如实告知避免以为漏算
      unparsed: unparsed.map(r => ({ id: r.id, name: r.name, location: r.location }))
    })
  } catch (err) {
    next(err)
  }
})

// ---------------------------------------------------------------------------
// POST /locations/merge  合并格子（物理打通）
//   body: { layer, startRow, startCol, endRow, endCol, remark? }
//
// 合并后被吞并格子里的料，location 自动改成主格号——这是「位置自动更新」。
// 单事务：合并关系与料的库位迁移要么都成，要么都不成，
// 否则会出现「格子合并了但料还指着已不存在的库位」。
//
// 校验复用 web/location.js 的 validateMerge，与前端同一套规则。
// ---------------------------------------------------------------------------
router.post('/locations/merge', (req, res, next) => {
  try {
    const layer = String(req.body?.layer ?? '').trim().toUpperCase()
    if (!LAYERS.includes(layer)) {
      return res.status(400).json({ error: `层号必须是 A~Z` })
    }

    const startRow = Math.floor(Number(req.body?.startRow))
    const startCol = Math.floor(Number(req.body?.startCol))
    const endRow = Math.floor(Number(req.body?.endRow))
    const endCol = Math.floor(Number(req.body?.endCol))

    if (![startRow, startCol, endRow, endCol].every(Number.isFinite)) {
      return res.status(400).json({ error: '合并范围必须是数字' })
    }

    const check = validateMerge(layer, startRow, startCol, endRow, endCol, listMerges())
    if (!check.ok) return res.status(400).json({ error: check.error })

    const primary = formatLocation({ layer, row: startRow, col: startCol })
    const cells = getMergeCells(layer, startRow, startCol, endRow, endCol)
    // 主格之外的格子：里面的料要迁到主格
    const swallowed = cells.filter(c => c !== primary)
    const remark = String(req.body?.remark ?? '').trim()

    let moved = 0
    const run = db.transaction(() => {
      db.prepare(
        `INSERT INTO location_merge (layer, start_row, start_col, end_row, end_col, remark)
         VALUES (?, ?, ?, ?, ?, ?)`
      ).run(layer, startRow, startCol, endRow, endCol, remark)

      // 位置自动更新：被吞并格里的料一律改成主格号。
      // 用 IN 而不是逐条 UPDATE：一次语句搞定，也避免中途失败留下半迁移状态。
      if (swallowed.length > 0) {
        const placeholders = swallowed.map(() => '?').join(', ')
        const info = db
          .prepare(`UPDATE inventory SET location = ? WHERE location IN (${placeholders})`)
          .run(primary, ...swallowed)
        moved = info.changes
      }
    })
    run()

    res.status(201).json({
      ok: true,
      layer,
      primary,
      cells,
      // 有多少条料的库位被自动改写，如实回报让用户知道发生了什么
      moved
    })
  } catch (err) {
    next(err)
  }
})

// ---------------------------------------------------------------------------
// DELETE /locations/merge/:id  取消合并（恢复隔板）
//
// 刻意不把料散回原格：合并期间放进去的料物理上就在主格那一片区域，
// 拆开隔板后它们仍在主格里。散回去等于凭空猜测每件料现在归哪一格。
// 用户自己按实际情况调整即可。
// ---------------------------------------------------------------------------
router.delete('/locations/merge/:id', (req, res, next) => {
  try {
    const id = Number(req.params.id)
    const info = db.prepare('DELETE FROM location_merge WHERE id = ?').run(id)
    if (info.changes === 0) return res.status(404).json({ error: '合并区域不存在' })
    res.json({ ok: true, id })
  } catch (err) {
    next(err)
  }
})

// ---------------------------------------------------------------------------
// GET /logs  全局出入库流水查询（注册在 /:id 之前）
//   支持按类型、关键字（元件名/料号）、日期范围筛选，附带汇总
//   query: type / q / from / to / page / pageSize
// ---------------------------------------------------------------------------
router.get('/logs', (req, res, next) => {
  try {
    const where = []
    const params = []

    // 类型：入库/出库/盘点/初始
    const type = String(req.query.type ?? '').trim()
    if (type && LOG_TYPES.has(type)) {
      where.push('l.type = ?')
      params.push(type)
    }

    // 按产品筛选：批量出库时记下了 product_id，手工单件出入库为 NULL
    const productId = Number(req.query.productId)
    if (Number.isFinite(productId) && productId > 0) {
      where.push('l.product_id = ?')
      params.push(Math.floor(productId))
    }

    // 按 BOM 行筛选：单行出库时记下了 material_id，撤销补偿行继承同一个值。
    // 这是「这条 BOM 明细领过几次料」的唯一依据，也是「已焊接」列的聚合口径
    // （见 materials.js 的 solderedQty 派生表），两处必须用同一个字段，
    // 否则流水弹框里的合计与表格里的已焊接数会对不上。
    const materialId = Number(req.query.materialId)
    if (Number.isFinite(materialId) && materialId > 0) {
      where.push('l.material_id = ?')
      params.push(Math.floor(materialId))
    }

    // 关键字覆盖元件名与两种料号，以及流水事由。
    // 这里的列跨两张表（i. 与 l.），前缀不统一，所以把带前缀的列名整体
    // 交给 buildKeywordFilter 当"列名"用，prefix 留空。分词语义同列表页。
    const logKeywordFilter = buildKeywordFilter(req.query.q, LOG_SEARCH_COLUMNS)
    if (logKeywordFilter) {
      where.push(logKeywordFilter.sql)
      params.push(...logKeywordFilter.params)
    }

    // 日期范围（含当天）。created_at 是 'YYYY-MM-DD HH:MM:SS' 本地时间字符串，
    // 直接按前缀比较即可，不用做时区换算。
    const from = String(req.query.from ?? '').trim()
    if (from) {
      where.push('l.created_at >= ?')
      params.push(`${from.slice(0, 10)} 00:00:00`)
    }
    const to = String(req.query.to ?? '').trim()
    if (to) {
      where.push('l.created_at <= ?')
      params.push(`${to.slice(0, 10)} 23:59:59`)
    }

    const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : ''

    const page = Math.max(1, Number(req.query.page) || 1)
    const pageSize = Math.min(Math.max(1, Number(req.query.pageSize) || 50), MAX_PAGE_SIZE)
    const offset = (page - 1) * pageSize

    const joinSql = `
      FROM inventory_log l
      LEFT JOIN inventory i   ON i.id = l.inventory_id
      LEFT JOIN products p    ON p.id = l.product_id
      LEFT JOIN materials ma  ON ma.id = l.material_id
      ${whereSql}
    `

    const { total } = db.prepare(`SELECT COUNT(*) AS total ${joinSql}`).get(...params)

    // revoked_by_log_id 用标量子查询而不是自连接：自连接会改变 joinSql 的行数，
    // 把下面的 COUNT / SUM 汇总一起带偏。
    const list = db
      .prepare(
        `SELECT l.id, l.inventory_id, l.product_id, l.material_id, l.type, l.delta, l.stock_after,
                l.remark, l.created_at, l.revokes_log_id,
                (SELECT r.id FROM inventory_log r WHERE r.revokes_log_id = l.id) AS revoked_by_log_id,
                i.name, i.package, i.mfr_pn, i.supplier_pn, i.location,
                p.code AS product_code,
                ma.designator AS material_designator
         ${joinSql}
         ORDER BY l.id DESC
         LIMIT ? OFFSET ?`
      )
      .all(...params, pageSize, offset)

    // 汇总：当前筛选条件下的出入库总量，便于核对"这段时间领了多少料"
    const summary = db
      .prepare(
        `SELECT
           COALESCE(SUM(CASE WHEN l.delta > 0 THEN l.delta ELSE 0 END), 0)  AS inQty,
           COALESCE(SUM(CASE WHEN l.delta < 0 THEN -l.delta ELSE 0 END), 0) AS outQty,
           COUNT(DISTINCT l.inventory_id) AS itemKinds
         ${joinSql}`
      )
      .get(...params)

    const typeCounts = db
      .prepare(
        `SELECT l.type AS type, COUNT(*) AS count
         ${joinSql}
         GROUP BY l.type
         ORDER BY count DESC, l.type ASC`
      )
      .all(...params)

    res.json({ list, total, page, pageSize, ...summary, typeCounts })
  } catch (err) {
    next(err)
  }
})

// ---------------------------------------------------------------------------
// 撤销出库的核心逻辑，单条与批量共用同一份不变式。
//
// 撤销不删也不改原出库行，而是追加一条反向入库，并用 revokes_log_id 指回去。
// 这样库存永远等于流水累加，账目双向可查，也不会出现"库存被改了但流水没有痕迹"。
//
// 只有出库可撤销：入库撤销语义上等于出库（库存可能已经不够，另说），
// 盘点没有"原值"概念，初始是建档动作，都不该走这条路。
// 一条出库最多撤一次，由 uq_inv_log_revokes 部分唯一索引在库层面兜底。
//
// 返回 { ok: true, ... } 或 { ok: false, status, error }：
// 刻意不抛异常——批量场景要能逐行跳过并汇报，抛了就得靠 try/catch 控流。
// 注意：本函数只做单行读改写，事务由调用方开（批量时要一个大事务）。
// ---------------------------------------------------------------------------
function revokeOneLog(logId, userRemark = '') {
  const log = db.prepare('SELECT * FROM inventory_log WHERE id = ?').get(logId)
  if (!log) return { ok: false, status: 404, error: '流水记录不存在' }

  if (log.type !== '出库') {
    return { ok: false, status: 400, error: '只有出库记录可以撤销' }
  }
  // 撤销记录本身是入库，上面那条已经拦住了；这里是双重保险
  if (log.revokes_log_id != null) {
    return { ok: false, status: 400, error: '撤销记录不能再被撤销' }
  }

  const already = db.prepare('SELECT id FROM inventory_log WHERE revokes_log_id = ?').get(logId)
  if (already) return { ok: false, status: 409, error: '该出库记录已撤销过' }

  const qty = Math.abs(Number(log.delta) || 0)
  if (qty === 0) {
    return { ok: false, status: 400, error: '该记录变动量为 0，无需撤销' }
  }

  const item = findById.get(log.inventory_id)
  if (!item) return { ok: false, status: 404, error: '库存记录不存在' }

  const before = Number(item.stock) || 0
  const after = before + qty

  // 事由统一带上"出库撤销"前缀，流水里一眼能看出这行是撤销产生的
  const remark = userRemark ? `出库撤销：${userRemark}` : '出库撤销'

  db.prepare('UPDATE inventory SET stock = ? WHERE id = ?').run(after, log.inventory_id)
  const info = insertRevokeLog.run(
    log.inventory_id,
    log.product_id ?? null, // 批量领料出库带产品，撤销要继承，否则产品维度对不上账
    log.material_id ?? null, // 绑 BOM 行出库时，撤销补偿行必须继承同一 material_id，
                            // 使 -SUM(delta) 在该 material_id 下能归零。
    qty,
    after,
    remark,
    logId
  )

  return {
    ok: true,
    log: db.prepare('SELECT * FROM inventory_log WHERE id = ?').get(info.lastInsertRowid),
    item: findById.get(log.inventory_id),
    revokedLogId: logId,
    inventoryId: log.inventory_id,
    delta: qty,
    stockBefore: before,
    stockAfter: after
  }
}

// ---------------------------------------------------------------------------
// POST /logs/revoke-bulk  批量撤销出库（注册在 /logs/:logId 之前）
//   body: { logIds: number[], remark?: string }
//
// 单事务：要么全部落库，要么全不落。但"不合格的行"不算失败——
// 前端是按当前页勾选的，其中可能混进已被别人撤过的行，整批回滚反而难用。
// 所以逐行跳过并在 errors 里汇报，与 /bulk 导入的处理方式一致。
// ---------------------------------------------------------------------------
router.post('/logs/revoke-bulk', (req, res, next) => {
  try {
    const raw = req.body?.logIds
    if (!Array.isArray(raw)) return res.status(400).json({ error: 'logIds 必须是数组' })

    // 去重：同一条撤两次必然第二次报"已撤销过"，不如提前去掉
    const logIds = [...new Set(raw.map(Number).filter(n => Number.isFinite(n) && n > 0))]
    if (logIds.length === 0) return res.status(400).json({ error: '没有可撤销的流水记录' })
    if (logIds.length > MAX_PAGE_SIZE) {
      return res.status(400).json({ error: `一次最多撤销 ${MAX_PAGE_SIZE} 条` })
    }

    const userRemark = String(req.body?.remark ?? '').trim()

    const revoked = []
    const errors = []

    const run = db.transaction(() => {
      // 按 id 升序处理：同一元件多条出库时，流水里的 stock_after 递增可读
      for (const logId of logIds.sort((a, b) => a - b)) {
        const r = revokeOneLog(logId, userRemark)
        if (r.ok) {
          revoked.push({
            logId,
            newLogId: r.log.id,
            inventoryId: r.inventoryId,
            qty: r.delta,
            stockAfter: r.stockAfter
          })
        } else {
          errors.push({ logId, error: r.error })
        }
      }
    })
    run()

    res.json({
      ok: true,
      revoked: revoked.length,
      skipped: errors.length,
      totalQty: revoked.reduce((a, x) => a + x.qty, 0),
      itemKinds: new Set(revoked.map(x => x.inventoryId)).size,
      details: revoked,
      errors
    })
  } catch (err) {
    if (isUniqueViolation(err)) {
      return res.status(409).json({ error: '所选记录中有已被撤销的，请刷新后重试' })
    }
    next(err)
  }
})

// ---------------------------------------------------------------------------
// DELETE /logs/by-product/:productId  删除某产品的全部出入库流水
//
// 清空库存台账中该产品关联的所有流水记录（入库/出库/盘点/初始/撤销）。
// 不删除库存记录本身，只清流水——库存数量不受影响。
//
// 用途：产品 BOM 作废后，历史流水已无追溯价值，留着只会干扰核对。
// ---------------------------------------------------------------------------
router.delete('/logs/by-product/:productId', (req, res, next) => {
  try {
    const productId = Number(req.params.productId)
    if (!Number.isFinite(productId) || productId <= 0) {
      return res.status(400).json({ error: '产品 ID 无效' })
    }

    // 先查有多少条会受影响，给用户一个明确预期
    const { count } = db.prepare(
      'SELECT COUNT(*) AS count FROM inventory_log WHERE product_id = ?'
    ).get(productId)

    if (count === 0) {
      return res.json({ ok: true, deleted: 0, message: '该产品没有出入库记录' })
    }

    const info = db.prepare('DELETE FROM inventory_log WHERE product_id = ?').run(productId)

    res.json({
      ok: true,
      deleted: info.changes,
      productId,
      message: `已删除 ${info.changes} 条出入库记录`
    })
  } catch (err) {
    next(err)
  }
})

// ---------------------------------------------------------------------------
// DELETE /logs/by-inventory/:inventoryId  删除某个元件的全部出入库流水
//
// 清空该库存记录的所有流水（入库/出库/盘点/初始/撤销）。
// 不删除库存记录本身，只清流水——库存数量不受影响。
// ---------------------------------------------------------------------------
router.delete('/logs/by-inventory/:inventoryId', (req, res, next) => {
  try {
    const inventoryId = Number(req.params.inventoryId)
    if (!Number.isFinite(inventoryId) || inventoryId <= 0) {
      return res.status(400).json({ error: '库存记录 ID 无效' })
    }

    if (!findById.get(inventoryId)) {
      return res.status(404).json({ error: '库存记录不存在' })
    }

    const { count } = db.prepare(
      'SELECT COUNT(*) AS count FROM inventory_log WHERE inventory_id = ?'
    ).get(inventoryId)

    if (count === 0) {
      return res.json({ ok: true, deleted: 0, message: '该元件没有出入库记录' })
    }

    const info = db.prepare('DELETE FROM inventory_log WHERE inventory_id = ?').run(inventoryId)

    res.json({
      ok: true,
      deleted: info.changes,
      inventoryId,
      message: `已删除 ${info.changes} 条出入库记录`
    })
  } catch (err) {
    next(err)
  }
})

// ---------------------------------------------------------------------------
// POST /logs/:logId/revoke  撤销单条出库（注册在 /:id 之前）
//   body: { remark?: string }
// ---------------------------------------------------------------------------
router.post('/logs/:logId/revoke', (req, res, next) => {
  try {
    const logId = Number(req.params.logId)
    const userRemark = String(req.body?.remark ?? '').trim()

    const revoke = db.transaction(() => revokeOneLog(logId, userRemark))
    const r = revoke()

    if (!r.ok) return res.status(r.status).json({ error: r.error })
    res.json(r)
  } catch (err) {
    // 并发下两个撤销请求同时通过检查时，靠唯一索引兜底
    if (isUniqueViolation(err)) {
      return res.status(409).json({ error: '该出库记录已撤销过' })
    }
    next(err)
  }
})

// ---------------------------------------------------------------------------
// POST /adopt-unmatched  把 BOM 里未匹配到库存的物料建进台账（注册在 /:id 之前）
//   body: { productId: number }
//
// 用途：新导入一份 BOM 后，台账里往往还没有这些元件，逐个手工新增太慢。
// 这里按制造商料号一次性建档，库存一律给 0 —— 建档只是"把料号登记进台账"，
// 手头到底有几个得靠入库/盘点如实录，不能凭 BOM 猜。
//
// 几个刻意的取舍：
//   1. 跳过 mfr_pn 为空的行。台账与 BOM 的关联依据就是 mfr_pn，
//      空料号建了也永远关联不上，只会往台账里塞永久对不上的死数据。
//   2. 按 mfr_pn 去重。同一料号在 BOM 里可能占多行（不同位号），
//      但台账是元件级的，只该有一条。
//   3. 库存 0 不写"初始"流水。没有实物入库就不该有流水，
//      否则流水里全是 delta=0 的噪音。
//   4. supplier_pn 撞唯一约束的行跳过并汇报，不静默清空料号建档 —— 那会丢信息。
// ---------------------------------------------------------------------------
router.post('/adopt-unmatched', (req, res, next) => {
  try {
    const productId = Number(req.body?.productId)
    if (!Number.isFinite(productId) || productId <= 0) {
      return res.status(400).json({ error: '请指定产品' })
    }

    const product = db.prepare('SELECT id, code FROM products WHERE id = ?').get(Math.floor(productId))
    if (!product) return res.status(404).json({ error: '产品不存在' })

    // 未匹配 = 该产品 BOM 里有制造商料号、但台账中没有同料号记录的行。
    // 同一料号可能占多行（不同位号），台账是元件级的只该建一条，
    // 所以先按料号挑出"最早出现的那一行"（firstId）再取它的字段。
    //
    // 不能写成 (SELECT x.name FROM materials x WHERE x.id = MIN(m.id))：
    // SQLite 不允许在关联子查询里引用外层的聚合结果，会报
    // "misuse of aggregate function MIN()"。改成先聚合出 id、再 JOIN 回去取值。
    const candidates = db
      .prepare(
        `WITH pick AS (
           SELECT m.mfr_pn AS mfr_pn, MIN(m.id) AS firstId, COUNT(*) AS bomLines
           FROM materials m
           WHERE m.product_id = ?
             AND m.mfr_pn <> ''
             AND NOT EXISTS (SELECT 1 FROM inventory i WHERE i.mfr_pn = m.mfr_pn)
           GROUP BY m.mfr_pn
         )
         SELECT p.mfr_pn, p.bomLines,
                f.name, f.package, f.mfr, f.supplier, f.supplier_pn
         FROM pick p
         JOIN materials f ON f.id = p.firstId
         ORDER BY p.firstId`
      )
      .all(product.id)

    // 空料号行数单独统计，好在结果里如实说明"为什么这几条没建"
    const { skippedNoPn } = db
      .prepare(
        `SELECT COUNT(*) AS skippedNoPn
         FROM materials WHERE product_id = ? AND mfr_pn = ''`
      )
      .get(product.id)

    if (candidates.length === 0) {
      return res.json({
        ok: true,
        inserted: 0,
        skipped: 0,
        skippedNoPn,
        details: [],
        errors: [],
        message: skippedNoPn > 0
          ? `没有可建档的未匹配料号（另有 ${skippedNoPn} 行无制造商料号，无法建档）`
          : '没有需要建档的未匹配料号'
      })
    }

    // --- 自动分配库位 --------------------------------------------------------
    // 建档时按顺序分配空位（A11→A15→A21…→B11…），让新建的料在货架上连续一片，
    // 找料时不用跳着找。分配发生在事务之前——先拿到位置再建档，逻辑更清晰。
    //
    // 不同于 findFreeLocations 的「只看已用范围」：台账可能还是空的，但空不代表
    // 没有位置可分。allocateFreeCells 从全网格取，台账空时照样能从 A11 开始排。
    //
    // 位置不够时不整批失败——分到几个算几个，剩下的留在未匹配列表里等人处理。
    // 全批失败时才报错：0 条能分 = 网格全满或已有同料号的记录，此时强行建档只
    // 会让元件挤在同一个格子里，不如让人知道。
    const usedLocations = db
      .prepare("SELECT location FROM inventory WHERE TRIM(location) != ''")
      .all()
      .map(r => r.location)

    const merges = db.prepare('SELECT * FROM location_merge').all().map(m => ({
      layer: m.layer, startRow: m.start_row, startCol: m.start_col,
      endRow: m.end_row, endCol: m.end_col,
      primary: `${m.layer}${m.start_row}${m.start_col}`
    }))

    const allocation = allocateFreeCells(usedLocations, candidates.length, merges)

    const insert = db.prepare(
      `INSERT INTO inventory (${CREATE_COLUMNS.join(', ')})
       VALUES (${CREATE_COLUMNS.map(() => '?').join(', ')})`
    )

    const details = []
    const errors = []
    let allocated = 0

    const run = db.transaction(() => {
      for (const c of candidates) {
        // 库存固定 0：建档 ≠ 入库。有分配到位置就带位置，没分到的留空（人工处理）。
        const data = normalize({ ...c, stock: 0 })
        if (allocated < allocation.cells.length) {
          data.location = allocation.cells[allocated]
          allocated++
        }
        try {
          const info = insert.run(...CREATE_COLUMNS.map(col => data[col]))
          details.push({
            id: info.lastInsertRowid,
            mfr_pn: c.mfr_pn,
            name: data.name,
            bomLines: c.bomLines,
            location: data.location || null
          })
        } catch (err) {
          errors.push({
            mfr_pn: c.mfr_pn,
            name: data.name,
            error: isUniqueViolation(err) ? conflictMessage(data.supplier_pn) : err.message
          })
        }
      }
    })
    run()

    res.json({
      ok: true,
      productCode: product.code,
      inserted: details.length,
      skipped: errors.length,
      skippedNoPn,
      locationAllocated: allocated,
      locationAvailable: allocation.available,
      details,
      errors
    })
  } catch (err) {
    next(err)
  }
})

// ---------------------------------------------------------------------------
// GET /:id  单条
// ---------------------------------------------------------------------------
router.get('/:id', (req, res, next) => {
  try {
    const row = findById.get(Number(req.params.id))
    if (!row) return res.status(404).json({ error: '库存记录不存在' })
    res.json(row)
  } catch (err) {
    next(err)
  }
})

// ---------------------------------------------------------------------------
// GET /:id/logs  单条流水
// ---------------------------------------------------------------------------
router.get('/:id/logs', (req, res, next) => {
  try {
    const id = Number(req.params.id)
    if (!findById.get(id)) return res.status(404).json({ error: '库存记录不存在' })

    const list = db
      .prepare(
        `SELECT l.id, l.inventory_id, l.product_id, l.material_id, l.type, l.delta, l.stock_after,
                l.remark, l.created_at, l.revokes_log_id,
                (SELECT r.id FROM inventory_log r WHERE r.revokes_log_id = l.id) AS revoked_by_log_id,
                ma.designator AS material_designator
         FROM inventory_log l
         LEFT JOIN materials ma ON ma.id = l.material_id
         WHERE l.inventory_id = ?
         ORDER BY l.id DESC LIMIT 200`
      )
      .all(id)

    res.json({ list, total: list.length })
  } catch (err) {
    next(err)
  }
})

// ---------------------------------------------------------------------------
// POST /  新增；初始库存 > 0 时同步落一条"初始"流水
// ---------------------------------------------------------------------------
router.post('/', (req, res, next) => {
  try {
    const data = normalize(req.body)
    if (!data.name && !data.supplier_pn && !data.mfr_pn) {
      return res.status(400).json({ error: '名称、供应商料号、制造商料号至少填一项' })
    }

    const create = db.transaction(() => {
      const info = db
        .prepare(
          `INSERT INTO inventory (${CREATE_COLUMNS.join(', ')})
           VALUES (${CREATE_COLUMNS.map(() => '?').join(', ')})`
        )
        .run(...CREATE_COLUMNS.map(c => data[c]))

      if (data.stock > 0) {
        insertLog.run(info.lastInsertRowid, '初始', data.stock, data.stock, '新建台账初始库存')
      }
      return info.lastInsertRowid
    })

    res.status(201).json(findById.get(create()))
  } catch (err) {
    if (isUniqueViolation(err)) {
      return res.status(409).json({ error: conflictMessage(req.body?.supplier_pn) })
    }
    next(err)
  }
})

// ---------------------------------------------------------------------------
// PUT /:id  局部更新；stock 被刻意排除，必须走 /move
// ---------------------------------------------------------------------------
router.put('/:id', (req, res, next) => {
  try {
    const id = Number(req.params.id)
    if (!findById.get(id)) return res.status(404).json({ error: '库存记录不存在' })

    const patch = normalize(req.body, { partial: true, columns: EDITABLE_COLUMNS })
    const keys = Object.keys(patch)
    if (keys.length === 0) return res.status(400).json({ error: '没有需要更新的字段' })

    db.prepare(`UPDATE inventory SET ${keys.map(k => `${k} = ?`).join(', ')} WHERE id = ?`)
      .run(...keys.map(k => patch[k]), id)

    res.json(findById.get(id))
  } catch (err) {
    if (isUniqueViolation(err)) {
      return res.status(409).json({ error: conflictMessage(req.body?.supplier_pn) })
    }
    next(err)
  }
})

/**
 * 解析并校验单件出库时的产品与 BOM 行绑定参数。
 *
 * 规则：
 *   - 只有出库可以带 productId/materialId；入库/盘点传了任何一项都直接 400。
 *   - 传 materialId 时必须同时传 productId，且 material.product_id 要一致。
 *   - material.mfr_pn 必须与目标库存台账行的 mfr_pn 相同，防止把出库绑到
 *     一块板 BOM 里同名不同料的行上。
 *   - 不传时保持原来的未绑定出库行为，product_id/material_id 均为 NULL。
 *
 * @returns {{ ok: true, productId?: number, materialId?: number } | { ok: false, error: string }}
 */
function parseOutboundBinding(type, body, inventoryRow) {
  const rawProductId = Number(body?.productId)
  const rawMaterialId = Number(body?.materialId)
  const hasProduct = Number.isFinite(rawProductId) && rawProductId > 0
  const hasMaterial = Number.isFinite(rawMaterialId) && rawMaterialId > 0

  if (!hasProduct && !hasMaterial) return { ok: true }

  if (type !== '出库') {
    return { ok: false, error: '只有出库可以绑定产品与 BOM 行' }
  }

  const productId = hasProduct ? Math.floor(rawProductId) : undefined
  const materialId = hasMaterial ? Math.floor(rawMaterialId) : undefined

  if (hasMaterial && !hasProduct) {
    return { ok: false, error: '绑定 BOM 行时必须同时提供 productId' }
  }

  if (hasMaterial) {
    const material = findMaterialById.get(materialId)
    if (!material) {
      return { ok: false, error: 'BOM 行不存在' }
    }
    if (material.product_id !== productId) {
      return { ok: false, error: 'BOM 行不属于指定产品' }
    }
    if (material.mfr_pn !== inventoryRow.mfr_pn) {
      return { ok: false, error: 'BOM 行制造商料号与库存台账不匹配' }
    }
  }

  return { ok: true, productId, materialId }
}

// ---------------------------------------------------------------------------
// POST /:id/move  出入库：库存变动的唯一入口，库存与流水同事务写入
//   body: { type: '入库'|'出库'|'盘点', qty: number, remark?: string,
//           productId?: number, materialId?: number }
//   入库 qty 加、出库 qty 减、盘点直接把库存设为 qty
//   出库时可额外绑定产品(productId) 与 BOM 行(materialId)，默认不绑
// ---------------------------------------------------------------------------
router.post('/:id/move', (req, res, next) => {
  try {
    const id = Number(req.params.id)
    const row = findById.get(id)
    if (!row) return res.status(404).json({ error: '库存记录不存在' })

    const type = String(req.body?.type ?? '').trim()
    if (!MOVE_TYPES.has(type)) {
      return res.status(400).json({ error: `类型必须是 ${[...MOVE_TYPES].join(' / ')}` })
    }

    const rawQty = Number(req.body?.qty)
    if (!Number.isFinite(rawQty) || rawQty < 0) {
      return res.status(400).json({ error: '数量必须是不小于 0 的整数' })
    }
    const qty = Math.floor(rawQty)
    if (type !== '盘点' && qty === 0) {
      return res.status(400).json({ error: '出入库数量必须大于 0' })
    }

    const binding = parseOutboundBinding(type, req.body, row)
    if (!binding.ok) {
      return res.status(400).json({ error: binding.error })
    }

    const before = Number(row.stock) || 0
    let after
    if (type === '入库') after = before + qty
    else if (type === '出库') after = before - qty
    else after = qty // 盘点：直接以实盘数为准

    if (after < 0) {
      return res.status(400).json({ error: `库存不足：当前 ${before}，无法出库 ${qty}` })
    }

    const delta = after - before
    const remark = String(req.body?.remark ?? '').trim()

    const move = db.transaction(() => {
      db.prepare('UPDATE inventory SET stock = ? WHERE id = ?').run(after, id)
      if (type === '出库' && binding.materialId != null) {
        // 绑定出库：走专用语句，可写 product_id/material_id。
        // 这里 materialId 有值时 productId 一定也有值（parseOutboundBinding 保证）。
        insertBoundOutboundLog.run(id, binding.productId, binding.materialId, delta, after, remark)
      } else if (type === '出库' && binding.productId != null) {
        // 只绑产品、不绑 BOM 行：仍走通用出库逻辑，只写 product_id。
        // 目前通用 insertLog 不含 product_id，所以用单独的 "出库+product_id" 语句。
        // 不通过 materialId，因此不会触发聚合，安全。
        insertProductOutboundLog.run(id, binding.productId, delta, after, remark)
      } else {
        // 入库 / 盘点 / 未绑定出库：继续用原始 5 参数语句，绝不出 material_id
        insertLog.run(id, type, delta, after, remark)
      }
    })
    move()

    res.json({ ...findById.get(id), delta, stockBefore: before, stockAfter: after })
  } catch (err) {
    next(err)
  }
})

// ---------------------------------------------------------------------------
// DELETE /:id  台账删除；流水由外键 ON DELETE CASCADE 一并清除
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// POST /bulk-delete  批量删除（注册在 /:id 之前，否则 'bulk-delete' 会被当成 id）
//   body: { ids: number[] }
//
// 单事务：要么全删，要么全不删。与 /logs/revoke-bulk 的「逐行跳过」不同——
// 删除是不可恢复操作，用户勾了 20 条就该确切知道这 20 条的下场，
// 悄悄跳过几条会让人以为删干净了。所以不存在的 id 直接整批拒绝。
//
// 流水由外键 ON DELETE CASCADE 一并清除，所以返回被删元件的库存与流水条数，
// 让前端能在确认框里说清「连带清掉多少账目」。
// ---------------------------------------------------------------------------
router.post('/bulk-delete', (req, res, next) => {
  try {
    const raw = req.body?.ids
    if (!Array.isArray(raw)) return res.status(400).json({ error: 'ids 必须是数组' })

    const ids = [...new Set(raw.map(Number).filter(n => Number.isFinite(n) && n > 0))]
    if (ids.length === 0) return res.status(400).json({ error: '没有可删除的记录' })
    if (ids.length > MAX_PAGE_SIZE) {
      return res.status(400).json({ error: `一次最多删除 ${MAX_PAGE_SIZE} 条` })
    }

    const placeholders = ids.map(() => '?').join(', ')

    // 先查齐：删之前要拿到名称/库存/流水数用于回报，删完就查不到了。
    // 同时校验是否有不存在的 id——批量删除不容许"悄悄少删几条"。
    const found = db
      .prepare(
        `SELECT i.id, i.name, i.mfr_pn, i.supplier_pn, i.stock,
                (SELECT COUNT(*) FROM inventory_log l WHERE l.inventory_id = i.id) AS logCount
         FROM inventory i
         WHERE i.id IN (${placeholders})`
      )
      .all(...ids)

    if (found.length !== ids.length) {
      const foundIds = new Set(found.map(r => r.id))
      const missing = ids.filter(id => !foundIds.has(id))
      return res.status(404).json({
        error: `以下记录不存在，已取消整批删除：${missing.join(', ')}`
      })
    }

    const run = db.transaction(() => {
      db.prepare(`DELETE FROM inventory WHERE id IN (${placeholders})`).run(...ids)
    })
    run()

    res.json({
      ok: true,
      deleted: found.length,
      // 连带清掉的流水条数与库存件数，供前端汇报
      logsRemoved: found.reduce((a, r) => a + (Number(r.logCount) || 0), 0),
      stockRemoved: found.reduce((a, r) => a + (Number(r.stock) || 0), 0),
      details: found.map(r => ({
        id: r.id,
        name: r.name || r.mfr_pn || r.supplier_pn || `#${r.id}`,
        stock: r.stock,
        logCount: r.logCount
      }))
    })
  } catch (err) {
    next(err)
  }
})

router.delete('/:id', (req, res, next) => {
  try {
    const id = Number(req.params.id)
    const info = db.prepare('DELETE FROM inventory WHERE id = ?').run(id)
    if (info.changes === 0) return res.status(404).json({ error: '库存记录不存在' })
    res.json({ ok: true, id })
  } catch (err) {
    next(err)
  }
})

// ---------------------------------------------------------------------------
// POST /bulk  批量导入：单事务；无有效标识的行跳过而不是整批失败
//   mode: 'append' 追加 | 'replace' 清空重建 | 'upsert' 按 supplier_pn 合并库存
// ---------------------------------------------------------------------------
router.post('/bulk', (req, res, next) => {
  try {
    const { rows, mode = 'append' } = req.body || {}
    if (!Array.isArray(rows)) return res.status(400).json({ error: 'rows 必须是数组' })

    const insert = db.prepare(
      `INSERT INTO inventory (${CREATE_COLUMNS.join(', ')})
       VALUES (${CREATE_COLUMNS.map(() => '?').join(', ')})`
    )
    const findBySupplierPn = db.prepare("SELECT * FROM inventory WHERE supplier_pn = ? AND supplier_pn <> ''")
    const bumpStock = db.prepare('UPDATE inventory SET stock = ? WHERE id = ?')

    let inserted = 0
    let updated = 0
    let skipped = 0
    const errors = []

    const run = db.transaction(() => {
      if (mode === 'replace') {
        db.exec('DELETE FROM inventory_log')
        db.exec('DELETE FROM inventory')
        db.exec("DELETE FROM sqlite_sequence WHERE name IN ('inventory', 'inventory_log')")
      }

      rows.forEach((raw, i) => {
        const data = normalize(raw)
        if (!data.name && !data.supplier_pn && !data.mfr_pn) {
          skipped++
          errors.push({ row: i + 1, error: '名称/供应商料号/制造商料号全为空，已跳过' })
          return
        }

        try {
          // upsert：同一供应商料号已存在则累加库存并补流水，不新建行
          if (mode === 'upsert' && data.supplier_pn) {
            const hit = findBySupplierPn.get(data.supplier_pn)
            if (hit) {
              if (data.stock > 0) {
                const after = (Number(hit.stock) || 0) + data.stock
                bumpStock.run(after, hit.id)
                insertLog.run(hit.id, '入库', data.stock, after, '批量导入合并')
              }
              updated++
              return
            }
          }

          const info = insert.run(...CREATE_COLUMNS.map(c => data[c]))
          if (data.stock > 0) {
            insertLog.run(info.lastInsertRowid, '初始', data.stock, data.stock, '批量导入初始库存')
          }
          inserted++
        } catch (err) {
          skipped++
          errors.push({
            row: i + 1,
            error: isUniqueViolation(err) ? conflictMessage(data.supplier_pn) : err.message
          })
        }
      })
    })

    run()
    res.json({ inserted, updated, skipped, errors })
  } catch (err) {
    next(err)
  }
})

export default router
