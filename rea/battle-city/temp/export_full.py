# -*- coding: utf-8 -*-
"""完整导出：28 个槽 + 全部曲子组合，按数据块真实长度渲染。"""
import os, sys, wave
import numpy as np
sys.path.insert(0, 'tools')
from sound import (Rom, Engine, synth, write_wav, MIXES, SR, FRAME_HZ, HW_NAMES)

ROM = 'battle_city.nes'
OUT = 'sound'

# 槽位命名（按触发地址逆向 + 数据特征归类）
SLOT_NAMES = {
    0:  'sfx_pause',
    1:  'bgm_stage_pulse1',
    2:  'bgm_stage_tri',
    3:  'bgm_stage_pulse2',
    4:  'sfx_04',
    5:  'sfx_05',
    6:  'sfx_06',
    7:  'sfx_noise_07',
    8:  'sfx_08',
    9:  'sfx_09',
    10: 'sfx_noise_10',
    11: 'sfx_11',
    12: 'sfx_tri_12',
    13: 'sfx_13',
    14: 'sfx_14',
    15: 'sfx_15',
    16: 'sfx_16',
    17: 'sfx_17',
    18: 'sfx_18',
    19: 'sfx_19',
    20: 'sfx_noise_20',
    21: 'bgm_hiscore_pulse1',
    22: 'bgm_hiscore_pulse2',
    23: 'bgm_hiscore_tri',
    24: 'jingle_gameover_pulse1',
    25: 'jingle_gameover_pulse2',
    26: 'jingle_gameover_tri',
    27: 'jingle_result',
}


def render_exact(engine, idx, max_frames=60 * 120, tail=0.3):
    """不做静音截断：跑满 max_frames 或槽状态归零后多跑 30 帧。"""
    engine.trigger(idx)
    snaps, wr = [], []
    ended = 0
    for _ in range(max_frames):
        s = engine.frame()
        snaps.append(s)
        wr.append(list(engine.writes))
        if engine.ch[idx].status == 0:
            ended += 1
            if ended > 30:      # 停止后多录 30 帧尾音
                break
        else:
            ended = 0
    if not snaps:
        return np.zeros(0)
    return synth(snaps, wr, tail)


def render_mix_exact(engine, idxs, max_frames=60 * 180, tail=0.3):
    for i in idxs:
        engine.trigger(i)
    snaps, wr = [], []
    ended = 0
    for _ in range(max_frames):
        s = engine.frame()
        snaps.append(s)
        wr.append(list(engine.writes))
        if all(engine.ch[i].status == 0 for i in idxs):
            ended += 1
            if ended > 30:
                break
        else:
            ended = 0
    return synth(snaps, wr, tail) if snaps else np.zeros(0)


def info(x):
    if len(x) == 0:
        return 0.0, 0.0, 1.0
    rms = float(np.sqrt(np.mean(x.astype(np.float64) ** 2)))
    peak = float(np.max(np.abs(x)))
    silent = float(np.mean(np.abs(x) < 1e-4))
    return rms, peak, silent


def main():
    rom = Rom(ROM)
    engine = Engine(rom)

    print('=== 单个槽 (28) ===')
    rows = []
    for idx in range(28):
        eng = Engine(rom)          # 每个槽新建引擎，避免状态污染
        x = render_exact(eng, idx)
        rms, peak, sil = info(x)
        name = SLOT_NAMES.get(idx, 'slot_%02d' % idx)
        fn = 'slot_%02d_%s.wav' % (idx, name)
        if len(x):
            write_wav(os.path.join(OUT, fn), x)
        dur = len(x) / SR
        rows.append((idx, name, dur, rms, peak, sil))
        print('  %2d %-22s %5.2fs rms=%.3f peak=%.3f sil=%5.1f%%' %
              (idx, name, dur, rms, peak, sil))

    print('\n=== 曲子组合 ===')
    for key, (idxs, desc) in MIXES.items():
        eng = Engine(rom)
        x = render_mix_exact(eng, idxs)
        rms, peak, sil = info(x)
        dur = len(x) / SR
        fn = key + '.wav'
        if len(x):
            write_wav(os.path.join(OUT, fn), x)
        print('  %-20s %5.2fs rms=%.3f peak=%.3f sil=%5.1f%%  (%s)' %
              (key, dur, rms, peak, sil, desc))

    # 汇总表
    with open(os.path.join(OUT, 'index.txt'), 'w', encoding='utf-8') as f:
        f.write('槽位  名称                    时长     RMS     峰值   静音率\n')
        f.write('-' * 76 + '\n')
        for idx, name, dur, rms, peak, sil in rows:
            f.write('%3d   %-22s %6.2fs  %.3f  %.3f  %5.1f%%\n' %
                    (idx, name, dur, rms, peak, sil))
    print('\n索引表 -> sound/index.txt')


if __name__ == '__main__':
    main()
