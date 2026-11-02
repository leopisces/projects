# -*- coding: utf-8 -*-
"""原版压制得到的 WAV 是不是“原版音源”？——用频谱指纹回答。

`..\\contra\\sound\\*.wav` 是另一条链路（直接跑逆向出的声音引擎、绕开模拟器
CPU/APU）导出的。如果它确实等于原版音乐，那么“跑到同一首歌时模拟器录音的
频谱”应该和它高度重合；如果对不上，说明问题在 APU 合成或帧序列器相位，
而不是播放器/队列。这里只比较 0~2 kHz 的频带能量分布（音高），
避开发声起点的相位差。
"""
import os
import sys
import wave

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
WAV = os.path.join(HERE, '..', 'contra', 'sound', 'bgm_full_id003.wav')


def read_wav(path):
    w = wave.open(path)
    n = w.getnframes()
    x = np.frombuffer(w.readframes(n), dtype='<i2').astype(np.float64)
    if w.getnchannels() == 2:
        x = x.reshape(-1, 2).mean(axis=1)
    return x, w.getframerate()


def bands(x, sr, nfft=4096):
    """把信号切成若干 4096 点窗口，返回每窗的 0~2kHz 频带能量（12 个 band）。"""
    out = []
    for i in range(0, len(x) - nfft, nfft):
        seg = x[i:i + nfft] * np.hanning(nfft)
        sp = np.abs(np.fft.rfft(seg))
        if sp.sum() < 1e-6:
            continue
        freqs = np.fft.rfftfreq(nfft, 1.0 / sr)
        b = []
        for lo, hi in [(0, 200), (200, 400), (400, 600), (600, 800),
                       (800, 1000), (1000, 1250), (1250, 1500), (1500, 1800)]:
            m = (freqs >= lo) & (freqs < hi)
            b.append(sp[m].sum())
        tot = sum(b) or 1.0
        out.append([v / tot for v in b])
    return np.array(out)


def compare(a, b):
    """两组 band 序列的余弦相似度（取长度较短的一部分）。"""
    n = min(len(a), len(b))
    if n == 0:
        return 0.0
    a, b = a[:n], b[:n]
    num = (a * b).sum()
    den = np.sqrt((a * a).sum() * (b * b).sum()) or 1.0
    return num / den


def main():
    from nes import NES
    rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(
        HERE, '..', 'contra', 'Contra.nes')
    ref, sr = read_wav(WAV)
    rb = bands(ref, sr)
    print('参考 %s  %d 采样  %d 窗  峰值 %d' % (
        os.path.basename(WAV), len(ref), len(rb), abs(ref).max()))

    emu = NES(rom)
    print('ROM: %s' % os.path.basename(rom))
    # 和导出侧一样：先等游戏自己进标题/开场，再按 START 进游戏
    best = []
    for f in range(1, 1801):
        if f == 300:                       # 片头结束前后按一下 START
            emu.set_buttons(0x08)
        elif f == 310:
            emu.set_buttons(0)
        emu.run_frame(audio=True)
        if f % 300 == 0 and emu.audio is not None:
            p1, p2 = emu.apu.p1, emu.apu.p2
            print('f%4d p1 len=%3d vol=%2d timer=%4d(%7.1fHz)  '
                  'p2 len=%3d vol=%2d  tri len=%3d  noi len=%3d  '
                  'audio_std=%.4f' % (
                      f, p1.length, p1.env.volume(p1.const_vol, p1.vol_period),
                      p1.timer, p1.freq(), p2.length,
                      p2.env.volume(p2.const_vol, p2.vol_period),
                      emu.apu.tri.length, emu.apu.noi.length,
                      float(np.std(emu.audio))))
    print('（参考 WAV 的 10ms RMS 前 12 段：）', end=' ')
    print([int(ref[i:i + 441].std()) for i in range(0, 441 * 12, 441)])


if __name__ == '__main__':
    main()
