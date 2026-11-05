import sys
sys.path.insert(0,'tools')
from play_sound import Harness, ADDR_TICK
h = Harness(r'C:\Users\Leopisces\Desktop\魂斗罗1.nes')
h.engine_reset(); h.request(7)
prev=0
for f in range(600):
    h.bus.frame = h.frames
    h.cpu.call(ADDR_TICK)
    h._scan_notes(); h.frames += 1
    new = len(h.note_events)-prev; prev=len(h.note_events)
    if 520 <= f <= 545:
        ram=h.bus.ram
        def ptr(i): return ram[0x0112+i] | (ram[0x0118+i]<<8)
        print('%3d P0=%04X P1=%04X T=%04X +%d | cnt0=%d cnt1=%d cnt2=%d | E0=%02X' % (
            f, ptr(0), ptr(1), ptr(2), new,
            ram[0x0148], ram[0x0149], ram[0x014A], ram[0x00E0]))
