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
let sqliteConn = null // SQLiteConnection 实例（saveToStore/initWebStore 在它上面，不在 db 连接上）
let opening = null

/**
 * 网页端：注册 jeep-sqlite 自定义元素（Stencil 组件 + sql.js WASM），
 * 数据落在 localforage 的 IndexedDB store（jeepSqliteStore）。
 *
 * WASM 取的是 public/assets/sql-wasm.wasm（由 npm run copy-wasm 从 node_modules/sql.js/dist 拷来，
 * 已入库，不依赖 CDN）——jeep-sqlite 的 wasmPath 是个目录，它会自己拼上 sql-wasm.wasm。
 */
async function mountJeep() {
  if (document.querySelector('jeep-sqlite')) return
  const { defineCustomElements } = await import('jeep-sqlite/loader')
  defineCustomElements(window)
  await customElements.whenDefined('jeep-sqlite')

  const el = document.createElement('jeep-sqlite')
  el.style.display = 'none'
  el.setAttribute('auto-save', 'true')
  // base: './' 时用相对当前页面解析，子路径部署也能找到
  el.setAttribute('wasmPath', new URL('assets', location.href).href)
  document.body.appendChild(el)
  await customElements.whenDefined('jeep-sqlite')
}

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
CREATE TABLE IF NOT EXISTS photos (
  id TEXT PRIMARY KEY NOT NULL,
  entry_id TEXT,
  mime TEXT,
  w INTEGER,
  h INTEGER,
  ts INTEGER,
  blob BLOB
);
CREATE INDEX IF NOT EXISTS idx_photos_entry ON photos(entry_id);
`

async function open() {
  if (conn) return conn
  if (!opening) {
    opening = (async () => {
      const { CapacitorSQLite, SQLiteConnection } = await import('@capacitor-community/sqlite')
      const sqlite = new SQLiteConnection(CapacitorSQLite)
      sqliteConn = sqlite

      if (!NATIVE) {
        // 网页端必须先挂 jeep-sqlite 元素，并 initWebStore 才能持久化到 IndexedDB
        await mountJeep()
        await sqlite.initWebStore()
      }

      // native 用 1 号 schema 版本；web 的 jeep 内核不限版本号，保持同值即可
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

/** 落盘：原生端每次 executeSet 已直写文件；web 端存在内存库，必须显式 saveToStore */
async function flushWeb() {
  if (NATIVE || !sqliteConn) return
  try {
    await sqliteConn.saveToStore(DB_NAME)
  } catch (err) {
    console.warn('[成长账本] web SQLite 落盘失败', err)
  }
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
  await flushWeb()
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
    [
      { statement: 'DELETE FROM entries', values: [] },
      { statement: 'DELETE FROM kv', values: [] },
      { statement: 'DELETE FROM photos', values: [] },
    ],
    true,
  )
  await flushWeb()
  return true
}

// ---------------- 图片（存 SQLite，不占 localStorage） ----------------

/**
 * Blob → base64。
 *
 * 为什么不用 number[]：真机实测 executeSet 传纯数字数组会报
 *   `ExecuteSet: Cannot bind [255,216,255,224,...]`
 * （Android 端把数组当 bindAllArgsAsStrings 的字符串参数，绑不上）。
 * base64 字符串是插件官方支持的传输形式，写入后列类型是 TEXT，读回再解码。
 * 分块是为了绕开 String.fromCharCode.apply 的参数个数上限（大图会栈溢出）。
 */
async function blobToBase64(blob) {
  const bytes = new Uint8Array(await blob.arrayBuffer())
  let bin = ''
  const CHUNK = 0x8000
  for (let i = 0; i < bytes.length; i += CHUNK) {
    bin += String.fromCharCode.apply(null, bytes.subarray(i, i + CHUNK))
  }
  return btoa(bin)
}

/** base64 → Uint8Array（给 Blob 用） */
function base64ToBytes(b64) {
  const bin = atob(b64)
  const out = new Uint8Array(bin.length)
  for (let i = 0; i < bin.length; i += 1) out[i] = bin.charCodeAt(i)
  return out
}

/**
 * 写入一批图片。
 * @param {Array<{id:string, entryId:string, mime:string, w:number, h:number, ts:number, blob:Blob}>} items
 */
export async function savePhotosNative(items) {
  if (!items?.length) return false
  const db = await open()
  if (!db) return false
  const set = []
  for (const it of items) {
    set.push({
      statement:
        'INSERT OR REPLACE INTO photos (id, entry_id, mime, w, h, ts, blob) VALUES (?, ?, ?, ?, ?, ?, ?)',
      values: [
        String(it.id),
        String(it.entryId || ''),
        String(it.mime || 'image/jpeg'),
        Number(it.w) || 0,
        Number(it.h) || 0,
        Number(it.ts) || Date.now(),
        await blobToBase64(it.blob),
      ],
    })
  }
  await db.executeSet(set, true)
  await flushWeb()
  return true
}

/** 读单张：返回 { id, entryId, mime, w, h, blob(Blob) } 或 null */
export async function getPhotoNative(id) {
  const db = await open()
  if (!db) return null
  const rows = await db.query('SELECT entry_id, mime, w, h, blob FROM photos WHERE id = ?', [String(id)])
  const r = rows.values?.[0]
  if (!r) return null
  // 写入时存的是 base64 文本；早期/原生可能直接回 Uint8Array 或 number[]，统一成 Blob
  const raw = r.blob
  let bytes
  if (typeof raw === 'string') bytes = base64ToBytes(raw)
  else if (raw instanceof Uint8Array) bytes = raw
  else if (Array.isArray(raw)) bytes = new Uint8Array(raw)
  else bytes = new Uint8Array(0)
  return {
    id: String(id),
    entryId: r.entry_id || '',
    mime: r.mime || 'image/jpeg',
    w: Number(r.w) || 0,
    h: Number(r.h) || 0,
    blob: new Blob([bytes], { type: r.mime || 'image/jpeg' }),
  }
}

/** 某条记录的全部图片（按 ts 升序） */
export async function photosOfEntryNative(entryId) {
  const db = await open()
  if (!db) return []
  const rows = await db.query(
    'SELECT id FROM photos WHERE entry_id = ? ORDER BY ts ASC, id ASC',
    [String(entryId)],
  )
  return (rows.values || []).map((r) => r.id)
}

export async function deletePhotosNative(ids) {
  if (!ids?.length) return false
  const db = await open()
  if (!db) return false
  await db.executeSet(
    ids.map((id) => ({ statement: 'DELETE FROM photos WHERE id = ?', values: [String(id)] })),
    true,
  )
  await flushWeb()
  return true
}

export const nativeReady = true
