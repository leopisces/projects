"""渲染 CHR bank 里的 tile 到 PNG，用于识别图形用途。

用法：
    python tools/chrview.py 4              # 渲染 CHR page 4 全部 256 tile
    python tools/chrview.py 4 0 64         # 只渲染 tile 0..63
"""
import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', 'python'))
from contra_rom import Rom, NES_PALETTE

try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')


def find_rom():
    """按文件大小找 ROM（避开中文文件名编码问题）。"""
    import glob
    for p in glob.glob(os.path.join(os.path.expanduser('~'), 'Desktop', '*.nes')):
        if os.path.getsize(p) == 393232:      # Contra: 8*16K PRG + 32*8K CHR + 16
            return p
    raise FileNotFoundError('找不到 393232 字节的 .nes')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('page', type=int)
    ap.add_argument('start', type=int, nargs='?', default=0)
    ap.add_argument('count', type=int, nargs='?', default=256)
    ap.add_argument('--rom', default=None)
    ap.add_argument('-o', '--out', default=None)
    ap.add_argument('--scale', type=int, default=3)
    args = ap.parse_args()

    from PIL import Image

    rom = Rom(args.rom or find_rom())
    n = min(args.count, 256 - args.start)
    cols = 16
    rows = (n + cols - 1) // cols
    s = args.scale
    img = Image.new('RGB', (cols * 8 * s, rows * 8 * s), (0, 0, 0))
    px = img.load()

    # 用灰阶调色板，看得清形状
    gray = [(0, 0, 0), (85, 85, 85), (170, 170, 170), (255, 255, 255)]
    for i in range(n):
        t = args.start + i
        tile = rom.tile_2bpp(args.page, t)
        cx = (i % cols) * 8
        cy = (i // cols) * 8
        for y in range(8):
            for x in range(8):
                c = gray[tile[y][x]]
                for dy in range(s):
                    for dx in range(s):
                        px[cx * s + x * s + dx, cy * s + y * s + dy] = c
    out = args.out or os.path.join(ROOT, 'temp', f'chr{args.page:02d}.png')
    os.makedirs(os.path.dirname(out), exist_ok=True)
    img.save(out)
    print(f'CHR page {args.page} tile {args.start}..{args.start+n-1} -> {out}')


if __name__ == '__main__':
    main()
