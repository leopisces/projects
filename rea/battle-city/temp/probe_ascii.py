import sys
sys.path.insert(0,'python')
import battle_city as bc
from bc_rom import Rom, sprite_block
rom = Rom('battle_city.nes')
CH = ' .o@'
def show(base, layout='A', title=''):
    p = sprite_block(rom, base)
    print('--- %s base=$%02X layout %s' % (title, base, layout))
    for y in range(16):
        print(''.join(CH[p[y][x]] for x in range(16)))
for b in (0x30, 0x80, 0x88, 0x90, 0x98):
    show(b)
