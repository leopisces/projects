# PROJECT KNOWLEDGE BASE

**Updated:** 2026-10-30
**Branch:** main

## OVERVIEW
个人多项目仓库（无 workspace / 无 npm 分包）：3 个相互独立的项目放在同一 git 仓库，各自有独立 `.gitignore`、独立技术栈、独立 `AGENTS.md`。
**改哪个项目先读它的 `AGENTS.md`**——根文件只给交叉规则和高频坑。

| 项目 | 是什么 | 技术栈 | 版本 | 细节 |
|------|--------|--------|------|------|
| `inline-web-translator/` | Chrome MV3 扩展：网页正文 + 视频字幕逐句翻译 | 原生 ES5 JS/CSS，**无构建、无依赖** | 1.14.4 | `inline-web-translator/AGENTS.md` |
| `ompcb/` | PCB 打样物料管理：BOM 清单 + 库存台账，按 mfr_pn 关联 | Vue 3 + Element Plus + Vite 6 / Express 4 + better-sqlite3 | 1.0.0 | `ompcb/AGENTS.md`、`ompcb/CLAUDE.md` |
| `xw/` | 小歪机器人 v2：ESP32-S3 固件成品 + 3D 模型（纯交付物，无源码） | 二进制交付物 | 固件 0.0.56 | `xw/AGENTS.md` |

## STRUCTURE
```text
projects/
├── inline-web-translator/   # MV3 扩展（无 npm / 无构建）
│   ├── content.js           # 核心管线：收集/分句/攒批/缓存/字幕/悬浮层（1588 行，ES5 风格）
│   ├── bridge.js            # MAIN world：读 video.js / Brightcove 字幕轨
│   ├── background.js        # config.json 加载、Ark 后台转发、Google 翻译拦截
│   ├── early.js             # document_start：translate="no"、清 Google 翻译控件
│   ├── popup.html/js/css    # 设置弹窗
│   ├── content.css          # ppp-sent/ppp-trans、字幕悬浮层、hover tooltip
│   └── manifest.json        # MV3 权限与版本号（改发布必升）
├── ompcb/                   # 主力项目（102 个跟踪文件）
│   ├── server/              # Express API + SQLite（数据唯一来源）
│   ├── web/                 # Vue 3 前端（Tab 壳 App.vue，无路由；纯函数抽 web/*.js 供单测）
│   ├── test/                # node:test，跑 %TEMP% 临时库
│   ├── scripts/             # deploy*.bat/ps1、serve.ps1、backup-db.mjs、install-*.ps1
│   ├── docs/                # 开发规范.md + intent/ specs/ plans/ lessons/
│   └── data/                # 运行时 SQLite（gitignore，WAL）
├── xw/                      # 纯交付物（固件 bin + stp），无源码
│   ├── OpenDeskBotV2-firmware-0.0.56/   # bootloader/partitions/boot_app0/firmware .bin + README.txt
│   └── *.stp                            # 摄像头卡子、打印件模型（交付物，必须入库）
├── .gitignore               # 只管仓库根这一层（/ 前缀锚定）
└── README.md                # 三项目总览
```

## HARD RULES（跨项目，不可协商）
- **不主动 commit / push**：只有用户明确说「提交/推送」才执行，且先展示 diff 与 commit message 等确认。
- **不主动启动服务或跑 build**：除非用户要求（ompcb 的 `npm run dev` / `npm run build` 都算）。
- **`ompcb` 任何功能开发/修复必须走 AI-Native SDLC**：`docs/intent/<名称>.md` → `docs/specs/<名称>.md` → `docs/plans/<名称>.md`，用户逐段确认后才写代码；报告完成前跑 `npm test` 并贴输出。模板与检查清单见 `ompcb/docs/开发规范.md`。
- **`inline-web-translator` 每次发布改动同步升 `manifest.json` 的 `version`**。
- **密钥只进 gitignored 文件**：`inline-web-translator/config.json`（提交用空模板 `config.json.simple`）、`ompcb/.env`（模板 `.env.example`）；ompcb 的 `data/`、`dist/`、translator 的 `dist/` 都不入库。
- 各项目 `.gitignore` 自己管自己；根 `.gitignore` 只用 `/` 前缀锚定仓库根，避免误伤子项目同名文件。

## WHERE TO LOOK
| 任务 | 位置 |
|------|------|
| 网页正文/字幕翻译、引擎选择 | `inline-web-translator/content.js`（collect → processBlock → translateText） |
| 字幕轨读取（video.js/Brightcove） | `inline-web-translator/bridge.js`（`collectTracks` / `collectCues`） |
| Ark 请求转发 / config.json 加载 | `inline-web-translator/background.js`（`llmConfig` 侧 `llmRequest`） |
| BOM 查询、库存动态关联、统计 | `ompcb/server/routes/materials.js` |
| 出入库、流水、盘点、撤销 | `ompcb/server/routes/inventory.js` |
| 产品 CRUD 与汇总 | `ompcb/server/routes/products.js` |
| 表结构 / 迁移 / 种子 | `ompcb/server/db/schema.sql`、`migrate-*.js`、`seed.tsv` |
| BOM 表格与 CSV 口径 | `ompcb/web/bom-display.js`（界面与导出共用，禁止各写一套） |
| 备份 / 恢复 | `ompcb/scripts/backup-db.mjs`、`npm run backup:status` |
| 发布部署 | `ompcb/scripts/deploy-quick.bat`（日常）/ `deploy.bat`（改过 package.json） |
| 固件烧录说明 | `xw/OpenDeskBotV2-firmware-0.0.56/README.txt` |

## CODE MAP — inline-web-translator
（无 LSP；以下为 grep 函数清单）

| 符号/区域 | 位置 | 作用 |
|-----------|------|------|
| `start()` | content.js | 读取设置、中文页判定、启动 collect |
| `collect()` / `processBlock()` | content.js | 文本分组、分句、插入译文 |
| `translateText()` | content.js | memo/inflight、fast/prefetch/正文三类队列 |
| `runBatch()` / `serial()` | content.js | 攒批、优先级插队、限速与重试 |
| `prefetchVideoCues()` / `renderSubtitleOverlay()` | content.js | 字幕预取、时间轴匹配、悬浮层 |
| `llmConfig()` / `arkBackgroundRequest()` | content.js | 引擎配置；Ark 后台转发 |
| `collectTracks()` / `collectCues()` | bridge.js | 定位 video / video.js / Brightcove 播放器与字幕轨 |
| `loadConfigFile()` / `llmRequest` | background.js | config.json 加载、跨域请求代理 |

## CODE MAP — ompcb
| 区域 | 位置 | 要点 |
|------|------|------|
| 入口 | `server/server.js` | 挂 3 组路由；生产模式托管 `dist/`（含 SPA fallback） |
| 开库+迁移 | `server/db/index.js` | 建表 → seed（materials 空时）→ 幂等迁移 → 抽初始库存 |
| 搜索/同规格 | `server/search.js` | 关键词分词 + 等价字符归一 |
| 绑定阈值 | `server/bind-rules.js` | 仅提示不禁用，随 `GET /inventory/match` 带出 |
| 前端壳 | `web/App.vue` | Tab 切换，无 vue-router |
| 纯函数 | `web/{bom-display,expand-keys,designator,location,xlsx-import}.js` | 都被 `test/*.test.js` 锁住 |

## COMMANDS
```powershell
# inline-web-translator（无 npm、无测试，仅语法检查 + 手动验证）
node --check inline-web-translator\content.js
node --check inline-web-translator\bridge.js
node --check inline-web-translator\background.js

# ompcb（Node ≥ 20）
cd ompcb
npm run dev            # API :4000 + Web :5173
npm run dev:api        # 只起后端（--watch）
npm test               # node:test，临时库，不碰真实数据
npm run build          # → dist/（发布前必跑，serve.ps1 只在 dist 缺失时才构建）
npm start              # 生产：单进程单端口 :4000
npm run backup         # 一致性快照（WAL 已合并），三写：本地 14 + D:\ompcb-backup 30 + 百度同步盘 30
npm run backup:status  # 各目标最近时间/份数/占用
npm run seed           # 破坏性：清空 materials 重导入
```

## ANTI-PATTERNS（各项目最高频）
**inline-web-translator**
- 把 `ppp-trans` 注入 video.js/Brightcove 的 cue 节点（播放时被擦除，字幕忽隐忽现）。
- 从内容脚本直接 `fetch` 火山方舟（CORS 预检不允许 `authorization`），必须走 `background.js`。
- 翻译播放器控制栏/`.vjs-time-control`/时间显示；对中文字幕调用翻译（应被 `needsTranslation` 跳过）。
- 引入 npm/构建链、`eval`/远程脚本（MV3 CSP）、箭头函数/模板字符串/可选链（content.js 保持 ES5）。
- 恢复逐请求 `console.info` 日志（只留 `console.warn`）。

**ompcb**
- 已焊接量直接 join `inventory_log` → 行数/数字翻倍；必须按 `material_id` 子查询预聚合再 LEFT JOIN。
- 用 `WHERE type='出库'` 统计已焊接 → 已撤销的也被算成已领；必须用 `-SUM(delta)` 净额。
- 绑定（`POST /:id/bind`，留 `src_*` 快照）与手改（`PUT /:id`，清快照）混用同一端点。
- `src_*` / `bound_at` 进 `EDITABLE_COLUMNS`（导入 normalize() 会清空）。库存 `stock` 走 `PUT`（只能经 `/move`）。
- schema 直接 `ALTER TABLE ADD COLUMN`（SQLite 无 IF NOT EXISTS，先 `PRAGMA table_info` 自查）。
- 发布不 rebuild（页面还是旧的）；界面与 CSV 两套显示逻辑。
- 备份直接拷 `data/ompcb.db`（WAL 模式下真实数据在 `-wal` 里，必须走 `scripts/backup-db.mjs`）。

**xw**
- 给 `*.stp` / `*.bin` 加通配忽略规则（交付物必须入库）；提交 `build/`、`.pio/`、日志。

## NOTES
- `xw/OpenDeskBotV2-firmware-0.0.56/` 只有固件产物（ESP32-S3，deskbot_v2 板），**没有源码**；上游是 https://github.com/tudoom/OpenDeskBotV2。全量烧录地址：`0x0 bootloader.bin` / `0x8000 partitions.bin` / `0xe000 boot_app0.bin` / `0x10000 firmware.bin`。
- `ompcb` 单人本地工具、**无鉴权**，仅限内网，勿映射公网；备份不能与源数据同盘（见 `ompcb/docs/lessons/`）。
- `translator` 的 `bridge.js` 以 `world: "MAIN"` 注入，需要 Chrome 111+；Ark Base URL 必须 `/api/coding/v3`。
- 最近工作区状态（2026-10-26 起）：ompcb 备份三写落地（`0df1669` 起）；translator 停在 v1.14.4（DeepSeek 模型白名单，默认 `deepseek-flash`）。
