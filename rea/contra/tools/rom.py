"""魂斗罗1.nes 的 ROM 读取层（mapper 4 / MMC3，128KB PRG + 256KB CHR）。

只依赖标准库。坐标约定：
  文件偏移 = 16(头) + prg_off / chr_off
  PRG 里 8 个 16KB bank 在文件里是连续的，索引 0..7 对应 offset 0x0000,0x4000,...
  MMC3 寄存器 $8000 的 6 位选 bank，$A000-$BFFF 与 $C000-$DFFF 可换，
  $E000-$FFFF 固定为最后一个 8KB（= bank 7 的后半）。

用法：
    rom = Rom(r'C:\\Users\\Leopisces\\Desktop\\魂斗罗1.nes')
    rom.vector('RESET')          -> $F80D
    rom.bank(1)[0x1b21-0x8000]   -> 该地址的字节（假设该 bank 映射在 $8000）
"""
import struct


class Rom:
    def __init__(self, path):
        self.path = path
        self.data = open(path, 'rb').read()
        h = self.data[:16]
        if h[:4] != b'NES\x1a':
            raise ValueError('不是 iNES 文件')
        self.prg_banks = h[4]
        self.chr_banks = h[5]
        self.flags6 = h[6]
        self.flags7 = h[7]
        self.mapper = (h[6] >> 4) | (h[7] & 0xF0)
        self.prg = self.data[16:16 + self.prg_banks * 16384]
        self.chr = self.data[16 + self.prg_banks * 16384:]

    # ---- 通用 ----
    def vector(self, name):
        """NMI / RESET / IRQ 的地址（取自固定 bank 末尾 6 字节）。"""
        off = {'NMI': -6, 'RESET': -4, 'IRQ': -2}[name]
        return struct.unpack('<H', self.prg[off:off + 2])[0]

    def bank(self, n):
        """返回第 n 个 16KB bank 的 bytes（默认它映射在 $8000-$BFFF）。"""
        o = n * 16384
        return self.prg[o:o + 16384]

    def fixed8k(self):
        """$E000-$FFFF 固定 8KB（MMC3）。"""
        return self.prg[-8192:]

    def read_prg(self, addr, n=1):
        """读固定 bank（$C000-$FFFF）里的地址。"""
        if 0xE000 <= addr < 0x10000:
            off = len(self.prg) - 8192 + (addr - 0xE000)
        elif 0xC000 <= addr < 0xE000:
            off = len(self.prg) - 16384 + (addr - 0xC000)
        else:
            raise ValueError('$%04X 不在固定 bank' % addr)
        return self.prg[off:off + n]

    def word(self, addr):
        return struct.unpack('<H', self.read_prg(addr, 2))[0]

    def find(self, needle, start=0):
        """在 PRG 里找字节串，返回全部偏移（可带 '?' 通配，如 b'\\xa9?\\x8d\\x01\\x40'）。"""
        if isinstance(needle, str):
            needle = bytes(int(x, 16) for x in needle.split())
        out = []
        n = len(needle)
        i = start
        while True:
            i = self.prg.find(needle[:1], i)
            if i < 0:
                return out
            if '?' not in str(needle):
                if self.prg[i:i + n] == needle:
                    out.append(i)
                    i += 1
                else:
                    i += 1
            else:
                if self._match(needle, i):
                    out.append(i)
                    i += 1
                else:
                    i += 1

    def _match(self, needle, i):
        for k, b in enumerate(needle):
            if b == 0xFF and needle[k] == 0xFF:
                pass
            if i + k >= len(self.prg):
                return False
            if self.prg[i + k] != b:
                return False
        return True

    def rx(self, off, n=1):
        """按偏移直接读 PRG。"""
        return self.prg[off:off + n]

    def off_to_addr(self, off):
        """PRG 偏移 → 地址（假设该 bank 映射在 $8000）。"""
        bank = off // 16384
        return 0x8000 + (off % 16384)


if __name__ == '__main__':
    rom = Rom(r'C:\Users\Leopisces\Desktop\魂斗罗1.nes')
    print('%s: %d PRG banks, %d CHR banks, mapper %d' % (
        rom.path, rom.prg_banks, rom.chr_banks, rom.mapper))
    for v in ('NMI', 'RESET', 'IRQ'):
        print('  %-5s $%04X' % (v, rom.vector(v)))
