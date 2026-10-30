"""Battle City ROM 读取层：CHR 图形、调色板、关卡地图、敌方配置。

所有数据都从原版 ROM 实时解析，不依赖外部素材文件。
ROM 布局（已验证）：
  - iNES 头 16 字节
  - PRG 16 KB @ CPU $C000-$FFFF
  - CHR  8 KB：前三 4 KB = PT0 精灵图形表，后 4 KB = PT1 背景图形表
"""
import os

# 标准 NES 2C02 调色板（64 色，RGB）
NES_PALETTE = [
    (0x62, 0x62, 0x62), (0x00, 0x1F, 0xB2), (0x24, 0x04, 0xC8), (0x52, 0x00, 0xB2),
    (0x76, 0x00, 0x61), (0x8C, 0x00, 0x00), (0x8C, 0x17, 0x00), (0x74, 0x3B, 0x00),
    (0x48, 0x58, 0x00), (0x00, 0x59, 0x00), (0x00, 0x59, 0x00), (0x00, 0x53, 0x0F),
    (0x00, 0x51, 0x3C), (0x00, 0x00, 0x00), (0x00, 0x00, 0x00), (0x00, 0x00, 0x00),
    (0xAB, 0xAB, 0xAB), (0x01, 0x57, 0xFF), (0x44, 0x66, 0xFF), (0x7C, 0x3D, 0xFF),
    (0xA0, 0x00, 0xFF), (0xBF, 0x00, 0x87), (0xBF, 0x29, 0x00), (0xB2, 0x5F, 0x00),
    (0x8A, 0x83, 0x00), (0x00, 0x8A, 0x00), (0x00, 0x8A, 0x18), (0x00, 0x83, 0x4A),
    (0x00, 0x6A, 0x7D), (0x00, 0x00, 0x00), (0x00, 0x00, 0x00), (0x00, 0x00, 0x00),
    (0xFF, 0xFF, 0xFF), (0x3C, 0x9B, 0xFF), (0x7B, 0xD0, 0xFF), (0xB4, 0xAB, 0xFF),
    (0xE8, 0xA8, 0xFF), (0xFF, 0xA0, 0xD0), (0xFF, 0x8A, 0x47), (0xFF, 0xC1, 0x3C),
    (0xE8, 0xE8, 0x00), (0x5A, 0xEA, 0x00), (0x29, 0xFF, 0x29), (0x29, 0xF8, 0x88),
    (0x00, 0xDE, 0xD0), (0x4F, 0x4F, 0x4F), (0x00, 0x00, 0x00), (0x00, 0x00, 0x00),
    (0xFF, 0xFF, 0xFF), (0xB4, 0xDF, 0xFF), (0xD0, 0xFF, 0xFF), (0xE8, 0xE8, 0xFF),
    (0xFF, 0xD0, 0xFF), (0xFF, 0xC1, 0xE8), (0xFF, 0xD0, 0xB4), (0xFF, 0xE8, 0xA0),
    (0xFF, 0xFF, 0x50), (0xB4, 0xFF, 0x50), (0x7B, 0xFF, 0x7B), (0x50, 0xFF, 0xB4),
    (0x50, 0xFF, 0xDE), (0xA0, 0xA0, 0xA0), (0x00, 0x00, 0x00), (0x00, 0x00, 0x00),
]

# ---- 精灵 tile（PT0，tile id 直接索引）----
# 坦克 tile 公式（REA/Ghidra 确认，来自 $DFB6 + sub_DA73）：
#   tile = ($A8 & $F0) + $B0(动画帧) + dir*8
# $A8 的高半字节是坦克类型，dir 是朝向（0=上 1=左 2=下 3=右）。
# 注意：$DF46 是"出生闪光动画"的绘制，不是坦克本体，别搞混。
TANK_TYPE_BASE = {
    'basic': 0x80,      # 基本坦克
    'fast':  0xA0,      # 快速坦克
    'power': 0xC0,      # 火力坦克
    'armor': 0xE0,      # 装甲坦克
}
# 玩家坦克（$DF33 → sub_DEF0，A=$08 → tile=$F9）与 $F1 组成两组图：
#   $F1 = 一组，$F9 = 另一组；原版玩家坦克只有 2 张（竖/横），
#   上下朝向共用同一张。16x16 = T, T+1, T+2, T+3（左上/左下/右上/右下）
PLAYER_TILE = 0xF1
PLAYER_TILE_SIDE = 0xF9


def tank_tile(type_base, direction, frame=0):
    """按 ROM $DFB6 的公式计算坦克右上 tile 编号。"""
    return (type_base + frame + direction * 8) & 0xFF


EAGLE_TILES = (0xC8, 0xCA, 0xC9, 0xCB)          # TL, TR, BL, BR
EAGLE_DEAD_TILES = (0xCC, 0xCE, 0xCD, 0xCF)
POWERUP_BASE = 0x81                   # 道具 tile = $81 + type*4

# ---- 背景 tile（PT1，tile id 直接索引）----
BG_EMPTY, BG_BRICK, BG_STEEL_1, BG_STEEL_2 = 0x00, 0x0F, 0x10, 0x20
BG_WATER, BG_ICE, BG_FOREST = 0x12, 0x21, 0x22

# ---- 精灵调色板（$D555，4 组 × 4 色）----
SPR_PALETTES = (
    (0x0F, 0x18, 0x27, 0x38),        # SP0 玩家坦克 / UI
    (0x0F, 0x0A, 0x1B, 0x3B),        # SP1 文字/数字
    (0x0F, 0x0C, 0x10, 0x20),        # SP2 绿灰（敌方基本型）
    (0x0F, 0x04, 0x16, 0x20),        # SP3 紫灰（敌方强化型）
)
# 4 种敌方坦克用到的精灵调色板
ENEMY_PALETTE = (2, 1, 3, 3)          # basic, fast, power, armor

STAGE_TABLE = 0xF07A
STAGE_SIZE = 91
STAGE_COUNT = 36

# ---- 地形码 → (每格 4 个背景 tile, 调色板槽) ----
# 顺序: TL, TR, BL, BR  (来自 ROM 的 tbl_DACB_block_data)
BLOCK_DEF = {
    0x0: ((0x00, 0x0F, 0x00, 0x0F), 0),   # 半砖
    0x1: ((0x00, 0x00, 0x0F, 0x0F), 0),
    0x2: ((0x0F, 0x00, 0x0F, 0x00), 0),
    0x3: ((0x0F, 0x0F, 0x00, 0x00), 0),
    0x4: ((0x0F,) * 4, 0),                # 全砖
    0x5: ((0x20, 0x10, 0x20, 0x10), 3),   # 半钢
    0x6: ((0x20, 0x20, 0x10, 0x10), 3),
    0x7: ((0x10, 0x20, 0x10, 0x20), 3),
    0x8: ((0x10, 0x10, 0x20, 0x20), 3),
    0x9: ((0x10,) * 4, 3),                # 全钢
    0xA: ((0x12,) * 4, 1),                # 水
    0xB: ((0x22,) * 4, 2),                # 森林
    0xC: ((0x21,) * 4, 3),                # 冰
}


def find_rom():
    """按优先级找 ROM：环境变量 → 当前目录 → 上级目录 → 桌面。"""
    cands = []
    env = os.environ.get('BATTLE_CITY_ROM')
    if env:
        cands.append(env)
    here = os.path.dirname(os.path.abspath(__file__))
    for base in (here, os.path.dirname(here), os.path.dirname(os.path.dirname(here))):
        cands += [os.path.join(base, 'battle_city.nes'),
                  os.path.join(base, '坦克大战.nes')]
    cands.append(os.path.join(os.path.expanduser('~'), 'Desktop', '坦克大战.nes'))
    for c in cands:
        if os.path.isfile(c):
            return c
    raise FileNotFoundError(
        '找不到 battle_city.nes。请用环境变量指定：'
        'set BATTLE_CITY_ROM=D:\\path\\to\\battle_city.nes')


class Rom:
    def __init__(self, path=None):
        self.path = path or find_rom()
        data = open(self.path, 'rb').read()
        if data[:4] != b'NES\x1a':
            raise ValueError('不是 iNES 文件: ' + self.path)
        self.prg = data[16:16 + data[4] * 16384]
        self.chr = data[16 + len(self.prg):]
        if len(self.chr) < 8192:
            raise ValueError('CHR 数据不足')

    # ---- PRG ----
    def prg_byte(self, addr):
        return self.prg[addr - 0xC000]

    def stage_index(self, n):
        """关卡号 → 表索引。A >= $24 回绕 $23（与 sub_F000 一致）。"""
        a = 0x24 if n == 0xFF else n
        if a >= 0x24:
            a -= 0x23
        return max(0, min(STAGE_COUNT - 1, a - 1))

    def stage_grid(self, n):
        """关卡 n → 13×13 地形码网格（nibble 流，每行 7 字节取前 13 个）。"""
        idx = self.stage_index(n)
        off = STAGE_TABLE - 0xC000 + idx * STAGE_SIZE
        rec = self.prg[off:off + STAGE_SIZE]
        grid = []
        for row in range(13):
            nib = []
            for b in rec[row * 7:(row + 1) * 7]:
                nib += [b >> 4, b & 0x0F]
            grid.append(nib[:13])
        return grid

    def stage_enemies(self, n):
        """关卡 n → (基本, 快速, 火力, 装甲) 各类型数量，合计 20。"""
        idx = (n - 1) % 35
        o = 0xE578 - 0xC000 + idx * 4
        return tuple(self.prg[o:o + 4])

    def stage_types(self, n):
        """关卡 n → 第 1-4 个出场的敌方类型字节（$80/$A0/$C0/$E0）。"""
        idx = (n - 1) % 35
        o = 0xE4EC - 0xC000 + idx * 4
        return tuple(self.prg[o:o + 4])

    # ---- CHR ----
    def tile_pixels(self, index, sprite=False):
        """tile → 8×8 的 0..3 颜色索引。sprite=True 用 PT0，否则 PT1。"""
        off = index * 16 + (0 if sprite else 4096)
        return [[((self.chr[off + y] >> (7 - x)) & 1) |
                 (((self.chr[off + y + 8] >> (7 - x)) & 1) << 1)
                 for x in range(8)] for y in range(8)]

    def bg_palette(self, slot_set=0, slot=0):
        """背景调色板。$D565 起 9 组 × 16 字节，每组 4 槽 × 4 色。"""
        o = 0xD565 - 0xC000 + slot_set * 16 + slot * 4
        return tuple(self.prg[o:o + 4])


def sprite_block(rom, base):
    """精灵 16×16 块：TL=base, BL=base+1, TR=base+2, BR=base+3。"""
    tl = rom.tile_pixels(base, True)
    bl = rom.tile_pixels(base + 1, True)
    tr = rom.tile_pixels(base + 2, True)
    br = rom.tile_pixels(base + 3, True)
    return [tl[y] + tr[y] for y in range(8)] + [bl[y] + br[y] for y in range(8)]
