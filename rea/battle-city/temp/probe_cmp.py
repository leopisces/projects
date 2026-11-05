import sys
sys.path.insert(0,'python')
import pygame
pygame.init()
import battle_city as bc
from bc_rom import Rom, SPR_PALETTES, tank_tile, PLAYER_A8, TANK_ROM_DIR, TANK_TYPE_BASE

rom = Rom('battle_city.nes')
game = bc.Game(rom, scale=1, sound=False, minimized=False)
game.running = True; game.mode = 0; game.reset_run(); game.start_stage()
game.state='play'; game.curtain=0
for _ in range(240): game.tick()
game.draw()

S=8
crop = pygame.Surface((16,16))
out = pygame.Surface((16*S*4, 16*S))
out.fill((40,40,40))
# 1) 游戏内玩家坦克实际像素
crop.blit(game.canvas, (0,0), (80,208,16,16))
out.blit(pygame.transform.scale(crop,(16*S,16*S)), (0,0))
# 2) 直接渲染 tank_tile 对应的块
for i,(a8,base,dir_,pal) in enumerate(((PLAYER_A8[0],0x30,2,0),(0x80,0x00,0,0),(0x80,0x00,0,1))):
    t = tank_tile(a8, dir_, base)
    img = game.assets.spr(t, SPR_PALETTES[pal])
    out.blit(pygame.transform.scale(img,(16*S,16*S)), ((i+1)*16*S, 0))
    print('slot',i+1,'tile=$%02X'%t,'pal',pal)
pygame.image.save(out,'temp/cmp_tank.png')
print('ok temp/cmp_tank.png  [游戏内P1 | $30族朝上 | $80族朝下pal0 | $80族朝下pal1]')
