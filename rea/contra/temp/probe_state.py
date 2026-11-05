"""临时探针：逐帧打印声音引擎的通道状态，看序列指针/时值是否正常推进。

用法：python temp/probe_state.py --id 0x07 --frames 24
"""
import argparse
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', 'tools'))

from play_sound import Harness   # noqa: E402

CH = ['P1', 'P2', 'TR', 'NO', 'DP', 'EX']


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--id', default='0x07')
    ap.add_argument('--frames', type=int, default=24)
    ap.add_argument('--channels', type=int, default=4)
    args = ap.parse_args()
    sid = int(args.id, 16) if str(args.id).lower().startswith('0x') else int(args.id)

    h = Harness()
    h.engine_reset()
    print('--- 复位后 ---')
    for x in range(args.channels):
        print(' %s id=%02X ptr=%04X timer=%02X flags=%02X pitch=%02X' % (
            CH[x], h.bus.ram[0x0106 + x], h.bus.ram[0x0118 + x] << 8 | h.bus.ram[0x0112 + x],
            h.bus.ram[0x0100 + x], h.bus.ram[0x0124 + x], h.bus.ram[0x0142 + x]))
    h.request(sid)
    print('--- 请求 $%02X 之后 ---' % sid)
    for x in range(args.channels):
        ptr = h.bus.ram[0x0118 + x] << 8 | h.bus.ram[0x0112 + x]
        print(' %s id=%02X ptr=%04X byte=%02X timer=%02X flags=%02X vol=%02X env=%02X' % (
            CH[x], h.bus.ram[0x0106 + x], ptr, h.bus.peek(ptr),
            h.bus.ram[0x0100 + x], h.bus.ram[0x0124 + x],
            h.bus.ram[0x014E + x], h.bus.ram[0x0136 + x]))

    print('\n%-4s %-3s %-8s %-4s %-4s %-4s %-4s %-4s %-4s' % (
        'frm', 'ch', 'ptr', 'byte', 'tmr', 'flg', 'pitch', 'note', 'hi'))
    for f in range(args.frames):
        h.bus.frame = f
        steps = h.cpu.call(0x80D5)
        for x in range(args.channels):
            ptr = h.bus.ram[0x0118 + x] << 8 | h.bus.ram[0x0112 + x]
            print('%-4d %-3s %04X %02X %02X %02X %02X %02X %02X  (%d 步)' % (
                f, CH[x], ptr, h.bus.peek(ptr), h.bus.ram[0x0100 + x],
                h.bus.ram[0x0124 + x], h.bus.ram[0x0142 + x],
                h.bus.ram[0x010C + x], h.bus.ram[0x0172 + x],
                steps if x == 0 else 0))


if __name__ == '__main__':
    main()
