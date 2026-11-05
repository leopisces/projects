"""方案 A：对比 engine_reset 后与 request(id) 后的 RAM，找出 per-id 写入的地址。

如果某个 id 把某个 RAM 单元写成了指向 ROM ($8000-$FFFF) 的指针，那它就是"曲目数据指针"。
用法: python temp/ram_diff.py [id ...]
"""
import sys, os

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', 'tools'))

from play_sound import Harness, ADDR_REQ


def snapshot():
    """reset 后的 RAM 快照（每步都用全新 harness，避免互相污染）。"""
    h = Harness()
    h.engine_reset()
    return bytes(h.bus.ram), h


def probe(sid):
    h = Harness()
    h.engine_reset()
    before = bytes(h.bus.ram)
    h.request(sid)
    after = bytes(h.bus.ram)
    diffs = [(a, before[a], after[a]) for a in range(len(after)) if before[a] != after[a]]
    # 再跑 1 帧，看还改了什么（有些参数在第一次 tick 才展开）
    h.tick()
    after2 = bytes(h.bus.ram)
    diffs2 = [(a, after[a], after2[a]) for a in range(len(after2)) if after[a] != after2[a]]
    return diffs, diffs2


def is_ptr(lo, hi):
    v = lo | (hi << 8)
    return 0x8000 <= v <= 0xFFFF, v


def main():
    ids = [int(x) for x in sys.argv[1:]] or [0, 1, 5, 20, 88, 90, 94, 95, 106, 127]
    for sid in ids:
        d1, d2 = probe(sid)
        print(f'=== id {sid:3d} ===')
        for a, b, c in d1:
            print(f'  req:  ${a:04X} {b:02X} -> {c:02X}')
        # 找指向 ROM 的 16 位指针
        ptrs = []
        for i in range(0, 0x10000 - 1):
            pass
        for a, b, c in d1:
            if a + 1 < 0x10000:
                ok, v = is_ptr(c, after_val := 0)  # placeholder
        # 简单：把所有改动地址里，连续两字节能拼成 ROM 地址的列出来
        vals = {}
        for a, b, c in d1:
            vals[a] = c
        for a in sorted(vals):
            if a in vals and a + 1 in vals:
                v = vals[a] | (vals[a + 1] << 8)
                if 0x8000 <= v <= 0xFFFF:
                    ptrs.append((a, v))
        if ptrs:
            print('  ** ROM 指针:')
            for a, v in ptrs:
                print(f'     ${a:04X} = ${v:04X}')
        if d2:
            print(f'  tick1 后变化 {len(d2)} 处: ' + ', '.join(f'${a:04X}:{b:02X}->{c:02X}' for a, b, c in d2[:12]))
        print()


if __name__ == '__main__':
    main()
