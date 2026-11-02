"""通用 NES 播放器 —— 任意 iNES ROM 都能跑。

用法:
    python tools/play_nes.py 游戏.nes
    python tools/play_nes.py 游戏.nes --scale 3
    python tools/play_nes.py 游戏.nes --headless --frames 600        # 无窗口测速
    python tools/play_nes.py 游戏.nes --headless --frames 300 --shot 150  # 截一帧 PNG

不写 ROM 路径时，如果当前目录/上级目录只有一个 .nes 文件，就直接用它。
截图默认写到本次会话的归档目录 artifacts/shots（见 TEMP_DIR），--outdir 或环境变量 NES_TEMP_DIR 可改。

按键:
    W A S D   上左下右（方向键也可）
    F         Select
    H         Start（确认）
    J         开火（手柄 B）
    K         跳跃（手柄 A）
    Z / X     开火 / 跳跃 的备用键
    U         连发开火（按住约 15 次/秒）
    I         连发跳跃
    P         暂停        F1  显示/隐藏 FPS+PC
    F12       截图（存到当前目录 shot_*.png）    ESC  退出

支持 mapper：0/1/2/3/4/7/11/13/66（见 mappers.py）。
"""
import glob
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
if HERE not in sys.path:
    sys.path.insert(0, HERE)

try:
    sys.stdout.reconfigure(encoding='utf-8')
except Exception:
    pass

from nes import (NES, BTN_A, BTN_B, BTN_SELECT, BTN_START,
                 BTN_UP, BTN_DOWN, BTN_LEFT, BTN_RIGHT)
from mappers import supported

try:                                    # 只 import，不 init；build_mask 里要用常量
    import pygame
except ImportError:                     # 无 pygame 时 headless 仍可用
    pygame = None

SCALE = 1            # 默认原大小（256x240）；--scale N 放大，N<=0 则自动铺满屏幕
HUD_H = 26           # 窗口底部信息栏高度（不遮游戏画面）
BASE_W, BASE_H = 256, 240

# 手柄按键的语义别名：Contra 这类游戏 B=开火、A=跳跃（$4016 bit0=A、bit1=B）。
BTN_FIRE = BTN_B
BTN_JUMP = BTN_A
RAPID_HALF = 2          # 连发：2 帧按住 / 2 帧松开 → 60fps 下约 15 次/秒

# 临时产物（截图/录屏/调试图）一律不放仓库，也不放 D:\Codes\temps：
# 直接落到本次会话的归档目录下（D:\Codes\Sessions/<日期>/<会话>/artifacts/shots）。
# 优先级：--outdir > 环境变量 NES_TEMP_DIR > 下面的默认值。
DEFAULT_TEMP_DIR = os.path.join(
    r'D:\Codes\Sessions', '2026-11-02', '1045_Contra 原版鉴定与仓库整理', 'artifacts', 'shots')
TEMP_DIR = os.environ.get('NES_TEMP_DIR') or DEFAULT_TEMP_DIR


def find_rom():
    """没有给路径时找一个 .nes。"""
    for pat in ('*.nes', os.path.join('..', '*.nes')):
        hits = sorted(glob.glob(pat))
        if len(hits) == 1:
            return hits[0]
        if len(hits) > 1:
            raise SystemExit('找到多个 .nes，请指定一个：\n  ' + '\n  '.join(hits))
    raise SystemExit('用法: python play_nes.py 游戏.nes（当前目录没有 .nes 文件）')


# ======================================================================
# 无窗口模式
# ======================================================================
def ascii_frame(buf, cols=64):
    """把 framebuffer 粗成 ASCII 图（64×30），用来看画面是否正常。"""
    chars = ' .:-=+*#%@'
    rows = []
    for y in range(0, BASE_H, 8):
        line = []
        for x in range(0, BASE_W, 4):
            o = (y * BASE_W + x) * 3
            lum = (buf[o] * 299 + buf[o + 1] * 587 + buf[o + 2] * 114) // 1000
            line.append(chars[min(len(chars) - 1, lum * len(chars) // 256)])
        rows.append(''.join(line))
    return '\n'.join(rows)


def run_headless(rom, frames, shot=None, board=None, start=False, quiet=False):
    emu = NES(rom)
    print(emu.info())
    t0 = time.perf_counter()
    for i in range(frames):
        mask = 0
        if board is not None:
            board(emu, i)
        if start and i < 60:
            mask |= BTN_START
        emu.set_buttons(mask)
        emu.run_frame()
        if shot is not None and i == shot - 1:
            save_png(emu.ppu.framebuffer, 'shot_%04d.png' % i)
    dt = time.perf_counter() - t0
    fps = frames / dt if dt else 0
    print('无窗口跑 %d 帧：%.2fs，%.1f fps（%.1f ms/帧），PC=$%04X'
          % (frames, dt, fps, dt / max(1, frames) * 1000, emu.cpu.pc))
    if quiet:
        return emu
    print(ascii_frame(emu.ppu.framebuffer))
    return emu


def save_png(framebuffer, path):
    """存 PNG；相对路径一律落到 TEMP_DIR，不往仓库里丢临时文件。"""
    import pygame
    if not os.path.isabs(path):
        os.makedirs(TEMP_DIR, exist_ok=True)
        path = os.path.join(TEMP_DIR, path)
    surf = pygame.image.frombuffer(bytes(framebuffer), (BASE_W, BASE_H), 'RGB')
    pygame.image.save(surf, path)
    print('截图 →', os.path.abspath(path))


# ======================================================================
# 窗口模式
# ======================================================================
VK_MAP = {                     # Win32 虚拟键码 → pygame 键码（GetAsyncKeyState 用）
    0x57: 'K_w', 0x41: 'K_a', 0x53: 'K_s', 0x44: 'K_d',
    0x26: 'K_UP', 0x28: 'K_DOWN', 0x25: 'K_LEFT', 0x27: 'K_RIGHT',
    0x46: 'K_f', 0x47: 'K_g', 0xA0: 'K_RSHIFT',
    0x48: 'K_h', 0x0D: 'K_RETURN',
    0x4A: 'K_j', 0x5A: 'K_z', 0x4B: 'K_k', 0x58: 'K_x',
    0x55: 'K_u', 0x49: 'K_i',
}


def win32_held(pg):
    """用 GetAsyncKeyState 直接问操作系统要按键状态（返回 pygame 键码集合）。

    不走 SDL 事件队列，也不依窗口焦点——常见两种「按了没反应」都绕过去了：
      1. SDL 窗口在后台启动 / 失焦，get_pressed() 常年全 0；
      2. 中文输入法占着焦点，按键被 IME 吃掉，窗口收不到 WM_KEYDOWN。
    """
    try:
        import ctypes
        u = ctypes.windll.user32
    except Exception:
        return set()
    held = set()
    for vk, name in VK_MAP.items():
        if u.GetAsyncKeyState(vk) & 0x8000:
            kc = getattr(pg, name, None)
            if kc is not None:
                held.add(kc)
    return held


def build_keymap(pg):
    """pygame 键码 → NES 按键位（play_nes 与 selftest_input 共用）。"""
    return {
        pg.K_w: BTN_UP, pg.K_UP: BTN_UP,
        pg.K_s: BTN_DOWN, pg.K_DOWN: BTN_DOWN,
        pg.K_a: BTN_LEFT, pg.K_LEFT: BTN_LEFT,
        pg.K_d: BTN_RIGHT, pg.K_RIGHT: BTN_RIGHT,
        pg.K_f: BTN_SELECT, pg.K_g: BTN_SELECT, pg.K_RSHIFT: BTN_SELECT,
        pg.K_h: BTN_START, pg.K_RETURN: BTN_START,
        pg.K_j: BTN_FIRE, pg.K_z: BTN_FIRE,
        pg.K_k: BTN_JUMP, pg.K_x: BTN_JUMP,
    }


def build_mask(KB, held, keys, frame):
    """事件按键集 ∪ get_pressed 快照 → 一个 NES 按键掩码。"""
    mask = 0
    for k, bit in KB.items():
        if k in held or (k < len(keys) and keys[k]):
            mask |= bit
    if (frame // RAPID_HALF) % 2 == 0:            # 连发：held 里也有 Win32 读到的键
        if pygame.K_u in held or (len(keys) > pygame.K_u and keys[pygame.K_u]):
            mask |= BTN_FIRE
        if pygame.K_i in held or (len(keys) > pygame.K_i and keys[pygame.K_i]):
            mask |= BTN_JUMP
    return mask


def pick_scale(scale):
    """scale<=0 时自动选：铺满屏幕高度 90% 的最大整数倍，1..8。

    用 Win32 GetSystemMetrics 取屏幕尺寸——不走 pygame，避免为了量屏幕而
    初始化 SDL（pygame.init() 还会拉 mixer，无声卡时要卡好几秒）。
    """
    if scale and scale > 0:
        return scale
    try:
        import ctypes
        u = ctypes.windll.user32
        w, h = u.GetSystemMetrics(0), u.GetSystemMetrics(1)
    except Exception:
        w, h = 1920, 1080
    s = min((h - HUD_H - 80) // BASE_H, w // BASE_W) or 1
    return max(1, min(8, s))


def run_window(rom, scale=SCALE, start=False, sound=True):
    import pygame
    import numpy as np
    from apu import SR as APU_SR

    emu = NES(rom)
    scale = pick_scale(scale)
    print(emu.info())
    print('按键：WASD 方向  F 选择  H 确认  J 开火  K 跳跃  U 连发开火  P 暂停  ESC 退出')
    print('显示：%dx%d（%d 倍，--scale N 可指定）' % (BASE_W * scale, BASE_H * scale, scale))

    pygame.display.init()
    pygame.font.init()

    # ---- 音频：44100Hz / 16bit / 单声道，每帧 735 个采样进队列 ----
    snd = None
    mixer_channels = 1
    if sound:
        try:
            # SDL 在这台机器上会把单声道请求退化成双声道（实测 get_init()
            # 回来的是 -16/2），所以不假设声道数，按实际 init 结果决定。
            pygame.mixer.pre_init(APU_SR, -16, 1, 1024)
            pygame.mixer.init()
            pygame.mixer.set_num_channels(2)
            got = pygame.mixer.get_init()
            mixer_channels = got[2] if got else 1
            snd = pygame.mixer.Channel(1)
            print('声音：%d Hz / %d 声道（--no-sound 可关）' % (APU_SR, mixer_channels))
        except Exception as e:                # 没声卡 / mixer 起不来时照样能玩
            print('音频初始化失败，静音运行：%s' % e)
            snd = None
    pygame.display.set_caption('NES — %s' % os.path.basename(rom))
    screen = pygame.display.set_mode((BASE_W * scale, BASE_H * scale + HUD_H))
    font = pygame.font.SysFont('consolas,monospace', 13)
    clock = pygame.time.Clock()

    # 从后台/脚本启动时窗口往往抢不到键盘焦点，主动拉一次到前台
    try:
        import ctypes
        hwnd = pygame.display.get_wm_info().get('window')
        if hwnd:
            u = ctypes.windll.user32
            u.ShowWindow(hwnd, 5)             # SW_SHOW
            u.SetForegroundWindow(hwnd)
    except Exception:
        pass

    paused = False
    show_hud = True
    frame = 0
    running = True
    held = set()                              # 事件版按键状态（比 get_pressed 更可靠）
    FOCUS_LOST = getattr(pygame, 'WINDOWFOCUSLOST', -1)
    grab = True                               # 允许 Win32 全局轮询（窗口没焦点也能玩）
    last_mask = 0
    last_draw = 0.0
    last_drawn_frame = -1
    keylog = None
    if os.environ.get('NES_KEYLOG'):
        keylog = open(os.environ['NES_KEYLOG'], 'a', buffering=1)
    KB = build_keymap(pygame)
    while running:
        for ev in pygame.event.get():
            if ev.type == pygame.QUIT:
                running = False
            elif ev.type == pygame.KEYDOWN:
                if ev.key in KB:
                    held.add(ev.key)              # 先入位，避免落键在帧间被丢
                if ev.key == pygame.K_ESCAPE:
                    running = False
                elif ev.key == pygame.K_p:
                    paused = not paused
                elif ev.key == pygame.K_F1:
                    show_hud = not show_hud
                elif ev.key == pygame.K_F12:
                    save_png(emu.ppu.framebuffer, 'shot_%05d.png' % frame)
            elif ev.type == pygame.KEYUP:
                held.discard(ev.key)
            elif ev.type == FOCUS_LOST:
                held.clear()                      # 失焦时清空，防按键卡住

        keys = pygame.key.get_pressed()
        wh = win32_held(pygame) if grab else set()
        mask = build_mask(KB, held | wh, keys, frame)
        if keylog is not None and mask != last_mask:
            keylog.write('%d %02X focus=%d held=%s w32=%s\n' % (
                frame, mask, int(pygame.key.get_focused()),
                sorted(KB.get(k, k) for k in held), sorted(KB.get(k, k) for k in wh)))
            last_mask = mask
        if start and frame < 60:
            mask |= BTN_START

        if not paused:
            emu.set_buttons(mask)
            emu.run_frame(audio=snd is not None)
            frame += 1
            if snd is not None and emu.audio is not None:
                x = emu.audio
                x = x - x.mean()          # 去非线性混音的直流偏置
                pcm = np.clip(x * 28000.0, -32768, 32767).astype('<i2')
                if mixer_channels == 2:
                    pcm = np.repeat(pcm, 2)   # 双声道：每个样本重复一次
                snd.queue(pygame.sndarray.make_sound(
                    pcm.reshape(-1, mixer_channels)))

        # 跳帧保速：模拟器照旧每帧完整跑（游戏逻辑按满帧率走、声音不会变慢），
        # 只是不每帧都重画。pygame 这边要补上：CPU/PPU/APU 就要花 15-20 ms，
        # 再加上 tofrombuffer + fill + blit + flip + clock.tick 那 3-5 ms，
        # 不足 60fps 时全是拖后腿的部分。
        now = time.perf_counter()
        if frame != last_drawn_frame and now - last_draw >= 1.0 / 60.0:
            last_draw = now
            last_drawn_frame = frame
            surf = pygame.image.frombuffer(
                bytes(emu.ppu.framebuffer), (BASE_W, BASE_H), 'RGB')
            if scale != 1:
                surf = pygame.transform.scale(surf, (BASE_W * scale, BASE_H * scale))
            screen.fill((0, 0, 0))
            screen.blit(surf, (0, 0))
            if show_hud:
                y0 = BASE_H * scale + 4
                hud = 'fps %4.1f  帧 %d  PC $%04X  键 %02X  声%s  焦点%s%s' % (
                    clock.get_fps(), frame, emu.cpu.pc, mask,
                    '开' if snd is not None else '关',
                    '✓' if pygame.key.get_focused() else '✗（点一下窗口）',
                    '  [暂停]' if paused else '')
                screen.blit(font.render(hud, True, (255, 255, 0), (0, 0, 0)), (4, y0))
                tip = 'WASD 方向  F 选择  H 确认  J 开火  K 跳跃  U 连发开火  P 暂停  F12 截图'
                screen.blit(font.render(tip, True, (170, 170, 170), (0, 0, 0)), (4, y0 + 14))
            pygame.display.flip()
        clock.tick(60)

    pygame.quit()


def main():
    global TEMP_DIR
    args = sys.argv[1:]
    scale = SCALE
    headless = False
    frames = 300
    shot = None
    start = False
    sound = True
    rom = None

    i = 0
    while i < len(args):
        a = args[i]
        if a == '--scale':
            i += 1
            scale = max(1, int(args[i]))
        elif a == '--outdir':
            i += 1
            TEMP_DIR = args[i]
        elif a == '--headless':
            headless = True
        elif a == '--frames':
            i += 1
            frames = int(args[i])
        elif a == '--shot':
            i += 1
            shot = int(args[i])
        elif a == '--no-sound':
            sound = False
        elif a in ('--start', '-s'):
            start = True
        elif a in ('-h', '--help'):
            print(__doc__)
            return 0
        elif a.startswith('-'):
            raise SystemExit('未知参数 %s（-h 看用法）' % a)
        else:
            rom = a
        i += 1

    if rom is None:
        rom = find_rom()
    if not os.path.exists(rom):
        raise SystemExit('找不到 ROM：%s' % rom)

    try:
        if headless:
            run_headless(rom, frames, shot=shot, start=start)
        else:
            run_window(rom, scale=scale, start=start, sound=sound)
    except Exception as e:
        if type(e).__name__ == 'UnsupportedMapper':
            print(e)
            print('当前支持：%s' % ', '.join('%d=%s' % kv for kv in supported().items()))
            return 2
        raise
    return 0


if __name__ == '__main__':
    sys.exit(main())
