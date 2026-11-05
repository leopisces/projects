import sys
sys.path.insert(0,'tools')
from play_sound import Harness, ADDR_TICK
for secs in (8, 20, 60):
    h = Harness(r'C:\Users\Leopisces\Desktop\魂斗罗1.nes')
    h.engine_reset(); h.request(7)
    nf = int(secs*60)
    marks = {}
    for f in range(nf):
        h.bus.frame = h.frames
        h.cpu.call(ADDR_TICK)
        h._scan_notes()
        h.frames += 1
        if f in (200, 600, 1200, 2400, 3599):
            marks[f] = len(h.note_events)
    print('%2ds -> 总事件 %5d  各帧累计 %s' % (secs, len(h.note_events), marks))
