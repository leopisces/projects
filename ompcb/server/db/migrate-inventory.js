// 从 materials(板级 BOM) 抽取初始库存台账。
//
// 一次性迁移，幂等：inventory 表已有数据时直接跳过，绝不覆盖已维护的台账。
// materials 表只读，不做任何修改。
//
// 去重键（业务唯一键是 supplier_pn，但空料号无法参与去重，故逐级降级）：
//   1. supplier_pn 非空 → 按 supplier_pn 合并
//   2. 否则 mfr_pn 非空 → 按 mfr_pn 合并
//   3. 否则           → 按 name + package 合并
// 合并时 stock 相加，文本字段取第一个非空值。

import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

const TEXT_FIELDS = ['name', 'package', 'mfr_pn', 'mfr', 'supplier', 'supplier_pn', 'location', 'remark']

/** 同一元件的多行 BOM 记录归并到同一个 key 上 */
function dedupeKey(row) {
  const supplierPn = String(row.supplier_pn ?? '').trim()
  if (supplierPn) return `sp:${supplierPn}`

  const mfrPn = String(row.mfr_pn ?? '').trim()
  if (mfrPn) return `mp:${mfrPn}`

  return `nm:${String(row.name ?? '').trim()}|${String(row.package ?? '').trim()}`
}

/**
 * @param {import('better-sqlite3').Database} db
 * @param {{ force?: boolean }} options force=true 时清空 inventory 后重新抽取
 * @returns {{ skipped: boolean, inserted: number, merged: number, reason?: string }}
 */
export function migrateInventory(db, { force = false } = {}) {
  const { count: existing } = db.prepare('SELECT COUNT(*) AS count FROM inventory').get()

  if (existing > 0 && !force) {
    return { skipped: true, inserted: 0, merged: 0, reason: 'inventory 表已有数据' }
  }

  const source = db
    .prepare(
      `SELECT name, package, mfr_pn, mfr, supplier, supplier_pn, stock, location, remark
       FROM materials
       ORDER BY seq ASC, id ASC`
    )
    .all()

  if (source.length === 0) {
    return { skipped: true, inserted: 0, merged: 0, reason: 'materials 表为空，无可抽取数据' }
  }

  // 归并：Map 保序，先出现的行决定文本字段
  const grouped = new Map()
  let merged = 0

  for (const row of source) {
    const key = dedupeKey(row)
    const hit = grouped.get(key)

    if (!hit) {
      // 不带 status：状态由 stock 派生（stock<=0 缺货 / >0 正常），不落库
      const item = { stock: 0 }
      for (const f of TEXT_FIELDS) item[f] = String(row[f] ?? '').trim()
      item.stock = Math.max(0, Math.floor(Number(row.stock) || 0))
      grouped.set(key, item)
      continue
    }

    // 已有同料号：库存累加，文本字段补齐空缺
    hit.stock += Math.max(0, Math.floor(Number(row.stock) || 0))
    for (const f of TEXT_FIELDS) {
      if (!hit[f]) hit[f] = String(row[f] ?? '').trim()
    }
    merged++
  }

  const insertItem = db.prepare(
    `INSERT INTO inventory (name, package, mfr_pn, mfr, supplier, supplier_pn, stock, location, remark)
     VALUES (@name, @package, @mfr_pn, @mfr, @supplier, @supplier_pn, @stock, @location, @remark)`
  )
  const insertLog = db.prepare(
    `INSERT INTO inventory_log (inventory_id, type, delta, stock_after, remark)
     VALUES (?, '初始', ?, ?, ?)`
  )

  let inserted = 0

  const run = db.transaction(() => {
    if (force) {
      // 先删流水再删台账：inventory_log 有外键指向 inventory
      db.exec('DELETE FROM inventory_log')
      db.exec('DELETE FROM inventory')
      db.exec("DELETE FROM sqlite_sequence WHERE name IN ('inventory', 'inventory_log')")
    }

    for (const item of grouped.values()) {
      const info = insertItem.run(item)
      inserted++
      // 库存为 0 的不落流水，避免一堆 delta=0 的空记录
      if (item.stock > 0) {
        insertLog.run(info.lastInsertRowid, item.stock, item.stock, '由 BOM 抽取初始化')
      }
    }
  })

  run()

  return { skipped: false, inserted, merged }
}

// 作为 CLI 运行时：node server/db/migrate-inventory.js [--force]
// 与 seed.js 同样的理由：这里必须自己开库，绝不能 import('./index.js')——
// index.js 静态依赖本文件，绕道会形成循环依赖。
if (process.argv[1] === __filename) {
  const { default: Database } = await import('better-sqlite3')
  const { mkdirSync, readFileSync } = await import('node:fs')

  const dbPath = process.env.OMPCB_DB || join(__dirname, '../../data/ompcb.db')
  mkdirSync(dirname(dbPath), { recursive: true })

  const db = new Database(dbPath)
  db.pragma('journal_mode = WAL')
  db.pragma('foreign_keys = ON')
  db.exec(readFileSync(join(__dirname, 'schema.sql'), 'utf8'))

  const force = process.argv.includes('--force')
  const result = migrateInventory(db, { force })
  console.log('[ompcb] 库存台账抽取结果:', result)
  db.close()
  process.exit(0)
}
