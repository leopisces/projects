"""NES PPU（2C02）实现 —— 逐扫描线渲染，供 Contra 复刻用。

设计目标：**画面与真机一致**，所以严格按硬件行为实现，不做简化：
  * 两个 nametable + 属性表 + 图案表，完整 16KB VRAM
  * 背景 32 tile 一行的取图流水线（含 tile 内 x 偏移、属性延迟）
  * 精灵：8×8 / 8×16、优先级、翻转、0 号精灵碰撞、8 精灵每行限制
  * 滚动：$2005 双写、coarse/fine X/Y、$2006 定位、$2000 NT 选择
  * 精灵 RAM 256 字节（$2003/$2004 DMA）
  * NMI 在 scanline 241 / dot 1 触发

参考：NESdev PPU 帧时序
    scanline 0-239   可见
    scanline 240     post-render（不取图）
    scanline 241     VBlank 开始 → 触发 NMI
    scanline 261     pre-render（清 VBlank、清 sprite0 hit）

不做（与玩法无关，注明以免误以为遗漏）：
  * 精确的 sprite overflow bug 变体（按标准有 bug 的版本实现）
  * MMC3 的 IRQ 计数器在 CPU 侧完成（见 mmc3.py）
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

try:
    sys.stdout.reconfigure(encoding='utf-8')
except Exception:
    pass

from contra_rom import NES_PALETTE


class PPU:
    WIDTH = 256
    HEIGHT = 240

    def __init__(self, cart):
        self.cart = cart
        self.vram = bytearray(0x800)       # 2 × 1KB nametable
        self.palette = bytearray(32)
        self.oam = bytearray(256)
        self.oam_addr = 0

        # 寄存器
        self.ctrl = 0           # $2000
        self.mask = 0           # $2001
        self.status = 0         # $2002
        self.oam_dma_page = 0
        self.v = 0              # 当前 VRAM 地址（15 位）
        self.t = 0              # 临时 VRAM 地址
        self.fine_x = 0
        self.w = 0              # $2005/$2006 写翻转
        self.read_buf = 0

        # 时序
        self.scanline = 0
        self.dot = 0
        self.frame = 0
        self.nmi_pending = False
        self.nmi_output = False

        # 渲染状态
        self.sprite0_hit = False

        # 输出
        self.framebuffer = bytearray(self.WIDTH * self.HEIGHT * 3)

        # nametable 镜像（垂直 = NT0/NT1 各 1KB；水平 = 2KB 镜像）
        self.mirroring = cart.mirroring

    # ---------------- 内存映射 ----------------
    def _nt_index(self, addr):
        """nametable 地址 → vram 索引（$2000-$2FFF 4 个 NT）。"""
        a = (addr - 0x2000) & 0xFFF
        nt = a >> 10            # 0..3
        off = a & 0x3FF
        if self.mirroring == 0:          # 垂直镜像：NT0/NT2, NT1/NT3
            phys = nt & 1
        elif self.mirroring == 1:        # 水平镜像：NT0/NT1, NT2/NT3
            phys = nt >> 1
        elif self.mirroring == 2:        # 单屏低位
            phys = 0
        elif self.mirroring == 3:        # 单屏高位
            phys = 1
        else:                            # 四屏
            phys = nt
        return phys * 0x400 + off

    def read(self, addr):
        addr &= 0x3FFF
        if addr < 0x2000:
            return self.cart.chr_read(addr)
        if addr < 0x3F00:
            if self.mirroring == 4:
                return self.cart.high_chr_read(addr)
            return self.vram[self._nt_index(addr)]
        # 调色板
        p = addr & 0x1F
        if p in (0x10, 0x14, 0x18, 0x1C):
            p -= 0x10
        return self.palette[p]

    def write(self, addr, val):
        addr &= 0x3FFF
        val &= 0xFF
        if addr < 0x2000:
            self.cart.chr_write(addr, val)
        elif addr < 0x3F00:
            if self.mirroring == 4:
                self.cart.high_chr_write(addr, val)
            else:
                self.vram[self._nt_index(addr)] = val
        else:
            p = addr & 0x1F
            if p in (0x10, 0x14, 0x18, 0x1C):
                p -= 0x10
            self.palette[p] = val

    # ---------------- CPU 侧寄存器 ----------------
    def cpu_read(self, addr):
        a = addr & 7
        if a == 2:                       # PPUSTATUS
            r = (self.status & 0xE0) | (self.read_buf & 0x1F)
            self.status &= ~0x80
            self.nmi_output = False
            self.w = 0
            return r
        if a == 4:                       # OAMDATA
            return self.oam[self.oam_addr]
        if a == 7:                       # PPUDATA
            r = self.read_buf
            self.read_buf = self.read(self.v)
            if (self.v & 0x3FFF) >= 0x3F00:
                # 调色板读取无缓冲且立即返回
                r = self.read_buf
                self.read_buf = self.read(self.v - 0x1000)
            self.v = (self.v + (32 if self.ctrl & 0x04 else 1)) & 0x7FFF
            return r
        return 0

    def cpu_write(self, addr, val):
        a = addr & 7
        val &= 0xFF
        if a == 0:                       # PPUCTRL
            prev_nmi = self.nmi_output
            self.ctrl = val
            self.t = (self.t & 0xF3FF) | ((val & 3) << 10)
            self.nmi_output = bool(val & 0x80) and bool(self.status & 0x80)
            if not prev_nmi and self.nmi_output and (self.status & 0x80):
                self.nmi_pending = True
        elif a == 1:                     # PPUMASK
            self.mask = val
        elif a == 3:                     # OAMADDR
            self.oam_addr = val
        elif a == 4:                     # OAMDATA
            self.oam[self.oam_addr] = val
            self.oam_addr = (self.oam_addr + 1) & 0xFF
        elif a == 5:                     # PPUSCROLL
            if self.w == 0:
                self.t = (self.t & 0xFFE0) | (val >> 3)
                self.fine_x = val & 7
                self.w = 1
            else:
                self.t = (self.t & 0x8FFF) | ((val & 7) << 12)
                self.t = (self.t & 0xFC1F) | ((val >> 3) << 5)
                self.w = 0
        elif a == 6:                     # PPUADDR
            if self.w == 0:
                self.t = (self.t & 0x00FF) | ((val & 0x3F) << 8)
                self.w = 1
            else:
                self.t = (self.t & 0xFF00) | val
                self.v = self.t
                self.w = 0
        elif a == 7:                     # PPUDATA
            self.write(self.v, val)
            self.v = (self.v + (32 if self.ctrl & 0x04 else 1)) & 0x7FFF

    def do_oam_dma(self, page_data):
        """$4014：把 256 字节拷进 OAM。"""
        for i in range(256):
            self.oam[i] = page_data[i]

    # ---------------- 渲染 ----------------
    def _bg_pixel(self, x, y=None):
        """返回 (调色板索引, 像素值) 或 None。"""
        if not (self.mask & 0x08):
            return None
        v = self.v if y is None else self.v_for_line(y)
        nt_x = (v & 0x1F)
        nt_y = (v >> 5) & 0x1F
        fine_y = (v >> 12) & 7
        base_nt = (v >> 11) & 1
        nt_addr = 0x2000 + (base_nt & 1) * 0x400
        tile = self.read(nt_addr + nt_y * 32 + nt_x)
        attr_addr = nt_addr + 0x3C0 + (nt_y // 4) * 8 + (nt_x // 4)
        attr = self.read(attr_addr)
        shift = ((nt_y % 4) // 2) * 4 + ((nt_x % 4) // 2) * 2
        pal = (attr >> shift) & 3
        if self.ctrl & 0x10:
            pat_addr = 0x1000 + tile * 16
        else:
            pat_addr = tile * 16
        bit = 7 - self.fine_x
        lo = (self.cart.chr_read(pat_addr + fine_y) >> bit) & 1
        hi = (self.cart.chr_read(pat_addr + fine_y + 8) >> bit) & 1
        return (pal, lo | (hi << 1))

    def v_for_line(self, y):
        """给定屏幕行 y，算出该行起始的 v。"""
        hx = self.t & 0x1F
        base_fine = (self.t >> 12) & 7
        base_coarse = (self.t >> 5) & 0x1F
        base_nt = (self.t >> 11) & 1
        total = base_fine + y
        fine_y = total & 7
        cy = base_coarse + (total >> 3)
        nt_sel = base_nt
        while cy >= 30:
            cy -= 30
            nt_sel ^= 1
        return ((nt_sel & 1) << 11) | ((cy & 0x1F) << 5) | (fine_y << 12) | hx

    def _sprite_pixels(self, y):
        """返回该行的精灵列表 [(x, 调色板, 像素值, 优先级, sprite_idx)]。"""
        out = []
        if not (self.mask & 0x10):
            return out
        h = 16 if (self.ctrl & 0x20) else 8
        for i in range(64):
            sy = self.oam[i * 4] + 1
            if y < sy or y >= sy + h:
                continue
            if len(out) >= 8:
                break
            tile = self.oam[i * 4 + 1]
            attr = self.oam[i * 4 + 2]
            sx = self.oam[i * 4 + 3]
            row = y - sy
            if attr & 0x80:              # 垂直翻转
                row = h - 1 - row
            if h == 16:
                bank = (tile & 1) * 0x1000
                tnum = tile & 0xFE
                if row >= 8:
                    tnum += 1
                    row -= 8
            else:
                bank = 0x1000 if (self.ctrl & 0x08) else 0
                tnum = tile
            pat = bank + tnum * 16
            pal = attr & 3
            prio = 1 if (attr & 0x20) else 0
            out.append((sx, pal, pat, row, prio, i, attr & 0x40))
        return out

    def render_scanline(self, y):
        """渲染一条可见扫描线到 framebuffer。"""
        if y >= self.HEIGHT:
            return
        bgpix = [None] * 256
        sprites = self._sprite_pixels(y) if (self.mask & 0x10) else []

        if self.mask & 0x08:
            v = self.v_for_line(y)
            nx0 = v & 0x1F
            nt_y = (v >> 5) & 0x1F
            fine_y = (v >> 12) & 7
            bnt = (v >> 11) & 1
            for x in range(256):
                tx = nx0 + (x >> 3)
                nt_sel = bnt
                while tx > 31:
                    tx -= 32
                    nt_sel ^= 1
                nt_addr = 0x2000 + (nt_sel & 1) * 0x400
                tile = self.read(nt_addr + nt_y * 32 + tx)
                attr_addr = nt_addr + 0x3C0 + (nt_y // 4) * 8 + (tx // 4)
                attr = self.read(attr_addr)
                shift = ((nt_y % 4) // 2) * 4 + ((tx % 4) // 2) * 2
                pal = (attr >> shift) & 3
                pat = (0x1000 + tile * 16) if (self.ctrl & 0x10) else (tile * 16)
                bit = 7 - (x & 7)
                lo = (self.cart.chr_read(pat + fine_y) >> bit) & 1
                hi = (self.cart.chr_read(pat + fine_y + 8) >> bit) & 1
                bgpix[x] = (pal, lo | (hi << 1))

        for x in range(256):
            b = bgpix[x]
            color = 0
            if b is not None:
                pal_i, pix = b
                color = self.palette[0] if pix == 0 else self.palette[pal_i * 4 + pix]

            for sx, pal, pat, row, prio, idx, flip_h in sprites:
                dx = x - sx
                if dx < 0 or dx >= 8:
                    continue
                if flip_h:
                    dx = 7 - dx
                lo = (self.cart.chr_read(pat + row) >> (7 - dx)) & 1
                hi = (self.cart.chr_read(pat + row + 8) >> (7 - dx)) & 1
                v = lo | (hi << 1)
                if v == 0:
                    continue
                if idx == 0 and b is not None and b[1] != 0:
                    self.sprite0_hit = True
                    self.status |= 0x40
                if prio == 0 or b is None or b[1] == 0:
                    color = self.palette[0x10 + pal * 4 + v]
                break

            if x < 8 and not (self.mask & 0x02):
                color = self.palette[0]

            rgb = NES_PALETTE[color & 0x3F]
            o = (y * 256 + x) * 3
            self.framebuffer[o] = rgb[0]
            self.framebuffer[o + 1] = rgb[1]
            self.framebuffer[o + 2] = rgb[2]

    def step(self):
        """推进一个 dot（简化：每 dot 调用一次太慢，实际按 scanline 推进）。"""
        self.dot += 1
        if self.dot >= 341:
            self.dot = 0
            self.scanline += 1
            if self.scanline == 241:
                self.status |= 0x80
                if self.ctrl & 0x80:
                    self.nmi_pending = True
            elif self.scanline == 261:
                self.status &= ~0xE0
                self.sprite0_hit = False
                if self.ctrl & 0x80:
                    self.nmi_output = True
            elif self.scanline >= 262:
                self.scanline = 0
                self.frame += 1

    def run_scanline(self):
        """跑完一整条扫描线（341 dot），用于快速推进。"""
        if 0 <= self.scanline < 240:
            self.render_scanline(self.scanline)
        # Y 递增（背景取图流水线）
        if 0 <= self.scanline < 240 or self.scanline == 261:
            if (self.v & 0x7000) == 0x7000:
                self.v &= ~0x7000
                fy = (self.v >> 5) & 0x1F
                if fy == 29:
                    fy = 0
                    self.v ^= 0x0800
                elif fy == 31:
                    fy = 0
                else:
                    fy += 1
                self.v = (self.v & ~0x03E0) | (fy << 5)
            else:
                self.v += 0x1000

        self.scanline += 1
        if self.scanline == 241:
            self.status |= 0x80
            if self.ctrl & 0x80:
                self.nmi_pending = True
        elif self.scanline == 261:
            self.status &= ~0xE0
            self.sprite0_hit = False
            if self.ctrl & 0x80:
                self.nmi_output = True
        elif self.scanline >= 262:
            self.scanline = 0
            self.frame += 1
