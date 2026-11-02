"""把 NES 画面打成字符图，方便在没有图形界面时检查渲染是否正确。

用法:
    python emulator/preview.py contra/Contra.nes --frames 300
    python emulator/preview.py contra/Contra.nes --frames 800 --press 60:START --press 70:START
    python emulator/preview.py x.nes --frames 300 --mode tile     # 按 8x8 块分类
    python emulator/preview.py x.nes --frames 300 --mode color    # 按块主色

--mode braille  2x4 像素一个盲文字符，分辨率 128x60（默认）
--mode tile     每个 8x8 块一个字符：' '=全黑  '.'=少量亮点  '+'=半满  '#'=满
--mode color    每个 8x8 块一个字符，代表该块里出现最多的颜色（字母 A-P 表示调色板索引）
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from nes import NES  # noqa: E402

# 盲文点位 -> 位值
_BRAILLE = ((0x01, 0x08), (0x02, 0x10), (0x04, 0x20), (0x40, 0x80))


def _lum(fb, i):
    return fb[i] * 299 + fb[i + 1] * 587 + fb[i + 2] * 114


def to_braille(fb, width=256, height=240, threshold=40000):
    rows = []
    for by in range(0, height, 4):
        line = []
        for bx in range(0, width, 2):
            bits = 0
            for dy in range(4):
                y = by + dy
                if y >= height:
                    break
                base = (y * width + bx) * 3
                for dx in range(2):
                    if bx + dx >= width:
                        break
                    if _lum(fb, base + dx * 3) > threshold:
                        bits |= _BRAILLE[dy][dx]
            line.append(chr(0x2800 + bits) if bits else ' ')
        rows.append(''.join(line).rstrip())
    return '\n'.join(rows)


def to_tile(fb, width=256, height=240, threshold=40000):
    rows = []
    for by in range(0, height, 8):
        line = []
        for bx in range(0, width, 8):
            on = 0
            for dy in range(8):
                base = ((by + dy) * width + bx) * 3
                for dx in range(8):
                    if _lum(fb, base + dx * 3) > threshold:
                        on += 1
            if on == 0:
                line.append(' ')
            elif on < 16:
                line.append('.')
            elif on < 48:
                line.append('+')
            else:
                line.append('#')
        rows.append(''.join(line).rstrip())
    return '\n'.join(rows)


def to_color(fb, width=256, height=240, threshold=40000):
    rows = []
    for by in range(0, height, 8):
        line = []
        for bx in range(0, width, 8):
            hist = {}
            for dy in range(8):
                base = ((by + dy) * width + bx) * 3
                for dx in range(8):
                    i = base + dx * 3
                    if _lum(fb, i) <= threshold:
                        continue
                    key = (fb[i], fb[i + 1], fb[i + 2])
                    hist[key] = hist.get(key, 0) + 1
            if not hist:
                line.append(' ')
                continue
            key = max(hist, key=hist.get)
            line.append(chr(ord('A') + (hist[key] % 16)))
        rows.append(''.join(line).rstrip())
    return '\n'.join(rows)


BUTTONS = ('A', 'B', 'SELECT', 'START', 'UP', 'DOWN', 'LEFT', 'RIGHT')
# 位序与 nes.read_controller 一致：A 最先输出 → bit0
BIT = {n: 1 << i for i, n in enumerate(BUTTONS)}


def parse_press(spec):
    """'60:START+A' -> (60, ('A', 'START'))"""
    frame, _, names = spec.partition(':')
    names = names.upper().replace(' ', '').split('+') if names else []
    for n in names:
        if n and n not in BUTTONS:
            raise SystemExit('未知按键 %r（可选 %s）' % (n, ', '.join(BUTTONS)))
    return int(frame), tuple(n for n in names if n)


def main(argv):
    if not argv:
        print(__doc__)
        return 1
    rom = argv[0]
    frames = 300
    mode = 'braille'
    threshold = 40000
    presses = []
    i = 1
    while i < len(argv):
        a = argv[i]
        if a in ('--frames', '-f'):
            frames = int(argv[i + 1]); i += 2
        elif a == '--mode':
            mode = argv[i + 1]; i += 2
        elif a == '--threshold':
            threshold = int(argv[i + 1]); i += 2
        elif a == '--press':
            presses.append(parse_press(argv[i + 1])); i += 2
        else:
            raise SystemExit('未知参数 %r' % a)

    nes = NES(rom)
    held = {}
    by_frame = {}
    for f, names in presses:
        by_frame.setdefault(f, []).extend(names)
    for fr in range(1, frames + 1):
        for n in by_frame.get(fr, ()):
            held[n] = fr + 2                      # 按住 3 帧
        btns = {n for n, until in held.items() if until >= fr}
        mask = 0
        for n in btns:
            mask |= BIT[n]
        nes.set_buttons(mask)
        nes.run_frame()

    fb = nes.ppu.framebuffer
    ink = sum(1 for j in range(0, len(fb), 3) if fb[j] or fb[j + 1] or fb[j + 2])
    print('# %s  frames=%d  ink=%d' % (os.path.basename(rom), frames, ink))
    if mode == 'braille':
        print(to_braille(fb, threshold=threshold))
    elif mode == 'tile':
        print(to_tile(fb, threshold=threshold))
    elif mode == 'color':
        print(to_color(fb, threshold=threshold))
    else:
        raise SystemExit('未知 mode %r' % mode)
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
