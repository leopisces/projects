"""PPU 自检：不依赖任何 ROM，直接按硬件规格构造 nametable/CHR/调色板，
逐条验证背景滚动、属性、裁切、精灵、精灵 0 命中、调色板镜像。

运行：python emulator/selftest_ppu.py
全部通过时退出码 0。
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import nes_ppu  # noqa: E402
from nes_ppu import NES_RGB, PPU  # noqa: E402

FAILS = []


class FakeCart:
    def __init__(self, mirroring=0):
        self.mirroring = mirroring
        self.chr = bytearray(8192)

    def chr_read(self, addr):
        return self.chr[addr & 0x1FFF]

    def chr_write(self, addr, val):
        self.chr[addr & 0x1FFF] = val


def make_ppu(mirroring=0):
    cart = FakeCart(mirroring)
    p = PPU(cart)
    # 背景调色板：0=黑, 1=红, 2=蓝, 3=白（用真实 NES 色号）
    for i, c in enumerate((0x0F, 0x16, 0x12, 0x30)):
        p.write(0x3F00 + i, c)
    for i, c in enumerate((0x0F, 0x27, 0x2A, 0x30)):
        p.write(0x3F04 + i, c)
    for i, c in enumerate((0x0F, 0x12, 0x16, 0x30)):
        p.write(0x3F08 + i, c)
    for i, c in enumerate((0x0F, 0x1A, 0x25, 0x30)):
        p.write(0x3F0C + i, c)
    # 精灵调色板 0..3 各自同色系
    for slot in range(4):
        p.write(0x3F10 + slot * 4 + 0, 0x0F)
        p.write(0x3F10 + slot * 4 + 1, (0x16, 0x1A, 0x27, 0x12)[slot])
        p.write(0x3F10 + slot * 4 + 2, (0x12, 0x25, 0x2A, 0x30)[slot])
        p.write(0x3F10 + slot * 4 + 3, 0x30)
    p.mask = 0x1E          # 开背景/精灵，左 8 像素不裁切
    p.ctrl = 0x00
    p.oam = bytearray([0xF8] * 256)     # 所有精灵在屏外
    return p


def tile(p, base, rows):
    """rows: 8 个 (lo, hi) 字节，写入图案表偏移 base 的 tile。"""
    for i, (lo, hi) in enumerate(rows):
        p.cart.chr[base + i] = lo
        p.cart.chr[base + i + 8] = hi


def color_of(p, x, y):
    fb = p.framebuffer
    o = (y * 256 + x) * 3
    return (fb[o], fb[o + 1], fb[o + 2])


def want(p, idx):
    return tuple(NES_RGB[p.palette[idx] & 0x3F])


def rgb(p, idx):
    return tuple(NES_RGB[p.palette[idx] & 0x3F])


def check(name, got, exp):
    if got != exp:
        FAILS.append('%s: got %s want %s' % (name, got, exp))


# ---------------------------------------------------------------- 测试
def test_solid_tile_and_palette():
    """tile 0 = 全 0（透明），tile 1 单像素，验证像素 0 用全局背景色。"""
    p = make_ppu()
    # nametable 行 0 全部 tile 0
    p.write(0x2000, 0)          # 注意 $2000 是 PPUCTRL，改用 vram 直写
    p = make_ppu()
    p.vram[0:0x400] = bytearray(0x400)
    # tile 1：左上角一个点（颜色 1）
    tile(p, 16, [(0x80, 0x00)] + [(0, 0)] * 7)
    p.vram[0] = 1               # nametable (0,0) 用 tile 1
    p.v = 0x0000
    p.render_scanline(0)
    check('单像素左上', color_of(p, 0, 0), want(p, 1))
    check('单像素右侧透明', color_of(p, 1, 0), want(p, 0))


def test_attr_quadrants():
    """属性表 4 个象限 → 4 个调色板（16x16 像素为一个象限）。"""
    p = make_ppu()
    for t in range(4):
        tile(p, (t + 1) * 16, [(0xFF, 0x00)] * 8)     # 该 tile 整行颜色 1
    p.vram[0] = 1        # (col 0, row 0) 左上象限
    p.vram[2] = 2        # (col 2, row 0) 右上象限
    p.vram[64] = 3       # (col 0, row 2) 左下象限
    p.vram[66] = 4       # (col 2, row 2) 右下象限
    p.vram[0x3C0] = 0b11_10_01_00
    p.v = 0
    p.render_scanline(0)
    check('attr 左上=调色板0/色1', color_of(p, 0, 0), rgb(p, 1))
    check('attr 右上=调色板1/色1', color_of(p, 16, 0), rgb(p, 5))
    p.v = 2 << 5
    p.render_scanline(16)
    check('attr 左下=调色板2/色1', color_of(p, 0, 16), rgb(p, 9))
    check('attr 右下=调色板3/色1', color_of(p, 16, 16), rgb(p, 13))


def test_fine_x():
    """fine X=3：tile 内像素整体左移 3 像素。"""
    p = make_ppu()
    tile(p, 16, [(0x0F, 0x00)] * 8)          # 右 4 像素为颜色 1
    p.vram[0] = 1
    p.v = 0
    p.render_scanline(0)
    check('fine_x=0 首像素透明', color_of(p, 3, 0), want(p, 0))
    check('fine_x=0 x=4 有色', color_of(p, 4, 0), want(p, 1))
    p.fine_x = 3
    p.render_scanline(0)
    check('fine_x=3 x=1 有色', color_of(p, 1, 0), want(p, 1))
    check('fine_x=3 x=0 透明', color_of(p, 0, 0), want(p, 0))


def test_fine_y():
    """v 的 fine Y 选中 tile 内哪一行。"""
    p = make_ppu()
    rows = [(0, 0)] * 8
    rows[3] = (0xFF, 0x00)                   # 第 4 行有颜色
    tile(p, 16, rows)
    p.vram[0] = 1
    p.v = 0x3000                              # fine Y = 3
    p.render_scanline(0)
    check('fine_y=3 取第 4 行', color_of(p, 0, 0), want(p, 1))
    p.v = 0x2000                              # fine Y = 2
    p.render_scanline(0)
    check('fine_y=2 无颜色', color_of(p, 0, 0), want(p, 0))


def test_coarse_scroll():
    """coarse Y=2 时读 nametable 第 2 行。"""
    p = make_ppu()
    tile(p, 16, [(0xFF, 0x00)] * 8)
    p.vram[2 * 32] = 1                        # 第 3 行第一个 tile
    p.v = 2 << 5
    p.render_scanline(0)
    check('coarse_y=2', color_of(p, 0, 0), want(p, 1))


def test_nametable_flip():
    """水平镜像：coarse X=30、NT=0 时右侧越过界进 NT1。"""
    p = make_ppu(mirroring=0)                 # 垂直镜像，NT1 物理独立
    tile(p, 16, [(0xFF, 0x00)] * 8)
    p.vram[0x400 + 0] = 1                     # NT1 的 (0,0)
    p.v = 30 | 0x0000
    p.render_scanline(0)
    # 30,31 是 NT0 的空 tile；x=16..23 应来自 NT1 的 (2,0)
    check('NT0 x=0 透明', color_of(p, 0, 0), want(p, 0))
    check('跨 NT 后 x=16 有色', color_of(p, 16, 0), rgb(p, 1))


def test_left_clip():
    p = make_ppu()
    tile(p, 16, [(0xFF, 0x00)] * 8)
    p.vram[0] = 1
    p.vram[1] = 1
    p.v = 0
    p.mask = 0x18                              # 背景开，左 8 像素裁切
    p.render_scanline(0)
    check('背景左裁切 x=0', color_of(p, 0, 0), want(p, 0))
    check('背景左裁切 x=8', color_of(p, 8, 0), rgb(p, 1))
    p.mask = 0x1A                              # 不裁切
    p.render_scanline(0)
    check('不裁切 x=0', color_of(p, 0, 0), rgb(p, 1))


def test_sprite_basic():
    p = make_ppu()
    p.mask = 0x1E
    p.ctrl = 0x08                              # 精灵图案表 0x1000
    tile(p, 0x1000 + 2 * 16, [(0xFF, 0x00)] * 8)
    p.oam[0:4] = bytes([49, 2, 0x00, 99])      # Y=50, tile 2, pal 0, X=99
    p.render_scanline(50)
    check('精灵像素', color_of(p, 99, 50), rgb(p, 0x11))
    p.render_scanline(49)
    check('精灵未到', color_of(p, 99, 49), want(p, 0))


def test_sprite_flip():
    p = make_ppu()
    p.ctrl = 0x08
    tile(p, 0x1000 + 2 * 16, [(0x80, 0x00)] * 8)   # 左侧一列
    p.oam[0:4] = bytes([0, 2, 0x40, 0])            # Y=1, 水平翻转
    p.mask = 0x1E
    p.render_scanline(1)
    check('水平翻转', color_of(p, 7, 1), rgb(p, 0x11))
    p.oam[2] = 0x80                                # 垂直翻转
    tile(p, 0x1000 + 2 * 16, [(0, 0)] * 7 + [(0x80, 0x00)])
    p.render_scanline(1)
    check('垂直翻转', color_of(p, 0, 1), rgb(p, 0x11))


def test_sprite_8x16():
    p = make_ppu()
    p.ctrl = 0x28                              # 8x16 精灵，图案表 0x1000
    tile(p, 0x1000 + 2 * 16, [(0, 0)] * 8)     # 上半张空（tile 2，bit0=0 → 表 0x1000）
    tile(p, 0x1000 + 3 * 16, [(0xFF, 0x00)] * 8)   # 下半张有色（tile 3）
    p.oam[0:4] = bytes([9, 3, 0x00, 50])       # Y=10 起 16 像素，tile 3&0xFE=2
    p.mask = 0x1E
    p.render_scanline(10)
    check('8x16 上半张', color_of(p, 50, 10), want(p, 0))
    p.render_scanline(18)
    check('8x16 下半张', color_of(p, 50, 18), rgb(p, 0x11))


def test_sprite_priority():
    """背景不透明 + 精灵在后 → 显示背景。"""
    p = make_ppu()
    p.ctrl = 0x08
    tile(p, 16, [(0xFF, 0x00)] * 8)                       # 背景 tile 1
    tile(p, 0x1000 + 2 * 16, [(0xFF, 0x00)] * 8)           # 精灵 tile 2
    p.vram[0] = 1
    p.v = 0
    p.oam[0:4] = bytes([0, 2, 0x20, 0])                   # Y=1, 属性 bit5=1 在背景后
    p.mask = 0x1E
    p.render_scanline(1)
    check('精灵在背景后', color_of(p, 0, 1), rgb(p, 1))


def test_sprite0_hit():
    p = make_ppu()
    p.ctrl = 0x08
    tile(p, 16, [(0xFF, 0x00)] * 8)
    tile(p, 0x1000 + 2 * 16, [(0xFF, 0x00)] * 8)
    p.vram[0] = 1
    p.v = 0
    p.oam[0:4] = bytes([0, 2, 0x00, 0])
    p.mask = 0x1E
    p.sprite0_hit = False
    p.render_scanline(1)
    check('精灵0命中置位', bool(p.sprite0_hit), True)
    # 背景透明处不命中
    p2 = make_ppu()
    p2.ctrl = 0x08
    tile(p2, 0x1000 + 2 * 16, [(0xFF, 0x00)] * 8)
    p2.v = 0
    p2.oam[0:4] = bytes([0, 2, 0x00, 0])
    p2.mask = 0x1E
    p2.sprite0_hit = False
    p2.render_scanline(1)
    check('背景透明不命中', bool(p2.sprite0_hit), False)


def test_palette_mirror():
    p = make_ppu()
    p.write(0x3F10, 0x16)
    check('$3F10 镜像到 $3F00', p.read(0x3F00), 0x16)


def test_scroll_reload():
    """end_line：v 的水平位从 t 重载，Y 递增。"""
    p = make_ppu()
    p.t = 0x041F                              # 水平 31，Y 位 0
    p.v = 0x0000
    p.end_line()
    check('水平重载', p.v & 0x041F, 0x041F)
    check('fine Y 递增', (p.v >> 12) & 7, 1)
    p2 = make_ppu()
    p2.v = 0x7000 | (29 << 5)                 # fine Y=7, coarse Y=29
    p2.t = 0
    p2.end_line()
    check('Y 溢出回 0', (p2.v >> 12) & 7, 0)
    check('Y=29 翻页', (p2.v >> 5) & 0x1F, 0)
    check('翻页切 nametable', (p2.v >> 11) & 1, 1)


def test_v_advance_render_off_in_vblank():
    """回归：可见行开了渲染、垂直空白关渲染时，v 仍必须推进并回卷到 t。

    旧代码 `end_line()` / `start_frame()` 都只在 `mask & 0x18` 时调用，游戏
    在垂直空白整帧关渲染做大块上传时 v 就停在第 240 行，进关后顶部出现
    16 行黑带。这里直接跑真 NES：可见行开渲染，扫到第 241 行立刻关渲染。
    """
    import tempfile
    from nes import NES
    prg = bytes([0x4C, 0x00, 0x80]) + bytes([0xEA]) * (0x7FFC - 3) \
        + bytes([0x00, 0x80]) + bytes([0xEA]) * 2   # $8000: JMP $8000 死循环
    blob = bytearray(b'NES\x1a') + bytes([1, 1, 0, 0]) + bytes(8)
    blob += prg + bytes(8192)
    fd, path = tempfile.mkstemp(suffix='.nes')
    os.write(fd, bytes(blob))
    os.close(fd)
    try:
        e = NES(path)
        e.ppu.t = 0
        e.ppu.v = 0
        e.ppu.mask = 0x1E
        for _ in range(200000):
            if e.ppu.scanline >= 241:
                e.ppu.mask = 0            # 垂直空白一开始就关渲染（大块上传期）
                break
            e.step_cpu()
        check('扫到 240 行时 v 已推进', e.ppu.rendered_lines, 240)
        frame = e.ppu.frame
        while e.ppu.frame == frame:
            e.step_cpu()
        check('关渲染的空白期也推进 v（回卷到 t）', e.ppu.v, 0)
        check('rendered_lines 已清零', e.ppu.rendered_lines, 0)
    finally:
        os.unlink(path)


def main():
    tests = [v for k, v in sorted(globals().items()) if k.startswith('test_')]
    for t in tests:
        t()
    if FAILS:
        print('FAIL %d 项：' % len(FAILS))
        for f in FAILS:
            print('  -', f)
        return 1
    print('PPU 自检全部通过（%d 个用例）' % len(tests))
    return 0


if __name__ == '__main__':
    sys.exit(main())
