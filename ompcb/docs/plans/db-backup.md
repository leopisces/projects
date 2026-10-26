# Plan: 数据库自动备份（db-backup）

> 源自 spec.md: `docs/specs/db-backup.md`
日期: 2026-10-26

> 流程偏差留痕：本计划初稿写在实现之前，但 `intent.md` / `spec.md` 是事后补齐的
> （事故恢复驱动的改动）。缺失阶段已补，见 `docs/intent/db-backup.md`、`docs/specs/db-backup.md`。

## Files that change

- 新增 `scripts/backup-db.mjs` — 备份实现（CLI + 可 import）
- 新增 `scripts/install-backup-task.ps1` — 注册/卸载每日备份计划任务
- 新增 `test/backup-db.test.js` — 12 个用例
- 新增 `docs/intent/db-backup.md`、`docs/specs/db-backup.md`、`docs/plans/db-backup.md`
- 修改 `scripts/serve.ps1` — 启动前备份，失败不阻断
- 修改 `package.json` — `npm run backup`
- 修改 `AGENTS.md` — 命令表 + 「不能直接拷 .db」口径

## Order of work

1. 写 `scripts/backup-db.mjs`：路径解析、备份、校验、轮转（先跑通 CLI）。
2. 写 `test/backup-db.test.js`，先锁死快照可用性与保留策略（TDD：实现出坑时由测试暴露）。
3. 修实现缺陷：`-wal`/`-shm` 伴生文件清理（测试先红后绿）。
4. 接入 `scripts/serve.ps1`（`try/catch` + `$LASTEXITCODE`）。
5. `package.json` 加 `backup` 脚本。
6. 写 `scripts/install-backup-task.ps1`，注册 `OMPCB-Backup` 并试跑。
7. 更新 `AGENTS.md`，跑全量 `npm test`。
8. 事故恢复完成后，回溯补齐 `intent.md` / `spec.md` 并提交。

## Risks

| 风险 | 表现 | 缓解 |
|------|------|------|
| 直接拷 `.db` 导致快照残缺 | 恢复后数据"少一截" | 用在线备份 API 合并 WAL，产物只留单个 `.db` |
| 校验打开备份产生孤儿 `-wal`/`-shm` | 备份目录膨胀、轮转统计错乱 | 校验后删除伴生文件；`pruneBackups` 连带清理 |
| 轮转把备份删光 | `keep` 传 0/undefined | `Math.max(keep, 1)`；单测覆盖 `keep=0` |
| 误删外来文件 | 用户手工放进目录的文件消失 | 只匹配 `^ompcb-\d{8}-\d{6}\.db$` |
| 备份阻塞启动 | 备份异常导致 4000 端口起不来 | `try/catch`，失败仅告警 |
| 同盘备份 | 整盘损坏时备份一起没了 | `OMPCB_BACKUP_DIR` 可指向 D 盘/同步盘（默认值待你定） |
| PS 5.1 读 UTF-8 无 BOM 崩语法 | 中文注释把脚本解析搞坏 | 新 `.ps1` 写后补 BOM 并校验首字节 |

## Proof

- `npm test` → **318 通过 / 0 失败**（新增 `test/backup-db.test.js` 12 个用例：
  命名与排序、快照可打开且数据完整、缺库报错、保留策略、不误删外来文件、`keep=0` 兜底）。
- `npm run backup` → `[backup] 已备份: ...\data\backups\ompcb-20261026-215432.db (225280 bytes)`，
  且脚本内 `quick_check` 通过。
- 备份内容与线上库一致：materials 60 / inventory 90 / inventory_log 285（max id 725）/ products 3。
- 服务重启验证：计划任务 `OMPCB` 停止→启动后 `/api/health = {"ok":true}`，
  `data/backups/` 新增一份（21:48:39）。
- 计划任务 `OMPCB-Backup` 试跑：`LastTaskResult = 0`（21:48:50 生成一份）。
