# Lessons: 误删数据库与自动备份的落地（2026-10-26）

> 两个教训：**数据丢了怎么找回**，以及**备份实现里踩到的两个坑**。
> 前者写进本文与 `docs/intent/db-backup.md`，后者同时沉淀进 `CLAUDE.md`。

## 事件 1：`Codes\ompcb` 目录被误删，数据库随之消失

### 现象

- 用户发现 `:4000` 上的数据不是自己的（只剩 75 行种子料），而真实数据应当在
  `C:\Users\Leopisces\Desktop\Codes\ompcb\data\ompcb.db`。
- 该目录已不存在，`Desktop\projects\ompcb\data\` 里的库是 21:17 新建的种子库。
- 回收站 62 条记录逐一核对：**没有** ompcb 目录，也没有 `ompcb.db`。

### 定位过程（可复用的排查顺序）

1. **先划清责任时间线**：对比文件 `CreationTime`、进程 `StartTime`、`-wal` 的 mtime。
   本次 `ompcb.db` 创建于 21:17:36，而当前会话 21:22:31 才启动 → 与本会话无关。
2. **查回收站要解析 `$I` 元数据**，不能只看 `$R` 目录名：`$I` 里有原始路径 + 删除时间。
   结论：62 条里没有 ompcb → 说明是 `rm` / `git clean` 这类**绕过回收站**的删除。
3. **提权读 USN 变更日志**：`fsutil usn readjournal C: csv | findstr /i ompcb`，
   直接给出 `"ompcb",目录,文件删除,2026/10/26 20:56:48` —— 精确到秒，且证实是目录删除。
4. **查卷影副本**：`vssadmin list shadows /for=C:` 找到 10-24、10-25 两个快照，
   从 `\\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy15\Users\...\Codes\ompcb\data\`
   捞出 `ompcb.db`(225,280 B) + `ompcb.db-wal`(4,144,752 B) + 一份 8-27 的 `.bak`。
5. **恢复**：备份现场 → 拷 `db` + `db-wal` → 删旧 `-shm` 让 SQLite 重建 → 起服务验证。
   结果：3 个产品、60 行 BOM、90 条台账、285 条流水（最后一条 2026-10-11 12:39），`quick_check = ok`。

### 根因

项目没有任何备份；`data/` 被 gitignore，删除后 git 帮不上忙。
损失窗口 = 10-15 13:32（最后一次写入）→ 10-26 20:56（删除），这段时间的改动永久丢失。

### 沉淀

- 新增自动备份（`docs/specs/db-backup.md`）。
- 恢复出来的快照别急着删：`D:\ompcb-recovered\` 保留期间是唯一来源。
- **排查顺序**：时间线 → 回收站 `$I` → USN → 卷影副本 → 文件雕刻。前四步都是秒级/分钟级，
  不要一上来就全盘雕刻（慢且成功率低）。

## 事件 2：备份实现中的两个坑（已由测试锁住）

### 坑 A：只读打开 WAL 库会生成 `-wal`/`-shm`

校验备份时用 `readonly` 打开，SQLite 仍会在备份文件旁边创建 `-wal` / `-shm`，
导致 `data/backups/` 里每个备份变成 3 个文件，轮转统计与命名规则全乱。

- 暴露方式：`test/backup-db.test.js` 断言「5 次备份 keep=3 只剩 3 个 `.db`」，
  实际多出 4 个 `-wal`/`-shm`，测试先红。
- 修复：校验后删除 `dest + '-wal' / '-shm'`；轮转删旧份时连带清理伴生文件。

### 坑 B：轮转 `keep` 没兜底会清空目录

`files.slice(Math.max(keep, 1))` —— 不写 `Math.max` 时，`keep=0` / 传入 `undefined`
会让 `slice(0)` 删光所有备份（包括刚生成的那份）。已加兜底 + 单测覆盖。

### 通用教训

- **先写测试再修实现**：两个坑都是测试先红，改完立刻变绿，没有"猜"的成分。
- **备份必须自校验**：`db.backup()` 之后 `PRAGMA quick_check`，不能只看文件大小。
- **备份失败不能阻断服务**：`serve.ps1` 里 `try/catch` + 检查 `$LASTEXITCODE`，只告警。
