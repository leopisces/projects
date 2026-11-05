import sys
sys.path.insert(0,'python')
import pygame
pygame.init()
import battle_city as bc
from bc_rom import Rom

rom = Rom('battle_city.nes')
# --- 选单：光标是否 16x16 坦克 ---
g = bc.Game(rom, scale=1, sound=False, minimized=False)
g.state='menu'; g.menu_index=0; g.title_scroll=bc.TITLE_SCROLL_FRAMES; g.frames.lo=0
g.draw(); pygame.image.save(g.canvas,'temp/c_menu.png')
print('menu cursor x=%d y=%d' % (bc.MENU_CURSOR_X, bc.MENU_CURSOR_Y0))
# --- 关卡 1：敌人朝向 ---
g.mode=0; g.reset_run(); g.start_stage(); g.state='play'; g.curtain=0
for _ in range(240): g.tick()
g.draw(); pygame.image.save(g.canvas,'temp/c_play.png')
for t in g.tanks:
    print('  %s dir=%s pos=(%.0f,%.0f)' % ('P1' if t.player else 'enemy', t.dir, t.x, t.y))
