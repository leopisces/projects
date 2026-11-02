"""递归下降 6502 反汇编器（contra 专用）。

从入口地址出发，跟进 JSR/JMP/分支，识别代码与数据边界；
对 `JSR $xxxx` 后紧跟的数据表（contra 用这种内联表技法，见 $C6F2）做特殊标记。

用法：
    python tools/rdis.py                 # 反汇编固定 bank
    python tools/rdis.py --addr F889     # 指定入口
"""
import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rom import Rom
from dis6502 import T, MODES, LEN, decode

try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

DEFAULT_ROM = r'C:\Users\Leopisces\Desktop\魂斗罗1.nes'

# 不继续跟进的指令
STOP = {'RTS', 'RTI', 'BRK'}
# 无条件的跳转
UNCOND = {'JMP'}
BRANCHES = {'BCC', 'BCS', 'BEQ', 'BMI', 'BNE', 'BPL', 'BVC', 'BVS'}

# 内联跳转表分派器：JSR 到这些地址后，紧跟一串 16bit 目标
INLINE_DISPATCH = {
    0xC6F2: None,   # LDA $18 / JSR $C6F2 → 表在 JSR 下一条指令处，表基址 $C013 是默认
}


def table_targets(code, base, at, count=None):
    """读 at 处的 16bit 跳转表（count=None 则读到越界或遇到非目标值）。"""
    out = []
    limit = base + len(code)
    o = at - base
    while o + 1 < len(code):
        v = code[o] | code[o + 1] << 8
        if not (base <= v < limit):
            break
        out.append(v)
        o += 2
        if count and len(out) >= count:
            break
    return out


def trace(code, base, entries, tables=()):
    """递归下降：返回 (visited:set[addr], order:list[addr])。

    tables: 额外要当代码入口的表地址列表。
    """
    seen = set()
    order = []
    stack = list(entries) + list(tables)
    limit = base + len(code)
    while stack:
        a = stack.pop()
        while base <= a < limit and a not in seen:
            seen.add(a)
            order.append(a)
            off = a - base
            op = code[off]
            if op not in T:
                break
            mn, mode = T[op]
            ln = 1 + MODES[mode]
            if mn in UNCOND:
                if mode == 'abs':
                    tgt = code[off + 1] | code[off + 2] << 8
                    if base <= tgt < limit:
                        a = tgt
                        continue
                break
            if mn in BRANCHES:
                d = code[off + 1]
                tgt = a + 2 + (d - 256 if d > 127 else d)
                if base <= tgt < limit and tgt not in seen:
                    stack.append(tgt)
                a += ln
                continue
            if mn in STOP:
                break
            if mn == 'JSR' and mode == 'abs':
                tgt = code[off + 1] | code[off + 2] << 8
                if base <= tgt < limit and tgt not in seen:
                    stack.append(tgt)
                # 内联分派表：跟进紧跟的目标
                if tgt in INLINE_DISPATCH:
                    for t in table_targets(code, base, a + ln, 8):
                        if t not in seen:
                            stack.append(t)
            a += ln
    return seen, order


def dump(code, base, addrs, extra_data=()):
    """按地址顺序输出，未在 addrs 里的算数据。"""
    addrs = set(addrs)
    out = []
    a = base
    end = base + len(code)
    while a < end:
        off = a - base
        if a in addrs:
            op = code[off]
            if op in T:
                mn, mode = T[op]
                ln = 1 + MODES[mode]
                for row in decode(code[off:off + ln], base=a):
                    out.append(row)
                a += ln
                continue
        # 数据：合并连续数据成一行（最多 16 字节）
        j = off
        buf = []
        while j < len(code) and (base + j) not in addrs and len(buf) < 16:
            buf.append(code[j])
            j += 1
        if not buf:                 # 防死循环
            a += 1
            continue
        out.append((a, bytes(buf).hex(' '), '.byte ' + '$%02X' % buf[0] +
                    (' …' if len(buf) > 1 else '')))
        a += len(buf)
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--rom', default=DEFAULT_ROM)
    ap.add_argument('--bank', default='fixed',
                    help='"fixed" 或 0-7')
    ap.add_argument('--addr', default=None, help='入口地址（hex）')
    ap.add_argument('-o', '--out', default=None)
    args = ap.parse_args()

    rom = Rom(args.rom)
    if args.bank == 'fixed':
        # $C000-$FFFF 是一个连续 16KB 地址空间：$C000-$DFFF 在 prg[-16384:-8192]，
        # $E000-$FFFF 在 prg[-8192:]。拼起来才能跟进跨区 JSR。
        code = rom.prg[len(rom.prg) - 16384:]
        base = 0xC000
        entries = [rom.vector('RESET'), rom.vector('NMI'), rom.vector('IRQ'),
                   0xF880]                      # 主循环
    else:
        n = int(args.bank)
        code = rom.bank(n)
        base = 0x8000
        entries = [0x8000, 0x80D5] if n == 1 else [0x8000]
    if args.addr:
        entries = [int(args.addr, 16)]

    seen, order = trace(code, base, entries)
    # 状态机跳转表 $C013（$C6F2 分派）单独补充
    if args.bank == 'fixed':
        extra = table_targets(code, base, 0xC013, 8)
        seen2, _ = trace(code, base, list(seen) + extra)
        seen = seen2
    rows = dump(code, base, seen)
    lines = [f'; {os.path.basename(args.rom)} bank={args.bank} '
             f'base=${base:04X} 入口={[f"${e:04X}" for e in entries]}',
             f'; 代码 {len(seen)} 字节（递归下降）']
    for a, b, t in rows:
        lines.append(f'${a:04X}: {b:<9} {t}')
    text = '\n'.join(lines)

    if args.out:
        with open(args.out, 'w', encoding='utf-8') as f:
            f.write(text + '\n')
        print(f'{len(rows)} 行 -> {args.out}')
    else:
        print(text)


if __name__ == '__main__':
    main()
