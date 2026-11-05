import sys, numpy as np
sys.path.insert(0,'tools')
from play_sound import Harness
for sid in (94, 90, 106, 88):
    h = Harness(r'C:\Users\Leopisces\Desktop\魂斗罗1.nes')
    h.engine_reset(); h.request(sid)
    x = h.run_frames(60*60)
    # 按 1 秒切片看 RMS
    n = len(x); seg = n // 60
    rms = [float(np.sqrt(np.mean(x[i*seg:(i+1)*seg].astype(np.float64)**2))) for i in range(60)]
    print('id %3d  每秒RMS: %s' % (sid, ' '.join('%.2f'%v for v in rms)))
