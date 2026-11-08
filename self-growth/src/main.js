import { createApp } from 'vue'
import App from './App.vue'
import { hydrateNative } from './store.js'
import { installReportHooks } from './diag.js'
import './styles.css'

if (import.meta.env.DEV) installReportHooks()
createApp(App).mount('#app')

// APK 里用原生存储回灌数据（localStorage 在 WebView 里不可靠）
hydrateNative()
