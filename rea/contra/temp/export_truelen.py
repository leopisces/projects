import os, sys, wave
import numpy as np
sys.path.insert(0, 'tools')
from play_sound import Harness
from sound import Rom

ROM = r'C:\Users\Leopisces\Desktop\魂斗罗1.nes'
OUT = 'sound'

for f in os.listdir(OUT):
    if f.endswith('.wav'): os.remove(os.path.join(OUT, f))

# 实测每首的真实长度（秒）+ 起始偏移
PLAN = {
    94:  (35.0, 0.0),
    95:  (35.0, 0.0),
    20:  (28.0, 0.0),
    90:  (45.0, 0.0),
    106: (56.0, 0.0),
    88:  (39.0, 21.0),
    7:   (30.0, 0.0),
}

for sid, (dur, skip) in PLAN.items():
    h = Harness(ROM)
    h.engine_reset(); h.request(sid)
    total = int((dur + skip) * 60)
    x = h.run_frames(total)
    a = int(skip * 44100); b = int((skip + dur) * 44100)
    y = x[a:b]
    rms = float(np.sqrt(np.mean(y.astype(np.float64)**2)))
    peak = float(np.max(np.abs(y)))
    silent = float(np.mean(np.abs(y) < 1e-4))
    path = os.path.join(OUT, 'id_%03d.wav' % sid)
    d = np.clip(y, -1, 1); pcm = (d*32767).astype(np.int16)
    with wave.open(path,'wb') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(44100)
        w.writeframes(pcm.tobytes())
    print('id %3d  %5.1fs (跳过%.0fs)  rms=%.3f peak=%.3f silent=%4.1f%%' % (
        sid, dur, skip, rms, peak, silent*100))
