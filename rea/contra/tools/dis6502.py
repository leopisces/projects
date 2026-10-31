"""线性 6502 反汇编器（只做逐条解码，不做递归下降）。

操作码表沿用 `rea/battle-city/tools/d6502.py` 的权威表（同一份数据，减少抄错）。
用在 contra 上时，一个 16KB PRG bank 直接喂进来 + 起始地址就能出清单；
数据区（音序表）会解成乱码，需要靠跳转目标人工切分。
"""
import io

try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass


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

MODES = {
    'imp': 0, 'acc': 0, 'imm': 1, 'zp': 1, 'zpx': 1, 'zpy': 1, 'rel': 1,
    'abs': 2, 'absx': 2, 'absy': 2, 'ind': 2, 'indx': 1, 'indy': 1,
}


def decode(bank, base=0x8000, off=0x0000, count=None):
    """把 bank[off:] 线性反汇编，返回 [(addr, bytes, text)]。"""
    out = []
    i = off
    n = len(bank) if count is None else off + count
    while i < n:
        op = bank[i]
        if op not in T:
            out.append((base + i, '%02X' % op, '.byte $%02X' % op))
            i += 1
            continue
        mn, mode = T[op]
        ln = 1 + MODES[mode]
        args = bank[i + 1:i + ln]
        if mode == 'rel':
            tgt = base + i + 2 + (args[0] - 256 if args[0] > 127 else args[0])
            text = '%-5s $%04X' % (mn, tgt)
        elif mode in ('imp', 'acc'):
            text = mn
        elif mode == 'imm':
            text = '%-5s #$%02X' % (mn, args[0])
        elif mode == 'zp':
            text = '%-5s $%02X' % (mn, args[0])
        elif mode == 'zpx':
            text = '%-5s $%02X,X' % (mn, args[0])
        elif mode == 'zpy':
            text = '%-5s $%02X,Y' % (mn, args[0])
        elif mode == 'indx':
            text = '%-5s ($%02X,X)' % (mn, args[0])
        elif mode == 'indy':
            text = '%-5s ($%02X),Y' % (mn, args[0])
        elif mode == 'abs':
            text = '%-5s $%04X' % (mn, args[0] | args[1] << 8)
        elif mode == 'absx':
            text = '%-5s $%04X,X' % (mn, args[0] | args[1] << 8)
        elif mode == 'absy':
            text = '%-5s $%04X,Y' % (mn, args[0] | args[1] << 8)
        elif mode == 'ind':
            text = '%-5s ($%04X)' % (mn, args[0] | args[1] << 8)
        else:
            text = mn
        out.append((base + i, bank[i:i + ln].hex(' '), text))
        i += ln
    return out


def write(bank, path, base=0x8000, off=0, count=None):
    with io.open(path, 'w', encoding='utf-8') as f:
        for addr, raw, text in decode(bank, base, off, count):
            f.write('%04X: %-9s %s' % (addr, raw, text) + chr(10))
