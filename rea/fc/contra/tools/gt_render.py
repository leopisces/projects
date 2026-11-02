"""用模拟器拿 ground truth nametable，再用真实 MMC3 CHR 映射渲染。

这是最终可信路径：地图数据、CHR bank、调色板全部来自 ROM 实际执行结果。
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
from cpu6502 import CPU6502
from mapexec import MMC3Bus, find_rom
from chrmap import ChrMapper

CHR_TABLE = 0xC793      # $C778: LDA $30 / ASL ASL ASL → Y = 关卡×8
PAL_TABLE = 0xD0E3


def code16(rom):
    return rom.prg[len(rom.prg) - 16384:]


def run_map(rom, idx, page):
    bus = MMC3Bus(rom)
    if page is not None:
        bus.r[6] = page
    cpu = CPU6502(bus)
    cpu.sp = 0xFD
    bus.ram[0x1FF] = 0xFF
    bus.ram[0x1FE] = 0xF0
    cpu.pc = 0xC93A
    cpu.x = (idx * 2) & 0xFF
    n = 0
    try:
        while n < 600000:
            cpu.step()
            n += 1
            if cpu.pc == 0:
                break
    except Exception:
        pass
    return {a: v for a, v in bus.writes if 0x2000 <= a < 0x2800}


def maptable(rom):
    c = code16(rom)
    return [c[0xC9B1 + i * 2 - 0xC000] | c[0xC9B2 + i * 2 - 0xC000] << 8
            for i in range(16)]


def level_regs(rom, level):
    """$C778 写入 $07F0-$07F7，$FACE 取 [0],[2],[4],[5],[6],[7] → R0..R5。"""
    c = code16(rom)
    o = CHR_TABLE + level * 8 - 0xC000
    t = list(c[o:o + 8])
    return t, [t[0], t[2], t[4], t[5], t[6], t[7]]


def render(rom, cells, level, pals, scale=2, w=32, h=30):
    from PIL import Image
    tbl, regs = level_regs(rom, level)
    mapper = ChrMapper(regs + [0, 0], 0)
    cols = [NES_PALETTE[v & 0x3F] for v in pals]

    img = Image.new('RGB', (w * 8 * scale, h * 8 * scale), (0, 0, 0))
    px = img.load()
    for row in range(h):
        for col in range(w):
            t = cells.get(0x2000 + row * w + col, 0)
            page, off = mapper.locate(0x1000 + t * 16)
            blk = rom.chr_page(page % rom.chr_banks)
            o = off & 0x1FFF
            for y in range(8):
                lo = blk[o + y]
                hi = blk[o + y + 8]
                for x in range(8):
                    v = ((lo >> (7 - x)) & 1) | (((hi >> (7 - x)) & 1) << 1)
                    for dy in range(scale):
                        for dx in range(scale):
                            px[(col * 8 + x) * scale + dx,
                               (row * 8 + y) * scale + dy] = cols[v]
    return img


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--map', type=int, default=2)
    ap.add_argument('--level', type=int, default=1)
    ap.add_argument('--pal', type=int, default=0)
    ap.add_argument('--scale', type=int, default=2)
    ap.add_argument('--all-pal', action='store_true')
    ap.add_argument('--outdir', default=None)
    args = ap.parse_args()

    rom = Rom(find_rom())
    ptrs = maptable(rom)
    page = 8 if ptrs[args.map] < 0xA000 else (9 if ptrs[args.map] < 0xC000 else None)
    cells = run_map(rom, args.map, page)
    tbl, regs = level_regs(rom, args.level)
    print(f'地图 {args.map} (${ptrs[args.map]:04X}, PRG page {page}): '
          f'{len(cells)} 格, 非零 {sum(1 for v in cells.values() if v)}')
    print(f'关卡 {args.level} CHR 表: ' + ' '.join(f'${v:02X}' for v in tbl))
    print(f'  → R0..R5 = ' + ' '.join(f'${v:02X}' for v in regs))
    mapper = ChrMapper(regs + [0, 0], 0)
    print('  PT1 映射: ' + ', '.join(
        f'${a:04X}→page{mapper.locate(a)[0]}' for a in (0x1000, 0x1400, 0x1800, 0x1C00)))

    c = code16(rom)
    outdir = args.outdir or os.path.join(HERE, '..', 'temp')
    os.makedirs(outdir, exist_ok=True)
    rng = range(4) if args.all_pal else [args.pal]
    for g in rng:
        o = PAL_TABLE + g * 3 - 0xC000
        pals = [0x0F, c[o], c[o + 1], c[o + 2]]
        img = render(rom, cells, args.level, pals, args.scale)
        out = os.path.join(outdir, f'gt_M{args.map:02d}_L{args.level:02d}_P{g}.png')
        img.save(out)
        print(f'  调色板 {g} ' + ' '.join(f'${v:02X}' for v in pals) + f' -> {os.path.basename(out)}')


if __name__ == '__main__':
    main()
