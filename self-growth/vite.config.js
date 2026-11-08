import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  // 相对路径：build 产物可以放在任意静态目录 / 子路径下直接用
  base: './',
  plugins: [vue()],
  server: { host: true },
})
