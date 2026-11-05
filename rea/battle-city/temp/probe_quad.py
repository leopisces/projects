import sys
sys.path.insert(0,'python')
import pygame
pygame.init()
import battle_city as bc
from bc_rom import Rom, SPR_PALETTES, sprite_block
rom = Rom('battle_city.nes'); a = bc.Assets(rom)
T=8; S=8; TT=T*S
def block(base, order):
    # order = (tl,bl,tr,br) 的 tile 偏移
    img = pygame.Surface((16,16))
    for i,off in enumerate(order):
        sub = a.sprite_tile(base+off, SPR_PALETTES[0])
        img.blit(sub, ((i%2)*8, (i//2)*8))
    return img
rows = [0x80,0x88,0x90,0x98]
out = pygame.Surface((TT*6, TT*len(rows)))
out.fill((35,35,35))
for r,b in enumerate(rows):
    y = r*TT
    for i in range(4):
        out.blit(pygame.transform.scale(a.sprite_tile(b+i, SPR_PALETTES[0]),(TT,TT)), (i*TT, y))
    # layout A: TL=+0 BL=+1 TR=+2 BR=+3  → 摆位 (0,0)+0 (0,1)+1 (1,0)+2 (1,1)+3
    A = block(b, (0,1,2,3))
    B = block(b, (0,2,1,3))
    out.blit(pygame.transform.scale(A,(TT,TT)), (4*TT, y))
    out.blit(pygame.transform.scale(B,(TT,TT)), (5*TT, y))
pygame.image.save(out,'temp/quad.png')
print('rows: $80 $88 $90 $98 ; cols: 4个8x8单块 | 布局A | 布局B')
