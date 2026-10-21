# Inline Web Translator

一个即装即用的 Chrome 扩展（Manifest V3）：自动识别网页中的**任意外语**（英文、德文、法文、日文、韩文等），逐句翻译为简体中文，并把译文直接显示在**每一句原文下方**，逐句对照，适合学习语言和查阅外文资料。

## 功能简介

- 逐句对照：一句外语 → 紧跟一行中文译文，句子之间严格一一对应
- 支持多语种：英文 / 德文 / 法文 / 西班牙文 / 日文 / 韩文等，源语言由翻译接口自动识别
- 自动跳过中文内容与代码/脚本，不会把已中文的页面再翻一遍
- 同句去重缓存，只翻译进入可视区域的段落，滚动时逐步加载
- **攒批请求**：多句合并成一次接口调用（最多 8 句 / 1200 字符），凑满或等待 600ms 即发送，返回后按句拆回
- **视频字幕实时翻译**：自动识别 YouTube / Bilibili / Video.js 等播放器的 DOM 字幕，字幕一出现立即单独翻译并显示在当前字幕下方，不攒批、不走视口排队，延迟约 40ms
- 请求串行限速（间隔 500ms），遇到 429/503 自动指数退避重试（2.5s 起，最多 4 次）
- 译文写入本地缓存（localStorage），刷新或再次访问同一页面不重复请求
- 动态加载内容（无限滚动、SPA 切换）自动跟进翻译
- 中文页面默认整页跳过（依据 `<html lang>` 与正文汉字占比），不干扰中文网站
- 自动屏蔽网页自带的 Google 翻译（网络拦截 + 页面清理 + `notranslate` 标记），避免它把译文改回英文
- 两种翻译引擎可选：Google 翻译（免费）或 DeepSeek 大模型（需 API Key，可在弹窗中填写）
- 工具栏弹窗可一键开关翻译（译文固定为简体中文）

## 安装步骤

1. 打开 Chrome，地址栏输入 `chrome://extensions` 并回车
2. 打开右上角的「开发者模式」
3. 点击「加载已解压的扩展程序」
4. 选择本目录（`D:\Users\19098\Desktop\ppp`）
5. 工具栏出现扩展图标即安装成功（可点击图钉固定到工具栏）

## 打包为 .crx（正式安装 / 分发）

本目录已是完整可打包的扩展，无需任何构建步骤：

1. 打开 `chrome://extensions`，开启右上角「开发者模式」
2. 点击「打包扩展程序」
3. **扩展程序根目录** 选择 `D:\Users\19098\Desktop\ppp`
4. 「私有密钥文件」选择 `dist\ppp.pem`（首次打包可留空自动生成，之后必须固定使用同一个）
5. 打包完成后在上级目录生成 `ppp.crx`，放入 `dist` 文件夹
6. 安装 `.crx`：Windows 版 Chrome 会强制停用非应用商店来源的扩展（开关灰色、无法启用），需要配合企业策略或上架应用商店；个人自用请使用上面的「加载已解压」

> 注意：后续更新必须使用同一个 `.pem` 签名，否则 Chrome 会视为不同扩展导致覆盖安装失败。打包前建议把 `dist` 临时移出项目目录，避免把旧包和私钥一起打进新包。

## 本地配置文件 config.json

DeepSeek 的 API Key 不从弹窗输入，而是读取扩展目录下的 `config.json`（与 `manifest.json` 同级）：

```json
{
  "deepseekApiKey": "sk-你的key",
  "provider": "deepseek",
  "model": "deepseek-flash"
}
```

- `deepseekApiKey`：必填，填入你的 DeepSeek Key
- `provider`：默认引擎，`deepseek` 或 `google`；弹窗里的手动选择优先
- `model`：`deepseek-flash`（默认，快且便宜）或 `deepseek-v4-pro`

修改后需在 `chrome://extensions` 点击扩展的刷新按钮，再刷新网页。

> 安全提示：Key 会随扩展目录一起被打进 `.crx`，不要把填了 Key 的包分发给别人，也不要提交到公开仓库。

## 使用方法

- 打开任意外语网页（英文维基百科、德语新闻、法语博客等）
- 页面加载后，每个外语句子下方会自动出现一行小字中文译文，颜色略淡，不抢原文视线
- 阅读顺序：原句 → 对应译文 → 下一句原句 → 对应译文
- 点击工具栏扩展图标：
  - **启用翻译**：总开关，关闭后隐藏全部译文，开启后恢复并继续翻译新内容
  - **翻译引擎**：可选 Google 翻译（免费）或 DeepSeek AI
  - **屏蔽网页 Google 翻译**：默认开启，阻止网站嵌入的 Google 翻译把页面改回英文
  - **中文页面自动跳过**：默认开启，检测到中文网站时整页不翻译；需要翻译中文站里的英文内容时关闭它
- 选择 DeepSeek 前，先在扩展目录的 `config.json` 里填入 `deepseekApiKey`，保存后在 `chrome://extensions` 点击刷新
- 所有外文内容固定翻译为简体中文

## 原理简述

- 基于 Manifest V3 的 content script，在 `document_idle` 时注入页面
- 用 `TreeWalker` 收集文本节点，按最近的块级祖先（p/div/li/h1-h6/td 等）分组
- 用正则把每个块拆成句子（支持 `.` `!` `?` 与 `。！？`），逐句判断是否需要翻译
- 语言判断：统计 Unicode 字母占比与汉字占比——汉字占比 > 60% 视为中文并跳过，其余外语逐句翻译
- 每句单独调用谷歌免费翻译接口 `translate.googleapis.com/translate_a/single`（`sl=auto`，无需 API Key）
- `IntersectionObserver` 只翻译进入视口（含 400px 预加载边距）的段落，避免一次性打满接口
- 每句先进入批量队列，最多 8 句 / 1200 字符用换行拼接成一次请求，返回后按换行拆回；拆不开时自动降级为逐句请求
- 所有请求串行执行、间隔 500ms；返回 429/503 时全局冷却并按 2.5s×2ⁿ 指数退避重试
- 译文按句子缓存在内存与 `localStorage`，相同句子跨页面复用
- 原文按句子切分并包裹为自定义标签 `<ppp-sent>`，译文写入紧邻的 `<ppp-trans>`（`inline-block` 占满整行，自动换行到句子下方）
- `MutationObserver` + 300ms 防抖处理动态新增内容
- 通过常见播放器字幕选择器与「类名含 subtitle/caption 且祖先含 `<video>`」的通用规则识别字幕块；字幕块跳过 `IntersectionObserver` 与攒批，`MutationObserver` 对字幕变更只用 40ms 防抖并立即单条请求，占位译文已被播放器移除时不再发送请求
- 页面级语言检测：`<html lang>` 以 `zh` 开头，或正文采样中汉字占字母总数 30% 以上，则判定为中文页面并整页跳过
- `early.js` 在 `document_start` 注入：给 `html` 打上 `translate="no"` / `notranslate`，清除 `googtrans` Cookie，并持续移除 Google 翻译控件与横幅
- 后台 Service Worker 通过 `declarativeNetRequest` 动态规则拦截 `translate_a/element.js` 与 `translate-pa.googleapis.com`
- 我们插入的每个句块与译文都带 `translate="no"`，任何残留翻译器都不会再改动它们
- 选择 DeepSeek 时改为调用 `api.deepseek.com/chat/completions`，模型 `deepseek-flash`（关闭思考模式，`temperature: 0`），多句用换行拼接后一次翻译，返回按行拆回；行数不匹配时自动二分重试或降级逐句
- `chrome.storage.sync` 保存开关状态、引擎选择等偏好；API Key 由后台从 `config.json` 读取后缓存到 `chrome.storage.local`

## 注意事项

- 翻译请求走公网谷歌翻译接口，需要网络能访问 googleapis.com；句子较多时请求量较大，可能被限流
- 中文网站里如果有想对照阅读的英文文章，关闭「中文页面自动跳过」即可
- 如果页面在本插件生效前已经被网站自带的翻译改过，刷新一次页面即可恢复
- DeepSeek 引擎会消耗你账号的 token 额度；API Key 保存在本地 `config.json`，不会上传到任何第三方
- 涉及敏感信息的页面（网银、内部系统等）建议关闭翻译开关
- 仅支持以 DOM 元素渲染的字幕（YouTube、Bilibili、Video.js 等）；浏览器原生 `<video><track>` 字幕渲染在浏览器内部，扩展无法读取和翻译
- 首次安装后，已打开的页面需刷新一次才生效
