"""诊断：逐帧打印 6 个通道的指针/标志，找出引擎停摆的那一帧。"""
import sys
sys.path.insert(0, 'tools')
from play_sound import Harness, ADDR_TICK

h = Harness(r'C:\Users\Leopisces\Desktop\魂斗罗1.nes')
h.engine_reset()
h.request(7)

print('帧  CH0ptr CH0fl CH1ptr CH1fl CH2ptr CH2fl CH3ptr CH3fl  新增事件')
prev = 0
for f in range(140):
    h.bus.frame = h.frames
    h.cpu.call(ADDR_TICK)
    h._scan_notes()
    h.frames += 1
    ram = h.bus.ram
    def ptr(i):
        return ram[0x0112 + i] | (ram[0x0118 + i] << 8)
    def fl(i):
        return ram[0x0124 + i]
    new = len(h.note_events) - prev
    prev = len(h.note_events)
    if f < 12 or new or f % 10 == 0:
        print('%3d  %04X %02X   %04X %02X   %04X %02X   %04X %02X   +%d' % (
            f, ptr(0), fl(0), ptr(1), fl(1), ptr(2), fl(2), ptr(3), fl(3), new))
print('\n总事件 %d' % len(h.note_events))
print('最后 5 个:', h.note_events[-5:])
