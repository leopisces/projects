// 迁移：元件电气参数对比表（component_spec）
//
// 拿 BOM 原始料号（bom_mfr_pn）与候选库存料号（cand_mfr_pn）两个一起发给 AI，
// 让 AI 判断电气参数差异与可替换性。同一对料号只调一次 AI，后续直接读表。
//
// v2 schema：复合主键 (bom_mfr_pn, cand_mfr_pn)。
// v1 schema 只有单列 mfr_pn 主键——如果检测到旧表就删掉重建（表里不会有有效数据）。
export default function migrateComponentSpec(db) {
  // 检测旧 schema：v1 表有 mfr_pn 列但没有 bom_mfr_pn 列
  const cols = db.prepare("PRAGMA table_info(component_spec)").all()
  const hasOldSchema = cols.some(c => c.name === 'mfr_pn') && !cols.some(c => c.name === 'bom_mfr_pn')
  if (hasOldSchema) {
    db.exec('DROP TABLE component_spec')
  }

  db.exec(`
    CREATE TABLE IF NOT EXISTS component_spec (
      bom_mfr_pn   TEXT NOT NULL,           -- BOM 行原始料号
      cand_mfr_pn  TEXT NOT NULL,           -- 候选库存料号
      name         TEXT,                    -- 名称快照（方便展示）
      package      TEXT,                    -- 封装快照
      spec         TEXT NOT NULL DEFAULT '{}', -- AI 返回的结构化对比 JSON
      source       TEXT NOT NULL DEFAULT 'ai', -- 分析来源：ai / manual
      created_at   TEXT DEFAULT (datetime('now','localtime')),
      PRIMARY KEY (bom_mfr_pn, cand_mfr_pn)
    );
  `)
}
