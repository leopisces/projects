import os, sys, wave
import numpy as np
sys.path.insert(0, 'tools')
from play_sound import Harness
from sound import Rom

ROM = r'C:\Users\Leopisces\Desktop\魂斗罗1.nes'
OUT = 'sound'
SECS = 60.0

# 清掉旧文件，只重建验证过的
for f in os.listdir(OUT):
    if f.endswith('.wav'):
        os.remove(os.path.join(OUT, f))

TARGETS = [94, 106, 90, 88, 95, 7, 96, 12, 5, 14, 20, 22, 30, 36, 42, 48]
rows = []
for sid in TARGETS:
    try:
        h = Harness(ROM)
        h.engine_reset(); h.request(sid)
        x = h.run_frames(int(SECS * 60))
        if len(x) == 0:
            continue
        rms = float(np.sqrt(np.mean(x.astype(np.float64) ** 2)))
        peak = float(np.max(np.abs(x)))
        silent = float(np.mean(np.abs(x) < 1e-4))
        path = os.path.join(OUT, 'id_%03d.wav' % sid)
        d = np.clip(x, -1, 1)
        pcm = (d * 32767).astype(np.int16)
        with wave.open(path, 'wb') as w:
            w.setnchannels(1); w.setsampwidth(2); w.setframerate(44100)
            w.writeframes(pcm.tobytes())
        rows.append((sid, rms, peak, silent, len(h.note_events)))
        print('id %3d  rms=%.3f peak=%.3f silent=%5.1f%% ev=%4d' % (sid, rms, peak, silent*100, len(h.note_events)))
    except Exception as e:
        print('id %3d ERR %r' % (sid, e))

print('\n=== 汇总 ===')
good = [r for r in rows if r[1] > 0.15 and r[3] < 0.05]
print('完整可听: %s' % ', '.join('id_%03d' % r[0] for r in good))
