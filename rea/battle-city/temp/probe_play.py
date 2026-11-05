import sys
sys.path.insert(0,'python')
import pygame
pygame.init()
import battle_city as bc
from bc_rom import Rom

rom = Rom('battle_city.nes')
game = bc.Game(rom, scale=1, sound=False, minimized=False)
game.running = True
game.mode = 0
game.reset_run()
game.start_stage()
game.state = 'play'
game.curtain = 0
for i in range(240):
    game.tick()
print('state', game.state, 'curtain', game.curtain, 'tanks', len(game.tanks))
for t in game.tanks:
    print('  tank idx=%s kind=%s player=%s dir=%s pos=(%s,%s) alive=%s spawn=%s'
          % (t.idx, t.kind, t.player, t.dir, t.x, t.y, t.alive, getattr(t,'spawn',None)))
game.draw()
pygame.image.save(game.canvas, 'temp/s_play2.png')
print('ok temp/s_play2.png')
