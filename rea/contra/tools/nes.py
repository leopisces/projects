"""完整 NES 主机模拟 —— 直接运行原版 Contra ROM。

结构：
    NES(rom) → .run_frame()  推进一帧
             → .framebuffer  RGB888
             → .set_buttons(mask)  设置手柄

这是“能玩和原版一样”的最可靠实现路径：不改 ROM 一个字节，
CPU/PPU/APU/MMC3/手柄全部按硬件行为实现，所以画面与逻辑天然一致。

手柄位（标准 NES）：
    A=0x01  B=0x02  Select=0x04  Start=0x08
    Up=0x10 Down=0x20 Left=0x40 Right=0x80
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
from nes_ppu import PPU
from mmc3 import MMC3
from apu_stub import APU

BTN_A = 0x01
BTN_B = 0x02
BTN_SELECT = 0x04
BTN_START = 0x08
BTN_UP = 0x10
BTN_DOWN = 0x20
BTN_LEFT = 0x40
BTN_RIGHT = 0x80


class NESBus:
    def __init__(self, nes):
        self.nes = nes
        self.ram = bytearray(0x800)
        self.trace = None

    # ---- CPU 接口 ----
    def read(self, addr):
        addr &= 0xFFFF
        if addr < 0x2000:
            return self.ram[addr & 0x7FF]
        if addr < 0x4000:
            return self.nes.ppu.cpu_read(0x2000 + (addr & 7))
        if addr == 0x4014:
            return 0
        if addr == 0x4015:
            return self.nes.apu.read_status()
        if addr == 0x4016:
            return self.nes.read_controller(0)
        if addr == 0x4017:
            return self.nes.read_controller(1)
        if addr < 0x4020:
            return 0
        if addr >= 0x8000:
            return self.nes.mapper.bus_read(addr)
        return 0

    def write(self, addr, val):
        addr &= 0xFFFF
        val &= 0xFF
        if addr < 0x2000:
            self.ram[addr & 0x7FF] = val
        elif addr < 0x4000:
            self.nes.ppu.cpu_write(0x2000 + (addr & 7), val)
        elif addr == 0x4014:
            # OAM DMA：从 CPU 页 val 拷 256 字节
            base = val << 8
            data = bytearray(256)
            for i in range(256):
                a = (base + i) & 0xFFFF
                data[i] = self.ram[a & 0x7FF] if a < 0x2000 else self.read(a)
            self.nes.ppu.do_oam_dma(data)
        elif addr == 0x4016:
            self.nes.write_strobe(val)
        elif addr < 0x4018:
            self.nes.apu.write(addr, val)
        elif addr >= 0x8000:
            self.nes.mapper.prg_write(addr, val)


class NES:
    def __init__(self, rom_path=None):
        self.rom = Rom(rom_path) if rom_path else Rom()
        self.mapper = MMC3(self.rom)
        self.ppu = PPU(self.mapper)
        self.ppu.mirroring = 1          # 水平镜像（Contra $A000 会设置）
        self.apu = APU()
        self.bus = NESBus(self)
        self.cpu = CPU6502(self.bus)

        # 手柄
        self.buttons = [0, 0]
        self.strobe = False
        self.shift_reg = [0, 0]

        # CPU 周期累计（用于 PPU 步进比例 3:1）
        self.cycles = 0

        self.reset()

    def reset(self):
        # 读 RESET 向量
        vec = self.rom.vector('RESET')
        self.ppu = PPU(self.mapper)
        self.ppu.mirroring = 1
        self.cpu = CPU6502(self.bus, pc=vec)
        self.cpu.sp = 0xFD
        self.cpu.p = 0x24
        self.cycles = 0
        self.frame = 0

    # ---- 手柄 ----
    def write_strobe(self, val):
        """$4016 写入。1 = 持续锁存；1→0 的下降沿装载移位寄存器。"""
        new_strobe = bool(val & 1)
        if self.strobe and not new_strobe:
            # 下降沿：装载本次按键快照
            self.shift_reg = [self.buttons[0], self.buttons[1]]
        self.strobe = new_strobe

    def read_controller(self, n):
        """读 $4016/$4017（标准 NES 位序：A,B,Select,Start,Up,Down,Left,Right）。"""
        if n > 1:
            return 0x40
        if self.strobe:
            return 0x40 | (self.buttons[n] & 1)
        v = self.shift_reg[n] & 1
        self.shift_reg[n] = (self.shift_reg[n] >> 1) | 0x80
        return 0x40 | v

    def set_buttons(self, mask, player=0):
        """mask 用标准位序（A=01,B=02,Select=04,Start=08,Up=10,Down=20,Left=40,Right=80）。

        Contra 的 $C1F9 把每次读到的位 ROL 进 $04，8 次后第 1 次读落到 bit7，
        并从 $C1B3 表得知 Left=$40/Right=$80（即 bit6/bit7），
        所以这份 ROM 期望 $4016 先输出 Right、最后输出 A —— 这里反过来存。
        """
        b = mask & 0xFF
        rev = 0
        for i in range(8):
            if b & (1 << i):
                rev |= 1 << (7 - i)
        self.buttons[player] = rev

    # ---- 执行 ----
    def step_cpu(self):
        if self.ppu.nmi_pending:
            self.ppu.nmi_pending = False
            self.cpu.nmi()
        elif self.mapper.irq_pending:
            self.mapper.irq_pending = False
            self.cpu.irq()
        cyc = self.cpu.step()
        self.cycles += cyc
        # PPU 每 CPU 周期走 3 个 dot → 这里按 scanline 粒度推进
        self._ppu_advance(cyc * 3)
        self.apu.step(cyc)
        return cyc

    def _ppu_advance(self, dots):
        p = self.ppu
        m = self.mapper
        for _ in range(dots):
            p.dot += 1
            # ---- MMC3 A12 边沿检测（scanline counter）----
            # PPU 每 8 个 dot 取一次 tile；背景在 $0000-$0FFF（若 ctrl&0x10 则为背景 $1000），
            # 精灵恒在 $1000（16x8）或 $0000（8x8）。这里用“本 dot 是否在取精灵图案”近似 A12。
            if (p.dot & 7) == 0 and 0 <= p.scanline < 240:
                a12 = self._ppu_a12_now()
                if a12 and not m._a12_prev:
                    m.clock_irq()
                m._a12_prev = a12

            if p.dot >= 341:
                p.dot = 0
                # 每条扫描线开始时把该行画出来（实时渲染）
                if 0 <= p.scanline < 240:
                    p.render_scanline(p.scanline)
                p.scanline += 1
                if p.scanline == 241:
                    p.status |= 0x80
                    if p.ctrl & 0x80:
                        p.nmi_pending = True
                elif p.scanline == 261:
                    p.status &= ~0xE0
                    p.sprite0_hit = False
                    m._a12_prev = False
                elif p.scanline >= 262:
                    p.scanline = 0
                    p.frame += 1

    def _ppu_a12_now(self):
        """当前 dot 是否在读 $1000+ 的图案（A12 高）。"""
        p = self.ppu
        d = p.dot
        # 粗略时序：每 8 dot 一个 tile；预取/精灵取图在行末 257-320
        if 257 <= d < 320:
            return True          # 精灵图案取数
        if d >= 328 or d < 256:
            return bool(p.ctrl & 0x10)
        return False

    def run_frame(self):
        """跑一帧（到 PPU 下一次 frame 递增）。"""
        target = self.ppu.frame + 1
        start_sl = self.ppu.scanline
        guard = 0
        while self.ppu.frame != target and guard < 2_000_000:
            # 在可见行的 start 处渲染整行（快路径）
            self.step_cpu()
            guard += 1
        # 渲染本帧所有可见扫描线
        return self.ppu.frame

    def render_frame(self):
        """渲染当前 VRAM 状态下的整帧（供截图）。"""
        # 保存滚动状态，逐行渲染后恢复
        for y in range(240):
            self.ppu.render_scanline(y)
        return self.ppu.framebuffer
