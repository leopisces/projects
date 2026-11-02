"""解压 Contra 的关卡地图数据。

格式（由 $C93A 解压器逆向，地址级证据见 REPORT.md）：
  每个地图 = 一串指令，写入 VRAM（$2007）：
    $FF       结束
    $7F       换行（到下一行的左边）
    $80|n     重复下一个字节 n 次（n = 低 7 位）
    其他      直接写一个 tile

指针表在 $C9B1（固定 bank），每项 16bit 小端 → 目标在 $8000-$BFFF，
需要知道当时哪个 PRG bank 映射在那里。⚠️ 具体 bank 由调用方决定。
"""
import argparse
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, '..', 'python'))
from contra_rom import Rom

try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

MAP_TABLE = 0xC9B1


def find_rom():
    import glob
    for p in glob.glob(os.path.join(os.path.expanduser('~'), 'Desktop', '*.nes')):
        if os.path.getsize(p) == 393232:
            return p
    raise FileNotFoundError


def code16(rom):
    return rom.prg[len(rom.prg) - 16384:]


def map_pointers(rom, count=16):
    code = code16(rom)
    out = []
    for i in range(count):
        o = MAP_TABLE + i * 2 - 0xC000
        if o + 1 >= len(code):
            break
        out.append(code[o] | code[o + 1] << 8)
    return out


def decompress(data, width=32):
    """解压地图流 → 行列表（每行 width 个 tile）。"""
    rows = [[]]
    i = 0
    while i < len(data):
        b = data[i]
        i += 1
        if b == 0xFF:
            break
        if b == 0x7F:
            rows.append([])
            continue
        if b & 0x80:
            n = b & 0x7F
            if i >= len(data):
                break
            v = data[i]
            i += 1
            rows[-1].extend([v] * n)
        else:
            rows[-1].append(b)
    return rows


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--rom', default=None)
    ap.add_argument('--bank', type=int, default=None,
                    help='PRG bank 号（$8000 映射的 16KB bank），不给则从所有 bank 里找')
    ap.add_argument('--index', type=int, default=None, help='地图序号，不给则全部')
    ap.add_argument('--raw', action='store_true', help='打印原始字节')
    args = ap.parse_args()

    rom = Rom(args.rom or find_rom())
    ptrs = map_pointers(rom)
    print('地图指针表 $C9B1:')
    for i, p in enumerate(ptrs):
        print(f'  [{i:2d}] ${p:04X}' + ('  (在固定 bank $C000-$FFFF)'
                                        if p >= 0xC000 else '  ⚠️ 在 $8000-$BFFF，需切 bank'))
    print()

    idxs = [args.index] if args.index is not None else range(len(ptrs))
    for i in idxs:
        p = ptrs[i]
        print('=' * 70)
        print(f'地图 {i}: ${p:04X}')
        if p >= 0xC000:
            data = code16(rom)[p - 0xC000:p - 0xC000 + 0x1000]
            src = '固定 bank'
        else:
            if args.bank is not None:
                b = rom.bank(args.bank)
                data = b[p - 0x8000:]
                src = f'bank {args.bank}'
            else:
                # 在所有 bank 里找最短的合理解压结果
                best = None
                for bn in range(rom.prg_banks):
                    b = rom.bank(bn)
                    d = b[p - 0x8000:p - 0x8000 + 0x2000]
                    rows = decompress(d)
                    total = sum(len(r) for r in rows)
                    if 50 < total < 2000:
                        cand = (len(rows), bn, d, rows)
                        if best is None or cand[0] < best[0]:
                            best = cand
                if best is None:
                    print('  找不到合理解压结果')
                    continue
                _, bn, data, rows = best
                src = f'bank {bn}（自动选出最合理的）'
                print(f'  来源: {src}')
                if args.raw:
                    print('  raw:', data[:64].hex(' '))
                for r in rows[:30]:
                    print('  ' + ''.join('%X' % (v & 0xF) for v in r[:64]))
                continue
        rows = decompress(data)
        print(f'  来源: {src}  行数={len(rows)}')
        if args.raw:
            print('  raw:', data[:64].hex(' '))
        for r in rows[:40]:
            print('  ' + ''.join('%X' % (v & 0xF) for v in r[:64]))


if __name__ == '__main__':
    main()
