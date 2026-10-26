# Review instructions

单人项目没有 PR 流程，但**评审这个动作不能省**。合并/发布前自己当 reviewer 过一遍下面三类，
尤其是「这次改动是否偏离了 `docs/plans/*.md` 的意图」。

## Passes（三类，每条发现标注来源）

- **Bugs**：逻辑错误、边界情况、微妙回归
- **Security**：注入、鉴权缺口、敏感数据进日志
- **Compliance**：改动符合 `docs/specs/*.md`、`docs/plans/*.md`、`CLAUDE.md` 的设计原则

## Important vs Nit

- **Important**：破坏行为、泄露数据、违反政策的发现
- 风格和命名是 **Nit**

## 限制 Nit 数量

- 每次评审最多报 5 条 Nit，其余汇总成计数

## 不报告

- 生成文件（`dist/`、`node_modules/`、`data/`）
- CI / `npm test` 已强制的项

## 本项目必过的关卡

| 关卡 | 触发条件 | 做法 |
|------|---------|------|
| 数据库 schema 变更 | 改 `server/db/schema.sql` 或新增 `migrate-*.js` | 幂等 + `PRAGMA table_info` 自查；发布前 `npm run backup` |
| 破坏性命令 | `npm run seed`、手写 SQL 改 `data/ompcb.db` | 必须人工确认；先 `npm run backup` 留档 |
| 业务口径改动 | 出入库、已焊接量、库存状态、BOM 绑定 | 对照 `CLAUDE.md` 的 Conventions 逐条核 |
| 发布 | `scripts\deploy*.bat` | 先 `npm test` 全绿，再 build；回滚 = 用 `data/backups/` 最近一份覆盖 `data/ompcb.db` |

## 回滚预案

1. 停服务（`Stop-ScheduledTask -TaskName OMPCB`）。
2. 取 `data/backups/` 最近一份，覆盖 `data/ompcb.db`（备份是单文件，WAL 已合并）。
3. 删除残留 `data/ompcb.db-wal` / `-shm`。
4. 起服务（`Start-ScheduledTask -TaskName OMPCB`），`/api/health` 与数据抽查。
