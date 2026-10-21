# INLINE WEB TRANSLATOR — AGENT NOTES

## OVERVIEW
Chrome MV3 扩展：网页正文逐句翻译 + 视频字幕实时翻译。静态 JS/CSS，无构建步骤。

## FILE MAP
| 文件 | 职责 |
|------|------|
| `content.js` | 核心：文本收集、分句、攒批/串行翻译、缓存、字幕预取与悬浮层、hover tooltip |
| `bridge.js` | MAIN world 桥接：`videojs.getPlayer()` / `bc.getPlayer()` 读取字幕轨 |
| `background.js` | 读取 `config.json`；Ark 请求后台转发；DNR 拦截网页 Google 翻译 |
| `early.js` | `document_start`：`translate="no"`、清 Google 翻译控件 |
| `popup.html/js/css` | 设置弹窗 |
| `content.css` | `ppp-sent`/`ppp-trans`、字幕悬浮层、hover tooltip |
| `manifest.json` | MV3 权限、content scripts、版本 |
| `config.json.simple` | 空 Key 模板（可提交） |

## PAGE PIPELINE
```text
collect(root) → findBlockAncestor 分组 → IntersectionObserver 排队
→ processBlock → translateText → batchQueue/serial → memo/localStorage
→ 原文下方插入 ppp-trans
```
- 普通正文攒批：Google 8 条/600ms；LLM 12 条/800ms。
- `memo` 精确键 + `looseKey` 宽松键；空译文不缓存。
- 中文页面 `chinesePageSkip=true`：普通块跳过，字幕块仍处理。

## SUBTITLE PIPELINE
1. `bridge.js` 只取第一条 `kind=subtitles/captions && mode=showing` 的轨；忽略 metadata/隐藏轨。
2. `prefetchVideoCues` 预取未来 cue：DeepSeek/Ark 25s，Google 40s。
3. `processBlock(..., fast=true)` → `renderSubtitleOverlay`：译文写入播放器容器内的独立悬浮层，**不修改 cue DOM**。
4. `lookupCueTranslation` 按 `currentTime` + 文本相似度匹配已预取的 cue 译文。
5. 字幕防抖 40ms 且不被高频 DOM 变更重置；快速请求优先于预取/正文。
6. hover 模式只隐藏页面正文译文，字幕悬浮层始终显示。

## PROVIDERS
- `google`：直连 `translate.googleapis.com`，串行 500ms 间隔。
- `deepseek`：`api.deepseek.com/chat/completions`，`stream: true` 用于未命中的单条字幕；80ms 优先间隔。
- `ark`：`llmConfig()` → `/api/coding/v3/chat/completions`，默认 `ark-code-latest`；经 `background.js` 的 `llmRequest` 转发，非流式；不带 `thinking` 参数。
- 无 Key / 行数不匹配 / 请求失败 → 回退 Google 翻译。

## CONVENTIONS
- `content.js` 保持 ES5 风格；不引入箭头函数、模板字符串、可选链。
- 字幕请求使用 `translateText(text, { fast: true, el })`；预取使用 `{ prefetch: true }`。
- 预取/快速请求带 `priority`，由 `serial()` 插队；不要绕过 `requestGap`/`cooldownUntil`。
- 播放器 UI（`.vjs-control-bar`、`.vjs-time-control` 等）必须排除。
- Key 只在 `config.json`；提交物里只能有空模板。
- 每次改动升级 `manifest.json` 版本。

## ANTI-PATTERNS
- 把译文插回播放器 cue 节点（播放时会被擦除，造成忽隐忽现）。
- 直接 `fetch` Ark（页面 CORS 预检不允许 `authorization`）。
- 在中文页面上跳过整个 `activateCollect`（会连英文字幕一起丢掉）。
- 对中文字幕调用翻译（应被 `needsTranslation` 跳过）。
- 重新加入逐请求 `console.info` 日志（已明确移除）。
- 为了小改动引入 npm/构建链。

## VERIFY
```powershell
node --check content.js
node --check bridge.js
node --check background.js
```
手动检查：英文正文、中文页+英文字幕、中文页+中文字幕、播放/暂停字幕稳定性、悬停开关、Google/DeepSeek/Ark 切换、Ark 请求走后台。
