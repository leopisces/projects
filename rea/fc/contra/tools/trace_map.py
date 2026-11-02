"""跑 $C93A 地图解压器，带指令跟踪，看 PC 何时跑飞。"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, '..', 'python'))

try:
    sys.stdout.reconfigure(encoding='utf-8')
except Exception:
    pass

from contra_rom import Rom
from cpu6502 import CPU6502
from mapexec import MMC3Bus, find_rom
from cpu6502 import OP


def main():
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument('--map', type=int, default=2)
    ap.add_argument('--steps', type=int, default=3000)
    ap.add_argument('--tail', type=int, default=40)
    args = ap.parse_args()

    rom = Rom(find_rom())
    bus = MMC3Bus(rom)
    bus.r[6] = 0x18
    cpu = CPU6502(bus)
    cpu.sp = 0xFD
    bus.ram[0x1FF] = 0xFF
    bus.ram[0x1FE] = 0xF0
    cpu.pc = 0xC93A
    cpu.x = args.map * 2

    hist = []
    n = 0
    err = None
    while n < args.steps:
        pc = cpu.pc
        op = bus.read(pc)
        hist.append((pc, op, cpu.a, cpu.x, cpu.y, cpu.sp, bus.addr, bus.latch))
        if len(hist) > 200:
            hist.pop(0)
        try:
            cpu.step()
        except Exception as e:
            err = e
            break
        n += 1
        if cpu.pc < 0x8000 and cpu.pc > 0x0200:
            err = f'PC 跑到 {cpu.pc:04X}'
            break

    print(f'步数 {n}, 错误: {err}')
    print(f'VRAM 写入 {len(bus.writes)} 次, 地址范围 '
          f'{min((a for a, _ in bus.writes), default=0):04X}-'
          f'{max((a for a, _ in bus.writes), default=0):04X}')
    print(f'$00/$01 = {bus.ram[0]:02X}/{bus.ram[1]:02X}  '
          f'$2006 addr = {bus.addr:04X}  latch={bus.latch}')
    print('最后 %d 条:' % args.tail)
    for pc, op, a, x, y, sp, ad, la in hist[-args.tail:]:
        mn = OP.get(op)
        txt = f'{mn[0]} {mn[1]}' if mn else '???'
        print(f'  ${pc:04X}: {op:02X}  {a:02X}/{x:02X}/{y:02X}  '
              f'sp={sp:02X} ppu={ad:04X} latch={la}  {txt}')


if __name__ == '__main__':
    main()
