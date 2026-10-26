// 给 inventory_log 增加"撤销出库"追溯能力。
//
// 业务语义：撤销一条出库记录时，不删除原记录，而是新增一条入库记录把库存加回来。
// 新入库行的 revokes_log_id 指向被撤销的出库行，从而保证：
//   1. 库存与流水永远一致（库存变动必由流水承载）
//   2. 原出库记录完整保留，便于审计
//   3. 同一条出库记录只能被撤销一次（由部分唯一索引保证）
//
// 幂等：列已存在则跳过。历史行 revokes_log_id 为 NULL。

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
export function migrateLogRevoke(db) {
  let addedColumn = false

  const run = db.transaction(() => {
    // SQLite 的 ALTER TABLE ADD COLUMN 不支持 IF NOT EXISTS，先自查。
    // 刻意不加 REFERENCES：SQLite 无法给已有表补外键；逻辑上它指向同表的
    // 出库行，靠业务代码与唯一索引共同维护。
    if (!hasColumn(db, 'inventory_log', 'revokes_log_id')) {
      db.exec('ALTER TABLE inventory_log ADD COLUMN revokes_log_id INTEGER')
      addedColumn = true
    }

    // 部分唯一索引：仅在 revokes_log_id 不为 NULL 的行生效，
    // 保证一条出库记录最多只能产生一条撤销入库。
    db.exec(
      'CREATE UNIQUE INDEX IF NOT EXISTS uq_inv_log_revokes ON inventory_log(revokes_log_id) WHERE revokes_log_id IS NOT NULL'
    )
  })

  run()
  return { addedColumn }
}

// CLI：node server/db/migrate-log-revoke.js
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

  console.log('[ompcb] 流水撤销出库迁移结果:', migrateLogRevoke(db))
  db.close()
  process.exit(0)
}
