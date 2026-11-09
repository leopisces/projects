import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

/**
 * 浏览器直连模型 API 会被 CORS 拦（DeepSeek / 多数厂商都不放行 Origin）。
 * 这里把 /llm-proxy 反代到 DeepSeek，前端 apiBase 填 /llm-proxy/v1 即可同源调用。
 * dev 与 preview 都挂了代理；部署到别的静态目录时，需要用 nginx/本地反代提供同样的路径。
 */
const llmProxy = {
  '/llm-proxy': {
    target: 'https://api.deepseek.com',
    changeOrigin: true,
    secure: true,
    rewrite: (path) => path.replace(/^\/llm-proxy/, ''),
  },
}

export default defineConfig({
  // 相对路径：build 产物可以放在任意静态目录 / 子路径下直接用
  base: './',
  plugins: [vue()],
  // jeep-sqlite 是 Stencil 组件，预构建会把它的 loader 打散；sql.js 自带 wasm 也不能被重打包
  optimizeDeps: {
    exclude: ['jeep-sqlite/loader', 'jeep-sqlite', '@capacitor-community/sqlite'],
  },
  build: {
    // sql.js 的 wasm 约 660KB，作为单独资源输出而不内联成 base64
    assetsInlineLimit: 0,
  },
  server: { host: true, proxy: llmProxy },
  preview: { host: true, proxy: llmProxy },
})
