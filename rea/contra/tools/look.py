"""查看反汇编清单里某些地址附近的代码。"""
import argparse
import os
import re
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

DEFAULT = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                       '..', 'temp', 'fixed.asm')


def load(path):
    lines = open(path, encoding='utf-8').read().splitlines()
    idx = {}
    for i, l in enumerate(lines):
        m = re.match(r'^\$([0-9A-Fa-f]{4}):', l)
        if m:
            idx[int(m.group(1), 16)] = i
    return lines, idx


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('addrs', nargs='+', help='十六进制地址')
    ap.add_argument('-n', '--num', type=int, default=20)
    ap.add_argument('-f', '--file', default=DEFAULT)
    args = ap.parse_args()

    lines, idx = load(args.file)
    for s in args.addrs:
        a = int(s, 16)
        print('=' * 60)
        print('$%04X' % a)
        i = idx.get(a)
        if i is None:
            print('  (该地址不在反汇编范围内)')
            continue
        for l in lines[i:i + args.num]:
            print(l)
        print()


if __name__ == '__main__':
    main()
