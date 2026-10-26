// server/bind-rules.js — 手动绑定的库存提示阀值
//
// 库存不高于 LOW_BIND_STOCK 的候选，在绑定弹框里标注「库存偏低」。
//
// **仅提示，不禁用。** 绑不绑是使用者的判断 —— 先绑上再采购、或明知不够也要
// 先把关联记下来，都是合理用法。系统给出信息，不替人做决定。
//
// 提示的意义：手动绑定多半是「原料号缺货，从台账挑个同规格的替代品换上」，
// 而换上一个本身也没几个的料通常解决不了问题。值得提醒一句，但不该拦。
//
// 曾实现过「库存必须 > 50 才允许绑定」的硬守卫（后端 400 + 前端置灰），
// 按业务要求撤掉。若将来又要收紧：改这一处阀值，并在
// routes/materials.js 的 POST /:id/bind 里加回守卫 —— 只在前端置灰不够，
// /api/* 没有鉴权（README「几个坑」），curl 一样能打进来。
//
// 为什么单独成文件：阀值被后端 GET /inventory/match 与前端弹框两处读到。
// 各写一份必然飘：后端按 50 标注、前端按 30 判断，同一条记录两种说法。
export const LOW_BIND_STOCK = 50

/**
 * 这条候选的库存是否算「偏低」（仅用于提示，不影响能否绑定）。
 *
 * 非数字 / null 按「偏低」处理：库存列是 NOT NULL 整数，真出现异常值时
 * 提示出来比静默当成充足安全。
 *
 * @param {number|string|null|undefined} stock
 * @returns {boolean} true 表示库存偏低，应给出提示
 */
export function isLowBindStock(stock) {
  const n = Number(stock)
  if (!Number.isFinite(n)) return true
  return n <= LOW_BIND_STOCK
}
