// scripts/backup-db.mjs — 数据库一致性备份
//
// 为什么不用「直接拷 data/ompcb.db」：
// 库跑在 WAL 模式，真实数据大量驻留在 ompcb.db-wal 里。单拷 .db 会得到
// 一个落后的快照，拷三件套又可能拿到页级不一致的组合。这里用 better-sqlite3
// 的在线备份 API（db.backup()，对应 SQLite Online Backup API），由 SQLite
// 自己保证页级一致，并把 WAL 内容合并进单个目标文件。
//
// 备份目录默认在 data/backups（data/ 已被 .gitignore 排除），可用
// OMPCB_BACKUP_DIR 覆盖；源库路径与 server/db/index.js 同口径，用 OMPCB_DB。
//
// CLI：  npm run backup        （等价 node scripts/backup-db.mjs）
// 保留：  默认最近 14 份，按文件名（时间戳）倒序保留，其余删除。
import { existsSync, mkdirSync, readdirSync, rmSync, statSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath, pathToFileURL } from 'node:url'
import Database from 'better-sqlite3'

const root = join(dirname(fileURLToPath(import.meta.url)), '..')

export const DEFAULT_KEEP = 14
const BACKUP_PATTERN = /^ompcb-\d{8}-\d{6}\.db$/

/** 源库路径：与 server/db/index.js 保持一致 */
export function resolveDbPath() {
  return process.env.OMPCB_DB || join(root, 'data', 'ompcb.db')
}

/** 备份目录：默认 data/backups（随 data/ 一起被 gitignore） */
export function resolveBackupDir() {
  return process.env.OMPCB_BACKUP_DIR || join(root, 'data', 'backups')
}

/** ompcb-YYYYMMDD-HHmmss.db，字典序即时间序，清理时不必读文件内容 */
export function backupFileName(now = new Date()) {
  const p = (n) => String(n).padStart(2, '0')
  const stamp =
    now.getFullYear().toString() +
    p(now.getMonth() + 1) +
    p(now.getDate()) +
    '-' +
    p(now.getHours()) +
    p(now.getMinutes()) +
    p(now.getSeconds())
  return 'ompcb-' + stamp + '.db'
}

/**
 * 只保留最近 keep 份（按文件名倒序）。返回被删除的文件名列表。
 * 只处理符合 BACKUP_PATTERN 的文件，用户手工丢进目录的东西不动。
 */
export function pruneBackups(backupDir, keep = DEFAULT_KEEP) {
  if (!existsSync(backupDir)) return []
  const files = readdirSync(backupDir)
    .filter((name) => BACKUP_PATTERN.test(name))
    .sort()
    .reverse()
  const doomed = files.slice(Math.max(keep, 1))
  for (const name of doomed) {
    rmSync(join(backupDir, name), { force: true })
    // 校验备份时会就地生成 -wal/-shm，别把它们留成孤儿文件
    for (const suffix of ['-wal', '-shm']) {
      rmSync(join(backupDir, name + suffix), { force: true })
    }
  }
  return doomed
}

/**
 * 生成一份备份并校验可打开。
 * @returns {Promise<{ path: string, size: number, removed: string[] }>}
 */
export async function backupDatabase(options = {}) {
  const dbPath = options.dbPath || resolveDbPath()
  const backupDir = options.backupDir || resolveBackupDir()
  const keep = options.keep == null ? DEFAULT_KEEP : options.keep
  const now = options.now || new Date()

  if (!existsSync(dbPath)) {
    throw new Error('数据库不存在：' + dbPath + '（先启动一次服务让 schema 建库）')
  }
  mkdirSync(backupDir, { recursive: true })

  const dest = join(backupDir, backupFileName(now))
  // 只读打开源库：备份过程绝不修改数据
  const db = new Database(dbPath, { readonly: true, fileMustExist: true })
  try {
    await db.backup(dest)
  } finally {
    db.close()
  }

  // 校验：备份必须能被 SQLite 打开且页结构完好，坏文件不能算备份成功
  const check = new Database(dest, { readonly: true, fileMustExist: true })
  try {
    const result = check.pragma('quick_check', { simple: true })
    if (result !== 'ok') throw new Error('备份校验失败：' + result)
  } finally {
    check.close()
  }
  // 以只读方式打开 WAL 库仍会创建 -shm/-wal；备份产物只应留单个 .db 文件
  for (const suffix of ['-wal', '-shm']) {
    rmSync(dest + suffix, { force: true })
  }

  const removed = pruneBackups(backupDir, keep)
  return { path: dest, size: statSync(dest).size, removed }
}

const invokedDirectly =
  process.argv[1] && pathToFileURL(process.argv[1]).href === import.meta.url

if (invokedDirectly) {
  try {
    const result = await backupDatabase()
    console.log('[backup] 已备份: ' + result.path + ' (' + result.size + ' bytes)')
    if (result.removed.length) console.log('[backup] 清理旧备份: ' + result.removed.join(', '))
  } catch (err) {
    console.error('[backup] 失败: ' + err.message)
    process.exitCode = 1
  }
}
