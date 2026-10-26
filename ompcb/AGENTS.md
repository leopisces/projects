# AGENTS.md — OMPCB 项目引导（OpenCode 入口）

> 本文件是任何 AI agent（OpenCode / Claude Code / 其他）在本项目工作的**必读入口**。
> **开发前必须先读并遵守：`docs/开发规范.md`（AI-Native SDLC 流程）。本文件是它的摘要 + 强制入口。**

## 0. 这是什么项目

PCB 打样物料管理工具：BOM 清单 + 库存台账，按制造商料号（mfr_pn）自动关联。
**单人本地工具，内网自用，无鉴权**。技术栈：Vue 3 + Element Plus + Vite 6 / Express 4 + better-sqlite3 / SQLite。Node ≥ 20。

## 1. 强制开发流程（不可跳过）

任何功能开发/修复/改动，**必须**按 `docs/开发规范.md` 的 AI-Native SDLC 流程走，产出物提交到 git：

1. **Plan**：写 `docs/intent/<名称>.md`（问题/目标/用户/约束/未决问题）→ 用户确认
2. **Design**：写 `docs/specs/<名称>.md`（需求编号化、约束逐条映射、concerns 标注 owner）→ 用户确认
3. **Build**：先出 `docs/plans/<名称>.md`（文件/顺序/风险/证明），用户批准后才实现；实现偏离计划须同提交更新 plan
4. **Test**：报告完成前必须跑 `npm test` 并贴输出；修 bug 先写失败测试
5. **收尾**：逐条过 `docs/开发规范.md` §9 检查清单

> 用户说"开发 XX 功能 / 按规范开发 XX / 加个 XX"时，默认进入此流程。模板见 `docs/开发规范.md` §2/§3/§4。

## 2. 命令

- `npm run dev` — 同时起 API(:4000) + 前端(:5173)
- `npm run dev:api` / `npm run dev:web` — 单独起后端/前端
- `npm test` — node:test，跑在 %TEMP% 临时库（**不碰真实数据**）
- `npm run build` — vite build → dist/
- `npm start` — 生产模式，Express 托管 dist/（单进程单端口 :4000）
- `npm run seed` — **破坏性**：清空 materials 重导入种子数据，慎用
- `npm run backup` — 生成一份一致性快照到 `data/backups/`（SQLite 在线备份 API，自动合并 WAL；保留最近 14 份）
- 备份计划任务：`scripts\install-backup-task.ps1`（每日 12:00）；`-Uninstall` 卸载
- 发布：`scripts\deploy-quick.bat`（日常）/ `scripts\deploy.bat`（改过 package.json 时）

## 3. 关键约定（完整版在 docs/开发规范.md 与 CLAUDE.md）

- `mfr_pn` **无唯一约束**；"已焊接量"必须在子查询按 `material_id` 预聚合再 LEFT JOIN，**不能**直接 join `inventory_log`（行数/数字翻倍）
- 已焊接量按 `-SUM(delta)` 净额，**不是** `WHERE type='出库'`
- `material_id` 只写出库行及其撤销补偿行，绝不写入库/盘点/初始行
- 库存状态是派生值（stock>0 正常），不可手工设置；库存只能经 `POST /api/inventory/:id/move` 变动
- BOM 不存库存信息，动态 `LEFT JOIN` 关联
- `src_*` 与 `bound_at` **绝不能进 `EDITABLE_COLUMNS`**（导入 normalize() 会清空）
- 绑定（`POST /:id/bind`）留原值快照 vs 手改（`PUT /:id`）清快照，语义相反，两个端点
- BOM 表格/CSV 导出共用 `web/bom-display.js`，必须一致
- 位号唯一约束**产品内唯一**；`mode=replace` 批量导入按位号对账（不删表重建）
- SQLite schema 变更：schema.sql 幂等 + migrate-*.js 用 `PRAGMA table_info` 自查后 ALTER（不支持 IF NOT EXISTS）
- `.bat` 无 BOM + CRLF；`.ps1` 带 BOM 的 UTF-8；`.bat` 注释用 ASCII
- 换机器不能拷 `node_modules/`（原生模块）；install 前先停服务（锁 .node 文件）
- 数据库 `data/ompcb.db` 不入库（WAL）；`schema.sql` 与 `seed.tsv` 是源码**必须被跟踪**
- 备份**不能直接拷 .db**：WAL 模式下真实数据在 `-wal` 里，必须用 `scripts/backup-db.mjs`（在线备份 API）
- `data/backups/` 每次服务启动前备一份（`serve.ps1`），另有每日计划任务 `OMPCB-Backup`
- 发布必须重新 build（serve.ps1 只在 dist 缺失时才构建）

## 4. 架构速览

- `server/` — Express + better-sqlite3（数据唯一来源，所有数据都来自 /api/*）
  - `routes/`：`materials.js`（BOM）、`inventory.js`（台账+流水）、`products.js`
  - `db/`：`index.js`（开库+迁移）、`schema.sql`、`seed.js/.tsv`、`migrate-*.js`
  - `search.js`（分词归一）、`bind-rules.js`（绑定阀值，仅提示）
- `web/` — Vue 3 + Element Plus，Tab 壳 `App.vue`；纯函数抽 `web/*.js`（designator/expand-keys/bom-display 等）以便单测
- `test/` — node:test 跑临时库，锁关键口径
- 三张表：`products` / `materials` / `inventory` + `inventory_log` 流水

## 5. 常错点（agent 老犯的错，勿再犯）

1. 已焊接量直接 join inventory_log → 行数翻倍。先 GROUP BY material_id 预聚合。
2. 用 `WHERE type='出库'` 统计已焊接 → 已撤销的出库被算成已领。用净额。
3. el-table `expand-change` 第二参数是**数组不是布尔**（`Boolean([])===true` 收不回去）。逻辑在 `web/expand-keys.js`。
4. 绑定/手改混用端点 → 快照语义冲突。两个端点。
5. schema 直接 `ALTER TABLE ADD COLUMN`（无 IF NOT EXISTS）→ 先 PRAGMA 自查。
6. 发布不 rebuild → 页面旧。
7. UI 与 CSV 口径不一致 → 共用 bom-display.js。

## 6. 收尾铁律

- **不主动 commit/push**：只有用户明确说"提交/推送"才执行，且先展示 diff 与 commit message 等确认
- **不主动启动服务/跑 build**：除非用户要求
- 报告完成前跑 `npm test` 并贴输出
- 每次踩坑沉淀：同错误第二次 → 写进 `CLAUDE.md`；政策被违反 → 固化进 skill 或加 hook（见 docs/开发规范.md §7.2）
