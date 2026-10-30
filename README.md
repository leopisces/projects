# Projects

个人项目仓库，目前包含三个相互独立的项目（无 workspace，各自有 `.gitignore` 与 `AGENTS.md`）：

- **Inline Web Translator**：Chrome 扩展，把网页正文与视频字幕逐句翻译成简体中文，支持 Google、DeepSeek、火山方舟三种引擎。
- **OMPCB**：PCB 打样物料管理工具，BOM 清单与库存台账按制造商料号自动关联。
- **xw**：小歪机器人 v2 的交付物仓库（ESP32-S3 固件成品 + 3D 模型），无源码。

## 项目列表

| 项目 | 说明 | 技术栈 | 版本 | 详细文档 |
|------|------|--------|------|----------|
| [inline-web-translator](./inline-web-translator/) | Chrome Manifest V3 扩展：网页正文 + 视频字幕翻译 | 原生 JS/CSS，无构建 | 1.14.4 | [扩展 README](./inline-web-translator/README.md) |
| [ompcb](./ompcb/) | PCB 打样物料管理：BOM 清单 + 库存台账 | Vue 3 + Element Plus + Vite 6 / Express 4 + SQLite | 1.0.0 | [项目 README](./ompcb/README.md) |
| [xw](./xw/) | 小歪机器人 v2：固件成品 + 3D 模型（纯交付物） | ESP32-S3 固件 / STP 模型 | 固件 0.0.56 | [说明](./xw/AGENTS.md) |

> 各项目的开发规则在各自目录的 `AGENTS.md`（ompcb 另有 `CLAUDE.md` 与 `docs/开发规范.md`）；仓库级交叉规则见根 [`AGENTS.md`](./AGENTS.md)。

## 目录结构

```
projects/
├── inline-web-translator/     # Chrome 扩展源码（纯 JS，无构建步骤）
│   ├── content.js             # 页面/字幕核心管线、翻译引擎、悬浮层
│   ├── bridge.js              # MAIN world：读取 video.js / Brightcove 字幕轨
│   ├── background.js          # 配置加载、Ark 后台请求转发、Google 翻译控件拦截
│   ├── early.js               # document_start：notranslate / 清理 Google 翻译
│   ├── popup.html/js/css      # 设置弹窗
│   ├── content.css            # 译文、字幕悬浮层、hover tooltip 样式
│   ├── manifest.json          # MV3 配置与版本号
│   ├── config.json.simple     # 空 Key 配置模板（可提交）
│   └── icons/
├── ompcb/                     # PCB 物料管理（Node ≥ 20）
│   ├── web/                   # Vue 3 前端源码
│   ├── server/                # Express API、SQLite、schema.sql / seed.tsv
│   ├── test/                  # node --test 测试
│   ├── data/                  # 运行时 SQLite 数据库（gitignore，自动建库）
│   ├── scripts/               # 辅助脚本
│   └── package.json
├── xw/                        # 小歪机器人 v2：纯交付物，无源码/无构建
│   ├── OpenDeskBotV2-firmware-0.0.56/   # 固件 bin（0.0.56）+ 烧录说明 README.txt
│   └── *.stp                  # 摄像头卡子、打印件 3D 模型
├── .gitignore                 # 只管仓库根这一层（/ 前缀锚定）
└── README.md
```

每个子项目维护自己的 `.gitignore`：translator 排除 `config.json` 与 `dist/`；ompcb 排除 `node_modules/`、`data/`、`dist/`、`.env`；xw 只排除构建目录与临时文件（固件 bin 与 stp 必须入库）。

---

# Inline Web Translator

当前版本：**1.14.4**（见 `inline-web-translator/manifest.json`）

## 功能

- **网页正文逐句对照**：一句外语紧跟一句中文，按视口懒加载，多句攒批请求，同句缓存。
- **视频字幕实时翻译**：读取播放器字幕轨，提前 25–40 秒预取翻译；字幕出现时命中缓存，显示在播放器内的独立悬浮层。
- **中文网站适配**：中文页面默认只翻译视频字幕、跳过正文；中文字幕按语言判断自动跳过。
- **悬停显示译文**：可选开关；只影响页面正文，悬停时显示浅色 tooltip，不占原文下方空间。
- **播放器兼容**：过滤播放器控件/元数据轨，避免破坏 video.js、Brightcove 等播放器内部节点。
- **多引擎**：Google（免费）、DeepSeek、火山方舟 Coding Plan。

## 架构

| 文件 | 职责 |
|------|------|
| `content.js` | 文本收集、分句、翻译队列、缓存、字幕预取/悬浮层、hover 提示 |
| `bridge.js` | MAIN world 注入，读取播放器 `textTracks()` 的 cue，转发给内容脚本 |
| `background.js` | 读取 `config.json`；代理火山方舟请求（规避页面 CORS）；拦截网页自带 Google 翻译脚本 |
| `early.js` | 页面早期注入，阻止网站自带翻译改写文本 |
| `popup.*` | 引擎、悬停、中文页策略、总开关 |
| `content.css` | 页面译文、字幕悬浮层、tooltip |
| `manifest.json` | MV3 权限、content scripts、版本 |

### 页面流程

```
collect(root) → 按块级祖先分组 → IntersectionObserver 排队
  → processBlock → translateText → 攒批/串行请求 → memo 缓存
  → 在原文下方插入 ppp-trans
```

### 字幕流程

```
bridge.js 读取当前 showing 的 subtitles/captions 轨
  → content.js 预取未来 cue（DeepSeek/Ark 25s，Google 40s）
  → 整条 cue 翻译并写入缓存
  → 字幕出现时按时间轴/文本匹配命中
  → 渲染到播放器级悬浮层（不修改播放器字幕 DOM）
```

## 安装

1. Chrome 打开 `chrome://extensions`，开启右上角「开发者模式」。
2. 点击「加载已解压的扩展程序」，选择 `inline-web-translator/`。
3. 复制配置模板并按需填写 Key：

   ```powershell
   Copy-Item inline-web-translator\config.json.simple inline-web-translator\config.json
   ```

4. 在扩展弹窗选择翻译引擎；修改 `config.json` 后需在扩展页刷新。
5. 刷新目标网页。首次安装后，已打开的页面也需要刷新。

## 配置

`inline-web-translator/config.json`（与 `manifest.json` 同级，已被 gitignore）：

```json
{
  "deepseekApiKey": "sk-你的key",
  "provider": "deepseek",
  "model": "deepseek-flash",
  "arkApiKey": "ark-你的key",
  "arkModel": "ark-code-latest",
  "arkBaseUrl": "https://ark.cn-beijing.volces.com/api/coding/v3"
}
```

| 字段 | 说明 |
|------|------|
| `deepseekApiKey` | DeepSeek API Key |
| `provider` | 默认引擎：`google` / `deepseek` / `ark`；弹窗选择优先 |
| `model` | DeepSeek 模型：`deepseek-flash` 或 `deepseek-v4-pro` |
| `arkApiKey` | 火山方舟 Coding Plan API Key |
| `arkModel` | 默认 `ark-code-latest`，也可指定具体模型 |
| `arkBaseUrl` | 必须是 `/api/coding/v3`，不要用 `/api/v3` |

> 火山方舟请求由后台 Service Worker 转发，避免内容脚本直连被 CORS 拦截。

## 使用

弹窗选项：

- **启用翻译**：总开关。
- **翻译引擎**：Google / DeepSeek / 火山方舟。
- **悬停显示译文**：开启后页面正文译文隐藏，悬停原句时显示 tooltip；视频字幕不受影响。
- **屏蔽网页 Google 翻译**：阻止网页自带翻译把译文改回原文。
- **中文页面仅翻视频字幕**：默认开启；中文站的英文正文不翻，英文视频字幕仍翻译。

## 开发

- Manifest V3，原生 JavaScript/CSS，无 npm、无打包。
- 语法检查：

  ```powershell
  node --check inline-web-translator\content.js
  node --check inline-web-translator\bridge.js
  node --check inline-web-translator\background.js
  ```

- 版本号在 `manifest.json` 中维护；每次发布改动同步升级。
- 手动验证清单：
  1. 英文网页正文正常逐句翻译；
  2. 中文页面正文跳过、英文字幕翻译；
  3. 中文字幕不翻译；
  4. 悬停开关只影响正文；
  5. 播放/暂停时字幕译文稳定显示；
  6. Google / DeepSeek / 火山方舟切换正常。

## 已知限制

- 仅支持以 DOM 渲染的字幕；浏览器原生 `<video><track>` 字幕、图片字幕、YouTube 内部字幕可能无法读取。
- 播放器控制栏、时间显示等 UI 不翻译，避免破坏播放器内部引用。
- 全页翻译会消耗所选引擎的额度；中文页面默认只翻字幕可减少消耗。
- 火山方舟快速单条目前走后台非流式请求；预取命中的字幕仍然即时显示。
- 仅在本机保存配置与译文缓存，不上传账号信息。

## 安全

- translator：`config.json`、`dist/`（含 `ppp.pem` 私钥）、`.omo/` 已被 `.gitignore` 排除，请勿提交；仓库中的 `config.json.simple` 只保留空 Key。
- ompcb：`.env` 与 `data/` 不入库，`.env.example` 是模板；`data/ompcb.db` 含全部业务数据，外发前先脱敏。
- 若 Key 曾出现在聊天、日志或提交中，请到对应平台轮换。

---

# OMPCB

当前版本：**1.0.0**（PCB 打样物料管理，单人本地内网自用，**无鉴权**）。

两份台账按制造商料号（`mfr_pn`）自动关联：BOM 清单管「这块板要用什么」，库存台账管「手头有什么、放在哪」。BOM 不存库存信息，查询时 `LEFT JOIN` 动态带入。

```bash
cd ompcb
npm install          # Node ≥ 20
npm run dev          # API :4000 + Web :5173
npm test             # node:test，临时库，不碰真实数据
npm run build        # 发布前必跑
npm start            # 生产：单进程单端口 :4000
npm run backup       # 一致性快照（WAL 已合并），三写
```

- 开发必须走 AI-Native SDLC：`docs/intent` → `docs/specs` → `docs/plans` → 实现 → `npm test`，见 `ompcb/docs/开发规范.md`。
- 备份**不能直接拷 `.db`**（WAL 下真实数据在 `-wal`）；用 `scripts/backup-db.mjs`。
- 部署：`scripts/deploy-quick.bat`（日常）/ `deploy.bat`（改过 package.json）。
- 完整说明见 [ompcb/README.md](./ompcb/README.md) 与 [ompcb/AGENTS.md](./ompcb/AGENTS.md)。

---

# xw

小歪机器人 v2（ESP32-S3，`deskbot_v2` 板）的**交付物仓库**：不含源码、无构建、无依赖。

| 内容 | 说明 |
|------|------|
| `OpenDeskBotV2-firmware-0.0.56/` | 固件 0.0.56：`bootloader.bin`(0x0) / `partitions.bin`(0x8000) / `boot_app0.bin`(0xe000) / `firmware.bin`(0x10000) + 烧录说明 |
| `*.stp` | 摄像头卡子、打印件 3D 模型（交付物，必须入库） |

- 上游固件项目：<https://github.com/tudoom/OpenDeskBotV2>。
- 新增版本请**新建版本目录**、保留旧版（回滚依据），不要原地覆盖 bin。
- 烧录步骤见 `xw/OpenDeskBotV2-firmware-0.0.56/README.txt` 或 [xw/AGENTS.md](./xw/AGENTS.md)。

## 许可

个人项目，未声明开源许可证（默认保留所有权利）。如需复用请先联系作者。
