import os, sys
os.environ['SDL_VIDEODRIVER'] = 'dummy'
sys.path.insert(0, 'python')
import pygame
pygame.init(); pygame.display.set_mode((1,1))
from bc_rom import Rom, NES_PALETTE, tank_tile, TANK_ROM_DIR, PLAYER_A8
from battle_city import Assets, SPR_PALETTES, UP, LEFT, DOWN, RIGHT
rom = Rom('battle_city.nes'); assets = Assets(rom)
pal = SPR_PALETTES[0]
def compose(base, arr):
    s = pygame.Surface((16,16), pygame.SRCALPHA)
    for k in range(4):
        if arr == 'A':   # TL=t, BL=t+1, TR=t+2, BR=t+3  (column-major)
            tx, ty = (1,0) if k==2 else (0,1) if k==1 else (1,1) if k==3 else (0,0)
        else:            # TL=t, TR=t+1, BL=t+2, BR=t+3  (row-major)
            tx, ty = (k & 1, k >> 1)
        tid = base + k
        px = rom.tile_pixels(tid, True)
        for y in range(8):
            for x in range(8):
                c = px[y][x]
                if c: s.set_at((tx*8+x, ty*8+y), NES_PALETTE[pal[c]])
    return s
dirs = [(UP,'UP'),(LEFT,'LEFT'),(DOWN,'DOWN'),(RIGHT,'RIGHT')]
Z = 6; W = 16*Z+16; rows = 2
surf = pygame.Surface((W*4, W*2)); surf.fill((30,30,36))
font = pygame.font.Font(None, 20)
for r,arr in enumerate(('A','B')):
    for i,(d,dn) in enumerate(dirs):
        base = tank_tile(PLAYER_A8[0], TANK_ROM_DIR[d], 0x30)
        img = compose(base, arr)
        x, y = i*W, r*W
        surf.blit(pygame.transform.scale(img,(64,64)), (x+8, y+14))
        surf.blit(font.render(f'{arr} {dn} ${base:02X}', True, (230,230,230)), (x+4, y))
pygame.image.save(surf, '/tmp/tanks_ab.png'); print('ok')
