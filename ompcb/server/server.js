import { existsSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import 'dotenv/config'
import express from 'express'
import { db } from './db/index.js'
import materialsRouter from './routes/materials.js'
import inventoryRouter from './routes/inventory.js'
import productsRouter from './routes/products.js'

const __dirname = dirname(fileURLToPath(import.meta.url))

const app = express()
// 批量粘贴导入可能较大，放宽 body 上限
app.use(express.json({ limit: '5mb' }))

app.get('/api/health', (req, res) => {
  res.json({ ok: true })
})

app.use('/api/materials', materialsRouter)
app.use('/api/inventory', inventoryRouter)
app.use('/api/products', productsRouter)

// 生产模式下由 Express 直接托管 Vite 构建产物；dist 不存在时不能让 dev 服务崩掉
const distDir = join(__dirname, '../dist')
if (process.env.NODE_ENV === 'production' && existsSync(distDir)) {
  app.use(express.static(distDir))
  // SPA history fallback：非 /api 的 GET 一律回 index.html
  app.get(/^\/(?!api\/).*/, (req, res) => {
    res.sendFile(join(distDir, 'index.html'))
  })
}

// 兜底错误处理
app.use((err, req, res, next) => {
  console.error('[ompcb] 未捕获错误:', err)
  res.status(500).json({ error: err.message })
})

const port = process.env.PORT || 4000
app.listen(port, () => {
  console.log(`[ompcb] API 已启动: http://localhost:${port}`)
  console.log(`[ompcb] 数据库文件: ${db.name}`)
})
