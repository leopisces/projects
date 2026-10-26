// web/bom-display.js — 绑定行的四列显示口径
//
// 手动绑定（BOM 页状态列 → 弹框选一条库存记录）只改 BOM 的 mfr_pn，库存的
// 制造商 / 供应商 / 供应商料号绝不写进 BOM 那三列（见 server/routes/materials.js
// 的 POST /:id/bind 与 README 核心设计 §1：BOM 不存库存信息）。
// 但用户绑定的语义是「这一行就是台账里的那个料」，所以这四列应当显示台账那条
// 记录的值 —— 合并只发生在读取侧，落库的还是 BOM 自己的数据。
//
// 三条口径（已定，改动前请确认业务同意）：
//   1. 只对绑定过的行生效。bound_at 为 NULL（从未绑定）的行完全按原样显示。
//      按料号自动 JOIN 到的行不算绑定 —— 那是系统推断，不是用户意图。
//   2. 库存值为空时回退 BOM 自有值。台账里 supplier 常常没填，
//      显示成空等于凭空丢信息。
//   3. 原导入值在 src_* 快照里，是唯一的原始凭证（界面用 hover 呈现）。
//
// 为什么单独成文件而不是塞进 MaterialTable.vue：
//   - 表格渲染与 CSV 导出（BomPanel.vue）必须用同一套口径，否则「看到的」
//     和「导出的」不一致，是最难被发现的一类 bug。
//   - 纯函数、无 Vue 依赖，`node:test` 能直接 import 断言（同 designator.js）。

/** 四列 → 库存值别名 / 原值快照列 的映射。键即 materials 表的列名。 */
export const BOUND_FIELDS = {
  mfr_pn: { inv: 'inventory_mfr_pn', src: 'src_mfr_pn', label: '制造商料号' },
  mfr: { inv: 'inventory_mfr', src: 'src_mfr', label: '制造商' },
  supplier: { inv: 'inventory_supplier', src: 'src_supplier', label: '供应商' },
  supplier_pn: { inv: 'inventory_supplier_pn', src: 'src_supplier_pn', label: '供应商料号' },
};

/** null/undefined/数字 一律转成 trim 过的字符串，便于统一判空 */
function text(v) {
  return v === null || v === undefined ? '' : String(v).trim();
}

/**
 * 这一行是否被手动绑定过。
 *
 * bound_at 由 POST /materials/:id/bind 写入，NULL 表示从未绑定。
 * 手工改料号（PUT /:id）会把它清回 NULL —— 手改之后库存值就不再是用户的意图了。
 *
 * @param {object|null|undefined} row BOM 行（listMaterials 返回的形状）
 * @returns {boolean}
 */
export function isBound(row) {
  return Boolean(text(row?.bound_at));
}

/**
 * 四列之一的显示值：绑定行取库存值（空则回退 BOM 自有值），未绑定行按原样。
 *
 * 传入非这四列的 key 时原样返回该列值，这样调用方（如 CSV 导出）能对所有列
 * 无脑调用，不必自己分流。
 *
 * @param {object} row BOM 行
 * @param {string} key 列名
 * @returns {string} 显示值，可能为空串（由调用方决定占位符）
 */
export function boundValue(row, key) {
  const own = text(row?.[key]);
  const field = BOUND_FIELDS[key];
  if (!field || !isBound(row)) return own;
  return text(row?.[field.inv]) || own;
}

/**
 * 原导入值（绑定前的那份），仅对这四列有意义。
 *
 * 返回空串有两种情况，调用方不必区分：
 *   - 导入时这一列本来就是空的
 *   - 这行是加快照列之前就绑定过的老数据，原值已永久丢失
 *     （遵循项目惯例：不做猜测性回填）
 *
 * @param {object} row BOM 行
 * @param {string} key 列名
 * @returns {string}
 */
export function sourceValue(row, key) {
  const field = BOUND_FIELDS[key];
  if (!field || !isBound(row)) return '';
  return text(row?.[field.src]);
}
