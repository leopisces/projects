/**
 * 原生持久化层（APK 专用）：SQLite。
 *
 * 为什么不用 WebView 的 localStorage：Android 清缓存/回收时会把 WebView 存储一起端掉，
 * 实测过「记完关掉再进就没了」。SQLite 落在 app 私有目录的数据库文件里，随 app 数据一起活。
 *
 * 网页端不会走到这里（Capacitor.isNativePlatform() 为假时全部返回 null/false），
 * 插件也是动态 import，不进 web 包体。
 */
import { Capacitor } from '@capacitor/core'

const NATIVE = Capacitor.isNativePlatform()
const DB_NAME = 'growth'

let conn = null
let opening = null

const SCHEMA = `
CREATE TABLE IF NOT EXISTS kv (key TEXT PRIMARY KEY NOT NULL, value TEXT);
CREATE TABLE IF NOT EXISTS entries (
  id TEXT PRIMARY KEY NOT NULL,
  ts INTEGER,
  day TEXT,
  dimension TEXT,
  data TEXT
);
CREATE INDEX IF NOT EXISTS idx_entries_ts ON entries(ts);
`

async function open() {
  if (!NATIVE) return null
  if (conn) return conn
  if (!opening) {
    opening = (async () => {
      const { CapacitorSQLite, SQLiteConnection } = await import('@capacitor-community/sqlite')
      const sqlite = new SQLiteConnection(CapacitorSQLite)
      const db = await sqlite.createConnection(DB_NAME, false, 'no-encryption', 1, false)
      await db.open()
      await db.execute(SCHEMA)
      conn = db
      return db
    })().catch((err) => {
      console.warn('[成长账本] SQLite 打开失败，回退到 localStorage', err)
      opening = null
      return null
    })
  }
  return opening
}

/** 原子写入：先清 entries 再整表灌入（几十~几百行，开销可忽略，省掉 diff 逻辑） */
export async function saveNative(snapshot) {
  const db = await open()
  if (!db) return false
  const set = [
    { statement: 'DELETE FROM entries', values: [] },
    { statement: "INSERT OR REPLACE INTO kv (key, value) VALUES ('settings', ?)", values: [JSON.stringify(snapshot.settings || {})] },
  ]
  for (const e of snapshot.entries || []) {
    set.push({
      statement: 'INSERT OR REPLACE INTO entries (id, ts, day, dimension, data) VALUES (?, ?, ?, ?, ?)',
      values: [String(e.id), Number(e.ts) || 0, String(e.day || ''), String(e.dimension || ''), JSON.stringify(e)],
    })
  }
  await db.executeSet(set, true)
  return true
}

/** 读全量；库还空时返回 entries: []，由调用方决定是否用现有数据播种 */
export async function loadNative() {
  const db = await open()
  if (!db) return null
  const rows = await db.query('SELECT data FROM entries ORDER BY ts ASC, id ASC')
  const settingsRow = await db.query("SELECT value FROM kv WHERE key = 'settings'")
  const entries = (rows.values || [])
    .map((r) => {
      try {
        return JSON.parse(r.data)
      } catch {
        return null
      }
    })
    .filter(Boolean)
  const rawSettings = settingsRow.values?.[0]?.value
  let settings = null
  if (rawSettings) {
    try {
      settings = JSON.parse(rawSettings)
    } catch {
      settings = null
    }
  }
  return { entries, settings }
}

export async function clearNative() {
  const db = await open()
  if (!db) return false
  await db.executeSet(
    [{ statement: 'DELETE FROM entries', values: [] }, { statement: 'DELETE FROM kv', values: [] }],
    true,
  )
  return true
}

export const nativeReady = NATIVE
