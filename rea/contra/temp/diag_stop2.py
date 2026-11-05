import sys
sys.path.insert(0,'tools')
from play_sound import Harness, ADDR_TICK
h = Harness(r'C:\Users\Leopisces\Desktop\魂斗罗1.nes')
h.engine_reset(); h.request(7)
prev = 0
for f in range(640):
    h.bus.frame = h.frames
    h.cpu.call(ADDR_TICK)
    h._scan_notes()
    h.frames += 1
    new = len(h.note_events) - prev
    prev = len(h.note_events)
    if 590 <= f <= 625:
        ram = h.bus.ram
        def ptr(i): return ram[0x0112+i] | (ram[0x0118+i] << 8)
        def fl(i): return ram[0x0124+i]
        print('%3d P0=%04X/%02X P1=%04X/%02X T=%04X/%02X N=%04X/%02X +%d' % (
            f, ptr(0), fl(0), ptr(1), fl(1), ptr(2), fl(2), ptr(3), fl(3), new))
