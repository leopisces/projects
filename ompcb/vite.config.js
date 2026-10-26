// Vite config for OMPCB frontend
//   - entry index.html at project root
//   - dev server on :5173 with /api proxy -> http://localhost:4000
//   - @ -> web/  (ESM-safe via fileURLToPath so JSON-style __dirname works)
import { fileURLToPath, URL } from 'node:url';
import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
  plugins: [vue()],
  root: '.',
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./web', import.meta.url)),
    },
  },
  server: {
    port: 5173,
    strictPort: false,
    proxy: {
      '/api': {
        target: 'http://localhost:4000',
        changeOrigin: true,
      },
    },
  },
  build: {
    outDir: 'dist',
    emptyOutDir: true,
  },
});
