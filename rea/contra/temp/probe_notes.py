"""临时探针：打印某个 id 的逐通道音符事件（序列指针前进的那一刻）。

用法：python temp/probe_notes.py --id 0x5A --frames 300
"""
import argparse
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', 'tools'))

from play_sound import Harness   # noqa: E402

CH = ['P1', 'P2', 'TR', 'NO', 'DP', 'EX']
NOTE_NAME = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--id', default='0x5A')
    ap.add_argument('--frames', type=int, default=300)
    args = ap.parse_args()
    sid = int(args.id, 16) if str(args.id).lower().startswith('0x') else int(args.id)

    h = Harness()
    h.engine_reset()
    h.request(sid)
    chans = [x for x in range(6) if h.bus.ram[0x0106 + x]]
    print('id $%02X 通道 %s' % (sid, ','.join(CH[x] for x in chans)))
    for x in chans:
        print('  %s ptr=%04X base=$%02X flags=$%02X' % (
            CH[x], h.bus.ram[0x0118 + x] << 8 | h.bus.ram[0x0112 + x],
            h.bus.ram[0x0154 + x], h.bus.ram[0x0124 + x]))

    h.events = {}
    prev = {x: (h.bus.ram[0x0118 + x] << 8) | h.bus.ram[0x0112 + x] for x in chans}
    cur = dict(prev)
    for f in range(args.frames):
        h.bus.frame = f
        h.cpu.call(0x80D5)
        for x in chans:
            p = (h.bus.ram[0x0118 + x] << 8) | h.bus.ram[0x0112 + x]
            if p != cur[x]:
                byte = h.bus.peek(p)
                cur[x] = p
                if len(h.events.get(x, [])) < 40:
                    h.events.setdefault(x, []).append((f, byte, p))
    for x in chans:
        ev = h.events.get(x, [])
        print('\n%s：%d 个事件（前 40）' % (CH[x], len(ev)))
        line = []
        for f, byte, p in ev:
            cmd = ''
            if byte >= 0xF0:
                cmd = 'cmd F%X' % (byte & 0x0F)
            elif byte >= 0xE0:
                cmd = 'cmd E%X' % (byte & 0x0F)
            elif byte >= 0xD0:
                cmd = 'cmd D%X' % (byte & 0x0F)
            elif byte >= 0xC0:
                cmd = 'vol C%X' % (byte & 0x0F)
            else:
                n = (byte >> 4) & 0x0F
                cmd = '%s%d(%d)' % (NOTE_NAME[n % 12], n // 12, byte & 0x0F)
            line.append('@%d:%02X=%s' % (f, byte, cmd))
        print('  ' + '  '.join(line))


if __name__ == '__main__':
    main()
