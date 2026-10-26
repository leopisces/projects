// test/helpers.js — 启动一个指向临时数据库的测试服务
//
// 关键：绝不碰 data/ompcb.db（你的真实数据）。
// 每次都用 %TEMP%/ompcb-test/ 下的新库，由 server/db/index.js 自动建表并
// 导入 seed.tsv 的 75 行种子数据 + 抽取库存台账，所以每个测试文件拿到的
// 都是一份干净且可预期的数据。
//
// 注意：ESM 模块有缓存，server/db/index.js 在首次 import 时就绑定了
// OMPCB_DB。因此每个测试文件只能调用 createTestServer() 一次
// （node:test 默认每个文件独立进程，天然满足）。
import { mkdirSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import { createServer } from 'node:net'

/** 找一个空闲端口，避免和 4000/5173 抢 */
function getFreePort() {
  return new Promise((resolve, reject) => {
    const srv = createServer()
    srv.listen(0, '127.0.0.1', () => {
      const { port } = srv.address()
      srv.close(() => resolve(port))
    })
    srv.on('error', reject)
  })
}

/**
 * 创建临时数据库 + 启动测试服务。
 * @returns {Promise<{ baseUrl: string, port: number, call: Function, cleanup: Function, db: object, dbPath: string }>}
 */
export async function createTestServer() {
  const dbDir = join(tmpdir(), 'ompcb-test')
  mkdirSync(dbDir, { recursive: true })
  const dbPath = join(dbDir, `test_${Date.now()}_${Math.random().toString(36).slice(2, 8)}.db`)

  // 必须在 import server/db/index.js 之前设置：它在模块顶层读这个变量
  process.env.OMPCB_DB = dbPath

  const { db } = await import('../server/db/index.js')
  const { default: express } = await import('express')
  const { default: materialsRouter } = await import('../server/routes/materials.js')
  const { default: inventoryRouter } = await import('../server/routes/inventory.js')
  const { default: productsRouter } = await import('../server/routes/products.js')

  const app = express()
  app.use(express.json({ limit: '5mb' }))
  app.get('/api/health', (req, res) => res.json({ ok: true }))
  app.use('/api/materials', materialsRouter)
  app.use('/api/inventory', inventoryRouter)
  app.use('/api/products', productsRouter)
  app.use((err, req, res, next) => {
    res.status(500).json({ error: err.message })
  })

  const port = await getFreePort()
  const baseUrl = `http://127.0.0.1:${port}`

  const server = await new Promise((resolve, reject) => {
    const s = app.listen(port, () => resolve(s))
    s.on('error', reject)
  })

  /** 轻量 fetch 包装：返回 { status, data }，非 2xx 不抛异常，方便断言错误码 */
  async function call(path, opts = {}) {
    const res = await fetch(baseUrl + path, {
      method: opts.method || 'GET',
      headers: opts.body ? { 'Content-Type': 'application/json' } : undefined,
      body: opts.body ? JSON.stringify(opts.body) : undefined
    })
    let data = null
    try {
      data = await res.json()
    } catch {
      /* 空响应体 */
    }
    return { status: res.status, data }
  }

  function cleanup() {
    server.close()
    // 刻意不删 db 文件：测试失败时可以直接打开临时库排查
  }

  return { baseUrl, port, call, cleanup, db, dbPath }
}