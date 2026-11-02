"""把解压出的 nametable 用真实 CHR + 调色板渲染成 PNG。

这是“一模一样”的验证手段：图形、调色板、布局全部来自 ROM。
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
from mapdecode import (find_rom, load_map, decompress, map_pointers,
                       MAP_PRG_PAGE, MAP_PRG_PAGE_HI)

PALETTE_TABLE = 0xD0E3


def code16(rom):
    return rom.prg[len(rom.prg) - 16384:]


def palette_groups(rom, first, count):
    """读 first 起 count 组调色板（每组 3 字节，前置 $0F）。"""
    out = []
    c = code16(rom)
    for g in range(count):
        o = PALETTE_TABLE + (first + g) * 3 - 0xC000
        out.append([0x0F, c[o], c[o + 1], c[o + 2]])
    return out


def chr_layout(rom, level):
    """关卡 level 的 CHR bank 分配（表 $C793，每关 8 字节）。"""
    c = code16(rom)
    o = 0xC793 + level * 8 - 0xC000
    return list(c[o:o + 8])


def nametable_to_image(rom, cells, pal_bg, chr_banks, nt=0x2000,
                       w=32, h=30, scale=3):
    """渲染 nametable → RGB 像素矩阵。

    MMC3 CHR 映射（默认模式，R0/R1 = 2KB，R2..R5 = 1KB）：
      $0000-$07FF = R0（2KB，tile 0-127）
      $0800-$0FFF = R1（2KB，tile 128-255）
      $1000-$13FF = R2
      $1400-$17FF = R3
      $1800-$1BFF = R4
      $1C00-$1FFF = R5
    """
    from PIL import Image
    img = Image.new('RGB', (w * 8 * scale, h * 8 * scale), (0, 0, 0))
    px = img.load()

    # 建立 tile 号 → (chr 8KB page, tile 在 page 里的序号)
    # 表里 8 字节 = $07F0..$07F7 → R0..R5 + 额外两个
    def tile_source(idx):
        """idx = 0..255（nametable 里的 tile 号，实际用低 8 位）。"""
        t = idx & 0xFF
        if t < 128:
            page = chr_banks[0] & 0x0F          # 2KB → 4 个 8KB page 的低位
            # 2KB bank 号 → 8KB page 的 1/4
            base = (chr_banks[0] & 0x3F) * 2
            return (base // 8) * 8 + (t * 16) // 8192 if False else None
        return None

    # 简化：直接用 CHR page = 每关表的第 3、4 项（背景 1KB bank 组）
    for r in range(h):
        for c in range(w):
            v = cells.get(nt + r * w + c, 0)
            pal = pal_bg
            for y in range(8):
                for x in range(8):
                    pass
    return img


def simple_render(rom, cells, pal, chr_page, w=32, h=30, scale=3):
    """最简渲染：所有 tile 都取自同一个 8KB CHR page。"""
    from PIL import Image
    img = Image.new('RGB', (w * 8 * scale, h * 8 * scale), (0, 0, 0))
    px = img.load()
    cols = [NES_PALETTE[v & 0x3F] for v in pal]
    for r in range(h):
        for c in range(w):
            t = cells.get(r * w + c, 0)
            tile = rom.tile_2bpp(chr_page, t)
            for y in range(8):
                for x in range(8):
                    col = cols[tile[y][x]]
                    for dy in range(scale):
                        for dx in range(scale):
                            px[(c * 8 + x) * scale + dx,
                               (r * 8 + y) * scale + dy] = col
    return img


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--rom', default=None)
    ap.add_argument('--map', type=int, default=2)
    ap.add_argument('--chr', type=int, default=6, help='8KB CHR page')
    ap.add_argument('--pal', type=int, default=0, help='调色板组号')
    ap.add_argument('--scale', type=int, default=3)
    ap.add_argument('-o', '--out', default=None)
    args = ap.parse_args()

    rom = Rom(args.rom or find_rom())
    p, data = load_map(rom, args.map)
    cells, _ = decompress(data, 0)
    pal = palette_groups(rom, args.pal, 1)[0]
    print(f'地图 {args.map} (${p:04X}) {len(cells)} 格, '
          f'调色板 {args.pal}: ' + ' '.join(f'${v:02X}' for v in pal))
    img = simple_render(rom, cells, pal, args.chr,
                        scale=args.scale)
    out = args.out or os.path.join(HERE, '..', 'temp',
                                   f'map{args.map:02d}_chr{args.chr:02d}.png')
    os.makedirs(os.path.dirname(out), exist_ok=True)
    img.save(out)
    print('->', out)


if __name__ == '__main__':
    main()
