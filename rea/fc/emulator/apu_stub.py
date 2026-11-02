"""轻量 APU 桩 —— 让 NES 主机能跑起来（画面/玩法优先）。

只做三件事：
  * 记录 $4000-$4017 的写入（不生成声音）
  * $4015 状态读回
  * 提供 step(cycles) 空实现，保持接口一致

音频另有 `tools/apu.py`（音序引擎解码 + 合成）与 `sound/*.wav`，
那是离线导出用的；运行时若要发声可接 pygame 播放这些 WAV。
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)


class APU:
    def __init__(self):
        self.regs = bytearray(0x18)     # $4000-$4017
        self.status = 0x0F
        self.frame_irq = False
        self.cycles = 0

    def write(self, addr, val):
        a = addr - 0x4000
        if 0 <= a < 0x18:
            self.regs[a] = val & 0xFF
            if addr == 0x4015:
                self.status = val & 0x0F
            elif addr == 0x4017:
                pass

    def read_status(self):
        r = self.status
        self.status &= ~0x80
        return r

    def step(self, cycles):
        self.cycles += cycles

    # 供调试：当前各通道的频率字
    def channel_periods(self):
        def p(lo, hi):
            return ((self.regs[hi] & 7) << 8) | self.regs[lo]
        return [p(0x02, 0x03), p(0x06, 0x07), p(0x0A, 0x0B)]
