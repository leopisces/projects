/**
 * 图片层：选图 → 压缩 → 存 SQLite blob → 按需取 objectURL。
 *
 * 为什么不把图塞进 entries 的 JSON：
 *   网页版 localStorage 只有 ~5MB，且 store.js 的 persistNow() 每次全量
 *   JSON.stringify(state)，塞 base64 必卡死。所以图片单独进 SQLite 的 photos 表，
 *   entry 上只留 photoIds: string[]（几十字节）。
 *
 * objectURL 生命周期：一张原图 createObjectURL 后如果不 revoke，WebView/浏览器
 * 会一直持有解码后的位图（一张 1600px 图约 10MB 内存），滑动几十条就爆。
 * 这里做引用计数：retain → +1，release → -1，归零才 revoke。
 */
import { savePhotosNative, getPhotoNative, deletePhotosNative } from './storage-native.js'

/** 单条记录图片数量软上限（点错了不会存几百张） */
export const MAX_PHOTOS_PER_ENTRY = 20

/** 压缩参数：长边 1600、JPEG q0.72 → 一般 150–300KB，2~4 张约 1MB */
const MAX_EDGE = 1600
const QUALITY = 0.72

function newId() {
  if (globalThis.crypto?.randomUUID) return globalThis.crypto.randomUUID()
  return `p-${Date.now()}-${Math.random().toString(16).slice(2)}`
}

/** 把 File 压成 JPEG Blob；返回 { blob, w, h } */
export async function compressImage(file, { maxEdge = MAX_EDGE, quality = QUALITY } = {}) {
  const url = URL.createObjectURL(file)
  try {
    const img = await new Promise((resolve, reject) => {
      const el = new Image()
      el.onload = () => resolve(el)
      el.onerror = () => reject(new Error('图片解码失败'))
      el.src = url
    })

    const scale = Math.min(1, maxEdge / Math.max(img.naturalWidth, img.naturalHeight))
    const w = Math.max(1, Math.round(img.naturalWidth * scale))
    const h = Math.max(1, Math.round(img.naturalHeight * scale))

    const canvas = document.createElement('canvas')
    canvas.width = w
    canvas.height = h
    const ctx = canvas.getContext('2d')
    ctx.drawImage(img, 0, 0, w, h)

    const blob = await new Promise((resolve) => canvas.toBlob(resolve, 'image/jpeg', quality))
    if (!blob) throw new Error('图片压缩失败')
    return { blob, w, h }
  } finally {
    URL.revokeObjectURL(url)
  }
}

/**
 * 选中的文件批量压缩并落库。
 * @returns {Promise<string[]>} 新图片 id（顺序与传入一致）
 */
export async function addPhotos(files, entryId = '') {
  const list = [...(files || [])].filter((f) => f && f.type?.startsWith('image/'))
  if (!list.length) return []

  const items = []
  const ids = []
  const ts = Date.now()
  let lastError = null
  for (let i = 0; i < list.length; i += 1) {
    try {
      const { blob, w, h } = await compressImage(list[i])
      const id = newId()
      ids.push(id)
      items.push({ id, entryId, mime: 'image/jpeg', w, h, ts: ts + i, blob })
    } catch (err) {
      console.warn('[成长账本] 图片处理失败，已跳过', err)
      lastError = err
    }
  }
  if (items.length) {
    try {
      await savePhotosNative(items)
    } catch (err) {
      // 写库失败必须抛出去：否则上层拿到空 id 列表，界面静默地少一张图
      console.error('[成长账本] 图片写库失败', err)
      throw new Error('图片保存失败：' + (err?.message || err))
    }
  }
  if (!items.length && lastError) throw new Error('图片处理失败：' + (lastError.message || lastError))
  return ids
}

/** 记录确认入账后，把图片挂到 entryId 上（先存图后建 entry 时用） */
export async function attachPhotos(ids, entryId) {
  if (!ids?.length) return
  const items = []
  for (const id of ids) {
    const p = await getPhotoNative(id)
    if (p) items.push({ ...p, entryId })
  }
  if (items.length) await savePhotosNative(items)
}

export async function removePhotos(ids) {
  for (const id of ids || []) release(id, true)
  await deletePhotosNative(ids)
}

// ---------------- objectURL 引用计数 ----------------

const urlCache = new Map() // id -> { url, refs }

/**
 * 取图片的可直接给 <img src> 用的 URL（异步，首次从库里读）。
 * 用完必须调 release(id)，否则内存不释放。
 */
export async function acquire(id) {
  const hit = urlCache.get(id)
  if (hit) {
    hit.refs += 1
    return hit.url
  }
  const photo = await getPhotoNative(id)
  if (!photo) return ''
  const url = URL.createObjectURL(photo.blob)
  urlCache.set(id, { url, refs: 1 })
  return url
}

export function release(id, force = false) {
  const hit = urlCache.get(id)
  if (!hit) return
  hit.refs -= 1
  if (hit.refs <= 0 || force) {
    URL.revokeObjectURL(hit.url)
    urlCache.delete(id)
  }
}

/** 清空全部缓存（导入/清库后调用） */
export function releaseAll() {
  for (const { url } of urlCache.values()) URL.revokeObjectURL(url)
  urlCache.clear()
}
