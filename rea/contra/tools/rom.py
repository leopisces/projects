"""Contra（魂斗罗1.nes，mapper 4 / MMC3）ROM 读取层。

实测布局（⚠️ 与 REPORT.md 早期记录不同，以本文件为准）：
  PRG = 8 × 16KB = 128KB
  CHR = 32 × 8KB = 256KB

MMC3 映射：
  $8000-$9FFF  = R6 指定的 8KB page（PRG bank 的低半）
  $A000-$BFFF  = R7 指定的 8KB page（PRG bank 的高半）
  $C000-$DFFF  = 倒数第二个 8KB page
  $E000-$FFFF  = 最后一个 8KB page（固定）

实测：文件里 bank7（最后 16KB）拆成两半：
  前半 = $C000-$DFFF（游戏主代码）
  后半 = $E000-$FFFF（复位/NMI/IRQ + 子系统）
  向量表位于文件末尾 6 字节：NMI=$F889 RESET=$F80D IRQ=$F8E1

CHR：32 个 8KB bank，每 bank 256 个 8×8 tile，2bpp 平面格式。
"""
import struct
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

PRG_BANK = 16384
CHR_BANK = 8192


class Rom:
    def __init__(self, path):
        with open(path, 'rb') as f:
            self.data = f.read()
        if self.data[:4] != b'NES\x1a':
            raise ValueError('不是 iNES 文件')
        self.prg_banks = self.data[4]
        self.chr_banks = self.data[5]
        self.flags6 = self.data[6]
        self.flags7 = self.data[7]
        self.mapper = (self.data[6] >> 4) | (self.data[7] & 0xF0)
        self.prg = self.data[16:16 + self.prg_banks * PRG_BANK]
        self.chr = self.data[16 + self.prg_banks * PRG_BANK:
                              16 + self.prg_banks * PRG_BANK + self.chr_banks * CHR_BANK]

    # ---- 向量 ----
    def vector(self, name):
        off = {'NMI': -6, 'RESET': -4, 'IRQ': -2}[name]
        # prg 是 bytes，负索引切片在 -2:0 得到空；显式换算
        start = len(self.prg) + off
        return struct.unpack('<H', self.prg[start:start + 2])[0]

    # ---- PRG ----
    def bank(self, n):
        """16KB bank n（映射到 $8000-$BFFF 时的内容）。"""
        o = n * PRG_BANK
        return self.prg[o:o + PRG_BANK]

    def page8k(self, n):
        """8KB page n（共 prg_banks*2 个）。"""
        o = n * 8192
        return self.prg[o:o + 8192]

    def fixed8k(self):
        """$E000-$FFFF 固定 8KB。"""
        return self.prg[len(self.prg) - 8192:]

    def read_prg(self, addr, n=1):
        """按 MMC3 默认映射读 PRG 地址。"""
        if 0xE000 <= addr <= 0xFFFF:
            return self.fixed8k()[addr - 0xE000:addr - 0xE000 + n]
        if 0xC000 <= addr < 0xE000:
            return self.prg[len(self.prg) - 16384:len(self.prg) - 8192][addr - 0xC000:][:n]
        raise ValueError('$%04X 不在固定 bank；切 bank 后用 page8k()' % addr)

    def word(self, addr):
        return struct.unpack('<H', self.read_prg(addr, 2))[0]

    def read_bank_addr(self, bank, addr, n=1):
        """在 16KB bank 内按 $8000 基址读。"""
        off = addr - 0x8000
        if off < 0 or off + n > PRG_BANK:
            raise ValueError('$%04X out of bank %d' % (addr, bank))
        return self.bank(bank)[off:off + n]

    # ---- CHR ----
    def chr_page(self, n):
        return self.chr[n * CHR_BANK:(n + 1) * CHR_BANK]

    def tile(self, chr_page, tile_idx):
        """返回一个 8×8 tile 的像素值矩阵（0-3），列表 of list of int。"""
        blk = self.chr_page(chr_page)
        o = tile_idx * 16
        rows = []
        for y in range(8):
            lo = blk[o + y]
            hi = blk[o + y + 8]
            rows.append([((lo >> (7 - x)) & 1) | (((hi >> (7 - x)) & 1) << 1)
                         for x in range(8)])
        return rows


# MMC3 PRG 8KB page 编号（R6/R7 写入值）→ 文件内 page 索引
def mmc3_prg_pages(prg):
    """把 128KB PRG 拆成 16 个 8KB page。"""
    return [prg[i * 8192:(i + 1) * 8192] for i in range(len(prg) // 8192)]


if __name__ == '__main__':
    import sys
    rom = Rom(sys.argv[1] if len(sys.argv) > 1 else r'C:\Users\Leopisces\Desktop\魂斗罗1.nes')
    print(f'PRG {rom.prg_banks}×16KB = {len(rom.prg)} 字节')
    print(f'CHR {rom.chr_banks}×8KB  = {len(rom.chr)} 字节')
    print(f'mapper {rom.mapper}')
    print(f'RESET=${rom.vector("RESET"):04X} NMI=${rom.vector("NMI"):04X} IRQ=${rom.vector("IRQ"):04X}')
    print()
    print('16KB bank 首字节（bank 标记）:')
    for i in range(rom.prg_banks):
        b = rom.bank(i)
        nz = sum(1 for x in b if x)
        print(f'  bank{i}: [{b[0]:02X}] nonzero={nz:6d}  {b[1:13].hex(" ")}')
