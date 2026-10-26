# Spec: 数据库自动备份（db-backup）

> 源自 intent.md: `docs/intent/db-backup.md`
日期: 2026-10-26

## Requirements

- **R1.** 服务启动时（`scripts/serve.ps1`）自动生成一份一致性备份。
- **R2.** 每日定时（默认 12:00）通过 Windows 计划任务再生成一份。
- **R3.** 备份必须是**单文件**、可独立打开的完整库：WAL 内容已合并，不残留 `-wal`/`-shm`。
- **R4.** 备份完成后必须自校验（`PRAGMA quick_check`），校验不过视为失败。
- **R5.** 保留最近 14 份，超出按文件名（时间戳）删除最旧的；清理**只**作用于符合命名规则的文件。
- **R6.** 备份失败不得阻断服务启动，只告警。
- **R7.** 备份过程**只读**源库，不修改 `data/ompcb.db`。
- **R8.** 提供手动入口 `npm run backup`，并用 `node:test` 覆盖快照可用性与保留策略。
- **R9.** 备份目录可配置（`OMPCB_BACKUP_DIR`），源库路径与 `server/db/index.js` 同口径（`OMPCB_DB`）。

## Design

### 核心技术选择

用 `better-sqlite3` 的在线备份 API（`db.backup(dest)`，对应 SQLite Online Backup API），
而不是文件拷贝：由 SQLite 自己保证页级一致，并自动把 WAL 内容合并进目标文件。

### 文件

| 文件 | 角色 |
|------|------|
| `scripts/backup-db.mjs` | 备份实现（可 CLI、可 import）。导出 `resolveDbPath` / `resolveBackupDir` / `backupFileName` / `pruneBackups` / `backupDatabase` / `DEFAULT_KEEP` |
| `scripts/serve.ps1` | 启动前调用备份；`try/catch` + 检查 `$LASTEXITCODE`，失败仅黄字告警 |
| `scripts/install-backup-task.ps1` | 注册/卸载计划任务 `OMPCB-Backup`（每日 12:00），`-Uninstall` 移除 |
| `package.json` | `"backup": "node scripts/backup-db.mjs"` |
| `test/backup-db.test.js` | 12 个用例，全部跑在 `%TEMP%` 临时库 |
| `docs/plans/db-backup.md` | 实现计划 |

### 数据流

```
serve.ps1 / 计划任务 / npm run backup
        └─> node scripts/backup-db.mjs
              1. 解析源库路径（OMPCB_DB 或 data/ompcb.db）
              2. 以 readonly 打开源库
              3. db.backup(data/backups/ompcb-YYYYMMDD-HHmmss.db)   ← WAL 合并
              4. 关闭后以 readonly 打开备份 → PRAGMA quick_check === 'ok'
              5. 删除校验时产生的 -wal/-shm 伴生文件
              6. pruneBackups(dir, keep=14)：按文件名倒序保留，其余删除
```

### 关键实现细节

- **只读打开**：`new Database(dbPath, { readonly: true, fileMustExist: true })`，
  备份是纯读操作，绝不写源库。
- **校验会生成伴生文件**：以只读方式打开一份 WAL 模式的库，SQLite 仍会创建 `-wal`/`-shm`，
  因此校验后必须删除 `dest + '-wal'` / `dest + '-shm'`，否则备份目录会积累孤儿文件
  （这是实现过程中真实踩到的坑，见 §Areas of concern 1）。
- **命名即排序**：`ompcb-YYYYMMDD-HHmmss.db` 补零后字典序等于时间序，清理无需读文件内容。
- **keep 兜底**：`Math.max(keep, 1)`，`keep=0/负数` 也不会把目录清空。
- **不误删外来文件**：`pruneBackups` 只处理匹配 `^ompcb-\d{8}-\d{6}\.db$` 的文件，
  用户手工丢进目录的其他文件不动。

## How each intent constraint is met

| intent 约束 | 设计中的对应 |
|-------------|-------------|
| 不改变 `data/ompcb.db` 位置与口径 | 备份只写 `data/backups/`（`OMPCB_BACKUP_DIR` 可覆盖），源库只读打开 |
| 备份不进 git | 产物在 `data/` 下，`data/` 已被 `.gitignore` 排除；未新增任何被跟踪的二进制 |
| 不得阻断服务启动 | `serve.ps1` 的备份调用包在 `try/catch` 里，并检查 `$LASTEXITCODE`，失败只告警 |
| 不引入新依赖 | 复用已有 `better-sqlite3` 的 `db.backup()` |
| `.ps1` 带 BOM 的 UTF-8、兼容 PS 5.1 | 新脚本写后补 BOM（`efbbbf` 已校验）；只用 `New-ScheduledTask*` 等 5.1 可用 cmdlet |
| 体积可控 | 保留 14 份；单份 ≈ 225 KB（WAL 合并后） |

## Open questions

| intent 问题 | 结论 |
|-------------|------|
| 1. 备份放哪 | 默认项目内 `data/backups/`（随 `data/` 被 ignore，无需改仓库配置）；外部磁盘/同步盘通过 `OMPCB_BACKUP_DIR` 覆盖，不硬编码盘符 |
| 2. 每日时间点 | 12:00（午间，机器通常开机；配合 `-StartWhenAvailable` 支持错过后补跑） |
| 3. 保留多少份 | 14 份 ≈ 两周，约 3 MB 量级，够覆盖"发现被删时已过几天"的场景 |
| 4. 运行中备份是否安全 | 安全，不需要停服务。SQLite 在线备份 API 保证页级一致；源库以只读方式打开 |
| 5. 失败要不要告警 | 现阶段只记日志（stderr + 退出码 1，计划任务 `LastTaskResult` 可查）。桌面通知/邮件属于范围外，留待后续 |

## Areas of concern

1. **校验打开备份会产生 `-wal`/`-shm` 孤儿文件**。Owner: leopisces。
   首发实现里漏了清理，`test/backup-db.test.js` 的保留策略用例直接暴露（期望 3 个 `.db`，
   实际多出 4 个 `-wal`/`-shm`）。处置：校验后删除伴生文件，`pruneBackups` 删除旧份时一并清理。
2. **备份目录与源库同盘**：整盘/整机损坏时备份同归于尽。Owner: leopisces。
   缓解：`OMPCB_BACKUP_DIR` 可指向 D 盘或同步盘；是否默认异地备份待定（属新的 intent）。
3. **备份不是版本历史**：只保留 14 份，且"误操作后写入的新数据"会覆盖滚动窗口。
   Owner: leopisces。属可接受风险（单人自用，事故场景主要是误删文件而非数据写坏）。
4. **计划任务依赖当前用户登录态**（沿用 `install-autostart.ps1` 的取舍：注册服务需管理员）。
   Owner: leopisces。未登录时每日备份不会跑，但服务启动兜底仍在。

## 验证

- `npm test`：318 通过 / 0 失败（含新增 12 个备份用例）。
- 手动 `npm run backup`：输出路径与大小，`quick_check = ok`。
- 服务重启（计划任务 `OMPCB`）：启动日志出现备份、`data/backups/` 新增一份、`:4000` 健康检查 ok。
- 计划任务 `OMPCB-Backup` 试跑：`LastTaskResult = 0`。
