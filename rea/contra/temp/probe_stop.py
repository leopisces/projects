"""临时探针：跟踪 id 7 在 8~11 秒之间 $25/$2F 与 6 个通道的状态变化，找“为什么停”。

用法：python temp/probe_stop.py --id 7 --from 400 --to 700
"""
import argparse
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', 'tools'))

import play_sound as ps   # noqa: E402

CH = ['P1', 'P2', 'TR', 'NO', 'DP', 'EX']


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--id', type=int, default=7)
    ap.add_argument('--from', dest='f0', type=int, default=400)
    ap.add_argument('--to', dest='f1', type=int, default=700)
    args = ap.parse_args()

    h = ps.Harness()
    h.engine_reset()
    h.request(args.id)

    prev = None
    for f in range(args.f1):
        h.bus.frame = f
        h.cpu.call(ps.ADDR_TICK)
        if f < args.f0:
            continue
        r = h.bus.ram
        snap = (r[0x0025], r[0x002F],
                tuple(r[0x0106 + x] for x in range(6)),
                tuple(r[0x010C + x] for x in range(6)))
        if snap != prev:
            prev = snap
            print('f%-4d $25=%02X $2F=%02X | act=%s | st=%s' % (
                f, snap[0], snap[1],
                ' '.join('%s:%d' % (CH[i], snap[2][i]) for i in range(6)),
                ' '.join('%d' % snap[3][i] for i in range(6))))


if __name__ == '__main__':
    main()
