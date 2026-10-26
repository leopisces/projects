// 给 inventory_log 加"这次出库领的是 BOM 清单的哪一行料"。
//
// 业务语义：产品级绑定（product_id）已存在，但它只能回答"这批料是为哪个
// 产品领的"。出库时要进一步绑到 BOM 清单的具体行（material），这样产品
// 才能知道每一行料是否已经领用焊接。
//
// 关键不变量：material_id 只写在"出库"行及其撤销补偿行上，绝不写入
// "入库"/"盘点"/"初始"行——因为"已焊接量"按 -SUM(delta) 聚合，
// 盘点的正负 delta 会污染结果。
//
// 幂等：列已存在则跳过。历史流水的 material_id 为 NULL
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
export function migrateLogMaterial(db) {
  let addedColumn = false

  const run = db.transaction(() => {
    // SQLite 的 ALTER TABLE ADD COLUMN 不支持 IF NOT EXISTS，先自查。
    // 刻意不加 REFERENCES：SQLite 无法给已有表补外键，且 BOM 行删除时
    // 流水应保留（历史记录不该因为 BOM 行被删就消失）。
    if (!hasColumn(db, 'inventory_log', 'material_id')) {
      db.exec('ALTER TABLE inventory_log ADD COLUMN material_id INTEGER')
      addedColumn = true
    }
    db.exec('CREATE INDEX IF NOT EXISTS idx_inv_log_material ON inventory_log(material_id, id DESC)')
  })

  run()
  return { addedColumn }
}

// CLI：node server/db/migrate-log-material.js
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

  console.log('[ompcb] 流水物料行绑定迁移结果:', migrateLogMaterial(db))
  db.close()
  process.exit(0)
}
