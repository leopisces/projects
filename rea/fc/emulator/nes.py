"""通用 NES 主机模拟器（iNES 文件 → 可运行、可显示）。

    from nes import NES
    emu = NES('xxx.nes')
    emu.set_buttons(0)
    emu.run_frame()          # 跑一帧
    emu.framebuffer          # RGB888, 256×240

组成：
    ines.py      iNES/NES2.0 解析
    mappers.py   mapper 0/1/2/3/4/7/11/13/66
    nes_ppu.py   PPU（逐扫描线渲染，v/t 滚动模型）
    cpu6502.py   6502 CPU
    apu.py       2A03 APU（脉冲×2 / 三角 / 噪声 / DMC，非线性混音）

手柄位（标准 NES）：
    A=0x01  B=0x02  Select=0x04  Start=0x08
    Up=0x10 Down=0x20 Left=0x40 Right=0x80
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
if HERE not in sys.path:
    sys.path.insert(0, HERE)

try:
    sys.stdout.reconfigure(encoding='utf-8')
except Exception:
    pass

from ines import INes
from mappers import make_mapper, supported, UnsupportedMapper
from cpu6502 import CPU6502
from nes_ppu import PPU
from apu import APU, SR as APU_SR

BTN_A = 0x01
BTN_B = 0x02
BTN_SELECT = 0x04
BTN_START = 0x08
BTN_UP = 0x10
BTN_DOWN = 0x20
BTN_LEFT = 0x40
BTN_RIGHT = 0x80


class NESBus:
    """CPU 地址空间：$0000-$1FFF RAM，$2000 PPU，$4000 APU/手柄，$6000 PRG-RAM，$8000 PRG。"""

    def __init__(self, nes):
        self.nes = nes
        self.mapper = nes.mapper          # 热路径缓存，省一次属性查找
        self.ram = bytearray(0x800)
        self.trace = None
        # 热路径别名：取指/取数据绝大部分走 2A03 的 RAM（$0000-$07FF），
        # 直接把这些方法绑到实例上，read() 里就只差 addr&0x7FF 一次运算；
        # 下面是“未优化前就有的”通用实现，_partial_bind() 不存在时自动回落。
        self.read = self.read_ranged
        self.write = self.write_ranged

    def read_ranged(self, addr):
        addr &= 0xFFFF
        if addr >= 0x8000:
            return self.mapper.prg_read(addr)
        if addr < 0x2000:
            return self.ram[addr & 0x7FF]
        return self._read_slow(addr)

    def write_ranged(self, addr, val):
        if addr < 0x2000:
            self.ram[addr & 0x7FF] = val & 0xFF
        elif addr >= 0x8000:
            self.mapper.prg_write(addr, val & 0xFF)
        else:
            self._write_slow(addr, val)

    def _read_slow(self, addr):
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
        if addr < 0x6000:
            return 0                                     # 扩展区，未接
        return self.mapper.prg_ram_read(addr)

    def _write_slow(self, addr, val):
        val &= 0xFF
        if addr < 0x2000:
            self.ram[addr & 0x7FF] = val
        elif addr < 0x4000:
            self.nes.ppu.cpu_write(0x2000 + (addr & 7), val)
        elif addr == 0x4014:                             # OAM DMA
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
        elif addr < 0x6000:
            pass
        elif addr < 0x8000:
            self.nes.mapper.prg_ram_write(addr, val)
        else:
            self.nes.mapper.prg_write(addr, val)


class NES:
    def __init__(self, rom_path=None):
        if isinstance(rom_path, INes):
            self.rom = rom_path
        else:
            if rom_path is None:
                raise ValueError('需要 .nes 文件路径')
            self.rom = INes(rom_path)
        self.mapper = make_mapper(self.rom)
        self.ppu = PPU(self.mapper)
        self.apu = APU()
        self.bus = NESBus(self)
        self.apu.dmc.read_mem = self.bus.read     # DMC 从 CPU 地址空间取样本
        self.cpu = CPU6502(self.bus)
        self.apu_cycles = 0                       # 攒到帧末一次性推帧序列器
        self.samples_per_frame = APU_SR // 60     # 44100/60 = 735
        self.audio = None                         # run_frame(audio=True) 时写入

        self.buttons = [0, 0]
        self.strobe = False
        self.shift_reg = [0, 0]

        self.cycles = 0
        self.frame = 0
        self.reset()

    # ---------------- 复位 ----------------
    def reset(self):
        self.mapper = make_mapper(self.rom)
        self.mapper.reset()
        self.ppu = PPU(self.mapper)
        self.bus.mapper = self.mapper            # Bus 缓存了 mapper，重建后必须同步
        vec = self.rom.vector('RESET')
        self.cpu = CPU6502(self.bus, pc=vec)
        self.cpu.sp = 0xFD
        self.cpu.p = 0x24
        self.cycles = 0
        self.frame = 0

    # ---------------- 手柄 ----------------
    def write_strobe(self, val):
        """$4016 写 1 → 持续锁存；1→0 下降沿装载按键快照。"""
        new = bool(val & 1)
        if self.strobe and not new:
            self.shift_reg = [self.buttons[0], self.buttons[1]]
        self.strobe = new

    def read_controller(self, n):
        """标准位序：A,B,Select,Start,Up,Down,Left,Right（A 最先输出）。"""
        if n > 1:
            return 0x40
        if self.strobe:
            return 0x40 | (self.buttons[n] & 1)
        v = self.shift_reg[n] & 1
        self.shift_reg[n] = (self.shift_reg[n] >> 1) | 0x80
        return 0x40 | v

    def set_buttons(self, mask, player=0):
        self.buttons[player] = mask & 0xFF

    # ---------------- 执行 ----------------
    def step_cpu(self):
        if self.ppu.nmi_pending:
            self.ppu.nmi_pending = False
            self.cpu.nmi()
        elif self.mapper.irq_pending:
            self.mapper.irq_pending = False
            self.cpu.irq()
        cyc = self.cpu.step()
        self.cycles += cyc
        self.apu_cycles += cyc
        self._ppu_advance(cyc * 3)
        return cyc

    def _ppu_advance(self, dots):
        p = self.ppu
        m = self.mapper
        irq = m.has_irq
        while dots > 0:
            step = 341 - p.dot
            if step > dots:
                p.dot += dots
                return
            dots -= step
            p.dot = 0
            sl = p.scanline
            if sl < 240:
                if irq and (p.mask & 0x18):
                    m.clock_irq()          # 近似 A12 上升沿：每条可见行一次
                p.render_scanline(sl)
                # 真机每次取图都会让 v 自增 1 行并重载水平位；只要这一帧
                # 开过渲染，v 就必须跟着走，否则游戏预置的 v 会和实际扫描线错位。
                p.end_line()
                p.rendered_lines += 1
            elif p.rendered_lines:
                # 可见行阶段开过渲染 → v 已是“活”的，垂直空白期也要推进
                # （游戏在这段靠 v 连续写 CHR/名字表，v 停住会让进关后顶部留黑带）。
                p.end_line()
            sl += 1
            if sl == 241:
                p.status |= 0x80
                if p.ctrl & 0x80:
                    p.nmi_pending = True
            elif sl == 261:
                p.status &= ~0xE0
                p.sprite0_hit = False
                # 整帧关渲染时 v 必须原样保留（否则大块上传会错位）；
                # 开过渲染则按 t 回卷到帧首。
                if p.mask & 0x18 or p.rendered_lines:
                    p.start_frame()
                p.rendered_lines = 0
            elif sl >= 262:
                sl = 0
                p.frame += 1
            p.scanline = sl

    def run_frame(self, audio=False):
        """跑到 PPU 帧计数 +1。

        audio=True 时同时渲染这一帧的音频采样（735 个），存进 self.audio。
        帧序列器用“整帧一次推进”，和 play_sound.py 的做法一致。
        """
        target = self.ppu.frame + 1
        guard = 0
        while self.ppu.frame != target:
            self.step_cpu()
            guard += 1
            if guard > 4_000_000:
                raise RuntimeError('一帧跑了 %d 条指令还没结束（CPU 卡死？PC=$%04X）'
                                   % (guard, self.cpu.pc))
        self.frame += 1
        if self.apu_cycles:
            self.apu._clock_frame(self.apu_cycles)
            self.apu_cycles = 0
        if audio:
            self.audio = self.apu.render(self.samples_per_frame, clock_frame=False)
        return self.ppu.framebuffer

    # ---------------- 信息 ----------------
    def info(self):
        return self.rom.describe()


def main(argv=None):
    """命令行：python nes.py <rom.nes> [帧数] —— 跑几帧并打印信息（自检用）。"""
    argv = list(sys.argv[1:] if argv is None else argv)
    if not argv:
        print('用法: python nes.py <rom.nes> [帧数]')
        print('已支持 mapper: %s' % ', '.join(
            '%d=%s' % kv for kv in supported().items()))
        return 1
    emu = NES(argv[0])
    print(emu.info())
    frames = int(argv[1]) if len(argv) > 1 else 60
    for _ in range(frames):
        emu.run_frame()
    print('跑了 %d 帧，PC=$%04X，framebuffer %d 字节'
          % (frames, emu.cpu.pc, len(emu.ppu.framebuffer)))
    return 0


if __name__ == '__main__':
    sys.exit(main())
