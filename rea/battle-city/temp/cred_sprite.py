import sys
sys.path.insert(0, 'python')
from bc_rom import Rom, sprite_block

rom = Rom('battle_city.nes')
def show(base):
    blk = sprite_block(rom, base)
    print('  16x16 @ $%02X (TL=%02X BL=%02X TR=%02X BR=%02X)' % (base, base, base+1, base+2, base+3))
    for row in blk:
        print('   ' + ''.join('#' if v else '.' for v in row))
    print()
for b in (0x99, 0x9D, 0xA1):
    show(b)
