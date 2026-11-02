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
from bc_logic import (Random, FrameCounter, enemy_goal_stage,
                      FLAG_FOLLOW_HQ, FLAG_RANDOM, FLAG_FOLLOW_P1,
                      FLAG_FOLLOW_P2)
from bc_rom import (Rom, NES_PALETTE, tank_tile, TANK_TYPE_BASE, PLAYER_A8,
                    TANK_ROM_DIR, TANK_ROM_DIR_ENEMY, MENU_CURSOR_TILES,
                    PLAYER_TILE, PLAYER_TILE_SIDE, EAGLE_TILES,
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

# --------------------------------------------------------------------------
# 开场画面（$D17F 把标题+选单画进 NT B，$C7AB 用 240 帧垂直卷动滑入）
# --------------------------------------------------------------------------
TITLE_SCROLL_FRAMES = 240      # $4F: 0 → $F0，约 4 秒
TITLE_PAL_SET = 3              # $D595：BG0 = 0F 16 16 30（暗红/白的砖块 logo）
STAGE_PAL_SET = 3              # ⚠️ 见 draw_stage_select：set 4 slot 0 太暗
LOGO_LINES = (('BATTLE', 26, 46), ('CITY', 60, 86))   # 巨型砖块字，像素坐标
MENU_ITEMS = ('1 PLAYER', '2 PLAYERS', 'CONSTRUCTION')
MENU_TEXT_X, MENU_TEXT_Y = 88, 136      # 列 11 行 17，行距 16px
MENU_CURSOR_X, MENU_CURSOR_Y0 = 72, 139  # $C9C7/$CA85

# $C49C 隐藏的 credits 画面（选单里 $4B==7 且 $4A==$74 时按 Start 进入）
CREDITS_LINES = ((8, 8, 'THIS PROGRAM WAS'),
                 (8, 10, 'WRITTEN BY'),
                 (8, 12, 'OPEN-REACH'),
                 (8, 14, 'WHO LOVES NORIKO'))
CREDITS_DOT_ROW, CREDITS_DOT_COL = 16, 8   # 5 个点，逐字出现
CREDITS_WAIT = 64                          # sub_C567：等 $0B & $3F 个帧
CREDITS_STEPS = 10                         # 10 次空等 / 9 次绘制（4 行 + 5 点）
CREDITS_DROP_X = 120                       # sub_C575：($56,$57) = ($78,$1E)
CREDITS_DROP_Y0, CREDITS_DROP_Y1 = 30, 248
CREDITS_DROP_DELAY = 28                    # 7 轮 × 4 次 sub_C5B0
CREDITS_TRIGGER_A, CREDITS_TRIGGER_B = 0x74, 7
BAND_TILES = tuple(range(0x60, 0x69))    # 选单下方的 9 tile 装饰带（$D28F）
STAGE_LABEL_TILES = (0x23, 0x24, 0x25, 0x26, 0x27)   # "STAGE"（$CA91）
STAGE_TEXT_X, STAGE_TEXT_Y = 96, 112     # 列 12 行 14
STAGE_MIN, STAGE_MAX = 1, 35             # $85 的界（$C197/$C1BC）

# 按键分组（ROM 位序 Right $80 Left $40 Down $20 Up $10 Start $08 Select $04 B $02 A $01）
KEY_UP = (pygame.K_UP, pygame.K_w)
KEY_DOWN = (pygame.K_DOWN, pygame.K_s)
KEY_LEFT = (pygame.K_LEFT, pygame.K_a)
KEY_RIGHT = (pygame.K_RIGHT, pygame.K_d)
KEY_START = (pygame.K_RETURN,)
KEY_SELECT = (pygame.K_TAB,)
KEY_A = (pygame.K_j, pygame.K_f, pygame.K_SPACE)   # A = 开火
KEY_B = (pygame.K_k, pygame.K_l)                  # B = 构造模式里换地形
WATCH_KEYS = tuple(dict.fromkeys(
    KEY_UP + KEY_DOWN + KEY_LEFT + KEY_RIGHT + KEY_START + KEY_SELECT +
    KEY_A + KEY_B + (pygame.K_p,)))

# 双人手柄映射（$D689 读 $4016/$4017，P1=$06/$08、P2=$07/$09）
PAD_SOLO = dict(up=(pygame.K_UP, pygame.K_w), down=(pygame.K_DOWN, pygame.K_s),
                left=(pygame.K_LEFT, pygame.K_a),
                right=(pygame.K_RIGHT, pygame.K_d),
                fire=(pygame.K_j, pygame.K_f, pygame.K_SPACE))
PAD_1P = dict(up=(pygame.K_w,), down=(pygame.K_s,), left=(pygame.K_a,),
              right=(pygame.K_d,), fire=(pygame.K_j, pygame.K_f))
PAD_2P = dict(up=(pygame.K_UP,), down=(pygame.K_DOWN,), left=(pygame.K_LEFT,),
              right=(pygame.K_RIGHT,), fire=(pygame.K_SPACE, pygame.K_k))

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
    def __init__(self, rom, stage=1, codes=None):
        self.grid = [[EMPTY] * TG for _ in range(TG)]
        if codes is None:
            codes = rom.stage_grid(stage)
        self.load_codes(codes)

    def load(self, rom, stage):
        """按关卡 nibble 表填充地形（每格 = 2×2 个 8px tile）。"""
        self.load_codes(rom.stage_grid(stage))

    def load_codes(self, codes):
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
        self.bonus = False        # 闪光车（$A8 = 4）
        self.wheels = 0           # $B0：bit2 翻转控制履带两帧动画
        self.goal = FLAG_FOLLOW_HQ  # $A0 高半字节：当前目标阶段
        self.respawn_timer = 0     # $0106：复活等待
        self.invuln_timer = 0      # $0108：随身无敌计时
        self.idx = 0               # 玩家编号（0=P1, 1=P2）
        self.freeze = 0            # $6F：被同伴打中后的冻结帧数

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
            if (int(nx) % 8 == 0 and int(ny) % 8 == 0) or abs(nx - self.x) > 0:
                self.wheels ^= 0x04        # $DD29 AnimBitToggle
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
    MAX_ENEMIES_ON_SCREEN = 4      # 1P：槽 2..$05（4 个）
    MAX_ENEMIES_2P = 6             # 2P：槽 2..$07（6 个），$6C = 7
    ENEMIES_PER_STAGE = 20
    TOTAL_LIVES = 3
    PLAYER_SPAWN = ((4, 12), (8, 12))   # 原版 ($58,$D8)/($98,$D8) 换到端口坐标

    def __init__(self, rom, scale=SCALE, sound=True, corner=False,
                 always_on_top=False, borderless=False, size=None,
                 minimized=True):
        pygame.init()
        pygame.display.set_caption('Battle City (Namco 1985) — Python 复刻')
        self.scale = scale
        self.canvas = pygame.Surface((SCREEN_W, SCREEN_H))
        if size:
            w, h = size
        else:
            w, h = SCREEN_W * scale, SCREEN_H * scale
        flags = pygame.NOFRAME if borderless else 0
        self.screen = pygame.display.set_mode((w, h), flags)
        self.minimized = minimized
        # SDL 创建/flip 时会把窗口重新 ShowWindow，需在前若干帧反复最小化
        self._reminimize_frames = 6 if minimized else 0
        if corner:
            self.move_to_corner(always_on_top=always_on_top)
        if minimized:
            self.minimize()
        self.clock = pygame.time.Clock()
        self.rom = rom
        self.assets = Assets(rom)
        self.audio = Audio(enabled=sound)
        self.bg_pal_sets = [[rom.bg_palette(s, i) for i in range(4)]
                            for s in range(6)]
        self.bg_pal = self.bg_pal_sets[0]
        self.field = None
        self.font_cache = {}
        self.paused = False
        self.running = True
        self.rng = Random()
        self.frames = FrameCounter()
        self.state = 'title'          # title / menu / stagesel / build / play / clear / gameover
        self.state_timer = 0
        self.title_scroll = 0         # $4F
        self.menu_index = 0           # $83
        self.menu_code_a = 0          # $4A：选单里 ↓ 加 $10、→ 减 1 的隐藏计数
        self.menu_code_b = 0          # $4B：构造模式按 Start 退出的次数（开局清零）
        self.credit_step = 0          # credits 画面进度
        self.credit_timer = 0
        self.drop_y = 0
        self.mode = 0                 # 0 = 1P, 1 = 2P
        self.pending_stage = 1        # 关卡选择画面的 $85
        self.custom_codes = None      # 构造模式画出来的图（$4B 保活的地图）
        self.build_field = None
        self.build_cursor = [0, 0]
        self.build_code = 0           # $5C
        self.build_latch = False      # $81
        self.build_hold = 0
        self.stage_hold = 0
        self.hi_p1 = 0
        self.hi_p2 = 0
        self.hi_all = 20000
        self.held = {}
        self.press = {}
        self._logo_cache = {}
        self.reset_run()

    def minimize(self):
        """启动即最小化（Windows 专用，失败就忽略）。"""
        try:
            import ctypes
            hwnd = pygame.display.get_wm_info().get('window')
            if not hwnd:
                return
            SW_SHOWMINNOACTIVE = 7
            ctypes.windll.user32.ShowWindow(hwnd, SW_SHOWMINNOACTIVE)
        except Exception:
            pass

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
    def reset_run(self):
        """$C2BD/$C2DD：新局清零（分数、分数层、关卡号、双方命数）。"""
        self.stage = 1
        self.lives = self.TOTAL_LIVES - 1          # 保留旧字段：P1 备用命
        self.p_lives = [self.TOTAL_LIVES - 1, self.TOTAL_LIVES - 1]   # $51/$52
        if self.mode != 1:
            self.p_lives[1] = 0                    # $C2D5：1P 时 P2 命数清 0
        self.p_star = [0, 0]                       # $0101/$0102
        self.p_out = [False, False]
        self.score = 0
        self.player_level = 0

    CURTAIN_FRAMES = 16

    def start_stage(self, codes=None):
        self.field = Field(self.rom, self.stage, codes)
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
        self.players = [None, None]
        self.out_texts = []
        # 2P：$84 = $BE - 4*stage - 20，在场敌人上限 6（槽 2..$07）
        self.max_enemies = self.MAX_ENEMIES_2P if self.mode == 1 else \
            self.MAX_ENEMIES_ON_SCREEN
        self.spawn_interval = max(30, 0xBE - self.stage * 4 -
                                  (20 if self.mode == 1 else 0))
        self.spawn_delay = self.spawn_interval
        for idx in range(2 if self.mode == 1 else 1):
            # 出局（命已为负）的玩家不会在下一关复活
            if self.p_lives[idx] >= 0:
                self.spawn_player(idx)
        # 开局：灰色幕布从上/下两侧各展开 16 行，再逐帧拉开
        self.curtain = 0          # 0..16，表示已覆盖的行数
        self.curtain_phase = 'close'
        self.curtain_timer = 0
        self.hold_left = 0
        self.freeze = 0
        self.shovel = 0
        self.state = 'play'
        self.state_timer = 0
        self.audio.play_music('bgm')

    def spawn_player(self, idx=0):
        """$E363：P1 出生 ($88,$D8)、P2 ($98,$D8)；复活立即执行，无延迟。"""
        col, row = self.PLAYER_SPAWN[idx]
        p = Tank(FIELD_X + col * BLOCK, FIELD_Y + row * BLOCK, 'player',
                 player=True, level=self.p_star[idx])
        p.idx = idx
        # 原版 $DE46：$0108 = $0D（出生动画 13 帧），$0106 = $D8
        p.spawn = 13
        p.respawn_timer = 0xD8
        p.shield = 0
        self.players[idx] = p
        if idx == 0:
            self.player = p
        self.tanks.append(p)

    # ---------------- 输入 ----------------
    def poll_input(self):
        """$D689 的边沿检测：press = 本帧按下且上一帧没按下。"""
        keys = pygame.key.get_pressed()
        held = {k: bool(keys[k]) for k in WATCH_KEYS}
        self.press = {k: held[k] and not self.held.get(k, False)
                      for k in WATCH_KEYS}
        self.held = held

    def held_any(self, group):
        return any(self.held.get(k) for k in group)

    def press_any(self, group):
        return any(self.press.get(k) for k in group)

    def pad_for(self, idx=0):
        if self.mode != 1:
            return PAD_SOLO
        return PAD_1P if idx == 0 else PAD_2P

    def read_input(self, idx=0):
        pad = self.pad_for(idx)
        if self.held_any(pad['up']):
            return UP
        if self.held_any(pad['down']):
            return DOWN
        if self.held_any(pad['left']):
            return LEFT
        if self.held_any(pad['right']):
            return RIGHT
        return None

    def fire_pressed(self, idx=0):
        return self.held_any(self.pad_for(idx)['fire'])

    # ---------------- 主循环 ----------------
    def run(self):
        while self.running:
            self.clock.tick(FPS)
            self.handle_events()
            if not self.paused:
                self.tick()
            self.draw()
            pygame.display.flip()
            if self._reminimize_frames > 0:
                self._reminimize_frames -= 1
                self.minimize()

    def handle_events(self):
        for e in pygame.event.get():
            if e.type == pygame.QUIT:
                self.running = False
            elif e.type == pygame.KEYDOWN:
                if e.key == pygame.K_ESCAPE:
                    self.running = False
                elif e.key in (pygame.K_RETURN, pygame.K_p) and \
                        self.state == 'play':
                    self.paused = not self.paused
                    if self.paused:
                        # 原版 $F5 从 $1C 降到 1：音序引擎降速，音乐变慢而非静音
                        self.audio.play_music('bgm_slow')
                    else:
                        self.audio.stop_music()
                        self.audio.set_engine(False)

    # ---------------- 逻辑 ----------------
    def tick(self):
        self.frames.tick()
        self.poll_input()
        if self.state == 'title':
            self.tick_title()
        elif self.state == 'menu':
            self.tick_menu()
        elif self.state == 'credits':
            self.tick_credits()
        elif self.state == 'stagesel':
            self.tick_stage_select()
        elif self.state == 'build':
            self.tick_build()
        elif self.state == 'play':
            self.tick_play()
        else:
            self.state_timer -= 1
            if self.state_timer <= 0:
                if self.state == 'clear':
                    self.stage += 1
                    self.start_stage()
                elif self.state == 'gameover':
                    self.to_title()

    # ---- 标题 / 选单 / 关卡选择（$C7AB / $C9C0 / $C159）----
    def tick_title(self):
        """$C7AB：240 帧把整屏从下往上推入，期间按 Start/Select 立刻跳到选单。"""
        if self.title_scroll >= TITLE_SCROLL_FRAMES:
            self.title_scroll = TITLE_SCROLL_FRAMES
            self.enter_menu()
            return
        self.title_scroll += 1
        if self.press_any(KEY_START + KEY_SELECT):
            self.title_scroll = TITLE_SCROLL_FRAMES
            self.enter_menu()

    def enter_menu(self):
        """$C9E0：每次进选单都把 $4A 清零（$4B 只在开局 $C359 清）。"""
        self.state = 'menu'
        self.menu_code_a = 0

    def tick_menu(self):
        """$C9C0：Select/↓ 循环三项，Start 确认。

        $CA04/$CA17：按住 ↓ 给隐藏计数 $4A 加 $10，按住 → 减 1；
        $CA43：$4B==7 且 $4A==$74 时按 Start → 进 $C49C 的 credits 画面。
        """
        if self.press_any(KEY_SELECT + KEY_DOWN):
            self.menu_index = (self.menu_index + 1) % len(MENU_ITEMS)
        elif self.press_any(KEY_UP):
            self.menu_index = (self.menu_index - 1) % len(MENU_ITEMS)
        if self.held_any(KEY_DOWN):
            self.menu_code_a = (self.menu_code_a + 0x10) & 0xFF
        if self.held_any(KEY_RIGHT):
            self.menu_code_a = (self.menu_code_a - 1) & 0xFF
        if self.press_any(KEY_START):
            if (self.menu_code_b == CREDITS_TRIGGER_B and
                    self.menu_code_a == CREDITS_TRIGGER_A):
                self.enter_credits()
                return
            self.choose_mode()

    # ---- 隐藏的 credits 画面（$C49C，选单 $CA4F 跳进来）----
    def enter_credits(self):
        self.state = 'credits'
        self.credit_step = 0
        self.credit_timer = 0
        self.drop_y = CREDITS_DROP_Y0

    def tick_credits(self):
        """每 64 帧出一行（4 行 + 5 个点），然后 $C575 让精灵从 y=30 落到 248。"""
        if self.credit_step < CREDITS_STEPS:
            self.credit_timer += 1
            if self.credit_timer >= CREDITS_WAIT:
                self.credit_timer = 0
                self.credit_step += 1
            return
        if self.credit_timer < CREDITS_DROP_DELAY:
            self.credit_timer += 1
            return
        self.drop_y += 1
        if self.drop_y >= CREDITS_DROP_Y1:
            # $C55A → $C9B0/$D7B4 之后回到选单，继续执行选中的那一项
            self.enter_menu()
            self.choose_mode()

    def choose_mode(self):
        """$CA69 跳转表：1P($CA6F) / 2P($CA74) / CONSTRUCTION($CA7E)。"""
        if self.menu_index == 2:
            self.enter_build()
            return
        self.mode = self.menu_index
        self.reset_run()
        self.pending_stage = 1        # $C2DD：$85 = 1
        self.state = 'stagesel'

    def tick_stage_select(self):
        """$C159：A 加关（连发 8 帧），B 减关，Start 开打。"""
        if self.press_any(KEY_START):
            self.start_run_at(self.pending_stage)
            return
        if self.press_any(KEY_A):
            self.pending_stage = min(STAGE_MAX, self.pending_stage + 1)
            self.stage_hold = 8
        elif self.held_any(KEY_A):
            self.stage_hold -= 1
            if self.stage_hold <= 0:
                self.pending_stage = min(STAGE_MAX, self.pending_stage + 1)
                self.stage_hold = 8
        if self.press_any(KEY_B):
            self.pending_stage = max(STAGE_MIN, self.pending_stage - 1)

    def start_run_at(self, stage):
        """$C1C5：按选定关卡开局；自定义地图优先（对应 $4B）。"""
        self.reset_run()
        self.stage = stage
        self.start_stage(self.custom_codes)
        self.custom_codes = None      # $C331 会把 $4B 清 0
        self.menu_code_b = 0          # $C359：开局清 $4B

    def to_title(self):
        """$C095：回到标题（重新滑入）。"""
        self.state = 'title'
        self.title_scroll = 0
        self.menu_index = 0
        self.reset_run()

    # ---- 构造模式（$CA7E → $C0AE）----
    def enter_build(self):
        """$C0AE：清场、光标归位（$90=$10/$98=$18），老鹰单独画（$CAF5）。

        $4B 未清时上次画的图原样保留，对应原版“进过游戏就会清空”。
        """
        self.state = 'build'
        self.mode = 2
        if self.build_field is None:
            # 0xD = 空块（BLOCK_DEF[0xD] = 四个 tile $00），0x4 = 整块砖
            self.build_codes = [[0xD] * GRID for _ in range(GRID)]
            self.build_field = Field(self.rom, 1, self.build_codes)
            for c, r in ((5, 11), (6, 11), (7, 11), (5, 12), (7, 12)):
                self.build_field.set_block(c, r, 0x4)
        self.base_x = FIELD_X + 6 * BLOCK
        self.base_y = FIELD_Y + 12 * BLOCK
        self.base_alive = True
        self.build_cursor = [0, 0]
        self.build_code = 0            # $5C
        self.build_latch = False       # $81
        self.build_move_delay = 20

    def tick_build(self):
        """$C0EA 编辑循环。

        方向键移格（按住 20 帧后每帧一格）；A/B 首按只落笔，
        之后再按则换地形码（A 加、B 减，0..$D 循环）；按住 A/B 连涂。
        """
        if self.press_any(KEY_START):
            self.leave_build()
            return
        col, row = self.build_cursor
        dirs = ((KEY_UP, 0, -1), (KEY_DOWN, 0, 1),
                (KEY_LEFT, -1, 0), (KEY_RIGHT, 1, 0))
        moved = False
        for group, ddx, ddy in dirs:
            if self.press_any(group):
                col, row = (col + ddx) % GRID, (row + ddy) % GRID
                self.build_latch = False    # $C6D2：移动后重置落笔闩锁
                self.build_move_delay = 20
                moved = True
                break
        if not moved:
            if any(self.held_any(g) for g, _, _ in dirs):
                self.build_move_delay -= 1
                if self.build_move_delay <= 0:
                    for group, ddx, ddy in dirs:
                        if self.held_any(group):
                            col, row = (col + ddx) % GRID, (row + ddy) % GRID
                            break
            else:
                self.build_move_delay = 20
        self.build_cursor = [col, row]

        if self.press_any(KEY_A):
            if self.build_latch:
                self.build_code = (self.build_code + 1) % 14
            else:
                self.build_latch = True
            self.stamp_build()
        elif self.press_any(KEY_B):
            if self.build_latch:
                self.build_code = (self.build_code - 1) % 14
            else:
                self.build_latch = True
            self.stamp_build()
        elif self.held_any(KEY_A + KEY_B):
            self.stamp_build()

    def stamp_build(self):
        """$C6C6/$D80B：一次落笔 = 整 16×16 block（4 个 tile + 1 属性字节）。"""
        col, row = self.build_cursor
        self.build_codes[row][col] = self.build_code
        self.build_field.set_block(col, row, self.build_code)

    def leave_build(self):
        """$C150：Start 回选单，图进入“等开局”状态（$4B=1）。"""
        if self.build_codes is not None:
            self.custom_codes = [r[:] for r in self.build_codes]
        self.menu_code_b += 1         # $C154：INC $4B（连退 7 次凑出 credits 条件）
        self.enter_menu()

    def tick_curtain(self):
        """$CC90 close_grey_curtain / $CCB2 open_grey_curtain。

        每帧画第 n 行和第 29-n 行（各一行灰砖），16 帧画满；
        反向再 16 帧拉开。幕布期间游戏逻辑不跑。
        """
        if self.curtain_phase == 'close':
            self.curtain_timer += 1
            if self.curtain_timer < 2:      # 原版每帧一行，这里慢一半
                return
            self.curtain_timer = 0
            self.curtain += 1
            if self.curtain >= self.CURTAIN_FRAMES:
                self.curtain_phase = 'hold'
                self.hold_left = 30         # 幕布全闭后停留约半秒
        elif self.curtain_phase == 'hold':
            self.hold_left -= 1
            if self.hold_left <= 0:
                self.curtain_phase = 'open'
                self.curtain_timer = 0
        elif self.curtain_phase == 'open':
            self.curtain_timer += 1
            if self.curtain_timer < 2:
                return
            self.curtain_timer = 0
            self.curtain -= 1
            if self.curtain <= 0:
                self.curtain = 0
                self.curtain_phase = 'done'

    def tick_play(self):
        if self.curtain_phase != 'done':
            self.tick_curtain()
            return
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

        for ot in self.out_texts:
            ot[1] -= ot[2]          # $C972：每帧把速度累加到坐标
            ot[3] -= 1
        self.out_texts = [ot for ot in self.out_texts if ot[3] > 0]

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
        for idx, p in enumerate(self.players):
            if p is None or not p.alive:
                continue
            if p.freeze > 0:               # $6F：被同伴打中，冻结期间吞输入
                p.freeze -= 1
                continue
            if p.spawn > 0:
                p.spawn -= 1
                if p.spawn == 0:
                    p.shield = max(p.shield, 90)
                continue
            if p.shield > 0:
                p.shield -= 1
            if p.fire_cd > 0:
                p.fire_cd -= 1

            d = self.read_input(idx)
            if d is None:
                self.audio.set_engine(False)
            if d is not None:
                if p.move(self.field, d):
                    self.audio.set_engine(True)
                p.slide = 8
            elif p.slide > 0:
                self.audio.set_engine(False)
                p.slide -= 1
                # 冰面上滑行
                if self.field.kind_at_px(p.x + 8, p.y + 8) == ICE:
                    p.move(self.field, p.dir)
                    self.audio.play('ice')     # $0310：冰面滑行

            if self.fire_pressed(idx) and p.fire_cd == 0:
                mine = sum(1 for b in self.bullets
                           if b.owner is p and b.alive)
                if mine < p.st['maxb']:
                    self.shoot(p)
                    p.fire_cd = 6 if p.level < 2 else 4

    def shoot(self, t):
        dx, dy = DVEC[t.dir]
        bx = t.x + 8 + dx * 9 - 3
        by = t.y + 8 + dy * 9 - 3
        self.bullets.append(
            Bullet(bx, by, t.dir, t.st['bullet'], t,
                   power=t.level if t.player else 1))
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

            # 原版 $DC7C：三个条件全满足才重新决策方向
            #   1) X 落在 8px 网格  2) Y 落在 8px 网格  3) PRNG & $0F == 0（1/16）
            gx, gy = int(t.x) % 8, int(t.y) % 8
            if gx == 0 and gy == 0:
                r = self.rng.next(self.frames.hi, self._zp_probe())
                if (r & 0x0F) == 0:
                    t.dir = self.pick_enemy_dir(t)
                    t.wheels ^= 0x04          # $DC66：EOR #$04，履带动画帧
                    continue                   # 本帧只决策不移动

            if not t.move(self.field, t.dir):
                # 原版 $DD11 撞墙处理：
                #   PRNG & $03 == 0 → 25% 掉头 180°（EOR $02），且不翻履带帧
                #   否则           → 只翻履带帧（看起来在"原地蹭"）
                r = self.rng.next(self.frames.hi, self._zp_probe())
                if (r & 0x03) == 0:
                    t.dir ^= 0x02          # 上下互换 / 左右互换 = 掉头
                    if int(t.x) % 8 == 0 and int(t.y) % 8 == 0:
                        t.goal = FLAG_RANDOM   # con_tank_flag_90
                else:
                    t.wheels ^= 0x04
                    # 原版撞墙不发声，只翻履带帧

            # 原版开火：先对齐（与玩家/基地同行或同列）再按 PRNG 抽
            if t.fire_cd == 0:
                aligned = self.enemy_aligned(t)
                r = self.rng.next(self.frames.hi, self._zp_probe())
                if aligned and (r & 0x03) == 0:
                    self.shoot(t)
                    t.fire_cd = 24

    def pick_enemy_dir(self, t):
        """原版 $DE72 + $E420：按帧计数选择目标，不追击时用 PRNG 抽方向。"""
        goal = getattr(t, 'goal', FLAG_FOLLOW_HQ)
        if goal == FLAG_RANDOM:
            pass                       # 已被撞墙逻辑设成随机，保持
        else:
            goal = enemy_goal_stage(self.spawn_interval, self.frames.hi)

        if goal == FLAG_RANDOM:
            r = self.rng.next(self.frames.hi, self._zp_probe())
            return r & 0x03

        if goal == FLAG_FOLLOW_HQ:
            tx, ty = self.base_x, self.base_y
        else:
            target = self.chase_player()
            if target is None:
                tx, ty = self.base_x, self.base_y
            else:
                tx, ty = target.x, target.y

        # 原版 CalcDirToTarget：轴向差大的先走
        if abs(tx - t.x) > abs(ty - t.y):
            return RIGHT if tx > t.x else LEFT
        return DOWN if ty > t.y else UP

    def chase_player(self):
        """$DE72：追击目标选 P1 还是 P2。

        ⚠️ 原版靠 $84>>2 / $84>>3 与 $0A 的相位决定 $B0（追 P2）/ $C0（追 P1），
        这里用 $84>>2 ≥ $0A 作等价条件；2P 少 20 后该窗口更早开启。
        """
        alive = [p for p in self.players if p is not None and p.alive]
        if not alive:
            return None
        if len(alive) == 1:
            return alive[0]
        if (self.spawn_interval >> 2) >= 0x0A:
            return self.players[1] or self.players[0]
        return self.players[0] or self.players[1]

    def _zp_probe(self):
        """PRNG 会读零页 $00+idx；这里用场上状态喂一个稳定的伪零页。"""
        return {i: (self.frames.lo ^ (i * 37)) & 0xFF for i in range(1, 64)}

    def enemy_aligned(self, t):
        if t.dir in (UP, DOWN):
            return abs(t.x - self.base_x) < 12 or any(
                p is not None and p.alive and abs(t.x - p.x) < 12
                for p in self.players)
        return False

    def tick_spawn(self):
        alive = sum(1 for t in self.tanks if t.alive and not t.player and t.spawn == 0)
        if self.enemies_left <= 0 or alive >= self.max_enemies:
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
        # 原版 $E393：剩余数 = 3 / $0A / $11 时标记闪光车（第 18/11/4 辆）
        if self.enemies_left in (3, 0x0A, 0x11):
            tank.bonus = True
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

    def _bullet_probes(self, b):
        """原版 $E604 的 4 个探测点：位置 ± 速度，构成菱形四角。

        A = pos + v   C = pos + v - v_prev
        B = pos - v   D = pos - v + v_prev
        实际 ROM 用的是 pos±(vx,vy) 的组合，这里按其几何还原。
        """
        dx, dy = DVEC[b.dir]
        sp = max(1, int(round(b.speed)))
        ox, oy = dx * sp, dy * sp
        # B/D 相对 A/C 做垂直偏移（弹体宽 4px：±2）
        px, py = (-dy * 2, dx * 2)         # 垂直方向
        return [
            (b.x + ox, b.y + oy),          # A 前
            (b.x - ox, b.y - oy),          # C 后
            (b.x + ox + px, b.y + oy + py),  # B 前侧
            (b.x - ox - px, b.y - oy - py),  # D 后侧
        ]

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
        # 地形：原版先测 A、C 两点（命中即停弹），再测 B、D（只破坏砖不停弹）
        probes = self._bullet_probes(b)
        main_hit = None
        for px, py in (probes[0], probes[1]):          # A, C
            kk = self.field.kind_at_px(px, py)
            if kk == BRICK:
                self.field.carve(px, py, b.dir)
                main_hit = 'brick'
                break
            if kk == STEEL:
                main_hit = 'steel'
                break
        if main_hit:
            # B/D 只在 A/C 命中砖时连带破砖（原版行为）
            if main_hit == 'brick':
                for px, py in (probes[2], probes[3]):   # B, D
                    if self.field.kind_at_px(px, py) == BRICK:
                        self.field.carve(px, py, b.dir)
                self.audio.play('brick')
            else:
                if b.power >= 3 and b.owner.player:
                    tx = int(probes[0][0] - FIELD_X) // TILE
                    ty = int(probes[0][1] - FIELD_Y) // TILE
                    if 0 <= tx < TG and 0 <= ty < TG:
                        self.field.grid[ty][tx] = EMPTY
                self.audio.play('steel')
            b.alive = False
            self.explosions.append(Explosion(b.x - 4, b.y - 4, big=False))
            return True

        k = self.field.kind_at_px(b.x, b.y)
        if k == BRICK:
            self.field.carve(b.x, b.y, b.dir)
            self.audio.play('brick')
            b.alive = False
            self.explosions.append(Explosion(b.x - 4, b.y - 4, big=False))
            return True
        if k == STEEL:
            if b.power >= 3 and b.owner.player:
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
                if t.player and getattr(b.owner, 'player', False):
                    self.player_hit_player(t)      # $E843：玩家打玩家
                else:
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
            idx = t.idx
            self.p_star[idx] = 0               # $E75F：火力等级清零
            self.p_lives[idx] -= 1             # $DE0D：DEC $51,X
            self.lives = max(0, self.p_lives[0])
            if self.p_lives[idx] < 0:
                self.player_out(idx)           # $DE18：出局
            else:
                self.spawn_player(idx)         # $DE11：立刻复活
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
            self.audio.play('kill')          # $030A：敌方坦克被击毁
            if t.bonus:                      # 只有闪光车掉道具
                self.drop_powerup()

    def player_hit_player(self, t):
        """$E843 PvP：命中同伴只冻结 $C8(200) 帧，不扣命也不掉级。"""
        self.explosions.append(Explosion(t.x, t.y, big=False))
        if t.shield > 0 or t.freeze > 0:
            return
        t.freeze = 0xC8
        self.audio.play('armor')

    def player_out(self, idx):
        """$DE18：一方命耗尽 —— 只有另一方还有命时才飞 GAME OVER 字，游戏继续。"""
        self.p_out[idx] = True
        self.players[idx] = None
        if idx == 0:
            self.player = None
        alive_other = any(p is not None and not self.p_out[i]
                          for i, p in enumerate(self.players))
        if alive_other and self.mode == 1:
            self.out_texts.append([28 if idx == 0 else 124,
                                   FIELD_Y + 12 * BLOCK, 3, 13])
        if not alive_other:
            self.game_over()

    def drop_powerup(self):
        """原版 $E8BE PowerupSpawn：用 PRNG 在网格上定位，类型也从 PRNG 取。"""
        if self.powerups:
            return
        for _ in range(40):
            r1 = self.rng.next(self.frames.hi, self._zp_probe())
            r2 = self.rng.next(self.frames.hi, self._zp_probe())
            c = (r1 >> 4) % GRID
            r = (r2 >> 4) % GRID
            if self.field.kind(c * 2, r * 2) == EMPTY:
                r3 = self.rng.next(self.frames.hi, self._zp_probe())
                ptype = (r3 >> 3) % 6
                self.powerups.append(
                    Powerup(FIELD_X + c * BLOCK, FIELD_Y + r * BLOCK, ptype))
                self.audio.play('spawn_item')
                return

    def tick_powerups(self):
        for pu in self.powerups:
            pu.t += 1
            if pu.t > 60 * 20:
                pu.alive = False
                continue
            # $E972：先查 P2 再查 P1，所以同时踩上去 P2 优先
            for idx in (1, 0):
                if idx >= len(self.players):
                    continue
                p = self.players[idx]
                if not p or not p.alive or p.spawn != 0:
                    continue
                if abs((p.x + 8) - (pu.x + 8)) < 16 and \
                        abs((p.y + 8) - (pu.y + 8)) < 16:
                    pu.alive = False
                    self.audio.play('get_item')
                    self.apply_powerup(pu.type, idx)
                    break
        self.powerups = [x for x in self.powerups if x.alive]

    def apply_powerup(self, ptype, idx=0):
        """道具效果：星级/命/护盾只给拾取者，冻结/钢墙/全灭全局共享。"""
        self.score += 500
        name = POWERUP_NAMES[ptype]
        p = self.players[idx] if idx < len(self.players) else None
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
            self.p_star[idx] = min(3, self.p_star[idx] + 1)   # $EA07：只加拾取者
            if idx == 0:
                self.player_level = self.p_star[0]
            if p:
                p.level = self.p_star[idx]
                p.st['maxb'] = 2 if p.level >= 2 else 1
                p.st['bullet'] = 4.0 if p.level >= 2 else 3.0
        elif name == 'grenade':
            for t in self.tanks:
                if t.alive and not t.player:
                    t.alive = False
                    self.explosions.append(Explosion(t.x, t.y))
                    self.score += ENEMY_SCORE.get(t.kind, 100)
        elif name == 'tank':
            self.p_lives[idx] += 1              # $EA3E：只加拾取者的命
            self.lives = max(0, self.p_lives[0])
            self.audio.play('bonus')

    def tick_explosion(self, e):
        e.t += 1
        return e.t < e.life

    def game_over(self):
        self.state = 'gameover'
        self.state_timer = 150
        if self.mode == 1:
            self.hi_p2 = max(self.hi_p2, self.score)
        else:
            self.hi_p1 = max(self.hi_p1, self.score)
        self.hi_all = max(self.hi_all, self.score)
        self.audio.play_music('gameover')

    # ---------------- 绘制 ----------------
    def draw(self):
        c = self.canvas
        c.fill((0, 0, 0))
        if self.state in ('title', 'menu'):
            self.draw_title(c)
        elif self.state == 'credits':
            self.draw_credits(c)
        elif self.state == 'stagesel':
            self.draw_stage_select(c)
        elif self.state == 'build':
            self.draw_build(c)
        else:
            self.draw_game(c)
        if self.paused:
            self.banner(c, 'PAUSE')
        pygame.transform.scale(c, self.screen.get_size(), self.screen)

    def draw_game(self, c):
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
        self.draw_curtain(c)
        self.draw_hud(c)
        for x, y, _v, _f in self.out_texts:
            self.text(c, 'GAME OVER', x, y, SPR_PALETTES[1])

        if self.state in ('clear', 'gameover'):
            self.banner(c, 'STAGE CLEAR' if self.state == 'clear' else 'GAME OVER')

    def draw_curtain(self, c):
        if self.curtain <= 0:
            return
        n = self.curtain
        col = NES_PALETTE[self.bg_pal[3][3]]
        for i in range(n):
            top = FIELD_Y - 8 + i * 8
            bot = FIELD_Y + FIELD_W + 8 - (i + 1) * 8
            pygame.draw.rect(c, col, (0, top, SCREEN_W, 8))
            pygame.draw.rect(c, col, (0, bot, SCREEN_W, 8))

    def draw_base(self, c):
        # 老鹰是背景图（PT1）的 $C8/$CA/$C9/$CB 四块，按列序拼成 16×16：
        # TL=C8 BL=C9 / TR=CA BR=CB；被打掉后换成 $CC/$CE/$CD/$CF 的废墟。
        tiles = EAGLE_TILES if self.base_alive else EAGLE_DEAD_TILES
        pal = self.bg_pal[3]          # 与钢墙同一个“白/灰”调色板（原版老鹰是白的）
        for i, tid in enumerate(tiles):
            img = self.assets.tile(tid, pal)
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
        # ROM $DFE9：tile = ($A8 & $F0) + $B0 + dir*8，PT0 里按列拼成 16×16
        if t.player:
            # $EA07：星级直接写进 $A8，所以升星会换一套坦克外观
            base = tank_tile(PLAYER_A8[min(t.level, 3)], TANK_ROM_DIR[t.dir],
                             0x30)          # $B0[X] = $30（$DA73），敌人侧为 0
            # OAM 属性低 2 位 = 槽位号：P1 用 SP0（黄）、P2 用 SP1（绿）
            pal = SPR_PALETTES[t.idx if t.idx is not None else 0]
        else:
            ki = KIND_INDEX.get(t.kind, 0)
            # 敌人的方向码→美术朝向与玩家相反（$80=上 $88=左 $90=下 $98=右）
            base = tank_tile(TANK_TYPE_BASE.get(t.kind, 0x80),
                             TANK_ROM_DIR_ENEMY[t.dir])
            pal = SPR_PALETTES[ENEMY_PALETTE[ki]]
        # 闪光车：原版用帧计数交替调色板（每 16 帧闪一次）
        if t.bonus and not t.player and (self.frames.lo & 0x10):
            pal = SPR_PALETTES[1]
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
        self.text(c, str(max(0, self.p_lives[0])), 32, HUD_Y, SPR_PALETTES[1])
        if self.mode == 1:
            # ⚠️ 原版是 HUD 下移 3 行画第二份；端口底部只有 16px，改画在顶部条
            self.text(c, 'IIP', 8, 0, SPR_PALETTES[1])
            self.text(c, str(max(0, self.p_lives[1])), 40, 0, SPR_PALETTES[1])
        self.text(c, 'STAGE', 168, HUD_Y, SPR_PALETTES[1])
        self.text(c, str(self.stage), 208, HUD_Y, SPR_PALETTES[1])
        self.text(c, 'HI', 8, HUD_Y + 8, SPR_PALETTES[1])
        self.text(c, str(self.score).rjust(5, '0'), 24, HUD_Y + 8, SPR_PALETTES[1])

        # 剩余敌人图标：原版 $C894 —— 2 列 × 10 行、屏幕右缘竖条
        remaining = self.enemies_left + sum(
            1 for t in self.tanks if t.alive and not t.player and t.spawn == 0)
        for i in range(min(20, remaining)):
            x = 232 + (i & 1) * TILE
            y = FIELD_Y + (i >> 1) * TILE
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
            elif ch == ' ':
                tid = 0x20
            elif ch == '.':
                tid = 0x69
            elif ch == '©':
                tid = 0x40
            if tid is None:
                x += 8
                continue
            c.blit(self.assets.tile(tid, pal), (x, y))
            x += 8

    # ---- 标题 / 选单 / 关卡选择（$D17F / $C9C0 / $C159）----
    def logo_tiles(self, ch):
        """$D85E + $D71E：把 PT1 字体的 bitplane0 放大 4 倍成砖块块字。

        每个源像素 → 目标 8×8 tile 里的一个 4×4 象限，
        tile 号就是象限掩码（bit0=TL / bit1=TR / bit2=BL / bit3=BR），
        正好对应 PT1 的 $00-$0F 那组砖纹象限 tile（$0F = 全砖）。
        """
        tiles = self._logo_cache.get(ch)
        if tiles is None:
            px = self.rom.tile_pixels(ord(ch), False)
            on = [[px[y][x] & 1 for x in range(TILE)] for y in range(TILE)]
            tiles = [[0] * 4 for _ in range(4)]
            for ty in range(4):
                for tx in range(4):
                    mask = 0
                    for dy in (0, 1):
                        for dx in (0, 1):
                            if on[ty * 2 + dy][tx * 2 + dx]:
                                mask |= 1 << (dy * 2 + dx)
                    tiles[ty][tx] = mask
            self._logo_cache[ch] = tiles
        return tiles

    def draw_logo(self, c, text, x, y, pal):
        """每个字母 32×32 px = 4×4 个 8px tile（$D8D2 每次 $56 += $20）。"""
        for ch in text:
            tiles = self.logo_tiles(ch)
            for ty in range(4):
                for tx in range(4):
                    c.blit(self.assets.tile(tiles[ty][tx], pal),
                           (x + tx * TILE, y + ty * TILE))
            x += 4 * TILE

    def text_tiles(self, c, tiles, x, y, pal):
        for tid in tiles:
            c.blit(self.assets.tile(tid, pal), (x, y))
            x += TILE

    def draw_title(self, c):
        """标题与选单是同一块屏：标题用垂直偏移模拟 $C7AB 的卷动。"""
        pal = self.bg_pal_sets[TITLE_PAL_SET][0]
        dy = 0 if self.state == 'menu' else TITLE_SCROLL_FRAMES - self.title_scroll
        for text, x, y in LOGO_LINES:
            self.draw_logo(c, text, x, y + dy, pal)
        self.text_tiles(c, (0x5E, 0x6B), 16, 24 + dy, pal)            # "I-"
        self.text(c, str(self.hi_p1), 40, 24 + dy, pal)
        self.text_tiles(c, (0x48, 0x49, 0x6B), 88, 24 + dy, pal)      # "HI-"
        self.text(c, str(self.hi_all), 112, 24 + dy, pal)
        if self.hi_p2:                                                 # "II-"
            self.text_tiles(c, (0x5F, 0x6B), 168, 24 + dy, pal)
            self.text(c, str(self.hi_p2), 192, 24 + dy, pal)
        for i, label in enumerate(MENU_ITEMS):
            self.text(c, label, MENU_TEXT_X, MENU_TEXT_Y + 16 * i + dy, pal)
        self.text_tiles(c, BAND_TILES, MENU_TEXT_X, 184 + dy, pal)
        self.text(c, '© 1980 1985 NAMCO LTD.', 32, 200 + dy, pal)
        self.text(c, 'ALL RIGHTS RESERVED.', 48, 216 + dy, pal)
        if self.state == 'menu':
            # $C9E6：每 4 帧 $B0 ^= 4 → $00/$04 两帧；$DFE9 → tile = $00 + dir*8(dir=0)
            frame = 1 if (self.frames.lo >> 2) & 1 else 0
            img = self.assets.spr(MENU_CURSOR_TILES[frame], SPR_PALETTES[0])
            c.blit(img, (MENU_CURSOR_X,
                         MENU_CURSOR_Y0 + 16 * self.menu_index))

    def draw_credits(self, c):
        """$C49C：4 行文字 + 5 个点逐字出现，最后 $C575 的精灵从 y=30 落到 248。

        ⚠️ 原版进来先调 $D7B4 铺一层场地缓冲再写字，底色来源未取证，这里用黑底。
        """
        pal = self.bg_pal_sets[TITLE_PAL_SET][0]
        shown = max(0, self.credit_step - 1)          # 两次空等之后才出第一行
        for i in range(min(shown, len(CREDITS_LINES))):
            cx, cy, s = CREDITS_LINES[i]
            self.text(c, s, cx * TILE, cy * TILE, pal)
        dots = min(5, max(0, shown - len(CREDITS_LINES)))
        for i in range(dots):
            self.text(c, '.', (CREDITS_DOT_COL + i) * TILE,
                      CREDITS_DOT_ROW * TILE, pal)
        if self.credit_step >= CREDITS_STEPS:          # 下落阶段（$04=1 → SP1）
            c.blit(self.assets.spr(0x9D, SPR_PALETTES[1]),
                   (CREDITS_DROP_X, int(self.drop_y)))

    def draw_stage_select(self, c):
        """$C159：黑屏 + "STAGE" + 关号（A/B 可改）。

        ⚠️ 原版这屏把调色板换成 set 4（$D5A5），但属性字节来源未能从 ROM 证实；
        set 4 slot 0 渲染出来是橙/红/棕的糊图，这里改用标题那套 set 3 slot 0，
        字形颜色（白字 + 红影）与原版截图一致。
        """
        pal = self.bg_pal_sets[STAGE_PAL_SET][0]
        self.text_tiles(c, STAGE_LABEL_TILES, STAGE_TEXT_X, STAGE_TEXT_Y, pal)
        self.text(c, str(self.pending_stage), STAGE_TEXT_X + 7 * TILE,
                  STAGE_TEXT_Y, pal)

    def draw_build(self, c):
        """$C0AE：构造模式画面（场地 + 老鹰 + 光标）。"""
        self.build_field.draw(c, self.assets, self.bg_pal)
        self.draw_base(c)
        cx = FIELD_X + self.build_cursor[0] * BLOCK
        cy = FIELD_Y + self.build_cursor[1] * BLOCK
        if self.frames.lo & 0x10:      # 原版是闪烁的 tile $00，这里画可见框
            pygame.draw.rect(c, NES_PALETTE[0x30], (cx, cy, BLOCK, BLOCK), 1)
        self.text(c, 'CODE %02X' % self.build_code, 8, HUD_Y, SPR_PALETTES[1])

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
    ap.add_argument('--state', default='play',
                    choices=('title', 'menu', 'stagesel', 'build', 'play'),
                    help='--shot 时渲染哪个画面（默认 play）')
    ap.add_argument('--mode', type=int, default=1, choices=(1, 2),
                    help='--state play 时以几人模式开局（调参用）')
    ap.add_argument('--mute', action='store_true', help='静音')
    ap.add_argument('--corner', action='store_true', help='启动后自动移到右下角')
    ap.add_argument('--no-minimize', action='store_true', help='启动时不最小化')
    ap.add_argument('--top', action='store_true', help='窗口置顶（摸鱼用）')
    ap.add_argument('--borderless', action='store_true', help='无边框窗口')
    ap.add_argument('--size', metavar='WxH', help='指定窗口像素尺寸，如 100x100')
    args = ap.parse_args()

    size = None
    if args.size:
        try:
            wstr, hstr = args.size.lower().split('x')
            size = (int(wstr), int(hstr))
        except Exception:
            print('--size 格式应为 100x100'); return

    rom = Rom(args.rom)
    if args.atlas:
        make_atlas(rom)
        return
    if args.shot:
        import os
        os.environ.setdefault('SDL_VIDEODRIVER', 'dummy')
        g = Game(rom, args.scale, sound=not args.mute,
                 corner=args.corner, always_on_top=args.top,
                 borderless=args.borderless, size=size,
                 minimized=not args.no_minimize)
        g.state = args.state
        if args.state == 'title':
            g.title_scroll = args.frames
        elif args.state == 'build':
            g.enter_build()
        elif args.state == 'stagesel':
            g.pending_stage = args.stage
        elif args.state == 'play':
            g.mode = args.mode - 1
            g.reset_run()
            g.stage = args.stage
            g.start_stage()
        for _ in range(args.frames):
            g.tick()
            g.draw()
        pygame.image.save(g.canvas, args.shot)
        print('已保存截图 ->', args.shot)
        return
    Game(rom, args.scale, sound=not args.mute,
         corner=args.corner, always_on_top=args.top,
         borderless=args.borderless, size=size,
         minimized=not args.no_minimize).run()


if __name__ == '__main__':
    main()
