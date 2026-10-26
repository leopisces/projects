// scripts/backup-db.mjs — 数据库一致性备份（多目标：本地 + 异地副本）
//
// 为什么不用「直接拷 data/ompcb.db」：
// 库跑在 WAL 模式，真实数据大量驻留在 ompcb.db-wal 里。单拷 .db 会得到
// 一个落后的快照，拷三件套又可能拿到页级不一致的组合。这里用 better-sqlite3
// 的在线备份 API（db.backup()，对应 SQLite Online Backup API），由 SQLite
// 自己保证页级一致，并把 WAL 内容合并进单个目标文件。
//
// 多目标策略：快照只生成一次（落到 %TEMP%），校验通过后再复制到各个目标。
// 这样三份内容天然一致，也不会因为同步盘慢而拉长源库被读取的时间窗。
// 任一目标失败只影响它自己：本地成功即整体成功（异地只是冗余）。
//
// 目标配置：
//   OMPCB_BACKUP_DIR      本地主副本目录（默认 <repo>/data/backups）
//   OMPCB_BACKUP_KEEP     本地保留份数（默认 14）
//   OMPCB_BACKUP_MIRRORS  异地副本，格式 "路径=份数;路径=份数"
//                         默认 "D:\ompcb-backup=30;D:\BaiduSyncdisk\ompcb-backup=30"
//
// CLI：
//   npm run backup          生成备份（exit 0 = 本地成功）
//   npm run backup:status   查看各目标最近一次备份时间 / 份数 / 占用 / 冲突副本
import {
  copyFileSync,
  existsSync,
  mkdirSync,
  mkdtempSync,
  readdirSync,
  rmSync,
  statSync
} from 'node:fs'
import { tmpdir } from 'node:os'
import { dirname, join, parse } from 'node:path'
import { fileURLToPath, pathToFileURL } from 'node:url'
import Database from 'better-sqlite3'

const root = join(dirname(fileURLToPath(import.meta.url)), '..')

export const DEFAULT_KEEP = 14
export const DEFAULT_MIRROR_KEEP = 30
export const DEFAULT_MIRRORS = 'D:\\ompcb-backup=30;D:\\BaiduSyncdisk\\ompcb-backup=30'

const BACKUP_PATTERN = /^ompcb-(\d{4})(\d{2})(\d{2})-(\d{2})(\d{2})(\d{2})\.db$/
// 同步盘客户端可能生成 "xxx.db (1)" 这类冲突副本：不删，只统计提示
const CONFLICT_PATTERN = /^ompcb-\d{8}-\d{6}\.db \(\d+\)$/

/** 源库路径：与 server/db/index.js 保持一致 */
export function resolveDbPath() {
  return process.env.OMPCB_DB || join(root, 'data', 'ompcb.db')
}

/** 本地主副本目录：默认 data/backups（随 data/ 一起被 gitignore） */
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

/** 从文件名还原备份时间（不信文件 mtime：同步盘会改它） */
function backupTimeFromName(name) {
  const m = BACKUP_PATTERN.exec(name)
  if (!m) return null
  return `${m[1]}-${m[2]}-${m[3]} ${m[4]}:${m[5]}:${m[6]}`
}

/**
 * 解析 "路径=份数;路径" 形式的异地目标列表。
 * 未配置（空串）时退回默认双写目标；设为 "none" 表示关闭异地副本。
 * 份数写 0/负数 → 归一到 1（与 pruneBackups 的下限一致）；写非数字 → 退回默认。
 */
export function resolveMirrors(spec) {
  const raw = spec == null ? process.env.OMPCB_BACKUP_MIRRORS : spec
  const text = String(raw == null ? '' : raw).trim()
  if (!text) return resolveMirrors(DEFAULT_MIRRORS)
  if (text.toLowerCase() === 'none') return []
  return text
    .split(';')
    .map((item) => item.trim())
    .filter(Boolean)
    .map((item) => {
      const at = item.lastIndexOf('=')
      const rawDir = at > 1 ? item.slice(0, at).trim() : item
      const rawKeep = at > 1 ? Number(item.slice(at + 1).trim()) : NaN
      const keep = Number.isFinite(rawKeep) ? Math.max(1, Math.floor(rawKeep)) : DEFAULT_MIRROR_KEEP
      return { label: mirrorLabel(rawDir), dir: rawDir, keep }
    })
    .filter((m) => m.dir)
}

function mirrorLabel(dir) {
  // 用完整路径做 label：两个镜像可能同名目录（D:\ompcb-backup 与 D:\BaiduSyncdisk\ompcb-backup）
  return dir.replace(/[\\/]+$/, '')
}

/** 解析本地目标（可用 OMPCB_BACKUP_KEEP 覆盖份数） */
export function resolveLocalTarget() {
  const rawKeep = Number(process.env.OMPCB_BACKUP_KEEP)
  const keep = Number.isFinite(rawKeep) ? Math.max(1, Math.floor(rawKeep)) : DEFAULT_KEEP
  return { label: 'local', dir: resolveBackupDir(), keep }
}

/** 全部目标：本地 + 异地，按解析后的路径去重（避免同目录重复写） */
export function resolveTargets() {
  const targets = [resolveLocalTarget(), ...resolveMirrors()]
  const seen = new Set()
  return targets.filter((t) => {
    const key = t.dir.replace(/[\\/]+$/, '').toLowerCase()
    if (seen.has(key)) return false
    seen.add(key)
    return true
  })
}

/**
 * 只保留最近 keep 份（按文件名倒序）。返回被删除的文件名列表。
 * 只处理符合 BACKUP_PATTERN 的文件：同步盘冲突副本、用户手工文件一律不动。
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

/** 盘符是否在线（D:\ 不存在时直接跳过，而不是报错） */
function driveAvailable(dir) {
  const rootPath = parse(dir).root
  return rootPath ? existsSync(rootPath) : true
}

/** 生成一次快照（临时文件），校验通过后返回路径 */
async function snapshotToTemp(dbPath, fileName) {
  const tmpDir = mkdtempSync(join(tmpdir(), 'ompcb-snap-'))
  const tmpFile = join(tmpDir, fileName)
  const src = new Database(dbPath, { readonly: true, fileMustExist: true })
  try {
    await src.backup(tmpFile)
  } finally {
    src.close()
  }

  // 校验：备份必须能被 SQLite 打开且页结构完好，坏文件不能算备份成功
  const check = new Database(tmpFile, { readonly: true, fileMustExist: true })
  try {
    const result = check.pragma('quick_check', { simple: true })
    if (result !== 'ok') throw new Error('备份校验失败：' + result)
  } finally {
    check.close()
  }
  // 以只读方式打开 WAL 库仍会创建 -shm/-wal；快照只应留单个 .db
  for (const suffix of ['-wal', '-shm']) rmSync(tmpFile + suffix, { force: true })
  return tmpFile
}

/** 把一个目标交付到位：复制 + 独立轮转，失败不抛出 */
function deliverTarget({ tmpFile, fileName, target }) {
  const base = { label: target.label, dir: target.dir, keep: target.keep, removed: [] }

  if (!driveAvailable(target.dir)) {
    return { ...base, status: 'skipped', reason: '盘未挂载' }
  }
  try {
    mkdirSync(target.dir, { recursive: true })
  } catch (err) {
    return { ...base, status: 'failed', reason: '目录不可用: ' + err.message }
  }

  const dest = join(target.dir, fileName)
  if (existsSync(dest)) {
    // 同一秒内重复触发：同名同内容，跳过比覆盖安全（避免两次不同内容互相盖掉）
    return { ...base, status: 'skipped', reason: '同名已存在' }
  }

  let lastError = null
  for (let attempt = 0; attempt < 2; attempt++) {
    try {
      copyFileSync(tmpFile, dest)
      lastError = null
      break
    } catch (err) {
      lastError = err
    }
  }
  if (lastError) {
    return { ...base, status: 'failed', reason: '复制失败: ' + lastError.message }
  }

  let removed = []
  try {
    removed = pruneBackups(target.dir, target.keep)
  } catch (err) {
    // 轮转失败不该让这份备份变成失败（文件已经落地了）
    removed = []
    return { ...base, status: 'ok', removed, warning: '轮转失败: ' + err.message }
  }
  return { ...base, status: 'ok', removed }
}

/**
 * 生成备份并分发到所有目标。
 * @returns {Promise<{ok: boolean, file: string, size: number, path: string|null, targets: object[]}>}
 */
export async function backupDatabase(options = {}) {
  const dbPath = options.dbPath || resolveDbPath()
  const now = options.now || new Date()

  // 兼容旧调用：显式 backupDir/keep 时只写这一个目标
  const targets =
    options.targets ||
    (options.backupDir
      ? [{ label: 'local', dir: options.backupDir, keep: options.keep == null ? DEFAULT_KEEP : options.keep }]
      : resolveTargets())

  if (!existsSync(dbPath)) {
    throw new Error('数据库不存在：' + dbPath + '（先启动一次服务让 schema 建库）')
  }

  const file = backupFileName(now)
  const tmpFile = await snapshotToTemp(dbPath, file)
  const size = statSync(tmpFile).size
  let results = []
  try {
    results = targets.map((target) => deliverTarget({ tmpFile, fileName: file, target }))
  } finally {
    rmSync(dirname(tmpFile), { recursive: true, force: true })
  }

  const local = results.find((r) => r.label === 'local')
  // 本地成功即成功；本地不存在（未配置）时任一目标成功即成功
  const ok = local ? local.status === 'ok' : results.some((r) => r.status === 'ok')
  const localDir = local && local.status === 'ok' ? join(local.dir, file) : null

  return { ok, file, size, path: localDir, targets: results }
}

/** 逐目标统计：份数、最近备份时间、占用、冲突副本数 */
export function listBackups(targets = resolveTargets()) {
  return targets.map((target) => {
    const row = {
      label: target.label,
      dir: target.dir,
      keep: target.keep,
      exists: existsSync(target.dir),
      count: 0,
      newest: null,
      sizeBytes: 0,
      conflicts: 0
    }
    if (!row.exists) return row
    let names = []
    try {
      names = readdirSync(target.dir)
    } catch {
      return row
    }
    const backups = names.filter((n) => BACKUP_PATTERN.test(n)).sort()
    row.count = backups.length
    row.newest = backups.length ? backupTimeFromName(backups[backups.length - 1]) : null
    row.sizeBytes = backups.reduce((sum, n) => {
      try {
        return sum + statSync(join(target.dir, n)).size
      } catch {
        return sum
      }
    }, 0)
    row.conflicts = names.filter((n) => CONFLICT_PATTERN.test(n)).length
    return row
  })
}

function formatBytes(bytes) {
  if (bytes >= 1024 * 1024) return (bytes / 1024 / 1024).toFixed(2) + ' MB'
  return Math.round(bytes / 1024) + ' KB'
}

/** 状态输出（纯函数，便于测试） */
export function formatStatus(rows) {
  const lines = []
  for (const row of rows) {
    if (!row.exists) {
      lines.push(`[${row.label}] ${row.dir} — 目录不存在（盘未挂载或未创建）`)
      continue
    }
    const newest = row.newest || '（无备份）'
    let line = `[${row.label}] ${row.dir} — ${row.count} 份，最近 ${newest}，占用 ${formatBytes(row.sizeBytes)}，保留 ${row.keep} 份`
    if (row.conflicts > 0) line += `；另发现 ${row.conflicts} 个同步盘冲突副本（未纳入轮转）`
    lines.push(line)
  }
  return lines
}

function describeTargets(result) {
  return result.targets.map((t) => {
    if (t.status === 'ok') {
      const removed = t.removed && t.removed.length ? `（清理 ${t.removed.length} 份旧备份）` : ''
      return `  ok      ${t.label}  ${join(t.dir, result.file)}${removed}`
    }
    return `  ${t.status.padEnd(7)} ${t.label}  ${t.dir} — ${t.reason}`
  })
}

const invokedDirectly =
  process.argv[1] && pathToFileURL(process.argv[1]).href === import.meta.url

if (invokedDirectly) {
  if (process.argv.includes('--status')) {
    console.log(formatStatus(listBackups()).join('\n'))
  } else {
    try {
      const result = await backupDatabase()
      console.log('[backup] 快照: ' + result.file + ' (' + formatBytes(result.size) + ')')
      console.log(describeTargets(result).join('\n'))
      const problems = result.targets.filter((t) => t.status !== 'ok')
      for (const t of problems) console.warn('[backup] 警告: ' + t.label + ' ' + t.status + ' — ' + t.reason)
      if (!result.ok) {
        console.error('[backup] 失败：没有任何目标写入成功')
        process.exitCode = 1
      }
    } catch (err) {
      console.error('[backup] 失败: ' + err.message)
      process.exitCode = 1
    }
  }
}
