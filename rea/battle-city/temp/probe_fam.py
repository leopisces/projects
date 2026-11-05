import sys
sys.path.insert(0,'python')
import pygame
pygame.init()
import battle_city as bc
from bc_rom import Rom, SPR_PALETTES
rom = Rom('battle_city.nes'); a = bc.Assets(rom)
S=5; W=16*S
fam = [0x30,0x38,0x40,0x48, 0x50,0x70,0x90, 0xF1,0xF5,0xF9, 0x80,0x88,0xA0,0xC0,0xE0,0xE8]
surf = pygame.Surface((W*8, W*2))
surf.fill((30,30,30))
for i,b in enumerate(fam):
    img = a.spr(b, SPR_PALETTES[0])
    surf.blit(pygame.transform.scale(img,(W,W)), ((i%8)*W, (i//8)*W))
pygame.image.save(surf,'temp/tank_catalog.png')
print('order: 30 38 40 48 | 50 70 90 F1 | F5 F9 80 88 | A0 C0 E0 E8')
