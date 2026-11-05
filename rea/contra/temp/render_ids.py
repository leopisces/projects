"""临时探针：跑 contra 真实引擎，导出 WAV + 音符事件，供人工挑歌。

用法：
    python temp/render_ids.py --ids 1-40 --seconds 6
"""
import argparse
import os
import sys
import wave

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', 'tools'))

import play_sound as ps   # noqa: E402

OUT = os.path.join(HERE, '..', 'sound')


def write_wav(path, data, sr=44100):
    d = np.clip(data, -1.0, 1.0)
    pcm = (d * 32767).astype(np.int16)
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sr)
        w.writeframes(pcm.tobytes())


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--ids', default='1-40')
    ap.add_argument('--seconds', type=float, default=6.0)
    args = ap.parse_args()

    a, b = args.ids.split('-') if '-' in args.ids else (args.ids, args.ids)
    ids = list(range(int(a), int(b) + 1))
    os.makedirs(OUT, exist_ok=True)
    n = int(args.seconds * 60)

    rows = []
    for sid in ids:
        try:
            h = ps.Harness()
            h.engine_reset()
            h.request(sid)
            x = h.run_frames(n)
            m = ps.analyse(x)
            if len(x) == 0 or m['rms'] < 0.003:
                rows.append((sid, m, None, 0))
                continue
            path = os.path.join(OUT, 'id_%03d.wav' % sid)
            write_wav(path, x)
            rows.append((sid, m, path, len(h.note_events)))
        except Exception as e:
            rows.append((sid, {'rms': -1, 'peak': 0, 'centroid': 0, 'silent_ratio': 1},
                         'ERR %s' % e, 0))

    print('%-5s %-8s %-8s %-8s %-6s %s' % ('id', 'rms', 'peak', 'centroid', 'notes', 'file'))
    for sid, m, path, nnotes in rows:
        print('%-5d %-8.4f %-8.3f %-8.0f %-6d %s' % (
            sid, m['rms'], m['peak'], m['centroid'], nnotes,
            path if path else '(静音/跳过)'))


if __name__ == '__main__':
    main()
