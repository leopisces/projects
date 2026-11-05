import sys
sys.path.insert(0, 'python')
from bc_rom import Rom

rom = Rom('battle_city.nes')
def art(tid):
    px = rom.tile_pixels(tid)          # PT1 背景表
    return [''.join('#' if px[y][x] else '.' for x in range(8)) for y in range(8)]

for t in range(0x5C, 0x70):
    print('  $%02X   ' % t)
    for r in art(t):
        print('  ' + r)
    print()
