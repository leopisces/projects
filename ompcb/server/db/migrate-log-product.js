// 给 inventory_log 加"这次出库是为哪个产品领的料"。
//
// 为什么要存而不是靠料号反推：一个通用元件（如 100nF）会出现在多个产品的
// BOM 里，靠 mfr_pn 反查产品会在每个产品下都命中，统计不准。
//
// 幂等：列已存在则跳过。历史流水的 product_id 为 NULL
// （旧数据没记录来源，无法追溯，不做猜测性回填）。

import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

function hasColumn(db, table, column) {
  return db.prepare(`PRAGMA table_info(${table})`).all().some(c => c.name === column)
}

/**
 * @param {import('better-sqlite3').Database} db
 * @returns {{ addedColumn: boolean }}
 */
export function migrateLogProduct(db) {
  let addedColumn = false

  const run = db.transaction(() => {
    // SQLite 的 ALTER TABLE ADD COLUMN 不支持 IF NOT EXISTS，先自查。
    // 刻意不加 REFERENCES：SQLite 无法给已有表补外键，且产品删除时
    // 流水应保留（历史记录不该因为产品被删就消失）。
    if (!hasColumn(db, 'inventory_log', 'product_id')) {
      db.exec('ALTER TABLE inventory_log ADD COLUMN product_id INTEGER')
      addedColumn = true
    }
    db.exec('CREATE INDEX IF NOT EXISTS idx_inv_log_product ON inventory_log(product_id, id DESC)')
  })

  run()
  return { addedColumn }
}

// CLI：node server/db/migrate-log-product.js
// 与其他迁移同理：自己开库，避免和 db/index.js 循环依赖。
if (process.argv[1] === __filename) {
  const { default: Database } = await import('better-sqlite3')
  const { mkdirSync, readFileSync } = await import('node:fs')

  const dbPath = process.env.OMPCB_DB || join(__dirname, '../../data/ompcb.db')
  mkdirSync(dirname(dbPath), { recursive: true })

  const db = new Database(dbPath)
  db.pragma('journal_mode = WAL')
  db.pragma('foreign_keys = ON')
  db.exec(readFileSync(join(__dirname, 'schema.sql'), 'utf8'))

  console.log('[ompcb] 流水产品维度迁移结果:', migrateLogProduct(db))
  db.close()
  process.exit(0)
}
