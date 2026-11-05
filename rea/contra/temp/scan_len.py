import sys
sys.path.insert(0,'tools')
from play_sound import Harness, ADDR_TICK
from sound import Rom

rom = Rom(r'C:\Users\Leopisces\Desktop\魂斗罗1.nes')
ids = [s for s,_f,_p in rom.all_ids()]
print('id  flags  seq    事件数  最后事件帧  估计时长s')
for sid in ids:
    try:
        h = Harness(r'C:\Users\Leopisces\Desktop\魂斗罗1.nes')
        h.engine_reset(); h.request(sid)
        for f in range(1800):   # 30s
            h.bus.frame = h.frames
            h.cpu.call(ADDR_TICK)
            h._scan_notes(); h.frames += 1
        ev = h.note_events
        last = ev[-1][0] if ev else 0
        f_, seq = rom.request(sid)
        print('%3d  $%02X    $%04X  %6d  %6d      %.1f' % (sid, f_, seq, len(ev), last, last/60.0))
    except Exception as e:
        print('%3d  ERR %s' % (sid, e))
