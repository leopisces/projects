# 计划：数据库自动备份（db-backup）

## 背景 / 问题

2026-10-26 20:56 本地 `Codes\ompcb` 目录被误删，`data/ompcb.db` + `data/ompcb.db-wal` 随之丢失，
最后靠 10-25 的卷影副本才找回。项目本身**没有任何备份机制**：`data/` 被 `.gitignore` 排除，
WAL 模式下真实数据大量驻留在 `-wal`，直接拷 `db` 单文件可能拿到残缺快照。

## 目标

1. 每次服务启动前，生成一份**一致性快照**（不是简单文件拷贝）。
2. 每日定时再备一份，保留最近 14 份，旧份自动清理。
3. 备份失败**不得阻断**服务启动。

## 非目标

- 不做异地/云同步（如需，后续接同步盘目录即可，路径可配置）。
- 不改动任何业务表结构、不动 `data/ompcb.db` 本体。

## 方案

用 better-sqlite3 自带的**在线备份 API**（`db.backup()`，对应 SQLite Online Backup API）：
在服务运行中也能拿到页级一致的单文件快照，且自动把 WAL 内容合并进去，避免 `-wal`/`-shm` 三件套不匹配。

| 文件 | 变更 | 说明 |
|------|------|------|
| `scripts/backup-db.mjs` | 新增 | 备份实现 + 保留策略，可作 CLI 也可被 import 测试 |
| `scripts/serve.ps1` | 修改 | 启动前调用备份，失败仅告警不退出 |
| `package.json` | 修改 | 增 `npm run backup` |
| `test/backup-db.test.js` | 新增 | 快照可用性 + 保留策略（跑在临时目录，不碰真实库） |
| `docs/plans/db-backup.md` | 新增 | 本文件 |

## 关键设计点

- **路径**：`OMPCB_DB`（与 `server/db/index.js` 口径一致）；备份目录 `OMPCB_BACKUP_DIR`，
  默认 `<repo>/data/backups`（在 `data/` 内，天然被 `.gitignore` 忽略，不污染仓库）。
- **命名**：`ompcb-YYYYMMDD-HHmmss.db`，字典序即时间序，清理时无需读文件内容。
- **保留**：默认 14 份，按文件名倒序保留前 N，其余删除；返回值列出被删文件，便于日志。
- **只读打开**：`readonly: true`，备份过程绝不修改源库。

## 风险

| 风险 | 处置 |
|------|------|
| 备份目录写满磁盘 | 单份 ≈ 225 KB 本体 + WAL 合并后约 4 MB，14 份 ≈ 60 MB，可接受；保留策略兜底 |
| 服务启动时备份耗时 | 备份为本地顺序拷贝，实测 < 1s；且失败不阻断启动 |
| 备份文件本身损坏 | 测试中打开备份库并 `PRAGMA quick_check` 校验 |
| 首次运行无 `data/` | 备份脚本对缺库场景给出明确错误信息，不创建空库 |

## 验证

1. `npm test` 全绿（新增 `backup-db.test.js` 覆盖快照可用性与保留策略）。
2. 手动 `npm run backup` → 输出备份路径与大小，`PRAGMA quick_check = ok`。
3. 重启服务（计划任务）→ `data/backups/` 新增一份，服务正常起。
