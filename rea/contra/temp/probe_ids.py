"""临时探针：把全部 id 都跑一遍，判断哪些是音乐、哪些是音效。

判据：
  * 音符事件次数 / 帧数 → << 1 说明一个音能持续很多帧（音乐）
  * 活跃通道数、基础时值 $0154、第一个音符序列
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', 'tools'))

from play_sound import Harness   # noqa: E402

CH = ['P1', 'P2', 'TR', 'NO', 'DP', 'EX']
FRAMES = 120


def probe(sid):
    h = Harness()
    h.engine_reset()
    h.request(sid)
    ptr0 = [(h.bus.ram[0x0118 + x] << 8) | h.bus.ram[0x0112 + x] for x in range(6)]
    chans = [x for x in range(6) if h.bus.ram[0x0106 + x]]
    if not chans:
        return None
    seqs = {x: [] for x in chans}
    lasts = {x: 0 for x in chans}
    for f in range(FRAMES):
        h.bus.frame = f
        h.cpu.call(0x80D5)
        for x in chans:
            p = h.bus.ram[0x0142 + x]
            if not seqs[x] or seqs[x][-1] != p:
                seqs[x].append(p)
            else:
                lasts[x] += 1
    return {
        'id': sid,
        'ptr': ptr0[chans[0]],
        'chans': chans,
        'base': [h.bus.ram[0x0154 + x] for x in chans],
        'seq': seqs,
        'hold': {x: lasts[x] / max(1, len(seqs[x])) for x in chans},
    }


def main():
    print('id   ptr   chans        base   变化次数  每音平均帧数  前 12 个音高')
    for sid in range(0x00, 0x7F):
        try:
            r = probe(sid)
        except Exception as e:
            print('$%02X  异常 %s' % (sid, e))
            continue
        if not r:
            continue
        c0 = r['chans'][0]
        seq = r['seq'][c0]
        changes = len(seq)
        if changes < 3:
            continue
        hold = r['hold'][c0]
        print('$%02X  %04X  %-12s %-7s %6d    %6.1f      %s' % (
            sid, r['ptr'], ','.join(CH[x] for x in r['chans']),
            ','.join('%X' % b for b in r['base']), changes, hold,
            ' '.join('%X' % p for p in seq[:12])))


if __name__ == '__main__':
    main()
