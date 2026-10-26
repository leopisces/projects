# 测试

零依赖，用 Node 20+ 内置的 `node:test`。

```bash
npm test          # 跑全部测试
npm run test:watch  # 改代码自动重跑
```

## 数据安全

**测试绝不碰 `data/ompcb.db`。**

`helpers.js` 里的 `createTestServer()` 会：

1. 在 `%TEMP%/ompcb-test/` 下建一个全新的 SQLite 文件
2. 通过 `OMPCB_DB` 环境变量让 `server/db/index.js` 指向它
3. 由启动流程自动建表、导入 `seed.tsv` 种子数据、抽取库存台账
4. 在随机空闲端口起服务，不会和 dev 的 4000 / 5173 冲突

所以每个测试文件拿到的都是一份干净、可预期的数据，跑多少次都不会污染你的真实库。

测试结束后**刻意不删**临时 db 文件，失败时可以直接打开排查。

## 约束

`server/db/index.js` 是 ESM 模块、有缓存，首次 import 时就绑定了 `OMPCB_DB`。
因此**每个测试文件只能调用 `createTestServer()` 一次**。
`node:test` 默认每个文件跑在独立进程里，天然满足这个前提。

## 文件

| 文件 | 覆盖范围 |
|---|---|
| `bom-products.test.js` | 产品 CRUD、BOM 字段归属、按 `mfr_pn` 动态关联库存、产品隔离、批量导入、删除保护、手动绑定的原值快照 |
| `inventory.test.js` | 台账抽取去重、出入库/盘点流水、库存只能经出入库变动、唯一约束、级联删除、筛选搜索 |
| `soldered.test.js` | 出库 ↔ BOM 行绑定、已焊接量净额聚合、撤销出库回退进度、按焊接进度筛选 |
| `designator.test.js` | 位号解析（纯函数，不起服务） |
| `expand-keys.test.js` | el-table 展开行 key 同步（纯函数）—— 为「明细点开后收不回去」建的回归锁 |
| `bom-display.test.js` | 绑定行四列的**显示口径**（纯函数，不起服务）—— 表格与 CSV 导出共用同一套 |

`bom-display.test.js` 与 `bom-products.test.js` 里的「绑定原值快照」互补：
后者验后端**存了什么**（`src_*` 快照、`bound_at`、绝不把 `i.*` 写进 BOM），
前者验前端把这些列**合并成用户看到的什么**。分开是因为一旦有人在
`MaterialTable.vue` 里就地改显示逻辑而漏了 CSV（或反之），界面与导出就会
不一致 —— 这类 bug 在 UI 上完全看不出来。

## 断言原则

不硬编码依赖种子数据的具体条数（如"匹配 59 行"），改为断言**恒等关系**
（如"匹配 + 未匹配 = 总行数"）。种子数据变了测试也不会假失败。
