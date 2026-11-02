"""用 6502 模拟器跑 ROM 的关卡加载例程，截获实际写入 VRAM 的数据。

这是拿到 ground truth 的方法：不猜格式，直接观察硬件行为。

思路：
  1. 加载 ROM，初始化 RAM
  2. 挂 JSR $F989（bank 切换）钩子记录 bank
  3. 挂 STA $2006/$2007 钩子记录 VRAM 写入
  4. 从 $C93A 开始跑，截获完整地图

MMC3 的 bank 切换需要配合，这里实现简化的 mapper。
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, '..', 'python'))

try:
    sys.stdout.reconfigure(encoding='utf-8')
except Exception:
    pass

from contra_rom import Rom


def find_rom():
    import glob
    for p in glob.glob(os.path.join(os.path.expanduser('~'), 'Desktop', '*.nes')):
        if os.path.getsize(p) == 393232:
            return p
    raise FileNotFoundError


class MMC3:
    """精简 MMC3：只实现 PRG bank 切换 + CHR bank。"""

    def __init__(self, rom):
        self.rom = rom
        self.bank_select = 0
        self.r = [0] * 8
        self.prg_mode = 0
        self.chr_mode = 0

    def prg_read(self, addr):
        if addr >= 0xE000:
            return self.rom.prg[len(self.rom.prg) - 8192 + (addr - 0xE000)]
        if addr >= 0xC000:
            o = len(self.rom.prg) - 16384 + (addr - 0xC000)
            return self.rom.prg[o]
        if addr >= 0xA000:
            page = (self.r[7] & 0x3F) if self.prg_mode == 0 else (len(self.rom.prg) // 8192 - 2)
            return self.rom.prg[page * 8192 + (addr - 0xA000)]
        page = (len(self.rom.prg) // 8192 - 2) if self.prg_mode == 0 else (self.r[6] & 0x3F)
        return self.rom.prg[page * 8192 + (addr - 0x8000)]

    def write(self, addr, v):
        if addr < 0xA000:
            if addr % 2 == 0:
                self.bank_select = v & 7
            else:
                self.r[self.bank_select] = v
                if self.bank_select == 6:
                    self.prg_mode = (v >> 6) & 1
                if self.bank_select == 0:
                    self.chr_mode = (v >> 7) & 1


class VRAMSpy:
    """记录 $2006/$2007 交互，还原成 VRAM 内容。"""

    def __init__(self):
        self.addr = 0
        self.hi = None
        self.vram = {}
        self.writes = []            # (addr, value) 序列

    def write_2006(self, v):
        if self.hi is None:
            self.hi = v
        else:
            self.addr = ((self.hi << 8) | v) & 0x3FFF
            self.hi = None

    def write_2007(self, v):
        self.vram[self.addr] = v
        self.writes.append((self.addr, v))
        self.addr = (self.addr + 1) & 0x3FFF


def main():
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument('--rom', default=None)
    ap.add_argument('--addr', default='C93A', help='入口地址（hex）')
    ap.add_argument('--max-steps', type=int, default=500000)
    ap.add_argument('--png', default=None)
    args = ap.parse_args()

    rom = Rom(args.rom or find_rom())
    mapper = MMC3(rom)
    spy = VRAMSpy()

    # 简化执行：只跑 CPU，不跑 PPU
    mem = bytearray(0x800)

    def rd(a):
        if a < 0x2000:
            return mem[a & 0x7FF]
        if a == 0x2002:
            return 0x80          # vblank 标志
        if a == 0x2007:
            v = spy.vram.get(spy.addr, 0)
            spy.addr = (spy.addr + 1) & 0x3FFF
            return v
        if a >= 0x8000:
            return mapper.prg_read(a)
        return 0

    def wr(a, v):
        if a < 0x2000:
            mem[a & 0x7FF] = v
        elif a == 0x2006:
            spy.write_2006(v)
        elif a == 0x2007:
            spy.write_2007(v)
        elif 0x8000 <= a < 0xA000:
            mapper.write(a, v)
        elif 0x2000 <= a < 0x4000:
            pass

    # 极简 6502 执行器（足够跑地图解压器）
    A = X = Y = 0
    SP = 0xFD
    PC = int(args.addr, 16)
    C = Z = N = V = 0
    mem[0x1FF] = 0xFF
    mem[0x1FE] = 0xF0

    def push(v):
        nonlocal SP
        mem[0x100 + SP] = v
        SP = (SP - 1) & 0xFF

    def pull():
        nonlocal SP
        SP = (SP + 1) & 0xFF
        return mem[0x100 + SP]

    def setzn(v):
        nonlocal Z, N
        v &= 0xFF
        Z = 1 if v == 0 else 0
        N = (v >> 7) & 1
        return v

    ADDR = {0x00: 'imm', 0x01: 'zp', 0x05: 'zp', 0x06: 'zp', 0x08: 'imp',
            0x09: 'imm', 0x0A: 'imp', 0x10: 'rel', 0x11: 'izy', 0x15: 'zpx',
            0x16: 'zpx', 0x18: 'imp', 0x19: 'aby', 0x1D: 'abx', 0x1E: 'abx',
            0x20: 'abs', 0x21: 'izx', 0x24: 'zp', 0x25: 'zp', 0x26: 'zp',
            0x28: 'imp', 0x29: 'imm', 0x2A: 'imp', 0x2C: 'abs', 0x2D: 'abs',
            0x30: 'rel', 0x31: 'izy', 0x35: 'zpx', 0x38: 'imp', 0x39: 'aby',
            0x3D: 'abx', 0x3E: 'abx', 0x40: 'imp', 0x41: 'izx', 0x45: 'zp',
            0x46: 'zp', 0x48: 'imp', 0x49: 'imm', 0x4A: 'imp', 0x4C: 'abs',
            0x4D: 'abs', 0x50: 'rel', 0x51: 'izy', 0x55: 'zpx', 0x58: 'imp',
            0x59: 'aby', 0x5D: 'abx', 0x5E: 'abx', 0x60: 'imp', 0x61: 'izx',
            0x65: 'zp', 0x66: 'zp', 0x68: 'imp', 0x69: 'imm', 0x6A: 'imp',
            0x6C: 'ind', 0x6D: 'abs', 0x70: 'rel', 0x71: 'izy', 0x75: 'zpx',
            0x78: 'imp', 0x79: 'aby', 0x7D: 'abx', 0x7E: 'abx', 0x81: 'izx',
            0x84: 'zp', 0x85: 'zp', 0x86: 'zp', 0x88: 'imp', 0x8A: 'imp',
            0x8C: 'abs', 0x8D: 'abs', 0x8E: 'abs', 0x90: 'rel', 0x91: 'izy',
            0x94: 'zpx', 0x95: 'zpx', 0x96: 'zpy', 0x98: 'imp', 0x99: 'aby',
            0x9A: 'imp', 0x9D: 'abx', 0xA0: 'imm', 0xA1: 'izx', 0xA2: 'imm',
            0xA4: 'zp', 0xA5: 'zp', 0xA6: 'zp', 0xA8: 'imp', 0xA9: 'imm',
            0xAA: 'imp', 0xAC: 'abs', 0xAD: 'abs', 0xAE: 'abs', 0xB0: 'rel',
            0xB1: 'izy', 0xB4: 'zpx', 0xB5: 'zpx', 0xB6: 'zpy', 0xB8: 'imp',
            0xB9: 'aby', 0xBA: 'imp', 0xBC: 'abx', 0xBD: 'abx', 0xBE: 'aby',
            0xC0: 'imm', 0xC1: 'izx', 0xC4: 'zp', 0xC5: 'zp', 0xC6: 'zp',
            0xC8: 'imp', 0xC9: 'imm', 0xCA: 'imp', 0xCC: 'abs', 0xCD: 'abs',
            0xCE: 'abs', 0xD0: 'rel', 0xD1: 'izy', 0xD5: 'zpx', 0xD6: 'zpx',
            0xD8: 'imp', 0xD9: 'aby', 0xDD: 'abx', 0xDE: 'abx', 0xE0: 'imm',
            0xE1: 'izx', 0xE4: 'zp', 0xE5: 'zp', 0xE6: 'zp', 0xE8: 'imp',
            0xE9: 'imm', 0xEA: 'imp', 0xEC: 'abs', 0xED: 'abs', 0xEE: 'abs',
            0xF0: 'rel', 0xF1: 'izy', 0xF5: 'zpx', 0xF6: 'zpx', 0xF8: 'imp',
            0xF9: 'aby', 0xFD: 'abx', 0xFE: 'abx'}

    steps = 0
    while steps < args.max_steps:
        steps += 1
        op = mapper.prg_read(PC)
        mode = ADDR.get(op)
        if mode is None:
            print(f'未知指令 ${op:02X} @ ${PC:04X}')
            break
        PC = (PC + 1) & 0xFFFF
        operand = 0
        if mode in ('imm', 'rel'):
            operand = mapper.prg_read(PC)
            PC = (PC + 1) & 0xFFFF
        elif mode in ('zp', 'zpx', 'zpy'):
            operand = mapper.prg_read(PC)
            PC = (PC + 1) & 0xFFFF
        elif mode in ('abs', 'abx', 'aby', 'ind'):
            operand = mapper.prg_read(PC) | mapper.prg_read(PC + 1) << 8
            PC = (PC + 2) & 0xFFFF
        elif mode in ('izx', 'izy'):
            operand = mapper.prg_read(PC)
            PC = (PC + 1) & 0xFFFF

        ea = 0
        if mode == 'zp':
            ea = operand
        elif mode == 'zpx':
            ea = (operand + X) & 0xFF
        elif mode == 'zpy':
            ea = (operand + Y) & 0xFF
        elif mode == 'abs':
            ea = operand
        elif mode == 'abx':
            ea = (operand + X) & 0xFFFF
        elif mode == 'aby':
            ea = (operand + Y) & 0xFFFF
        elif mode == 'izx':
            p = (operand + X) & 0xFF
            ea = rd(p) | rd((p + 1) & 0xFF) << 8
        elif mode == 'izy':
            ea = (rd(operand) | rd((operand + 1) & 0xFF) << 8) + Y
            ea &= 0xFFFF
        elif mode == 'ind':
            ea = rd(operand) | rd((operand & 0xFF00) | ((operand + 1) & 0xFF)) << 8

        j = None
        if op == 0xA9:
            A = setzn(operand)
        elif op == 0xA2:
            X = setzn(operand)
        elif op == 0xA0:
            Y = setzn(operand)
        elif op == 0xA5:
            A = setzn(rd(ea))
        elif op == 0xA6:
            X = setzn(rd(ea))
        elif op == 0xA4:
            Y = setzn(rd(ea))
        elif op == 0xAD:
            A = setzn(rd(ea))
        elif op == 0xAE:
            X = setzn(rd(ea))
        elif op == 0xAC:
            Y = setzn(rd(ea))
        elif op == 0xB5:
            A = setzn(rd(ea))
        elif op == 0xB6:
            X = setzn(rd(ea))
        elif op == 0xB4:
            Y = setzn(rd(ea))
        elif op == 0xBD:
            A = setzn(rd(ea))
        elif op == 0xBE:
            X = setzn(rd(ea))
        elif op == 0xBC:
            Y = setzn(rd(ea))
        elif op == 0xB9:
            A = setzn(rd(ea))
        elif op == 0xB1:
            A = setzn(rd(ea))
        elif op == 0x85:
            wr(ea, A)
        elif op == 0x86:
            wr(ea, X)
        elif op == 0x84:
            wr(ea, Y)
        elif op == 0x8D:
            wr(ea, A)
        elif op == 0x8E:
            wr(ea, X)
        elif op == 0x8C:
            wr(ea, Y)
        elif op == 0x95:
            wr(ea, A)
        elif op == 0x75:                      # ADC zp,X
            t = A + rd(ea) + C
            C = 1 if t > 0xFF else 0
            A = setzn(t)
        elif op == 0x55:                      # EOR zp,X
            A = setzn(A ^ rd(ea))
        elif op == 0x35:                      # AND zp,X
            A = setzn(A & rd(ea))
        elif op == 0x15:                      # ORA zp,X
            A = setzn(A | rd(ea))
        elif op == 0xF5:                      # SBC zp,X
            t = A - rd(ea) - (1 - C)
            C = 1 if t >= 0 else 0
            A = setzn(t)
        elif op == 0xD5:                      # CMP zp,X
            v = rd(ea)
            setzn(A - v)
            C = 1 if A >= v else 0
        elif op == 0xF6:                      # INC zp,X
            wr(ea, (rd(ea) + 1) & 0xFF)
            setzn(rd(ea))
        elif op == 0xD6:                      # DEC zp,X
            wr(ea, (rd(ea) - 1) & 0xFF)
            setzn(rd(ea))
        elif op == 0x16:                      # ASL zp,X
            v = rd(ea)
            C = (v >> 7) & 1
            wr(ea, setzn((v << 1) & 0xFF))
        elif op == 0x26:                      # ROL zp
            v = rd(ea)
            t = v << 1 | C
            C = (t >> 8) & 1
            wr(ea, setzn(t & 0xFF))
        elif op == 0x46:                      # LSR zp
            v = rd(ea)
            C = v & 1
            wr(ea, setzn(v >> 1))
        elif op == 0x66:                      # ROR zp
            v = rd(ea)
            t = (C << 8) | v
            C = v & 1
            wr(ea, setzn(t >> 1))
        elif op == 0x96:
            wr(ea, X)
        elif op == 0x94:
            wr(ea, Y)
        elif op == 0x9D:
            wr(ea, A)
        elif op == 0x99:
            wr(ea, A)
        elif op == 0x91:
            wr(ea, A)
        elif op == 0x29:
            A = setzn(A & operand)
        elif op == 0x25:
            A = setzn(A & rd(ea))
        elif op == 0x09:
            A = setzn(A | operand)
        elif op == 0x05:
            A = setzn(A | rd(ea))
        elif op == 0x49:
            A = setzn(A ^ operand)
        elif op == 0x0A:
            C = (A >> 7) & 1
            A = setzn((A << 1) & 0xFF)
        elif op == 0x4A:
            C = A & 1
            A = setzn(A >> 1)
        elif op == 0x2A:
            t = A << 1 | C
            C = (t >> 8) & 1
            A = setzn(t & 0xFF)
        elif op == 0x6A:
            t = (C << 8) | A
            C = A & 1
            A = setzn(t >> 1)
        elif op == 0x69:
            t = A + operand + C
            C = 1 if t > 0xFF else 0
            A = setzn(t)
        elif op == 0x65:
            t = A + rd(ea) + C
            C = 1 if t > 0xFF else 0
            A = setzn(t)
        elif op == 0xE9:
            t = A - operand - (1 - C)
            C = 1 if t >= 0 else 0
            A = setzn(t)
        elif op == 0xE5:
            t = A - rd(ea) - (1 - C)
            C = 1 if t >= 0 else 0
            A = setzn(t)
        elif op == 0xC9:
            setzn(A - operand)
            C = 1 if A >= operand else 0
        elif op == 0xC5:
            v = rd(ea)
            setzn(A - v)
            C = 1 if A >= v else 0
        elif op == 0xE0:
            setzn(X - operand)
            C = 1 if X >= operand else 0
        elif op == 0xE4:
            v = rd(ea)
            setzn(X - v)
            C = 1 if X >= v else 0
        elif op == 0xC0:
            setzn(Y - operand)
            C = 1 if Y >= operand else 0
        elif op == 0xC4:
            v = rd(ea)
            setzn(Y - v)
            C = 1 if Y >= v else 0
        elif op == 0xE8:
            X = setzn(X + 1)
        elif op == 0xC8:
            Y = setzn(Y + 1)
        elif op == 0xCA:
            X = setzn(X - 1)
        elif op == 0x88:
            Y = setzn(Y - 1)
        elif op == 0xE6:
            wr(ea, (rd(ea) + 1) & 0xFF)
            setzn(rd(ea))
        elif op == 0xC6:
            wr(ea, (rd(ea) - 1) & 0xFF)
            setzn(rd(ea))
        elif op == 0x18:
            C = 0
        elif op == 0x38:
            C = 1
        elif op == 0x58:
            pass
        elif op == 0x78:
            pass
        elif op == 0xEA:
            pass
        elif op == 0x48:
            push(A)
        elif op == 0x68:
            A = setzn(pull())
        elif op == 0x8A:
            A = setzn(X)
        elif op == 0x98:
            A = setzn(Y)
        elif op == 0xAA:
            X = setzn(A)
        elif op == 0xA8:
            Y = setzn(A)
        elif op == 0xBA:
            X = setzn(SP)
        elif op == 0x9A:
            SP = X
        elif op == 0x20:
            ret = (PC - 1) & 0xFFFF
            push(ret >> 8)
            push(ret & 0xFF)
            PC = operand
        elif op == 0x60:
            lo = pull()
            hi = pull()
            PC = ((hi << 8) | lo) + 1 & 0xFFFF
        elif op == 0x4C:
            PC = operand
        elif op == 0x6C:
            PC = ea
        elif op == 0x10:                      # BPL
            if N == 0:
                PC = (PC + (operand - 256 if operand > 127 else operand)) & 0xFFFF
        elif op == 0x30:                      # BMI
            if N:
                PC = (PC + (operand - 256 if operand > 127 else operand)) & 0xFFFF
        elif op == 0x90:                      # BCC
            if C == 0:
                PC = (PC + (operand - 256 if operand > 127 else operand)) & 0xFFFF
        elif op == 0xB0:                      # BCS
            if C:
                PC = (PC + (operand - 256 if operand > 127 else operand)) & 0xFFFF
        elif op == 0xD0:                      # BNE
            if Z == 0:
                PC = (PC + (operand - 256 if operand > 127 else operand)) & 0xFFFF
        elif op == 0xF0:                      # BEQ
            if Z:
                PC = (PC + (operand - 256 if operand > 127 else operand)) & 0xFFFF
        elif op == 0x00:                      # BRK
            break
        else:
            print(f'未实现指令 ${op:02X} @ ${PC - 1:04X}')
            break

    print(f'执行 {steps} 步，VRAM 写入 {len(spy.writes)} 字节')
    # 输出 nametable 内容
    for nt, name in ((0x2000, 'NT0'), (0x2400, 'NT1')):
        cells = {a: v for a, v in spy.writes if nt <= a < nt + 0x400}
        if not cells:
            continue
        print(f'\n{name}: {len(cells)} 格')
        for row in range(30):
            line = ''.join(
                '%X' % (cells.get(nt + row * 32 + c, 0) & 0xF) for c in range(32))
            print('  ' + line)


if __name__ == '__main__':
    main()
