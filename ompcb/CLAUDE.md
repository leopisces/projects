# OMPCB

PCB 打样物料管理工具：BOM 清单 + 库存台账，按制造商料号（mfr_pn）自动关联。
单人本地工具（内网自用），**无鉴权**，不要映射公网。
开发流程遵循 `docs/开发规范.md`（AI-Native SDLC）：先 intent → spec → plan，再动手。

## Commands

- Dev: `npm run dev`（同时起 API :4000 + 前端 :5173）
- 只起后端: `npm run dev:api`（--watch 自动重载）
- 只起前端: `npm run dev:web`（vite）
- Test: `npm test`（node:test，跑在 %TEMP% 临时库，**不碰真实数据**）
- Build: `npm run build`（vite build → dist/）
- Prod: `npm start`（Express 托管 dist/，单进程单端口 :4000）
- Seed: `npm run seed`（**破坏性**：清空 materials 重导入种子数据，慎用）
- 备份: `npm run backup`（SQLite 在线备份 API，WAL 已合并的单文件 → `data/backups/`，保留 14 份）
- 备份计划任务: `scripts\install-backup-task.ps1`（每日 12:00，任务名 `OMPCB-Backup`；`-Uninstall` 卸载）
- 发布: 双击 `scripts\deploy-quick.bat`（日常）/ `scripts\deploy.bat`（改过 package.json 时）
- 版本: Node ≥ 20 必需（Vite 6 + better-sqlite3）

## Conventions

- 金额/数量用数值比较注意精度（SQLite REAL 浮点；涉及金额尽量整数或小数扩展）。
- `mfr_pn` **没有唯一约束**——多条库存共享同一 mfr_pn 会让 LEFT JOIN 使 BOM 行重复。聚合"已焊接量"必须在子查询里按 `material_id` 预聚合后再 LEFT JOIN，**不能**直接 join `inventory_log`（否则行数和数字翻倍）。
- 已焊接量按 `-SUM(delta)` 净额聚合，**不是** `WHERE type='出库'`（撤销出库会产生正 delta 补偿行，净额自动归零）。
- `material_id`（BOM 行绑定）**只写**在出库行及其撤销补偿行上，绝不写入入库/盘点/初始行（盘点 delta 可正可负会污染净额求和）。单件出库接口只在 `type==='出库'` 时接受绑定参数，其余类型返回 400。
- 库存状态是**派生值**（`stock > 0` 正常 / `<= 0` 缺货），不可手工设置；旧 `status` 列已废弃，接口不读不写。
- 库存只能经 `POST /api/inventory/:id/move`（入库/出库/盘点）变动，`PUT` 不接受 `stock` 字段。
- BOM 不存库存信息，靠 `LEFT JOIN inventory ON m.mfr_pn = i.mfr_pn` 动态关联，永远最新。
- `src_*`（四列原值快照）与 `bound_at` **绝不能进 `EDITABLE_COLUMNS`**——那份列表被导入的 normalize() 复用，进去了会在每次导入时被清空。
- 手改 `mfr_pn`（`PUT /:id`）会清掉快照并把 `bound_at` 置 NULL；绑定（`POST /:id/bind`）则保留原值快照、只写 mfr_pn 一列。两个端点语义相反，不能合并。
- BOM 表格/CSV 显示口径共用 `web/bom-display.js`（绑定行四列紫字，原值 hover 可见；缺料橙字；"已焊接 N 件"用绝对件数不做比率）。导出必须和界面一致。
- 位号唯一约束是**产品内唯一**（`UNIQUE(product_id, designator)`），跨产品可重复。
- 批量导入 `mode=replace` 按**位号对账**更新（存在 UPDATE 保留 id，新位号 INSERT，消失 DELETE），不删表重建；不要破坏行级焊接进度。
- 搜索与同规格匹配共用 `server/search.js`（关键词分词 + 等价字符归一）。
- SQLite schema 变更：`schema.sql` 幂等建表 + `server/db/migrate-*.js` 里用 `PRAGMA table_info` 自查后再 `ALTER TABLE ADD COLUMN`（SQLite 不支持 `IF NOT EXISTS`）。加迁移照 `migrate-products.js` 的写法。
- `.bat` 必须无 BOM + CRLF；`.ps1` 必须带 BOM 的 UTF-8（PS 5.1 读无 BOM 按 ANSI 解析，中文会乱）。`.bat` 注释用 ASCII，中文只出现在 `chcp 65001` 之后的 `echo` 里。
- 换机器不能拷 `node_modules/`（better-sqlite3 是原生模块，须目标机重装）。
- 数据库 `data/ompcb.db` 不入库（gitignore），WAL 模式（-wal/-shm 也忽略）；`server/db/schema.sql` 与 `seed.tsv` 是源码**必须被跟踪**。
- **备份不能直接拷 `data/ompcb.db`**：WAL 模式下真实数据大量在 `-wal` 里，单拷会得到落后/残缺快照；必须走 `scripts/backup-db.mjs`（在线备份 API 合并 WAL，产物只剩单个 `.db`）。
- 备份目录默认 `data/backups/`（随 `data/` 被 ignore），可用 `OMPCB_BACKUP_DIR` 指到 D 盘/同步盘；源库路径口径同 `server/db/index.js`（`OMPCB_DB`）。
- 部署时 `dist/` 必须重新 build（`serve.ps1` 只在 dist 缺失时才构建，改前端后不重建会发布旧页面）；install 前必须先停服务（运行中 better-sqlite3 锁 .node 文件）。

## Architecture

- `server/` Express 4 + better-sqlite3（数据源唯一，前端所有数据都来自 /api/*）
  - `server/server.js` 入口，挂 3 组路由
  - `server/routes/`：`materials.js`（BOM，含库存动态关联/统计/批量导入）、`inventory.js`（台账 + 出入库流水/移动）、`products.js`（产品 CRUD + 每产品汇总）
  - `server/db/`：`index.js`（开库+建表+首次自动迁移）、`schema.sql`（DDL）、`seed.js/.tsv`、`migrate-*.js`（幂等迁移）
  - `server/search.js`、`server/bind-rules.js`（绑定库存提示阀值，仅提示不禁用；由 GET /inventory/match 带出，前端不硬编码）
- `web/` Vue 3 + Element Plus + Vite 6，无路由（Tab 壳 `App.vue`）
  - `web/api.js` fetch 封装；纯函数抽到 `web/*.js`（designator/expand-keys/bom-display/xlsx-import/location/confirm）以便单测
- `test/` node:test，跑临时库；纯逻辑单测锁关键口径（bom-display/expand-keys/designator/location/soldered）
- 三张表：`products` / `materials` / `inventory` + `inventory_log`（出入库流水，CASCADE 级联清除）
- 首次启动：建表 → materials 空则导 seed → 依次跑幂等迁移 → inventory 空则从 BOM 按料号去重抽取落"初始"流水

## Things Claude gets wrong

- **已焊接量计算**：忘记按 material_id 子查询预聚合，直接把 inventory_log join 进来 → 行数翻倍、数字翻倍。必须 `GROUP BY material_id` 预聚合完再 LEFT JOIN。
- **撤销出库的统计口径**：用 `WHERE type='出库'` 或 `revokes_log_id IS NULL` 反连接统计已焊接 → 已撤销的出库被算成已领。用 `-SUM(delta)` 净额。
- **el-table expand-change 第二参数是数组不是布尔**（只有树形表格才发布尔）。`Boolean([])===true` 会导致"点开后收不回去"。展开态一律以数组为准（逻辑在 `web/expand-keys.js`，别绕开）。
- **绑定 vs 手改混用同一端点**：绑定要留原值快照、手改要清快照，语义相反，必须两个端点。
- **schema 迁移直接 `ALTER TABLE ADD COLUMN`**：SQLite 不支持 IF NOT EXISTS，先 PRAGMA table_info 自查。
- **发布不 rebuild**：改了前端但 dist/ 还在 → 页面是旧的。
- **UI 显示口径与 CSV 导出不一致**：两处必须共用 `web/bom-display.js`，否则下单收货方看到两列不同值。
- **备份直接拷 `.db`**：WAL 模式下会拿到落后甚至页级残缺的快照。用 `scripts/backup-db.mjs`（`db.backup()` 在线备份 API）。
- **只读打开 WAL 库也会产生 `-wal`/`-shm`**：备份校验后忘了删 → `data/backups/` 里堆积孤儿文件，轮转统计也跟着错乱。校验完必须清理 `dest + '-wal' / '-shm'`。
- **轮转 `keep` 没兜底**：`keep=0` 或 `undefined` 直接把目录清空（`slice(0)`）。一律 `Math.max(keep, 1)`。
