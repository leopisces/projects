-- OMPCB 物料维护管理表 · SQLite schema
-- 幂等：可重复执行，不会破坏已有数据

PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;

-- ===========================================================================
-- 产品 products
-- 一个产品（如 AGB_CPU_03）拥有一份 BOM。materials 的每一行都归属某个产品。
-- ===========================================================================
CREATE TABLE IF NOT EXISTS products (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  code        TEXT    NOT NULL,                          -- 产品编号，如 AGB_CPU_03（唯一）
  name        TEXT    NOT NULL DEFAULT '',               -- 产品名称/说明
  remark      TEXT    NOT NULL DEFAULT '',
  created_at  TEXT    NOT NULL DEFAULT (datetime('now', 'localtime')),
  updated_at  TEXT    NOT NULL DEFAULT (datetime('now', 'localtime'))
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_products_code ON products(code);

CREATE TRIGGER IF NOT EXISTS trg_products_updated_at
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
  UPDATE products SET updated_at = datetime('now', 'localtime') WHERE id = OLD.id;
END;

CREATE TABLE IF NOT EXISTS materials (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  seq          INTEGER,                                  -- 序号（BOM 原始序号，可空）
  name         TEXT    NOT NULL,                          -- 名称 / 规格值（如 1MΩ、100nF）
  designator   TEXT    NOT NULL DEFAULT '',               -- 位号，逗号分隔（如 R1,R32）
  package      TEXT    NOT NULL DEFAULT '',               -- 封装（如 R0402）
  qty          INTEGER NOT NULL DEFAULT 0 CHECK (qty >= 0),    -- 需求数量（本板用量）
  mfr_pn       TEXT    NOT NULL DEFAULT '',               -- 制造商料号
  mfr          TEXT    NOT NULL DEFAULT '',               -- 制造商
  supplier     TEXT    NOT NULL DEFAULT '',               -- 供应商（如 LCSC）
  supplier_pn  TEXT    NOT NULL DEFAULT '',               -- 供应商料号（如 C26083）
  status       TEXT    NOT NULL DEFAULT '待购',            -- 状态：待购/已购/无立创编号/缺货 等
  stock        INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0), -- 库存数量（手头实有）
  location     TEXT    NOT NULL DEFAULT '',               -- 存放位置
  remark       TEXT    NOT NULL DEFAULT '',               -- 备注
  created_at   TEXT    NOT NULL DEFAULT (datetime('now', 'localtime')),
  updated_at   TEXT    NOT NULL DEFAULT (datetime('now', 'localtime'))
);

-- product_id 通过 migrate-products.js 里的幂等 ALTER 添加（老库升级路径），
-- 这里不写进 CREATE TABLE，避免"表已存在"时新列被跳过导致新旧库结构不一致。

-- 由 migrate-materials-bind.js 幂等追加（老库升级路径），同样不写进 CREATE TABLE：
--   src_mfr_pn / src_mfr / src_supplier / src_supplier_pn
--     绑定库存前的原导入值快照。绑定会覆盖 mfr_pn，原值留一份供表格 hover 查看。
--     只在「首次绑定」时写入，重复绑定不覆盖（保留的是最初导入的值）。
--   bound_at
--     绑定时间；NULL = 从未绑定过。刻意用独立列而不是从 src_* 反推：
--     结构件导入时 mfr_pn 本就为空，绑定后快照也是空串，反推会误判成未绑定。
-- 注意：这 5 列绝不能进 routes/materials.js 的 EDITABLE_COLUMNS，
-- 否则 normalize() 会在批量导入时把它们清成空值。

-- 常用查询列索引
CREATE INDEX IF NOT EXISTS idx_materials_name        ON materials(name);
CREATE INDEX IF NOT EXISTS idx_materials_designator  ON materials(designator);
CREATE INDEX IF NOT EXISTS idx_materials_supplier_pn ON materials(supplier_pn);
CREATE INDEX IF NOT EXISTS idx_materials_status      ON materials(status);
CREATE INDEX IF NOT EXISTS idx_materials_seq         ON materials(seq);
-- 按制造商料号关联库存：BOM 页动态匹配靠这个索引
CREATE INDEX IF NOT EXISTS idx_materials_mfr_pn      ON materials(mfr_pn);

-- 位号唯一约束改为"产品内唯一"，见 migrate-products.js：
-- 旧的全局唯一索引 uq_materials_designator 会被替换为
-- uq_materials_product_designator(product_id, designator)，
-- 否则两个产品都用 R1 会互相冲突。

-- updated_at 自动维护
CREATE TRIGGER IF NOT EXISTS trg_materials_updated_at
AFTER UPDATE ON materials
FOR EACH ROW
BEGIN
  UPDATE materials SET updated_at = datetime('now', 'localtime') WHERE id = OLD.id;
END;

-- ===========================================================================
-- 库存台账 inventory
-- 与 materials(板级 BOM) 完全独立：materials 记"这块板要用什么"，
-- inventory 记"我手头实际有什么、放在哪"。两边各自维护，互不影响。
-- 初始数据由 migrate-inventory.js 从 materials 按 supplier_pn 去重抽取一次。
-- ===========================================================================
CREATE TABLE IF NOT EXISTS inventory (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  name         TEXT    NOT NULL DEFAULT '',               -- 名称/规格（如 1MΩ、100nF），便于盘点时认料
  package      TEXT    NOT NULL DEFAULT '',               -- 封装（如 R0402）
  mfr_pn       TEXT    NOT NULL DEFAULT '',               -- 制造商料号
  mfr          TEXT    NOT NULL DEFAULT '',               -- 制造商
  supplier     TEXT    NOT NULL DEFAULT '',               -- 供应商（如 LCSC）
  supplier_pn  TEXT    NOT NULL DEFAULT '',               -- 供应商料号（如 C26083）——业务唯一键
  status       TEXT    NOT NULL DEFAULT '正常',            -- 【已废弃】状态改由 stock 派生：stock<=0 缺货，否则正常。
                                                          -- 保留此列仅为兼容旧数据，接口一律不读不写它。
  stock        INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0), -- 当前库存，由出入库流水累计维护
  location     TEXT    NOT NULL DEFAULT '',               -- 存放位置（如 A1-B2）
  remark       TEXT    NOT NULL DEFAULT '',               -- 备注
  created_at   TEXT    NOT NULL DEFAULT (datetime('now', 'localtime')),
  updated_at   TEXT    NOT NULL DEFAULT (datetime('now', 'localtime'))
);

CREATE INDEX IF NOT EXISTS idx_inventory_name     ON inventory(name);
CREATE INDEX IF NOT EXISTS idx_inventory_mfr_pn   ON inventory(mfr_pn);
CREATE INDEX IF NOT EXISTS idx_inventory_status   ON inventory(status);
CREATE INDEX IF NOT EXISTS idx_inventory_location ON inventory(location);

-- 供应商料号唯一。空料号不参与约束：无立创编号的元件允许多行并存
CREATE UNIQUE INDEX IF NOT EXISTS uq_inventory_supplier_pn
  ON inventory(supplier_pn) WHERE supplier_pn <> '';

CREATE TRIGGER IF NOT EXISTS trg_inventory_updated_at
AFTER UPDATE ON inventory
FOR EACH ROW
BEGIN
  UPDATE inventory SET updated_at = datetime('now', 'localtime') WHERE id = OLD.id;
END;

-- ===========================================================================
-- 出入库流水 inventory_log
-- 每次库存变动都落一条：delta 为正=入库，为负=出库。
-- stock_after 快照当次操作后的库存，便于对账（不用重算整条流水）。
-- 台账删除时流水级联删除。
-- ===========================================================================
CREATE TABLE IF NOT EXISTS inventory_log (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  inventory_id  INTEGER NOT NULL REFERENCES inventory(id) ON DELETE CASCADE,
  type          TEXT    NOT NULL,                          -- 入库/出库/盘点/初始
  delta         INTEGER NOT NULL,                          -- 变动量：+入库 / -出库
  stock_after   INTEGER NOT NULL CHECK (stock_after >= 0),  -- 变动后库存快照
  remark        TEXT    NOT NULL DEFAULT '',               -- 事由（如"领用做样板"）
  created_at    TEXT    NOT NULL DEFAULT (datetime('now', 'localtime'))
);

-- product_id 由 migrate-log-product.js 幂等追加（老库升级路径）：
-- 记录"这次出库是为哪个产品领的料"。手工单件出入库时为 NULL。
-- 不靠料号反推产品——通用元件（如 100nF）会出现在多个产品的 BOM 里，反推不准。

-- revokes_log_id 由 migrate-log-revoke.js 幂等追加（老库升级路径）：
-- 撤销出库时不删原记录，而是追加一条反向入库，该列指回被撤销的出库行。
-- 普通流水为 NULL。配套的部分唯一索引保证一条出库最多被撤销一次。

-- material_id 由 migrate-log-material.js 幂等追加（老库升级路径）：
-- 出库领料时绑到 BOM 清单的具体行（material），产品据此知道每一行料是否
-- 已领用焊接。只写在"出库"行及其撤销补偿行上，绝不写入入库/盘点/初始行
-- （"已焊接量"按 -SUM(delta) 聚合，盘点正负 delta 会污染结果）。

CREATE INDEX IF NOT EXISTS idx_inv_log_inventory ON inventory_log(inventory_id, id DESC);
CREATE INDEX IF NOT EXISTS idx_inv_log_created   ON inventory_log(created_at DESC);
