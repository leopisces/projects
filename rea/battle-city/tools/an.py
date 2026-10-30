import math, collections, struct
d = open('battle_city.nes','rb').read()
h = d[:16]
prg = d[16:16+16384]; chr_ = d[16+16384:16+16384+8192]
print("== iNES header ==")
print(" magic:", h[:4], " PRG banks:", h[4], "->", h[4]*16384, "B  CHR banks:", h[5], "->", h[5]*8192, "B")
f6 = h[6]
print(f" flags6=0x{f6:02X}  mapper={ (f6>>4)|(h[7]&0xF0) }  mirroring={'vertical' if f6&1 else 'horizontal'}  battery={bool(f6&2)}  trainer={bool(f6&4)}")
print(" flags7=0x%02X  vs-unisystem=%d nes2=%d" % (h[7], h[7]>>3 & 1, h[7]>>2 & 1))
print(" size check:", len(d), "==", 16+len(prg)+len(chr_))

print("\n== 6502 vectors (in PRG at $FFFA-$FFFF) ==")
vec = prg[0x3FFA:0x4000]
nmi, rst, irq = struct.unpack('<HHH', vec)
print(f" NMI=${nmi:04X}  RESET=${rst:04X}  IRQ/BRK=${irq:04X}")

def ent(b):
    c = collections.Counter(b); n=len(b)
    return -sum((v/n)*math.log2(v/n) for v in c.values())
print("\n== PRG 每 1KB 熵 (低=代码/零填充, 高=数据/图形) ==")
for i in range(0,16384,1024):
    blk = prg[i:i+1024]
    zeros = blk.count(0)
    print(f" ${0x8000+i:04X}-${0x8000+i+1023:04X}  H={ent(blk):.2f}  zeros={zeros*100//1024:>3}%")

print("\n== CHR 每 1KB 熵 ==")
for i in range(0,8192,1024):
    blk = chr_[i:i+1024]
    print(f" tile {i//16:>4}-{(i+1023)//16:<4}  H={ent(blk):.2f}  zeros={blk.count(0)*100//1024:>3}%")

print("\n== PRG 里的 ASCII 字符串 (>=4) ==")
cur=[]; start=0; outs=[]
for i,b in enumerate(prg):
    if 32 <= b < 127: 
        if not cur: start=i
        cur.append(chr(b))
    else:
        if len(cur)>=4: outs.append((0x8000+start, ''.join(cur)))
        cur=[]
if len(cur)>=4: outs.append((0x8000+start,''.join(cur)))
for a,s in outs[:40]: print(f" ${a:04X}  {s!r}")
print(" 合计", len(outs), "条")
