// server/search.js — 关键词检索条件生成
//
// 硬件人查料的真实习惯是「名称 + 封装」一起说：`04381.25WR F0603`、`1uF C0603`。
// 但这两段信息分别存在 name 和 package 两列里，任何单列 LIKE '%04381.25WR F0603%'
// 都必然查不到——数据库里从来没有哪一列同时含这两段。
//
// 所以关键词按空格切成多个词，语义是：
//   词与词之间 AND（每个词都得命中），词内部对各列 OR（命中任意一列即可）
//
//   q = "04381.25WR F0603"
//   → (name LIKE '%04381.25WR%' OR package LIKE '%04381.25WR%' OR ...)
//     AND (name LIKE '%F0603%' OR package LIKE '%F0603%' OR ...)
//
// 刻意不解析「第一个词是名称、第二个是封装」这种位置约定：
// 用户记不住顺序，而且同样的机制顺带支持 `0603 电阻`、`C0603 LCSC`、`1uF 已归位`
// 等任意维度组合，比写死字段映射更通用。
//
// 单个词时退化成原来的行为，完全兼容。多词场景是原行为的**超集**：
// 原来能整串命中某一列的（如 `TAIYO YUDEN`），拆成两词后那一列仍然两词都命中，
// 依旧会被查出来，不存在结果变少的回退。
//
// 另一件事：检索词与被搜索的列两侧都会做等价字符归一，
// 让 `100kΩ` 无论用哪个码点的欧姆符号都能查到。详见下面 DB_FOLD_PAIRS 处的说明。

// 分词上限。防止有人粘一整行 TSV 进来生成上百个 LIKE 拖垮查询；
// 超出的词直接丢弃而不是报错——前面的词已经足够收窄结果了。
const MAX_TERMS = 8

// ---------------------------------------------------------------------------
// 等价字符归一
//
// 电子物料名称里有一批「肉眼完全一样、码点却不同」的字符，最典型的是欧姆：
//
//   Ω  U+03A9  GREEK CAPITAL LETTER OMEGA  ← 中文输入法、本项目 DB 里存的
//   Ω  U+2126  OHM SIGN                    ← 部分输入法、从 PDF / 立创商城复制时带的
//
// 同理还有微法的 μ：U+03BC（希腊 mu）与 U+00B5（MICRO SIGN），`10μF` 天天遇到。
// SQLite 的 LIKE 只对 ASCII 做大小写折叠，对这类等价字符一律按字节比——
// 用户粘了 U+2126 进来就永远查不到 U+03A9 的数据，且因为长得一模一样，
// 他只会觉得「搜索坏了」，根本不可能想到是字符问题。
//
// 两侧都要归一，因为两个方向都真实存在：
//   输入侧变体 → DB 侧规范：用户从 PDF 复制 U+2126，DB 里是 U+03A9
//   输入侧规范 → DB 侧变体：批量导入把 PDF 里的 U+2126 写进了库，用户正常打 U+03A9
// 只归一一侧就会留下反向的坑。
// ---------------------------------------------------------------------------

/**
 * 词侧归一：直接用 NFKC。
 *
 * 选 NFKC 而不是手写替换表，是因为它一次性覆盖 U+2126→U+03A9、U+00B5→U+03BC、
 * 全角 ＲＯ４０２→R0402 等所有兼容等价，且经实测对本项目现有数据
 * （含「UNI-ROYAL(厚声)」这类中日韩厂商名）零改动 —— 中文汉字不在兼容分解范围内。
 *
 * 注意 NFKC 不折叠大小写，ASCII 的大小写交给 SQLite LIKE 自己处理（它对 ASCII
 * 本来就不敏感）。刻意不做 toLowerCase()：那会连带影响 DB 侧的比较语义，
 * 而 DB 侧无法用 SQL 廉价地做 Unicode 小写化，两侧就不对称了。
 */
export function normalizeTerm(term) {
  return String(term ?? '').normalize('NFKC')
}

/**
 * DB 侧归一要处理的等价字符对：[变体码点, 规范码点]。
 *
 * SQLite 没有内置 NFKC，只能用 REPLACE 定点替换，所以这里**刻意只收录**
 * 电子物料真实会遇到的少数几个：每加一对都会给每个被搜索的列套一层 REPLACE，
 * 是有查询成本的，不能照搬整张 Unicode 兼容表。
 *
 * 归一方向与 normalizeTerm（NFKC）保持一致：一律变体 → 规范，
 * 否则两侧归到不同目标上，等于没归。
 */
const DB_FOLD_PAIRS = [
  [0x2126, 0x03a9], // Ω OHM SIGN            → GREEK CAPITAL OMEGA
  [0x00b5, 0x03bc] // µ MICRO SIGN          → GREEK SMALL MU
]

/**
 * 把列名包装成「归一后的列」表达式。
 *
 * 用 char() 而不是把字符字面量拼进 SQL：这些码点长得和普通字符一样，
 * 直接内联会让 SQL 里出现肉眼无法区分的两个 Ω，以后没人看得懂也改不对。
 * char(8486) / char(937) 是自解释的。
 *
 * 导出是为了让「严格相等」的匹配（如按名称+封装找候选库存）复用同一套归一：
 * 严格相等比模糊搜索更需要归一 —— `=` 连子串兜底都没有，
 * 名称里一个 U+2126 就会让肉眼完全相同的两条记录判不相等。
 *
 * @param {string} column 已带前缀的完整列名，来自调用方白名单
 * @returns {string} 形如 REPLACE(REPLACE(name, char(8486), char(937)), ...)
 */
export function foldedColumn(column) {
  return DB_FOLD_PAIRS.reduce(
    (expr, [from, to]) => `REPLACE(${expr}, char(${from}), char(${to}))`,
    column
  )
}

/**
 * 把关键词切成检索词。空格（含中文全角空格）为分隔符，空串返回空数组。
 * 每个词都做等价字符归一，让 U+2126 与 U+03A9 这类变体互相可查。
 * @param {string} keyword
 * @returns {string[]}
 */
export function splitKeyword(keyword) {
  return String(keyword ?? '')
    .split(/[\s\u3000]+/)
    .filter(Boolean)
    .map(normalizeTerm)
    .filter(Boolean)
    .slice(0, MAX_TERMS)
}

/**
 * 生成关键词检索的 WHERE 片段与参数。
 *
 * @param {string} keyword  用户输入的原始关键词，可含空格
 * @param {string[]} columns 参与模糊匹配的列名（调用方的白名单，绝不来自用户输入）
 * @param {string} [prefix]  列前缀，多表 join 时传 'm.' 之类；默认无前缀
 * @returns {{ sql: string, params: string[] } | null} 关键词为空时返回 null
 */
export function buildKeywordFilter(keyword, columns, prefix = '') {
  const terms = splitKeyword(keyword)
  if (terms.length === 0 || columns.length === 0) return null

  // 列侧归一只需算一次，所有词复用同一批表达式
  const folded = columns.map(c => foldedColumn(`${prefix}${c}`))

  const params = []
  const clauses = terms.map(term => {
    const ors = folded.map(c => `${c} LIKE ?`).join(' OR ')
    for (let i = 0; i < folded.length; i++) params.push(`%${term}%`)
    return `(${ors})`
  })

  // 多词之间用 AND 串起来后整体再包一层括号，
  // 让调用方能安全地把它和其它筛选条件继续 AND 拼接。
  return { sql: `(${clauses.join(' AND ')})`, params }
}
