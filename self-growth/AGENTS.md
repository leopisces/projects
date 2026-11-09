# self-growth · 成长账本

**Updated:** 2026-11-08
**版本:** 0.1.0（v2 数据模型）

## OVERVIEW
个人向「成长记账」PWA：把每天做的事用一句话记下来，交给大模型判定**成长维度 + 分数**，累计成成长值与等级。
纯前端、无后端、无账号，数据只在本机：网页版 `localStorage`，APK 用 **SQLite**（双写，见 `src/storage-native.js`）。定位是**只记不罚**——负向行为只打标记不扣分。

设计依据全部在 `docs/体系设计.md`，**改规则前先读它**。

## STRUCTURE
```text
self-growth/
├── public/rulebook.md        # AI 评分规则（模型系统提示词，唯一事实来源，必须入库）
├── docs/体系设计.md           # 体系设计定稿：五维、打分、等级、数据模型、界面
├── src/
│   ├── rulebook.js           # 拉取 rulebook.md（含离线兜底提示词）
│   ├── local-config.js       # 软加载 config.local.js（缺失也 build 得出来）
│   ├── config.local.js       # 本地私有配置（含 API Key，**gitignored，绝不入库**）
│   ├── llm.js                # OpenAI 兼容打分 + 本地关键词降级 localScore()
│   ├── store.js              # 全部状态与统计（reactive + 双写持久化：localStorage/SQLite）
│   ├── storage-native.js     # SQLite 层：建表、整表事务写入、启动回灌、图片 blob 读写
│   ├── photos.js             # 图片：压缩 / 落库 / objectURL 引用计数
│   ├── dimensions.js         # 五维定义、挑战等级轴、分值档位
│   ├── App.vue               # 顶栏 + 五个 Tab（无路由）
│   └── components/           # LogPage / HistoryPage / CalendarPage / StatsPage / MinePage
│                             # + PhotoStrip（缩略图条）/ PhotoViewer（全屏看图）
├── public/assets/            # sql-wasm.wasm（npm run copy-wasm 生成，gitignored）
├── android/                  # Capacitor Android 工程（com.leopisces.growth，minSdk 24 / target 36）
├── assets/icon-only.png      # 1024 图标源（由 icon-src.html 渲染）→ npx @capacitor/assets generate
├── capacitor.config.json     # webDir: dist；plugins.CapacitorHttp.enabled=true
├── styles.css                # 单文件样式（暗色）
└── vite.config.js            # base: './'；/llm-proxy 反代 DeepSeek 绕 CORS（dev+preview）
```

## 核心链路
```
一句话输入 → resolveRulebook() 取规则文档 → scoreWithLLM()（system=规则文档）
          → 失败则 localScore() 降级（source='rule'）
          → 预览卡（可改维度/基础分/挑战系数）→ addScoredEntry()
          → 同类每日上限、负向不计分在此生效
```

## HARD RULES
- **打分口径只写在 `public/rulebook.md`**，不要往 `llm.js` 里塞判定规则；改口径 = 改文档。
- **API Key 只进 `src/config.local.js`**（已被 `.gitignore` 排除）或用户在界面里填的 localStorage；**永不入库、永不写进其他源码**。需换机器时另建该文件。
- **不要公开部署 `dist/`**：build 会把 Key 内联进产物 js。
- **数据模型变更必须升 `STORAGE_KEY` 或写迁移**：当前键 `self-growth.v2`，`normalize()` 负责补字段。
- **不引入后端/账号**：这是离线本地工具，加服务端会破坏定位。
- **枚举值收紧**：`dimension` 只能五选一，`challenge` 只取 1.0 / 1.3 / 1.6，`base` 整数 0–20。
- **`dist/` 与 `node_modules/` 不入库**（见 `.gitignore`）；`public/rulebook.md` 必须入库。

## COMMANDS
```powershell
cd self-growth
npm install          # 依赖：vue + vite + @capacitor/* + jeep-sqlite（网页端 SQLite）
npm run dev          # 开发 :5173（predev 自动拷 sql-wasm.wasm）
npm run build        # → dist/（含 rulebook.md + assets/sql-wasm.wasm）
npm run preview      # 预览产物
npm run copy-wasm    # 手动同步 wasm（predev/prebuild 已自动跑）

# ---- 打 APK（Capacitor，本机已装 JDK21 + Android SDK 36）----
npm run build && npx cap sync android      # 先 build 再拷进 android 工程
cd android && ./gradlew assembleDebug      # → app/build/outputs/apk/debug/app-debug.apk
```

环境：`JAVA_HOME=C:\Users\Leopisces\tools\jdk-21.0.13+9`、
`ANDROID_HOME=C:\Users\Leopisces\tools\android-sdk`（platform-tools + platforms;android-36 + build-tools;36.0.0）。
`android/local.properties` 的 `sdk.dir` **必须用正斜杠**（`C:/...`）——反斜杠会被 properties 当转义，
报 `java.io.IOException: 文件名、目录名或卷标语法不正确`。该文件机器相关，已 gitignore。
首次构建下载 Gradle 8.14.3（~200MB），之后增量约 1.5 分钟。

## 关键实现点
| 位置 | 要点 |
|------|------|
| `src/rulebook.js` | `loadDefaultRulebook()` 带内存缓存与 inflight 去重；`resolveRulebook(override)` 用户覆盖优先 |
| `src/local-config.js` | 用 `import.meta.glob('./config.local.js')` 软加载私有配置，文件不存在返回 `{}` |
| `src/storage-native.js` | 动态 import `@capacitor-community/sqlite`；表 `entries(id,ts,day,dimension,data)` + `kv(key,value)` + `photos(id,entry_id,mime,w,h,ts,blob)`，写入用 `executeSet(..., true)` 整表事务；`hydrateNative()` 启动回灌，库空时用现有数据播种；**网页端也走这里**（挂隐藏 `<jeep-sqlite wasmPath="assets">` + `initWebStore()`，写完调 `SQLiteConnection.saveToStore()`） |
| `src/photos.js` | `compressImage()` 长边≤1600/q0.72；`addPhotos()` 落库返回 id；`acquire()/release()` 做 objectURL 引用计数（不 release 会让 WebView OOM）；`MAX_PHOTOS_PER_ENTRY = 20` |
| `src/components/PhotoStrip.vue` | 缩略图条，`ids` 变化时自动 acquire/release，`removable` 时带 ✕ |
| `src/components/PhotoViewer.vue` | 全屏看图，← →/按钮翻页，Esc/✕ 关闭，卸载时统一 release |
| `src/store.js` 平台分支 | `Capacitor.isNativePlatform()` 为真时 `apiBase` 强制绝对地址（APK 没有 vite 反代） |
| `capacitor.config.json` | `CapacitorHttp.enabled=true`：把 fetch/XHR 转原生请求，APK 内绕过 CORS |
| `vite.config.js` | `/llm-proxy` → `https://api.deepseek.com`，`rewrite` 掉前缀；dev 与 preview 共用同一份 `llmProxy` |
| `src/llm.js` | `scoreWithLLM(text, settings, { rulebook })`；`parseJsonLoosely()` 容忍 ```json 围栏；失败抛 `ScoreError` |
| `src/store.js` | `addScoredEntry()` 处理同类上限与负向；`monthStats()` 出月度账本；`dimensionTotalsBetween()` 供能力图环比 |
| `src/components/StatsPage.vue` | 能力雷达（实线本期 / 虚线上期）+ 月度账本日历 + 14 天柱状 |
| `src/components/MinePage.vue` | 规则文档可编辑覆盖，存 `settings.rulebookOverride`，可恢复内置版 |

## ANTI-PATTERNS
- 把图片 base64 塞进 `entries` 字段（localStorage ~5MB + 每次全量 `JSON.stringify`，必卡死）。图片一律走 `photos.js` → SQLite blob，entry 只留 `photoIds`。
- 忘记 `release()` objectURL（一张 1600px 图解码后约 10MB 内存，滑几十条就 OOM 闪退）。
- 升级 `sql.js` 却不升 `jeep-sqlite`（或反之）：WASM 与胶水代码的 import 数不一致，报 `LinkError: WebAssembly.instantiate(): Import #34 "a" "I": function import requires a callable`。已用 `package.json` 的 `overrides: { "sql.js": "1.11.0" }` 锁住。
- 把评分规则写死在代码或提示词字符串里（应改 `public/rulebook.md`）。
- 直接在组件里 `localStorage.setItem`（统一走 `store.js` 的节流 watch）。
- 把 WebView `localStorage` 当 APK 的唯一存储（实测会丢：清缓存/系统回收连数据一起没）。
- 负向行为扣分（体系明确「只标记不扣分」）。
- 雷达图按绝对值缩放导致空数据全塌成一点（用 `dimMax` 且最小 0.04 兜底）。
- 改完 `entries` 字段结构却复用旧 `STORAGE_KEY` 且不加 `normalize()` 兜底 → 老数据 NaN。
- 在 APK 里留 `/llm-proxy` 相对路径（无反代必失败，必须绝对地址 + CapacitorHttp）。

## NOTES
- 默认模型：DeepSeek `deepseek-chat`，`apiBase = /llm-proxy/v1`（走 vite 反代）；换厂商只改 `config.local.js` 的 `apiBase` / `model`。
- 模型会自称返回 `deepseek-flash`（服务端路由结果），不影响调用。
- 演示数据可直接写 `localStorage['self-growth.v2']` 后刷新（Playwright 验证时用过）。
- APK 体积：sqlite 插件自带 4 个 ABI 原生库，`android/app/build.gradle` 里 `ndk { abiFilters 'arm64-v8a','armeabi-v7a' }` 把包从 14MB 压到 8.4MB。
- **打包必做**：`rm -rf android/app/src/main/assets/public` 后再 `npx cap sync android`。cap sync 会跳过未变化检测，实测出现过“sync 报成功但 APK 里 JS 仍是旧版”的情况（v10–v14 白折腾了好几轮）。每次打包后用 `grep -o 'assets/index-[A-Za-z0-9_-]*\.js' dist/index.html` 与 `android/app/src/main/assets/public/index.html` 比对，或直接 `python -c "import zipfile..."` 扫 APK 里的 bundle 名。
- 不再有启动 Toast（测试提示已按用户要求移除）；`MainActivity.onCreate` 里保留 `webView.clearCache(true)` 防止旧资源被缓存。
- 语音功能已弃用（用户机型没有可用语音引擎 + 调试成本高），`src/speech.js` 与 `@capacitor-community/speech-recognition` 已删除，录入只走打字。
- 诊断上报：`src/diag.js` 会把 boot/tap/diag 事件 POST 到 `192.168.0.107:8787`（`node tools/diag-server.mjs`，日志写 `tools/diag.log`），仅同一 WiFi 下有效，失败静默。
