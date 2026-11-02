"""通用 iNES / NES 2.0 文件解析（不依赖任何具体游戏）。

只做「文件 → 头信息 + PRG ROM + CHR ROM」这一层，mapper 逻辑在 mappers.py。

    rom = INes(path)
    rom.mapper      映射器编号（0=NROM, 1=MMC1, 2=UxROM, 3=CNROM, 4=MMC3, 7=AxROM, ...）
    rom.prg         PRG ROM 字节串（16KB 的整数倍）
    rom.chr         CHR ROM 字节串（8KB 的整数倍，长度 0 表示卡带上是 CHR-RAM）
    rom.mirroring   0=垂直 1=水平 2=单屏低 3=单屏高 4=四屏
    rom.battery     是否有电池存档
    rom.vector('RESET' / 'NMI' / 'IRQ')
"""
import os
import struct

PRG_BANK = 16384
CHR_BANK = 8192

MAGIC = b'NES\x1a'

# iNES mapper 号 → 名字（只列已实现的 + 常见的一批，用于报错提示）
MAPPER_NAMES = {
    0: 'NROM',
    1: 'MMC1',
    2: 'UxROM (UNROM/UOROM)',
    3: 'CNROM',
    4: 'MMC3 (TxROM)',
    7: 'AxROM',
    9: 'MMC2',
    10: 'MMC4',
    11: 'ColorDreams',
    13: 'CPROM',
    66: 'GxROM',
    71: 'Camerica',
    79: 'NINA-03/06',
}


class INesError(Exception):
    pass


class INes:
    """iNES 文件。

    兼容 iNES 与 NES 2.0 头；NES 2.0 的扩展 mapper 号（bit 8-11）也会算进去。
    """

    def __init__(self, path):
        self.path = os.path.abspath(path)
        with open(path, 'rb') as f:
            data = f.read()
        if len(data) < 16 or data[:4] != MAGIC:
            raise INesError('不是 iNES 文件：%s' % path)
        self.data = data
        h = data[:16]

        self.nes2 = (h[7] & 0x0C) == 0x08
        flags6, flags7 = h[6], h[7]
        self.flags6 = flags6

        mapper = (flags6 >> 4) | (flags7 & 0xF0)
        if self.nes2:
            mapper |= (h[8] & 0x0F) << 8
        self.mapper = mapper

        # 镜像
        if flags6 & 0x08:
            self.mirroring = 4                       # 四屏
        else:
            self.mirroring = 0 if (flags6 & 0x01) else 1   # 0=垂直 1=水平

        self.battery = bool(flags6 & 0x02)
        self.trainer = bool(flags6 & 0x04)

        if self.nes2:
            prg_units = (h[4] | ((h[9] & 0x0F) << 8))
            chr_units = (h[5] | ((h[10] & 0x0F) << 8))
            prg_size = self._nes2_size(prg_units, h[9] >> 4)
            chr_size = self._nes2_size(chr_units, h[10] >> 4)
            prg_ram_units = h[10] & 0x0F
            self.prg_ram_size = prg_ram_units * 8192 if prg_ram_units else 0
            self.chr_ram_size = 0
        else:
            prg_size = h[4] * PRG_BANK
            chr_size = h[5] * CHR_BANK
            self.prg_ram_size = 8192
            self.chr_ram_size = 8192 if chr_size == 0 else 0

        offset = 16 + (512 if self.trainer else 0)
        self.prg = data[offset:offset + prg_size]
        self.chr = data[offset + prg_size:offset + prg_size + chr_size]

        if not self.prg:
            raise INesError('PRG ROM 为空（头信息损坏？）：%s' % path)

        # 兼容旧接口
        self.prg_banks = len(self.prg) // PRG_BANK
        self.chr_banks = len(self.chr) // CHR_BANK
        self.chr_ram = not self.chr

    # ---------- NES 2.0 尺寸编码 ----------
    @staticmethod
    def _nes2_size(units, upper):
        """NES 2.0：尺寸 = units * 2^upper（units 为 0 时按 2^upper 理解为 0）。"""
        if upper == 0:
            return units * 16384 if units else 0
        return units << upper

    # ---------- 向量 ----------
    def vector(self, name):
        off = {'NMI': -6, 'RESET': -4, 'IRQ': -2}[name]
        start = len(self.prg) + off
        return struct.unpack('<H', self.prg[start:start + 2])[0]

    # ---------- PRG ----------
    def bank(self, n):
        """16KB bank。"""
        return self.prg[n * PRG_BANK:(n + 1) * PRG_BANK]

    def page8k(self, n):
        return self.prg[n * 8192:(n + 1) * 8192]

    def fixed8k(self):
        return self.prg[len(self.prg) - 8192:]

    def read_fixed(self, addr, n=1):
        return self.fixed8k()[addr - 0xE000:addr - 0xE000 + n]

    def read_bank(self, bank, addr, n=1):
        off = addr - 0x8000
        return self.bank(bank)[off:off + n]

    # ---------- CHR ----------
    def chr_page(self, n):
        return self.chr[n * CHR_BANK:(n + 1) * CHR_BANK]

    def tile_2bpp(self, chr_page, tile_idx):
        """8×8 tile → [[0-3]×8]×8。"""
        blk = self.chr_page(chr_page)
        o = tile_idx * 16
        out = []
        for y in range(8):
            lo = blk[o + y]
            hi = blk[o + y + 8]
            out.append([((lo >> (7 - x)) & 1) | (((hi >> (7 - x)) & 1) << 1)
                        for x in range(8)])
        return out

    # ---------- 描述 ----------
    def mapper_name(self):
        return MAPPER_NAMES.get(self.mapper, 'mapper %d' % self.mapper)

    def describe(self):
        return ('%s  PRG %dKB  CHR %s  mapper %d (%s)  %s镜像%s' % (
            os.path.basename(self.path),
            len(self.prg) // 1024,
            ('%dKB' % (len(self.chr) // 1024)) if self.chr else 'RAM 8KB',
            self.mapper, self.mapper_name(),
            {0: '垂直', 1: '水平', 2: '单屏低', 3: '单屏高', 4: '四屏'}.get(self.mirroring, '?'),
            '  电池' if self.battery else ''))


def tile_to_rgb(tile, palette, nes_palette=None):
    """tile 像素值(0-3) + 4 个调色板索引 → 8×8 RGB。"""
    from palette import NES_PALETTE
    pal = nes_palette or NES_PALETTE
    cols = [pal[p & 0x3F] for p in palette]
    return [[cols[v] for v in row] for row in tile]
