"""按 $8920 命令表分类导出 contra 音频。

表结构（代码级证据见 sound/README.md）：
  $8920 + 3*id + [0,1,2]
    第 0 字节: bits0-2 = 通道号(0-7), bits3-4 = 通道数-1
    第 1 字节: ptr_lo
    第 2 字节: ptr_hi
  通道数 = (flags>>3)&3，0 表示单通道。
  基址本身是 $880A 从 $8717/$8718 两个代码字节偷出来的（$20/$89 -> $8920）。
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(ROOT, 'tools'))

import numpy as np
import wave
from play_sound import Harness, analyse
import apu as apumod

BANK1 = os.path.join(HERE, '..', 'temp', 'contra_bank1.bin')
TBL = 0x8920
BASE = 0x8000
OUT = os.path.join(ROOT, 'sound')

# 各分类的导出时长上限（秒）。BGM 给够，音效短。
LIMIT = {'bgm_full': 90, 'sfx_multi': 6, 'stop': 1, 'sfx_single': 4}
QUIET_STOP = 1.2        # 连续静音多少秒就认为曲子结束


def read_bank1():
    with open(BANK1, 'rb') as f:
        return f.read()


def parse_table(blob):
    """返回 {id: (flags, nch, [(ch, ptr), ...])}"""
    out = {}
    for i in range(127):
        off = TBL - BASE + 3 * i
        flags = blob[off]
        nch = (flags >> 3) & 3
        rows = []
        for k in range(max(nch, 1)):
            o = off + 3 * k
            ch = blob[o] & 7
            ptr = blob[o + 1] | (blob[o + 2] << 8)
            rows.append((ch, ptr))
        out[i] = (flags, nch, rows)
    return out


def classify(flags, nch):
    if flags == 0:
        return 'stop'
    if nch >= 3:
        return 'bgm_full'
    if nch == 2:
        return 'sfx_multi'
    return 'sfx_single'


def render(sid, max_sec, tail_quiet=QUIET_STOP):
    """渲染一个 id，遇到连续静音就提前收尾。返回 (samples, seconds, analysis)。"""
    h = Harness()
    h.engine_reset()
    h.request(sid)
    total = int(max_sec * 60)
    chunks = []
    quiet_run = 0
    used = 0
    for _ in range(total):
        x = h.run_frames(1)
        chunks.append(x)
        used += 1
        if len(x) and float(np.max(np.abs(x))) < 0.004:
            quiet_run += 1
        else:
            quiet_run = 0
        if quiet_run > tail_quiet * 60 and used > 30:
            break
    if not chunks:
        return np.zeros(1, dtype=np.float32), 0.0, {}
    y = np.concatenate(chunks)
    return y, used / 60.0, analyse(y)


def write_wav(path, x, sr=apumod.SR):
    pcm = np.clip(x, -1.0, 1.0)
    pcm = (pcm * 32767).astype('<i2')
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sr)
        w.writeframes(pcm.tobytes())


def main():
    only = [int(a) for a in sys.argv[1:]] or list(range(127))
    blob = read_bank1()
    table = parse_table(blob)
    os.makedirs(OUT, exist_ok=True)

    manifest = []
    for sid in only:
        flags, nch, rows = table[sid]
        cat = classify(flags, nch)
        limit = LIMIT[cat]
        y, sec, st = render(sid, limit)
        name = f'{cat}_id{sid:03d}.wav'
        write_wav(os.path.join(OUT, name), y)
        rms = st.get('rms', 0.0)
        silent = st.get('silent_ratio', 1.0)
        chans = '+'.join(f'ch{ch}' for ch, _ in rows)
        ptrs = '+'.join(f'${p:04X}' for _, p in rows)
        manifest.append((sid, cat, flags, nch, chans, ptrs, sec, rms, silent))
        print(f'{name:<26} {sec:5.2f}s rms={rms:.3f} silent={silent:4.0%}  {chans}  {ptrs}')

    # ---- README ----
    lines = []
    lines.append('# Contra（魂斗罗）音频导出')
    lines.append('')
    lines.append('全部由 ROM 里的**声音引擎本身**跑出来的：不套用 battle-city 的音序格式，')
    lines.append('而是直接用带 APU 的 6502 解释器执行引擎代码（`tools/play_sound.py`）。')
    lines.append('')
    lines.append('## 命令表 `$8920`（3 字节/项）')
    lines.append('')
    lines.append('```asm')
    lines.append('$880A: AD 17 87   LDA $8717     ; 基址是代码字节：$8717 处的 "20 89 8A"')
    lines.append('$880D: 85 EC      STA $EC       ;   = JSR $8A89，$20/$89 正好被当基址读')
    lines.append('$8818: AD 22 01   LDA $0122     ; A = id')
    lines.append('$881C: 65 EC      ADC $EC')
    lines.append('$8824: 85 ED      STA $ED       ; $EC += 3*id（循环 3 次）')
    lines.append('$882E: B1 EC      LDA ($EC),Y   ; flags')
    lines.append('$8830: 4A 4A 4A   LSR A ×3')
    lines.append('$8833: 29 03      AND #$03      ; 通道数 = (flags>>3)&3')
    lines.append('$8840: 29 07      AND #$07      ; 通道号 = flags&7')
    lines.append('```')
    lines.append('')
    lines.append('| 位 | 含义 |')
    lines.append('|----|------|')
    lines.append('| bits 0-2 | 目标通道号（0=P1, 1=P2, 2=三角, 3=噪音, 4/5=扩展） |')
    lines.append('| bits 3-4 | 通道数-1（0 = 单通道） |')
    lines.append('')
    lines.append('`id >= $82`(130) 直接 `RTS` 无效；`id = $7F-$81`(127-129) 走 `$88DA` 特殊路径。')
    lines.append('')
    lines.append('## 分类')
    lines.append('')
    for cat, title in [('bgm_full', '完整 BGM（多声部）'), ('sfx_multi', '双通道音效'),
                       ('sfx_single', '单通道音效'), ('stop', '停止')]:
        rows = [m for m in manifest if m[1] == cat]
        lines.append(f'### {title}：{len(rows)} 个')
        lines.append('')
        lines.append('| id | flags | 通道 | 指针 | 时长 | RMS |')
        lines.append('|----|-------|------|------|------|-----|')
        for sid, c, fl, nc, chans, ptrs, sec, rms, sil in rows:
            lines.append(f'| {sid} | `${fl:02X}` | {chans} | {ptrs} | {sec:.1f}s | {rms:.3f} |')
        lines.append('')
    lines.append('## 分轨关系（重要）')
    lines.append('')
    lines.append('部分 id 是同一曲的**单声部分轨**，换关时只重载变化的声部：')
    lines.append('')
    lines.append('- id 3（ch0+ch1+ch2 完整）= id 4(ch1) + id 5(ch2)')
    lines.append('- id 7（ch0+ch1+ch2 完整）= id 8(ch1) + id 9(ch2)')
    lines.append('- id 16（ch4+ch1）= id 17(ch1) + 一个 ch4 分轨')
    lines.append('- id 32（ch4+ch1+ch3）= id 33(ch1) + id 34(ch3) + ch4 分轨')
    lines.append('')
    lines.append('## ⚠️ 已知重复')
    lines.append('')
    lines.append('id 119 与 id 123 三个通道的指针**完全相同**（`$9827/$986F/$98B3`），')
    lines.append('即同一首曲子登记了两次。')
    lines.append('')
    lines.append('## 复现')
    lines.append('')
    lines.append('```powershell')
    lines.append('python tools/export_sound.py           # 导出全部 127 个')
    lines.append('python tools/export_sound.py 3 7 90    # 只导指定 id')
    lines.append('```')
    lines.append('')
    with open(os.path.join(OUT, 'README.md'), 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    print(f'\nREADME -> {os.path.join(OUT, "README.md")}')


if __name__ == '__main__':
    main()
