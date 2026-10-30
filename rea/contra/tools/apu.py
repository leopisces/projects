"""NES 2A03 APU 渲染（够用来还原 contra 的声音引擎输出）。

对应 ROM 侧：bank 1 的驱动只会写这几个寄存器（已核对 bank1 反汇编 $8000-$8AFF）：
    $4000/$4004/$400C  duty+包络（值来自 $014E,X | 音量）
    $4001/$4005        扫频（只在初始化/静音时写 $7F）
    $4002/$4003        脉冲 1 周期（低 8 位 / 高 3 位）
    $4006/$4007        脉冲 2 周期
    $4008              三角线性计数（线性计数器重载）
    $400A/$400B        三角周期
    $400E/$400F        噪声周期（经 X=寄存器偏移 的 STA $4002,X 到达）
    $4010-$4013        DMC（只用于 id>=$7F 的打击乐路径）
    $4015              APU 状态/使能

实现内容：
  * 脉冲 4 种 duty（12.5/25/50/75%）、硬件包络（常量/衰减）、长度计数器；
  * 三角 32 级阶梯、线性计数器；
  * 噪声 LFSR（短模式 93 位 / 长模式 32767 位）；
  * 帧序列器 4-step（240Hz 四分 / 120Hz 半帧）；
  * NESdev 的非线性混音公式。
已知简化（⚠️ 非精确仿真）：
  * sweep 单元只实现"静音判定用不上"的近似——直接忽略，因此 id 里若靠 sweep
    做快速滑音，音高会偏；contra 的驱动 $8000-$8AFF 从不写 $4001/$4005（只有
    $7F 静音），所以对本次导出无影响。
  * 合成用"浮点相位 + 每采样一次的定时器步进"，不是 1.79MHz 逐周期仿真；
    对 44.1kHz 输出足够，且避免了 157M 次 Python 循环。
"""
import math
import wave

import numpy as np

CPU_HZ = 1789773.0
SR = 44100

# 长度计数器表（$4003 高 5 位 -> 长度）
LENGTH_TABLE = [10, 254, 20, 2, 40, 4, 80, 6, 160, 8, 60, 10, 14, 12, 26, 14,
                12, 16, 24, 18, 48, 20, 96, 22, 192, 24, 72, 26, 16, 28, 32, 30]

# 噪声周期表（NTSC）
NOISE_PERIODS = [4, 8, 16, 32, 64, 96, 128, 160, 202, 254, 380, 508, 762, 1016,
                 2034, 4068]

DUTY = [
    [0, 1, 0, 0, 0, 0, 0, 0],  # 12.5%
    [0, 1, 1, 0, 0, 0, 0, 0],  # 25%
    [0, 1, 1, 1, 1, 0, 0, 0],  # 50%
    [1, 0, 0, 1, 1, 1, 1, 1],  # 75%
]

# 帧序列器（4-step）在 APU 周期上的步进点：CPU cycle 7457/14913/22371/29829
FRAME_STEPS = [7457, 14913, 22371, 29829]


def note_name_from_period(period, is_triangle=False):
    """NES 定时器值 -> 最近音名。脉冲：f = CPU/(16*(t+1))；三角：CPU/(32*(t+1))。"""
    if period <= 0:
        return None, 0.0
    div = 32.0 if is_triangle else 16.0
    f = CPU_HZ / (div * (period + 1))
    if f <= 0:
        return None, 0.0
    n = int(round(69 + 12 * math.log2(f / 440.0)))
    names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
    return '%s%d' % (names[n % 12], n // 12 - 1), f


class Envelope:
    def __init__(self):
        self.start = False
        self.divider = 0
        self.decay = 0

    def clock(self, loop, constant, period):
        if self.start:
            self.start = False
            self.decay = 15
            self.divider = period
            return
        if self.divider == 0:
            self.divider = period
            if self.decay > 0:
                self.decay -= 1
            elif loop:
                self.decay = 15
        else:
            self.divider -= 1

    def volume(self, constant, period):
        return period if constant else self.decay


class Pulse:
    def __init__(self):
        self.enabled = False
        self.duty = 0
        self.halt = False
        self.const_vol = False
        self.vol_period = 0
        self.timer = 0
        self.length = 0
        self.env = Envelope()
        self.phase = 0.0

    def write0(self, v):
        self.duty = (v >> 6) & 3
        self.halt = bool(v & 0x20)
        self.const_vol = bool(v & 0x10)
        self.vol_period = v & 0x0F
        self.env.start = True

    def write2(self, v):
        self.timer = (self.timer & 0x700) | v

    def write3(self, v):
        self.timer = (self.timer & 0xFF) | ((v & 7) << 8)
        if self.enabled:
            self.length = LENGTH_TABLE[v >> 3]
        self.env.start = True

    def clock_length(self):
        if not self.halt and self.length > 0:
            self.length -= 1

    def clock_env(self):
        self.env.clock(self.halt, self.const_vol, self.vol_period)

    def freq(self):
        return CPU_HZ / (16.0 * (self.timer + 1))

    def sample(self, dt):
        if (not self.enabled) or self.length == 0 or self.timer < 8:
            return 0
        v = self.env.volume(self.const_vol, self.vol_period)
        # 8 步序列 -> 占空比
        step = int(self.phase * 8)
        self.phase += self.freq() * dt
        self.phase -= math.floor(self.phase)
        return v if DUTY[self.duty][step & 7] else 0


class Triangle:
    def __init__(self):
        self.enabled = False
        self.control = False          # $4008 bit7：halt（同时是线性计数器重载）
        self.linear_reload = 0
        self.linear = 0
        self.timer = 0
        self.length = 0
        self.phase = 0.0

    def write0(self, v):
        self.control = bool(v & 0x80)
        self.linear_reload = v & 0x7F

    def write2(self, v):
        self.timer = (self.timer & 0x700) | v

    def write3(self, v):
        self.timer = (self.timer & 0xFF) | ((v & 7) << 8)
        if self.enabled:
            self.length = LENGTH_TABLE[v >> 3]

    def clock_length(self):
        if not self.control and self.length > 0:
            self.length -= 1

    def clock_linear(self):
        if self.control:
            self.linear = self.linear_reload
        elif self.linear > 0:
            self.linear -= 1

    def freq(self):
        return CPU_HZ / (32.0 * (self.timer + 1))

    def sample(self, dt):
        if (not self.enabled) or self.length == 0 or self.timer < 2 or self.linear == 0:
            return 0
        step = int(self.phase * 32) & 31
        self.phase += self.freq() * dt
        self.phase -= math.floor(self.phase)
        # 三角波形：0..15..0
        return 15 - abs(step - 15)


class Noise:
    def __init__(self):
        self.enabled = False
        self.halt = False
        self.const_vol = False
        self.vol_period = 0
        self.mode = False
        self.period_idx = 0
        self.length = 0
        self.env = Envelope()
        self.lfsr = 1
        self.acc = 0.0

    def write0(self, v):
        self.halt = bool(v & 0x20)
        self.const_vol = bool(v & 0x10)
        self.vol_period = v & 0x0F
        self.env.start = True

    def write2(self, v):
        self.mode = bool(v & 0x80)
        self.period_idx = v & 0x0F

    def write3(self, v):
        if self.enabled:
            self.length = LENGTH_TABLE[v >> 3]
        self.env.start = True

    def clock_length(self):
        if not self.halt and self.length > 0:
            self.length -= 1

    def clock_env(self):
        self.env.clock(self.halt, self.const_vol, self.vol_period)

    def sample(self, dt):
        if (not self.enabled) or self.length == 0:
            return 0
        per = NOISE_PERIODS[self.period_idx]
        self.acc += CPU_HZ / per * dt
        n = int(self.acc)
        self.acc -= n
        for _ in range(min(n, 64)):
            fb = (self.lfsr & 1) ^ ((self.lfsr >> (6 if self.mode else 1)) & 1)
            self.lfsr = (self.lfsr >> 1) | (fb << 14)
        v = self.env.volume(self.const_vol, self.vol_period)
        return 0 if (self.lfsr & 1) else v


class DMC:
    """最小 DMC：只按 $4010-$4013 直接输出 7 位采样，供 id>=$7F 的打击乐用。"""

    RATE_TABLE = [428, 380, 340, 320, 286, 254, 226, 214, 190, 160, 142, 128,
                  106, 84, 72, 54]

    def __init__(self, read_mem):
        self.read_mem = read_mem
        self.enabled = False
        self.irq = False
        self.loop = False
        self.rate_idx = 0
        self.level = 0
        self.addr = 0xC000
        self.length = 0
        self.remaining = 0
        self.cur = 0
        self.bits = 0
        self.shift = 0
        self.acc = 0.0

    def write0(self, v):
        self.irq = bool(v & 0x80)
        self.loop = bool(v & 0x40)
        self.rate_idx = v & 0x0F

    def write1(self, v):
        self.level = v & 0x7F

    def write2(self, v):
        self.addr = 0xC000 | (v << 6)
        self._start_addr = self.addr

    def write3(self, v):
        self.length = (v << 4) | 1
        self.remaining = self.length

    def restart(self):
        self.remaining = self.length
        self.addr = getattr(self, '_start_addr', self.addr)

    def sample(self, dt):
        if not self.enabled:
            return 0
        rate = self.RATE_TABLE[self.rate_idx]
        self.acc += CPU_HZ / rate * dt
        n = int(self.acc)
        self.acc -= n
        for _ in range(min(n, 256)):
            if self.bits == 0:
                if self.remaining == 0:
                    if self.loop:
                        self.remaining = self.length
                    else:
                        break
                self.cur = self.read_mem(self.addr)
                self.addr = 0xC000 | ((self.addr + 1) & 0x3FFF)
                self.remaining -= 1
                self.bits = 8
            if self.cur & 1:
                if self.level <= 125:
                    self.level += 2
            else:
                if self.level >= 2:
                    self.level -= 2
            self.cur >>= 1
            self.bits -= 1
        return self.level


class APU:
    def __init__(self, read_mem=None):
        self.p1 = Pulse()
        self.p2 = Pulse()
        self.tri = Triangle()
        self.noi = Noise()
        self.dmc = DMC(read_mem or (lambda a: 0))
        self.frame_cycle = 0      # 累计 CPU 周期（用浮点，避免丢精度）
        self.frame_step = 0
        self.frame_mode5 = False
        self.regs = [0] * 0x18    # $4000-$4017 的镜像（供自检）

    # ---- 寄存器写 ----
    def write(self, addr, v):
        v &= 0xFF
        if 0x4000 <= addr <= 0x4017:
            self.regs[addr - 0x4000] = v
        if addr == 0x4015:
            self.p1.enabled = bool(v & 0x01)
            self.p2.enabled = bool(v & 0x02)
            self.tri.enabled = bool(v & 0x04)
            self.noi.enabled = bool(v & 0x08)
            self.dmc.enabled = bool(v & 0x10)
            if not self.p1.enabled:
                self.p1.length = 0
            if not self.p2.enabled:
                self.p2.length = 0
            if not self.tri.enabled:
                self.tri.length = 0
            if not self.noi.enabled:
                self.noi.length = 0
            if self.dmc.enabled and self.dmc.remaining == 0:
                self.dmc.restart()
            return
        if addr == 0x4017:
            self.frame_mode5 = bool(v & 0x80)
            self.frame_cycle = 0.0
            self.frame_step = 0
            return
        ch = addr & 0x1F
        if ch < 0x04:
            p = self.p1
            if ch == 0:
                p.write0(v)
            elif ch == 2:
                p.write2(v)
            elif ch == 3:
                p.write3(v)
            return
        if ch < 0x08:
            p = self.p2
            if ch == 4:
                p.write0(v)
            elif ch == 6:
                p.write2(v)
            elif ch == 7:
                p.write3(v)
            return
        if ch < 0x0C:
            if ch == 0x08:
                self.tri.write0(v)
            elif ch == 0x0A:
                self.tri.write2(v)
            elif ch == 0x0B:
                self.tri.write3(v)
            return
        if ch < 0x10:
            if ch == 0x0C:
                self.noi.write0(v)
            elif ch == 0x0E:
                self.noi.write2(v)
            elif ch == 0x0F:
                self.noi.write3(v)
            return
        # $4010-$4013 DMC
        if ch == 0x10:
            self.dmc.write0(v)
        elif ch == 0x11:
            self.dmc.write1(v)
        elif ch == 0x12:
            self.dmc.write2(v)
        elif ch == 0x13:
            self.dmc.write3(v)

    # ---- 帧序列器 ----
    def _clock_frame(self, cycles):
        self.frame_cycle += cycles
        pts = FRAME_STEPS
        while self.frame_step < 4 and self.frame_cycle >= pts[self.frame_step]:
            self._frame_event(self.frame_step)
            self.frame_step += 1
        if self.frame_step >= 4:
            self.frame_step = 0
            self.frame_cycle -= pts[-1]

    def _frame_event(self, step):
        if step == 0 or step == 2:
            self.p1.clock_env(); self.p2.clock_env(); self.noi.clock_env()
        if step == 1 or step == 3:
            self.p1.clock_env(); self.p2.clock_env(); self.noi.clock_env()
            self.p1.clock_length(); self.p2.clock_length()
            self.tri.clock_length(); self.noi.clock_length()
            self.tri.clock_linear()

    # ---- 渲染 ----
    def render(self, nsamples, collect=None, clock_frame=True):
        """渲染 nsamples 个采样。

        clock_frame=False 时由调用方自己按 CPU 周期调用 _clock_frame
        （play_sound 每帧跑完 tick 后统一推一次，避免帧序列器相位漂移）。
        """
        dt = 1.0 / SR
        cyc_per_sample = CPU_HZ / SR
        out = np.zeros(nsamples, dtype=np.float32)
        lp = self.dmc.level / 127.0
        for i in range(nsamples):
            if clock_frame:
                self._clock_frame(cyc_per_sample)
            p1 = self.p1.sample(dt)
            p2 = self.p2.sample(dt)
            tr = self.tri.sample(dt)
            no = self.noi.sample(dt)
            dm = self.dmc.sample(dt)
            pulse_sum = p1 + p2
            if pulse_sum > 0:
                pulse_out = 95.88 / (8128.0 / pulse_sum + 100.0)
            else:
                pulse_out = 0.0
            tnd = tr / 8227.0 + no / 12241.0 + dm / 22638.0
            tnd_out = 159.79 / (1.0 / tnd + 100.0) if tnd > 0 else 0.0
            out[i] = pulse_out + tnd_out
            if collect is not None:
                collect.append((p1, p2, tr, no, dm))
        return out


def write_wav(path, samples, sr=SR):
    """16-bit 单声道 WAV。samples 是 [-1,1] 的 float。"""
    x = np.clip(samples, -1.0, 1.0)
    pcm = np.round(x * 32767.0).astype('<i2')
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sr)
        w.writeframes(pcm.tobytes())
    return len(pcm)


def dc_block(x):
    """简单的 DC 高通（一阶），去掉非线性混音带来的直流偏置。"""
    if len(x) == 0:
        return x
    a = 0.995
    y = np.empty_like(x)
    prev_x = 0.0
    prev_y = 0.0
    for i in range(len(x)):
        y[i] = x[i] - prev_x + a * prev_y
        prev_x = x[i]
        prev_y = y[i]
    return y
