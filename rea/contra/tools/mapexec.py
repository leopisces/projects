"""用完整 6502 模拟器跑地图解压器，拿 ground truth。

关键：$C93A 用 `LDA $C9B1,X` / `LDA $C9B2,X` 取指针，所以 X = 地图索引 × 2。
需要先把当期 PRG bank 切对（指针指向 $8000-$BFFF 时），这里把每个 bank 都试一遍。
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
from cpu6502 import CPU6502


def find_rom():
    import glob
    for p in glob.glob(os.path.join(os.path.expanduser('~'), 'Desktop', '*.nes')):
        if os.path.getsize(p) == 393232:
            return p
    raise FileNotFoundError


class MMC3Bus:
    """6502 总线 + MMC3 PRG 切换 + PPU $2006/$2007 记录。"""

    def __init__(self, rom):
        self.rom = rom
        self.ram = bytearray(0x800)
        self.bank_select = 0
        self.r = [0] * 8
        self.prg_mode = 0
        self.vram = {}
        self.addr = 0
        self.latch = None
        self.writes = []
        self.log = []
        self.tracing = False

    # cpu6502 每步会调 bus.trace(pc, op)；设为 None 关闭
    trace = None

    # PRG 映射（MMC3）：$E000/$C000 固定为倒数两页，
    # prg_mode=0 时 $8000=R6、$A000=R7；prg_mode=1 时 $8000=倒数第二、$A000=R6
    def prg_page(self, addr):
        n = len(self.rom.prg) // 8192
        if addr >= 0xE000:
            return n - 1
        if addr >= 0xC000:
            return n - 2
        if addr >= 0xA000:
            return (self.r[7] & 0x3F) if self.prg_mode == 0 else (self.r[6] & 0x3F)
        return (self.r[6] & 0x3F) if self.prg_mode == 0 else (n - 2)

    def rd(self, a):
        a &= 0xFFFF
        if a < 0x2000:
            return self.ram[a & 0x7FF]
        if a == 0x2002:
            # 读 PPUSTATUS 会清 $2006 的半字节锁存（$C94D 就是靠这步复位）
            self.latch = None
            return 0x80
        if a == 0x2007:
            v = self.vram.get(self.addr, 0)
            self.addr = (self.addr + 1) & 0x3FFF
            return v
        if a >= 0x8000:
            page = self.prg_page(a)
            off = page * 8192 + (a & 0x1FFF)
            return self.rom.prg[off] if off < len(self.rom.prg) else 0
        return 0

    def wr(self, a, v):
        a &= 0xFFFF
        v &= 0xFF
        if a < 0x2000:
            self.ram[a & 0x7FF] = v
        elif a == 0x2006:
            if self.latch is None:
                self.latch = v
            else:
                self.addr = ((self.latch << 8) | v) & 0x3FFF
                self.latch = None
        elif a == 0x2007:
            self.vram[self.addr] = v
            self.writes.append((self.addr, v))
            self.addr = (self.addr + 1) & 0x3FFF
        elif 0x8000 <= a < 0xA000:
            if a & 1 == 0:
                self.bank_select = v & 7
            else:
                self.r[self.bank_select] = v
                if self.bank_select == 6:
                    self.prg_mode = (v >> 6) & 1

    # CPU6502 需要的接口名
    def read(self, a):
        return self.rd(a)

    def write(self, a, v):
        self.wr(a, v)


def run_map(rom, index, bank=None, max_steps=400000):
    bus = MMC3Bus(rom)
    if bank is not None:
        bus.r[6] = bank
        bus.prg_mode = 0
    cpu = CPU6502(bus)
    cpu.x = (index * 2) & 0xFF
    cpu.sp = 0xFD
    bus.ram[0x1FF] = 0xFF
    bus.ram[0x1FE] = 0xF0
    cpu.pc = 0xC93A
    steps = 0
    while steps < max_steps:
        cpu.step()
        steps += 1
        if cpu.pc <= 1 or cpu.pc == 0x0000:
            break
        if len(bus.writes) > 3000:
            break
    return bus, steps


def main():
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument('--rom', default=None)
    ap.add_argument('--index', type=int, default=2, help='地图序号')
    ap.add_argument('--bank', type=int, default=None)
    ap.add_argument('--steps', type=int, default=400000)
    args = ap.parse_args()

    rom = Rom(args.rom or find_rom())
    code = rom.prg[len(rom.prg) - 16384:]
    ptrs = []
    for i in range(16):
        o = 0xC9B1 + i * 2 - 0xC000
        ptrs.append(code[o] | code[o + 1] << 8)

    p = ptrs[args.index]
    print(f'地图 {args.index}: 指针 ${p:04X}')

    banks = [args.bank] if args.bank is not None else (
        [None] if p >= 0xC000 else range(rom.prg_banks))

    for bk in banks:
        bus, steps = run_map(rom, args.index, bk, args.steps)
        n = len(bus.writes)
        cells = {a: v for a, v in bus.writes if 0x2000 <= a < 0x2400}
        nz = sum(1 for v in cells.values() if v)
        tag = f'bank {bk}' if bk is not None else '固定 bank'
        print(f'  {tag}: {steps} 步, 写入 {n} 字节, NT0 {len(cells)} 格 (非零 {nz})')
        if nz > 50:
            for row in range(30):
                line = ''.join('%X' % (cells.get(0x2000 + row * 32 + c, 0) & 0xF)
                               for c in range(32))
                print('    ' + line)
            break


if __name__ == '__main__':
    main()
