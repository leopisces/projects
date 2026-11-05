import sys, numpy as np
sys.path.insert(0,'tools')
from play_sound import Harness

for sid in (94, 90, 106, 88, 95, 7, 20):
    h = Harness(r'C:\Users\Leopisces\Desktop\魂斗罗1.nes')
    h.engine_reset(); h.request(sid)
    x = h.run_frames(60*120)   # 120s
    n=len(x); seg=n//120
    rms=[float(np.sqrt(np.mean(x[i*seg:(i+1)*seg].astype(np.float64)**2))) for i in range(120)]
    first_sound = next((i for i,v in enumerate(rms) if v>0.01), None)
    # 检测是否循环：比较后半段与前半段
    print('id %3d 首音=%ss  0-30s均值=%.3f  30-60s=%.3f  60-90s=%.3f  90-120s=%.3f' % (
        sid, first_sound,
        np.mean(rms[0:30]), np.mean(rms[30:60]), np.mean(rms[60:90]), np.mean(rms[90:120])))
    # 找真正的循环周期：自相关
    a=np.array(rms)
    best=None
    for lag in range(5,60):
        c=float(np.corrcoef(a[:120-lag], a[lag:])[0,1])
        if best is None or c>best[1]: best=(lag,c)
    print('      最佳循环周期 ~%ds (r=%.3f)' % best)
