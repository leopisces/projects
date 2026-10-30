"""完整的 6502 CPU 核心（合法指令集，无非法 opcode）。

用在 contra 的声音引擎上（bank 1，$8000-$8AFF 那段代码）：
引擎只依赖 RAM + APU 写，所以这里不模拟中断优先级、也不做 cycle 精确计时，
只保证：指令语义、N/V/Z/C/I/D 标志、页边界行为与真机一致。

对应 ROM 用法：
    bus = Bus(...)                     # 由 play_sound.py 提供
    cpu = CPU6502(bus)
    cpu.call(0x8719)                   # 引擎复位（bank 1 映射在 $8000 时）

两条与真机对齐的细节：
  * JMP (ind) 的页边界 bug（指针高字节不进位）—— 由 jmp_ind_bug 控制，默认开启。
  * 十进制模式（SED）下的 ADC/SBC —— 引擎不用，但按真机实现，避免静默出错。
"""

# 状态标志位
FN = 0x80   # N negative
FV = 0x40   # V overflow
FU = 0x20   # U unused（始终为 1）
FB = 0x10   # B break
FD = 0x08   # D decimal
FI = 0x04   # I interrupt disable
FZ = 0x02   # Z zero
FC = 0x01   # C carry

# 长度表：操作码 -> (助记符, 寻址方式)
def _build_table():
    from dis6502 import T, LEN
    out = {}
    for op, (mn, mode) in T.items():
        out[op] = (mn.upper(), mode)
    return out

OP = _build_table()

# 寻址方式 -> 操作数字节数（不含 opcode）
ADDR_BYTES = {'imp': 0, 'acc': 0, 'imm': 1, 'zp': 1, 'zpx': 1, 'zpy': 1,
              'abs': 2, 'absx': 2, 'absy': 2, 'ind': 2, 'indx': 1, 'indy': 1,
              'rel': 1}


class CPU6502:
    def __init__(self, bus, pc=0x0000):
        self.bus = bus
        self.a = 0
        self.x = 0
        self.y = 0
        self.sp = 0xFD
        self.pc = pc
        self.p = FU | FI
        self.steps = 0
        self.jmp_ind_bug = True
        # 统计：进入过的 ROM 地址，用来证明引擎跑通了哪几段
        self.hits = {}

    # ---------------- 总线快捷方式 ----------------
    def rd(self, addr):
        return self.bus.read(addr & 0xFFFF)

    def wr(self, addr, val):
        self.bus.write(addr & 0xFFFF, val & 0xFF)

    # ---------------- 栈 ----------------
    def push(self, v):
        self.bus.write(0x0100 | self.sp, v & 0xFF)
        self.sp = (self.sp - 1) & 0xFF

    def pull(self):
        self.sp = (self.sp + 1) & 0xFF
        return self.bus.read(0x0100 | self.sp)

    # ---------------- 标志 ----------------
    def _nz(self, v):
        self.p = (self.p & ~(FN | FZ)) | (v & FN) | (FZ if v == 0 else 0)
        return v

    def set_flag(self, f, on):
        if on:
            self.p |= f
        else:
            self.p &= ~f & 0xFF

    def get_flag(self, f):
        return 1 if (self.p & f) else 0

    # ---------------- 取操作数 ----------------
    def fetch8(self):
        v = self.bus.read(self.pc)
        self.pc = (self.pc + 1) & 0xFFFF
        return v

    def fetch16(self):
        lo = self.fetch8()
        hi = self.fetch8()
        return lo | (hi << 8)

    def addr_of(self, mode):
        """把寻址方式解析成有效地址（imm/rel 不走这里）。"""
        if mode == 'zp':
            return self.fetch8()
        if mode == 'zpx':
            return (self.fetch8() + self.x) & 0xFF
        if mode == 'zpy':
            return (self.fetch8() + self.y) & 0xFF
        if mode == 'abs':
            return self.fetch16()
        if mode == 'absx':
            return (self.fetch16() + self.x) & 0xFFFF
        if mode == 'absy':
            return (self.fetch16() + self.y) & 0xFFFF
        if mode == 'indx':
            z = (self.fetch8() + self.x) & 0xFF
            return self.bus.read(z) | (self.bus.read((z + 1) & 0xFF) << 8)
        if mode == 'indy':
            z = self.fetch8()
            base = self.bus.read(z) | (self.bus.read((z + 1) & 0xFF) << 8)
            return (base + self.y) & 0xFFFF
        raise ValueError('addr_of 不支持的方式 %r' % mode)

    def read_operand(self, mode):
        if mode == 'imm':
            return self.fetch8()
        if mode == 'acc':
            return self.a
        return self.bus.read(self.addr_of(mode))

    # ---------------- ADC / SBC ----------------
    def adc(self, v):
        a = self.a
        if self.p & FD:
            lo = (a & 0x0F) + (v & 0x0F) + (self.p & FC)
            hi = (a >> 4) + (v >> 4)
            if lo > 9:
                lo += 6
                hi += 1
            # 二进制结果的 V/N/Z 语义（NES 的 2A03 无十进制，这里只为完整性）
            r_bin = (a + v + (self.p & FC)) & 0xFF
            if hi > 9:
                hi += 6
            r = ((hi << 4) | (lo & 0x0F)) & 0xFF
            self.set_flag(FC, hi > 0x0F)
            self._nz(r)
            self.a = r
            return
        r = a + v + (self.p & FC)
        self.set_flag(FC, r > 0xFF)
        r &= 0xFF
        # V = (~(a^v) & (a^r)) & 0x80
        self.set_flag(FV, (~(a ^ v) & (a ^ r) & 0x80) != 0)
        self.a = self._nz(r)

    def sbc(self, v):
        a = self.a
        if self.p & FD:
            borrow = 1 - (self.p & FC)
            lo = (a & 0x0F) - (v & 0x0F) - borrow
            hi = (a >> 4) - (v >> 4)
            if lo < 0:
                lo -= 6
                hi -= 1
            if hi < 0:
                hi -= 6
            r = ((hi << 4) | (lo & 0x0F)) & 0xFF
            self.set_flag(FC, not ((a - v - borrow) & 0x100))
            self._nz(r)
            self.a = r
            return
        d = a - v - (1 - (self.p & FC))
        self.set_flag(FC, d >= 0)
        r = d & 0xFF
        self.set_flag(FV, ((a ^ v) & (a ^ r) & 0x80) != 0)
        self.a = self._nz(r)

    # ---------------- 比较 ----------------
    def cmp_reg(self, reg, v):
        d = reg - v
        self.set_flag(FC, d >= 0)
        self._nz(d & 0xFF)

    # ---------------- 移位 ----------------
    def asl(self, v):
        self.set_flag(FC, v & 0x80)
        return self._nz((v << 1) & 0xFF)

    def lsr(self, v):
        self.set_flag(FC, v & 0x01)
        return self._nz(v >> 1)

    def rol(self, v):
        c = self.p & FC
        self.set_flag(FC, v & 0x80)
        return self._nz(((v << 1) | c) & 0xFF)

    def ror(self, v):
        c = (self.p & FC) << 7
        self.set_flag(FC, v & 0x01)
        return self._nz((v >> 1) | c)

    # ---------------- 单步 ----------------
    def step(self):
        pc = self.pc
        op = self.bus.read(pc)
        ent = OP.get(op)
        if ent is None:
            raise RuntimeError('非法 opcode $%02X @ $%04X' % (op, pc))
        mn, mode = ent
        self.pc = (pc + 1) & 0xFFFF
        self.steps += 1
        if self.bus.trace is not None:
            self.bus.trace(pc, op)

        # ---- 载入/存储 ----
        if mn == 'LDA':
            self.a = self._nz(self.read_operand(mode))
        elif mn == 'LDX':
            self.x = self._nz(self.read_operand(mode))
        elif mn == 'LDY':
            self.y = self._nz(self.read_operand(mode))
        elif mn == 'STA':
            self.wr(self.addr_of(mode), self.a)
        elif mn == 'STX':
            self.wr(self.addr_of(mode), self.x)
        elif mn == 'STY':
            self.wr(self.addr_of(mode), self.y)
        # ---- 传送 ----
        elif mn == 'TAX':
            self.x = self._nz(self.a)
        elif mn == 'TAY':
            self.y = self._nz(self.a)
        elif mn == 'TXA':
            self.a = self._nz(self.x)
        elif mn == 'TYA':
            self.a = self._nz(self.y)
        elif mn == 'TSX':
            self.x = self._nz(self.sp)
        elif mn == 'TXS':
            self.sp = self.x
        # ---- 算术 ----
        elif mn == 'ADC':
            self.adc(self.read_operand(mode))
        elif mn == 'SBC':
            self.sbc(self.read_operand(mode))
        elif mn == 'CMP':
            self.cmp_reg(self.a, self.read_operand(mode))
        elif mn == 'CPX':
            self.cmp_reg(self.x, self.read_operand(mode))
        elif mn == 'CPY':
            self.cmp_reg(self.y, self.read_operand(mode))
        elif mn == 'INC':
            a = self.addr_of(mode)
            self.wr(a, self._nz((self.bus.read(a) + 1) & 0xFF))
        elif mn == 'DEC':
            a = self.addr_of(mode)
            self.wr(a, self._nz((self.bus.read(a) - 1) & 0xFF))
        elif mn == 'INX':
            self.x = self._nz((self.x + 1) & 0xFF)
        elif mn == 'INY':
            self.y = self._nz((self.y + 1) & 0xFF)
        elif mn == 'DEX':
            self.x = self._nz((self.x - 1) & 0xFF)
        elif mn == 'DEY':
            self.y = self._nz((self.y - 1) & 0xFF)
        # ---- 逻辑 ----
        elif mn == 'AND':
            self.a = self._nz(self.a & self.read_operand(mode))
        elif mn == 'ORA':
            self.a = self._nz(self.a | self.read_operand(mode))
        elif mn == 'EOR':
            self.a = self._nz(self.a ^ self.read_operand(mode))
        elif mn == 'BIT':
            v = self.read_operand(mode)
            self.set_flag(FZ, (self.a & v) == 0)
            self.p = (self.p & ~(FN | FV)) | (v & 0xC0)
        # ---- 移位 ----
        elif mn == 'ASL':
            if mode == 'acc':
                self.a = self.asl(self.a)
            else:
                a = self.addr_of(mode)
                self.wr(a, self.asl(self.bus.read(a)))
        elif mn == 'LSR':
            if mode == 'acc':
                self.a = self.lsr(self.a)
            else:
                a = self.addr_of(mode)
                self.wr(a, self.lsr(self.bus.read(a)))
        elif mn == 'ROL':
            if mode == 'acc':
                self.a = self.rol(self.a)
            else:
                a = self.addr_of(mode)
                self.wr(a, self.rol(self.bus.read(a)))
        elif mn == 'ROR':
            if mode == 'acc':
                self.a = self.ror(self.a)
            else:
                a = self.addr_of(mode)
                self.wr(a, self.ror(self.bus.read(a)))
        # ---- 跳转/调用 ----
        elif mn == 'JMP':
            if mode == 'abs':
                self.pc = self.fetch16()
            else:
                ptr = self.fetch16()
                lo = self.bus.read(ptr)
                if self.jmp_ind_bug:
                    hi = self.bus.read((ptr & 0xFF00) | ((ptr + 1) & 0xFF))
                else:
                    hi = self.bus.read((ptr + 1) & 0xFFFF)
                self.pc = lo | (hi << 8)
        elif mn == 'JSR':
            tgt = self.fetch16()
            ret = (self.pc - 1) & 0xFFFF
            self.push(ret >> 8)
            self.push(ret & 0xFF)
            self.pc = tgt
        elif mn == 'RTS':
            lo = self.pull()
            hi = self.pull()
            self.pc = ((lo | (hi << 8)) + 1) & 0xFFFF
        elif mn == 'RTI':
            self.p = (self.pull() & ~FB) | FU
            lo = self.pull()
            hi = self.pull()
            self.pc = lo | (hi << 8)
        elif mn == 'BRK':
            self.pc = (self.pc + 1) & 0xFFFF
            self.push(self.pc >> 8)
            self.push(self.pc & 0xFF)
            self.push(self.p | FB | FU)
            self.set_flag(FI, True)
        # ---- 分支 ----
        elif mode == 'rel':
            off = self.fetch8()
            if off & 0x80:
                off -= 0x100
            cond = {
                'BPL': not (self.p & FN), 'BMI': bool(self.p & FN),
                'BVC': not (self.p & FV), 'BVS': bool(self.p & FV),
                'BCC': not (self.p & FC), 'BCS': bool(self.p & FC),
                'BNE': not (self.p & FZ), 'BEQ': bool(self.p & FZ),
            }[mn]
            if cond:
                self.pc = (self.pc + off) & 0xFFFF
        # ---- 标志 ----
        elif mn == 'CLC':
            self.set_flag(FC, False)
        elif mn == 'SEC':
            self.set_flag(FC, True)
        elif mn == 'CLI':
            self.set_flag(FI, False)
        elif mn == 'SEI':
            self.set_flag(FI, True)
        elif mn == 'CLV':
            self.set_flag(FV, False)
        elif mn == 'CLD':
            self.set_flag(FD, False)
        elif mn == 'SED':
            self.set_flag(FD, True)
        # ---- 栈 ----
        elif mn == 'PHA':
            self.push(self.a)
        elif mn == 'PHP':
            self.push(self.p | FB | FU)
        elif mn == 'PLA':
            self.a = self._nz(self.pull())
        elif mn == 'PLP':
            self.p = (self.pull() & ~FB) | FU
        elif mn == 'NOP':
            if mode in ('imm', 'zp', 'zpx', 'abs', 'absx'):
                self.addr_of(mode)
        else:
            raise RuntimeError('未实现指令 %s %s @ $%04X' % (mn, mode, pc))
        return mn

    # ---------------- 调用辅助 ----------------
    def call(self, addr, max_steps=200000):
        """等价于 JSR addr：跑到这条 JSR 对应的 RTS 返回为止。"""
        sp0 = self.sp
        ret = (self.pc - 1) & 0xFFFF
        self.push(ret >> 8)
        self.push(ret & 0xFF)
        self.pc = addr
        n = 0
        while True:
            mn = self.step()
            n += 1
            if n > max_steps:
                raise RuntimeError('call($%04X) 超过 %d 步未返回，PC=$%04X' %
                                   (addr, max_steps, self.pc))
            if self.sp == sp0 and mn == 'RTS':
                break
        return n

    def run(self, max_steps=100000):
        n = 0
        while n < max_steps:
            self.step()
            n += 1
        return n

    def dump(self):
        return ('A=%02X X=%02X Y=%02X SP=%02X P=%02X PC=%04X' %
                (self.a, self.x, self.y, self.sp, self.p, self.pc))
