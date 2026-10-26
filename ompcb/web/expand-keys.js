// web/expand-keys.js — el-table 展开行的 key 同步
//
// 只为一件事存在：el-table 的 `expand-change` 事件在 `type="expand"` 列上
// 发出的第二个参数是**当前所有已展开行的数组**，不是布尔值 ——
//
//   element-plus/es/components/table/src/store/expand.mjs:26
//     instance.emit('expand-change', row, expandRows.value.slice())
//
// 只有树形表格才发布尔值（同目录 store/tree.mjs:131）。
//
// 这里踩过一次坑：把第二个参数当布尔用（`if (expanded) keys.add(...) else keys.delete(...)`）。
// 数组恒为真，于是只会不断 add、永远删不掉，表现为「点开后收不回去」。
// 而且这个 bug 在只有 1 条候选时也照样出现，肉眼看代码完全合理。
//
// 所以：绝不自己推断展开态，一律以组件给的数组为唯一事实来源。
// 抽成纯函数是为了能被 node:test 直接断言 —— 项目刻意不引入
// vitest/jsdom（同 designator.js / bom-display.js 的理由）。

/**
 * 把 el-table 给的「已展开行数组」转成受控的 expand-row-keys。
 *
 * @param {unknown} expandedRows expand-change 的第二个参数
 * @param {string} keyField row-key 对应的字段名，默认 'id'
 * @returns {Array<string|number>} 去重后的 key 列表，顺序按组件给的数组
 */
export function toExpandKeys(expandedRows, keyField = 'id') {
  if (!Array.isArray(expandedRows)) return [];
  const out = [];
  const seen = new Set();
  for (const row of expandedRows) {
    const key = row?.[keyField];
    // key 为 null/undefined 的行进不了 expand-row-keys（el-table 按 key 找行），
    // 留着只会让「展开了几行」的计数与实际不符
    if (key === null || key === undefined) continue;
    if (seen.has(key)) continue;
    seen.add(key);
    out.push(key);
  }
  return out;
}

/**
 * 这一行在本次事件后是「展开」还是「收起」。
 *
 * 判断依据只有一个：它在不在最新的已展开行数组里。
 *
 * @param {unknown} expandedRows expand-change 的第二个参数
 * @param {object|null|undefined} row 被点的那一行
 * @param {string} keyField row-key 对应的字段名，默认 'id'
 * @returns {boolean}
 */
export function isRowExpanded(expandedRows, row, keyField = 'id') {
  if (!Array.isArray(expandedRows)) return false;
  const key = row?.[keyField];
  if (key === null || key === undefined) return false;
  return expandedRows.some(r => r?.[keyField] === key);
}
