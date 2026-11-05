"""临时探针：追踪一帧里引擎执行的指令，找出"读取时值/写 $0100"的地方。

用法：python temp/probe_trace.py --id 0x07 --frame 1
"""
import argparse
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', 'tools'))

from play_sound import Harness          # noqa: E402
from dis6502 import decode              # noqa: E402

WATCH = ('0100', '0154', '014E', '0136', '0178', '0148')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--id', default='0x07')
    ap.add_argument('--frame', type=int, default=1)
    args = ap.parse_args()
    sid = int(args.id, 16) if str(args.id).lower().startswith('0x') else int(args.id)

    h = Harness()
    h.engine_reset()
    h.request(sid)
    for f in range(args.frame):
        h.cpu.call(0x80D5)

    b1 = h.rom.bank(1)
    seq = []

    def trace(pc, op):
        seq.append(pc)

    h.bus.trace = trace
    h.cpu.call(0x80D5)
    h.bus.trace = None

    def text(pc):
        try:
            d = decode(b1, 0x8000, pc - 0x8000, 1)
            return d[0][2] if d else '?'
        except Exception:
            return '?'

    print('本帧共执行 %d 条指令' % len(seq))
    hits = [i for i, pc in enumerate(seq)
            if pc >= 0x8000 and any(w in text(pc) for w in WATCH)]
    print('命中 watch 的指令：', len(hits))
    shown = set()
    for i in hits:
        lo = max(0, i - 6)
        for j in range(lo, min(len(seq), i + 3)):
            pc = seq[j]
            if pc in shown:
                continue
            shown.add(pc)
            print('  %04X  %s%s' % (pc, text(pc), '   <<<' if j == i else ''))


if __name__ == '__main__':
    main()
