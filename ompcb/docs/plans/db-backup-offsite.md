# Plan: 备份异地副本（db-backup-offsite）

> 源自 spec.md: `docs/specs/db-backup-offsite.md`
日期: 2026-10-26

## Files that change

- 修改 `scripts/backup-db.mjs` — 单目标 → 多目标；新增 `resolveMirrors` / `--status`；`backupDatabase` 返回 targets 汇总
- 修改 `test/backup-db.test.js` — 现有 12 个用例适配新返回结构 + 新增多目标用例
- 修改 `package.json` — `backup:status`
- 修改 `README.md` — 命令表、三写口径、5 行恢复短版
- 修改 `CLAUDE.md`、`AGENTS.md` — `OMPCB_BACKUP_MIRRORS` / `OMPCB_BACKUP_KEEP` / `npm run backup:status`
- 新增 `docs/specs/db-backup-offsite.md`、`docs/plans/db-backup-offsite.md`（本文）
- 不改 `scripts/serve.ps1`、`scripts/install-backup-task.ps1`（入口与容错已满足）

## Order of work

1. **先写测试**：在 `test/backup-db.test.js` 增加多目标用例（三目标落地、mirror 失败隔离、独立轮转、同名跳过、盘不存在跳过、状态输出），跑一遍确认因缺实现而失败。
2. 重构 `scripts/backup-db.mjs`：
   1. `resolveTargets()`（本地 + `OMPCB_BACKUP_MIRRORS` 解析，路径去重）
   2. `backupDatabase()` 改为「临时快照 → 校验 → 逐目标复制 + 独立轮转 → 汇总」
   3. `--status` CLI（`formatStatus`）
3. 让测试转绿；保持原 12 个用例语义不变（只跟着返回结构微调断言）。
4. `package.json` 加 `backup:status`。
5. 手动验证：`npm run backup` → 三个目录同名文件；`npm run backup:status` → 三行；`Z:\nope` 负例。
6. 更新 `README.md` / `CLAUDE.md` / `AGENTS.md`。
7. 跑全量 `npm test`，重启服务确认启动兜底仍工作。

## Risks

| 风险 | 表现 | 缓解 |
|------|------|------|
| 同名跳过导致"看起来没备份" | 同一秒双触发时第二次 skipped | 日志/状态明确标注；人工与定时任务撞秒概率极低 |
| 同步盘占用文件 | 复制或删除失败 | 复制重试 1 次；删除失败仅 warning |
| 盘未挂载时误判为失败 | 服务启动刷黄色告警 | 用盘符存在性判定 → `skipped`，不计入失败 |
| 临时快照残留 | `%TEMP%` 堆积 4 MB 文件 | `finally` 中删除；异常路径也覆盖 |
| 返回结构变更破坏既有调用方 | `serve.ps1` 只读退出码，不受影响；测试需同步 | 保持 CLI 退出码语义不变（本地成功 = 0） |
| 三写导致总耗时增加 | 本地复制 2 次 × 4 MB | 本地毫秒级；同步盘复制不等网络（客户端异步上传） |

## Proof

- `npm test` 全绿，其中新增用例至少覆盖：
  - 三个目标各落地一份同名 `.db`，大小一致
  - `mirrors` 指向不存在盘符 → 该目标 `skipped`、整体 `ok`
  - 某目标目录不可写 → 该目标 `failed`、其余 `ok`、整体 `ok`（本地成功口径）
  - 三目标独立 `keep`：本地 2、异地 1 → 各自剩余份数正确
  - 同名文件已存在 → `skipped`，不覆盖
  - `formatStatus` 输出包含各目标份数/最近时间/冲突副本计数
- `npm run backup`：三个目录出现 `ompcb-YYYYMMDD-HHmmss.db`，`quick_check = ok`。
- `npm run backup:status`：三行输出，数字与 `dir` 实际一致。
- 重启计划任务 `OMPCB`：启动日志出现备份、`:4000` 健康检查 ok。

## 实现偏离记录（同提交更新）

1. `OMPCB_BACKUP_MIRRORS=none` 可显式关闭异地副本 —— 计划外补充，用于"只想本地备份"的回退路径，
   `resolveMirrors` 已覆盖；spec R6 的可配置语义不变。
2. 镜像 label 从 `盘符\目录名` 改为**完整路径**：`D:\ompcb-backup` 与 `D:\BaiduSyncdisk\ompcb-backup`
   旧口径下都显示成 `D:\ompcb-backup`，状态输出无法区分。
3. 新增 `listBackups` / `formatStatus` 两个导出（原计划只写 `--status` CLI），便于单测断言状态输出。
