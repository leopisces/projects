"""mapper（卡带映射器）实现 —— 通用，按 iNES mapper 号自动选择。

已实现：
    0   NROM        16/32KB PRG 固定，8KB CHR（ROM 或 RAM）
    1   MMC1        序列寄存器 5 位，PRG 16/32KB 切 bank，CHR 4/8KB，镜像可改
    2   UxROM       $8000 16KB 可切，$C000 固定最后一片
    3   CNROM       PRG 固定，8KB CHR 切 bank
    4   MMC3        8KB PRG 四窗口 + 1KB CHR + A12 扫描线 IRQ + 镜像可改
    7   AxROM       32KB PRG 切 bank + 单屏镜像
    11  ColorDreams
    13  CPROM       16KB PRG + 16KB CHR-RAM
    66  GxROM

接口（NES 总线用）：
    m.prg_read(addr)         $8000-$FFFF
    m.prg_write(addr, val)
    m.prg_ram_read(addr)     $6000-$7FFF
    m.prg_ram_write(addr, val)
    m.chr_read(addr)         $0000-$1FFF（PPU 侧）
    m.chr_write(addr, val)
    m.clock_irq()            A12 上升沿 / 每扫描线一次
    m.mirroring             0=垂直 1=水平 2=单屏低 3=单屏高 4=四屏
    m.irq_pending           置位表示要拉 CPU IRQ（NES 侧读完自动清）
"""


class Mapper:
    name = 'base'
    has_irq = False
    irq_pending = False

    def __init__(self, rom):
        self.rom = rom
        self.prg = rom.prg
        self.chr = rom.chr
        self.prg_ram = bytearray(rom.prg_ram_size or 0x2000)
        self.chr_ram = bytearray(rom.chr_ram_size or 0x2000) if not rom.chr else None
        self.mirroring = rom.mirroring
        self.irq_pending = False

    # ---------- PRG ----------
    def prg_read(self, addr):
        raise NotImplementedError

    def prg_write(self, addr, val):
        pass

    def prg_ram_read(self, addr):
        if not self.prg_ram:
            return 0
        return self.prg_ram[(addr - 0x6000) % len(self.prg_ram)]

    def prg_ram_write(self, addr, val):
        if self.prg_ram:
            self.prg_ram[(addr - 0x6000) % len(self.prg_ram)] = val & 0xFF

    def _prg_byte(self, offset):
        if not self.prg:
            return 0
        return self.prg[offset % len(self.prg)]

    # ---------- CHR ----------
    def chr_read(self, addr):
        a = addr & 0x1FFF
        if self.chr_ram is not None:
            return self.chr_ram[a % len(self.chr_ram)]
        return self.chr[a % len(self.chr)] if self.chr else 0xFF

    def chr_write(self, addr, val):
        if self.chr_ram is not None:
            self.chr_ram[(addr & 0x1FFF) % len(self.chr_ram)] = val & 0xFF

    # ---------- IRQ ----------
    def clock_irq(self):
        pass

    def reset(self):
        self.irq_pending = False

    @property
    def prg_8k_count(self):
        return max(1, len(self.prg) // 8192)

    @property
    def chr_1k_count(self):
        src = self.chr if self.chr else self.chr_ram
        return max(1, len(src) // 1024)


# =====================================================================
# 0 NROM
# =====================================================================
class NROM(Mapper):
    name = 'NROM'

    def __init__(self, rom):
        super().__init__(rom)
        self.prg_off = 0
        if len(self.prg) == 16384:               # 16KB 镜像到 $8000-$FFFF
            self.prg_off = -0x8000
        self.prg_mask = len(self.prg) - 1        # 2 的幂：16KB→0x3FFF，32KB→0x7FFF

    def prg_read(self, addr):
        # 16KB 的 NROM（如 Donkey Kong / Balloon Fight）把同一块镜像到
        # $8000-$BFFF 和 $C000-$FFFF 两个窗口；只减 0x8000 会让 $C000 以上
        # （包括复位向量 $FFFC）越界，所以按 16KB 掩码回绕。
        return self.prg[(addr - 0x8000) & self.prg_mask]


# =====================================================================
# 2 UxROM
# =====================================================================
class UxROM(Mapper):
    name = 'UxROM'

    def __init__(self, rom):
        super().__init__(rom)
        self.banks = max(1, len(self.prg) // 16384)
        self.prg_off = 0                        # 当前 $8000 窗口在 PRG 里的字节偏移
        self.fixed_off = (self.banks - 1) * 16384

    def prg_read(self, addr):
        if addr >= 0xC000:
            return self.prg[self.fixed_off + (addr - 0xC000)]
        return self.prg[self.prg_off + (addr - 0x8000)]

    def prg_write(self, addr, val):
        self.prg_off = (val % self.banks) * 16384


# =====================================================================
# 3 CNROM
# =====================================================================
class CNROM(Mapper):
    name = 'CNROM'

    def __init__(self, rom):
        super().__init__(rom)
        self.chr_bank = 0

    def prg_read(self, addr):
        return self._prg_byte(addr - 0x8000)

    def prg_write(self, addr, val):
        self.chr_bank = val & 0x03

    def chr_read(self, addr):
        off = self.chr_bank * 8192 + (addr & 0x1FFF)
        if self.chr_ram is not None:
            return self.chr_ram[off % len(self.chr_ram)]
        return self.chr[off % len(self.chr)]

    def chr_write(self, addr, val):
        if self.chr_ram is not None:
            off = self.chr_bank * 8192 + (addr & 0x1FFF)
            self.chr_ram[off % len(self.chr_ram)] = val & 0xFF


# =====================================================================
# 7 AxROM
# =====================================================================
class AxROM(Mapper):
    name = 'AxROM'

    def __init__(self, rom):
        super().__init__(rom)
        self.bank = 0

    def prg_read(self, addr):
        return self._prg_byte(self.bank * 32768 + (addr - 0x8000))

    def prg_write(self, addr, val):
        self.bank = val & 0x07
        self.mirroring = 2 + ((val >> 4) & 1)     # 单屏低 / 单屏高


# =====================================================================
# 11 ColorDreams / 66 GxROM
# =====================================================================
class ColorDreams(Mapper):
    name = 'ColorDreams'

    def __init__(self, rom):
        super().__init__(rom)
        self.prg_bank = 0
        self.chr_bank = 0

    def prg_read(self, addr):
        return self._prg_byte(self.prg_bank * 32768 + (addr - 0x8000))

    def prg_write(self, addr, val):
        self.prg_bank = val & 0x03
        self.chr_bank = (val >> 4) & 0x0F

    def chr_read(self, addr):
        off = self.chr_bank * 8192 + (addr & 0x1FFF)
        if self.chr_ram is not None:
            return self.chr_ram[off % len(self.chr_ram)]
        return self.chr[off % len(self.chr)]


class GxROM(ColorDreams):
    name = 'GxROM'

    def prg_write(self, addr, val):
        self.prg_bank = (val >> 4) & 0x03
        self.chr_bank = val & 0x03


# =====================================================================
# 13 CPROM
# =====================================================================
class CPROM(Mapper):
    name = 'CPROM'

    def __init__(self, rom):
        super().__init__(rom)
        if self.chr_ram is None:
            self.chr_ram = bytearray(0x4000)
        else:
            self.chr_ram = bytearray(0x4000)
        self.bank = 0

    def prg_read(self, addr):
        return self._prg_byte(addr - 0x8000)

    def prg_write(self, addr, val):
        self.bank = val & 0x03

    def chr_read(self, addr):
        a = addr & 0x1FFF
        if a >= 0x1000:
            off = 0x3000 + (a - 0x1000)
        else:
            off = self.bank * 0x1000 + a
        return self.chr_ram[off % len(self.chr_ram)]

    def chr_write(self, addr, val):
        a = addr & 0x1FFF
        off = 0x3000 + (a - 0x1000) if a >= 0x1000 else self.bank * 0x1000 + a
        self.chr_ram[off % len(self.chr_ram)] = val & 0xFF


# =====================================================================
# 1 MMC1
# =====================================================================
class MMC1(Mapper):
    name = 'MMC1'

    def __init__(self, rom):
        super().__init__(rom)
        self.shift = 0x10          # bit4 = 已收满 5 位的标志
        self.control = 0x0C
        self.chr0 = 0
        self.chr1 = 0
        self.prg0 = 0
        self.prg_ram_enable = True
        self._apply_control()

    def _apply_control(self):
        m = self.control & 0x03
        self.mirroring = 0 if m == 2 else 1 if m == 3 else (2 if m == 0 else 3)

    def prg_write(self, addr, val):
        if val & 0x80:                       # 复位序列寄存器
            self.shift = 0x10
            self.control |= 0x0C
            self._apply_control()
            return
        done = self.shift & 1
        self.shift = ((self.shift >> 1) | ((val & 1) << 4)) & 0x1F
        if not done:
            return
        value = self.shift & 0x1F
        self.shift = 0x10
        reg = (addr >> 13) & 3
        if reg == 0:
            self.control = value
            self._apply_control()
        elif reg == 1:
            self.chr0 = value
        elif reg == 2:
            self.chr1 = value
        else:
            self.prg0 = value & 0x0F
            self.prg_ram_enable = not (value & 0x10)

    def prg_ram_read(self, addr):
        if not self.prg_ram_enable:
            return 0
        return super().prg_ram_read(addr)

    def prg_ram_write(self, addr, val):
        if self.prg_ram_enable:
            super().prg_ram_write(addr, val)

    def prg_read(self, addr):
        n = self.prg_8k_count
        mode = (self.control >> 2) & 3
        if mode in (0, 1):                   # 32KB 模式
            base = (self.prg0 & 0x0E) * 8192
            return self._prg_byte(base + (addr - 0x8000))
        if mode == 2:                        # 固定低 16KB + 高 16KB 可切
            page = 0 if addr < 0xC000 else (self.prg0 & 0x0F)
        else:                                # 低 16KB 可切 + 固定末 16KB
            page = (self.prg0 & 0x0F) if addr < 0xC000 else n - 1
        return self._prg_byte((page % n) * 8192 + (addr & 0x1FFF))

    def chr_read(self, addr):
        a = addr & 0x1FFF
        if self.control & 0x10:              # 4KB 模式
            page = (self.chr0 if a < 0x1000 else self.chr1) % self.chr_1k_count
            off = page * 4096 + (a & 0x0FFF)
        else:                                # 8KB 模式
            page = (self.chr0 & 0x1E) % self.chr_1k_count
            off = page * 4096 + a
        if self.chr_ram is not None:
            return self.chr_ram[off % len(self.chr_ram)]
        return self.chr[off % len(self.chr)] if self.chr else 0xFF

    def chr_write(self, addr, val):
        if self.chr_ram is None:
            return
        a = addr & 0x1FFF
        if self.control & 0x10:
            page = (self.chr0 if a < 0x1000 else self.chr1) % self.chr_1k_count
            off = page * 4096 + (a & 0x0FFF)
        else:
            page = (self.chr0 & 0x1E) % self.chr_1k_count
            off = page * 4096 + a
        self.chr_ram[off % len(self.chr_ram)] = val & 0xFF


# =====================================================================
# 4 MMC3
# =====================================================================
class MMC3(Mapper):
    name = 'MMC3'
    has_irq = True

    def __init__(self, rom):
        super().__init__(rom)
        self.r = [0] * 8
        self.select = 0
        self.prg_mode = 0
        self.chr_mode = 0
        self.irq_latch = 0
        self.irq_counter = 0
        self.irq_reload = False
        self.irq_enable = False
        self.irq_pending = False
        self.mirroring = rom.mirroring
        self._win = None                      # 4 个 8KB 窗口的缓存（热路径用）

    def _rebuild_windows(self):
        self._win = [bytes(self.prg[p * 8192:p * 8192 + 8192])
                     for p in (self._prg_page(a)
                               for a in (0x8000, 0xA000, 0xC000, 0xE000))]

    # ---------- PRG ----------
    def _prg_page(self, addr):
        n = self.prg_8k_count
        if addr >= 0xE000:
            return n - 1
        if addr >= 0xC000:
            return (n - 2 if self.prg_mode == 0 else self.r[6]) % n
        if addr >= 0xA000:
            return (self.r[7] if self.prg_mode == 0 else n - 2) % n
        return (self.r[6] if self.prg_mode == 0 else n - 2) % n

    def prg_read(self, addr):
        win = self._win
        if win is None:
            self._rebuild_windows()
            win = self._win
        return win[(addr >> 13) & 3][addr & 0x1FFF]

    def prg_write(self, addr, val):
        val &= 0xFF
        if addr < 0xA000:
            if addr & 1 == 0:
                self.select = val & 7
            else:
                self.r[self.select] = val
                if self.select == 0:
                    self.chr_mode = (val >> 7) & 1
                elif self.select == 6:
                    self.prg_mode = (val >> 6) & 1
                    self._win = None
                elif self.select == 7:
                    self._win = None
        elif addr < 0xC000:
            if addr & 1 == 0:
                self.mirroring = 0 if (val & 1) else 1
            else:
                self.irq_reload = True
        elif addr < 0xE000:
            if addr & 1 == 0:
                self.irq_latch = val
            else:
                self.irq_counter = 0
        else:
            self.irq_enable = bool(val & 1)
            if not self.irq_enable:
                self.irq_pending = False

    # ---------- CHR ----------
    def _chr_off(self, addr):
        a = addr & 0x1FFF
        r = self.r
        if self.chr_mode == 0:
            if a < 0x0800:
                off = (r[0] & 0xFE) * 1024 + a
            elif a < 0x1000:
                off = (r[1] & 0xFE) * 1024 + (a - 0x800)
            else:
                slot = (a - 0x1000) // 0x400
                off = r[2 + slot] * 1024 + ((a - 0x1000) % 0x400)
        else:
            if a < 0x1000:
                slot = a // 0x400
                off = r[2 + slot] * 1024 + (a % 0x400)
            elif a < 0x1800:
                off = (r[0] & 0xFE) * 1024 + (a - 0x1000)
            else:
                off = (r[1] & 0xFE) * 1024 + (a - 0x1800)
        return off % (self.chr_1k_count * 1024)

    def chr_read(self, addr):
        off = self._chr_off(addr)
        if self.chr_ram is not None:
            return self.chr_ram[off % len(self.chr_ram)]
        return self.chr[off] if off < len(self.chr) else 0xFF

    def chr_write(self, addr, val):
        if self.chr_ram is not None:
            off = self._chr_off(addr)
            self.chr_ram[off % len(self.chr_ram)] = val & 0xFF

    # ---------- IRQ ----------
    def clock_irq(self):
        """每个 A12 上升沿调用一次。"""
        if self.irq_counter == 0 or self.irq_reload:
            self.irq_counter = self.irq_latch
            self.irq_reload = False
        else:
            self.irq_counter -= 1
        if self.irq_counter == 0 and self.irq_enable:
            self.irq_pending = True


# =====================================================================
# 工厂
# =====================================================================
MAPPERS = {
    0: NROM,
    1: MMC1,
    2: UxROM,
    3: CNROM,
    4: MMC3,
    7: AxROM,
    11: ColorDreams,
    13: CPROM,
    66: GxROM,
}


class UnsupportedMapper(Exception):
    pass


def make_mapper(rom):
    """按 iNES 头的 mapper 号造 mapper 实例。"""
    cls = MAPPERS.get(rom.mapper)
    if cls is None:
        raise UnsupportedMapper(
            '不支持的 mapper %d（%s）。已支持：%s' % (
                rom.mapper, rom.mapper_name(),
                ', '.join('%d=%s' % (k, v.name) for k, v in sorted(MAPPERS.items()))))
    return cls(rom)


def supported():
    """返回 {mapper 号: 名字}。"""
    return dict((k, v.name) for k, v in sorted(MAPPERS.items()))
