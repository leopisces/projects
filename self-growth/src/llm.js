import { DIMENSIONS } from './dimensions.js'

// 打分口径全部来自 public/rulebook.md（AI 评分规则），由 rulebook.js 注入，不在这里硬编码

export class ScoreError extends Error {}

function normalizeResult(raw, source) {
  const dimOk = DIMENSIONS.some((d) => d.id === raw.dimension)
  const base = Math.max(0, Math.min(20, Math.round(Number(raw.base) || 0)))
  const chRaw = Number(raw.challenge)
  const challenge = Math.abs(chRaw - 1.6) < 0.05 ? 1.6 : Math.abs(chRaw - 1.3) < 0.05 ? 1.3 : 1.0
  const negative = Boolean(raw.negative)
  return {
    dimension: dimOk ? raw.dimension : 'mind',
    kind: String(raw.kind || '未归类').slice(0, 8),
    base: negative ? 0 : base,
    challenge: negative ? 1.0 : challenge,
    negative,
    reason: String(raw.reason || '').slice(0, 60),
    points: negative ? 0 : Math.round(base * challenge),
    source,
  }
}

function parseJsonLoosely(text) {
  const cleaned = String(text || '')
    .replace(/```json/gi, '')
    .replace(/```/g, '')
    .trim()
  try {
    return JSON.parse(cleaned)
  } catch {
    const start = cleaned.indexOf('{')
    const end = cleaned.lastIndexOf('}')
    if (start >= 0 && end > start) {
      return JSON.parse(cleaned.slice(start, end + 1))
    }
    throw new ScoreError('模型返回的内容不是合法 JSON')
  }
}

/**
 * 调用 OpenAI 兼容接口打分。settings 需含 apiBase / apiKey / model。
 * rulebook 为评分规则文档（见 rulebook.js），每次请求都作为系统提示词下发，
 * 这样改了规则文档不需要重新打包。
 * 失败抛 ScoreError，由调用方降级到本地规则。
 */
export async function scoreWithLLM(text, settings, { rulebook, timeout = 25000 } = {}) {
  const base = String(settings.apiBase || '').replace(/\/+$/, '')
  const model = String(settings.model || '').trim()
  const key = String(settings.apiKey || '').trim()
  if (!base || !model || !key) throw new ScoreError('未配置模型（apiBase / apiKey / model）')

  const controller = new AbortController()
  const timer = setTimeout(() => controller.abort(), timeout)
  try {
    const res = await fetch(`${base}/chat/completions`, {
      method: 'POST',
      signal: controller.signal,
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${key}`,
      },
      body: JSON.stringify({
        model,
        temperature: 0.2,
        messages: [
          { role: 'system', content: String(rulebook || '') },
          { role: 'user', content: text },
        ],
      }),
    })
    if (!res.ok) {
      const detail = await res.text().catch(() => '')
      throw new ScoreError(`接口返回 ${res.status}${detail ? `：${detail.slice(0, 120)}` : ''}`)
    }
    const data = await res.json()
    const content = data?.choices?.[0]?.message?.content
    if (!content) throw new ScoreError('模型没有返回内容')
    return normalizeResult(parseJsonLoosely(content), 'llm')
  } catch (err) {
    if (err.name === 'AbortError') throw new ScoreError('模型响应超时')
    if (err instanceof ScoreError) throw err
    throw new ScoreError(err?.message || '请求失败（可能是 CORS 或网络问题）')
  } finally {
    clearTimeout(timer)
  }
}

// ---------------------------------------------------------------
// 降级：本地规则打分（体系设计 §5.2）
// ---------------------------------------------------------------

const NEGATIVE_WORDS = ['熬夜', '通宵', '到凌晨', '刷手机', '刷视频', '刷短视频', '停不下来', '躺了一天', '躺平一天', '暴饮暴食', '发脾气', '失控']
const HARD_WORDS = ['终于', '第一次', '最难', '硬着头皮', '吃力', '突破', '攻克', '坚持了', '两小时', '3小时', '三小时', '两万', '一口气']
const MILD_WORDS = ['稍微', '有点', '一点', '随手', '顺便']
const BIG_WORDS = ['完成', '上线', '发布', '搞定', '做完', '跑完', '交稿']

export function localScore(text) {
  const s = String(text || '').trim()
  const lower = s.toLowerCase()

  if (NEGATIVE_WORDS.some((w) => lower.includes(w))) {
    let dim = 'body'
    for (const d of DIMENSIONS) {
      if (d.keywords.some((k) => s.includes(k))) {
        dim = d.id
        break
      }
    }
    return normalizeResult(
      {
        dimension: dim,
        kind: s.slice(0, 6) || '负向记录',
        base: 0,
        challenge: 1.0,
        negative: true,
        reason: '本地估算：识别到负向行为',
      },
      'rule',
    )
  }

  // 维度：命中关键词最长的那个（越长越具体）
  let dim = 'mind'
  let best = 0
  for (const d of DIMENSIONS) {
    for (const k of d.keywords) {
      if (s.includes(k) && k.length > best) {
        best = k.length
        dim = d.id
      }
    }
  }

  let base = 5
  if (s.length >= 30) base += 2
  if (HARD_WORDS.some((w) => s.includes(w))) base += 4
  if (BIG_WORDS.some((w) => s.includes(w))) base += 3
  if (s.length <= 6) base -= 2
  base = Math.max(1, Math.min(20, base))

  let challenge = 1.0
  if (HARD_WORDS.some((w) => s.includes(w))) challenge = 1.3
  if (s.includes('吃力') || s.includes('最难') || s.includes('第一次')) challenge = 1.6
  if (MILD_WORDS.some((w) => s.includes(w))) challenge = 1.0

  return normalizeResult(
    {
      dimension: dim,
      kind: s.slice(0, 6) || '成长记录',
      base,
      challenge,
      negative: false,
      reason: '本地估算：关键词判定，未调用模型',
    },
    'rule',
  )
}
