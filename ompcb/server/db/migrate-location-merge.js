// server/db/migrate-location-merge.js — 库位合并关系表
//
// 幂等：可重复执行。老库升级路径与新库初始化走同一份代码。
//
// 为什么单独一张表而不是在 inventory 上加列：
// 合并是「货架的物理结构」，与「货架上放了什么料」是两件事。
// 一个合并区域可能暂时空着（拆了隔板还没放料），也可能放好几种料；
// 挂在 inventory 上就无法表达空的合并区域，且每加一种料都要重复存一遍合并范围。
//
// 主格（primary）不单独存字段：它恒等于 (start_row, start_col) 对应的格子，
// 存了就有可能与范围不一致。需要时由 formatLocation 算出来。
//
// 接收 db 参数而不是从 ./index.js 导入：index.js 正在初始化时会调用本函数，
// 反向 import 会形成循环依赖。与其他 migrate-*.js 保持同一签名。

export function migrateLocationMerge(db) {
  const existing = db
    .prepare("SELECT name FROM sqlite_master WHERE type='table' AND name='location_merge'")
    .get()

  if (existing) return { created: false }

  db.exec(`
    CREATE TABLE location_merge (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      layer      TEXT    NOT NULL,                       -- 层号 A~Z
      start_row  INTEGER NOT NULL CHECK (start_row >= 1), -- 左上角行
      start_col  INTEGER NOT NULL CHECK (start_col >= 1), -- 左上角列
      end_row    INTEGER NOT NULL CHECK (end_row >= 1),   -- 右下角行
      end_col    INTEGER NOT NULL CHECK (end_col >= 1),   -- 右下角列
      remark     TEXT    NOT NULL DEFAULT '',            -- 备注（如「放排母包」）
      created_at TEXT    NOT NULL DEFAULT (datetime('now', 'localtime')),
      -- 范围必须是左上到右下，与 web/location.js 的 validateMerge 同一约束。
      -- 在库层面兜底：绕过接口直接写库也不能存出反向范围。
      CHECK (start_row <= end_row),
      CHECK (start_col <= end_col),
      -- 单格不算合并
      CHECK (start_row <> end_row OR start_col <> end_col)
    );

    -- 按层查合并是最高频的操作（渲染某一层的网格）
    CREATE INDEX idx_location_merge_layer ON location_merge(layer);
  `)

  console.log('[ompcb] 库位合并关系表已创建: location_merge')
  return { created: true }
}