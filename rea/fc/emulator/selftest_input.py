"""输入链路自检：不靠人手按键，用合成事件验证 键盘 → 按键掩码 → $4016 读取。

跑法：python emulator/selftest_input.py
通过时退出码 0。
"""

import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import pygame  # noqa: E402

import play_nes  # noqa: E402
from nes import (NES, BTN_A, BTN_B, BTN_SELECT, BTN_START,  # noqa: E402
                 BTN_UP, BTN_DOWN, BTN_LEFT, BTN_RIGHT)

FAILS = []
KB = play_nes.build_keymap(pygame)


def check(name, got, exp):
    if got != exp:
        FAILS.append('%s: got %r want %r' % (name, got, exp))


def mask_of(held, frame=0):
    """等价于窗口循环里的 build_mask（get_pressed 为空快照）。"""
    return play_nes.build_mask(KB, held, pygame.key.ScancodeWrapper(), frame)


def test_keymap_and_mask():
    cases = [
        ('W 上', {pygame.K_w}, BTN_UP),
        ('方向键上', {pygame.K_UP}, BTN_UP),
        ('S 下', {pygame.K_s}, BTN_DOWN),
        ('A 左', {pygame.K_a}, BTN_LEFT),
        ('D 右', {pygame.K_d}, BTN_RIGHT),
        ('F 选择', {pygame.K_f}, BTN_SELECT),
        ('G 选择(别名)', {pygame.K_g}, BTN_SELECT),
        ('H 确认', {pygame.K_h}, BTN_START),
        ('回车确认(别名)', {pygame.K_RETURN}, BTN_START),
        ('J 开火(手柄B)', {pygame.K_j}, BTN_B),
        ('K 跳跃(手柄A)', {pygame.K_k}, BTN_A),
        ('Z 开火(别名)', {pygame.K_z}, BTN_B),
        ('X 跳跃(别名)', {pygame.K_x}, BTN_A),
        ('D+H 右+确认', {pygame.K_d, pygame.K_h}, BTN_RIGHT | BTN_START),
        ('无按键', set(), 0),
    ]
    for name, held, exp in cases:
        check('掩码 ' + name, mask_of(held), exp)


def test_rapid_fire():
    """连发：U→开火(手柄B)、I→跳跃(手柄A)，只有偶数半周期输出。

    两条来源都要测：held（Win32 轮询，本机实际生效的那条）和 get_pressed。
    """
    class FakeKeys:
        def __init__(self, on):
            self.on = on

        def __len__(self):
            return 512

        def __getitem__(self, k):
            return self.on and k in (pygame.K_u, pygame.K_i)

    empty = FakeKeys(False)
    physical = FakeKeys(True)
    period = play_nes.RAPID_HALF * 2
    want_bits = BTN_B | BTN_A                     # U→开火(B)，I→跳跃(A)
    for frame in range(period):
        want = want_bits if (frame // play_nes.RAPID_HALF) % 2 == 0 else 0
        check('连发 held frame=%d' % frame,
              play_nes.build_mask(KB, {pygame.K_u, pygame.K_i}, empty, frame), want)
        check('连发 get_pressed frame=%d' % frame,
              play_nes.build_mask(KB, set(), physical, frame), want)
    # 只按 U：开火有、跳跃没有
    check('只按 U 只出开火',
          play_nes.build_mask(KB, {pygame.K_u}, empty, 0), BTN_B)
    check('只按 I 只出跳跃',
          play_nes.build_mask(KB, {pygame.K_i}, empty, 0), BTN_A)


def test_event_path():
    """KEYDOWN/KEYUP → held 集合（窗口循环用的就是这套）。"""
    os.environ.setdefault('SDL_VIDEODRIVER', 'dummy')
    pygame.display.init()
    pygame.display.set_mode((64, 64))
    pygame.event.pump()
    held = set()

    def drain():
        for ev in pygame.event.get():
            if ev.type == pygame.KEYDOWN and ev.key in KB:
                held.add(ev.key)
            elif ev.type == pygame.KEYUP:
                held.discard(ev.key)

    pygame.event.post(pygame.event.Event(pygame.KEYDOWN, key=pygame.K_d))
    pygame.event.pump()
    drain()
    check('事件按 D → 右', mask_of(held), BTN_RIGHT)

    pygame.event.post(pygame.event.Event(pygame.KEYDOWN, key=pygame.K_h))
    pygame.event.pump()
    drain()
    check('事件再按 H → 右+确认', mask_of(held), BTN_RIGHT | BTN_START)

    pygame.event.post(pygame.event.Event(pygame.KEYUP, key=pygame.K_d))
    pygame.event.pump()
    drain()
    check('松开 D → 只剩确认', mask_of(held), BTN_START)

    pygame.event.post(pygame.event.Event(pygame.KEYUP, key=pygame.K_h))
    pygame.event.pump()
    drain()
    check('再松开 H → 无按键', mask_of(held), 0)
    pygame.display.quit()


def test_emulator_shift_register():
    """掩码 → $4016 串行读出（A,B,Select,Start,Up,Down,Left,Right）。"""
    e = NES(os.path.join(HERE, '..', 'contra', 'Contra.nes'))
    e.set_buttons(BTN_RIGHT | BTN_START)         # 0x88
    e.write_strobe(1)
    e.write_strobe(0)                            # 下降沿锁存
    bits = [e.read_controller(0) & 1 for _ in range(8)]
    exp = [0, 0, 0, 1, 0, 0, 0, 1]               # Start=bit3, Right=bit7
    check('串行位序', bits, exp)
    # 再读 8 次应该全是 1（硬件补 1）
    check('读满后补 1', [e.read_controller(0) & 1 for _ in range(8)], [1] * 8)


def main():
    test_keymap_and_mask()
    test_rapid_fire()
    test_emulator_shift_register()
    test_event_path()
    if FAILS:
        print('FAIL %d 项：' % len(FAILS))
        for f in FAILS:
            print('  -', f)
        return 1
    print('输入链路自检全部通过')
    return 0


if __name__ == '__main__':
    sys.exit(main())
