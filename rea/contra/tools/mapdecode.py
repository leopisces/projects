"""Contra 关卡地图解压（ground truth 已验证）。

数据格式（由 $C93A 解压器 + page 8 实数据双向验证）：
  头部  : 2 字节 VRAM 地址（小端），通常是 $2000 / $2400 ...
  主体  : 循环
    $FF     结束
    $7F     换行（VRAM 地址 = 行首，即 (addr & 0xFFE0) + 32）
    b<0x80  重复 (b) 次下一个字节
    b>=0x80 后跟 (b & 0x7F) 个字节，原样写入

PRG bank 的选取：$C912 里 `LDY #$18 / JSR $F989` 把 R6 写成 $18=24。
MMC3 的 PRG page 字段在 128KB ROM 上是 4 位，$18 & 0x0F = 8，
实测 page 8 的 $8EDF 处正好是合法地图流 → **R6 实际取 page 8**。
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

from contra_rom import Rom

MAP_TABLE = 0xC9B1
# $C912 的 LDY #$18 → & 0x0F = 8（8KB page）
MAP_PRG_PAGE = 8
MAP_PRG_PAGE_HI = 9         # R7 = $18+1 = $19 → & 0x0F = 9


def find_rom():
    import glob
    for p in glob.glob(os.path.join(os.path.expanduser('~'), 'Desktop', '*.nes')):
        if os.path.getsize(p) == 393232:
            return p
    raise FileNotFoundError


def map_pointers(rom, count=16):
    code = rom.prg[len(rom.prg) - 16384:]
    out = []
    for i in range(count):
        o = MAP_TABLE + i * 2 - 0xC000
        out.append(code[o] | code[o + 1] << 8)
    return out


def decompress(data, start_addr):
    """返回 (addr → tile) 字典 + 结束偏移。"""
    if len(data) < 2:
        return {}, 0
    addr = data[0] | data[1] << 8
    i = 2
    cells = {}
    while i < len(data):
        b = data[i]
        i += 1
        if b == 0xFF:
            break
        if b == 0x7F:
            # 换行：跳到下一行行首
            addr = ((addr & 0xFFE0) + 32) & 0x3FFF
            continue
        if b & 0x80:
            n = b & 0x7F
            for _ in range(n):
                if i >= len(data):
                    break
                cells[addr] = data[i]
                addr = (addr + 1) & 0x3FFF
                i += 1
        else:
            n = b
            if i >= len(data):
                break
            v = data[i]
            i += 1
            for _ in range(n):
                cells[addr] = v
                addr = (addr + 1) & 0x3FFF
    return cells, i


def load_map(rom, index):
    ptrs = map_pointers(rom)
    p = ptrs[index]
    if p >= 0xE000:
        data = rom.fixed8k()[p - 0xE000:]
    elif p >= 0xC000:
        data = rom.prg[len(rom.prg) - 16384:][p - 0xC000:]
    elif p >= 0xA000:
        data = rom.page8k(MAP_PRG_PAGE_HI)[p - 0xA000:]
    else:
        data = rom.page8k(MAP_PRG_PAGE)[p - 0x8000:]
    return p, data


def render(cells, nt=0x2000, w=32, h=30):
    lines = []
    for r in range(h):
        line = []
        for c in range(w):
            v = cells.get(nt + r * w + c)
            line.append('.' if v is None else '%02X' % v)
        lines.append(line)
    return lines


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--rom', default=None)
    ap.add_argument('--index', type=int, default=None)
    ap.add_argument('--hex', action='store_true')
    args = ap.parse_args()

    rom = Rom(args.rom or find_rom())
    idxs = [args.index] if args.index is not None else range(16)
    for i in idxs:
        p, data = load_map(rom, i)
        cells, used = decompress(data, 0)
        print('=' * 70)
        print(f'地图 {i}: 指针 ${p:04X}, 消耗 {used} 字节, 写入 {len(cells)} 格')
        if not cells:
            print('  (空)')
            continue
        for r in render(cells):
            print('  ' + (' '.join(r) if args.hex else
                          ''.join(c[-1] for c in r)))


if __name__ == '__main__':
    main()
