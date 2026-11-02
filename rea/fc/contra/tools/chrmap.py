"""完整的 MMC3 CHR 映射 + 背景 tile 来源解析。

MMC3 CHR-A 模式（R0 的 bit7 = 0）：
  $0000-$07FF (2KB) = R0 指定的 2KB bank  → 8KB page = (R0 & 0x3F) // 4，
                                           页内偏移 = (R0 & 3) * 2KB
  $0800-$0FFF (2KB) = R1 同理
  $1000-$13FF (1KB) = R2 → 8KB page = R2 // 8，页内偏移 = (R2 % 8) * 1KB
  $1400-$17FF (1KB) = R3
  $1800-$1BFF (1KB) = R4
  $1C00-$1FFF (1KB) = R5

MMC3 CHR-B 模式（R0 的 bit7 = 1）：
  $0000-$03FF (1KB) = R2, $0400-$07FF = R3, $0800-$0BFF = R4, $0C00-$0FFF = R5
  $1000-$17FF (2KB) = R0, $1800-$1FFF (2KB) = R1

关键：$FACE 把 $07F0..$07F7 依次写进 R0..R5（然后 $07F6/$07F7 也被写）。
对 32 个 8KB CHR page 的 ROM，R 值的有效范围要按 8KB page 解释。
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, '..', 'python'))

try:
    sys.stdout.reconfigure(encoding='utf-8')
except Exception:
    pass


class ChrMapper:
    """给定 R0..R7，把 CHR 地址映射到 (8KB page, 页内偏移)。"""

    def __init__(self, r, chr_mode=0):
        self.r = r
        self.chr_mode = chr_mode       # R0 bit7

    def locate(self, addr):
        """返回 (page, offset_in_8k)。"""
        a = addr & 0x1FFF
        r = self.r
        if self.chr_mode == 0:
            # A 模式
            if a < 0x0800:
                v = r[0]
                base2k = v & 0x3F             # 2KB bank 号
                return (base2k * 2048) // 8192, ((base2k * 2048) % 8192) + a
            if a < 0x1000:
                v = r[1]
                base2k = v & 0x3F
                return (base2k * 2048) // 8192, ((base2k * 2048) % 8192) + (a - 0x800)
            slot = (a - 0x1000) // 0x400       # 0..3 → R2..R5
            off = (a - 0x1000) % 0x400
            v = r[2 + slot]
            b1k = v & 0x7F                     # 1KB bank 号
            return (b1k * 1024) // 8192, ((b1k * 1024) % 8192) + off
        # B 模式
        if a < 0x1000:
            slot = a // 0x400                  # 0..3 → R2..R5
            off = a % 0x400
            v = r[2 + slot]
            b1k = v & 0x7F
            return (b1k * 1024) // 8192, ((b1k * 1024) % 8192) + off
        v = r[0] if a < 0x1800 else r[1]
        base2k = v & 0x3F
        off = a - (0x1000 if a < 0x1800 else 0x1800)
        return (base2k * 2048) // 8192, ((base2k * 2048) % 8192) + off


def tile_pixels(rom, mapper, chr_addr):
    """读一个 8×8 tile（2bpp）→ [[0-3]×8]×8。"""
    page, off = mapper.locate(chr_addr)
    if page >= rom.chr_banks:
        page %= rom.chr_banks
    blk = rom.chr_page(page)
    o = off & 0x1FFF
    if o + 16 > len(blk):
        return [[0] * 8 for _ in range(8)]
    out = []
    for y in range(8):
        lo = blk[o + y]
        hi = blk[o + y + 8]
        out.append([((lo >> (7 - x)) & 1) | (((hi >> (7 - x)) & 1) << 1)
                    for x in range(8)])
    return out


if __name__ == '__main__':
    # 自检：A 模式下 PT1 起始（$1000）应指向 R2
    r = [0x04, 0x04, 0x06, 0x07, 0x44, 0x45, 0x46, 0x47]
    m = ChrMapper(r, 0)
    for a in (0x0000, 0x1000, 0x1400, 0x1800, 0x1C00):
        print(f'${a:04X} → page {m.locate(a)[0]}, off ${m.locate(a)[1]:04X}')
