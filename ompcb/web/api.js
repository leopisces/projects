// Thin fetch wrapper for /api/...
//   - relative URLs only (Vite proxy in dev, Express in prod)
//   - throws Error(body.error || <statusText>) on non-2xx so callers can
//     try/catch and surface the server's Chinese message via ElMessage.error
const API_PREFIX = '/api';

async function request(path, { method = 'GET', body, query } = {}) {
  let url = API_PREFIX + path;
  if (query) {
    const sp = new URLSearchParams();
    for (const [k, v] of Object.entries(query)) {
      if (v === undefined || v === null || v === '') continue;
      sp.set(k, String(v));
    }
    const qs = sp.toString();
    if (qs) url += (url.includes('?') ? '&' : '?') + qs;
  }

  let res;
  try {
    res = await fetch(url, {
      method,
      headers: body ? { 'Content-Type': 'application/json' } : undefined,
      body: body ? JSON.stringify(body) : undefined,
    });
  } catch (e) {
    // Network failure (proxy down, CORS, etc.)
    throw new Error('网络请求失败：' + (e?.message || e));
  }

  // Try to parse JSON; tolerate empty bodies (e.g. some 204 paths).
  let data = null;
  const ct = res.headers.get('content-type') || '';
  if (ct.includes('application/json')) {
    try { data = await res.json(); } catch { data = null; }
  } else {
    try { data = await res.json(); } catch { /* swallow */ }
  }

  if (!res.ok) {
    const msg = (data && data.error) || res.statusText || `HTTP ${res.status}`;
    throw new Error(msg);
  }
  return data;
}

// --- public API surface ----------------------------------------------------

export function listMaterials(params = {}) {
  return request('/materials', { query: params });
}

/** BOM 汇总；传 { productId } 只统计该产品 */
export function getStats(params = {}) {
  return request('/materials/stats', { query: params });
}

export function getMaterial(id) {
  return request(`/materials/${encodeURIComponent(id)}`);
}

export function createMaterial(data) {
  return request('/materials', { method: 'POST', body: data });
}

export function updateMaterial(id, patch) {
  return request(`/materials/${encodeURIComponent(id)}`, {
    method: 'PUT',
    body: patch,
  });
}

export function deleteMaterial(id) {
  return request(`/materials/${encodeURIComponent(id)}`, { method: 'DELETE' });
}

/**
 * 清空某产品的全部 BOM 明细，保留产品本身。
 *
 * 与 deleteProduct(id, { withBom: true }) 不同：那个连产品一起删，
 * 这个只清明细，适合「这版 BOM 作废，重新导一份」。
 *
 * 返回 { removed, solderedLines }：solderedLines 是被删掉的行里有领料记录的条数，
 * 这些行的行级焊接进度会永久丢失（重新导入会生成新 id，对不回去）。
 */
export function clearProductMaterials(productId) {
  return request(`/materials/by-product/${encodeURIComponent(productId)}`, {
    method: 'DELETE',
  });
}

/**
 * 把某条库存记录的制造商料号绑定到 BOM 行。
 *
 * 刻意不复用 updateMaterial：两者都写 mfr_pn 但语义相反 ——
 * 绑定要留下原导入值的快照，手工改料号要清掉快照。走同一个接口就分不出是谁在改。
 *
 * 只写 mfr_pn；制造商/供应商等字段仍是 BOM 自己的原导入值，
 * 表格里显示的库存值由查询带出的 inventory_* 字段在渲染时合并。
 */
export function bindMaterialToInventory(id, mfrPn, opts = {}) {
  return request(`/materials/${encodeURIComponent(id)}/bind`, {
    method: 'POST',
    body: { mfr_pn: mfrPn, ...opts },
  });
}

/**
 * 某个制造商料号被哪些产品的哪些 BOM 行用到。
 *
 * 给库存关联弹框的「明细」用：一条库存料号可能被多个产品同时引用，
 * 换料号前要先知道会影响谁。按产品聚合返回
 * { mfrPn, products: [{ product_code, lines, qty, solderedQty }], ... }。
 *
 * 料号走查询串而不是路径段：料号里可能含 / 与 #，放路径要双重编码。
 */
export function listMaterialUsage(mfrPn) {
  return request('/materials/usage', { query: { mfrPn } });
}

export function bulkImport(rows, mode, productId) {
  return request('/materials/bulk', {
    method: 'POST',
    body: { rows, mode, productId },
  });
}

/**
 * 按产品批量出库（领料）。
 * 逐行需求 = 用量 × 套数；只出库存完全够的行，不够的整行跳过并在结果里列出。
 */
export function issueMaterials({ productId, sets, remark }) {
  return request('/materials/issue', {
    method: 'POST',
    body: { productId, sets, remark },
  });
}

// --- 产品 products ---------------------------------------------------------
// 一个产品（如 AGB_CPU_03）拥有一份 BOM；materials 每行都归属某个产品。

export function listProducts(params = {}) {
  return request('/products', { query: params });
}

export function getProduct(id) {
  return request(`/products/${encodeURIComponent(id)}`);
}

export function createProduct(data) {
  return request('/products', { method: 'POST', body: data });
}

export function updateProduct(id, patch) {
  return request(`/products/${encodeURIComponent(id)}`, {
    method: 'PUT',
    body: patch,
  });
}

/** withBom=true 时连同该产品的 BOM 明细一起删除 */
export function deleteProduct(id, { withBom = false } = {}) {
  const suffix = withBom ? '?withBom=1' : '';
  return request(`/products/${encodeURIComponent(id)}${suffix}`, {
    method: 'DELETE',
  });
}

// --- 库存台账 inventory ----------------------------------------------------
// 与上面的 materials(板级 BOM) 完全独立：materials 记"这块板要用什么"，
// inventory 记"手头实际有什么、放在哪"。

export function listInventory(params = {}) {
  return request('/inventory', { query: params });
}

export function getInventoryStats() {
  return request('/inventory/stats');
}

export function listInventoryLocations() {
  return request('/inventory/locations');
}

/**
 * 已用范围内还空着的库位（「未使用」弹框用）。
 *
 * 库位是二维格架编号 {层}{行}{列}，如 A15 = A 层 1 行 5 列。
 * 范围是「已用过的层 × 该层已用行列最大值」围成的矩形，
 * 所以只会列出比当前最大位置小的空格，不会凭空提议新层/新行。
 * 规则详见 web/location.js，由 test/location.test.js 锁定。
 *
 * 返回 { free, total, maxLocation, layers, unparsed }。
 */
export function listFreeLocations() {
  return request('/inventory/locations/free');
}

/**
 * 库位网格全景（库位管理页 / 选位置弹框用）。
 *
 * 每层 5×5，返回每格放了哪些料、是否被合并吞掉、主格横跨纵跨几格。
 * 不传 layer 时只返回「已用层 ∪ 有合并的层」，避免一次吐 26 层空网格；
 * 传 layer（如 'B'）可查看/启用指定层。
 *
 * 返回 { layers, allLayers, rows, cols, merges, unparsed }。
 */
export function getLocationGrid(layer) {
  return request('/inventory/locations/grid', { query: { layer } });
}

/**
 * 合并格子（物理打通隔板）。
 *
 * 合并后被吞并格子里的料，location 自动改成主格号（左上角），
 * 返回的 moved 是被自动改写库位的料条数。
 * 与已有合并重叠、超出 5×5 边界、单格、方向颠倒都会被拒。
 */
export function mergeLocations({ layer, startRow, startCol, endRow, endCol, remark }) {
  return request('/inventory/locations/merge', {
    method: 'POST',
    body: { layer, startRow, startCol, endRow, endCol, remark },
  });
}

/**
 * 取消合并（恢复隔板）。
 *
 * 刻意不把料散回原格：合并期间放进去的料物理上就在主格那片区域，
 * 拆开隔板后仍在主格里。散回去等于凭空猜测每件料现在归哪一格。
 */
export function unmergeLocations(mergeId) {
  return request(`/inventory/locations/merge/${encodeURIComponent(mergeId)}`, {
    method: 'DELETE',
  });
}

/**
 * 查某个库位当前放了哪些料（编辑弹框的重复占用提示）。
 *
 * 只是提醒不是校验：一个格子放多种料在硬件仓储里是常态，后端不拒绝重复库位。
 * editing 时传 excludeId 排除自身，否则会把自己算成占用者。
 *
 * 比较口径为「去空格 + 大小写无关」，所以 `a15` 与 `A15` 视为同一格；
 * variants 返回该格实际出现过的字面写法，>1 说明写法不统一（会导致筛选漏料）。
 */
export function checkLocationOccupants(location, { excludeId } = {}) {
  return request('/inventory/locations/occupants', {
    query: { location, excludeId },
  });
}

/**
 * 按「名称 + 封装」严格相等查同规格库存候选。
 *
 * 刻意不走 listInventory 的 q 模糊搜索：那是子串 + 跨列 OR + 空格分词，
 * 会把 MATCH_ABC 当成 MATCH_A 的命中、也会把名称里的空格拆开，
 * 用来做「同规格」判断必然给出错误候选。
 *
 * package 允许为空（结构件常不填封装），此时后端只按名称匹配。
 * 返回 { list, total, name, package }，list 每项额外带 mfrPnKinds：
 * 该候选的制造商料号在台账里对应几条记录，>1 表示回填后 BOM 行会重复出现。
 */
export function matchInventoryByNamePackage(name, pkg) {
  return request('/inventory/match', { query: { name, package: pkg } });
}

/**
 * 查询两个料号的 AI 电气参数对比结果。
 *
 * 先查后端缓存表（component_spec），有就直接返回；没有则调 DeepSeek API 分析。
 * 前端用 loading 状态给提示：首次查询可能需要几秒（AI 分析中），后续走缓存秒回。
 *
 * @param {string} bomPn  BOM 行原始制造商料号
 * @param {string} candPn 候选库存料号
 * @param {string} [name]  名称（给 AI 更多上下文）
 * @param {string} [pkg]   封装（给 AI 更多上下文）
 */
export function fetchComponentSpec(bomPn, candPn, name, pkg) {
  return request('/inventory/spec', {
    query: { bom: bomPn, cand: candPn, name: name || '', package: pkg || '' }
  });
}

export function getInventoryItem(id) {
  return request(`/inventory/${encodeURIComponent(id)}`);
}

export function createInventory(data) {
  return request('/inventory', { method: 'POST', body: data });
}

// 注意：stock 不能通过此接口修改，库存变动一律走 moveStock()
export function updateInventory(id, patch) {
  return request(`/inventory/${encodeURIComponent(id)}`, {
    method: 'PUT',
    body: patch,
  });
}

export function deleteInventory(id) {
  return request(`/inventory/${encodeURIComponent(id)}`, { method: 'DELETE' });
}

/**
 * 批量删除库存元件。
 *
 * 单事务、全成或全不成：不存在的 id 会让整批被拒（返回 404 并列出缺失的 id），
 * 而不是悄悄少删几条——删除不可恢复，用户勾了 N 条就该确切知道这 N 条的下场。
 *
 * 每条元件的出入库流水由外键级联一并清除。返回
 * { deleted, logsRemoved, stockRemoved, details } 供调用方如实汇报后果。
 */
export function bulkDeleteInventory(ids) {
  return request('/inventory/bulk-delete', {
    method: 'POST',
    body: { ids },
  });
}

/**
 * 出入库：type 为 入库 / 出库 / 盘点；盘点时 qty 是实盘库存。
 * 出库时可额外带 productId / materialId 把出库绑到 BOM 行（追溯已焊接进度）。
 * 绑定参数仅 type='出库' 时被后端接受；其他类型携带会返回 400，
 * 所以不在此处判断——仅当调用方真正传了才放进 body，绝不传 undefined/null。
 */
export function moveStock(id, payload = {}) {
  const { type, qty, remark, productId, materialId } = payload
  const body = { type, qty, remark }
  // 仅当调用方显式传了这两个键（即使值是 0 / null）才放进 body；
  // 这样默认（旧的）调用方发出的 body 仍然只有 { type, qty, remark }，
  // 与改造前完全一致，避免给后端 400。
  if (Object.prototype.hasOwnProperty.call(payload, 'productId') && productId) {
    body.productId = productId
  }
  if (Object.prototype.hasOwnProperty.call(payload, 'materialId') && materialId) {
    body.materialId = materialId
  }
  return request(`/inventory/${encodeURIComponent(id)}/move`, {
    method: 'POST',
    body,
  })
}

/** 单个元件的出入库流水 */
export function listItemLogs(id) {
  return request(`/inventory/${encodeURIComponent(id)}/logs`);
}

/** 全局出入库流水查询：type / q / from / to / page / pageSize / productId / materialId */
export function listInventoryLogs(params = {}) {
  return request('/inventory/logs', { query: params });
}

/**
 * 某条 BOM 明细行的出入库流水。
 *
 * 按 material_id 筛选，与「已焊接」列的聚合口径完全一致
 * （见 server/routes/materials.js 的 solderedQty 派生表），
 * 所以弹框里出库合计减去撤销量，就等于表格里那一行的已焊接数。
 *
 * 只会有出库行与其撤销补偿行：入库/盘点/初始都不带 material_id。
 */
export function listMaterialLogs(materialId, params = {}) {
  return request('/inventory/logs', {
    query: { ...params, materialId },
  });
}

/**
 * 撤销一条出库流水：服务端追加一条反向入库把库存加回来，原出库记录保留。
 * 只有「出库」可撤销，且同一条最多撤一次（重复调用返回 409）。
 * remark 为空时事由记为「出库撤销」，否则记为「出库撤销：<remark>」。
 */
export function revokeStockOut(logId, { remark } = {}) {
  return request(`/inventory/logs/${encodeURIComponent(logId)}/revoke`, {
    method: 'POST',
    body: { remark },
  });
}

/**
 * 批量撤销出库。单事务，但不合格的行（已撤销/非出库/不存在）只跳过不整批失败，
 * 明细在返回的 errors 里。返回 { revoked, skipped, totalQty, itemKinds, details, errors }。
 */
export function revokeStockOutBulk(logIds, { remark } = {}) {
  return request('/inventory/logs/revoke-bulk', {
    method: 'POST',
    body: { logIds, remark },
  });
}

export function bulkImportInventory(rows, mode) {
  return request('/inventory/bulk', {
    method: 'POST',
    body: { rows, mode },
  });
}

/**
 * 删除某产品的全部出入库流水。
 *
 * 只清流水不删库存记录本身——库存数量不受影响。
 * 用途：产品 BOM 作废后，历史流水已无追溯价值。
 *
 * @param {number} productId 产品 ID
 * @returns {{ ok: boolean, deleted: number, productId: number, message: string }}
 */
export function deleteLogsByProduct(productId) {
  return request(`/inventory/logs/by-product/${encodeURIComponent(productId)}`, {
    method: 'DELETE',
  });
}

/**
 * 删除某个元件的全部出入库流水。
 *
 * 只清流水不删库存记录本身——库存数量不受影响。
 *
 * @param {number} inventoryId 库存记录 ID
 * @returns {{ ok: boolean, deleted: number, inventoryId: number, message: string }}
 */
export function deleteLogsByInventory(inventoryId) {
  return request(`/inventory/logs/by-inventory/${encodeURIComponent(inventoryId)}`, {
    method: 'DELETE',
  });
}

/**
 * 把指定产品 BOM 里未匹配到库存的物料一键建进台账，库存一律为 0。
 * 按制造商料号去重；无制造商料号的行跳过（关联依据就是它，建了也对不上）；
 * 供应商料号撞唯一约束的行跳过并在 errors 里说明。
 * 返回 { inserted, skipped, skippedNoPn, details, errors }。
 */
export function adoptUnmatchedToInventory(productId) {
  return request('/inventory/adopt-unmatched', {
    method: 'POST',
    body: { productId },
  });
}
