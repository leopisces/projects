"""用 ROM 里的调色板渲染 CHR，验证颜色。

调色板表 $D0E3，每组 3 字节 + 前置 $0F（黑）。
"""
import argparse
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, '..', 'python'))
from contra_rom import Rom, NES_PALETTE

try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

ROOT = os.path.join(HERE, '..')

PALETTE_TABLE = 0xD0E3


def find_rom():
    import glob
    for p in glob.glob(os.path.join(os.path.expanduser('~'), 'Desktop', '*.nes')):
        if os.path.getsize(p) == 393232:
            return p
    raise FileNotFoundError


def palette_group(rom, g):
    code = rom.prg[len(rom.prg) - 16384:]
    o = PALETTE_TABLE + g * 3 - 0xC000
    return [0x0F, code[o], code[o + 1], code[o + 2]]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('page', type=int)
    ap.add_argument('--group', type=int, default=0)
    ap.add_argument('--scale', type=int, default=3)
    ap.add_argument('--start', type=int, default=0)
    ap.add_argument('--count', type=int, default=256)
    ap.add_argument('-o', '--out', default=None)
    args = ap.parse_args()

    from PIL import Image
    rom = Rom(find_rom())
    pal = [NES_PALETTE[v] for v in palette_group(rom, args.group)]
    print(f'调色板组 {args.group}: ' + ' '.join(f'${v:02X}' for v in palette_group(rom, args.group)))

    n = min(args.count, 256 - args.start)
    cols, s = 16, args.scale
    rows = (n + cols - 1) // cols
    img = Image.new('RGB', (cols * 8 * s, rows * 8 * s), (0, 0, 0))
    px = img.load()
    for i in range(n):
        tile = rom.tile_2bpp(args.page, args.start + i)
        cx, cy = (i % cols) * 8, (i // cols) * 8
        for y in range(8):
            for x in range(8):
                c = pal[tile[y][x]]
                for dy in range(s):
                    for dx in range(s):
                        px[cx * s + x * s + dx, cy * s + y * s + dy] = c
    out = args.out or os.path.join(ROOT, 'temp', f'chr{args.page:02d}_g{args.group}.png')
    os.makedirs(os.path.dirname(out), exist_ok=True)
    img.save(out)
    print(f'-> {out}')


if __name__ == '__main__':
    main()
