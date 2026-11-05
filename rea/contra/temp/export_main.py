import os, sys, wave
import numpy as np
sys.path.insert(0, 'tools')
from play_sound import Harness
from sound import Rom

ROM = r'C:\Users\Leopisces\Desktop\魂斗罗1.nes'
OUT = 'sound'
os.makedirs(OUT, exist_ok=True)
SECS = 30.0

rom = Rom(ROM)
rows = []
for sid in (94, 90, 88, 106, 95, 96, 7, 12, 5):
    try:
        h = Harness(ROM)
        h.engine_reset(); h.request(sid)
        x = h.run_frames(int(SECS * 60))
        if len(x) == 0:
            print('id %3d EMPTY' % sid); continue
        rms = float(np.sqrt(np.mean(x.astype(np.float64) ** 2)))
        peak = float(np.max(np.abs(x)))
        silent = float(np.mean(np.abs(x) < 1e-4))
        path = os.path.join(OUT, 'id_%03d.wav' % sid)
        d = np.clip(x, -1, 1)
        pcm = (d * 32767).astype(np.int16)
        with wave.open(path, 'wb') as w:
            w.setnchannels(1); w.setsampwidth(2); w.setframerate(44100)
            w.writeframes(pcm.tobytes())
        dur = len(x) / 44100.0
        print('id %3d  %5.1fs  rms=%.3f  peak=%.3f  silent=%4.1f%%  ev=%4d  -> %s' % (
            sid, dur, rms, peak, silent*100, len(h.note_events), os.path.basename(path)))
        rows.append((sid, rms, peak, silent, len(h.note_events), dur))
    except Exception as e:
        print('id %3d ERR %r' % (sid, e))
