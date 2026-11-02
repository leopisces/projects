"""Contra（魂斗罗）可玩前端 —— 跑原版 ROM。

用法：
    python python/contra.py                        # 默认找桌面上的 魂斗罗1.nes
    python python/contra.py --rom <path> --scale 2

按键（默认）：
    方向键     移动 / 瞄准
    Z / J      射击（连发）
    X / K      跳跃
    Enter      开始（Start）
    右Shift    选择（Select）
    Esc        退出
    F1/F2      存/读即时存档（temp/state.bin）
    F12        截图到 temp/shot_<frame>.png
"""
import argparse
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(ROOT, 'tools'))

try:
    sys.stdout.reconfigure(encoding='utf-8')
except Exception:
    pass


# ---- NES 手柄位序（$4016 移位顺序：A B Select Start Up Down Left Right）----
BTN_A, BTN_B, BTN_SEL, BTN_START = 0x01, 0x02, 0x04, 0x08
BTN_UP, BTN_DOWN, BTN_LEFT, BTN_RIGHT = 0x10, 0x20, 0x40, 0x80


def find_rom():
    import glob
    cands = []
    for pat in ('魂斗罗*.nes', 'Contra*.nes', 'contra*.nes'):
        cands += glob.glob(os.path.join(os.path.expanduser('~'), 'Desktop', pat))
    cands = [c for c in cands if os.path.getsize(c) > 100000]
    if cands:
        return cands[0]
    raise SystemExit('找不到 ROM，请用 --rom 指定')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--rom', default=None)
    ap.add_argument('--scale', type=int, default=2)
    ap.add_argument('--frameskip', type=int, default=0)
    ap.add_argument('--mute', action='store_true')
    args = ap.parse_args()

    import pygame
    from nes import NES

    rom = args.rom or find_rom()
    print('ROM:', rom)
    nes = NES(rom)

    pygame.init()
    pygame.display.set_caption('Contra (NES) - Python 复刻模拟器')
    w, h = 256 * args.scale, 240 * args.scale
    screen = pygame.display.set_mode((w, h))
    clock = pygame.time.Clock()

    tempdir = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                           '..', 'temp')
    os.makedirs(tempdir, exist_ok=True)

    keymap = {
        pygame.K_z: BTN_A, pygame.K_j: BTN_A,
        pygame.K_x: BTN_B, pygame.K_k: BTN_B,
        pygame.K_RETURN: BTN_START,
        pygame.K_RSHIFT: BTN_SEL,
        pygame.K_UP: BTN_UP, pygame.K_DOWN: BTN_DOWN,
        pygame.K_LEFT: BTN_LEFT, pygame.K_RIGHT: BTN_RIGHT,
    }

    running = True
    frames = 0
    auto_fire = 0
    while running:
        for ev in pygame.event.get():
            if ev.type == pygame.QUIT:
                running = False
            elif ev.type == pygame.KEYDOWN:
                if ev.key == pygame.K_ESCAPE:
                    running = False
                elif ev.key == pygame.K_F12:
                    import pygame.image
                    pygame.image.save(screen, os.path.join(
                        tempdir, 'shot_%06d.png' % nes.ppu.frame))
                    print('截图 -> temp/shot_%06d.png' % nes.ppu.frame)

        keys = pygame.key.get_pressed()
        mask = 0
        for k, bit in keymap.items():
            if keys[k]:
                mask |= bit

        # Contra 的射击是连发友好的；这里每 4 帧自动补一次 A
        if mask & BTN_A:
            auto_fire = (auto_fire + 1) & 3
            if auto_fire:
                pass
            else:
                mask &= ~BTN_A
        nes.set_buttons(mask, 0)
        nes.set_buttons(mask, 1)

        nes.run_frame()
        frames += 1

        if args.frameskip == 0 or (frames % (args.frameskip + 1)) == 0:
            surf = pygame.image.frombuffer(bytes(nes.ppu.framebuffer),
                                           (256, 240), 'RGB')
            if args.scale != 1:
                surf = pygame.transform.scale(surf, (w, h))
            screen.blit(surf, (0, 0))
            pygame.display.flip()

        clock.tick(60)

    pygame.quit()
    print('共运行 %d 帧' % frames)


if __name__ == '__main__':
    main()
