"""NES PPU（2C02）—— 通用逐扫描线渲染。

设计要点（为了通用，不再针对任何具体游戏）：
  * 4KB VRAM（nametable），镜像模式由 mapper 决定并可逐帧变化
  * 滚动用硬件寄存器语义：v/t/fine_x/w，$2005 双写、$2006 双写
  * 每条可见扫描线开始时用**当时的 v** 渲染 → 游戏在 HBlank 改 $2006 做的
    分段滚动（状态栏、split screen）自动正确
  * 行末按真机 dot 257/256 的行为：v 水平位从 t 重载、v 的 Y 递增
  * 背景 33 个 tile 批量取（每 8 像素一次读 VRAM，而不是每像素）
  * 精灵 8×8 / 8×16、优先级、翻转、每行 8 个限制、0 号精灵碰撞
  * 左 8 像素裁切（mask bit1 背景 / bit2 精灵）
  * CHR 读写走 mapper（支持 CHR-RAM / 切 bank）

帧时序：
    scanline 0-239   可见
    scanline 240     post-render
    scanline 241     VBlank 开始 → NMI
    scanline 261     pre-render：清 VBlank，v = t

不做（不影响画面/玩法的部分，注明以免误以为漏了）：
  * 精确到 dot 的精灵 overflow bug 变体
  * sprite 0 hit 的 dot 级时序（按扫描线粒度判定）
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

from palette import NES_PALETTE, NES_RGB

# 8 位不透明掩码 → 8 字节（每像素 1/0），供切片赋值
_MASK_BITS = [bytes([(m >> k) & 1 for k in range(8)]) for m in range(256)]


class PPU:
    WIDTH = 256
    HEIGHT = 240

    def __init__(self, cart):
        self.cart = cart                 # mapper（提供 chr_read / chr_write / mirroring）

        self.vram = bytearray(0x1000)    # 4KB，四屏镜像时需要
        self.palette = bytearray(32)
        self.oam = bytearray(256)
        self.oam_addr = 0

        # 寄存器
        self.ctrl = 0                    # $2000
        self.mask = 0                    # $2001
        self.status = 0                  # $2002
        self.v = 0                       # 当前 VRAM 地址
        self.rendered_lines = 0          # 本帧已推进过 v 的可见行数
        self.t = 0                       # 临时 VRAM 地址（滚动目标）
        self.fine_x = 0
        self.w = 0                       # $2005/$2006 写翻转
        self.read_buf = 0

        # 时序
        self.scanline = 0
        self.dot = 0
        self.frame = 0
        self.nmi_pending = False
        self.nmi_output = False

        self.sprite0_hit = False
        self.mirroring = cart.mirroring

        self.framebuffer = bytearray(self.WIDTH * self.HEIGHT * 3)

        # tile 行缓存：(图案地址+fine_y, 调色板号) → (24 字节 RGB, 8 位不透明掩码)
        # CHR 或调色板被改写时整体清空
        self._tile_cache = {}            # (pat_row, 调色板索引) -> (RGB块, 不透明掩码)
        self._tile_cache2 = {}           # (tile, 调色板索引) -> 同上，fine_x=0 且整行调色板一致时用
        # 整行背景缓存：(v 的滚动位, fine_x, pat_base, 调色板快照) → (768 字节 RGB, 不透明掩码)
        # 横向卷轴时大部分扫描线的背景内容逐帧不变，这层缓存把 33 个 tile 的
        # 查表/拼块工作整行省掉。nametable / CHR / 调色板任一改动都会清空它。
        self._line_cache = {}
        self._line_cache_pal = bytes(self.palette)
        # nametable 行缓存：(nt选择, tile行[, 'a']) → bytes；nametable 被写或换帧时清空
        self._nt_row_cache = {}

    # ---------------- 内存映射 ----------------
    def _nt_index(self, addr):
        a = (addr - 0x2000) & 0xFFF
        nt = a >> 10
        off = a & 0x3FF
        m = self.mirroring
        if m == 0:                       # 垂直：NT0/NT2, NT1/NT3
            phys = nt & 1
        elif m == 1:                     # 水平：NT0/NT1, NT2/NT3
            phys = nt >> 1
        elif m == 2:                     # 单屏低
            phys = 0
        elif m == 3:                     # 单屏高
            phys = 1
        else:                            # 四屏
            phys = nt
        return phys * 0x400 + off

    def read(self, addr):
        addr &= 0x3FFF
        if addr < 0x2000:
            return self.cart.chr_read(addr)
        if addr < 0x3F00:
            return self.vram[self._nt_index(addr) & 0x0FFF]
        p = addr & 0x1F
        if p in (0x10, 0x14, 0x18, 0x1C):
            p -= 0x10
        return self.palette[p]

    def write(self, addr, val):
        addr &= 0x3FFF
        val &= 0xFF
        if addr < 0x2000:
            self.cart.chr_write(addr, val)
            self._tile_cache.clear()
            self._tile_cache2.clear()
            self._line_cache.clear()
        elif addr < 0x3F00:
            self.vram[self._nt_index(addr) & 0x0FFF] = val
            self._nt_row_cache.clear()
            self._line_cache.clear()
        else:
            p = addr & 0x1F
            if p in (0x10, 0x14, 0x18, 0x1C):
                p -= 0x10
            self.palette[p] = val & 0x3F
            self._tile_cache.clear()
            self._tile_cache2.clear()
            self._line_cache.clear()

    # ---------------- CPU 侧寄存器 ----------------
    def cpu_read(self, addr):
        a = addr & 7
        if a == 2:                                   # PPUSTATUS
            r = (self.status & 0xE0) | (self.read_buf & 0x1F)
            self.status &= ~0x80
            self.nmi_output = False
            self.w = 0
            return r
        if a == 4:                                   # OAMDATA
            return self.oam[self.oam_addr]
        if a == 7:                                   # PPUDATA
            v = self.v & 0x3FFF
            if v >= 0x3F00:
                # 调色板读取：立即返回，且缓冲区填为镜像 nametable 的数据
                r = self.read(v)
                self.read_buf = self.vram[self._nt_index((v - 0x1000) & 0x3FFF) & 0x0FFF]
            else:
                r = self.read_buf
                self.read_buf = self.read(v)
            self.v = (self.v + (32 if self.ctrl & 0x04 else 1)) & 0x7FFF
            return r
        return 0

    def cpu_write(self, addr, val):
        a = addr & 7
        val &= 0xFF
        if a == 0:                                   # PPUCTRL
            was = self.nmi_output
            self.ctrl = val
            self.t = (self.t & 0xF3FF) | ((val & 3) << 10)
            self.nmi_output = bool(val & 0x80) and bool(self.status & 0x80)
            if not was and self.nmi_output:
                self.nmi_pending = True
        elif a == 1:                                 # PPUMASK
            self.mask = val
        elif a == 3:                                 # OAMADDR
            self.oam_addr = val
        elif a == 4:                                 # OAMDATA
            self.oam[self.oam_addr] = val
            self.oam_addr = (self.oam_addr + 1) & 0xFF
        elif a == 5:                                 # PPUSCROLL
            if self.w == 0:
                self.t = (self.t & 0xFFE0) | (val >> 3)
                self.fine_x = val & 7
                self.w = 1
            else:
                self.t = (self.t & 0x8FFF) | ((val & 7) << 12)
                self.t = (self.t & 0xFC1F) | ((val >> 3) << 5)
                self.w = 0
        elif a == 6:                                 # PPUADDR
            if self.w == 0:
                self.t = (self.t & 0x00FF) | ((val & 0x3F) << 8)
                self.w = 1
            else:
                self.t = (self.t & 0xFF00) | val
                self.v = self.t
                self.w = 0
        elif a == 7:                                 # PPUDATA
            self.write(self.v, val)
            self.v = (self.v + (32 if self.ctrl & 0x04 else 1)) & 0x7FFF

    def do_oam_dma(self, page_data):
        self.oam[:] = page_data[:256]

    # ---------------- 扫描线状态 ----------------
    def start_frame(self):
        """pre-render 行：v 从 t 完整复制（真机 dot 280-304）。"""
        self.v = self.t & 0x7FFF

    def end_line(self):
        """行末：v 水平位从 t 重载（dot 257），随后 v 的 Y 递增（dot 256）。"""
        self.v = (self.v & 0x7BE0) | (self.t & 0x041F)
        if (self.v & 0x7000) != 0x7000:
            self.v = (self.v + 0x1000) & 0x7FFF
        else:
            self.v &= ~0x7000
            cy = (self.v >> 5) & 0x1F
            if cy == 29:
                cy = 0
                self.v ^= 0x0800
            elif cy == 31:
                cy = 0
            else:
                cy += 1
            self.v = (self.v & ~0x03E0) | (cy << 5)

    # ---------------- 渲染 ----------------
    def _nt_row(self, ntsel, nt_y):
        """取一条 tile 行（32 个 tile 号），带缓存；每帧最多 2×30 次。"""
        key = (ntsel, nt_y)
        ch = self._nt_row_cache.get(key)
        if ch is None:
            base = 0x2000 + (ntsel & 1) * 0x400 + nt_y * 32
            nt_idx = self._nt_index
            vram = self.vram
            ch = bytes(vram[nt_idx(base + i)] for i in range(32))
            self._nt_row_cache[key] = ch
        return ch

    def _attr_row(self, ntsel, nt_y):
        """取一条属性表行（8 个字节）。"""
        key = (ntsel, nt_y, 'a')
        ch = self._nt_row_cache.get(key)
        if ch is None:
            base = 0x2000 + (ntsel & 1) * 0x400 + 0x3C0 + (nt_y >> 2) * 8
            nt_idx = self._nt_index
            vram = self.vram
            ch = bytes(vram[nt_idx(base + i)] for i in range(8))
            self._nt_row_cache[key] = ch
        return ch

    def _bg_chunk(self, pat_row, pal_i):
        """把 tile 的一行解成 (24 字节 RGB, 8 位不透明掩码) 并缓存。

        pal_i 为该 tile 的调色板号；像素 0 按硬件规则显示全局背景色。
        """
        lo = self.cart.chr_read(pat_row)
        hi = self.cart.chr_read(pat_row + 8)
        pal = self.palette
        cols = [NES_RGB[pal[0] & 0x3F],
                NES_RGB[pal[pal_i * 4 + 1] & 0x3F],
                NES_RGB[pal[pal_i * 4 + 2] & 0x3F],
                NES_RGB[pal[pal_i * 4 + 3] & 0x3F]]
        buf = bytearray(24)
        mask = 0
        for k in range(8):
            bit = 7 - k
            pv = ((lo >> bit) & 1) | (((hi >> bit) & 1) << 1)
            buf[k * 3:k * 3 + 3] = cols[pv]
            if pv:
                mask |= 1 << k
        ch = (bytes(buf), mask)
        self._tile_cache[(pat_row, pal_i)] = ch
        return ch

    def render_scanline(self, y):
        if not 0 <= y < self.HEIGHT:
            return
        fb = self.framebuffer
        o = y * 768
        mask = self.mask
        pal = self.palette
        backdrop = NES_RGB[pal[0] & 0x3F]
        if not (mask & 0x18):                     # 渲染关闭：整行背景色
            fb[o:o + 768] = backdrop * 256
            return

        # 精灵先取出来：没有精灵的行不需要维护不透明掩码
        sprites = self._line_sprites(y) if (mask & 0x10) else ()
        row = fb                                   # 直接写 framebuffer，省一次整行拷贝
        # 不透明掩码必须一直存在：下面“快路径”会把它置 None，但精灵循环里
        # 仍然要读它做 sprite-0 命中与优先级判定（曾经因此 NoneType 下标崩溃）。
        opaque = bytearray(256)

        # ---- 背景：整行缓存 → 命中直接整段写入；未命中才逐 tile 拼 ----
        bg = None
        omask_line = None
        if mask & 0x08:
            v = self.v
            key = (v & 0x7FFF, self.fine_x, self.ctrl & 0x10)
            ent = self._line_cache.get(key)
            if ent is None:
                ent = self._build_bg_line()
                self._line_cache[key] = ent
            bg, omask_line = ent
            row[o:o + 768] = bg
            if not (mask & 0x02):                 # 背景左 8 像素裁切
                row[o:o + 24] = backdrop * 8
                omask_line = omask_line & ~0xFF & 0xFFFF
            if omask_line:
                opaque = bytearray(omask_line.to_bytes(256, 'little'))
            else:
                opaque = None
        elif not sprites:
            fb[o:o + 768] = backdrop * 256
            return

        # ---- 精灵：按 OAM 顺序叠加 ----
        if sprites:
            chr_read = self.cart.chr_read
            clip_left = not (mask & 0x04)
            for sx, spal, pat, srow, prio, idx, flip_h in sprites:
                lo = chr_read(pat + srow)
                hi = chr_read(pat + srow + 8)
                base = 0x10 + spal * 4
                for k in range(8):
                    x = sx + k
                    if x >= 256:
                        break
                    if clip_left and x < 8:
                        continue
                    d = 7 - k if flip_h else k
                    pv = ((lo >> (7 - d)) & 1) | (((hi >> (7 - d)) & 1) << 1)
                    if not pv:
                        continue
                    bg_opaque = opaque[x] if opaque is not None else 0
                    if idx == 0 and bg_opaque:
                        self.sprite0_hit = True
                        self.status |= 0x40
                    if prio == 0 or not bg_opaque:
                        o3 = o + x * 3
                        row[o3:o3 + 3] = NES_RGB[pal[base + pv] & 0x3F]
                    if opaque is not None:
                        opaque[x] = 1             # 先出现的非透明精灵赢

    def _build_bg_line(self):
        """按当前 v/fine_x/ctrl 拼一条 256 像素的背景行。

        返回 (768 字节 RGB, 不透明掩码 int)；结果由 render_scanline 缓存。
        """
        v = self.v
        nx0 = v & 0x1F
        nt_y = (v >> 5) & 0x1F
        fine_y = v >> 12 & 7
        bnt = v >> 11 & 1
        fine_x = self.fine_x
        pat_base = 0x1000 if (self.ctrl & 0x10) else 0
        yshift = ((nt_y & 3) >> 1) * 4
        rowA = self._nt_row(bnt, nt_y)
        rowB = self._nt_row(bnt ^ 1, nt_y)
        attrA = self._attr_row(bnt, nt_y)
        attrB = self._attr_row(bnt ^ 1, nt_y)
        cache = self._tile_cache
        out = bytearray(768)
        omask = 0
        pal = self.palette
        backdrop = NES_RGB[pal[0] & 0x3F]
        for t in range(33):                   # 256 像素 + fine_x ≤ 33 个 tile
            x0 = t * 8 - fine_x
            if x0 >= 256:
                break
            tx = nx0 + t
            if tx > 31:
                tx -= 32
                tiles = rowB
                attrs = attrB
            else:
                tiles = rowA
                attrs = attrA
            tile = tiles[tx]
            p = (attrs[tx >> 2] >> (yshift + ((tx & 3) >> 1) * 2)) & 3
            pat_row = pat_base + tile * 16 + fine_y
            ch = cache.get((pat_row, p))
            if ch is None:
                ch = self._bg_chunk(pat_row, p)
            rgb, om = ch
            if 0 <= x0 and x0 <= 248:
                o2 = x0 * 3
                out[o2:o2 + 24] = rgb
                if om:
                    omask |= om << x0
            else:
                for k in range(8):
                    x = x0 + k
                    if 0 <= x < 256:
                        o3 = x * 3
                        out[o3:o3 + 3] = rgb[k * 3:k * 3 + 3]
                        if (om >> k) & 1:
                            omask |= 1 << x
        return (bytes(out), omask)

    def _line_sprites(self, y):
        """返回该扫描线上要画的精灵（最多 8 个，按 OAM 顺序）。"""
        h = 16 if (self.ctrl & 0x20) else 8
        oam = self.oam
        ctrl = self.ctrl
        out = []
        for i in range(0, 256, 4):
            sy = oam[i] + 1
            row = y - sy
            if row < 0 or row >= h:
                continue
            tile = oam[i + 1]
            attr = oam[i + 2]
            sx = oam[i + 3]
            if attr & 0x80:                       # 垂直翻转
                row = h - 1 - row
            if h == 16:
                pat_base = 0x1000 * (tile & 1)
                pat = pat_base + (tile & 0xFE) * 16
                if row >= 8:                      # 下半张 tile
                    pat += 16
                    row -= 8
            else:
                pat_base = 0x1000 if (ctrl & 0x08) else 0
                pat = pat_base + tile * 16
            out.append((sx, attr & 3, pat, row, (attr >> 5) & 1, i // 4, attr & 0x40))
            if len(out) == 8:
                break
        return out
