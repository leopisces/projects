import sys
sys.path.insert(0, 'python')
import pygame
pygame.init()
import battle_city as bc
from bc_rom import Rom, SPR_PALETTES, NES_PALETTE, sprite_block
rom = Rom('battle_city.nes')
a = bc.Assets(rom)
S = 6
W = 16*S
names = list(range(0xF0, 0x100))
cols = 8
surf = pygame.Surface((W*cols, W*2 + W*2))
surf.fill((20,20,20))
for i,t in enumerate(names):
    img = a.sprite_tile(t, SPR_PALETTES[0])
    surf.blit(pygame.transform.scale(img,(W,W)), ((i%cols)*W, (i//cols)*W))
# 按 A 布局拼 $F0 / $F1 / $F9（16x16）
for k,base in enumerate((0xF0,0xF1,0xF9)):
    blk = a.spr(base, SPR_PALETTES[0])
    surf.blit(pygame.transform.scale(blk,(W,W)), (k*W, 2*W))
pygame.image.save(surf, 'temp/cursor_tiles.png')
print('ok temp/cursor_tiles.png  (上两行=$F0..$FF 单块, 下排=A布局拼 $F0,$F1,$F9)')
