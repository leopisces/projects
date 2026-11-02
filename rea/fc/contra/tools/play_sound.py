"""无头（不显示画面）运行 contra 的 NES 声音引擎，导出 WAV + 音符事件日志。

对应 ROM 的哪几段（证据见 sound/README.md）：
  * NMI $F889（固定 bank = 16KB bank 7，映射在 $C000-$FFFF）
      F8BE: a0 12      LDY #$12
      F8C0: 20 89 f9   JSR $F989      ; MMC3 R6=$12 R7=$13 -> 8KB 2/3 = 16KB bank 1 到 $8000
      F8C3: 20 d5 80   JSR $80D5      ; ← 每帧一次的声音引擎 tick（bank 1）
  * 引擎复位      bank 1 $8719  （$8717 = JSR $8A89 再接 $8719 的主体）
  * 播放请求      bank 1 $87A2  （A = 音效/音乐 id）
  * 命令表        bank 1 $8920  每项 3 字节 [flags][ptr_lo][ptr_hi]，ptr = $8920 + 3*id

用法：
    python tools/play_sound.py --id 5 --seconds 30 --wav sound/contra_05.wav

设计取舍：
  * 不模拟 PPU / 控制器 / NMI 中断，只把 NMI 里那句 "JSR $80D5" 等价地每帧调用一次；
  * 引擎只依赖 RAM + APU 写，所以其它读写全部丢弃（但保留 MMC3 的 $8000/$8001
    写入口，万一引擎自己切 bank 也不会跑飞）；
  * 每帧先跑 tick 再渲染 735 个采样 —— 真机上驱动也是 NMI 里一次性写完寄存器。
"""
import argparse
import os
import sys
import time

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from rom import Rom
from cpu6502 import CPU6502
import apu as apumod

try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

DEFAULT_ROM = r'C:\Users\Leopisces\Desktop\魂斗罗1.nes'

# bank 1 内部的入口（全部由反汇编核对过）
ADDR_TICK = 0x80D5      # 每帧 tick（NMI F8C3 调用）
ADDR_RESET = 0x8719     # 引擎复位（$8717 先 JSR $8A89 再落到这里）
ADDR_REQ = 0x87A2       # 播放请求，A = id
ADDR_TABLE = 0x8920     # 命令表基址（从 $8717/$8718 两个代码字节偷出来）

PRG_RAM = 0x6000        # MMC3 PRG RAM 8KB

APU_REG_NAMES = {
    0x4000: 'P1_CTRL', 0x4001: 'P1_SWEEP', 0x4002: 'P1_TIMER_LO', 0x4003: 'P1_TIMER_HI',
    0x4004: 'P2_CTRL', 0x4005: 'P2_SWEEP', 0x4006: 'P2_TIMER_LO', 0x4007: 'P2_TIMER_HI',
    0x4008: 'TRI_LINEAR', 0x4009: 'TRI_UNUSED', 0x400A: 'TRI_TIMER_LO', 0x400B: 'TRI_TIMER_HI',
    0x400C: 'NOI_CTRL', 0x400D: 'NOI_UNUSED', 0x400E: 'NOI_PERIOD', 0x400F: 'NOI_LENGTH',
    0x4010: 'DMC_RATE', 0x4011: 'DMC_LEVEL', 0x4012: 'DMC_ADDR', 0x4013: 'DMC_LEN',
    0x4015: 'APU_STATUS', 0x4017: 'FRAME_CTR',
}


class Bus:
    """$0000-$FFFF 总线 + MMC3（mapper 4）bank 切换。"""

    def __init__(self, rom, apu, trace=None):
        self.rom = rom
        self.apu = apu
        self.prg = rom.prg                      # 16 个 8KB page
        self.ram = bytearray(0x10000)           # $0000-$1FFF 镜像 + $6000-$7FFF
        self.trace = trace                      # callable(addr, opcode) 或 None
        self.bank_regs = [0] * 8                # MMC3 R0..R7
        self.bank_select = 0
        self.mode_swapped = False
        self.bank_regs[6] = 2                   # 8KB page 2 -> 16KB bank 1
        self.bank_regs[7] = 3
        self.events = []                        # [(frame, addr, value)]
        self.frame = 0
        self.read_calls = 0
        self.write_calls = 0

    # ---- MMC3 ----
    def _prg_page(self, idx, mask=0x0F):
        return self.bank_regs[idx] & mask

    def window_pages(self):
        if self.mode_swapped:
            return self._prg_page(7), self._prg_page(6)
        return self._prg_page(6), self._prg_page(7)

    def _write_mapper(self, addr, val):
        if addr < 0xA000:
            if (addr & 1) == 0:
                self.bank_select = val & 0x07
                self.mode_swapped = bool(val & 0x40)
            else:
                idx = self.bank_select
                self.bank_regs[idx] = val
        # $A000/$A001 是镜像与 PRG-RAM 保护，本工具不需要

    # ---- 读 ----
    def read(self, addr):
        self.read_calls += 1
        if addr < 0x2000:
            return self.ram[addr & 0x07FF]
        if addr < 0x4000:
            return self.ram[addr & 0x07FF]          # PPU 镜像区，按 RAM 镜像读
        if addr < 0x4018:
            return 0                                # APU/IO 读：驱动器不用
        if addr < 0x6000:
            return 0
        if addr < 0x8000:
            return self.ram[addr]
        p8, pa = self.window_pages()
        if addr < 0xA000:
            return self.prg[p8 * 0x2000 + (addr & 0x1FFF)]
        if addr < 0xC000:
            return self.prg[pa * 0x2000 + (addr & 0x1FFF)]
        if addr < 0xE000:
            return self.prg[14 * 0x2000 + (addr & 0x1FFF)]
        return self.prg[15 * 0x2000 + (addr & 0x1FFF)]

    def peek(self, addr):
        """不改变统计的只读访问（给调试用）。"""
        n = self.read_calls
        v = self.read(addr)
        self.read_calls = n
        return v

    # ---- 写 ----
    def write(self, addr, val):
        self.write_calls += 1
        if addr < 0x2000:
            self.ram[addr & 0x07FF] = val
            return
        if addr < 0x4000:
            self.ram[addr & 0x07FF] = val
            return
        if addr < 0x4018:
            self.events.append((self.frame, addr, val))
            self.apu.write(addr, val)
            return
        if addr < 0x6000:
            return
        if addr < 0x8000:
            self.ram[addr] = val
            return
        self._write_mapper(addr, val)


class Harness:
    def __init__(self, rom_path=DEFAULT_ROM, trace=None):
        self.rom = Rom(rom_path)
        self.apu = apumod.APU(read_mem=self._dmc_read)
        self.bus = Bus(self.rom, self.apu, trace=trace)
        self.cpu = CPU6502(self.bus)
        self.note_events = []       # [(frame, ch, period, name, freq)]
        self._last_period = {}
        self.frames = 0
        self.tick_steps = []

    def _dmc_read(self, addr):
        return self.bus.read(addr)

    # ---- 引擎调用 ----
    def engine_reset(self):
        self.cpu.call(ADDR_RESET)
        self.bus.ram[0x0025] = 0x00     # $25 = 游戏侧"声音关闭"标志，0 = 正常发声
        self.bus.ram[0x012F] = 0x00

    def request(self, sound_id):
        self.cpu.a = sound_id & 0xFF
        self.cpu.call(ADDR_REQ)

    def tick(self):
        self.cpu.call(ADDR_TICK)

    # ---- 音符事件 ----
    def _scan_notes(self):
        """从 $4002/$4003 等寄存器值还原"当前在响的音"，变化时记一条事件。"""
        r = self.apu
        pairs = [
            ('PULSE1', r.p1.timer, False),
            ('PULSE2', r.p2.timer, False),
            ('TRIANGLE', r.tri.timer, True),
        ]
        for ch, timer, is_tri in pairs:
            if r.p1.enabled if ch == 'PULSE1' else (r.p2.enabled if ch == 'PULSE2' else r.tri.enabled):
                prev = self._last_period.get(ch)
                if timer != prev and timer > 0:
                    self._last_period[ch] = timer
                    nm, f = apumod.note_name_from_period(timer, is_tri)
                    if f < 60.0 or f > 5000.0:
                        continue        # 静音/无效周期不算音
                    self.note_events.append((self.frames, ch, timer, nm, f))

    def run_frames(self, nframes):
        spf = apumod.SR // 60            # 735 采样/帧
        chunks = []
        for _ in range(nframes):
            self.bus.frame = self.frames
            steps = self.cpu.call(ADDR_TICK)
            # CPU 周期也要推进，否则 APU 帧序列器的 240Hz 包络/长度计数不跑，
            # 音量会一直停在某一拍上（听感就是"音色不对/音量不衰减"）。
            self.apu._clock_frame(steps)
            self.tick_steps.append(steps)
            self._scan_notes()
            chunks.append(self.apu.render(spf, clock_frame=False))
            self.frames += 1
        if not chunks:
            return np.zeros(0, dtype=np.float32)
        return np.concatenate(chunks)


# ---------------------------------------------------------------- 分析
def analyse(x, sr=apumod.SR):
    if len(x) == 0:
        return {'rms': 0.0, 'peak': 0.0, 'centroid': 0.0, 'silent_ratio': 1.0}
    rms = float(np.sqrt(np.mean(x.astype(np.float64) ** 2)))
    peak = float(np.max(np.abs(x)))
    # 频谱质心（"是不是尖叫"的量化判据）
    n = min(len(x), sr * 8)
    spec = np.abs(np.fft.rfft(x[:n] * np.hanning(n)))
    freqs = np.fft.rfftfreq(n, 1.0 / sr)
    c = float((spec * freqs).sum() / (spec.sum() + 1e-12))
    # 静音比例：按 20ms 窗口，RMS < 峰值的 1%
    w = sr // 50
    k = max(1, len(x) // w)
    frames = x[:k * w].reshape(k, w).astype(np.float64)
    wr = np.sqrt((frames ** 2).mean(axis=1))
    thr = max(1e-4, peak * 0.01)
    silent = float((wr < thr).mean())
    return {'rms': rms, 'peak': peak, 'centroid': c, 'silent_ratio': silent}


def main(argv=None):
    ap = argparse.ArgumentParser(description='contra 声音引擎无头 harness')
    ap.add_argument('--rom', default=DEFAULT_ROM)
    ap.add_argument('--id', default='0x05', help='音效/音乐 id（16 进制或 10 进制）')
    ap.add_argument('--seconds', type=float, default=30.0)
    ap.add_argument('--frames', type=int, default=None, help='覆盖 --seconds')
    ap.add_argument('--wav', default=None)
    ap.add_argument('--sr', type=int, default=apumod.SR)
    ap.add_argument('--print-notes', type=int, default=200)
    ap.add_argument('--dump-events', type=int, default=0, help='打印前 N 条原始 APU 写事件')
    ap.add_argument('--trace', action='store_true', help='打印每帧 tick 的 CPU 步数')
    args = ap.parse_args(argv)

    sid = int(args.id, 16) if str(args.id).lower().startswith('0x') else int(args.id)
    nframes = args.frames if args.frames else int(round(args.seconds * 60))

    t0 = time.time()
    h = Harness(args.rom)
    h.engine_reset()
    h.request(sid)
    audio = h.run_frames(nframes)
    dt = time.time() - t0

    a = analyse(audio, args.sr)
    audio = apumod.dc_block(audio) if len(audio) else audio
    dur = len(audio) / float(args.sr)

    print('ROM        : %s' % args.rom)
    print('id         : $%02X (%d)' % (sid, sid))
    print('tick 入口  : $%04X  reset $%04X  request $%04X' % (ADDR_TICK, ADDR_RESET, ADDR_REQ))
    print('帧数       : %d (%.2f s @60Hz)   CPU 步数合计 %d，均 %.0f 步/帧' %
          (h.frames, h.frames / 60.0, sum(h.tick_steps), sum(h.tick_steps) / max(1, len(h.tick_steps))))
    print('APU 写事件 : %d 条' % len(h.bus.events))
    print('音符事件   : %d 条' % len(h.note_events))
    print('耗时       : %.2f s' % dt)

    if args.dump_events:
        print('\n--- APU 写事件（前 %d 条）frame addr name=value ---' % args.dump_events)
        for i, (f, ad, v) in enumerate(h.bus.events[:args.dump_events]):
            print('%5d %04X %-12s = %02X' % (f, ad, APU_REG_NAMES.get(ad, '?'), v))

    if args.print_notes:
        print('\n--- 音符事件（前 %d 条） frame  channel  timer  note  freq ---' % args.print_notes)
        for f, ch, timer, nm, fr in h.note_events[:args.print_notes]:
            print('%5d  %-8s %5d  %-4s %8.2f Hz' % (f, ch, timer, nm or '-', fr))

    if args.wav:
        d = os.path.dirname(os.path.abspath(args.wav))
        os.makedirs(d, exist_ok=True)
        n = apumod.write_wav(args.wav, audio, args.sr)
        print('\nWAV        : %s (%d 采样, %.2f s)' % (args.wav, n, n / float(args.sr)))
    print('RMS        : %.5f   peak %.5f   频谱质心 %.1f Hz   静音窗比例 %.1f%%'
          % (a['rms'], a['peak'], a['centroid'], a['silent_ratio'] * 100))
    if a['rms'] < 1e-4:
        print('!! 静音')
    return 0


if __name__ == '__main__':
    sys.exit(main())
