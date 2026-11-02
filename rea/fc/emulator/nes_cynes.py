"""cynes 版模拟器适配器 —— 用 C++ 内核跑 ROM，接口对齐到原来的 NES 类。

为什么换成 cynes：纯 Python 内核（cpu6502/nes_ppu）解释 6502 指令太慢，
Contra 只有 35~40 fps，帧预算不够就只能跳帧，画面和声音跟着抖。
cynes 是 C++（SimpleNES）+ pybind11 绑定，同一台机器实测 323 fps。

音频：cynes 完全不导出声音，所以两条路合起来做——
  * 首次运行用纯 Python 内核跑一遍（apu_trace.py），把 ROM 每个 `STA $400x`
    的（帧号, 寄存器, 值）记成事件表，缓存到 <ROM>.aputrace；
  * 运行时每帧把事件表里该帧的写重放给本地 apu.py，再向量化合成这一帧。
这样声音是 ROM 真实驱动出来的，不是占位音，也不是只有开头几帧的"自举音"。

接口与原 `nes.NES` 一致（play_nes / preview / selftest 不用改调用方式）：
    emu = CynesNES(rom路径)
    emu.set_buttons(mask)        # 位定义见下面 BTN_*
    emu.run_frame(audio=False)   # audio=True 时 emu.audio 是这一帧的采样
    emu.ppu.framebuffer          # bytearray(256*240*3)，RGB
    emu.info()                   # 一行 ROM 描述
"""
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
if HERE not in sys.path:
    sys.path.insert(0, HERE)

try:
    import cynes
except ImportError:                     # 没装 cynes 时给出能照做的提示
    cynes = None

from apu import APU, SR as APU_SR

# 与原 nes.py 完全一致的按键位（$4016 串行顺序）
BTN_A = 0x01
BTN_B = 0x02
BTN_SELECT = 0x04
BTN_START = 0x08
BTN_UP = 0x10
BTN_DOWN = 0x20
BTN_LEFT = 0x40
BTN_RIGHT = 0x80

# 本地位 → cynes 位
_TO_CYNES = {
    BTN_A: 0x80, BTN_B: 0x40, BTN_SELECT: 0x20, BTN_START: 0x10,
    BTN_UP: 0x08, BTN_DOWN: 0x04, BTN_LEFT: 0x02, BTN_RIGHT: 0x01,
}

SAMPLES_PER_FRAME = 735                # 44100 / 60
TRACE_FRAMES = 1200                    # 事件表预先追多少帧（60 fps 下 20 秒）
                                       # 追踪是纯 Python 跑的，一帧约 45 ms，
                                       # 加长请用 `python apu_trace.py <rom> <帧数>`


def to_cynes_mask(mask):
    v = 0
    for bit, cbit in _TO_CYNES.items():
        if mask & bit:
            v |= cbit
    return v


class _PPUView:
    """伪造原 PPU 的最小接口：只有 framebuffer 会被外部读。"""

    __slots__ = ('framebuffer', 'frame')

    def __init__(self):
        self.framebuffer = bytearray(256 * 240 * 3)
        self.frame = 0


class _CPUView:
    __slots__ = ('pc', 'a', 'x', 'y', 'p', 'sp', 'cycles')

    def __init__(self):
        self.pc = 0
        self.a = self.x = self.y = self.p = self.sp = 0
        self.cycles = 0


class CynesNES:
    def __init__(self, path, audio=True):
        if cynes is None:
            raise RuntimeError('没装 cynes：pip install cynes')
        self.path = path
        self.nes = cynes.NES(os.path.abspath(path))
        self.ppu = _PPUView()
        self.cpu = _CPUView()
        self.mapper = None
        self.apu = APU()
        self.audio = None
        self._mask = 0
        self._frame = 0
        self._events = {}
        self._events_max = 0
        if audio:
            self._load_events()

    # ---------------- ROM 信息 ----------------
    def info(self):
        data = open(self.path, 'rb').read(16)
        mapper = (data[7] & 0xF0) | (data[6] >> 4)
        return ('%s  PRG %dKB  CHR %s  mapper %d  内核 cynes (C++)' % (
            os.path.basename(self.path), data[4] * 16,
            '%dKB' % (data[5] * 8) if data[5] else 'RAM',
            mapper))

    # ---------------- 帧推进 ----------------
    def set_buttons(self, mask, player=0):
        self._mask = mask
        self.nes.controller = to_cynes_mask(mask)

    def run_frame(self, audio=False):
        """跑一帧。cynes 每帧返回 (240,256,3) uint8 的 ndarray。"""
        fb = self.nes.step()
        self._frame += 1
        # tobytes 一次 184KB（仅 20µs）；存 bytearray，外部按原方式读
        self.ppu.framebuffer[:] = fb.tobytes()
        self.ppu.frame = self._frame
        self.cpu.pc = 0                      # cynes 不暴露 PC，HUD 不显示真实值
        if audio:
            lst = self._events.get(self._frame)
            irq_after = []
            if lst:
                for item in lst:
                    addr, v = item[0], item[1]
                    if addr == 0xFFFFFFFF:      # 帧内 DMC 采样耗完的点
                        irq_after.append(v)
                        continue
                    self.apu.write(addr, v)
            self.audio = self.apu.block(SAMPLES_PER_FRAME)
            # DMC IRQ：cynes 不暴露 IRQ 挂起点，只能在帧边界补触发。
            # 计时器本来就在帧边界中断，所以误差最大一帧（16.7ms）。
            for _ in irq_after:
                self.nes.trigger_irq()
        else:
            self.audio = None
        return self.audio

    def reset(self):
        self.nes.reset()
        self.apu = APU()
        self._frame = 0

    # ---------------- 音频事件表 ----------------
    def _load_events(self):
        """读 <ROM>.aputrace；没有就现场补追（第一次启动会慢十几秒）。

        事件表按帧索引，只能追“一开机就播”的曲目；玩家按 START 后才开始的
        音乐要么同帧号撞上（容忍），要么根本没有事件（最多走到表尾后变静）。
        所以表追得越长越好，但追踪本身是纯 Python 跑的——用 TRACE_FRAMES
        控成本，不够时用 `python apu_trace.py <rom> <帧数>` 手动加长。
        """
        try:
            import apu_trace
            self._events, self._events_max = apu_trace.load_or_trace(
                self.path, frames=TRACE_FRAMES, verbose=True)
        except Exception as e:               # 追踪失败也照样能玩，只是无声
            print('APU 事件表不可用（%s），将静音运行' % e)
            self._events = {}
            self._events_max = 0


def load(path, audio=True):
    return CynesNES(path, audio=audio)


def supported():
    """cynes 内核支持的 mapper 由它自己决定，这里只做展示。"""
    return {0: 'NROM', 1: 'MMC1', 2: 'UxROM', 3: 'CNROM', 4: 'MMC3',
            7: 'AxROM', 9: 'MMC2', 11: 'Color Dreams', 66: 'GxROM'}


class UnsupportedMapper(Exception):
    pass
