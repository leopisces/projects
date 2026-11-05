"""对比候选注释表：把 $86D4 起 128 字节按 2 字节一项展开成半音序号。"""
import sys
sys.path.insert(0, 'tools')
from sound import Rom

r = Rom(r'C:\Users\Leopisces\Desktop\魂斗罗1.nes')
print('$86D4 起 128 字节：')
for i in range(0, 128, 16):
    print('%04X: %s' % (0x86D4 + i, ' '.join('%02X' % r.p(0x86D4 + i + k) for k in range(16))))
print()
print('按 2 字节小端展开（前 40 项）：')
for i in range(40):
    v = r.word(0x86D4 + i * 2)
    print('%2d $%04X' % (i, v), end='   ')
    if i % 6 == 5:
        print()
print()
