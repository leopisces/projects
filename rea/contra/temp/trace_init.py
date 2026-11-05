"""临时探针：trace $87A2 请求 id 7 之后的行为，看它初始化了哪几个通道。"""
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'tools'))
import play_sound as ps

h = ps.Harness()
h.engine_reset()
trace = []
orig = h.bus.write
def w(addr, val):
    if 0x0100 <= addr <= 0x01FF or 0x0000 <= addr < 0x0100:
        trace.append(('W', addr, val))
    orig(addr, val)
h.bus.write = w
h.cpu.a = 7
h.cpu.call(ps.ADDR_REQ)
for t in trace[:60]:
    print('  RAM[$%04X] = $%02X' % (t[1], t[2]))
print('总写入 %d 条' % len(trace))
r = h.bus.ram
print('act: %s' % ' '.join('%02X' % r[0x0106+i] for i in range(6)))
print('ptr: %s' % ' '.join('%02X%02X' % (r[0x0118+i], r[0x0112+i]) for i in range(6)))
print('base: %s' % ' '.join('%02X' % r[0x0154+i] for i in range(6)))
