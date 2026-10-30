"""Battle City 声音引擎逆向 + APU 合成器。

复刻 ROM 里的音序引擎（$EA7E SoundEngineTick / $EB11 音序处理），
把 28 个音序槽解码成音频。

序列格式（逆向自 $EB4F-$ECAF）：
  头部 4 或 5 字节:
    b0 = 硬件声道  1=方波1  2=方波2  3=三角  4=噪音
    b1 = $4000 寄存器值（音量/包络/duty）
    b2 = $4001 寄存器值（扫频）
    b3 = $4003 值（含长度计数器位）      ← 代码里写进 idx4
    [仅 b0==4] 额外 1 字节 → idx3

  命令流:
    $00-$5F  音符：idx = b>>3（12 音，A..G#），shift = b&7
             周期 = NoteFreqTable[idx] >> shift
             freq = 1789773 / (16 * (周期 + 1))
    $60      音符结束标记（把时长写入计数器）
    $61-$E7  时长 = b - $60 帧
    $E8      停止本槽
    $E9/$EA  改 b1 低 6 位（音量/包络）
    $EB      改 b1 低 4 位（音量）
    $EC      改 b2（扫频）
    $ED      改 b3
    $EE      改整个 b1
    $EF      清零 3 个循环计数器
    $F0-$F2  循环：<次数> <回跳位置>（对应 loop1/2/3）
    $F3-$FF  跳过 1 字节
"""
import os
import sys
import wave
import struct

import numpy as np

CPU_HZ = 1789773
FRAME_HZ = 60.0988
SR = 44100

PTR_TABLE = 0xECFE
NOTE_TABLE = 0xECE6

HW_NAMES = {1: '方波1', 2: '方波2', 3: '三角', 4: '噪音'}

# 12 个音符周期（大端存于 $ECE6，A1 起半音递增）
NOTE_PERIODS = [0x07F2, 0x0780, 0x0714, 0x06AE, 0x0643, 0x05F4,
                0x059E, 0x054E, 0x0502, 0x04BA, 0x0476, 0x0436]
NOTE_NAMES = ['A', 'A#', 'B', 'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#']

DUTY = {0: [0, 1, 0, 0, 0, 0, 0, 0],
        1: [0, 1, 1, 0, 0, 0, 0, 0],
        2: [0, 1, 1, 1, 1, 0, 0, 0],
        3: [1, 0, 0, 1, 1, 1, 1, 1]}
TRI = [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0,
       0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
LENGTH_TBL = [10, 254, 20, 2, 40, 4, 80, 6, 160, 8, 60, 10, 14, 12, 26, 14,
              12, 16, 24, 18, 48, 20, 96, 22, 192, 24, 72, 26, 16, 28, 32, 30]


class Rom:
    def __init__(self, path):
        d = open(path, 'rb').read()
        self.prg = d[16:16 + d[4] * 16384]

    def p(self, a):
        return self.prg[a - 0xC000]

    def ptrs(self):
        return [self.p(PTR_TABLE + i * 2) | (self.p(PTR_TABLE + i * 2 + 1) << 8)
                for i in range(28)]

    def seq_len(self, addr):
        """估计序列长度（到最近的 0xE8 停止字节或下一个序列起点）。"""
        end = 0x10000
        for other in self.ptrs():
            if addr < other < end:
                end = other
        return end - addr


class ChanState:
    """一个音序槽的状态。

    ROM 里有两套并行数组，不能混为一谈：
      $0300+N   = status   0=空闲 1=待启动 >=2=运行中
      $031C+N*8 = 8 字节数据块，其中 byte0 = 待写寄存器标记（0 / 1-4 / 5-8）
    """
    __slots__ = ('st', 'status', 'b1', 'b2', 'b3', 'b4', 'pos', 'dur', 'cnt',
                 'hw', 'addr', 'trace')

    def __init__(self, addr):
        self.st = 0        # 数据块 byte0：0=空, 1-4=待写(声道), 5-8=已写
        self.status = 0    # $0300+N
        self.b1 = self.b2 = self.b3 = self.b4 = 0
        self.pos = 0
        self.dur = self.cnt = 0
        self.hw = 0
        self.addr = addr
        self.trace = []


class Engine:
    def __init__(self, rom, channels=28):
        self.rom = rom
        self.n = channels
        self.ch = [ChanState(a) for a in rom.ptrs()]
        self.loopc = [[0, 0, 0] for _ in self.ch]
        self.regs = [[0x30, 0, 0, 0] for _ in range(4)]  # 每帧 4 个硬件声道
        self.writes = [False] * 4      # 本帧是否真的写了该声道寄存器
        self.frames = []

    # ---- 音序数据读取（对应 $ECBE ReadChannelByte）----
    def rd(self, c):
        v = self.rom.p(c.addr + c.pos)
        c.pos = (c.pos + 1) & 0xFF
        return v

    def trigger(self, idx):
        self.ch[idx].status = 1

    def frame(self):
        """跑一帧，返回 4 个硬件声道的寄存器快照。"""
        claimed = [False] * 4
        self.writes = [False] * 4

        # ---- Pass 1: 寄存器写入 ----
        for c in self.ch:
            b0 = c.st
            if b0 == 0:
                continue
            if 5 <= b0 <= 8:
                claimed[b0 - 5] = True
                continue
            if 1 <= b0 <= 4:
                h = b0 - 1
                if not claimed[h]:
                    c.st = b0 + 4
                    claimed[h] = True
                    self.regs[h] = [c.b1, c.b2, c.b3, c.b4]
                    self.writes[h] = True

        for h in range(4):
            if not claimed[h]:
                self.regs[h][0] = 0x10      # 音量 0（静音）

        # ---- Pass 2: 命令流处理 ----
        for i, c in enumerate(self.ch):
            if c.status == 0:
                continue
            if c.status == 1:
                c.status = 2
                c.pos = 0
                c.hw = self.rd(c)
                c.b1 = self.rd(c)
                c.b2 = self.rd(c)
                c.b4 = self.rd(c)
                if c.hw == 4:
                    c.b3 = self.rd(c)
                continue
            if c.cnt:
                c.cnt -= 1
                continue
            self.run_commands(c, i)

        return [tuple(r) for r in self.regs]

    def run_commands(self, c, i):
        guard = 0
        while guard < 500:
            guard += 1
            b = self.rd(c)
            if b < 0x60:
                idx = b >> 3
                shift = b & 7
                if idx < 12:
                    period = NOTE_PERIODS[idx] >> shift
                    c.b3 = period & 0xFF
                    c.b4 = (c.b4 & 0xF8) | ((period >> 8) & 0x07)
                    c.trace.append((idx, shift, period, c.dur))
                # 对应 ROM 的 "byte0 >= 5 时 byte0 -= 4"：重新排入寄存器写入队列
                c.st = (c.hw if c.hw else 1)
                c.cnt = c.dur or 1
                return
            if b == 0x60:
                c.cnt = c.dur or 1
                c.st = (c.hw if c.hw else 1)
                return
            if b < 0xE8:
                c.dur = b - 0x60
                continue
            # 控制字节
            if b == 0xE8:
                c.status = 0
                return
            if b == 0xE9 or b == 0xEA:
                c.b1 = (c.b1 & 0xC0) | (self.rd(c) & 0x3F)
            elif b == 0xEB:
                c.b1 = (c.b1 & 0xF0) | (self.rd(c) & 0x0F)
            elif b == 0xEC:
                c.b2 = self.rd(c)
            elif b == 0xED:
                c.b4 = self.rd(c)
            elif b == 0xEE:
                c.b1 = self.rd(c)
            elif b == 0xEF:
                self.loopc[i] = [0, 0, 0]
            elif 0xF0 <= b <= 0xF2:
                k = b - 0xF0
                count = self.rd(c)
                self.loopc[i][k] += 1
                if self.loopc[i][k] != count:
                    c.pos = self.rd(c)          # 回跳
                else:
                    self.loopc[i][k] = 0
                    self.rd(c)                  # 丢弃回跳字节
            elif b <= 0xF8:
                self.rd(c)                      # 跳过 1 字节
        c.status = 0


def render(engine, idx, max_frames=60 * 40, tail=0.4):
    """单独触发一个音序槽，渲染成 numpy 波形。"""
    engine.trigger(idx)
    snaps = []
    wr = []
    silent = 0
    for _ in range(max_frames):
        s = engine.frame()
        snaps.append(s)
        wr.append(list(engine.writes))
        solo = engine.ch[idx]
        if solo.status == 0:
            silent += 1
            if silent > 20:
                break
        else:
            silent = 0
    if not snaps:
        return np.zeros(0)
    return synth(snaps, wr, tail)


def synth(snaps, writes=None, tail=0.4):
    spf = SR / FRAME_HZ
    total = int(len(snaps) * spf) + int(SR * tail)
    out = np.zeros(total, dtype=np.float32)
    phase = [0.0] * 4
    noise_lfsr = 1
    # 硬件包络（$4000 bit4=0 时生效）—— 由 240Hz 帧序列器驱动，每 60Hz 帧走 4 拍
    env_vol = [15] * 4
    env_div = [0] * 4
    length = [0] * 4

    for fi, snap in enumerate(snaps):
        wr = writes[fi] if writes else [False] * 4
        n0 = int(fi * spf)
        n1 = int((fi + 1) * spf)
        width = max(1, n1 - n0)
        t = np.arange(width) / SR
        chans = [np.zeros(width, dtype=np.float32) for _ in range(4)]
        levels = [0, 0, 0, 0]

        for h in range(4):
            b1, b2, b3, b4 = snap[h]
            # 写 $4003/$4007/$400B/$400F → 包络复位 + 长度计数器重装
            if wr[h]:
                env_vol[h] = 15
                env_div[h] = 0
                length[h] = LENGTH_TBL[(b4 >> 3) & 0x1F]

            if h == 2:
                # 三角通道（$4008）没有音量/包络，只能被长度计数器关掉
                period = 0
                vol = 15
            else:
                const = (b1 >> 4) & 1
                vol = (b1 & 0x0F) if const else None
            if h == 2:
                pass
            elif vol is None:
                period = max(1, b1 & 0x0F)
                env_div[h] += 4                    # 240Hz 时钟
                while env_div[h] >= period:
                    env_div[h] -= period
                    env_vol[h] -= 1
                    if env_vol[h] < 0:
                        env_vol[h] = 15 if (b1 & 0x20) else 0
                        break
                vol = env_vol[h]
            # 长度计数器（半帧 120Hz 递减）
            if length[h] > 0:
                length[h] -= 0.5
                if length[h] <= 0:
                    vol = 0
            if vol == 0:
                continue
            timer_lo = b3
            timer_hi = b4 & 0x07
            timer = timer_lo | (timer_hi << 8)
            if timer < 8:
                continue

            if h < 2:                                  # 方波
                duty = DUTY[(b1 >> 6) & 3]
                f = CPU_HZ / (16.0 * (timer + 1))
                ph = (phase[h] + f * t) % 1.0
                seq = np.array(duty, dtype=np.float32)
                s = seq[(ph * 8).astype(np.int32) % 8]
                levels[h] = vol
            elif h == 2:                               # 三角
                f = CPU_HZ / (32.0 * (timer + 1))
                ph = (phase[h] + f * t) % 1.0
                tw = np.array(TRI, dtype=np.float32) / 15.0 * 2 - 1
                s = tw[(ph * 32).astype(np.int32) % 32]
                levels[h] = 15
            else:                                      # 噪音
                period = [4, 8, 16, 32, 64, 96, 128, 160,
                          202, 254, 380, 508, 762, 1016, 2034, 4068][timer_lo & 0x0F]
                rate = min(8000.0, CPU_HZ / float(period))
                steps = np.maximum(1, (rate * t).astype(np.int64))
                total_steps = int(steps.sum())
                lfsr = noise_lfsr
                bit_out = np.empty(total_steps, dtype=np.float32)
                for k in range(total_steps):
                    bit = (lfsr & 1) ^ ((lfsr >> 1) & 1)
                    lfsr = (lfsr >> 1) | (bit << 14)
                    bit_out[k] = 1.0 if (lfsr & 1) else -1.0
                noise_lfsr = lfsr
                idxs = np.repeat(np.arange(width), steps[:width])
                s = bit_out[idxs[:width]] if total_steps else np.zeros(width, np.float32)
                levels[h] = vol

            # 相位推进要用各自正确的频率
            f_ph = CPU_HZ / ((16.0 if h < 2 else 32.0) * (timer + 1))
            phase[h] = (phase[h] + f_ph * width / SR) % 1.0
            chans[h][:] = s

        out[n0:n0 + width] += nes_mix(chans, levels)[:width]

    # 简易低通，去掉方波的高频毛刺，更接近实机输出
    if len(out) > 8:
        k = np.array([0.25, 0.5, 0.25], dtype=np.float32)
        out = np.convolve(out, k, mode='same').astype(np.float32)

    peak = np.max(np.abs(out)) or 1.0
    if peak > 1.0:
        out /= peak
    return out


def nes_mix(chans, levels):
    """NES APU 非线性混音（沿用 NESdev 社区标定的经验公式）。

    pulse = 95.88 / (8128/(p1+p2) + 100)
    tnd   = 159.79 / (1/(t/8227 + n/12241 + d/22638) + 100)
    这个公式让三角/噪音相对方波的音量比例与实机一致，
    而不是简单相加（简单相加会让低音过响）。
    """
    s1, s2, tri, noi = [np.clip(c, -1.0, 1.0) for c in chans]
    l1, l2, lt, ln = levels

    # 方波：取当前音量包络 × 波形（0..15 的幅度）
    p1 = np.abs(s1) * l1
    p2 = np.abs(s2) * l2
    psum = p1 + p2
    pulse = np.where(psum > 0, 95.88 / (8128.0 / np.maximum(psum, 1e-6) + 100.0), 0.0)

    t = (tri + 1.0) * 0.5 * (15 if lt else 0)
    n = (noi + 1.0) * 0.5 * ln
    denom = t / 8227.0 + n / 12241.0
    tnd = np.where(denom > 0, 159.79 / (1.0 / np.maximum(denom, 1e-9) + 100.0), 0.0)

    return ((pulse + tnd) / 0.9).astype(np.float32)


def write_wav(path, data):
    pcm = (np.clip(data, -1, 1) * 32000).astype(np.int16)
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())


def describe(rom, addr, limit=120):
    """把序列解成可读的记谱文本。"""
    e = Engine(rom, 1)
    c = e.ch[0]
    c.addr = addr
    e.trigger(0)
    lines = []
    e.frame()
    lines.append(f"声道 {HW_NAMES.get(c.hw, c.hw)}  vol=${c.b1:02X}  sweep=${c.b2:02X}")
    cur_dur = None
    for _ in range(limit):
        if c.status == 0:
            lines.append('  [停止]')
            break
        before = len(c.trace)
        saved = c.cnt
        c.cnt = 0
        e.run_commands(c, 0)
        if len(c.trace) > before:
            idx, shift, period, _d = c.trace[-1]
            name = NOTE_NAMES[idx]
            div = 32.0 if c.hw == 3 else 16.0      # 三角用 32 分频，方波 16
            f = CPU_HZ / (div * (period + 1))
            lines.append(f"  {name:<3} shift={shift}  {f:7.1f} Hz  时长={c.cnt} 帧")
        else:
            if c.status == 0:
                lines.append('  [停止]')
                break
            lines.append(f"  (命令, 时长={c.cnt})")
        if len(lines) > limit:
            break
    return '\n'.join(lines)


# 曲子组合（触发点已从代码逆向确认，见 sound/README.md）
MIXES = {
    'bgm_stage_start': ([1, 2, 3], '关卡开始 / 主旋律（方波1+三角+方波2）'),
    'bgm_stage_melody': ([1], '关卡开始 / 只有主旋律声部（方波1，用来核对音高）'),
    'bgm_hiscore':     ([21, 22, 23], '高分榜登记背景音乐'),
    'jingle_gameover': ([24, 25, 26], 'GAME OVER 音乐'),
    'jingle_result':   ([27], '结算画面音乐'),
    'jingle_pause':    ([0], '暂停音效'),
}


def render_mix(engine, idxs, max_frames=60 * 30, tail=0.5):
    """同时触发多个音序槽（复刻引擎的 4 声道优先级混音）。"""
    for i in idxs:
        engine.trigger(i)
    snaps = []
    wr = []
    silence = 0
    for _ in range(max_frames):
        s = engine.frame()
        snaps.append(s)
        wr.append(list(engine.writes))
        if all(engine.ch[i].status == 0 for i in idxs):
            silence += 1
            if silence > 20:
                break
        else:
            silence = 0
    return synth(snaps, wr, tail) if snaps else np.zeros(0)


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    rom_path = sys.argv[1] if len(sys.argv) > 1 else \
        os.path.join(os.path.dirname(here), 'battle_city.nes')
    if not os.path.isfile(rom_path):
        rom_path = os.path.join(here, '..', 'battle_city.nes')
    rom = Rom(rom_path)
    outdir = os.path.join(os.path.dirname(here), 'sound')
    os.makedirs(outdir, exist_ok=True)

    print(f"ROM: {rom_path}")
    print(f"{'#':>2} {'地址':>6} {'声道':<6} {'音符数':>6} {'秒':>6}  文件")
    summary = []
    for i in range(28):
        e = Engine(rom, 1)
        wav = render(e, i, max_frames=60 * 20)
        secs = len(wav) / SR
        notes = len(e.ch[i].trace)
        fn = f"seq_{i:02d}.wav"
        if len(wav):
            write_wav(os.path.join(outdir, fn), wav)
        summary.append((i, rom.ptrs()[i], e.ch[i].hw, notes, secs, fn))
        print(f"{i:>2} ${rom.ptrs()[i]:04X} {HW_NAMES.get(e.ch[i].hw,'?'):<6} "
              f"{notes:>6} {secs:>6.1f}  {fn}")

    with open(os.path.join(outdir, 'sequences.txt'), 'w', encoding='utf-8') as f:
        for i in range(28):
            e = Engine(rom, 1)
            e.trigger(i)
            e.frame()
            f.write(f"\n===== 音序 {i}  @ ${rom.ptrs()[i]:04X}  "
                    f"{HW_NAMES.get(e.ch[0].hw, '?')} =====\n")
            f.write(describe(rom, rom.ptrs()[i]) + "\n")
    print(f"\n音频 -> {outdir}\\seq_XX.wav   记谱 -> sequences.txt")

    print("\n=== 完整曲子混音 ===")
    for name, (idxs, desc) in MIXES.items():
        e = Engine(rom)
        wav = render_mix(e, idxs)
        if len(wav):
            write_wav(os.path.join(outdir, name + '.wav'), wav)
        print(f"  {name}.wav  {len(wav)/SR:5.1f}s  槽{idxs}  {desc}")


if __name__ == '__main__':
    main()
