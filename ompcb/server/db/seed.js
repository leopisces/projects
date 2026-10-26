import { readFileSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

// seed.tsv 的 12 列（与表列一一对应，不含 remark）
const TSV_HEADERS = [
  'seq',
  'name',
  'designator',
  'package',
  'qty',
  'mfr_pn',
  'mfr',
  'supplier',
  'supplier_pn',
  'status',
  'stock',
  'location'
]

const EDITABLE_COLUMNS = [
  'seq',
  'name',
  'designator',
  'package',
  'qty',
  'mfr_pn',
  'mfr',
  'supplier',
  'supplier_pn',
  'status',
  'stock',
  'location',
  'remark'
]

export function parseSeedTsv() {
  const content = readFileSync(join(__dirname, 'seed.tsv'), 'utf8')
  const lines = content.replace(/\r/g, '').split('\n')
  const dataLines = lines.slice(1).filter(line => line !== '')

  return dataLines.map(line => {
    const cols = line.split('\t')
    const row = {}

    TSV_HEADERS.forEach((key, i) => {
      row[key] = (cols[i] ?? '').trim()
    })

    row.seq = Number(row.seq) || 0
    row.qty = Number(row.qty) || 0
    row.stock = Number(row.stock) || 0
    row.remark = ''

    return row
  })
}

export function seedDatabase(db, { force = false } = {}) {
  if (force) {
    db.exec("DELETE FROM materials")
    db.exec("DELETE FROM sqlite_sequence WHERE name='materials'")
  }

  const rows = parseSeedTsv()
  const insert = db.prepare(
    `INSERT INTO materials (${EDITABLE_COLUMNS.join(', ')}) VALUES (${EDITABLE_COLUMNS.map(() => '?').join(', ')})`
  )

  const insertMany = db.transaction(() => {
    for (const row of rows) {
      insert.run(...EDITABLE_COLUMNS.map(key => row[key]))
    }
  })

  insertMany()
  return rows.length
}

// 作为 CLI 运行时：node server/db/seed.js --force
// 注意：这里必须自己开库，绝不能 import('./index.js') ——
// index.js 静态依赖本文件的 seedDatabase，绕道会形成循环依赖并导致
// top-level await 永久挂起（表现为命令静默失败、数据未写入）。
if (process.argv[1] === __filename) {
  const { default: Database } = await import('better-sqlite3')
  const { mkdirSync } = await import('node:fs')

  const dbPath = process.env.OMPCB_DB || join(__dirname, '../../data/ompcb.db')
  mkdirSync(dirname(dbPath), { recursive: true })

  const db = new Database(dbPath)
  db.pragma('journal_mode = WAL')
  db.pragma('foreign_keys = ON')
  db.exec(readFileSync(join(__dirname, 'schema.sql'), 'utf8'))

  const force = process.argv.includes('--force')
  const inserted = seedDatabase(db, { force })
  console.log(`已导入 ${inserted} 条物料记录（force=${force}）`)
  db.close()
  process.exit(0)
}
