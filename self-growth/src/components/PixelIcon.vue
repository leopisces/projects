<script setup>
import { computed } from 'vue'

/**
 * 8×8 像素精灵图标。
 * 每个精灵用 8 行字符串描述，'X' 为实心像素、'.' 为透明。
 * 渲染成 SVG 并按行横向合并连续像素，减少 DOM 节点。
 * 用 shape-rendering="crispEdges" 保证放大后仍是硬边方块，不出模糊。
 */
const SPRITES = {
  // 铅笔（记录 / 编辑）
  log: [
    '.....XX.',
    '....XXXX',
    '...XXXX.',
    '..XXXX..',
    '.XXXX...',
    'XXXX....',
    'XXX.....',
    '........',
  ],
  // 带项目符号的清单（流水）
  history: [
    '........',
    'X.XXXXXX',
    '........',
    'X.XXXXXX',
    '........',
    'X.XXXXXX',
    '........',
    'X.XXXXXX',
  ],
  // 日历：两个挂环 + 实心表头 + 网点
  calendar: [
    '..X..X..',
    'XXXXXXXX',
    'XXXXXXXX',
    'X......X',
    'X.X..X.X',
    'X......X',
    'XXXXXXXX',
    '........',
  ],
  // 柱状图（统计）
  stats: [
    '........',
    '.....XX.',
    '.....XX.',
    '..XX.XX.',
    '..XX.XX.',
    'XX.XX.XX',
    'XX.XX.XX',
    '........',
  ],
  // 头像（我的）
  mine: [
    '..XXXX..',
    '.XXXXXX.',
    '.XXXXXX.',
    '..XXXX..',
    '........',
    '.XXXXXX.',
    'XXXXXXXX',
    'XXXXXXXX',
  ],
  // 拍照
  camera: [
    '........',
    '..XXXX..',
    '.XXXXXX.',
    'XXXXXXXX',
    'X.XXXX.X',
    'X.XXXX.X',
    'X......X',
    '.XXXXXX.',
  ],
  // 删除 / 关闭
  close: [
    'X......X',
    'XX....XX',
    '.XX..XX.',
    '..XXXX..',
    '..XXXX..',
    '.XX..XX.',
    'XX....XX',
    'X......X',
  ],
  // 垃圾桶（删除）
  trash: [
    '.XXXXXX.',
    'XXXXXXXX',
    '........',
    '.XXXXXX.',
    '.X.XX.X.',
    '.X.XX.X.',
    '.XXXXXX.',
    '........',
  ],
  // 左箭头
  left: [
    '....X...',
    '...XX...',
    '..XXX...',
    '.XXXX...',
    '.XXXX...',
    '..XXX...',
    '...XX...',
    '....X...',
  ],
  // 右箭头
  right: [
    '...X....',
    '...XX...',
    '...XXX..',
    '...XXXX.',
    '...XXXX.',
    '...XXX..',
    '...XX...',
    '...X....',
  ],
  // 身体：哑铃
  body: [
    '..X..X..',
    '.XX..XX.',
    'XXXXXXXX',
    'XXXXXXXX',
    '.XX..XX.',
    '..X..X..',
    '........',
    '........',
  ],
  // 心智：灯泡
  mind: [
    '..XXXX..',
    '.X....X.',
    '.X.XX.X.',
    '.X.XX.X.',
    '.X....X.',
    '..XXXX..',
    '...XX...',
    '..XXXX..',
  ],
  // 情绪关系：心
  heart: [
    '.XX..XX.',
    'XXXXXXXX',
    'XXXXXXXX',
    'XXXXXXXX',
    '.XXXXXX.',
    '..XXXX..',
    '...XX...',
    '........',
  ],
  // 创造产出：锤子
  // 代码尖括号（写代码）
  code: [
    '........',
    '...XX...',
    '..X..X..',
    '.X....X.',
    '..X..X..',
    '...XX...',
    '........',
    '........',
  ],
  craft: [
    '.XXXXXX.',
    '.XXXXXX.',
    '...XX...',
    '...XX...',
    '...XX...',
    '...XX...',
    '...XX...',
    '...XX...',
  ],
  // 秩序：文件夹
  order: [
    'XXX.....',
    'XXXXXXX.',
    'X.....X.',
    'X.....X.',
    'X.....X.',
    'X.....X.',
    'XXXXXXX.',
    '........',
  ],
  // 星
  star: [
    '...XX...',
    '...XX...',
    'XXXXXXXX',
    '.XXXXXX.',
    '..XXXX..',
    '.XX..XX.',
    '.X....X.',
    '........',
  ],
  // 火苗（连续天数）
  flame: [
    '...XX...',
    '..XXX...',
    '..XXX...',
    '.XXXXX..',
    '.XXXXX..',
    'XXXXXXX.',
    'XXXXXXX.',
    '.XXXXX..',
  ],
  // 宝石（成长值）
  gem: [
    '..XXXX..',
    '.XXXXXX.',
    'XXXXXXXX',
    'XXX..XXX',
    'XXX..XXX',
    'XXXXXXXX',
    '.XXXXXX.',
    '..XXXX..',
  ],
  // 宝石（填充版，用在开屏 / 大图位置）：上宽下尖的钻石剪影
  gemFull: [
    '..XXXX..',
    '.XXXXXX.',
    'XXXXXXXX',
    'XXXXXXXX',
    'XXXXXXXX',
    '.XXXXXX.',
    '..XXXX..',
    '...XX...',
  ],
  // 代码（写代码推进）
  code: [
    '........',
    '..X...X.',
    '.X...X..',
    'X...X...',
    '.X...X..',
    '..X...X.',
    '........',
    '........',
  ],
  // 抽屉/收纳箱（整理收纳）
  box: [
    '........',
    '.XXXXXX.',
    '.X....X.',
    '.XXXXXX.',
    '.X....X.',
    '.XXXXXX.',
    '........',
    '........',
  ],
  // 靶心（目标）
  target: [
    '..XXXX..',
    '.X....X.',
    'X..XX..X',
    'X..XX..X',
    'X..XX..X',
    'X..XX..X',
    '.X....X.',
    '..XXXX..',
  ],
  // 时钟（早起）
  clock: [
    '..XXXX..',
    '.X....X.',
    'X..X...X',
    'X..X...X',
    'X..XXX.X',
    'X......X',
    '.X....X.',
    '..XXXX..',
  ],
  // 勾
  check: [
    '........',
    '......XX',
    '.....XX.',
    'X...XX..',
    'XX.XX...',
    '.XXXX...',
    '..XX....',
    '........',
  ],
  // 加号
  plus: [
    '...XX...',
    '...XX...',
    '...XX...',
    'XXXXXXXX',
    'XXXXXXXX',
    '...XX...',
    '...XX...',
    '........',
  ],
  // 齿轮（设置）
  gear: [
    '...XX...',
    'X.XXXX.X',
    '.XXXXXX.',
    '.XX..XX.',
    '.XX..XX.',
    '.XXXXXX.',
    'X.XXXX.X',
    '...XX...',
  ],
  // 数据库
  db: [
    '..XXXX..',
    '.X....X.',
    'XXXXXXXX',
    'X......X',
    'X......X',
    'XXXXXXXX',
    '.X....X.',
    '..XXXX..',
  ],
  // 导出
  download: [
    '...XX...',
    '...XX...',
    '...XX...',
    'X..XX..X',
    'XX.XX.XX',
    '.XXXXXX.',
    '..XXXX..',
    '........',
  ],
  // 上传 / 导入
  upload: [
    '..XXXX..',
    '.XXXXXX.',
    'XX.XX.XX',
    'X..XX..X',
    '...XX...',
    '...XX...',
    '...XX...',
    '........',
  ],
  // 眼睛（显示 / 隐藏密钥）
  eye: [
    '........',
    '..XXXX..',
    '.X....X.',
    'X..XX..X',
    'X..XX..X',
    '.X....X.',
    '..XXXX..',
    '........',
  ],
  // 奖杯（等级）
  trophy: [
    'XXXXXXXX',
    'X.XXXX.X',
    'X.XXXX.X',
    '.XXXXXX.',
    '..XXXX..',
    '...XX...',
    '..XXXX..',
    '.XXXXXX.',
  ],
  // 闪电（能量 / 负向）
  bolt: [
    '....XX..',
    '...XX...',
    '..XX....',
    '.XXXXX..',
    '...XX...',
    '..XX....',
    '.XX.....',
    '........',
  ],
  // 四角星（AI）
  spark: [
    '...XX...',
    '...XX...',
    '..XXXX..',
    'XXXXXXXX',
    'XXXXXXXX',
    '..XXXX..',
    '...XX...',
    '...XX...',
  ],
  // 文档（规则）
  book: [
    'XXXXXXXX',
    'X......X',
    'X.XXXX.X',
    'X......X',
    'X.XXXX.X',
    'X......X',
    'XXXXXXXX',
    '........',
  ],
}

const props = defineProps({
  name: { type: String, required: true },
  size: { type: [Number, String], default: 16 },
})

const rows = computed(() => SPRITES[props.name] || [])

/** 每行把连续像素合并成一个 rect：8×8 最多 64 个节点，合并后通常 <16 */
const rects = computed(() => {
  const out = []
  rows.value.forEach((row, y) => {
    let start = -1
    for (let x = 0; x <= row.length; x++) {
      const on = x < row.length && row[x] !== '.' && row[x] !== ' '
      if (on && start < 0) start = x
      else if (!on && start >= 0) {
        out.push({ x: start, y, w: x - start, h: 1 })
        start = -1
      }
    }
  })
  return out
})

const box = computed(() => Math.max(1, rows.value.length))
</script>

<template>
  <svg
    class="px-icon"
    :width="size"
    :height="size"
    :viewBox="`0 0 ${box} ${box}`"
    shape-rendering="crispEdges"
    fill="currentColor"
    aria-hidden="true"
  >
    <rect v-for="(r, i) in rects" :key="i" :x="r.x" :y="r.y" :width="r.w" :height="r.h" />
  </svg>
</template>

<style scoped>
.px-icon {
  display: block;
  flex-shrink: 0;
}
</style>
