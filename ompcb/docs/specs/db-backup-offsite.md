# Spec: 备份异地副本（db-backup-offsite）

> 源自 intent.md: `docs/intent/db-backup-offsite.md`
日期: 2026-10-26

## Requirements

- **R1.** 一次备份产生三份副本：本地 `data/backups/`、`D:\ompcb-backup\`、`D:\BaiduSyncdisk\ompcb-backup\`。
- **R2.** 快照只生成**一次**（一份源文件），其余目标通过复制该快照落地 —— 避免对源库重复备份、避免三份内容不一致。
- **R3.** 各目标**独立轮转**：本地保留 14 份，两个异地目标各保留 30 份。
- **R4.** 任一目标失败（目录不可写、盘未挂载、被占用）**不得**导致其他目标失败，也不得让服务启动失败；失败要告警并体现在退出码/状态输出里。
- **R5.** 整体成功口径：**本地目标成功即视为成功**（异地只是冗余）；若本地目标也未配置，则任一目标成功即成功。
- **R6.** 目标路径与保留份数可配置：`OMPCB_BACKUP_DIR`/`OMPCB_BACKUP_KEEP`（本地）、`OMPCB_BACKUP_MIRRORS`（异地，`路径=份数;路径=份数`）。
- **R7.** 轮转严格匹配 `^ompcb-\d{8}-\d{6}\.db$`；同步盘客户端产生的 ` (1)` 后缀冲突副本、临时文件**不自动删除**，只在状态里提示。
- **R8.** 新增 `npm run backup:status`：逐目标输出「最近成功时间 / 份数 / 占用大小 / 冲突副本数」。
- **R9.** 备份仍须 `PRAGMA quick_check` 自校验，且产物只留单个 `.db`（不留 `-wal`/`-shm`）。
- **R10.** 文档更新：`README` 增加 5 行恢复短版 + 状态命令；`CLAUDE.md`/`AGENTS.md` 记录新环境变量与「三写」口径。

## Design

### 流程（单次 `npm run backup`）

```
1. 解析目标列表 resolveTargets()
     local    : OMPCB_BACKUP_DIR || <repo>/data/backups          keep = OMPCB_BACKUP_KEEP || 14
     mirrors  : OMPCB_BACKUP_MIRRORS || "D:\\ompcb-backup=30;D:\\BaiduSyncdisk\\ompcb-backup=30"
     - 去掉与 local 解析后同路径的项（去重）
2. 以 readonly 打开源库 → db.backup(<tmp>/ompcb-YYYYMMDD-HHmmss.db)   ← 只做一次，WAL 合并
3. 校验快照：PRAGMA quick_check === 'ok'，否则整体失败（不落地任何副本）
4. 逐目标复制快照：
     - 目录不存在 → mkdir（父盘不存在 → 记 status='skipped:盘未挂载'）
     - 复制失败（占用/权限）→ 重试 1 次 → 仍失败 → status='failed' + 告警
     - 复制成功 → pruneBackups(dir, keep) → status='ok'
5. 删除临时快照
6. 汇总：任一 failed/skipped 打印告警；判定总体成败（R5）
```

### 数据/接口形态

```js
// 目标描述
{ label: 'local' | 'D:' | 'sync', dir: 'C:\\...', keep: 14 }

// 备份结果
{
  ok: boolean,                     // R5 口径
  file: 'ompcb-20261026-220000.db',
  size: 225280,
  targets: [
    { label, dir, status: 'ok' | 'failed' | 'skipped', keep, removed: [...], error?: string }
  ]
}
```

### 关键实现细节

- **只 Snap 一次**：`db.backup()` 只在第 2 步调用，异地副本用 `copyFile`。这样即使同步盘很慢，
  也不会拉长源库被读取的时间窗，且三份内容天然一致。
- **复制前不覆盖已有同名文件**：同名即同一秒内重复触发，跳过并记 `skipped`，避免两次不同内容互相覆盖。
- **盘可用性判定**：用 `existsSync(path.parse(dir).root)` 判断盘符是否存在（`D:\` 存在且无 D 盘时返回 false），
  不存在则 `skipped`，不抛异常。
- **临时快照位置**：`os.tmpdir()`，进程退出前 `finally` 删除，避免残留。
- **状态命令**：`node scripts/backup-db.mjs --status`；`package.json` 增加 `backup:status`。
  冲突副本识别：`^ompcb-\d{8}-\d{6}\.db( \(\d+\))?$` 中带括号后缀的计为冲突副本（仅提示）。

### 涉及文件

| 文件 | 变更 |
|------|------|
| `scripts/backup-db.mjs` | 重写为多目标：`resolveTargets` / `resolveMirrors` / `backupDatabase`（返回 targets 汇总）/ `--status` CLI |
| `test/backup-db.test.js` | 扩展现有 12 个用例 + 新增多目标用例（见 Proof） |
| `package.json` | `backup:status` |
| `README.md` | 命令表 + 5 行恢复短版 |
| `CLAUDE.md` / `AGENTS.md` | 新环境变量、三写口径、状态命令 |
| `scripts/serve.ps1` / `install-backup-task.ps1` | 无需改动（仍调用同一脚本，失败不阻断已成立） |

## How each intent constraint is met

| intent 约束 | 设计中的对应 |
|-------------|-------------|
| 不能因 D 盘/同步盘问题让备份失败或服务起不来 | 每目标独立 `try/catch`；盘不存在 → `skipped`；`serve.ps1` 已 `try/catch`；R5 口径以本地为准 |
| 不改源库路径与备份命名 | 不动 `resolveDbPath()`；文件名规则沿用 `ompcb-YYYYMMDD-HHmmss.db` |
| 不引入新依赖 | 只用 `better-sqlite3` + `fs/path/os` |
| 各目标保留份数独立可配 | 目标结构自带 `keep`；`OMPCB_BACKUP_MIRRORS` 用 `路径=份数` 表达 |
| 备份不进 git | 三个目录都在 `data/`（ignore）或盘外 |
| 同步盘容错 | 严格命名匹配才轮转；` (1)` 副本只在状态里提示 |
| 备份耗时不能显著增加 | 快照只做一次，异地为本地文件复制（4 MB 级） |

## Open questions

intent 的 7 个问题均已在 intent 的「决策」表中关闭；实现层面无新增未决问题。

## Areas of concern

1. **数据上云**：`D:\BaiduSyncdisk\ompcb-backup` 会把 BOM/库存库文件同步到百度云端。Owner: leopisces（已接受）。
   缓解：可用 `OMPCB_BACKUP_MIRRORS` 去掉该目标，一行配置即可退出上云。
2. **同步客户端占用文件**：百度网盘上传时可能短暂占用刚创建的 `.db`，导致下一轮复制/轮转失败。
   Owner: leopisces。缓解：复制失败重试 1 次；轮转删除失败只记 warning 不抛错（`rmSync force` + try）。
3. **同名跳过策略的副作用**：同一秒内两次触发时第二次会 `skipped`，看起来像"没备份"。
   Owner: leopisces。缓解：状态/日志里明确打印 `skipped:同名已存在`；实际触发频率极低（人工 + 每日任务）。
4. **`D:\ompcb-backup` 与 `D:\BaiduSyncdisk` 同盘**：两块路径其实在同一块物理盘（D:），不是真正的"第二块盘"。
   真正异地靠的是百度云端。Owner: leopisces。若将来插移动硬盘，改 `OMPCB_BACKUP_MIRRORS` 即可。
5. **轮转把异地备份删光的可能**：`keep` 传错时可能清空某个目标（已用 `Math.max(keep, 1)` 兜底）。
   Owner: leopisces。单测覆盖 `keep=0`。

## 验证

- `npm test`：现有 318 个用例全绿 + 新增多目标用例。
- 手动 `npm run backup`：三个目录都出现同名 `.db`，大小一致，`quick_check = ok`。
- 手动 `npm run backup:status`：三行输出，时间/份数/占用正确。
- 模拟失败：把某个 mirror 指到不存在的盘符（如 `Z:\nope=30`）→ 该目标 `skipped`，其余 `ok`，整体 `ok`。
- 服务重启：`serve.ps1` 启动日志出现备份，`:4000` 健康检查 ok。
