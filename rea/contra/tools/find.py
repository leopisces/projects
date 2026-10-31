"""在反汇编清单里搜索指令/操作数。"""
import argparse
import os
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

DEFAULT = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                       '..', 'temp', 'fixed.asm')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('patterns', nargs='+', help='要搜索的子串（不分大小写）')
    ap.add_argument('-f', '--file', default=DEFAULT)
    ap.add_argument('-c', '--context', type=int, default=0)
    args = ap.parse_args()

    lines = open(args.file, encoding='utf-8').read().splitlines()
    pats = [p.lower() for p in args.patterns]
    for i, l in enumerate(lines):
        low = l.lower()
        if all(p in low for p in pats):
            lo = max(0, i - args.context)
            hi = min(len(lines), i + args.context + 1)
            for j in range(lo, hi):
                mark = '>' if j == i else ' '
                print(mark, lines[j])
            if args.context:
                print()


if __name__ == '__main__':
    main()
