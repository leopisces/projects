"""`$82CD` 命令表的跳转目标反汇编（在 $82D5/$8395/$85B7 段内找函数头）。"""
import re
import sys

lines = open('temp/bank1.asm', encoding='utf-8', errors='replace').read().splitlines()

# 收集地址 -> 反汇编行
by_addr = {}
for ln in lines:
    mm = re.match(r'^([0-9A-F]{4}): ', ln)
    if mm:
        by_addr[int(mm.group(1), 16)] = ln

print('=== $82CD 表（10 项）===')
import sys as _s
_s.path.insert(0, 'tools')
from sound import Rom
r = Rom(r'C:\Users\Leopisces\Desktop\魂斗罗1.nes')
targets = []
for i in range(10):
    lo = r.p(0x82CD + i * 2)
    hi = r.p(0x82CE + i * 2)
    targets.append(lo | (hi << 8))
    print('  [%d] -> $%04X' % (i, lo | (hi << 8)))

print()
for t in targets:
    print('--- $%04X ---' % t)
    a = t
    for k in range(10):
        if a in by_addr:
            print('   ' + by_addr[a])
            m = re.search(r'\$([0-9A-F]{4})$', by_addr[a])
            raw = by_addr[a]
            # 估算下一条地址
            parts = raw.split()
            nbytes = 0
            for p in parts[1:]:
                if re.match(r'^[0-9a-f]{2}$', p):
                    nbytes += 1
                else:
                    break
            a += max(1, nbytes)
        else:
            print('   %04X: <数据>' % a)
            a += 1
            if k > 3:
                break
    print()
