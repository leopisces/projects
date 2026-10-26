// 给 materials 加「绑定前的原导入值」快照 + 绑定标记。
//
// 背景：BOM 页可以把某条库存记录的制造商料号「绑定」到 BOM 行上
// （见 routes/materials.js 的 POST /:id/bind）。绑定会覆盖 m.mfr_pn，
// 原来导入时填的料号就没了。而用户需要在表格里 hover 看到原导入的信息，
// 所以必须在覆盖之前把原值留一份。
//
// 为什么要 bound_at 而不是从 src_* 反推「是否绑定过」：
// 结构件（AGB CPU 之类）导入时 mfr_pn 本来就是空的，绑定后快照也是空字符串，
// 靠「src_* 非空」或「src_mfr_pn <> mfr_pn」判断都会把这些行误判成未绑定 ——
// 而它们恰恰是最需要绑定的行。所以用一个独立的时间戳列，NULL 表示从未绑定。
//
// 关键约束（改动这里前务必读）：
//   1. 这 5 列绝不能进 routes/materials.js 的 EDITABLE_COLUMNS。
//      normalize() 会把 EDITABLE_COLUMNS 里的每一列都写成 String(raw ?? '')，
//      批量导入会因此把快照清成空值，功能直接失效。
//   2. 快照只能从 m.* 抄（BOM 自己绑定前的值），绝不能从 inventory 抄。
//      从库存抄就等于把库存数据存进了 BOM，违背「BOM 不存库存信息」的设计，
//      而且库存一改快照就飘了。
//
// 幂等：列已存在则跳过。历史行 src_* 得到 DEFAULT ''，bound_at 为 NULL
// （旧数据没有绑定记录，不做猜测性回填 —— 与其他迁移一致）。
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

function hasColumn(db, table, column) {
  return db.prepare(`PRAGMA table_info(${table})`).all().some(c => c.name === column)
}

// [列名, 列定义]。src_* 给 DEFAULT '' 是必须的：
// 它们不在 EDITABLE_COLUMNS 里，INSERT 语句不会列出它们，
// NOT NULL 而无默认值会让所有新增行直接失败。
const COLUMNS = [
  ['src_mfr_pn', "TEXT NOT NULL DEFAULT ''"],
  ['src_mfr', "TEXT NOT NULL DEFAULT ''"],
  ['src_supplier', "TEXT NOT NULL DEFAULT ''"],
  ['src_supplier_pn', "TEXT NOT NULL DEFAULT ''"],
  // 绑定时间。可空，NULL = 从未绑定过；也顺带留下「什么时候绑的」
  ['bound_at', 'TEXT']
]

/**
 * @param {import('better-sqlite3').Database} db
 * @returns {{ addedColumn: boolean, added: string[] }}
 */
export function migrateMaterialsBind(db) {
  const added = []

  const run = db.transaction(() => {
    for (const [col, ddl] of COLUMNS) {
      // SQLite 的 ALTER TABLE ADD COLUMN 不支持 IF NOT EXISTS，先自查。
      if (!hasColumn(db, 'materials', col)) {
        db.exec(`ALTER TABLE materials ADD COLUMN ${col} ${ddl}`)
        added.push(col)
      }
    }
  })

  run()
  return { addedColumn: added.length > 0, added }
}

// CLI：node server/db/migrate-materials-bind.js
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

  console.log('[ompcb] BOM 绑定快照列迁移结果:', migrateMaterialsBind(db))
  db.close()
  process.exit(0)
}
