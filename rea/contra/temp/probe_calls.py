"""临时探针：扫所有 bank，找 JSR 到 $87xx/$88xx（声音请求区）的调用点。

用法：python temp/probe_calls.py [--lo 8700] [--hi 88FF]
"""
import argparse
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', 'tools'))

from play_sound import Harness   # noqa: E402

LO, HI = 0x8700, 0x88FF


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--lo', default='8700')
    ap.add_argument('--hi', default='88FF')
    ap.add_argument('--limit', type=int, default=40)
    args = ap.parse_args()
    lo, hi = int(args.lo, 16), int(args.hi, 16)

    h = Harness()
    rom = h.rom
    n = getattr(rom, 'nbanks', None) or getattr(rom, 'bank_count', None) or 0
    if not n:
        n = 1
        while True:
            try:
                rom.bank(n)
                n += 1
            except Exception:
                break
    print('bank 数 = %d' % n)

    found = []
    for bank in range(0, n):
        try:
            b = rom.bank(bank)
        except Exception:
            continue
        for i in range(1, len(b) - 2):
            if b[i] != 0x20:
                continue
            tgt = b[i + 1] | (b[i + 2] << 8)
            if not (lo <= tgt <= hi):
                continue
            sid = None
            for back in range(1, 14):
                if b[i - back] == 0xA9:
                    sid = b[i - back + 1]
                    break
                if b[i - back] == 0x20:
                    break
            found.append((bank, 0x8000 + i, tgt, sid))

    print('命中 %d 处：' % len(found))
    for bank, addr, tgt, sid in found[:args.limit]:
        print('  bank %-3d $%04X -> JSR $%04X  id=%s' % (
            bank, addr, tgt, '-' if sid is None else '$%02X' % sid))


if __name__ == '__main__':
    main()
