# self-growth · 成长账本

**Updated:** 2026-11-08
**版本:** 0.1.0（v2 数据模型）

## OVERVIEW
个人向「成长记账」PWA：把每天做的事用一句话记下来，交给大模型判定**成长维度 + 分数**，累计成成长值与等级。
纯前端、无后端、无账号，数据只在本机 `localStorage`。定位是**只记不罚**——负向行为只打标记不扣分。

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
│   ├── store.js              # 全部状态与统计（reactive + localStorage 节流写入）
│   ├── dimensions.js         # 五维定义、挑战等级轴、分值档位
│   ├── App.vue               # 顶栏 + 四个 Tab（无路由）
│   └── components/           # LogPage / HistoryPage / StatsPage / MinePage
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
npm install          # 依赖只有 vue + vite
npm run dev          # 开发 :5173
npm run build        # → dist/（含 rulebook.md 拷贝）
npm run preview      # 预览产物

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
| `src/store.js` 平台分支 | `Capacitor.isNativePlatform()` 为真时 `apiBase` 强制绝对地址（APK 没有 vite 反代） |
| `capacitor.config.json` | `CapacitorHttp.enabled=true`：把 fetch/XHR 转原生请求，APK 内绕过 CORS |
| `vite.config.js` | `/llm-proxy` → `https://api.deepseek.com`，`rewrite` 掉前缀；dev 与 preview 共用同一份 `llmProxy` |
| `src/llm.js` | `scoreWithLLM(text, settings, { rulebook })`；`parseJsonLoosely()` 容忍 ```json 围栏；失败抛 `ScoreError` |
| `src/store.js` | `addScoredEntry()` 处理同类上限与负向；`monthStats()` 出月度账本；`dimensionTotalsBetween()` 供能力图环比 |
| `src/components/StatsPage.vue` | 能力雷达（实线本期 / 虚线上期）+ 月度账本日历 + 14 天柱状 |
| `src/components/MinePage.vue` | 规则文档可编辑覆盖，存 `settings.rulebookOverride`，可恢复内置版 |

## ANTI-PATTERNS
- 把评分规则写死在代码或提示词字符串里（应改 `public/rulebook.md`）。
- 直接在组件里 `localStorage.setItem`（统一走 `store.js` 的节流 watch）。
- 负向行为扣分（体系明确「只标记不扣分」）。
- 雷达图按绝对值缩放导致空数据全塌成一点（用 `dimMax` 且最小 0.04 兜底）。
- 改完 `entries` 字段结构却复用旧 `STORAGE_KEY` 且不加 `normalize()` 兜底 → 老数据 NaN。
- 在 APK 里留 `/llm-proxy` 相对路径（无反代必失败，必须绝对地址 + CapacitorHttp）。

## NOTES
- 默认模型：DeepSeek `deepseek-chat`，`apiBase = /llm-proxy/v1`（走 vite 反代）；换厂商只改 `config.local.js` 的 `apiBase` / `model`。
- 模型会自称返回 `deepseek-flash`（服务端路由结果），不影响调用。
- 演示数据可直接写 `localStorage['self-growth.v2']` 后刷新（Playwright 验证时用过）。
