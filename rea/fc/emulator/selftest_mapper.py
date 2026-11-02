"""mapper / PRG 窗口自检（不依赖任何具体游戏的 ROM）。

    python selftest_mapper.py

重点是 NROM 的 PRG 窗口：
  16KB 的 NROM 会把同一块 ROM 镜像到 $8000-$BFFF 与 $C000-$FFFF，
  复位向量 $FFFC 就落在第二个窗口里——早期实现只做 addr-0x8000，
  读 $C000 以上会直接越界（16KB 的 NROM 游戏连启动都起不来）。
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
if HERE not in sys.path:
    sys.path.insert(0, HERE)

try:
    sys.stdout.reconfigure(encoding='utf-8')
except Exception:
    pass

FAILS = []


class FakeRom:
    """只提供 mapper 需要的那几个字段。"""

    def __init__(self, prg, chr_=b'', mapper=0, mirroring=1):
        self.prg = prg
        self.chr = chr_
        self.mapper = mapper
        self.mirroring = mirroring
        self.chr_ram_size = 8192 if not chr_ else 0
        self.prg_ram_size = 8192
        self.battery = False


def check(name, got, exp):
    if got != exp:
        FAILS.append('%s: 期望 %r，实际 %r' % (name, exp, got))


def test_nrom16k_mirror():
    from mappers import make_mapper
    prg = bytearray(16384)
    prg[0x0000] = 0x11                       # $8000
    prg[0x3FFF] = 0x22                       # $BFFF
    prg[0x3FFC] = 0x00                       # $FFFC 复位向量（落在镜像窗口）
    prg[0x3FFD] = 0x80
    m = make_mapper(FakeRom(bytes(prg)))
    check('16K NROM $8000', m.prg_read(0x8000), 0x11)
    check('16K NROM $BFFF', m.prg_read(0xBFFF), 0x22)
    check('16K NROM $C000 镜像', m.prg_read(0xC000), 0x11)
    check('16K NROM $FFFC 向量低位', m.prg_read(0xFFFC), 0x00)
    check('16K NROM $FFFD 向量高位', m.prg_read(0xFFFD), 0x80)


def test_nrom32k_no_mirror():
    from mappers import make_mapper
    prg = bytearray(32768)
    prg[0x0000] = 0x11                       # $8000
    prg[0x4000] = 0x33                       # $C000
    prg[0x7FFF] = 0x44                       # $FFFF
    m = make_mapper(FakeRom(bytes(prg)))
    check('32K NROM $8000', m.prg_read(0x8000), 0x11)
    check('32K NROM $C000 不镜像', m.prg_read(0xC000), 0x33)
    check('32K NROM $FFFF', m.prg_read(0xFFFF), 0x44)


def test_uxrom_bank_switch():
    from mappers import make_mapper
    prg = bytearray(32768)                   # 2 个 16KB bank
    prg[0x0000] = 0x0A                       # bank 0 @ $8000
    prg[0x4000] = 0x0B                       # bank 1 @ $C000 固定
    prg[0x7FFF] = 0x0C
    m = make_mapper(FakeRom(bytes(prg), mapper=2))
    check('UxROM 初始 bank0', m.prg_read(0x8000), 0x0A)
    m.prg_write(0x8000, 1)                   # 写 $8000-$FFFF 切 $8000 窗口
    check('UxROM 切到 bank1', m.prg_read(0x8000), 0x0B)
    check('UxROM $C000 固定 bank1', m.prg_read(0xC000), 0x0B)
    check('UxROM 向量区固定', m.prg_read(0xFFFF), 0x0C)


def main():
    tests = [v for k, v in sorted(globals().items()) if k.startswith('test_')]
    for t in tests:
        t()
    if FAILS:
        print('FAIL %d 项：' % len(FAILS))
        for f in FAILS:
            print('  -', f)
        return 1
    print('mapper 自检全部通过（%d 个用例）' % len(tests))
    return 0


if __name__ == '__main__':
    sys.exit(main())
