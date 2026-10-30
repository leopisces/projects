"""坦克大战 (Battle City, Namco 1985) —— Python 复刻版

图形、关卡地图、调色板、敌方配置全部实时取自原版 ROM。
运行：python battle_city.py [--rom 路径] [--scale 3] [--atlas]

操作：方向键/WASD 移动   空格/J 开火   Enter 暂停   Esc 退出
"""
import argparse
import random
import sys

import pygame

from audio import Audio
from bc_rom import (Rom, NES_PALETTE, ENEMY_BASE, PLAYER_BASE, EAGLE_TILES,
                    EAGLE_DEAD_TILES, POWERUP_BASE, SPR_PALETTES, ENEMY_PALETTE,
                    BLOCK_DEF, BG_BRICK, BG_STEEL_1, BG_STEEL_2,
                    sprite_block)

SCREEN_W, SCREEN_H = 256, 240
SCALE = 1
FIELD_X, FIELD_Y = 16, 16
BLOCK, TILE = 16, 8
GRID = 13                       # 13 × 13 格
TG = GRID * 2                   # 26 × 26 个 8px tile
FIELD_W = GRID * BLOCK
HUD_Y = 224

FPS = 60
UP, LEFT, DOWN, RIGHT = 0, 1, 2, 3
DVEC = {UP: (0, -1), LEFT: (-1, 0), DOWN: (0, 1), RIGHT: (1, 0)}

EMPTY, BRICK, STEEL, WATER, FOREST, ICE = 0, 1, 2, 3, 4, 5
BLOCKING = {BRICK, STEEL, WATER}

# 坦克参数：速度(px/帧)、子弹速度、最大子弹数
TANK_STATS = {
    'player':  dict(speed=1.0, bullet=3.0, maxb=1, hp=1),
    'basic':   dict(speed=0.75, bullet=2.0, maxb=1, hp=1),
    'fast':    dict(speed=1.5, bullet=2.0, maxb=1, hp=1),
    'power':   dict(speed=0.9, bullet=3.0, maxb=2, hp=1),
    'armor':   dict(speed=0.75, bullet=2.0, maxb=1, hp=4),
}
ENEMY_KIND = {0: 'basic', 1: 'fast', 2: 'power', 3: 'armor'}
KIND_INDEX = {v: k for k, v in ENEMY_KIND.items()}
ENEMY_SCORE = {'basic': 100, 'fast': 200, 'power': 300, 'armor': 400}

POWERUP_NAMES = ('helm', 'clock', 'shovel', 'star', 'grenade', 'tank')


# --------------------------------------------------------------------------
# 贴图缓存
# --------------------------------------------------------------------------
class Assets:
    def __init__(self, rom):
        self.rom = rom
        self._tile = {}
        self._spr = {}

    def tile(self, index, pal):
        key = (index, pal, False)
        s = self._tile.get(key)
        if s is None:
            s = pygame.Surface((TILE, TILE))
            s.set_colorkey((0, 0, 0))
            px = self.rom.tile_pixels(index, False)
            for y in range(TILE):
                for x in range(TILE):
                    c = px[y][x]
                    if c:
                        s.set_at((x, y), NES_PALETTE[pal[c]])
            self._tile[key] = s
        return s

    def spr(self, base, pal):
        key = (base, pal)
        s = self._spr.get(key)
        if s is None:
            s = pygame.Surface((16, 16))
            s.set_colorkey((0, 0, 0))
            px = sprite_block(self.rom, base)
            for y in range(16):
                for x in range(16):
                    c = px[y][x]
                    if c:
                        s.set_at((x, y), NES_PALETTE[pal[c]])
            self._spr[key] = s
        return s

    def sprite_tile(self, index, pal):
        """单个 8×8 精灵 tile（PT0）。"""
        key = (index, pal, True)
        s = self._tile.get(key)
        if s is None:
            s = pygame.Surface((TILE, TILE))
            s.set_colorkey((0, 0, 0))
            px = self.rom.tile_pixels(index, True)
            for y in range(TILE):
                for x in range(TILE):
                    c = px[y][x]
                    if c:
                        s.set_at((x, y), NES_PALETTE[pal[c]])
            self._tile[key] = s
        return s


def scale_sprite(src, size):
    return pygame.transform.scale(src, (size, size))


# --------------------------------------------------------------------------
# 场地
# --------------------------------------------------------------------------
class Field:
    def __init__(self, rom, stage):
        self.grid = [[EMPTY] * TG for _ in range(TG)]
        self.load(rom, stage)

    def load(self, rom, stage):
        """按关卡 nibble 表填充地形（每格 = 2×2 个 8px tile）。"""
        codes = rom.stage_grid(stage)
        for r in range(GRID):
            for c in range(GRID):
                self.set_block(c, r, codes[r][c])

    def set_block(self, col, row, code):
        tiles, _ = BLOCK_DEF.get(code & 0x0F, ((0x00,) * 4, 0))
        kinds = []
        for t in tiles:
            if t == BG_BRICK:
                kinds.append(BRICK)
            elif t in (BG_STEEL_1, BG_STEEL_2):
                kinds.append(STEEL)
            elif t == 0x12:
                kinds.append(WATER)
            elif t == 0x21:
                kinds.append(ICE)
            elif t == 0x22:
                kinds.append(FOREST)
            else:
                kinds.append(EMPTY)
        # tiles 顺序 TL, TR, BL, BR
        self.grid[row * 2 + 0][col * 2 + 0] = kinds[0]
        self.grid[row * 2 + 0][col * 2 + 1] = kinds[1]
        self.grid[row * 2 + 1][col * 2 + 0] = kinds[2]
        self.grid[row * 2 + 1][col * 2 + 1] = kinds[3]

    def kind(self, tx, ty):
        if 0 <= tx < TG and 0 <= ty < TG:
            return self.grid[ty][tx]
        return STEEL                     # 边界当墙

    def kind_at_px(self, px, py):
        """屏幕像素坐标 → 地形类型（要减去场地偏移）。"""
        return self.kind(int(px - FIELD_X) // TILE, int(py - FIELD_Y) // TILE)

    def rect_blocked(self, x, y, w=16, h=16):
        """矩形是否与阻挡地形重叠（场外也算阻挡）。"""
        x0, y0 = int(x - FIELD_X), int(y - FIELD_Y)
        if x0 < 0 or y0 < 0 or x0 + w > FIELD_W or y0 + h > FIELD_W:
            return True
        for ty in (y0 // TILE, (y0 + h - 1) // TILE):
            for tx in (x0 // TILE, (x0 + w - 1) // TILE):
                if self.kind(tx, ty) in BLOCKING:
                    return True
        return False

    def carve(self, px, py, direction):
        """子弹命中砖墙：沿弹道挖出一个 8×16 的洞。"""
        x0, y0 = int(px - FIELD_X), int(py - FIELD_Y)
        if direction in (UP, DOWN):
            cols = [x0 // TILE, (x0 + 7) // TILE]
            rows = [y0 // TILE]
        else:
            cols = [x0 // TILE]
            rows = [y0 // TILE, (y0 + 7) // TILE]
        hit = False
        for ty in rows:
            for tx in cols:
                if self.kind(tx, ty) == BRICK:
                    self.grid[ty][tx] = EMPTY
                    hit = True
                elif self.kind(tx, ty) == STEEL:
                    hit = True
        return hit

    def draw(self, surf, assets, pal_bg):
        for ty in range(TG):
            for tx in range(TG):
                k = self.grid[ty][tx]
                if k == EMPTY:
                    continue
                if k == BRICK:
                    tiles = (BG_BRICK, BG_BRICK, BG_BRICK, BG_BRICK)
                    pi = 0
                elif k == STEEL:
                    tiles = (BG_STEEL_1, BG_STEEL_1, BG_STEEL_1, BG_STEEL_1)
                    pi = 3
                elif k == WATER:
                    tiles = (0x12,) * 4
                    pi = 1
                elif k == FOREST:
                    tiles = (0x22,) * 4
                    pi = 2
                else:
                    tiles = (0x21,) * 4
                    pi = 3
                surf.blit(assets.tile(tiles[0], pal_bg[pi]),
                          (FIELD_X + tx * TILE, FIELD_Y + ty * TILE))


# --------------------------------------------------------------------------
# 实体
# --------------------------------------------------------------------------
class Tank:
    def __init__(self, x, y, kind, player=False, level=0):
        self.x, self.y = float(x), float(y)
        self.kind = kind
        self.player = player
        self.dir = UP if player else DOWN
        self.level = level
        self.st = dict(TANK_STATS[kind])
        if player and level >= 2:
            self.st['maxb'] = 2
            self.st['bullet'] = 4.0
        self.hp = self.st['hp']
        self.alive = True
        self.spawn = 0            # 出生动画倒计时
        self.shield = 0           # 护盾帧数
        self.fire_cd = 0
        self.slide = 0
        self.flash = 0            # 被打中的闪白

    @property
    def rect(self):
        return pygame.Rect(int(self.x) + 2, int(self.y) + 2, 12, 12)

    def move(self, field, direction):
        self.dir = direction
        dx, dy = DVEC[direction]
        sp = self.st['speed']
        nx, ny = self.x + dx * sp, self.y + dy * sp
        # 网格对齐（避免卡在 8px 网格之间）
        if dx:
            ny = round(ny / 8) * 8 if abs(ny - round(ny)) < 2 else ny
        if dy:
            nx = round(nx / 8) * 8 if abs(nx - round(nx)) < 2 else nx
        if not field.rect_blocked(nx, ny):
            self.x, self.y = nx, ny
            return True
        return False


class Bullet:
    def __init__(self, x, y, direction, speed, owner, power=1):
        self.x, self.y = float(x), float(y)
        self.dir = direction
        self.speed = speed
        self.owner = owner
        self.power = power
        self.alive = True


class Explosion:
    def __init__(self, x, y, big=True):
        self.x, self.y = x, y
        self.t = 0
        self.life = 18 if big else 10
        self.big = big


class Powerup:
    def __init__(self, x, y, ptype):
        self.x, self.y = x, y
        self.type = ptype
        self.t = 0
        self.alive = True


# --------------------------------------------------------------------------
# 游戏
# --------------------------------------------------------------------------
class Game:
    MAX_ENEMIES_ON_SCREEN = 4
    ENEMIES_PER_STAGE = 20
    TOTAL_LIVES = 3

    def __init__(self, rom, scale=SCALE, sound=True, corner=True,
                 always_on_top=False, borderless=False):
        pygame.init()
        pygame.display.set_caption('Battle City (Namco 1985) — Python 复刻')
        self.scale = scale
        self.canvas = pygame.Surface((SCREEN_W, SCREEN_H))
        w, h = SCREEN_W * scale, SCREEN_H * scale
        flags = pygame.NOFRAME if borderless else 0
        self.screen = pygame.display.set_mode((w, h), flags)
        if corner:
            self.move_to_corner(always_on_top=always_on_top)
        self.clock = pygame.time.Clock()
        self.rom = rom
        self.assets = Assets(rom)
        self.audio = Audio(enabled=sound)
        self.bg_pal = [rom.bg_palette(0, i) for i in range(4)]
        self.font_cache = {}
        self.paused = False
        self.running = True
        self.state = 'play'
        self.state_timer = 0
        self.new_game()

    def move_to_corner(self, margin=8, always_on_top=False):
        """把窗口挪到屏幕右下角，可选置顶（Windows 专用，失败就忽略）。"""
        try:
            import ctypes
            from ctypes import wintypes
            hwnd = pygame.display.get_wm_info().get('window')
            if not hwnd:
                return
            user32 = ctypes.windll.user32
            rect = wintypes.RECT()
            user32.GetWindowRect(hwnd, ctypes.byref(rect))
            ww, wh = rect.right - rect.left, rect.bottom - rect.top
            sw = user32.GetSystemMetrics(0)
            sh = user32.GetSystemMetrics(1)
            # 任务栏高度
            taskbar = user32.FindWindowW("Shell_TrayWnd", None)
            tb_h = 0
            if taskbar:
                r2 = wintypes.RECT()
                user32.GetWindowRect(taskbar, ctypes.byref(r2))
                if r2.top > sh // 2:
                    tb_h = r2.bottom - r2.top
            x = sw - ww - margin
            y = sh - wh - tb_h - margin
            HWND_TOPMOST = -1
            SWP_NOSIZE = 0x0001
            SWP_SHOWWINDOW = 0x0040
            insert = HWND_TOPMOST if always_on_top else 0
            user32.SetWindowPos(hwnd, insert, x, y, 0, 0,
                                SWP_NOSIZE | SWP_SHOWWINDOW)
        except Exception:
            pass

    # ---------------- 关卡 ----------------
    def new_game(self):
        self.stage = 1
        self.lives = self.TOTAL_LIVES - 1
        self.score = 0
        self.hiscore = 20000
        self.player_level = 0
        self.start_stage()

    def start_stage(self):
        self.field = Field(self.rom, self.stage)
        codes = self.rom.stage_grid(self.stage)
        self.enemy_queue = []
        counts = self.rom.stage_enemies(self.stage)
        for kind_idx, cnt in enumerate(counts):
            self.enemy_queue += [kind_idx] * cnt
        random.shuffle(self.enemy_queue)
        self.enemies_left = len(self.enemy_queue)
        self.kills = 0
        self.spawn_delay = max(30, 0xBE - self.stage * 4)
        self.spawn_timer = 90
        self.spawn_point = 0
        self.spawned = 0

        # 基地（13×13 网格中心的第 7 列第 13 行）
        self.base_x = FIELD_X + 6 * BLOCK
        self.base_y = FIELD_Y + 12 * BLOCK
        self.base_alive = True
        # 基地周围砖墙
        for c, r in ((5, 11), (6, 11), (7, 11), (5, 12), (7, 12)):
            self.field.set_block(c, r, 0x4)

        self.tanks, self.bullets, self.explosions, self.powerups = [], [], [], []
        self.player = None
        self.spawn_player()
        self.freeze = 0
        self.shovel = 0
        self.state = 'play'
        self.state_timer = 0
        self.audio.play_music('bgm')

    def spawn_player(self):
        p = Tank(FIELD_X + 4 * BLOCK, FIELD_Y + 12 * BLOCK, 'player',
                 player=True, level=self.player_level)
        p.spawn = 40
        p.shield = 120 if p.spawn else 0
        self.player = p
        self.tanks.append(p)

    # ---------------- 输入 ----------------
    def read_input(self):
        keys = pygame.key.get_pressed()
        if keys[pygame.K_UP] or keys[pygame.K_w]:
            return UP
        if keys[pygame.K_DOWN] or keys[pygame.K_s]:
            return DOWN
        if keys[pygame.K_LEFT] or keys[pygame.K_a]:
            return LEFT
        if keys[pygame.K_RIGHT] or keys[pygame.K_d]:
            return RIGHT
        return None

    def fire_pressed(self):
        keys = pygame.key.get_pressed()
        return keys[pygame.K_SPACE] or keys[pygame.K_j]

    # ---------------- 主循环 ----------------
    def run(self):
        while self.running:
            self.clock.tick(FPS)
            self.handle_events()
            if not self.paused:
                self.tick()
            self.draw()
            pygame.display.flip()

    def handle_events(self):
        for e in pygame.event.get():
            if e.type == pygame.QUIT:
                self.running = False
            elif e.type == pygame.KEYDOWN:
                if e.key == pygame.K_ESCAPE:
                    self.running = False
                elif e.key in (pygame.K_RETURN, pygame.K_p):
                    self.paused = not self.paused
                    self.audio.play_music('pause')

    # ---------------- 逻辑 ----------------
    def tick(self):
        if self.state == 'play':
            self.tick_play()
        else:
            self.state_timer -= 1
            if self.state_timer <= 0:
                if self.state == 'clear':
                    self.stage += 1
                    self.start_stage()
                elif self.state == 'gameover':
                    self.new_game()

    def tick_play(self):
        if self.freeze > 0:
            self.freeze -= 1
        if self.shovel > 0:
            self.shovel -= 1
            if self.shovel == 0 and self.base_alive:
                for c, r in ((5, 11), (6, 11), (7, 11), (5, 12), (7, 12)):
                    self.field.set_block(c, r, 0x4)

        self.tick_player()
        self.tick_enemies()
        self.tick_spawn()
        self.tick_bullets()
        self.tick_powerups()

        for t in self.tanks:
            if t.flash > 0:
                t.flash -= 1
        self.explosions = [e for e in self.explosions if self.tick_explosion(e)]

        if self.enemies_left == 0 and not any(
                t.alive and not t.player for t in self.tanks):
            self.state = 'clear'
            self.state_timer = 110
            self.audio.play_music('result')

    def tick_player(self):
        p = self.player
        if not p or not p.alive:
            return
        if p.spawn > 0:
            p.spawn -= 1
            if p.spawn == 0:
                p.shield = max(p.shield, 90)
            return
        if p.shield > 0:
            p.shield -= 1
        if p.fire_cd > 0:
            p.fire_cd -= 1

        d = self.read_input()
        if d is None:
            self.audio.set_engine(False)
        if d is not None:
            if p.move(self.field, d):
                self.audio.set_engine(True)
            else:
                self.audio.play('bump')
            p.slide = 8
        elif p.slide > 0:
            self.audio.set_engine(False)
            p.slide -= 1
            # 冰面上滑行
            if self.field.kind_at_px(p.x + 8, p.y + 8) == ICE:
                p.move(self.field, p.dir)

        if self.fire_pressed() and p.fire_cd == 0:
            mine = sum(1 for b in self.bullets if b.owner is p and b.alive)
            if mine < p.st['maxb']:
                self.shoot(p)
                p.fire_cd = 6 if p.level < 2 else 4

    def shoot(self, t):
        dx, dy = DVEC[t.dir]
        bx = t.x + 8 + dx * 9 - 3
        by = t.y + 8 + dy * 9 - 3
        self.bullets.append(
            Bullet(bx, by, t.dir, t.st['bullet'], t, power=self.player_level
                   if t.player else 1))
        if t.player:
            self.audio.play('fire')

    def tick_enemies(self):
        if self.freeze > 0:
            return
        for t in self.tanks:
            if t.player or not t.alive:
                continue
            if t.spawn > 0:
                t.spawn -= 1
                if t.spawn == 0:
                    t.shield = 30
                continue
            if t.shield > 0:
                t.shield -= 1
            if t.fire_cd > 0:
                t.fire_cd -= 1

            # 对齐到格点时按概率换向
            gx, gy = int(t.x) % BLOCK, int(t.y) % BLOCK
            if gx == 0 and gy == 0 and random.random() < 0.06:
                t.dir = self.pick_enemy_dir(t)

            if not t.move(self.field, t.dir):
                t.dir = self.pick_enemy_dir(t)

            # 开火：对准玩家/基地，或随机
            if t.fire_cd == 0 and random.random() < 0.02:
                if self.enemy_aligned(t) or random.random() < 0.35:
                    self.shoot(t)
                    t.fire_cd = 30

    def pick_enemy_dir(self, t):
        """简易 AI：较高阶段倾向追击玩家，否则压向基地。"""
        targets = []
        if self.stage >= 4 and self.player and self.player.alive:
            targets.append((self.player.x, self.player.y))
        if self.base_alive:
            targets.append((self.base_x, self.base_y))
        if targets and random.random() < 0.7:
            tx, ty = random.choice(targets)
            if abs(tx - t.x) > abs(ty - t.y):
                return RIGHT if tx > t.x else LEFT
            return DOWN if ty > t.y else UP
        return random.choice((UP, DOWN, LEFT, RIGHT))

    def enemy_aligned(self, t):
        if t.dir in (UP, DOWN):
            return abs(t.x - self.base_x) < 12 or (
                self.player and self.player.alive and abs(t.x - self.player.x) < 12)
        return False

    def tick_spawn(self):
        alive = sum(1 for t in self.tanks if t.alive and not t.player and t.spawn == 0)
        if self.enemies_left <= 0 or alive >= self.MAX_ENEMIES_ON_SCREEN:
            return
        self.spawn_timer -= 1
        if self.spawn_timer > 0:
            return
        self.spawn_timer = self.spawn_delay
        sx = (FIELD_X + 0 * BLOCK, FIELD_X + 6 * BLOCK, FIELD_X + 12 * BLOCK)
        px, py = sx[self.spawn_point], FIELD_Y
        self.spawn_point = (self.spawn_point + 1) % 3
        if self.field.rect_blocked(px + 1, py + 1, 14, 14):
            return
        kind_idx = self.enemy_queue.pop()
        kind = ENEMY_KIND[kind_idx]
        tank = Tank(px, py, kind)
        tank.spawn = 24
        tank.dir = DOWN
        self.tanks.append(tank)
        self.enemies_left -= 1
        self.spawned += 1

    def tick_bullets(self):
        for b in self.bullets:
            if not b.alive:
                continue
            dx, dy = DVEC[b.dir]
            steps = int(round(b.speed))
            for _ in range(steps):
                b.x += dx
                b.y += dy
                if self.bullet_hit(b):
                    break

        # 子弹互撞
        for i, a in enumerate(self.bullets):
            if not a.alive:
                continue
            for b in self.bullets[i + 1:]:
                if not b.alive or a.owner is b.owner:
                    continue
                if abs(a.x - b.x) < 6 and abs(a.y - b.y) < 6:
                    a.alive = b.alive = False
        self.bullets = [b for b in self.bullets if b.alive]

    def bullet_hit(self, b):
        # 出界
        if not (FIELD_X - 8 < b.x < FIELD_X + FIELD_W + 8 and
                FIELD_Y - 8 < b.y < FIELD_Y + FIELD_W + 8):
            b.alive = False
            return True
        # 基地
        if self.base_alive and abs(b.x - (self.base_x + 8)) < 10 and \
                abs(b.y - (self.base_y + 8)) < 10:
            self.base_alive = False
            b.alive = False
            self.audio.play('eagle')
            self.explosions.append(Explosion(self.base_x, self.base_y))
            self.game_over()
            return True
        # 地形
        k = self.field.kind_at_px(b.x, b.y)
        if k == BRICK:
            self.field.carve(b.x, b.y, b.dir)
            self.audio.play('brick')
            b.alive = False
            self.explosions.append(Explosion(b.x - 4, b.y - 4, big=False))
            return True
        if k == STEEL:
            if b.power >= 3 and b.owner is self.player:
                tx, ty = int(b.x - FIELD_X) // TILE, int(b.y - FIELD_Y) // TILE
                self.field.grid[ty][tx] = EMPTY
            self.audio.play('steel')
            b.alive = False
            self.explosions.append(Explosion(b.x - 4, b.y - 4, big=False))
            return True
        # 坦克
        for t in self.tanks:
            if not t.alive or t is b.owner or t.spawn > 0:
                continue
            if t.rect.collidepoint(b.x, b.y):
                b.alive = False
                self.hit_tank(t)
                return True
        return False

    def hit_tank(self, t):
        if t.shield > 0:
            self.explosions.append(Explosion(t.x, t.y, big=False))
            return
        if t.player:
            t.alive = False
            self.explosions.append(Explosion(t.x, t.y))
            self.audio.play('hit')
            self.lives -= 1
            if self.lives < 0:
                self.game_over()
            else:
                self.spawn_player()
            return
        t.hp -= 1
        t.flash = 6
        if t.hp > 0:
            self.audio.play('armor')
        if t.hp <= 0:
            t.alive = False
            self.explosions.append(Explosion(t.x, t.y))
            self.audio.play('hit')
            self.score += ENEMY_SCORE.get(t.kind, 100)
            self.kills += 1
            self.maybe_drop_powerup()

    def maybe_drop_powerup(self):
        # 击杀第 4 / 11 / 18 辆时掉道具（对应原版剩余 17/10/3 的闪烁车）
        if self.kills in (4, 11, 18) and not self.powerups:
            for _ in range(30):
                c = random.randrange(GRID)
                r = random.randrange(GRID)
                if self.field.kind(c * 2, r * 2) == EMPTY:
                    self.powerups.append(
                        Powerup(FIELD_X + c * BLOCK, FIELD_Y + r * BLOCK,
                                random.randrange(6)))
                    self.audio.play('spawn_item')
                    return

    def tick_powerups(self):
        p = self.player
        for pu in self.powerups:
            pu.t += 1
            if pu.t > 60 * 20:
                pu.alive = False
                continue
            if p and p.alive and p.spawn == 0:
                if abs((p.x + 8) - (pu.x + 8)) < 16 and \
                        abs((p.y + 8) - (pu.y + 8)) < 16:
                    pu.alive = False
                    self.audio.play('get_item')
                    self.apply_powerup(pu.type)
        self.powerups = [x for x in self.powerups if x.alive]

    def apply_powerup(self, ptype):
        self.score += 500
        name = POWERUP_NAMES[ptype]
        p = self.player
        if name == 'helm':
            if p:
                p.shield = 60 * 12
        elif name == 'clock':
            self.freeze = 60 * 8
        elif name == 'shovel':
            self.shovel = 60 * 15
            for c, r in ((5, 11), (6, 11), (7, 11), (5, 12), (7, 12)):
                self.field.set_block(c, r, 0x9)
        elif name == 'star':
            self.player_level = min(3, self.player_level + 1)
            if p:
                p.level = self.player_level
                p.st['maxb'] = 2 if self.player_level >= 2 else 1
                p.st['bullet'] = 4.0 if self.player_level >= 2 else 3.0
        elif name == 'grenade':
            for t in self.tanks:
                if t.alive and not t.player:
                    t.alive = False
                    self.explosions.append(Explosion(t.x, t.y))
                    self.score += ENEMY_SCORE.get(t.kind, 100)
        elif name == 'tank':
            self.lives += 1
            self.audio.play('bonus')

    def tick_explosion(self, e):
        e.t += 1
        return e.t < e.life

    def game_over(self):
        self.state = 'gameover'
        self.state_timer = 150
        self.audio.play_music('gameover')

    # ---------------- 绘制 ----------------
    def draw(self):
        c = self.canvas
        c.fill((0, 0, 0))
        self.field.draw(c, self.assets, self.bg_pal)
        self.draw_base(c)

        for pu in self.powerups:
            if pu.t % 16 < 12:                       # 闪烁
                img = self.assets.spr(POWERUP_BASE + pu.type * 4,
                                      SPR_PALETTES[1])
                c.blit(img, (pu.x, pu.y))
        for t in self.tanks:
            if t.alive:
                self.draw_tank(c, t)
        for b in self.bullets:
            pygame.draw.rect(c, NES_PALETTE[0x30],
                             (int(b.x), int(b.y), 3, 3))
        for e in self.explosions:
            self.draw_explosion(c, e)
        self.draw_hud(c)

        if self.state in ('clear', 'gameover'):
            self.banner(c, 'STAGE CLEAR' if self.state == 'clear' else 'GAME OVER')
        if self.paused:
            self.banner(c, 'PAUSE')

        pygame.transform.scale(c, self.screen.get_size(), self.screen)

    def draw_base(self, c):
        tiles = EAGLE_TILES if self.base_alive else EAGLE_DEAD_TILES
        pal = SPR_PALETTES[0]
        for i, tid in enumerate(tiles):
            img = self.assets.sprite_tile(tid, pal)
            x = self.base_x + (8 if i % 2 else 0)
            y = self.base_y + (8 if i >= 2 else 0)
            c.blit(img, (x, y))

    def assets_tile_spr(self, tid, pal):
        s = pygame.Surface((TILE, TILE))
        s.set_colorkey((0, 0, 0))
        px = self.rom.tile_pixels(tid, True)
        for y in range(TILE):
            for x in range(TILE):
                cc = px[y][x]
                if cc:
                    s.set_at((x, y), NES_PALETTE[pal[cc]])
        return s

    def draw_tank(self, c, t):
        if t.spawn > 0:
            if t.spawn % 8 < 4:
                pygame.draw.rect(c, NES_PALETTE[0x30],
                                 (int(t.x) + 4, int(t.y) + 4, 8, 8), 2)
            return
        if t.player:
            base = PLAYER_BASE + t.dir * 4
            pal = SPR_PALETTES[0]
        else:
            ki = KIND_INDEX.get(t.kind, 0)
            base = ENEMY_BASE + t.dir * 4
            pal = SPR_PALETTES[ENEMY_PALETTE[ki]]
        img = self.assets.spr(base, pal)
        if t.flash and t.flash % 4 < 2:
            img = img.copy()
            img.fill((255, 255, 255, 0), special_flags=pygame.BLEND_RGB_ADD)
        c.blit(img, (int(t.x), int(t.y)))
        if t.shield > 0:
            r = 10 + (t.shield // 4) % 3
            pygame.draw.circle(c, NES_PALETTE[0x30],
                               (int(t.x) + 8, int(t.y) + 8), r, 1)

    def draw_explosion(self, c, e):
        cx, cy = int(e.x) + 8, int(e.y) + 8
        p = e.t / e.life
        if e.big:
            for r, col in ((14, 0x30), (10, 0x27), (6, 0x16), (3, 0x0F)):
                rr = int(r * (0.4 + p * 0.8))
                if rr > 0:
                    pygame.draw.circle(c, NES_PALETTE[col], (cx, cy), rr,
                                       1 if r != 6 else 0)
        else:
            r = 2 + int(p * 4)
            pygame.draw.circle(c, NES_PALETTE[0x27], (cx, cy), r, 1)

    def draw_hud(self, c):
        self.text(c, 'IP', 8, HUD_Y, SPR_PALETTES[1])
        self.text(c, str(max(0, self.lives)), 32, HUD_Y, SPR_PALETTES[1])
        self.text(c, 'STAGE', 168, HUD_Y, SPR_PALETTES[1])
        self.text(c, str(self.stage), 208, HUD_Y, SPR_PALETTES[1])
        self.text(c, 'HI', 8, HUD_Y + 8, SPR_PALETTES[1])
        self.text(c, str(self.score).rjust(5, '0'), 24, HUD_Y + 8, SPR_PALETTES[1])

        # 剩余敌人图标（两行）
        remaining = self.enemies_left + sum(
            1 for t in self.tanks if t.alive and not t.player and t.spawn == 0)
        for i in range(min(20, remaining)):
            col, row = i % 10, i // 10
            x = 96 + col * 8
            y = HUD_Y + row * 8
            pygame.draw.rect(c, NES_PALETTE[0x20], (x + 1, y + 2, 6, 5))

    # ---- 文字：用 ROM 的背景数字/字母 tile ----
    def text(self, c, s, x, y, pal):
        for ch in s:
            tid = None
            if '0' <= ch <= '9':
                tid = 0x30 + (ord(ch) - ord('0'))
            elif 'A' <= ch <= 'Z':
                tid = 0x41 + (ord(ch) - ord('A'))
            elif ch == '-':
                tid = 0x6B
            if tid is None:
                x += 8
                continue
            c.blit(self.assets.tile(tid, pal), (x, y))
            x += 8

    def banner(self, c, s):
        w = len(s) * 8
        pygame.draw.rect(c, (0, 0, 0), (128 - w // 2 - 4, 100, w + 8, 16))
        self.text(c, s, 128 - w // 2, 104, SPR_PALETTES[1])


# --------------------------------------------------------------------------
def make_atlas(rom, out='sprite_atlas.png'):
    """生成带 tile 号标注的精灵图鉴，便于核对 tile id。"""
    pygame.init()
    pygame.display.set_mode((1, 1))
    assets = Assets(rom)
    cell, cols = 40, 16
    rows = 256 // (cols * 4) + 1
    surf = pygame.Surface((cols * cell, rows * (cell + 12)))
    surf.fill((40, 40, 48))
    font = pygame.font.Font(None, 14)
    for i in range(64):
        base = i * 4
        img = assets.spr(base, SPR_PALETTES[0])
        x = (i % cols) * cell
        y = (i // cols) * (cell + 12)
        pygame.draw.rect(surf, (70, 70, 80), (x, y + 4, 20, 20))
        surf.blit(pygame.transform.scale(img, (20, 20)), (x, y + 4))
        surf.blit(font.render(f'${base:02X}', True, (200, 200, 200)), (x, y - 2))
    pygame.image.save(surf, out)
    print('已生成精灵图鉴 ->', out)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--rom')
    ap.add_argument('--scale', type=int, default=SCALE)
    ap.add_argument('--atlas', action='store_true', help='只生成精灵图鉴')
    ap.add_argument('--shot', metavar='PNG', help='无窗口渲染后保存截图')
    ap.add_argument('--frames', type=int, default=240)
    ap.add_argument('--stage', type=int, default=1)
    ap.add_argument('--mute', action='store_true', help='静音')
    ap.add_argument('--no-corner', action='store_true', help='不自动移到右下角')
    ap.add_argument('--top', action='store_true', help='窗口置顶（摸鱼用）')
    ap.add_argument('--borderless', action='store_true', help='无边框窗口')
    args = ap.parse_args()

    rom = Rom(args.rom)
    if args.atlas:
        make_atlas(rom)
        return
    if args.shot:
        import os
        os.environ.setdefault('SDL_VIDEODRIVER', 'dummy')
        g = Game(rom, args.scale, sound=not args.mute,
                 corner=not args.no_corner, always_on_top=args.top,
                 borderless=args.borderless)
        g.stage = args.stage
        g.start_stage()
        for _ in range(args.frames):
            g.tick()
            g.draw()
        pygame.image.save(g.canvas, args.shot)
        print('已保存截图 ->', args.shot)
        return
    Game(rom, args.scale, sound=not args.mute,
         corner=not args.no_corner, always_on_top=args.top,
         borderless=args.borderless).run()


if __name__ == '__main__':
    main()
