"""验证 $86DC 音高表 + 按 $8263-$8285 / $8288-$82CD 的规则解码序列。"""
import sys
sys.path.insert(0, 'tools')
from sound import Rom

r = Rom(r'C:\Users\Leopisces\Desktop\魂斗罗1.nes')

print('=== 音高表 $86DC（27 项）===')
for i in range(27):
    v = r.word(0x86DC + i * 2)
    print('  [%2d] $%04X' % (i, v), end='\n' if i % 5 == 4 else '   ')
print('\n')

print('=== $86D4 的 4 个音符后处理函数 ===')
for i in range(4):
    print('  %d -> $%04X' % (i, r.word(0x86D4 + i * 2)))

print('\n=== $86C4 的 8 个命令函数 ===')
for i in range(8):
    print('  %d -> $%04X' % (i, r.word(0x86C4 + i * 2)))


def decode(addr, maxn=40):
    """按 $820D 主循环规则走：$F0-$FF 命令 / $D0-$EF 时长 / 其余音符。"""
    pc = addr
    out = []
    for _ in range(maxn):
        b = r.p(pc)
        if b >= 0xF0:
            lo = b & 0x0F
            if b == 0xFF:
                out.append((pc, b, 'END'))
                break
            elif b == 0xFE:
                tgt = r.word(pc + 1)
                out.append((pc, b, 'LOOP->$%04X' % tgt))
                pc += 3
                if tgt < pc:
                    out.append((pc, None, '  (loop back, stop)'))
                    break
                continue
            elif b == 0xFD:
                tgt = r.word(pc + 1)
                out.append((pc, b, 'JUMP->$%04X' % tgt))
                pc = tgt
                continue
            else:
                out.append((pc, b, 'CMD $%X' % lo))
                pc += 1
                continue
        if b >= 0xD0:
            out.append((pc, b, 'DUR/MOD $%X' % (b & 0x0F)))
            pc += 1
            continue
        # 音符
        timer = r.word(0x86DC + b * 2) if b < 27 else None
        dur = r.p(pc + 1)
        out.append((pc, b, 'NOTE idx=%d $%s dur=%d' % (b, ('%04X' % timer) if timer else '??', dur)))
        pc += 2
    return out


for start, name in ((0x9268, 'id7-P1'), (0x9256, 'id5-P1'), (0x9291, 'id7-TRI')):
    print('\n=== %s @ $%04X ===' % (name, start))
    for pc, b, desc in decode(start, 24):
        print('  $%04X  %-6s %s' % (pc, ('%02X' % b) if b is not None else '', desc))
