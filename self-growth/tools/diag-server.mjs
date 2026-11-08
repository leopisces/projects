// 诊断日志服务：手机 App 通过局域网把日志 POST 到这里，电脑上实时看到。
// 用法：node tools/diag-server.mjs   → 日志写入 tools/diag.log
import http from 'node:http'
import fs from 'node:fs'
import path from 'node:path'

const PORT = 8787
const LOG = path.join(import.meta.dirname, 'diag.log')

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
}

http
  .createServer((req, res) => {
    if (req.method === 'OPTIONS') {
      res.writeHead(204, cors).end()
      return
    }
    if (req.method === 'GET') {
      res.writeHead(200, { ...cors, 'Content-Type': 'text/plain; charset=utf-8' })
      res.end(fs.existsSync(LOG) ? fs.readFileSync(LOG, 'utf8') : '(empty)')
      return
    }
    let body = ''
    req.on('data', (c) => {
      body += c
      if (body.length > 200000) req.destroy()
    })
    req.on('end', () => {
      const line = `${new Date().toISOString()} ${body}\n`
      fs.appendFileSync(LOG, line)
      process.stdout.write(line)
      res.writeHead(204, cors).end()
    })
  })
  .listen(PORT, '0.0.0.0', () => {
    console.log(`diag server on http://0.0.0.0:${PORT} → ${LOG}`)
  })
