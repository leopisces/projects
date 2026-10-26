// materials 加入"产品"维度的一次性迁移。
//
// 幂等：可反复执行。只做三件事，绝不删除任何 BOM 数据：
//   1. materials 追加 product_id 列（列已存在则跳过）
//   2. 建默认产品，把所有 product_id 为空的历史行归入它
//   3. 把全局唯一的位号索引换成"产品内唯一"
//      （否则两个产品都用 R1 会冲突）

import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

const DEFAULT_PRODUCT_CODE = 'AGB_CPU_03'
const DEFAULT_PRODUCT_NAME = 'AGB 主板（历史 BOM 数据）'

function hasColumn(db, table, column) {
  return db.prepare(`PRAGMA table_info(${table})`).all().some(c => c.name === column)
}

function indexExists(db, name) {
  return Boolean(
    db.prepare("SELECT 1 FROM sqlite_master WHERE type='index' AND name=?").get(name)
  )
}

/**
 * @param {import('better-sqlite3').Database} db
 * @returns {{ addedColumn: boolean, productId: number, adopted: number, reindexed: boolean }}
 */
export function migrateProducts(db) {
  let addedColumn = false
  let adopted = 0
  let reindexed = false

  const run = db.transaction(() => {
    // --- 1. 追加 product_id 列 -------------------------------------------
    // SQLite 的 ALTER TABLE ADD COLUMN 不支持 IF NOT EXISTS，先自查。
    // 这里刻意不加 REFERENCES：SQLite 无法给已有表补外键，
    // 产品删除时的处理交由 routes/products.js 显式控制。
    if (!hasColumn(db, 'materials', 'product_id')) {
      db.exec('ALTER TABLE materials ADD COLUMN product_id INTEGER')
      addedColumn = true
    }
    db.exec('CREATE INDEX IF NOT EXISTS idx_materials_product ON materials(product_id)')

    // --- 2. 历史行归入默认产品 --------------------------------------------
    const orphans = db
      .prepare('SELECT COUNT(*) AS c FROM materials WHERE product_id IS NULL')
      .get().c

    let productId = null
    if (orphans > 0) {
      const existing = db.prepare('SELECT id FROM products WHERE code = ?').get(DEFAULT_PRODUCT_CODE)
      productId = existing
        ? existing.id
        : db
            .prepare('INSERT INTO products (code, name, remark) VALUES (?, ?, ?)')
            .run(DEFAULT_PRODUCT_CODE, DEFAULT_PRODUCT_NAME, '由旧版扁平 BOM 自动归集').lastInsertRowid

      adopted = db
        .prepare('UPDATE materials SET product_id = ? WHERE product_id IS NULL')
        .run(productId).changes
    }

    // --- 3. 位号唯一约束改为产品内唯一 -------------------------------------
    if (indexExists(db, 'uq_materials_designator')) {
      db.exec('DROP INDEX uq_materials_designator')
      reindexed = true
    }
    db.exec(`CREATE UNIQUE INDEX IF NOT EXISTS uq_materials_product_designator
             ON materials(product_id, designator) WHERE designator <> ''`)

    return productId
  })

  const productId = run()
  return { addedColumn, productId, adopted, reindexed }
}

// CLI：node server/db/migrate-products.js
// 与 seed.js / migrate-inventory.js 同样的理由：自己开库，避免循环依赖。
if (process.argv[1] === __filename) {
  const { default: Database } = await import('better-sqlite3')
  const { mkdirSync, readFileSync } = await import('node:fs')

  const dbPath = process.env.OMPCB_DB || join(__dirname, '../../data/ompcb.db')
  mkdirSync(dirname(dbPath), { recursive: true })

  const db = new Database(dbPath)
  db.pragma('journal_mode = WAL')
  db.pragma('foreign_keys = ON')
  db.exec(readFileSync(join(__dirname, 'schema.sql'), 'utf8'))

  console.log('[ompcb] 产品维度迁移结果:', migrateProducts(db))
  db.close()
  process.exit(0)
}
