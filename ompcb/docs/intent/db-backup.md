# Intent: 数据库不再怕"删库/拷错"——自动一致性备份

Author: leopisces. Status: accepted.
日期: 2026-10-26

> 流程说明：本文档在实现之后补齐。当晚是事故恢复（误删 + 卷影副本找回）驱动的，
> 先动手后补文档，属于对 `docs/开发规范.md` Stage 1 的偏离，事后回溯补齐以留痕。

## Problem

- 2026-10-26 20:56，项目目录 `C:\Users\Leopisces\Desktop\Codes\ompcb` 被误删，
  `data/ompcb.db` 与 4 MB 的 `data/ompcb.db-wal` 一起消失。最后靠 10-25 的卷影副本
  （`HarddiskVolumeShadowCopy15`）捞回，**10-15 13:32 之后的所有改动永久丢失**。
- 项目此前没有任何备份机制：`data/` 被 `.gitignore` 排除，git 帮不上忙。
- 直觉做法「拷 `data\ompcb.db`」是错的：库跑在 WAL 模式，真实数据大量驻留在 `-wal`，
  单拷 `.db` 会得到落后甚至页级残缺的快照；拷三件套又可能拿到不一致的组合。
- 服务由计划任务托管，人工备份必然会被忘记。

## Proposed outcome

- 服务每次启动前，自动生成一份**一致性**快照。
- 每天定时再备一份。
- 每份备份是**单文件**，WAL 已合并，直接改名覆盖 `data/ompcb.db` 即可回滚。
- 旧备份自动轮转，不需要人工清理，占用空间有上限。
- 备份失败**不影响**服务启动。

## Affected users and systems

- 用户：单人内网自用，唯一使用者就是作者本人。
- 系统：`data/ompcb.db`（源）与 `data/backups/`（产物）；`scripts/serve.ps1`（启动入口）；
  Windows 计划任务（每日触发）。
- 不涉及：业务表结构、`/api/*` 接口、Vue 前端、`inventory_log` 口径。

## Constraints

- **不得**改变 `data/ompcb.db` 的位置与内容口径（数据唯一来源不变，不做迁移）。
- 备份产物**不进入 git**（`data/` 已 ignore；且体积会累积）。
- 备份**不得阻断**服务启动（备份是兜底，不该成为新的单点故障）。
- 不引入新的 npm 依赖：用已有的 `better-sqlite3`。
- 沿用项目约定：`.ps1` 带 BOM 的 UTF-8；脚本兼容 Windows PowerShell 5.1。
- 备份体积可控：保留份数有限，不能无限增长。

## Open questions

1. 备份放哪：项目内 `data/backups/` 还是 D 盘/同步盘（异地）？
2. 每日备份的时间点选什么时候？
3. 保留多少份合适？
4. 服务运行中备份是否安全，需要先停服务吗？
5. 备份失败要不要告警，还是只记日志？
