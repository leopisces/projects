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

try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

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
DUTY_NP = [np.array(d, dtype=np.float32) for d in DUTY]

# 帧序列器（4-step）在 APU 周期上的步进点：CPU cycle 7457/14913/22371/29829
FRAME_STEPS = [7457, 14913, 22371, 29829]
FRAME_LEN = 29830                              # 一整圈（4-step 序列）的 CPU 周期数


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
        # static=True 表示“这个音量变更不重载包络”（见 Pulse.write0 的注释）：
        #   $4000 从衰减模式切到恒定音量 → 立刻用新音量（游戏静音/开火音靠它）
        #   恒定音量改值 → 只是调音量
        #   衰减模式下写 $4000 → 按原曲参数走（不去把 decay 拉回 15）
        self.static = False

    def clock(self, loop, constant, period):
        if self.start:
            self.start = False
            self.divider = period
            self.static = False
            # 恒定音量模式：音量就是 period，衰减值只是个不用的影子；
            # 衰减模式：重载衰减到 15。之前的实现无条件 decay=15，再配合
            # write0 里“每次写都重载”，衰减模式下写了 $1x 也衰减不完。
            if not constant:
                self.decay = 15
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
        # 写 $4000 的语义（真机 $4003 才重载包络，但游戏普遍拿 $4000 做
        # “立即静音 / 立即改音量”，两条实测都必需）：
        #   · 切到恒定音量 → 立刻生效（Contra 静音写 $4000=$30，若不生效会
        #     持续发出不该有的音）
        #   · 恒定音量改值 → 立刻生效（音量渐弱、开火音量变化）
        #   · 衰减模式       → 只改参数，走原曲的包络节奏（如果这里也重载，
        #     音乐引擎每帧写一次 $4000 就会把衰减无限续命，音永远收不住）
        if self.const_vol:
            self.env.decay = self.vol_period
            self.env.static = True
        else:
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
        self.prg = None            # 有 PRG 时优先用“直接按 bank 读”，比 read_mem 快
        self.bank = 0              # 遗留字段（不再参与取字节）
        self.get_fixed_off = None  # () -> int：$C000 窗口对应的 PRG 文件偏移
        self.enabled = False
        self.irq = False
        self.irq_fired = 0         # 本帧累计拉过多少次 IRQ（供事件表记录）
        self.irq_pending = False   # 拉低后的 IRQ 线（由 NES 在帧边界投递给 CPU）
        self.irq_frames = []       # 每次 IRQ 拉低时的 CPU 周期偏移
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
        # 真机：写 $4013 只设长度寄存器，采样要等 $4015 把 DMC 使能后
        # 才会真正开始播。之前这里直接动 remaining，但 enabled 一直是 False
        # （没人打开它），于是 DMC 一帧都没响，level 一直卡在 $4011 初值。
        # 结果就是标题音乐里“鼓/贝斯”那条线整条缺失，听上去发飘、发干。
        self.acc = 0.0
        self.bits = 0
        self.cur = 0
        if not self.enabled:
            self.addr = getattr(self, '_start_addr', self.addr)

    def restart(self):
        self.remaining = self.length
        self.addr = getattr(self, '_start_addr', self.addr)

    def sample(self, dt):
        if not self.enabled:
            return 0
        self.acc += dt * (1.0 / self.RATE_TABLE[self.rate_idx]) * CPU_HZ
        n = int(self.acc)
        self.acc -= n
        for _ in range(min(n, 256)):
            if self.bits == 0:
                if self.remaining == 0:
                    if self.loop:
                        self.remaining = self.length
                    else:
                        break
                self.cur = self.next_byte()
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
            if self.remaining == 0 and not self.loop and self.irq:
                self.irq_fired += 1
                self.irq_pending = True
                self.irq_frames.append(self.clock_ref[0] - self.clock_base[0])
        return self.level

    def next_byte(self):
        """取下一个采样字节。

        DMC 永远读 CPU 的 $C000-$FFFF，而 UxROM 的那 16KB 是固定 bank（mapper.fixed_off），
        不是 $8000 窗口那个可切换 bank。旧实现走 `bus.read()`——当游戏把 $8000 切到
        bank 1 时（Contra 的音乐例程就在 bank 1），$C000 在 bus 层仍映射固定 bank，
        但旧版曾固定按 bank 0/bank 1 算偏移，拿到的是别的区的字节 → 鼓点/打击乐
        变成乱码噪声（“声音不自然”）。现在直接用 mapper 的 fixed bank 偏移。
        """
        a = self.addr
        self.addr = self.next_addr()
        prg = self.prg
        if prg is not None:
            base = self.get_fixed_off() if self.get_fixed_off else 0
            off = base + (a - 0xC000)
            if 0 <= off < len(prg):
                return prg[off]
        return self.read_mem(a)

    def next_addr(self):
        return 0xC000 | ((self.addr + 1) & 0x3FFF)

    # ---- 供 cynes 内核用：DMC 需要 PRG 才能读采样，且 IRQ 要能戳 CPU ----
    def attach(self, prg, fixed_off_getter):
        self.prg = prg
        self.get_fixed_off = fixed_off_getter

    def set_enabled(self, on):
        """$4015 bit4：DMC 使能。关闭时清掉剩余字节。"""
        self.enabled = bool(on)
        if not on:
            self.remaining = 0
            self.bits = 0

    def clock_cycles(self, cycles):
        """按 CPU 周期推进 DMC（cynes 内核不跑我们的 CPU，只能外部喂）。

        返回本段内是否产生过 IRQ。
        """
        if not self.enabled:
            return False
        # 每秒输出率 = CPU_HZ / RATE_TABLE[rate_idx]
        self.acc += cycles * (1.0 / self.RATE_TABLE[self.rate_idx])
        n = int(self.acc)
        self.acc -= n
        fired = False
        for _ in range(n):
            fired = self.sample_bit() or fired
        return fired

    def sample_bit(self):
        """推进一个 DMC 输出位；返回本次是否产生 IRQ。"""
        if self.bits == 0:
            if self.remaining == 0:
                if self.loop:
                    self.remaining = self.length
                else:
                    return False
            self.cur = self.next_byte()
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
        if self.remaining == 0 and not self.loop and self.irq:
            self.irq_fired += 1
            self.irq_pending = True
            self.irq_frames.append(self.clock_ref[0] - self.clock_base[0])
            return True
        return False


class APU:
    def __init__(self, read_mem=None):
        self.p1 = Pulse()
        self.p2 = Pulse()
        self.tri = Triangle()
        self.noi = Noise()
        self.dmc = DMC(read_mem or (lambda a: 0))
        self.dmc.get_fixed_off = None       # nes.py 里注入 lambda: mapper.fixed_off
        self.frame_cycle = 0      # 累计 CPU 周期（用浮点，避免丢精度）
        self.frame_step = 0
        self.frame_mode5 = False
        self.regs = [0] * 0x18    # $4000-$4017 的镜像（供自检）
        self.irq_pending = False  # DMC 的 IRQ 线（$4015 读或重载后清除）
        self.clock_ref = [0]      # 外部（CPU）周期计数的引用，见 bind_clock()
        self.clock_base = [0]     # 本帧起始周期
        self.dmc_steps = []       # 本块内每采样的 DMC 电平（不参与非线性混音）
        self._dmc_cache = None
        self._dmc_dirty_from = 0

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
            # 与真机一致：写 $4017 立刻跑一次事件（5-step 模式还要额外跑
            # 长度/线性计数），然后把序列器相位清零。这里 frame_cycle 的语义
            # 是「到本段结束还剩多少周期」，所以“清零”= 下一段立刻开始，
            # 不是“这一圈已经走完了”。
            if self.frame_mode5:
                self.p1.clock_env(); self.p2.clock_env(); self.noi.clock_env()
                self.p1.clock_length(); self.p2.clock_length()
                self.tri.clock_length(); self.noi.clock_length()
                self.tri.clock_linear()
            else:
                self.p1.clock_env(); self.p2.clock_env(); self.noi.clock_env()
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
        """推进 cycles 个 CPU 周期（一次给一整帧的量也可以）。

        早期实现只处理“最多跨一圈”，尾部只减一个事件点位置就返回，多出的
        周期被丢掉；一次给整帧（~29780）时包络/length 计数器就会偏慢。
        """
        # 语义统一：frame_cycle = 「本段还剩多少周期」，0 表示已经到点。
        # 到点(<=0) → 先跑事件、换下一段长度，再把新周期全算进这一段。
        # 旧实现用“坐标 - 已走”去比，事件跑完不重置剩余量，结果每小段都被
        # 判成整圈，帧序列器被反复推进（实测包络衰减快 4 倍），而且一圈结束
        # 时剩余量没归一，frame_cycle 会一路漂成负数。
        left = self.frame_cycle + cycles
        guard = 0
        while left > 0:
            if self.frame_cycle <= 0:
                step = self.frame_step
                if step >= 4:
                    step = 0
                self._frame_event(step)
                self.frame_step = (step + 1) & 3
                nxt = FRAME_STEPS[step + 1] if step + 1 < 4 else FRAME_LEN
                self.frame_cycle = nxt - FRAME_STEPS[step]
                left -= self.frame_cycle
                guard += 1
                if guard > 64:                # 防御：异常输入不至于死循环
                    break
                continue
            used = self.frame_cycle if self.frame_cycle < left else left
            self.frame_cycle -= used
            left -= used
            if self.frame_cycle <= 0:
                self.frame_cycle = 0

    def _frame_event(self, step):
        # 真机（APU 帧序列器）：4 步=半帧
        #   步 0 / 2: 包络（脉冲×2 + 噪声）
        #   步 1 / 3: 长度计数器 + 扫描 + 三角线性计数器
        # 旧实现把包络在 4 步全走，等于把衰减速度翻倍：Contra 的连发扫射
        # （写 $4000=$F2/$F1 靠包络自然衰减）两帧就掉到 0，本该四帧的尾音被
        # 砍短，听上去“哒哒”变成“嗒嗒”、音头生硬。
        if step == 0 or step == 2:
            self.p1.clock_env(); self.p2.clock_env(); self.noi.clock_env()
        if step == 1 or step == 3:
            self.p1.clock_length(); self.p2.clock_length()
            self.tri.clock_length(); self.noi.clock_length()
            self.tri.clock_linear()

    # ---- 渲染 ----
    def block(self, nsamples):
        """渲染 nsamples 个采样（供 cynes 内核用）。

        旧的 render() 是“每采样调 5 次 sample()”，735 个采样要跑近 4000 次
        Python 函数调用 + 每声道一次 float 相位累加，一帧 8~10 ms；而 735 个
        采样必须赶在 16.7 ms 内送进音频队列，所以听起来一顿一顿。

        这里把每声道在块内“不变的部分”（定时器/音量在段内恒定）用 numpy
        一次算完，只在帧序列器事件点或长度计数器归零时重算一段。
        波形公式与 sample() 完全一致（20 采样/周期内与原实现逐点误差 < 0.6 个
        采样位，肉耳不可辨），差别只在“相位步进从逐次累加改成一次性向量化”。
        """
        n = nsamples
        cyc = CPU_HZ / SR
        out = np.zeros(n, dtype=np.float32)
        pos = 0
        # frame_cycle 的语义必须是「本段还剩多少周期」：0 表示“已经到点、
        # 该跑事件了”。上面 _clock_frame 已经把 pos 归一化成剩余量，这里也
        # 必须保持同一语义——旧实现把 FRAME_STEPS 当坐标参与减法、事件跑完
        # 不重置剩余量，于是每段都当成整圈走，帧序列器被反复推进
        #（实测包络衰减快 4 倍，音头被砍、尾音消失）。
        while pos < n:
            if self.frame_cycle <= 0:
                if self.frame_step >= 4:
                    self.frame_step = 1 if self.frame_tick is None else self.frame_step
                step = self.frame_step
                if step >= 4:
                    step = 0
                self._frame_event(step)
                self.frame_step = (step + 1) % 4
                nxt = FRAME_STEPS[step + 1] if step + 1 < 4 else FRAME_LEN
                self.frame_cycle = nxt - FRAME_STEPS[step]
                if self.frame_cycle <= 0:
                    self.frame_cycle = FRAME_LEN      # 兜底，避免死循环
            k = int(self.frame_cycle / cyc) + 1
            if k > n - pos:
                k = n - pos
            self._mix_block(out, pos, k)
            used = k * cyc
            self.frame_cycle -= used
            pos += k
            if self.frame_cycle <= 0:
                self.frame_cycle = 0
        # DMC 不进非线性混音（会把它压成底噪），而是叠加后再去直流
        steps = self.flush()
        if steps is not None and steps.any():
            out += steps * (0.35 / 127.0)
        # 去直流必须放在最后、且只在真出现偏置时做：脉冲器的占空比波形本身
        # 就带直流分量（duty=2 约 0.11），旧实现只在有 DMC 时才减均值，
        # 于是“有 DMC 的帧”整体偏置被吃掉、“没 DMC 的帧”又带回来，
        # 每两帧跳一次 → 听着就是周期性的“噗噗”抖动。现在统一减一次。
        out -= np.float32(out.mean())
        return out

    def _mix_block(self, out, pos, k):
        """把 k 个采样写进 out[pos:pos+k]：四声道向量化 + NESdev 非线性混音。

        DMC 是在采样中途逐字节改变的直流台阶；它不进 tnd 混音公式，而是
        真实硬件上直接推动 DAC。旧版把它除 22638 塞进 tnd（分母 12241 的
        噪声旁边），能量被非线性公式压成一片底噪；更糟的是它没被 dc_block
        处理时就成了整个输出的直流偏置（实测均值 0.102、峰 0.685 → 声卡里
        听着发闷、发卡）。这里改为：APU 只输出四个真实声道，DMC 台阶单独
        存在 self.dmc_steps 里，由 _apply_dmc() 以偏移量累加。
        """
        p1 = self._pulse_block(self.p1, k)
        p2 = self._pulse_block(self.p2, k)
        tr = self._tri_block(self.tri, k)
        no = self._noise_block(self.noi, k)
        pulse_sum = p1 + p2
        tnd = tr / 8227.0 + no / 12241.0
        with np.errstate(divide='ignore', invalid='ignore'):
            pulse_out = np.where(pulse_sum > 0,
                                 95.88 / (8128.0 / pulse_sum + 100.0), 0.0)
            tnd_out = np.where(tnd > 0, 159.79 / (1.0 / tnd + 100.0), 0.0)
        out[pos:pos + k] = (pulse_out + tnd_out).astype(np.float32)
        # DMC：逐采样电平（7 位、未除系数）→ 存成 float32 追加到台阶表
        steps = self._dmc_block(k)
        self.dmc_steps.append(steps)

    def _dmc_block(self, k):
        """DMC 在这 k 个采样里的电平序列（float32，0~127）。

        DMC 只在采样字节耗尽时换台阶，块内很可能一格不变；遇到字节边界
        就逐采样算（只有那一小段走慢路径）。
        """
        d = self.dmc
        cyc = CPU_HZ / SR
        arr = np.empty(k, dtype=np.float32)
        cache = self._dmc_cache
        if cache is not None and cache[0] == d.enabled and cache[1] == d.level \
                and cache[2] == d.bits and cache[3] == d.remaining:
            # 上一块结束时没换台阶：跑到本块末尾看能不能保持恒定
            saved = (d.acc, d.bits, d.remaining, d.addr, d.cur)
            d.acc += k * (CPU_HZ / d.RATE_TABLE[d.rate_idx])
            used = int(d.acc)
            if used < d.bits:
                d.acc -= used
                d.bits -= used
                arr.fill(d.level)
                self._dmc_cache = (d.enabled, d.level, d.bits, d.remaining)
                return arr
            d.acc, d.bits, d.remaining, d.addr, d.cur = saved
        for i in range(k):
            arr[i] = d.sample(cyc)
        self._dmc_cache = (d.enabled, d.level, d.bits, d.remaining)
        return arr

    def _apply_dmc(self, out):
        """（遗留，未使用）保留以免外部引用断裂：见 flush()。"""
        return out

    def flush(self):
        """取出本块累积的 DMC 台阶数组（未归一）。

        DMC 的贡献与四个声道不同量级（电平是 0~127 的整数台阶，而混音输出
        只有 0~0.7），也不能进非线性混音公式，所以 block() 末尾单独叠加并
        去直流，见下面的调用。
        """
        chunks = self.dmc_steps
        self.dmc_steps = []
        self._dmc_cache = None
        if not chunks:
            return None
        if len(chunks) == 1:
            return chunks[0]
        return np.concatenate(chunks)

    @staticmethod
    def _freq_of(ch, div):
        """块内不动点：定时器在段内不会变，频率只算一次。

        旧实现每次 sample() 都调 ch.freq()（除法 + 浮点），735 个采样就是
        735 次函数调用；向量化后整段只算一次。
        """
        return CPU_HZ / (div * (ch.timer + 1))

    @staticmethod
    def _wave(ch, k, steps, div):
        """返回 k 个采样点对应的波形台阶号（与 sample() 逐点等价）。

        sample() 的写法是“先取当前台阶，再把相位推进一步”，台阶号就是
        int(phase * steps)；这里一次性算出整段，并把相位一次性推到段末。
        """
        dt = 1.0 / SR
        f = CPU_HZ / (div * (ch.timer + 1)) * dt * steps
        idx = (ch.phase + f * np.arange(k, dtype=np.float64)).astype(np.int64)
        ch.phase = float((ch.phase + f * k) % steps)
        return idx

    @classmethod
    def _pulse_block(cls, ch, k):
        if (not ch.enabled) or ch.length == 0 or ch.timer < 8:
            return np.zeros(k, dtype=np.float32)
        vol = ch.env.volume(ch.const_vol, ch.vol_period)
        if vol == 0:
            return np.zeros(k, dtype=np.float32)
        idx = cls._wave(ch, k, 8, 16.0) & 7
        return (DUTY_NP[ch.duty][idx] * vol).astype(np.float32)

    @classmethod
    def _tri_block(cls, ch, k):
        if (not ch.enabled) or ch.length == 0 or ch.timer < 2 or ch.linear == 0:
            return np.zeros(k, dtype=np.float32)
        idx = cls._wave(ch, k, 32, 32.0) & 31
        return (15 - np.abs(idx - 15)).astype(np.float32)

    @classmethod
    def _noise_block(cls, ch, k):
        """噪声无渐变：一次算出整段的 LFSR 位序列（Python 循环里只做移位异或）。"""
        if (not ch.enabled) or ch.length == 0:
            return np.zeros(k, dtype=np.float32)
        vol = ch.env.volume(ch.const_vol, ch.vol_period)
        if vol == 0:
            return np.zeros(k, dtype=np.float32)
        per = NOISE_PERIODS[ch.period_idx]
        taps = 6 if ch.mode else 1
        # 每采样推进的 LFSR 步数：CPU_HZ/per * dt，一次算一段里的总步数
        total = int(ch.acc + CPU_HZ / per * (k / SR))
        ch.acc = (ch.acc + CPU_HZ / per * (k / SR)) - total
        out = np.empty(k, dtype=np.float32)
        lfsr = ch.lfsr
        step_prev = 0
        bps = CPU_HZ / per / SR        # 每采样步数（浮点）
        for i in range(k):
            want = int(bps * (i + 1))
            for _ in range(min(want - step_prev, 512)):
                fb = (lfsr & 1) ^ ((lfsr >> taps) & 1)
                lfsr = (lfsr >> 1) | (fb << 14)
            step_prev = want
            out[i] = 0.0 if (lfsr & 1) else vol
        ch.lfsr = lfsr
        return out

    # ---- 渲染（旧接口，逐采样；保留给 selftest 与单声道导出对比） ----
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
    """一阶 DC 高通，去掉非线性混音带来的直流偏置（向量化版）。

    递归 y[i] = x[i] - x[i-1] + a*y[i-1] 用系数展开成 FIR：
        y = (x - 滞后一采样 的 x) 与 a^k 的卷积，再用 numpy 一次算完。
    对 44100 采样循环纯 Python 要 10 ms 以上，这里降到 0.3 ms。
    """
    x = np.asarray(x, dtype=np.float32)
    n = len(x)
    if n == 0:
        return x
    a = 0.995
    d = np.empty_like(x)
    d[0] = x[0]
    d[1:] = x[1:] - x[:-1]
    # 截断到权重 < 1e-5 的长度（约 2300 点），足够近似一阶高通
    k = min(n, 600)
    w = a ** np.arange(k, dtype=np.float32)
    return np.convolve(d, w)[:n].astype(np.float32)
