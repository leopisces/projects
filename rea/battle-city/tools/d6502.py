"""Recursive-descent 6502 disassembler with jump-table following (Battle City, NROM-128)."""
import struct
import collections

T = {}
def add(mn, mode, *ops):
    for o in ops:
        T[o] = (mn, mode)

add('ADC','imm',0x69); add('ADC','zp',0x65); add('ADC','zpx',0x75); add('ADC','abs',0x6D)
add('ADC','absx',0x7D); add('ADC','absy',0x79); add('ADC','indx',0x61); add('ADC','indy',0x71)
add('AND','imm',0x29); add('AND','zp',0x25); add('AND','zpx',0x35); add('AND','abs',0x2D)
add('AND','absx',0x3D); add('AND','absy',0x39); add('AND','indx',0x21); add('AND','indy',0x31)
add('ASL','acc',0x0A); add('ASL','zp',0x06); add('ASL','zpx',0x16); add('ASL','abs',0x0E); add('ASL','absx',0x1E)
for mn, o in [('BCC',0x90),('BCS',0xB0),('BEQ',0xF0),('BMI',0x30),('BNE',0xD0),('BPL',0x10),('BVC',0x50),('BVS',0x70)]:
    add(mn,'rel',o)
add('BIT','zp',0x24); add('BIT','abs',0x2C)
add('BRK','imp',0x00)
for mn, o in [('CLC',0x18),('CLD',0xD8),('CLI',0x58),('CLV',0xB8)]:
    add(mn,'imp',o)
add('CMP','imm',0xC9); add('CMP','zp',0xC5); add('CMP','zpx',0xD5); add('CMP','abs',0xCD)
add('CMP','absx',0xDD); add('CMP','absy',0xD9); add('CMP','indx',0xC1); add('CMP','indy',0xD1)
add('CPX','imm',0xE0); add('CPX','zp',0xE4); add('CPX','abs',0xEC)
add('CPY','imm',0xC0); add('CPY','zp',0xC4); add('CPY','abs',0xCC)
add('DEC','zp',0xC6); add('DEC','zpx',0xD6); add('DEC','abs',0xCE); add('DEC','absx',0xDE)
add('DEX','imp',0xCA); add('DEY','imp',0x88)
add('EOR','imm',0x49); add('EOR','zp',0x45); add('EOR','zpx',0x55); add('EOR','abs',0x4D)
add('EOR','absx',0x5D); add('EOR','absy',0x59); add('EOR','indx',0x41); add('EOR','indy',0x51)
add('INC','zp',0xE6); add('INC','zpx',0xF6); add('INC','abs',0xEE); add('INC','absx',0xFE)
add('INX','imp',0xE8); add('INY','imp',0xC8)
add('JMP','abs',0x4C); add('JMP','ind',0x6C); add('JSR','abs',0x20)
add('LDA','imm',0xA9); add('LDA','zp',0xA5); add('LDA','zpx',0xB5); add('LDA','abs',0xAD)
add('LDA','absx',0xBD); add('LDA','absy',0xB9); add('LDA','indx',0xA1); add('LDA','indy',0xB1)
add('LDX','imm',0xA2); add('LDX','zp',0xA6); add('LDX','zpy',0xB6); add('LDX','abs',0xAE); add('LDX','absy',0xBE)
add('LDY','imm',0xA0); add('LDY','zp',0xA4); add('LDY','zpx',0xB4); add('LDY','abs',0xAC); add('LDY','absx',0xBC)
add('LSR','acc',0x4A); add('LSR','zp',0x46); add('LSR','zpx',0x56); add('LSR','abs',0x4E); add('LSR','absx',0x5E)
add('NOP','imp',0xEA)
add('ORA','imm',0x09); add('ORA','zp',0x05); add('ORA','zpx',0x15); add('ORA','abs',0x0D)
add('ORA','absx',0x1D); add('ORA','absy',0x19); add('ORA','indx',0x01); add('ORA','indy',0x11)
for mn, o in [('PHA',0x48),('PHP',0x08),('PLA',0x68),('PLP',0x28)]:
    add(mn,'imp',o)
add('ROL','acc',0x2A); add('ROL','zp',0x26); add('ROL','zpx',0x36); add('ROL','abs',0x2E); add('ROL','absx',0x3E)
add('ROR','acc',0x6A); add('ROR','zp',0x66); add('ROR','zpx',0x76); add('ROR','abs',0x6E); add('ROR','absx',0x7E)
add('RTI','imp',0x40); add('RTS','imp',0x60)
add('SBC','imm',0xE9); add('SBC','zp',0xE5); add('SBC','zpx',0xF5); add('SBC','abs',0xED)
add('SBC','absx',0xFD); add('SBC','absy',0xF9); add('SBC','indx',0xE1); add('SBC','indy',0xF1)
for mn, o in [('SEC',0x38),('SED',0xF8),('SEI',0x78)]:
    add(mn,'imp',o)
add('STA','zp',0x85); add('STA','zpx',0x95); add('STA','abs',0x8D)
add('STA','absx',0x9D); add('STA','absy',0x99); add('STA','indx',0x81); add('STA','indy',0x91)
add('STX','zp',0x86); add('STX','zpy',0x96); add('STX','abs',0x8E)
add('STY','zp',0x84); add('STY','zpx',0x94); add('STY','abs',0x8C)
for mn, o in [('TAX',0xAA),('TAY',0xA8),('TSX',0xBA),('TXA',0x8A),('TXS',0x9A),('TYA',0x98)]:
    add(mn,'imp',o)
for o in [0x1A,0x3A,0x5A,0x7A,0xDA,0xFA]:
    add('NOP','imp',o)
for o in [0x80,0x04,0x44,0x64,0x14,0x34,0x54,0x74,0xD4,0xF4]:
    add('NOP','zp',o)
for o in [0x0C,0x1C,0x3C,0x5C,0x7C,0xDC,0xFC]:
    add('NOP','abs',o)

LEN = {'imp':1,'acc':1,'imm':2,'zp':2,'zpx':2,'zpy':2,'abs':3,'absx':3,'absy':3,
       'ind':3,'indx':2,'indy':2,'rel':2}

d = open('battle_city.nes','rb').read()
BASE = 0xC000
PRG = d[16:16+16384]

def rb(a):
    return PRG[a - BASE]
def rw(a):
    return PRG[a - BASE] | (PRG[a - BASE + 1] << 8)

nmi, rst, irq = struct.unpack('<HHH', PRG[0x3FFA:0x4000])

code = {}
visited = set()

def decode(work):
    while work:
        a = work.pop()
        while True:
            if a in visited or not (BASE <= a < BASE + 16384):
                break
            op = rb(a)
            if op not in T:
                break
            mn, mode = T[op]
            n = LEN[mode]
            if a + n > BASE + 16384:
                break
            arg = None
            if mode in ('imm','zp','zpx','zpy','indx','indy'):
                arg = rb(a + 1)
            elif mode in ('abs','absx','absy','ind'):
                arg = rw(a + 1)
            elif mode == 'rel':
                d8 = rb(a + 1)
                if d8 >= 0x80:
                    d8 -= 256
                arg = (a + 2 + d8) & 0xFFFF
            code[a] = (mn, mode, arg, n, PRG[a - BASE:a - BASE + n])
            visited.add(a)
            nxt = a + n
            if mn == 'JMP':
                work.append(arg)
                break
            if mn == 'JSR':
                work.append(arg)
            if mn in ('RTS','RTI','BRK'):
                break
            if mode == 'rel':
                work.append(arg)
            a = nxt

# ---- pass 1 ----
decode([rst, nmi, irq])

# ---- pass 2+: 跟进 JMP ($0011) 跳转表 ----

# 已验证的内联表分发器: JSR $ECD0 后面紧跟 [2字节头部][N x 2字节地址]
# 注意: $ECD0 的栈序是小端，但 ROM 里 $EBE6 起的表实测是小端表从 $EBE8 开始
#       (见 REPORT.md 第 7.1 节“字节序矛盾”)。17 项全部落在合法代码上。
INLINE_DISPATCH = {
    0xECD0: {'table': 0xEBE8, 'end': 0xEC0A, 'resume': 0xEC0A},
}

inline_targets = []
for a in list(code):
    mn, mode, arg, n, b = code[a]
    if mn == 'JSR' and arg in INLINE_DISPATCH:
        spec = INLINE_DISPATCH[arg]
        t = spec['table']
        ents = []
        for i in range(0, spec['end'] - t, 2):
            w = rw(t + i)
            if BASE <= w < BASE + 16384:
                ents.append(w)
        inline_targets.extend(ents)
        print(f"内联表 ${t:04X}({len(ents)} 项, 由 ${a:04X} 的 JSR 使用) -> " +
              ", ".join(f"${x:04X}" for x in ents))
def find_table(jmp_addr):
    """回溯找 LDA tbl,Y / LDA tbl+1,Y 的基址"""
    insns = [a for a in sorted(code) if a < jmp_addr][-12:]
    tbl = None
    for a in insns:
        mn, mode, arg, n, b = code[a]
        if mn == 'LDA' and mode in ('absy','absx'):
            if tbl is None or arg == tbl + 1:
                if tbl is None:
                    tbl = arg
    return tbl

tables = {}
for rounds in range(6):
    new = []
    for a in list(code):
        mn, mode, arg, n, b = code[a]
        if mn == 'JMP' and mode == 'ind' and arg in (0x0011, 0x00FD):
            t = find_table(a)
            if t is None:
                continue
            if t in tables:
                continue
            entries = []
            for i in range(0, 128, 2):
                w = rw(t + i)
                if w == 0 or not (BASE <= w < BASE + 16384):
                    break
                entries.append(w)
            tables[t] = entries
            new.extend(entries)
    if not new:
        break
    decode(new)

if inline_targets:
    decode(list(inline_targets))

codebytes = sum(v[3] for v in code.values())
print(f"RESET=${rst:04X}  NMI=${nmi:04X}  IRQ=${irq:04X}")
print(f"指令 {len(code)} 条 / 代码 {codebytes} 字节 = PRG 的 {codebytes*100/16384:.1f}%")
print(f"恢复跳转表 {len(tables)} 个: " + ", ".join(f"${k:04X}({len(v)})" for k, v in sorted(tables.items())))

labels = {}
for a in sorted(code):
    mn, mode, arg, n, b = code[a]
    if mn in ('JSR','JMP') and mode == 'abs':
        labels.setdefault(arg, f"sub_{arg:04X}")
    if mode == 'rel':
        labels.setdefault(arg, f"loc_{arg:04X}")
labels[rst] = "reset"
labels[nmi] = "nmi"
labels[irq] = "irq"

HW = {0x2000:'PPUCTRL',0x2001:'PPUMASK',0x2002:'PPUSTATUS',0x2003:'OAMADDR',
      0x2004:'OAMDATA',0x2005:'PPUSCROLL',0x2006:'PPUADDR',0x2007:'PPUDATA',
      0x4014:'OAMDMA',0x4015:'APUSTATUS',0x4016:'JOY1',0x4017:'JOY2'}

def fmt(a):
    mn, mode, arg, n, bs = code[a]
    lbl = labels.get(a)
    s = f"{a:04X}  {bs.hex(' '):<9}  " + (lbl + ":" if lbl else "")
    pad = s.ljust(30)
    if mode == 'imp':
        op = mn
    elif mode == 'acc':
        op = mn + ' A'
    elif mode == 'imm':
        op = f"{mn} #${arg:02X}"
    elif mode == 'zp':
        op = f"{mn} ${arg:02X}" + (f"  ; {HW[arg]}" if arg in HW else "")
    elif mode == 'zpx':
        op = f"{mn} ${arg:02X},X"
    elif mode == 'zpy':
        op = f"{mn} ${arg:02X},Y"
    elif mode == 'abs':
        tgt = labels.get(arg, f"${arg:04X}" + (f"  ; {HW[arg]}" if arg in HW else ""))
        op = f"{mn} {tgt}"
    elif mode == 'absx':
        op = f"{mn} ${arg:04X},X"
    elif mode == 'absy':
        op = f"{mn} ${arg:04X},Y"
    elif mode == 'ind':
        op = f"{mn} (${arg:04X})"
    elif mode == 'indx':
        op = f"{mn} (${arg:02X},X)"
    elif mode == 'indy':
        op = f"{mn} (${arg:02X}),Y"
    elif mode == 'rel':
        op = f"{mn} {labels.get(arg, f'${arg:04X}')}"
    else:
        op = mn
    return pad + op

with open('battle_city_dis.asm', 'w', encoding='utf-8') as f:
    f.write("; Battle City (Namco 1985) — NROM-128 (mapper 0), PRG $C000-$FFFF, CHR 8KB\n")
    f.write("; md5 cd4fe2e78df0696dbe652f02c19541a1\n")
    f.write(f"; RESET=${rst:04X}  NMI=${nmi:04X}  IRQ=${irq:04X}\n")
    f.write(f"; {len(code)} instructions, {codebytes} bytes code\n\n")
    f.write("vectors:\n.word nmi, reset, irq\n")
    for t, e in sorted(tables.items()):
        f.write(f"\n; jump table ${t:04X} ({len(e)} entries)\n.word " + ", ".join(f"sub_{x:04X}" for x in e) + "\n")
    f.write("\n")
    prev = None
    for a in sorted(code):
        if prev is not None and a != prev:
            f.write(f"\n; ---- ${prev:04X}..${a-1:04X} ({(a-prev)} bytes: data) ----\n")
        elif prev is None and a != BASE:
            f.write(f"; ---- ${BASE:04X}..${a-1:04X} : data ----\n")
        f.write(fmt(a) + "\n")
        prev = a + code[a][3]
print("listing -> battle_city_dis.asm")

# ---- 数据区扫描: 找 16 关的关卡表 ----
print("\n== 数据空洞排行 (最可能藏关卡/表格) ==")
gaps = []
prev = BASE
for a in sorted(code):
    if a > prev:
        gaps.append((prev, a - prev))
    prev = a + code[a][3]
if prev < BASE + 16384:
    gaps.append((prev, BASE + 16384 - prev))
gaps.sort(key=lambda x: -x[1])
for g, n in gaps[:10]:
    print(f"  ${g:04X}  {n:>5} 字节")

# ---- 13x13 关卡表探测: 每关 169 字节 ----
print("\n== 169 字节块 (13x13 关卡) 探测 ==")
for start in range(0, 16384 - 169*4, 1):
    ok = True
    for s in range(4):
        blk = PRG[start + s*169: start + s*169 + 169]
        if len(blk) < 169 or blk.count(0) * 100 // 169 < 20 or max(blk) > 0x40:
            ok = False
            break
    if ok:
        print(f"  候选表起始 ${BASE+start:04X} (连续 4 关 x 169B)")
        break
