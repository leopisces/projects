# -*- coding: utf-8 -*-
"""导出魂斗罗全部 127 个声音请求。"""
import os, sys, wave
import numpy as np
sys.path.insert(0, 'tools')
from play_sound import Harness
from sound import Rom

ROM = r'C:\Users\Leopisces\Desktop\魂斗罗1.nes'
OUT = 'sound'
os.makedirs(OUT, exist_ok=True)

rom = Rom(ROM)
ids = [sid for sid, _, _ in rom.all_ids()]
print('共 %d 个 id' % len(ids))

def stats(x):
    if len(x) == 0:
        return 0.0, 0.0, 1.0
    rms = float(np.sqrt(np.mean(x.astype(np.float64) ** 2)))
    peak = float(np.max(np.abs(x)))
    # 100ms 分段峰值，判断“有没有声”
    step = 4410
    nseg = len(x) // step
    if nseg == 0:
        return rms, peak, 0.0
    segmax = np.abs(x[:nseg*step]).reshape(nseg, step).max(axis=1)
    return rms, peak, float(np.mean(segmax < 0.01))

rows = []
for k, sid in enumerate(ids):
    try:
        h = Harness(ROM)
        h.engine_reset()
        h.request(sid)
        # 先跑 60 秒探查，之后按实际发声长度裁剪
        x = h.run_frames(int(60 * 60))
        rms, peak, gap = stats(x)
        # 裁剪尾部静音
        step = 4410
        xa = np.abs(x)
        nseg = len(xa) // step
        last = 0
        if nseg:
            segmax = xa[:nseg*step].reshape(nseg, step).max(axis=1)
            nz = np.nonzero(segmax >= 0.01)[0]
            if len(nz):
                last = min(len(x), (nz[-1] + 2) * step)
        x = x[:last] if last else x
        if len(x) == 0:
            continue
        path = os.path.join(OUT, 'id_%03d.wav' % sid)
        d = np.clip(x, -1, 1)
        pcm = (d * 32767).astype(np.int16)
        with wave.open(path, 'wb') as w:
            w.setnchannels(1); w.setsampwidth(2); w.setframerate(44100)
            w.writeframes(pcm.tobytes())
        dur = len(x) / 44100.0
        rows.append((sid, dur, rms, peak))
        print('[%3d/%3d] id %3d  %5.2fs rms=%.3f peak=%.3f' % (k+1, len(ids), sid, dur, rms, peak))
    except Exception as e:
        print('[%3d/%3d] id %3d  ERR %r' % (k+1, len(ids), sid, e))

with open(os.path.join(OUT, 'index.txt'), 'w', encoding='utf-8') as f:
    f.write('id    时长     RMS     峰值\n')
    f.write('-'*40 + '\n')
    for sid, dur, rms, peak in rows:
        f.write('%3d  %6.2fs  %.3f  %.3f\n' % (sid, dur, rms, peak))

print('\n完成 %d 个文件 -> %s' % (len(rows), OUT))
