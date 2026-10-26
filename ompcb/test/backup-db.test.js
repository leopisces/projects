// test/backup-db.test.js — 备份脚本
//
// 全部跑在 %TEMP% 下的临时库，绝不碰 data/ompcb.db。
// 断言口径遵循 test/README.md：不依赖种子数据的固定条数。
import test from 'node:test'
import assert from 'node:assert/strict'
import { existsSync, mkdtempSync, readdirSync, rmSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import Database from 'better-sqlite3'
import {
  backupDatabase,
  backupFileName,
  pruneBackups,
  DEFAULT_KEEP
} from '../scripts/backup-db.mjs'

function makeTempDir() {
  return mkdtempSync(join(tmpdir(), 'ompcb-backup-'))
}

function makeSourceDb(dir) {
  const dbPath = join(dir, 'ompcb.db')
  const db = new Database(dbPath)
  db.pragma('journal_mode = WAL')
  db.exec('CREATE TABLE t (id INTEGER PRIMARY KEY, name TEXT NOT NULL)')
  db.prepare('INSERT INTO t (name) VALUES (?)').run('alpha')
  db.prepare('INSERT INTO t (name) VALUES (?)').run('beta')
  db.close()
  return dbPath
}

test('备份文件名：可排序且格式固定', async (t) => {
  await t.test('时间戳字段补零', () => {
    const name = backupFileName(new Date(2026, 0, 5, 7, 8, 9))
    assert.equal(name, 'ompcb-20260105-070809.db')
  })

  await t.test('同一天内字典序等于时间序', () => {
    const a = backupFileName(new Date(2026, 0, 5, 7, 8, 9))
    const b = backupFileName(new Date(2026, 0, 5, 21, 8, 9))
    assert.ok(a < b)
  })
})

test('备份：生成的快照能打开且数据完整', async (t) => {
  const dir = makeTempDir()
  t.after(() => rmSync(dir, { recursive: true, force: true }))

  const dbPath = makeSourceDb(dir)
  const backupDir = join(dir, 'backups')

  await t.test('快照文件落在备份目录', async () => {
    const result = await backupDatabase({ dbPath, backupDir })
    assert.ok(existsSync(result.path))
    assert.ok(result.size > 0)
    assert.equal(dirnameOf(result.path), backupDir)
  })

  await t.test('快照内容与源库一致（WAL 已合并）', () => {
    const files = readdirSync(backupDir).filter((n) => n.endsWith('.db'))
    assert.equal(files.length, 1)
    const copy = new Database(join(backupDir, files[0]), { readonly: true })
    try {
      assert.equal(copy.pragma('quick_check', { simple: true }), 'ok')
      const rows = copy.prepare('SELECT name FROM t ORDER BY id').all()
      assert.deepEqual(rows.map((r) => r.name), ['alpha', 'beta'])
    } finally {
      copy.close()
    }
  })

  await t.test('源库不存在时给出明确错误', async () => {
    await assert.rejects(
      () => backupDatabase({ dbPath: join(dir, 'nope.db'), backupDir }),
      /数据库不存在/
    )
  })
})

test('备份保留策略：只留最近 keep 份，且不动外来文件', async (t) => {
  const dir = makeTempDir()
  t.after(() => rmSync(dir, { recursive: true, force: true }))

  const dbPath = makeSourceDb(dir)
  const backupDir = join(dir, 'backups')

  await t.test('默认保留份数为 14', () => {
    assert.equal(DEFAULT_KEEP, 14)
  })

  await t.test('连续 5 次备份、keep=3 时只剩最新 3 份', async () => {
    const stamp = (minute) => new Date(2026, 9, 26, 12, minute, 0)
    for (const minute of [0, 1, 2, 3, 4]) {
      await backupDatabase({ dbPath, backupDir, keep: 3, now: stamp(minute) })
    }
    const files = readdirSync(backupDir).filter((n) => n.startsWith('ompcb-')).sort()
    assert.deepEqual(files, [
      'ompcb-20261026-120200.db',
      'ompcb-20261026-120300.db',
      'ompcb-20261026-120400.db'
    ])
  })

  await t.test('清理不碰不符合命名的文件', () => {
    const keepFile = join(backupDir, 'manual-copy.db')
    const db = new Database(keepFile)
    db.exec('CREATE TABLE x (id INTEGER)')
    db.close()
    pruneBackups(backupDir, 1)
    assert.ok(existsSync(keepFile))
    assert.equal(readdirSync(backupDir).filter((n) => n.startsWith('ompcb-')).length, 1)
  })

  await t.test('keep 至少保留 1 份（不会被 0 或负数清空）', async () => {
    await backupDatabase({ dbPath, backupDir, keep: 0, now: new Date(2026, 9, 27, 8, 0, 0) })
    const files = readdirSync(backupDir).filter((n) => BACKUP_NAME_RE.test(n))
    assert.equal(files.length, 1)
  })
})

const BACKUP_NAME_RE = /^ompcb-\d{8}-\d{6}\.db$/

function dirnameOf(p) {
  return p.slice(0, Math.max(p.lastIndexOf('\\'), p.lastIndexOf('/')))
}
