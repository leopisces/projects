// web/designator.js — 位号解析
//
// 位号（designator）是 BOM 行里那一串「这块板上哪几个焊盘用这个料」，
// 如 `R1,R32` 或 27 个 `C…`。个数即该行在单板上的实际用量，所以
// 出库领料时可以据此直接把出库数量默认填好。
//
// 为什么单独成文件而不是塞进 StockMoveDialog.vue：
// 纯函数、无 Vue 依赖，`node:test` 能直接 import 断言，不必为了测一个
// 字符串拆分引入 vitest/jsdom（项目目前 4 个运行时依赖，刻意保持极简）。
//
// 刻意不支持的写法：
//   - 区间 `R1-R5` / `R1..R5`：现有数据与代码里都没有这个语义，
//     擅自展开会让 `R1-R5` 从 1 个变成 5 个，是静默的数据解释变更。
//     真要支持得先确认录入约定，届时改这里一处即可。

/** 位号分隔符：半角逗号 + 全角逗号（Excel 中文环境粘贴常见） */
const SEPARATOR = /[,，]/

/**
 * 把位号字符串拆成位号数组。
 *
 * 去空（连续逗号、首尾逗号、纯空格段都不算一个位号）并**去重**——
 * 同一个焊盘写两遍是录入笔误，不该让出库数量凭空多一个。
 * 去重大小写敏感：`R1` 与 `r1` 视为不同，因为无法确定哪种是笔误，
 * 猜测性归并会掩盖真实的录入问题。
 *
 * @param {string|null|undefined} raw 原始位号串，如 'R1,R32'
 * @returns {string[]} 去空去重后的位号，顺序保持原样
 */
export function parseDesignators(raw) {
  if (raw === null || raw === undefined) return []
  return [
    ...new Set(
      String(raw)
        .split(SEPARATOR)
        .map(s => s.trim())
        .filter(s => s !== '')
    )
  ]
}

/**
 * 位号个数。位号为空/无有效位号时返回 0，调用方据此决定是否回退默认值。
 *
 * @param {string|null|undefined} raw
 * @returns {number} >= 0
 */
export function countDesignators(raw) {
  return parseDesignators(raw).length
}
