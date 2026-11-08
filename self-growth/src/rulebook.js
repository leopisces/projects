/**
 * 规则文档加载（体系设计 §5 / rulebook.md）
 *
 * 唯一事实来源：public/rulebook.md —— AI 评分规则就在那份文件里，改文件即改口径。
 * 优先级：用户在设置里覆盖的版本 > 仓库内置版本 > 内置精简兜底（离线/加载失败时）
 */

const FALLBACK_PROMPT = `你是「成长账本」的打分器。用户用一句话描述刚做的事，你判定维度与分数。

维度（五选一）：body 身体（运动睡眠饮食体检）、mind 心智（学习阅读思考）、heart 情绪关系（情绪家人朋友社交陪伴）、craft 创造产出（有对外产出物的写作代码作品）、order 秩序（环境时间财务流程整理）。

流程：① 熬夜/刷手机失控/整天躺平/暴食 → negative=true, base=0（维度照判）；② 有对外产出物 → craft；③ 与人或自己情绪有关 → heart；④ 生理需求 → body；⑤ 整理结构资源流程 → order；⑥ 其余 → mind。

基础分 1–20：1-4 微小；5-9 标准（20–60 分钟完整投入）；10-14 扎实（难度明显/有突破）；15-20 里程碑（阶段目标达成/首次/长期节点）。
挑战系数：1.0 舒适区 / 1.3 略超 / 1.6 明显吃力。kind 归一化为 2-6 字类别名。

只输出 JSON：{"dimension":"body|mind|heart|craft|order","kind":"2-6字","base":1到20整数,"challenge":1.0|1.3|1.6,"negative":false,"reason":"不超过30字"}`

export { FALLBACK_PROMPT }

const DEFAULT_URL = `${import.meta.env.BASE_URL}rulebook.md`

let cache = null
let inflight = null

/** 读取仓库内置规则文档（带内存缓存） */
export async function loadDefaultRulebook() {
  if (cache) return cache
  if (inflight) return inflight
  inflight = (async () => {
    try {
      const res = await fetch(DEFAULT_URL, { cache: 'no-cache' })
      if (!res.ok) throw new Error(`HTTP ${res.status}`)
      const text = await res.text()
      if (!text.trim()) throw new Error('规则文档为空')
      cache = text
      return cache
    } catch (err) {
      console.warn('[成长账本] 规则文档加载失败，改用内置精简版', err)
      cache = FALLBACK_PROMPT
      return cache
    } finally {
      inflight = null
    }
  })()
  return inflight
}

/** 实际参与打分的提示词：用户覆盖版优先 */
export async function resolveRulebook(override) {
  const custom = String(override || '').trim()
  if (custom) return custom
  return loadDefaultRulebook()
}

export function clearRulebookCache() {
  cache = null
}
