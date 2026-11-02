"""完整复刻渲染：nametable + MMC3 CHR 映射 + 调色板 → PNG。

用法：
    python tools/render_map.py --level 0 --map 2
"""
import argparse
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, '..', 'python'))

try:
    sys.stdout.reconfigure(encoding='utf-8')
except Exception:
    pass

from contra_rom import Rom, NES_PALETTE
from mapdecode import find_rom, load_map, decompress
from chrmap import ChrMapper, tile_pixels

PALETTE_TABLE = 0xD0E3
CHR_TABLE = 0xC78B           # $C778 的 `ASL ASL ASL` → Y = 关卡*8


def code16(rom):
    return rom.prg[len(rom.prg) - 16384:]


def level_chr(rom, level):
    c = code16(rom)
    o = CHR_TABLE + level * 8 - 0xC000
    return list(c[o:o + 8])


def pal_group(rom, g):
    c = code16(rom)
    o = PALETTE_TABLE + g * 3 - 0xC000
    return [0x0F, c[o], c[o + 1], c[o + 2]]


def render(rom, cells, level, pal_bg, scale=3, w=32, h=30):
    from PIL import Image
    banks = level_chr(rom, level)
    # $FACE 写法：R0=bank[0], R1=bank[2], R2=bank[3], R3=bank[4], R4=bank[5], R5=bank[6]
    r = [banks[0], banks[2], banks[3], banks[4], banks[5], banks[6],
         banks[7], 0]
    mapper = ChrMapper(r, 0)
    pal = [NES_PALETTE[v & 0x3F] for v in pal_group(rom, pal_bg)]

    img = Image.new('RGB', (w * 8 * scale, h * 8 * scale), (0, 0, 0))
    px = img.load()
    for row in range(h):
        for col in range(w):
            t = cells.get(0x2000 + row * w + col, 0)
            # nametable 里的 tile 号索引 PT（这里是背景 → CHR $1000 + t*16）
            px8 = tile_pixels(rom, mapper, 0x1000 + t * 16)
            for y in range(8):
                for x in range(8):
                    c = pal[px8[y][x]]
                    for dy in range(scale):
                        for dx in range(scale):
                            px[(col * 8 + x) * scale + dx,
                               (row * 8 + y) * scale + dy] = c
    return img


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--rom', default=None)
    ap.add_argument('--level', type=int, default=0, help='关卡号（定 CHR 表）')
    ap.add_argument('--map', type=int, default=2, help='地图序号（定 nametable）')
    ap.add_argument('--pal', type=int, default=0)
    ap.add_argument('--scale', type=int, default=3)
    ap.add_argument('--outdir', default=None)
    args = ap.parse_args()

    rom = Rom(args.rom or find_rom())
    p, data = load_map(rom, args.map)
    cells, _ = decompress(data, 0)
    print(f'关卡 {args.level} CHR 表: ' +
          ' '.join(f'${v:02X}' for v in level_chr(rom, args.level)))
    print(f'地图 {args.map} (${p:04X}) {len(cells)} 格, '
          f'调色板 {args.pal}: ' + ' '.join(f'${v:02X}' for v in pal_group(rom, args.pal)))
    img = render(rom, cells, args.level, args.pal, args.scale)
    outdir = args.outdir or os.path.join(HERE, '..', 'temp')
    os.makedirs(outdir, exist_ok=True)
    out = os.path.join(outdir, f'L{args.level:02d}_M{args.map:02d}_P{args.pal:02d}.png')
    img.save(out)
    print('->', out)


if __name__ == '__main__':
    main()
