import sys
sys.path.insert(0,'python')
import battle_city as bc
from bc_rom import Rom, sprite_block
rom = Rom('battle_city.nes')

def px(base, layout):
    """返回 16x16 的颜色索引像素（0..3）"""
    if layout == 'A':
        return sprite_block(rom, base)
    # 布局 B：TL=+0 TR=+1 BL=+2 BR=+3
    tl = rom.tile_pixels(base, True); tr = rom.tile_pixels(base+1, True)
    bl = rom.tile_pixels(base+2, True); br = rom.tile_pixels(base+3, True)
    return [tl[y]+tr[y] for y in range(8)] + [bl[y]+br[y] for y in range(8)]

def barrel(p):
    # 只统计“中间 8 列/行”的条带，找炮管伸出的方向
    def band(rows, cols):
        return sum(1 for y in rows for x in cols if p[y][x])
    mid_c = range(4, 12)
    mid_r = range(4, 12)
    return {
        'up':    band(range(0, 4), mid_c),
        'down':  band(range(12, 16), mid_c),
        'left':  band(mid_r, range(0, 4)),
        'right': band(mid_r, range(12, 16)),
    }

for grp, name in ((0x30,'player 0star'), (0x80,'grunt')):
    for layout in ('A','B'):
        for d in range(4):
            base = grp + d*8
            p = px(base, layout)
            b = barrel(p)
            best = max(b, key=b.get)
            print('%s base=$%02X layout %s -> 炮管朝向 %-5s  %s' % (name, base, layout, best, b))
