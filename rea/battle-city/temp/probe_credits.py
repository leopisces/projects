import os, sys
os.environ['SDL_VIDEODRIVER'] = 'dummy'
os.environ['SDL_AUDIODRIVER'] = 'dummy'
sys.path.insert(0, 'python')
import pygame, battle_city as bc

game = bc.Game(bc.Rom('battle_city.nes'), scale=2, sound=False)
game.poll_input = lambda: None                 # 手动注入输入
game.state = 'menu'
game.menu_code_b = 7                           # 构造模式退 7 次之后的 $4B

def tick(held=(), press=()):
    game.held = {k: True for k in held}
    game.press = {k: True for k in press}
    game.tick()

for _ in range(8):
    tick(held=(pygame.K_DOWN,))
print('↓ ×8  → $4A = $%02X' % game.menu_code_a)
for _ in range(12):
    tick(held=(pygame.K_RIGHT,))
print('→ ×12 → $4A = $%02X' % game.menu_code_a)

tick(press=(pygame.K_RETURN,))
print('按 Start → state =', game.state)

def shot(name):
    game.draw()
    pygame.image.save(game.screen, 'temp/' + name)

while game.credit_step < 3:
    tick()
shot('cr_01_two_lines.png')
while game.credit_step < 10:
    tick()
shot('cr_02_all.png')
for _ in range(bc.CREDITS_DROP_DELAY + 90):
    tick()
shot('cr_03_drop.png')
print('下落中 y =', game.drop_y, 'state =', game.state)
while game.state == 'credits':
    tick()
print('结束 → state =', game.state, 'menu_index =', game.menu_index)
