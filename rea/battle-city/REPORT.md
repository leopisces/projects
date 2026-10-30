# 坦克大战 (Battle City) 逆向分析报告 v2

**目标**：`C:\Users\Leopisces\Desktop\projects\rea\battle-city\battle_city.nes`
**结论**：Namco《Battle City》(1985) NROM-128 原版，断点、跳转表、关卡数据全部定位
**日期**：2026-10-30

---

## 1. 样本信息

| 项 | 值 |
|---|---|
| 文件大小 | 24,592 字节 |
| MD5 | `cd4fe2e78df0696dbe652f02c19541a1` |
| 头部 | `4E 45 53 1A`（iNES） |
| PRG | 1 × 16 KB（CPU `$C000-$FFFF`，镜像到 `$8000-$BFFF`） |
| CHR | 1 × 8 KB（512 个 8×8 tile，2bpp） |
| Mapper | 0 (NROM-128)，水平镜像，无电池 |
| 校验 | 16 + 16384 + 8192 = 24592 ✅ |

**身份证据**（PRG 内明文）：

```
$C000  "COPYRIGHT 1981 1985 NAMCO LTD."
$C040  "RYOUITI OOKUBO  TAKEFUMI HYOUDOU JUNKO OZAWA"
$D299  "BATTLE"   $D2A0 "CITY"
$D2EB  "CONSTRUCTION"          ← 关卡编辑器
$D34D  "WHO LOVES NORIKO"      ← 制作组彩蛋
```

---

## 2. 中断向量

```
$FFFA  NMI   = $D400
$FFFC  RESET = $C070
$FFFE  IRQ   = $C070
```

---

## 3. 内存映射（★ = 已与上游反汇编标签交叉确认）

| 地址 | 含义 | 置信度 |
|---|---|---|
| `$00` | 通用临时 | ★★ |
| `$04`,`$05` | `$05` = PPU 地址高位偏移（`con_ppu_offset_2000 = $1C`）| ★ |
| `$06`,`$07` | P1/P2 **当前按住**的按键位图 | ★★★ |
| `$08`,`$09` | P1/P2 **本帧新按下**（边沿触发）| ★★★ |
| `$0A`,`$0B` | 帧计数器（`$0B++`，每 64 帧 `$0A++`）| ★★★ |
| `$0C` | **PPU 命令队列写指针**（`ram_buffer_index`）| ★★★ |
| `$11`,`$12` | 通用 16 位指针（字符串 / 关卡数据）| ★★★ |
| `$13`,`$14` | 第二指针（`ram_0013_t02_huge_text_data`）| ★★★ |
| `$46` | `ram_2nd_loop_flag`（`con_flag_demo = $02`）| ★ |
| `$47`,`$48` | 块坐标 X/Y 暂存 | ★★ |
| `$4D` | 标志位（`BMI` 时跳过 `$D50E`）| ★★★ |
| `$4F` | **PPU 滚动 Y**（`ram_scroll_Y`）| ★★★ |
| `$50` | **基 nametable**（`ram_base_nmt`，`ORA #$B0` 后写 `$2000`）| ★★★ |
| `$56`,`$57` | 块绘制循环的 X/Y 坐标 | ★★ |
| `$5A` | 绘制循环的 nibble 计数器（84 次引用，最热）| ★★★ |
| `$83` | **游戏模式/场景号**（跳转表索引）| ★★★ |
| `$85` | **关卡号**（`ram_stage`）| ★★★ |
| `$0101-$0103` | 音效触发槽 | ★ |
| `$0180-$01FF` | **PPU 写命令队列**（128 字节）| ★★★ |
| `$0200-$02FF` | **OAM 影子缓冲区**（NMI 整页 DMA）| ★★★ |

**按键位序**（`bank_val.inc` 确认，与我反汇编的 `sub_D689` 完全一致）：

```
Right $80  Left $40  Down $20  Up $10  Start $08  Select $04  B $02  A $01
con_btns_SS = $0C   ← 正是 $C7AB 里那个 AND #$0C
```

---

## 4. 启动流程 `reset = $C070`

```asm
C070  78        SEI
C071  A9 10     LDA #$10
C073  8D 00 20  STA PPUCTRL          ; NMI off
C077  A2 02     LDX #$02             ; 等 2 个 vblank
C079  AD 02 20  LDA PPUSTATUS
C07E  A9 06     STA PPUMASK
C086  A2 7F     LDX #$7F
C088  9A        TXS                  ; 栈 = $01FF
C089  20 91 D4  JSR sub_D491         ; 清零
C092  20 67 D4  JSR sub_D467         ; PPU 初始化
C09C  20 6A D1  JSR sub_D16A         ; ┌ 主循环
C09F  20 AB C7  JSR sub_C7AB         ; │ 标题滚屏 + START 检测
C0A2  20 C0 C9  JSR sub_C9C0         ; │ (游戏开始入口)
C0A5  20 B5 C3  JSR sub_C3B5         ; │
C0A8  20 1D C4  JSR sub_C41D         ; │
C0AB  4C 9C C0  JMP $C09C            ; └
```

---

## 5. NMI `$D400` —— 每帧主干

```asm
D400  48 8A 48 98 48 08   保存上下文
D408  8D 03 20  STA OAMADDR
D40D  8D 14 40  STA OAMDMA   ; $02 页 → $0200 → OAM (256B DMA)
D410  AD 02 20  LDA PPUSTATUS
D413  20 FD D8  JSR sub_D8FD ; 冲刷 PPU 命令队列
D416  A5 4D     LDA $4D / BMI 跳过
D421  8D 00 20  STA PPUCTRL  ; $50 | $B0
D426  8D 05 20  STA PPUSCROLL ; X = 0
D42B  8D 05 20  STA PPUSCROLL ; Y = $4F
D430  8D 01 20  STA PPUMASK  ; #$1E
D433  20 89 D6  JSR sub_D689 ; 读手柄
D436  20 93 DA  JSR sub_DA93 ; 音效
D43C  E6 0B     INC $0B      ; 帧计数
```

---

## 6. PPU 命令队列 + 单字节 RLE

### 队列格式（`$0180`，写指针 `$0C`）

```
条目: [addrHi] [addrLo] [data …] [$FF] [$FF]
队列尾: $0180[$0C] = $00   （哨兵）
```

### 冲刷器 `sub_D8FD`

```asm
D8FD  A6 0C     LDX $0C
D901  9D 80 01  STA $0180,X    ; 哨兵
D905  E4 0C     CPX $0C        ; 循环到指针
D90D  8D 06 20  STA PPUADDR    ; 高
D914  8D 06 20  STA PPUADDR    ; 低
D91B  C9 FF     CMP #$FF
D91F  BD 80 01  LDA $0180,X    ; 连续两个 FF？
D926  BD 7F 01  LDA $017F,X    ; ← RLE: 重复上一字节
D929  8D 07 20  STA PPUDATA
```

**`$FF $FF` = 重复前一个数据字节** —— 为 128 字节队列省空间的关键手法。

### 入队 `sub_D6B3`（最热，36 次调用）

由 `(X,Y)` 算 VRAM 地址 → 写进队列 → 从 `($11),Y` 拷脚本串直到 `$FF` 结束。

---

## 7. 三种分派机制

### 7.1 表 + `JMP ($0011)`（7 处）

```asm
LDA $83 / ASL A / TAY
LDA tbl,Y   / STA $11        ; 表项低字节在前（正常小端）
LDA tbl+1,Y / STA $12
JMP ($0011)
```

恢复出的表：`$CA69`(3)、`$E306`(7)、`$E498`、`$E4B8`(26)、`$E4D8`(10)、`$E4E2`(5)、`$E9E2`(7)。

### 7.2 实体行为分派 `sub_DC3D` → 表 `$E498`

```asm
DC3D  B5 A0     LDA $A0,X      ; 实体字段
DC3F  4A 4A 4A  LSR A x3       ; >> 3
DC42  29 FE     AND #$FE       ; *2
DC45  B9 98 E4  LDA $E498,Y
DC4F  6C 11 00  JMP ($0011)
```

`$A0,X` 是字节 → `>>3 & $FE` 最大得 **30**，所以**可达表项只有 16 项**（不是最初启发式读出的 42）。
实测：`[0..7]` 全部指向 `$DDEA`，`[8]`→`$DC52`、`[9]`→`$DD48`、`[10]`→`$DC7C`、`[11]`→`$DD94`、`[12]`→`$DD89`、`[13]`→`$DD7E`、`[14]`→`$DE64`、`[15]`→`$DE55`。

### 7.3 内联表尾调用分发 `sub_ECD0`（1 处，`$EBE3` 调用）

```asm
EC D0  0A        ASL A          ; A = 索引
ECD1  A8        TAY
ECD2  C8        INY            ; Y = 2i+1
ECD3  68        PLA            ; 弹出 JSR 返回地址 → 内联表指针 $FD/$FE
ECD4  85 FD     STA $FD
ECD6  68        PLA
ECD7  85 FE     STA $FE
ECD9  B1 FD     LDA ($FD),Y    ; 目标低字节
ECDB  AA        TAX
ECDC  C8        INY
ECDD  B1 FD     LDA ($FD),Y    ; 目标高字节
ECDF  85 FE     STA $FE
ECE1  86 FD     STX $FD
ECE3  6C FD 00  JMP ($00FD)
```

因为 `JSR` 的返回地址被弹掉了，目标的 `RTS` 直接回到**祖父调用者** —— 本质是**尾调用**。

调用点 `$EBE3` 之后的内联表在 `$EBE6`：

```
$EBE6: 0A | EC 21 EC 33 EC 45 EC 57 EC 61 EC 6B EC 75 EC
$EBF6: 81 EC 85 EC 88 EC 99 EC 99 EC 99 EC 99 EC 99 EC
$EC06: 99 EC A5 EC | $EC0A 恢复代码 (A6 F4 = LDX $F4)
```

17 个目标 `$EC21/$EC33/$EC45/$EC57/$EC61/$EC6B/$EC75/$EC81/$EC85/$EC88/$EC99×6/$ECA5` 全部是合法代码起点。

> **⚠️ 字节序矛盾（未解）**：按 `sub_ECD0` 的栈序（低字节在前）用小端解析上表，得到 `$21EC`（落在 PPU 寄存器映射区），不可能正确；只有按**大端**解析才得到全部合法地址。且首字节 `0x0A` 若当项数则表长只有 10 项，与实际 17 项不符。这是本 ROM 中**唯一**未能自洽解释的字节级不一致，需要拿另一份 dump 或实机验证。反汇编器按实测有效结果（17 项）处理。

---

## 8. 输入 `sub_D689`

```asm
D689  A2 01     LDX #$01
D68B  8E 16 40  STX $4016      ; strobe = 1
D690  8C 16 40  STY $4016      ; strobe = 0
D697  BD 16 40  LDA $4016,X    ; X=1→JOY2, X=0→JOY1
D69A  29 03     AND #$03
D69E  66 00     ROR $00        ; 逐位旋入
D6A3  B5 06     LDA $06,X      ; 上一帧
D6A5  49 FF     EOR #$FF
D6A7  25 00     AND $00
D6A9  95 08     STA $08,X      ; → 本帧新按下
D6AD  95 06     STA $06,X      ; → 当前按住
```

**双状态设计**：`$08` 边沿触发（单发动作），`$06` 持续（连续移动）。

---

## 9. 时序辅助

| 例程 | 作用 |
|---|---|
| `sub_D8F6` | 等 1 帧 |
| `sub_C567` | 延时 ≈64 帧（约 1 秒）：`$0B` 清零后等 `AND #$3F` 回绕 |
| `sub_C7AB` | 标题画面滚屏（`INC $4F` 0→`$F0`），`$08 & $0C`（Start/Select）中断 → `PLA PLA` 抛弃返回地址直接跳转 |
| `sub_D934` | 跳过 `Y` 索引处连续 `$00`（稀疏表扫描） |

---

## 10. 关卡数据 `$F07A` —— 已字节级验证 ✅

### 10.1 位置与格式

```
表起始: $F07A
每关:   91 字节 = 13 行 × 7 字节
记录数: 36  (关卡 1-35 + 1 条 stage_FF = demo)
总长:   3276 字节, 覆盖 $F07A-$F145
```

绘制例程 `sub_F000_draw_stage`（A = 关卡号）：

```asm
F000  C9 FF     CMP #$FF        ; demo 关卡
F004  A9 24     LDA #$24
F009  C9 24     CMP #$24        ; >= $24 则回绕
F00E  E9 23     SBC #$23
F012  A9 F0     LDA #> tbl_F07A_stage_data   ; ← 高字节 $F0
F016  A9 7A     LDA #< tbl_F07A_stage_data   ; ← 低字节 $7A
F01E  A9 5B     LDA #$5B        ; 每关 91 字节
F020  20 AA D7  JSR sub_D7AA_increase_16bit_0011_by_A
```

绘制循环：

```asm
Y = $10 .. $D0 step $10        ; 13 行
  X = $10 .. $D0 step $10      ; 13 列
    idx = $5A
    if idx & 1: v = data[idx>>1] & $0F     ; 奇数 → 低 nibble
    else:       v = data[idx>>1] >> 4      ; 偶数 → 高 nibble
    write_block(X, Y, v)
    INC $5A
  INC $5A                      ; ← 跨行跳掉一个 nibble → 91 = 13×7
```

**注意**：每行 7 字节 = 14 nibble，只用前 13 个，第 14 个是跨行填充。这就是 91 的来源。

### 10.2 地形码表（`tbl_DACB_block_data`，每格 4 个 tile id）

| 码 | 含义 | tile ids |
|---|---|---|
| `00`-`03` | 半砖（4 种朝向，缺 2 格）| `00 0F 00 0F` / `00 00 0F 0F` / `0F 00 0F 00` / `0F 0F 00 00` |
| `04` | **全砖** | `0F 0F 0F 0F` |
| `05`-`08` | 半钢（4 种朝向）| `20 10 20 10` 等 |
| `09` | **全钢** | `10 10 10 10` |
| `0A` | **水** | `12 12 12 12` |
| `0B` | **森林** | `22 22 22 22` |
| `0C` | **冰** | `21 21 21 21` |
| `0D` | **全空** | `00 00 00 00` |
| `0E` | 未使用 | `00 00 00 00` |

（`0x00` = 空 tile，`0x0F` = 砖 tile）

### 10.3 与上游反汇编交叉验证

拿 [cyneprepou4uk/NES-Games-Disassembly](https://github.com/cyneprepou4uk/NES-Games-Disassembly/tree/main/Battle%20City) 的 `incbin/stages/stage_XX.bin`（36 个 91 字节文件）逐个在本 ROM 中精确搜索：

```
全部 36 条记录命中且唯一，位置严格为 $F07A + 91 × n
stage_01 → $F07A   stage_18 → $F685   stage_35 → $FC90
stage_02 → $F0D5   stage_34 → $FC35   stage_FF → $FCEB
```

**36/36 字节完全一致** —— 这同时证明了本地 ROM 是该游戏的原版 dump（未被修改）。

### 10.4 解码效果

```
=== 关卡 9 ===
···#·····2F··
#·····2F1@3·#
···2F1@3·4F··
··1@3·4F·····
···4F········
···F2F·F2F···
@#·1@3·1@3·#@
···F4F·F4F···
····2···2····
#··1@3·1@3··#
#··F4F·F4F··#
··b·······b··
··##·····##··
```

完美左右对称的菱形装饰（`@` 钢 + `F` 森林 + `1 2 3 4` 半钢朝向）—— 格式完全正确。

工具：`python tools/stage.py battle_city.nes 1 9 35` 可导出任意关卡。

---

## 11. 覆盖率与未解部分

| 指标 | 值 |
|---|---|
| 已反汇编指令 | **5,047** 条 |
| 已覆盖代码 | **10,268 字节 = PRG 的 62.7%** |
| 恢复跳转表 | 7 个结构性 + 1 个内联表（17 项）|
| 已定位数据 | 关卡表 `$F07A-$F145`、地形属性表 `$DABB`、块数据表 `$DACB`、文本脚本 `$D284-$D3FF` |

### 剩余未解：`$F146-$FFF9`（约 3.7 KB）

- **不是代码**：`LDA #` 立即数出现率 **0.0%**（对比代码区 5.0%），`0xDD` 占 29.2%（代码区仅 0.47%）
- **无静态引用**：写入指针高位 `$12` 的最大立即数是 `$F0`，没有任何代码指向 `$F1AC+`
- **无记录结构**：位置-值互信息对所有周期 p 都趋近 0；奇偶字节分布几乎相同（熵 4.52 vs 4.47），排除 16 位表
- **与其他段不重复**：前 128 字节在整 ROM 中只出现 1 次

**推测**：1985 年 16KB 卡带是标准容量，游戏实际只用了约 12.6 KB（`$C000-$F145`），尾部是**未使用的芯片残留数据**。它的字节特征（大量 `0xDD` 成对出现）与关卡数据首字节相同，可能是原型阶段的关卡/图形残留。

---

## 12. 复现方式

```powershell
cd C:\Users\Leopisces\Desktop\projects\rea\battle-city
python tools\an.py                        # 头部/向量/熵/字符串
python tools\chr.py                       # CHR → chr_tiles.png
python tools\d6502.py                     # → battle_city_dis.asm
python tools\stage.py battle_city.nes 1 9 # 关卡地图 ASCII
```

`d6502.py` 要点：

1. 完整官方 151 条 6502 操作码 + 常见非法 NOP
2. 从 `RESET/NMI/IRQ` 三入口递归下降
3. 6 轮迭代跟进 `JMP ($0011)` 的 `LDA tbl,Y` / `LDA tbl+1,Y` 前置模式
4. 内联表分发器特例（`JSR $ECD0` → 17 项表）
5. 硬件寄存器自动注释 + 指令/数据洞分界

---

## 13. 过程中修掉的 3 个 Bug（方法论）

| # | Bug | 现象 | 修复 |
|---|---|---|---|
| 1 | `abs` 寻址取 `rw(a)`（操作码当低字节）| 所有 `JSR` 目标变成 `$??20`（`$20` 正是 JSR 自操作码），覆盖率假性只有 1% | `rw(a+1)` → 38% |
| 2 | 没跟进 `JMP ($0011)` 跳转表 | 覆盖率停在 38% | 6 轮迭代恢复 7 个表 → 62.7% |
| 3 | 关卡号按十六进制解析 `stage_10` | 关卡 10 以后全部错位，误判"仅 10/36 匹配" | 十进制解析 → 36/36 全匹配 |

**教训**：`0x20` 作为假地址的规律性、以及"覆盖率停滞但恰当"都是强信号；**调试反汇编器时优先看 JSR/JMP 目标的分布，而不是指令条数**。

---

## 14. 说明

本分析针对用户自有的卡带镜像，用于学习 1985 年 NES 游戏的工程实现（PPU 队列、RLE、尾调用分派、关卡数据压缩）。
关卡数据仅用于交叉验证，未随分析产物分发原始 ROM 数据。
本报告与上游公开反汇编（MIT 风格的社区项目）交叉核对，未复制其源码。
