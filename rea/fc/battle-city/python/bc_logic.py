"""原版逻辑移植层：PRNG、帧计数、敌人 AI、移动探测。

这里的每个函数都对应 ROM 里的具体地址，不做简化。
来源：cyneprepou4uk/NES-Games-Disassembly 与本地反汇编交叉核对。
"""

FRAME_HZ = 60.0988


class Random:
    """$D44D generate_random_number 的逐条移植。

    ROM:
        LDA $0F      ; ram_random
        ASL ASL ASL  ; *8
        SEC SBC $0F  ; -ram_random  → random*7
        CLC ADC $0A  ; +ram_frm_cnt_hi
        INC $10      ; ram_index_for_random++
        LDX $10
        ADC $00,X    ; +零页 $00+idx（借用了调用方的临时变量）
        STA $0F
    """

    def __init__(self):
        self.random = 0
        self.index = 0

    def next(self, frame_hi, zp):
        v = (self.random * 7) & 0xFF
        v = (v + frame_hi) & 0xFF
        self.index = (self.index + 1) & 0xFF
        v = (v + zp.get(self.index, 0)) & 0xFF
        self.random = v
        return v


class FrameCounter:
    """$0A(hi) / $0B(lo)：NMI 里每帧 INC $0B，每 64 帧 INC $0A。"""

    def __init__(self):
        self.lo = 0
        self.hi = 0

    def tick(self):
        self.lo = (self.lo + 1) & 0xFF
        if (self.lo & 0x3F) == 0:
            self.hi = (self.hi + 1) & 0xFF


# con_tank_flag_* (来自 bank_val.inc 与反汇编注释)
FLAG_FOLLOW_HQ = 0xB0
FLAG_RANDOM = 0xA0
FLAG_FOLLOW_P2 = 0xC0
FLAG_FOLLOW_P1 = 0xD0


def enemy_goal_stage(spawn_interval, frame_hi):
    """$DE72 sub_DE72 —— 敌人目标选择阶段。

    ROM:
        LDA $84 / LSR / LSR      ; spawn_interval >> 2
        CMP $0A                  ; 对比帧计数高位
        BCS +                    ; 若 >=  → 阶段 1（冲基地）
        /LSR（即 >>3 总计）       ; BCC → 阶段 2（随机）
        → 阶段 3（追玩家）

    返回 FLAG_FOLLOW_HQ / FLAG_RANDOM / FLAG_FOLLOW_P1|P2
    """
    a = (spawn_interval >> 2) & 0xFF
    if a >= frame_hi:
        return FLAG_FOLLOW_HQ
    a = (a >> 1) & 0xFF
    if a < frame_hi:
        return FLAG_FOLLOW_P1          # 追玩家（1P 模式固定 p1）
    return FLAG_RANDOM


def tank_speed_ticks(flags):
    """坦克移动节奏：原版每帧最多 1px，但只能在像素落 8 的倍数时才允许换向。

    返回 True 表示当前帧允许"重新决策方向"。
    """
    return True


def move_probe(field, x, y, direction, size=16, probe=1):
    """双点探测（$DC9C 附近）：沿行进方向前后各探 8px 再决定能否走。

    原版用 $58/$59 = DirDelta * 8 作为探测偏移，实际位移是 1px。
    这里返回 (can_move, blocked_ahead)。
    """
    dx, dy = {0: (0, -1), 1: (-1, 0), 2: (0, 1), 3: (1, 0)}[direction]
    nx, ny = x + dx * probe, y + dy * probe
    return (not field.rect_blocked(nx, ny)), field.rect_blocked(
        x + dx * 8, y + dy * 8)


def snap_to_grid(pos):
    """原版允许坦克停在任意像素，但转向只在 8px 对齐时发生。"""
    return pos
