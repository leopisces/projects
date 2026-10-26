import express from 'express'
import { db } from '../db/index.js'

const router = express.Router()

const EDITABLE_COLUMNS = ['code', 'name', 'remark']

const SORTABLE_COLUMNS = new Set(['code', 'name', 'created_at', 'updated_at', 'id'])

function normalize(input = {}, { partial = false } = {}) {
  const out = {}
  for (const col of EDITABLE_COLUMNS) {
    if (partial && !Object.prototype.hasOwnProperty.call(input, col)) continue
    out[col] = String(input[col] ?? '').trim()
  }
  return out
}

function isUniqueViolation(err) {
  return err && (err.code === 'SQLITE_CONSTRAINT_UNIQUE' || err.code === 'SQLITE_CONSTRAINT_PRIMARYKEY')
}

const findById = db.prepare('SELECT * FROM products WHERE id = ?')

// 每个产品的 BOM 汇总：行数、总用量，以及按制造商料号动态匹配库存后的缺料统计。
// 关联规则：materials.mfr_pn = inventory.mfr_pn（都非空才算匹配上）。
// 缺料按单板（做 1 套）计算：需求 − 可用库存，未匹配到库存的按可用 0 算（全缺）。
const STATS_SQL = `
  SELECT
    COUNT(*)                                            AS bomLines,
    COALESCE(SUM(m.qty), 0)                             AS totalQty,
    COALESCE(SUM(CASE WHEN i.id IS NOT NULL THEN 1 ELSE 0 END), 0) AS matchedLines,
    COALESCE(SUM(CASE WHEN i.id IS NULL     THEN 1 ELSE 0 END), 0) AS unmatchedLines,
    COALESCE(SUM(CASE WHEN MAX(m.qty - COALESCE(i.stock, 0), 0) > 0 THEN 1 ELSE 0 END), 0) AS shortageLines,
    COALESCE(SUM(MAX(m.qty - COALESCE(i.stock, 0), 0)), 0) AS shortageQty
  FROM materials m
  LEFT JOIN inventory i
    ON m.mfr_pn <> '' AND i.mfr_pn = m.mfr_pn
  WHERE m.product_id = ?
`

// ---------------------------------------------------------------------------
// GET /  产品列表（带 BOM 汇总，供下拉与概览用）
// ---------------------------------------------------------------------------
router.get('/', (req, res, next) => {
  try {
    const sortBy = SORTABLE_COLUMNS.has(String(req.query.sortBy)) ? String(req.query.sortBy) : 'code'
    const sortOrder = String(req.query.sortOrder).toLowerCase() === 'desc' ? 'DESC' : 'ASC'

    const list = db.prepare(`SELECT * FROM products ORDER BY ${sortBy} ${sortOrder}, id ASC`).all()

    const statsStmt = db.prepare(STATS_SQL)
    const withStats = list.map(p => ({ ...p, ...statsStmt.get(p.id) }))

    res.json({ list: withStats, total: withStats.length })
  } catch (err) {
    next(err)
  }
})

// ---------------------------------------------------------------------------
// GET /:id  单个产品（带汇总）
// ---------------------------------------------------------------------------
router.get('/:id', (req, res, next) => {
  try {
    const row = findById.get(Number(req.params.id))
    if (!row) return res.status(404).json({ error: '产品不存在' })
    res.json({ ...row, ...db.prepare(STATS_SQL).get(row.id) })
  } catch (err) {
    next(err)
  }
})

// ---------------------------------------------------------------------------
// POST /  新建产品
// ---------------------------------------------------------------------------
router.post('/', (req, res, next) => {
  try {
    const data = normalize(req.body)
    if (!data.code) return res.status(400).json({ error: '产品编号不能为空' })

    const info = db
      .prepare(
        `INSERT INTO products (${EDITABLE_COLUMNS.join(', ')})
         VALUES (${EDITABLE_COLUMNS.map(() => '?').join(', ')})`
      )
      .run(...EDITABLE_COLUMNS.map(c => data[c]))

    res.status(201).json(findById.get(info.lastInsertRowid))
  } catch (err) {
    if (isUniqueViolation(err)) {
      return res.status(409).json({ error: `产品编号 ${req.body?.code ?? ''} 已存在`.trim() })
    }
    next(err)
  }
})

// ---------------------------------------------------------------------------
// PUT /:id  改产品信息（含重命名）
// ---------------------------------------------------------------------------
router.put('/:id', (req, res, next) => {
  try {
    const id = Number(req.params.id)
    if (!findById.get(id)) return res.status(404).json({ error: '产品不存在' })

    const patch = normalize(req.body, { partial: true })
    const keys = Object.keys(patch)
    if (keys.length === 0) return res.status(400).json({ error: '没有需要更新的字段' })

    if (Object.prototype.hasOwnProperty.call(patch, 'code') && !patch.code) {
      return res.status(400).json({ error: '产品编号不能为空' })
    }

    db.prepare(`UPDATE products SET ${keys.map(k => `${k} = ?`).join(', ')} WHERE id = ?`)
      .run(...keys.map(k => patch[k]), id)

    res.json(findById.get(id))
  } catch (err) {
    if (isUniqueViolation(err)) {
      return res.status(409).json({ error: `产品编号 ${req.body?.code ?? ''} 已存在`.trim() })
    }
    next(err)
  }
})

// ---------------------------------------------------------------------------
// DELETE /:id  删除产品
//   默认拒绝删除还挂着 BOM 的产品，避免一次误操作清掉整份 BOM；
//   确实要连 BOM 一起删时传 ?withBom=1。
// ---------------------------------------------------------------------------
router.delete('/:id', (req, res, next) => {
  try {
    const id = Number(req.params.id)
    if (!findById.get(id)) return res.status(404).json({ error: '产品不存在' })

    const { c: bomLines } = db
      .prepare('SELECT COUNT(*) AS c FROM materials WHERE product_id = ?')
      .get(id)

    const withBom = String(req.query.withBom ?? '') === '1'
    if (bomLines > 0 && !withBom) {
      return res.status(409).json({
        error: `该产品下还有 ${bomLines} 条 BOM 明细，请先清空或确认连同 BOM 一起删除`,
        bomLines
      })
    }

    const remove = db.transaction(() => {
      // SQLite 老表补不了外键，这里显式删除子行
      const removedBom = db.prepare('DELETE FROM materials WHERE product_id = ?').run(id).changes
      db.prepare('DELETE FROM products WHERE id = ?').run(id)
      return removedBom
    })

    res.json({ ok: true, id, removedBom: remove() })
  } catch (err) {
    next(err)
  }
})

export default router
