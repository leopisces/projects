// 把运行时事件实时上报到电脑上的诊断服务（同一 WiFi）。
// 手机上没法看控制台，靠这个把真实日志带回电脑。
const HOST = '192.168.0.107:8787'
const ENDPOINT = `http://${HOST}/log`
export const BUILD = 'v13'

export function report(type, data = '') {
  try {
    const body = JSON.stringify({ build: BUILD, type, data: String(data ?? '').slice(0, 400) })
    // 用 image beacon 兜底不必要，fetch keepalive 足够
    fetch(ENDPOINT, { method: 'POST', body, keepalive: true }).catch(() => {})
  } catch {
    /* 上报失败绝不能影响主流程 */
  }
}

export function installReportHooks() {
  window.addEventListener('error', (e) => {
    report('window-error', `${e.message} @ ${e.filename}:${e.lineno}`)
  })
  window.addEventListener('unhandledrejection', (e) => {
    report('unhandled-rejection', e.reason?.stack || e.reason?.message || String(e.reason))
  })
  report('boot', `${navigator.userAgent.slice(0, 120)}`)
}
