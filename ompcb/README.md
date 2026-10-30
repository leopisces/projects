# OMPCB

PCB 打样的**物料管理**工具。解决一个具体问题：手头攒了一堆元件，又有几块板要做，到底还差什么、要买多少。

两份台账，各管一件事：

| | 回答的问题 | 数据 |
|---|---|---|
| **BOM 清单** | 这块板要用什么 | 按产品组织，一个产品一份 BOM |
| **库存台账** | 手头实际有什么、放在哪 | 元件级，出入库流水可追溯 |

两者**按制造商料号（mfr_pn）自动关联**，不需要人工维护对应关系。改了库存，BOM 页立刻反映。

## 技术栈

Vue 3 + Element Plus + Vite 6 / Express 4 + better-sqlite3 / SQLite

## 快速开始

需要 **Node ≥ 20**（Vite 6 + better-sqlite3 的要求）。

```bash
npm install
npm run dev        # 同时起 API(4000) 与前端(5173)
```

打开 http://localhost:5173 即可。首次启动会自动建库、导入种子数据、生成库存台账。

### 命令

| 命令 | 作用 |
|---|---|
| `npm run dev` | 并发启动 API + 前端（开发用） |
| `npm run dev:api` | 只起 API，带 `--watch` 自动重载 |
| `npm run dev:web` | 只起前端 |
| `npm run build` | 构建到 `dist/` |
| `npm start` | 生产模式，Express 直接托管 `dist/` |
| `npm test` | 跑测试（临时库，不碰真实数据） |
| `npm run seed` | **破坏性**：清空 materials 重新导入种子数据 |
| `npm run backup` | 生成一致性快照到 `data/backups/`（合并 WAL，保留最近 14 份） |
| `npm run backup:status` | 查看各备份目标：最近一次备份时间 / 份数 / 占用 |

## 备份与恢复（短版）

- 备份是**三写**：`data/backups/`（保留 14）+ `D:\ompcb-backup`（30）+ `D:\BaiduSyncdisk\ompcb-backup`（30）。三处同一文件名、同一内容。
- 服务启动前 `serve.ps1` 会自动备一份；另有每日 12:00 计划任务 `OMPCB-Backup`。任一目标失败只告警，不影响服务和其余目标。
- **恢复**：`Stop-ScheduledTask -TaskName OMPCB` → 拿 `data\backups\` 最新一个 `.db` 覆盖 `data\ompcb.db` → 删掉残留 `data\ompcb.db-wal` 与 `-shm` → `Start-ScheduledTask -TaskName OMPCB` → 看 `/api/health`。
- 要改目标/份数：设 `OMPCB_BACKUP_MIRRORS="路径=份数;路径=份数"`（设成 `none` 可关闭异地副本），`OMPCB_BACKUP_KEEP` 改本地份数。

## 部署（Windows 内网自用）

**这个项目不能纯静态部署。** 前端所有数据都来自 `/api/*`，而 `better-sqlite3` 是跑在服务端的原生模块。只把 `dist/` 丢给 IIS / 对象存储的话，页面能打开但全是空的 —— 必须有 Node 进程在跑。

生产模式下 `server.js` 会自己托管 `dist/`（含 SPA fallback），所以前后端同源、单进程、单端口，不需要 IIS 或反向代理。

### 首次部署

```powershell
npm install
powershell -ExecutionPolicy Bypass -File scripts\install-autostart.ps1
Start-ScheduledTask -TaskName OMPCB
```

注册的是**计划任务**而非 Windows 服务：注册服务要管理员权限，计划任务在当前用户下不用提权，内网自用足够。触发器为「登录时启动」，已关掉电池/空闲/超时相关的默认限制（默认 3 天会被强杀）。

访问 `http://localhost:4000`，同一局域网内其他设备用本机 IP 同端口。

### 更新发布

改完代码**双击 `scripts\deploy-quick.bat`** 就行。

流程是 停服务 → （`npm install`）→ `npm run build` → 起服务 → 健康检查，跑完停在窗口里显示访问地址，失败也不会闪退。

| 双击 | 场景 |
|---|---|
| `scripts\deploy-quick.bat` | **日常发布**，跳过 `npm install`，只改源码时用 |
| `scripts\deploy.bat` | 完整发布，改过 `package.json` / 换过机器时用 |

命令行调用可带参数：

```powershell
scripts\deploy.bat -Pull            # 先 git pull 再构建
scripts\deploy.bat -SkipInstall     # 等价于 deploy-quick.bat
```

### 脚本

| 脚本 | 作用 |
|---|---|
| `scripts\deploy-quick.bat` | **日常发布**，双击即可 |
| `scripts\deploy.bat` | 完整发布（含 `npm install`），双击即可 |
| `scripts\deploy.ps1` | 发布逻辑本体，上面两个 bat 都是它的壳 |
| `scripts\serve.ps1` | 前台启动，排错看报错用；启动前自动备一份数据库 |
| `scripts\install-autostart.ps1` | 注册自启，加 `-Uninstall` 卸载 |
| `scripts\restore-autostart.ps1` | 换机器 / 项目路径变更后的首次启用：注册计划任务后交由 `deploy.ps1` 完成发布 |
| `scripts\check-status.ps1` | 探活：`/api/health` 状态码、计划任务状态、4000 端口监听 |
| `scripts\install-backup-task.ps1` | 注册每日 12:00 备份计划任务 `OMPCB-Backup`，`-Uninstall` 卸载 |
| `scripts\backup-db.mjs` | 备份本体（`npm run backup` / `npm run backup:status` 都调它） |

### 几个坑

- **发布必须重新 `build`**。`serve.ps1` 只在 `dist/` 缺失时才构建，改了前端但 `dist/` 还在的话它不会重建，页面还是旧的。`deploy.ps1` 是无条件重建。
- **install 前必须停服务**。运行中 `better-sqlite3` 会锁住 `.node` 文件，`npm install` 会因文件占用失败。`deploy.ps1` 已处理，还会按端口清理残留的 node 子进程（`Stop-ScheduledTask` 只杀 powershell 宿主，node 可能活着占住端口）。
- **换机器不能拷 `node_modules/`**。`better-sqlite3` 是原生模块，必须在目标机器重新 `npm install` 编译。
- **数据库不在仓库里**。`data/` 已 gitignore，首次启动自动建库并导入种子数据。迁移数据就停服务后拷 `data\ompcb.db`（`-wal`/`-shm` 不用拷）。换位置设 `OMPCB_DB` 环境变量。
- **PowerShell 脚本必须存成带 BOM 的 UTF-8**。PS 5.1 读无 BOM 的 UTF-8 会按 ANSI 解析，脚本里的中文会打乱成语法错误。
- **`.bat` 反过来：不能带 BOM，且必须 CRLF 换行**。CMD 会把 BOM 当成第一条命令的一部分；LF 换行会让它认错行边界，把注释行当命令执行。另外 CMD 按「读到该行时生效的代码页」解码每一行，`chcp 65001` 之前的行仍按 GBK 解析 —— 所以 `.bat` 里的注释一律用 ASCII，中文只出现在 `chcp` 之后的 `echo` 里。
- **没有任何鉴权**，所有 `/api/*` 包括出入库写操作都是裸奔的。仅限内网，别往公网映射。

## 核心设计

### 1. 字段归属：BOM 不存库存信息

BOM 只存"这块板需要什么"，库存相关的一律不落库，查询时动态关联：

```
BOM 自有   序号 名称 位号 封装 数量 制造商料号 制造商 供应商 供应商料号 备注
                                      ↓ 按 mfr_pn 匹配
库存带出   状态  库存  位置
计算得出   需求  缺料
```

表头带 `库` 标记的列来自库存台账，带 `算` 的是算出来的。BOM 的编辑弹窗里**没有**状态/库存/位置的输入框，只有一个只读的「库存关联信息」面板 —— 要改这些请去库存台账。

**为什么不存关联关系**：存了就要维护，库存一变就可能对不上。现在 `LEFT JOIN inventory ON m.mfr_pn = i.mfr_pn`，永远是最新的。

### 1.5 手动绑定后：四列显示库存值，原值 hover 可见

在 BOM 页点状态列可以打开弹框，从台账里挑一条同名同封装的记录**手动绑定**。绑完之后 **制造商料号 / 制造商 / 供应商 / 供应商料号** 四列显示所绑定那条库存记录的值，鼠标悬停显示导入时的原值。

这不违背 §1 —— **合并只发生在读取侧**。绑定接口只写 `mfr_pn` 一列，库存的 `mfr`/`supplier`/`supplier_pn` 绝不写进 BOM，表格看到的库存值来自 `selectWithStock` 带出的 `i.*` 别名。

三条口径：

| | |
|---|---|
| **只对绑定过的行生效** | 靠 `bound_at` 判定（NULL = 从未绑定）。按料号自动 JOIN 上的行不算 —— 那是系统推断，不是用户意图。导入完还没绑过任何东西，表格里就该和 Excel 里一字不差 |
| **库存值为空则回退 BOM 自有值** | 台账里 `supplier` 常常没填，显示成空等于凭空丢信息 |
| **原导入值存进 `src_*` 快照** | 绑定会覆盖 `mfr_pn`，原值除快照外无处可寻。四列各存一份：`src_mfr_pn` / `src_mfr` / `src_supplier` / `src_supplier_pn` |

**快照只在首次绑定时写**（`bound_at IS NULL`）。重复绑定只换料号、保留最初那份快照，否则第二次绑定会把上次绑上的库存料号当成"原值"存进去，越绑越偏。

**手改料号（`PUT /:id`）会清掉快照并把 `bound_at` 置回 NULL**，显示随之回落到 BOM 自有值 —— 手改之后库存值就不再是用户的意图了。`mode=replace` 的批量导入同样重置这两者。

**`src_*` 与 `bound_at` 绝不能进 `EDITABLE_COLUMNS`**。那份列表被导入的 `normalize()` 复用，进去了会在每次导入时被清成空串。

**表格显示与 CSV 导出共用同一套函数**（`web/bom-display.js`），因为导出是拿去下单的，必须和用户在界面上确认过的那份一致。原导入值刻意不进 CSV：同一概念出两列，收到表格的人不知道该按哪列下单。

表头用 `绑` 角标而非 `库`：这四列本身是 BOM 自有字段，出处逐行而异，沿用 `库` 会和「整列都来自库存」的既有含义冲突。绑定行的这四格用**紫色字**（`--c-bind`）标出「这格不是原始导入值」。刻意不用橙色 —— 橙色在本表里已专指缺料（缺料行橙底、缺料数字橙字），四列再用橙字会在缺料行上被读成"这几格也在报缺料"；紫色表内未用过，无歧义。

**加快照列之前就绑定过的老数据，原值已永久丢失**，hover 显示"（无原始记录）"。遵循项目惯例：不做猜测性回填。

**库存量不限制绑定。** 曾实现过「库存必须 > 50 才允许绑」（理由是换个本身也缺货的替代品等于没解决问题），按业务要求撤掉 —— 绑不绑是使用者的判断：先绑上再采购、或明知不够也要先记录关联，都是合理用法。弹框里只对库存不高于阀值的候选标 `低` 角标提示，按钮照常可点。阀值在 `server/bind-rules.js`，由 `GET /inventory/match` 随响应带出（前端不硬编码，避免两边说法不一致）。若将来要收紧，除了改阀值还必须在 `POST /materials/:id/bind` 加回后端守卫 —— 只在前端置灰不够，`/api/*` 没有鉴权。

### 1.6 库存关联弹框：明细展开看「这个料谁在用」

一条库存料号可能被多个产品的 BOM 同时引用，换料号之前需要知道会影响谁。弹框里每行候选左侧箭头可**展开明细**，显示该料号被哪些产品的哪些 BOM 行用到、各用多少、已领多少。

用**展开行**而不是二级弹框：弹框里再开弹框会丢掉「我正在挑候选」的上下文，展开让「候选 → 谁在用它」留在同一视线内，收起就回到原状。

**懒加载**，只在展开时请求（`GET /materials/usage?mfrPn=`），否则打开弹框就要为每条候选各发一个请求，而多数时候只想看其中一条。结果按**料号**缓存而非按库存 id：BOM 与台账只靠料号关联，同一料号的多条库存记录展开后必然是同一份用量。

按**产品**聚合成两层（产品 → 该产品下的 BOM 行）而不是平铺：用户的问题是「哪些产品会受影响」，产品是主语。真实数据里单个料号最多跨 2 个产品、2 行 BOM，所以不分页、不折叠，也不套嵌套表格（那会带来双层边框和内层滚动条）。

明细里的**已领量与 BOM 页同口径**：`-SUM(delta)` 净额，不能按 `type='出库'` 过滤 —— 已撤销的出库会被算成已领。

**踩过的坑**：`el-table` 的 `expand-change` 在 `type="expand"` 列上发出的第二个参数是**当前所有已展开行的数组**，不是布尔值（只有树形表格才发布尔）。当布尔用会导致「点开后收不回去」——数组恒为真（`Boolean([]) === true`），于是 key 只增不减。展开态一律以那个数组为准，逻辑抽到 `web/expand-keys.js` 并由 `test/expand-keys.test.js` 锁住。

### 2. 库存状态：由库存量派生

只有两种，不可手工设置：

| 条件 | 状态 | 颜色 |
|---|---|---|
| `stock > 0` | 正常 | 绿 |
| `stock <= 0` | 缺货 | 红 |

SQL 里用 `CASE WHEN stock > 0 THEN '正常' ELSE '缺货' END` 派生。表里那个旧的 `status` 列已废弃（保留仅为兼容旧数据），接口不读不写它 —— 存成列必然和 `stock` 不一致。

### 3. 库存只能通过出入库变动

`PUT /api/inventory/:id` **不接受** `stock` 字段。库存变动只有一个入口：

```
POST /api/inventory/:id/move   { type, qty, remark }
```

- `入库` — 库存 + qty
- `出库` — 库存 − qty（不足则拒绝）
- `盘点` — 库存直接设为 qty（实盘数为准）

每次变动都在 `inventory_log` 落一条流水，带 `delta` 和 `stock_after` 快照。这样库存和流水永远一致，账目可追溯。盘点结果与账面相同时 `delta=0` 也记录，留下盘点痕迹。

### 4. 缺料算法

```
需求 = 数量 × 套数
缺料 = max(需求 − 可用库存, 0)
```

套数在工具栏可改，默认 1 套。

**未匹配到库存、或库存台账里查无此料的，可用库存按 0 算** —— 所以这些行也会算出缺料。否则显示 `—` 就不知道要买多少了。库存列对这类行显示灰色 `0` 并附说明，区别于"确实有 0 件"。

### 5. 产品隔离

BOM 按产品组织。位号唯一约束是**产品内唯一**（`UNIQUE(product_id, designator)`），所以两块板都用 `R1` 不会冲突。

批量导入的 `mode=replace` 按**位号对账**更新当前产品的 BOM：位号已存在则原地 UPDATE 保留 id，新位号 INSERT，本次导入中消失的位号 DELETE。不再是「全删再插」，所以重导入不会让 BOM 行拿到新 id，行级焊接进度得以保留。产品隔离性质不变，仍然只影响当前产品。删除还挂着 BOM 的产品会被拦下（409），需显式确认才连带删除。

### 6. 已焊接追溯：出库 ↔ BOM 行绑定

库存台账出库时可以绑定到 BOM 清单的具体行，产品据此知道每一行料是否已经领用焊接。

**绑定粒度是 BOM 行级，不只是产品级。** `inventory_log` 已有 `product_id`（只能回答"这批料为哪个产品领的"），新增 `material_id`（BOM 行 id），能回答"哪一行料已经领用焊接"。

**出库即视为已焊接。** 没有独立的焊接状态字段或焊接时间。撤销出库会自动回退进度。

**已焊接量按 `-SUM(delta)` 净额聚合，而不是 `WHERE type='出库'`。** 原因：撤销出库产生的是同 `material_id` 的正 delta 入库补偿行，净额自动归零。按 type 过滤、或按 `revokes_log_id IS NULL` 反连接，都会把已撤销的出库算成已焊接——因为原出库行自己的 `revokes_log_id` 就是 NULL。净额求和还天然兼容将来的部分撤销。

**关键不变量：`material_id` 只允许写在出库行及其撤销补偿行上，绝不写入入库/盘点/初始行。** 因为盘点的 delta 可正可负，会污染上面那个净额求和。单件出库接口因此只在 `type==='出库'` 时接受绑定参数，其他类型直接返回 400。

**产品绑定是可选的，默认不绑。** 必须保留样品/损耗/调拨这类没有产品归属的出库场景。不传绑定参数时行为与以前完全一致。

**`product_id` 和 `material_id` 两个列刻意冗余共存。** BOM 行被删除后 `material_id` 会悬空（无外键），此时行级进度自然不再统计该条流水，但 `product_id` 仍在，产品级汇总依旧正确。若改成从 material 反查产品，BOM 行一删就彻底丢失产品上下文。

**进度显示用绝对件数「已焊接 N 件」，不做比率。** 因为套数选择器是个计划输入而非承诺目标——用户领了 2 套后把选择器改成 5 套，比率会从 100% 掉到 40%，而现实中什么都没发生。

## 目录结构

```
server/
  server.js              Express 入口，挂 3 个路由
  search.js              关键词分词 + 等价字符归一（搜索与同规格匹配共用）
  bind-rules.js          手动绑定的库存提示阀值（仅提示，不禁用）
  db/
    index.js             开库 + 建表 + 首次启动的自动迁移
    schema.sql           建表 DDL（幂等，可重复执行）
    seed.js / seed.tsv   种子数据（75 行 AGB 主板 BOM）
    migrate-products.js  给 materials 加产品维度
    migrate-inventory.js 从 BOM 抽取初始库存台账
    migrate-log-material.js 给 inventory_log 加 BOM 行绑定（已焊接追溯）
    migrate-materials-bind.js 给 materials 加绑定前原值快照（见核心设计 §1.5）
  routes/
    materials.js         BOM 明细（含库存动态关联）
    inventory.js         库存台账 + 出入库流水
    products.js          产品 CRUD + 每产品汇总
web/
  App.vue                Tab 外壳
  api.js                 fetch 封装
  designator.js          位号解析（纯函数，可单测）
  bom-display.js         绑定行的四列显示口径（表格与 CSV 共用）
  expand-keys.js         el-table 展开行 key 同步（事件载荷是数组不是布尔，见文件注释）
  components/
    BomPanel.vue         BOM 页容器
    ProductSelectBar.vue 产品下拉 + 新建/重命名/删除
    MaterialTable.vue    BOM 表格
    MaterialFormDialog.vue
    BomStatsStrip.vue
    InventoryPanel.vue   库存页容器
    InventoryTable.vue
    InventoryFormDialog.vue
    StockMoveDialog.vue  出入库/盘点
    InventoryLogDrawer.vue
    InventoryStatsStrip.vue
    BulkImportDialog.vue 通用 TSV 粘贴导入（列可配置）
test/                    node:test，跑在临时库上
data/ompcb.db            SQLite 数据文件（已 gitignore）
```

## API

前缀 `/api`。开发时 Vite 代理到 `localhost:4000`。

### 产品 `/products`

| | |
|---|---|
| `GET /` | 列表，带每产品 BOM 行数/匹配数/缺料统计 |
| `GET /:id` | 单个 |
| `POST /` | 新建，`code` 必填且唯一 |
| `PUT /:id` | 改（含重命名） |
| `DELETE /:id?withBom=1` | 删除，有 BOM 时需 `withBom=1` |

### BOM 明细 `/materials`

| | |
|---|---|
| `GET /` | 列表。`productId` `q` `status` `matchState` `solderState` `sets` `sortBy` `page` `pageSize`；每行带 `solderedQty` 已焊接量 |
| `GET /stats` | 汇总。`productId` `sets`；含 `solderedLines` 已焊接行数、`solderedQty` 总焊接件数 |
| `GET /:id` | 单条 |
| `GET /usage?mfrPn=` | 某料号被哪些产品的哪些 BOM 行用到（按产品聚合，供库存关联弹框的明细展开用；见核心设计 §1.6） |
| `POST /` | 新增，必须带 `product_id` |
| `PUT /:id` | 局部更新（不接受 status/stock/location）；改 `mfr_pn` 会清掉绑定快照 |
| `DELETE /:id` | 删除 |
| `POST /:id/bind` | **手动绑定**库存记录。`{ mfr_pn }`，该料号须在台账里存在；见核心设计 §1.5 |
| `POST /bulk` | 批量导入，必须带 `productId`；`mode` = `append`/`replace` |

`POST /:id/bind` 与 `PUT /:id` 都会写 `mfr_pn`，但**语义相反**：绑定要留原值快照，手改要清掉快照。所以必须是两个端点 —— 走同一个就分不出是谁在改。响应带 `firstBind` 标明这次是否写了快照。

`matchState`：`matched` 已关联 / `unmatched` 未匹配 / `shortage` 缺料

`solderState`：`unfinished` 未焊完 / `done` 已焊完 / `over` 超领

判定基准是**需求量（用量 × 套数）**而不是单板用量 —— 领料本来就按套领，做 2 套时领满 2×用量才算焊完。所以和缺料筛选一样，这个筛选结果会随工具栏套数变化。`qty=0` 的行需求为 0，没领过时归入「已焊完」（不需要的料确实不用焊）。

实现上用的是自包含标量子查询而非列表里那个 `LEFT JOIN` 别名：列表与分页 `COUNT` 共用同一份 `WHERE`，而 `COUNT` 查询只 join 了 `inventory`、没有 soldered 派生表，引用别名会直接 SQL 报错。

### 库存台账 `/inventory`

| | |
|---|---|
| `GET /` | 列表。`q` `status` `location` `hasLocation` `inStock` `sortBy` `page` `pageSize` |
| `GET /stats` | 汇总 |
| `GET /locations` | 已用位置去重列表 |
| `GET /match?name=&package=` | 按「名称 + 封装」严格相等查同规格候选（供 BOM 绑定弹框）；带 `minBindStock` 库存偏低提示阀值，不过滤库存不足的候选 |
| `GET /logs` | 全局流水（带元件名） |
| `GET /:id` | 单条 |
| `GET /:id/logs` | 单个元件的流水（最近 200 条） |
| `POST /` | 新增。名称/供应商料号/制造商料号至少填一项 |
| `PUT /:id` | 局部更新（不接受 stock/status） |
| `POST /:id/move` | **出入库**。`{ type, qty, remark, productId?, materialId? }`；`productId`/`materialId` 仅 `type=出库` 时接受，其余类型返回 400 |
| `DELETE /:id` | 删除，流水级联清除 |
| `POST /bulk` | 批量导入。`mode` = `append`/`upsert`/`replace` |

`upsert` 按供应商料号合并：已存在则累加库存并补流水。

`location` 与 `hasLocation` 是两个维度：前者问「在哪一格」（精确匹配某个位置），后者问「归没归位」（`1` 只看已填位置的，`0` 只看没填的，空则不筛）。判空用 `TRIM(location) <> ''`，纯空格也算无位置。

## 数据库

3 张表，`schema.sql` 幂等，服务启动时自动执行。

```
products        产品
  code          产品编号，唯一
  name remark

materials       BOM 明细
  product_id    → products.id
  seq name designator package qty
  mfr_pn        关联库存的依据
  mfr supplier supplier_pn remark
  src_mfr_pn    ┐ 首次手动绑定前那四列的原导入值快照（见核心设计 §1.5）
  src_mfr       │ 绝不能进 EDITABLE_COLUMNS —— 那份列表被导入的 normalize() 复用，
  src_supplier  │ 进去了会在每次导入时被清空
  src_supplier_pn ┘
  bound_at      最近一次手动绑定的时间；NULL = 从未绑定（判定四列显示口径的唯一依据）
  UNIQUE(product_id, designator)   位号产品内唯一

inventory       库存台账
  name package mfr_pn mfr supplier
  supplier_pn   业务唯一键（空值不参与约束）
  stock         只能经 /move 变动
  location remark

inventory_log   出入库流水
  inventory_id  → inventory.id  ON DELETE CASCADE
  type          入库/出库/盘点/初始
  delta         +入库 / -出库
  stock_after   变动后快照，便于对账
  remark
  product_id    这次出库是为哪个产品领的料（手工出入库时为 NULL）
  revokes_log_id 撤销出库时的反向补偿行指回原出库行，普通流水为 NULL
  material_id   出库领料绑定的 BOM 行 id（见核心设计 §6），只写在出库行及其撤销补偿行上
```

**没有迁移框架**。schema 变更靠 `schema.sql` 的 `CREATE TABLE IF NOT EXISTS` + `db/migrate-*.js` 里的幂等 `ALTER`。加列时照 `migrate-products.js` 的写法：先 `PRAGMA table_info` 自查，因为 SQLite 的 `ALTER TABLE ADD COLUMN` 不支持 `IF NOT EXISTS`。

### 首次启动做的事

1. 执行 `schema.sql` 建表
2. `materials` 空 → 导入 `seed.tsv`（75 行）
3. `migrateProducts()` — 补 `product_id` 列，把无归属的历史行归入默认产品 `AGB_CPU_03`，并把位号索引从全局唯一改为产品内唯一
4. `migrateMaterialsBind()` — 补 `src_*` 四列 + `bound_at`，记录手动绑定前的原导入值
5. `migrateLogProduct()` — 补 `product_id` 列，记录每次领料是为哪个产品出的
6. `migrateLogRevoke()` — 补 `revokes_log_id` 列，支持出库撤销
7. `migrateLogMaterial()` — 补 `material_id` 列，出库绑定 BOM 行以追溯已焊接进度
8. `inventory` 空 → 从 BOM 按料号去重抽取（同料号库存相加），落「初始」流水

都是幂等的，重启不会重复执行。

## 批量导入

粘贴 Excel 复制的 TSV。第一行是表头会自动跳过。

**BOM**（导入到当前选中的产品）：

```
序号  名称  位号  封装  数量  制造商料号  制造商  供应商  供应商料号  备注
```

**库存台账**：

```
名称  封装  制造商料号  制造商  供应商  供应商料号  库存  位置  备注
```

两边都**不含状态** —— 它是派生值。

## 注意

- `npm run seed` 会清空 `materials`，慎用
- `migrate-inventory.js --force` 会清空库存台账和全部流水后从 BOM 重建，慎用
- `data/ompcb.db` 已 gitignore，是本地运行时产物
- 用了 WAL 模式，`.db-wal` / `.db-shm` 一并忽略
- **备份不能直接拷 `data/ompcb.db`**：WAL 模式下真实数据大量在 `-wal` 里，单拷会得到落后/残缺快照。用 `npm run backup`（SQLite 在线备份 API，产物是 WAL 已合并的单文件）。默认**三写**：`data/backups/`（14 份）+ `D:\ompcb-backup`（30）+ `D:\BaiduSyncdisk\ompcb-backup`（30），任一目标失败只告警；`OMPCB_BACKUP_MIRRORS` 可改异地目标（`none` 关闭），`OMPCB_BACKUP_KEEP` 改本地份数。回滚 = 停服务 → 用备份覆盖 `data/ompcb.db` 并删掉残留 `-wal`/`-shm` → 起服务。
- 没有用户系统和权限，单人本地使用
- **`mfr_pn` 没有唯一约束**（只有 `supplier_pn` 有）。两条不同供应商、相同制造商料号的库存记录，在 `LEFT JOIN inventory ON m.mfr_pn = i.mfr_pn` 下会让 BOM 行重复。因此"已焊接量"必须先在子查询里 `GROUP BY material_id` 预聚合完再 LEFT JOIN，不能把 `inventory_log` 直接塞进现有联接，否则行数翻倍、数字也翻倍。
- **迁移之前的历史出库流水没有 `material_id`**，不会计入行级"已焊接"统计（产品级汇总仍包含它们）。遵循项目既有的"不做猜测性回填"惯例。
- **`mfr_pn` 没有唯一约束**这件事也影响 §1.5：若台账里有多条库存共享同一 `mfr_pn`，`LEFT JOIN` 会让绑定行重复，四列显示的是其中任意一条的 `mfr`/`supplier`。当前真实数据里没有这种共享组，暂不处理；真要处理得让绑定落 `inventory_id` 而不是料号，那是另一个量级的改动。
- **加 `src_*` 快照列之前就绑定过的 BOM 行，原导入值已永久丢失**，hover 显示"（无原始记录）"。同样不做猜测性回填。

## 测试

```bash
npm test
```

`node:test`（Node 20+ 内置），零额外依赖。**跑在 `%TEMP%` 下的临时库上，不会碰 `data/ompcb.db`**。详见 `test/README.md`。

## 授权

[MIT](LICENSE) © Leopisces
