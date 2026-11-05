import os, sys
os.environ['SDL_VIDEODRIVER'] = 'dummy'
sys.path.insert(0, 'python')
import pygame
pygame.init(); pygame.display.set_mode((1,1))
from bc_rom import Rom, NES_PALETTE, tank_tile, TANK_ROM_DIR, PLAYER_A8, TANK_TYPE_BASE
from battle_city import Assets, SPR_PALETTES, UP, LEFT, DOWN, RIGHT

rom = Rom('battle_city.nes'); assets = Assets(rom)
dirnames = {UP:'UP', LEFT:'LEFT', DOWN:'DOWN', RIGHT:'RIGHT'}
cells = []
# 玩家 P1：0星，四方向，base=$30
for d in (UP, LEFT, DOWN, RIGHT):
    base = tank_tile(PLAYER_A8[0], TANK_ROM_DIR[d], 0x30)
    cells.append((f'P1 {dirnames[d]} ${base:02X}', assets.spr(base, SPR_PALETTES[0])))
# 玩家 1..3 星朝下
for star in (1,2,3):
    base = tank_tile(PLAYER_A8[star], TANK_ROM_DIR[DOWN], 0x30)
    cells.append((f'P1 {star}* ${base:02X}', assets.spr(base, SPR_PALETTES[0])))
# 敌人四种朝下
for name, tb in (('grunt',0x80),('fast',0xA0),('power',0xC0),('armor',0xE0)):
    base = tank_tile(tb, TANK_ROM_DIR[DOWN])
    cells.append((f'{name} ${base:02X}', assets.spr(base, SPR_PALETTES[0])))

Z, W, H = 4, 96, 116
surf = pygame.Surface((W*len(cells), H)); surf.fill((30,30,36))
font = pygame.font.Font(None, 22)
for i,(label,img) in enumerate(cells):
    x = i*W
    pygame.draw.rect(surf, (60,60,70), (x+8, 30, 80, 80))
    surf.blit(pygame.transform.scale(img,(64,64)), (x+14, 40))
    surf.blit(font.render(label, True, (230,230,230)), (x+6, 6))
pygame.image.save(surf, '/tmp/tanks.png')
print('saved')

# 代码路径 vs 直接按 PT0 拼贴（pal3）逐像素比对
pal = SPR_PALETTES[3]
for d in (UP, LEFT, DOWN, RIGHT):
    base = tank_tile(PLAYER_A8[0], TANK_ROM_DIR[d], 0x30)
    code = assets.spr(base, pal)
    truth = pygame.Surface((16,16), pygame.SRCALPHA)
    for ty in range(2):
        for tx in range(2):
            tid = base + ty*2 + tx
            px = rom.tile_pixels(tid, True)
            for y in range(8):
                for x in range(8):
                    c = px[y][x]
                    if c:
                        truth.set_at((tx*8+x, ty*8+y), NES_PALETTE[pal[c]])
    same = all((code.get_at((x,y))[:3] == truth.get_at((x,y))[:3])
               for x in range(16) for y in range(16))
    print(dirnames[d], 'base=%02X' % base, 'match=%s' % same)
