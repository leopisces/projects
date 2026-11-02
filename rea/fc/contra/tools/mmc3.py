"""MMC3（mapper 4）实现 —— Contra 用的就是它。

寄存器（$8000 偶数 = bank select，奇数 = bank data）：
  R0  $0000-$07FF / $1000-$17FF  (2KB，bit0 在 CHR-A 模式有特殊语义)
  R1  $0800-$0FFF / $1800-$1FFF  (2KB)
  R2  $1000-$13FF / $0000-$03FF  (1KB)
  R3  $1400-$17FF / $0400-$07FF  (1KB)
  R4  $1800-$1BFF / $0800-$0BFF  (1KB)
  R5  $1C00-$1FFF / $0C00-$0FFF  (1KB)
  R6  PRG $8000（模式 0）/ $C000（模式 1）
  R7  PRG $A000（模式 0 下）/ $8000（模式 1 下为固定倒数第二）
  $A000  bit0 = CHR 模式；bit6 = PRG 模式
  $A001  IRQ latch / reload / enable
  $C000 IRQ latch   $C001 IRQ reload   $E000 IRQ disable   $E001 IRQ enable
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)


class MMC3:
    def __init__(self, rom):
        self.rom = rom
        self.prg = rom.prg              # bytes
        self.chr = rom.chr              # bytes（CHR-RAM 时为空）
        self.prg_banks = len(self.prg) // 8192
        self.chr_banks = max(1, len(self.chr) // 1024)
        self.chr_ram = None
        if not self.chr:
            self.chr_ram = bytearray(8192)
            self.chr_banks = 8

        self.r = [0] * 8
        self.select = 0
        self.prg_mode = 0
        self.chr_mode = 0

        # IRQ
        self.irq_latch = 0
        self.irq_counter = 0
        self.irq_reload = False
        self.irq_enable = False
        self.irq_pending = False
        self._a12_prev = False

        # 镜像模式（Contra 用 $A000 bit0 控制 nametable 镜像）
        self.mirroring = 1              # 0=vert 1=horiz 2=one-lo 3=one-hi 4=four

    # ---------- PRG ----------
    def prg_page(self, addr):
        """返回 8KB 页号。

        MMC3 的 R 寄存器是 6 位，但实际 ROM 只有 16 个 8KB 页，
        游戏传入的 Y（如 $18）高位是无效的，必须按 ROM 实际页数取模。
        验证：$F92F 的 `LDY #$18` → 地图表指针 $8EDF 确实落在 page 8，
        即 $18 & 0x0F = 8。
        """
        n = self.prg_banks
        if addr >= 0xE000:
            return n - 1
        if addr >= 0xC000:
            return (n - 2 if self.prg_mode == 0 else self.r[6]) % n
        if addr >= 0xA000:
            return ((self.r[7] if self.prg_mode == 0 else n - 2) % n)
        return (self.r[6] if self.prg_mode == 0 else n - 2) % n

    def prg_read(self, addr):
        page = self.prg_page(addr)
        off = page * 8192 + (addr & 0x1FFF)
        if off >= len(self.prg):
            return 0
        return self.prg[off]

    def bus_read(self, addr):
        """$8000-$FFFF 的真实读取：MMC3 上 $8000 读回 bank select。

        Contra 的 $F99D 用 `LDA $8000` 保存现场，$F9AF 再用它恢复，
        所以这里必须返回 select 而不是 PRG 数据。
        """
        # Contra 的 $F989 用 `LDA $8000` 保存 bank select 现场（$F9AF 恢复）。
        # 注意：只有 $8000/$8001 这两个寄存器地址有读回语义，
        # 不能对整个 $8000-$9FFF 的偶数地址生效（$871A 就是普通 PRG 字节）。
        if addr == 0x8000:
            return self.select
        if addr == 0x8001:
            return self.r[self.select]
        return self.prg_read(addr)

    # MMC3 的寄存器可读回（Contra 的 $F99D 就靠 `LDA $8000` 存现场）：
    #   $8000 偶数 → bank select；$8001 奇数 → 当前 R[select]
    #   $A000/$A001/$C000/$C001/$E000/$E001 → 对应寄存器
    def read_register(self, addr):
        if addr < 0xA000:
            return self.select if (addr & 1) == 0 else self.r[self.select]
        if addr < 0xC000:
            return (0 if self.mirroring == 0 else 1) if (addr & 1) == 0 \
                else (0x80 if self.irq_reload else 0)
        if addr < 0xE000:
            return self.irq_latch if (addr & 1) == 0 else self.irq_counter
        return 1 if self.irq_enable else 0

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

    def clock_irq(self):
        """每次 A12 上升沿调用。"""
        if self.irq_counter == 0 or self.irq_reload:
            self.irq_counter = self.irq_latch
            self.irq_reload = False
        else:
            self.irq_counter -= 1
        if self.irq_counter == 0 and self.irq_enable:
            self.irq_pending = True

    # ---------- CHR ----------
    def _chr_off(self, addr):
        """$0000-$1FFF → CHR ROM/RAM 的字节偏移。"""
        a = addr & 0x1FFF
        r = self.r
        if self.chr_mode == 0:          # A 模式
            if a < 0x0800:
                b = (r[0] & 0xFE) * 1024 + a
            elif a < 0x1000:
                b = (r[1] & 0xFE) * 1024 + (a - 0x800)
            else:
                slot = (a - 0x1000) // 0x400
                b = r[2 + slot] * 1024 + ((a - 0x1000) % 0x400)
        else:                            # B 模式
            if a < 0x1000:
                slot = a // 0x400
                b = r[2 + slot] * 1024 + (a % 0x400)
            elif a < 0x1800:
                b = (r[0] & 0xFE) * 1024 + (a - 0x1000)
            else:
                b = (r[1] & 0xFE) * 1024 + (a - 0x1800)
        return b % (self.chr_banks * 1024)

    def chr_read(self, addr):
        off = self._chr_off(addr)
        if self.chr_ram is not None:
            return self.chr_ram[off]
        return self.chr[off] if off < len(self.chr) else 0

    def chr_write(self, addr, val):
        if self.chr_ram is not None:
            self.chr_ram[self._chr_off(addr)] = val & 0xFF

    # 四屏模式（Contra 不用，接口占位）
    def high_chr_read(self, addr):
        return 0

    def high_chr_write(self, addr, val):
        pass
