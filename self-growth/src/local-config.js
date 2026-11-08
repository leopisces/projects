/**
 * 本地私有配置（含 API Key）—— 已被 .gitignore 排除，不会进仓库。
 * 通过 import.meta.glob 软加载：文件不存在时自动返回空对象，不影响 build。
 */
const mods = import.meta.glob('./config.local.js', { eager: true })

export const localConfig = mods['./config.local.js']?.default || {}
