import { mkdirSync, readFileSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import Database from 'better-sqlite3'
import { seedDatabase } from './seed.js'
import { migrateInventory } from './migrate-inventory.js'
import { migrateProducts } from './migrate-products.js'
import { migrateLogProduct } from './migrate-log-product.js'
import { migrateLogRevoke } from './migrate-log-revoke.js'
import { migrateLogMaterial } from './migrate-log-material.js'
import { migrateMaterialsBind } from './migrate-materials-bind.js'
import { migrateLocationMerge } from './migrate-location-merge.js'
import migrateComponentSpec from './migrate-component-spec.js'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

const dbPath = process.env.OMPCB_DB || join(__dirname, '../../data/ompcb.db')
mkdirSync(dirname(dbPath), { recursive: true })

const db = new Database(dbPath)
db.pragma('journal_mode = WAL')
db.pragma('foreign_keys = ON')

const schema = readFileSync(join(__dirname, 'schema.sql'), 'utf8')
db.exec(schema)

const { count } = db.prepare('SELECT COUNT(*) AS count FROM materials').get()
if (count === 0) {
  seedDatabase(db, { force: false })
}

// 产品维度迁移必须在任何代码读 product_id 之前跑：
// 它负责补列、把历史 BOM 行归入默认产品、并把位号唯一索引改为产品内唯一。
const productResult = migrateProducts(db)
if (productResult.addedColumn || productResult.adopted > 0) {
  console.log(
    `[ompcb] 产品维度已就绪: ${productResult.addedColumn ? '新增 product_id 列, ' : ''}` +
      `${productResult.adopted} 行归入默认产品(id=${productResult.productId})`
  )
}

// BOM 行加「绑定前原导入值」快照列：绑定会覆盖 mfr_pn，原值要留一份供 hover 查看。
// 必须在 routes/materials.js 的查询读这些列之前跑。
const bindResult = migrateMaterialsBind(db)
if (bindResult.addedColumn) {
  console.log(`[ompcb] BOM 已支持记录绑定前的原导入信息: 新增 ${bindResult.added.join(', ')}`)
}

// 流水加产品维度：记录每次领料是为哪个产品出的
const logResult = migrateLogProduct(db)
if (logResult.addedColumn) {
  console.log('[ompcb] 出入库流水已支持按产品追溯')
}

// 流水加撤销指向：撤销出库 = 追加一条反向入库并指回原出库行
const revokeResult = migrateLogRevoke(db)
if (revokeResult.addedColumn) {
  console.log('[ompcb] 出入库流水已支持出库撤销')
}

// 流水加物料行绑定：出库领料时记下领的是 BOM 清单的哪一行（material），
// 让产品能知道每一行料是否已领用焊接。只写出库行及其撤销补偿行。
const materialResult = migrateLogMaterial(db)
if (materialResult.addedColumn) {
  console.log('[ompcb] 出入库流水已支持按 BOM 物料行追溯')
}

// 库位合并关系表：记录货架上哪些格子被打通成了一个大格。
// 与「格子里放了什么料」分开存——合并区域可能暂时空着，也可能放好几种料。
const mergeResult = migrateLocationMerge(db)
if (mergeResult.created) {
  console.log('[ompcb] 库位管理已支持格子合并')
}

// 元件电气参数分析表：按 mfr_pn 缓存 DeepSeek 分析结果，同一料号只调一次 AI
migrateComponentSpec(db)

// 库存台账首次启动时从 BOM 抽取初始数据；表里已有数据则原样跳过
const { count: inventoryCount } = db.prepare('SELECT COUNT(*) AS count FROM inventory').get()
if (inventoryCount === 0) {
  const result = migrateInventory(db, { force: false })
  if (!result.skipped) {
    console.log(`[ompcb] 库存台账已初始化: 新增 ${result.inserted} 条（合并重复 ${result.merged} 行）`)
  }
}

export { db }

export function runSeed({ force = false } = {}) {
  return seedDatabase(db, { force })
}

export function runInventoryMigration({ force = false } = {}) {
  return migrateInventory(db, { force })
}
