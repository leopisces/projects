"""CPU 差分自检：快速分派表 vs 参考实现（step_slow），逐 opcode 对比。

    python selftest_cpu.py

快速表（cpu6502.FAST）是按 opcode 代码生成的闭包，跑得快但容易和参考实现
走偏。这里给 174 个合法 opcode 各准备随机寄存器/内存状态，执行一条指令后
逐项比对：A/X/Y/SP/P/PC/steps/cycles 以及全部 64KB 内存（会覆盖栈操作、
RMW、所有寻址方式的边界）。
"""
import os
import random
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
if HERE not in sys.path:
    sys.path.insert(0, HERE)

try:
    sys.stdout.reconfigure(encoding='utf-8')
except Exception:
    pass

from cpu6502 import CPU6502, OP, CYCLES_OP

FAILS = []


class Ram:
    """64KB 平坦内存：没有 PPU/APU/映射，纯粹比指令语义。"""

    def __init__(self, data):
        self.data = bytearray(data)
        self.trace = None

    def read(self, addr):
        return self.data[addr & 0xFFFF]

    def write(self, addr, val):
        self.data[addr & 0xFFFF] = val & 0xFF


def one(op, seed):
    """同一个初始状态分别跑 step_slow 与 step，返回两边快照。"""
    rnd = random.Random(seed)
    mem = bytearray(rnd.getrandbits(8) for _ in range(0x10000))
    pc = 0x0400
    mem[pc] = op
    st = {
        'a': rnd.getrandbits(8), 'x': rnd.getrandbits(8), 'y': rnd.getrandbits(8),
        'sp': 0xF0 + rnd.randrange(8), 'p': rnd.getrandbits(8) | 0x20,
        'jmp_ind_bug': rnd.random() < 0.5,
    }
    out = []
    for impl in ('slow', 'fast'):
        bus = Ram(mem)
        cpu = CPU6502(bus, pc=pc)
        cpu.a, cpu.x, cpu.y = st['a'], st['x'], st['y']
        cpu.sp, cpu.p = st['sp'], st['p']
        cpu.jmp_ind_bug = st['jmp_ind_bug']
        cyc = cpu.step_slow() if impl == 'slow' else cpu.step()
        out.append(((cpu.a, cpu.x, cpu.y, cpu.sp, cpu.p, cpu.pc,
                     cpu.steps, cyc), bytes(bus.data)))
    return out[0], out[1]


def main():
    rnd = random.Random(20261102)
    checked = 0
    for op in sorted(OP):
        mn, mode = OP[op]
        for k in range(6):                       # 每个 opcode 试 6 组随机状态
            (s_regs, s_mem), (f_regs, f_mem) = one(op, rnd.getrandbits(30))
            tag = '$%02X %s %s' % (op, mn, mode)
            if s_regs != f_regs:
                FAILS.append('%s 寄存器不一致：slow=%r fast=%r'
                             % (tag, s_regs, f_regs))
                break
            if s_mem != f_mem:
                diff = [i for i in range(len(s_mem)) if s_mem[i] != f_mem[i]][:4]
                FAILS.append('%s 内存不一致 @ %s（%d 处）'
                             % (tag, ['$%04X' % d for d in diff],
                                sum(1 for i in range(len(s_mem))
                                    if s_mem[i] != f_mem[i])))
                break
            checked += 1
    if FAILS:
        print('FAIL %d 项：' % len(FAILS))
        for f in FAILS[:20]:
            print('  -', f)
        return 1
    print('CPU 差分自检通过（%d 个 opcode × 6 组状态 = %d 次对比，'
          '含内存全量比对）' % (len(OP), checked))
    print('周期表长度 %d，缺失（回落到 step_slow）的 opcode：%d 个'
          % (len(CYCLES_OP), sum(1 for x in range(256) if x in OP and CYCLES_OP[x] is None)))
    return 0


if __name__ == '__main__':
    sys.exit(main())
