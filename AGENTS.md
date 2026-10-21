# PROJECT KNOWLEDGE BASE

**Generated:** 2026-10-21
**Branch:** main

## OVERVIEW
个人项目仓库。当前只有一个主要项目：Chrome Manifest V3 扩展 `inline-web-translator`，做网页正文与视频字幕翻译。原生 JS/CSS，无构建、无 npm 依赖。

## STRUCTURE
```text
projects/
├── inline-web-translator/   # MV3 扩展（细节见其 AGENTS.md）
├── .gitignore               # 排除 config.json、dist/、.omo/
└── README.md                # 总览
```

## WHERE TO LOOK
| 任务 | 位置 | 说明 |
|------|------|------|
| 页面翻译逻辑 | `inline-web-translator/content.js` | collect → processBlock → translateText |
| 字幕翻译/悬浮层 | 同上 + `bridge.js` | 预取、时间轴匹配、播放器外悬浮层 |
| 引擎/请求 | `content.js`、`background.js` | Google 直连；DeepSeek 直连；Ark 后台转发 |
| 配置读取 | `background.js` + `config.json.simple` | 真实 Key 只在 gitignored 的 `config.json` |
| 设置 UI | `popup.html/js/css` | 引擎、悬停、中文页策略、总开关 |
| 扩展细节 | `inline-web-translator/AGENTS.md` | 文件地图与管线 |

## CODE MAP
（无 LSP；以下为 grep 函数清单，引用中心度未测量）

| 符号/区域 | 位置 | 作用 |
|-----------|------|------|
| `start()` | content.js | 读取设置、中文页判定、启动 collect |
| `collect()` / `processBlock()` | content.js | 文本分组、分句、插入译文 |
| `translateText()` | content.js | memo/inflight、fast/prefetch/正文三类队列 |
| `runBatch()` / `serial()` | content.js | 攒批、优先级插队、限速与重试 |
| `prefetchVideoCues()` / `renderSubtitleOverlay()` | content.js | 字幕预取、时间轴匹配、悬浮层 |
| `llmConfig()` / `arkBackgroundRequest()` | content.js | 引擎配置；Ark 后台转发 |
| `resolveTracks()` / `collectCues()` | bridge.js | video.js/Brightcove 字幕轨读取 |
| `loadConfigFile()` / `llmRequest` | background.js | config.json 加载、跨域请求代理 |

## CONVENTIONS
- 无打包/无依赖；直接加载解压目录调试。
- `content.js` 保持现有 ES5 风格：`function` 声明、字符串拼接、分号；不要引入箭头函数、模板字符串、可选链。
- 任何发布改动同步升级 `manifest.json` 的 `version`。
- API Key 只放 `config.json`（已 gitignore）；`config.json.simple` 是提交用的空模板。
- 火山方舟跨域请求必须走 `background.js` 的 `llmRequest`；内容脚本直连会被 CORS 拦截。
- 字幕译文渲染在播放器级悬浮层，不写入播放器字幕节点。
- 中文页面：正文跳过，字幕块仍处理；字幕是否翻译由 `needsTranslation` 逐条判断。
- 控制台只保留 `console.warn` 错误提示；不要恢复逐请求日志。

## ANTI-PATTERNS
- 绝不提交 `config.json`、`dist/`（含 `ppp.pem`）、`.omo/`。
- 绝不把 `ppp-trans` 注入 video.js/Brightcove 的 cue 节点（播放时会被擦除）。
- 绝不翻译播放器控制栏、`.vjs-time-control`、时间显示（会破坏 video.js TimeDisplay）。
- 绝不从内容脚本直接请求火山方舟（CORS）。
- 绝不移除字幕的 `needsTranslation` 判断（中文字幕必须跳过）。
- 绝不让「悬停显示译文」隐藏视频字幕（字幕始终显示）。
- 绝不引入 `eval`/远程脚本（MV3 CSP）。

## COMMANDS
```powershell
node --check inline-web-translator\content.js
node --check inline-web-translator\bridge.js
node --check inline-web-translator\background.js
```
无自动化测试；手动验证：加载解压扩展 → 英文页、中文页+英文字幕、中文字幕、悬停开关、三种引擎。

## NOTES
- `bridge.js` 以 `world: "MAIN"` 注入，需要 Chrome 111+。
- 引擎：`google` / `deepseek` / `ark`；Ark Base URL 为 `/api/coding/v3`，默认模型 `ark-code-latest`。
- 字幕快速路径：40ms 防抖、整条 cue 翻译、DeepSeek/Ark 预取 25s、Google 40s。
- YouTube 内部字幕、图片字幕、浏览器原生 `<track>` 渲染可能无法读取/预取。
- 统计写入 `localStorage`（`ppp-sub-stats-v1`），当前不打印日志。
