// test/backup-db.test.js — 备份脚本（多目标版）
//
// 全部跑在 %TEMP% 下的临时库，绝不碰 data/ompcb.db。
// 断言口径遵循 test/README.md：不依赖种子数据的固定条数。
import test from 'node:test'
import assert from 'node:assert/strict'
import {
  existsSync,
  mkdirSync,
  mkdtempSync,
  readdirSync,
  rmSync,
  writeFileSync
} from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import Database from 'better-sqlite3'
import {
  backupDatabase,
  backupFileName,
  pruneBackups,
  resolveMirrors,
  formatStatus,
  listBackups,
  DEFAULT_KEEP,
  DEFAULT_MIRROR_KEEP
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
    assert.equal(backupFileName(new Date(2026, 0, 5, 7, 8, 9)), 'ompcb-20260105-070809.db')
  })

  await t.test('同一天内字典序等于时间序', () => {
    const a = backupFileName(new Date(2026, 0, 5, 7, 8, 9))
    const b = backupFileName(new Date(2026, 0, 5, 21, 8, 9))
    assert.ok(a < b)
  })
})

test('镜像目标解析：路径=份数;路径', async (t) => {
  await t.test('未配置时给默认双写目标', () => {
    const spec = resolveMirrors('')
    assert.ok(spec.length >= 1)
    for (const m of spec) {
      assert.equal(typeof m.dir, 'string')
      assert.equal(m.keep, DEFAULT_MIRROR_KEEP)
    }
  })

  await t.test('显式份数与默认份数混用', () => {
    const list = resolveMirrors('D:\\a=30;E:\\b')
    assert.deepEqual(
      list.map((m) => [m.dir, m.keep]),
      [
        ['D:\\a', 30],
        ['E:\\b', DEFAULT_MIRROR_KEEP]
      ]
    )
  })

  await t.test('空段与非法份数被忽略/回退', () => {
    const list = resolveMirrors('D:\\a=abc;;E:\\b=0')
    assert.deepEqual(
      list.map((m) => [m.dir, m.keep]),
      [
        ['D:\\a', DEFAULT_MIRROR_KEEP],
        ['E:\\b', 1]
      ]
    )
  })
})

test('备份：生成的快照能打开且数据完整', async (t) => {
  const dir = makeTempDir()
  t.after(() => rmSync(dir, { recursive: true, force: true }))

  const dbPath = makeSourceDb(dir)
  const backupDir = join(dir, 'backups')

  await t.test('快照文件落在备份目录且校验通过', async () => {
    const result = await backupDatabase({ dbPath, backupDir })
    assert.equal(result.ok, true)
    assert.ok(existsSync(result.path))
    assert.ok(result.size > 0)
    assert.equal(result.targets.length, 1)
    assert.equal(result.targets[0].status, 'ok')
  })

  await t.test('快照内容与源库一致（WAL 已合并）', () => {
    const files = readdirSync(backupDir).filter((n) => n.endsWith('.db'))
    assert.equal(files.length, 1)
    const copy = new Database(join(backupDir, files[0]), { readonly: true })
    try {
      assert.equal(copy.pragma('quick_check', { simple: true }), 'ok')
      assert.deepEqual(
        copy.prepare('SELECT name FROM t ORDER BY id').all().map((r) => r.name),
        ['alpha', 'beta']
      )
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

test('多目标：一次快照写三处，内容一致', async (t) => {
  const dir = makeTempDir()
  t.after(() => rmSync(dir, { recursive: true, force: true }))

  const dbPath = makeSourceDb(dir)
  const targets = [
    { label: 'local', dir: join(dir, 'local'), keep: 2 },
    { label: 'mirror-a', dir: join(dir, 'mirror-a'), keep: 1 },
    { label: 'mirror-b', dir: join(dir, 'mirror-b'), keep: 1 }
  ]

  await t.test('三个目标都落地同名文件且大小一致', async () => {
    const result = await backupDatabase({ dbPath, targets })
    assert.equal(result.ok, true)
    assert.deepEqual(result.targets.map((r) => r.status), ['ok', 'ok', 'ok'])
    const sizes = targets.map((tg) => {
      const files = readdirSync(tg.dir).filter((n) => n.endsWith('.db'))
      assert.deepEqual(files, [result.file])
      return files.length && readdirSync(tg.dir).length
    })
    assert.deepEqual(sizes, [1, 1, 1])
  })

  await t.test('临时快照不残留在目标目录之外的地方（目标目录里只有 .db）', () => {
    for (const tg of targets) {
      const names = readdirSync(tg.dir)
      assert.ok(names.every((n) => /^ompcb-\d{8}-\d{6}\.db$/.test(n)), 'unexpected files: ' + names)
    }
  })
})

test('多目标：失败隔离与跳过口径', async (t) => {
  const dir = makeTempDir()
  t.after(() => rmSync(dir, { recursive: true, force: true }))
  const dbPath = makeSourceDb(dir)

  await t.test('盘符不存在 → skipped，其余 ok，整体 ok（本地成功口径）', async () => {
    const targets = [
      { label: 'local', dir: join(dir, 'local'), keep: 3 },
      { label: 'ghost', dir: 'Z:\\definitely-missing-ompcb', keep: 3 }
    ]
    const result = await backupDatabase({ dbPath, targets })
    assert.equal(result.ok, true)
    assert.equal(result.targets[0].status, 'ok')
    assert.equal(result.targets[1].status, 'skipped')
    assert.match(result.targets[1].reason, /盘|不存在|missing/)
  })

  await t.test('目录无法创建（父路径是文件）→ failed，但不影响本地', async () => {
    const blocker = join(dir, 'blocker')
    writeFileSync(blocker, 'not a dir')
    const targets = [
      { label: 'local', dir: join(dir, 'local2'), keep: 3 },
      { label: 'broken', dir: join(blocker, 'sub'), keep: 3 }
    ]
    const result = await backupDatabase({ dbPath, targets })
    assert.equal(result.ok, true)
    assert.equal(result.targets[0].status, 'ok')
    assert.equal(result.targets[1].status, 'failed')
  })

  await t.test('本地也失败时整体失败', async () => {
    const blocker = join(dir, 'blocker2')
    writeFileSync(blocker, 'x')
    const result = await backupDatabase({
      dbPath,
      targets: [{ label: 'local', dir: join(blocker, 'sub'), keep: 3 }]
    })
    assert.equal(result.ok, false)
    assert.equal(result.targets[0].status, 'failed')
  })
})

test('多目标：各自独立轮转', async (t) => {
  const dir = makeTempDir()
  t.after(() => rmSync(dir, { recursive: true, force: true }))
  const dbPath = makeSourceDb(dir)
  const local = join(dir, 'local')
  const mirror = join(dir, 'mirror')
  const targets = [
    { label: 'local', dir: local, keep: 2 },
    { label: 'mirror', dir: mirror, keep: 1 }
  ]

  await t.test('本地留 2 份、异地留 1 份', async () => {
    for (const minute of [0, 1, 2]) {
      const now = new Date(2026, 9, 26, 12, minute, 0)
      await backupDatabase({ dbPath, targets, now })
    }
    const localFiles = readdirSync(local).filter((n) => n.startsWith('ompcb-')).sort()
    const mirrorFiles = readdirSync(mirror).filter((n) => n.startsWith('ompcb-')).sort()
    assert.deepEqual(localFiles, ['ompcb-20261026-120100.db', 'ompcb-20261026-120200.db'])
    assert.deepEqual(mirrorFiles, ['ompcb-20261026-120200.db'])
  })

  await t.test('同名已存在时跳过而不是覆盖', async () => {
    const now = new Date(2026, 9, 26, 12, 5, 0)
    await backupDatabase({ dbPath, targets, now })
    const second = await backupDatabase({ dbPath, targets, now })
    assert.equal(second.targets[0].status, 'skipped')
    assert.match(second.targets[0].reason, /同名/)
  })
})

test('状态输出：份数/最近时间/占用/冲突副本', async (t) => {
  const dir = makeTempDir()
  t.after(() => rmSync(dir, { recursive: true, force: true }))
  const dbPath = makeSourceDb(dir)
  const local = join(dir, 'status-local')
  const targets = [{ label: 'local', dir: local, keep: 5 }]
  await backupDatabase({ dbPath, targets, now: new Date(2026, 9, 26, 13, 0, 0) })

  await t.test('统计份数与最近时间（来自文件名，不受同步盘 mtime 影响）', () => {
    const rows = listBackups(targets)
    assert.equal(rows.length, 1)
    assert.equal(rows[0].count, 1)
    assert.equal(rows[0].newest, '2026-10-26 13:00:00')
    assert.ok(rows[0].sizeBytes > 0)
  })

  await t.test('同步盘冲突副本不参与轮转，但会计数与提示', () => {
    const conflict = join(local, 'ompcb-20261026-130000.db (1)')
    writeFileSync(conflict, 'conflict-copy')
    mkdirSync(local, { recursive: true })
    const rows = listBackups(targets)
    assert.equal(rows[0].count, 1, '冲突副本不应算作备份份数')
    assert.equal(rows[0].conflicts, 1)
    pruneBackups(local, 1)
    assert.ok(existsSync(conflict), '冲突副本不能被自动删除')
  })

  await t.test('formatStatus 输出包含目标、份数、时间', () => {
    const text = formatStatus(listBackups(targets)).join('\n')
    assert.match(text, /local/)
    assert.match(text, /1 份|份数/)
    assert.match(text, /2026-10-26 13:00:00/)
  })
})

test('保留策略：只留最近 keep 份，且不动外来文件', async (t) => {
  const dir = makeTempDir()
  t.after(() => rmSync(dir, { recursive: true, force: true }))
  const dbPath = makeSourceDb(dir)
  const backupDir = join(dir, 'backups')

  await t.test('默认保留份数符合约定', () => {
    assert.equal(DEFAULT_KEEP, 14)
    assert.equal(DEFAULT_MIRROR_KEEP, 30)
  })

  await t.test('连续 5 次备份、keep=3 时只剩最新 3 份', async () => {
    for (const minute of [0, 1, 2, 3, 4]) {
      await backupDatabase({
        dbPath,
        backupDir,
        keep: 3,
        now: new Date(2026, 9, 26, 12, minute, 0)
      })
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
    const files = readdirSync(backupDir).filter((n) => /^ompcb-\d{8}-\d{6}\.db$/.test(n))
    assert.equal(files.length, 1)
  })
})
