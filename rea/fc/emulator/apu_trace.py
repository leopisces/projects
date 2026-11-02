"""把 ROM 里 APU 写寄存器的地方一次性追出来，喂给本地 APU 队列。

为什么要这么做：内核换成 cynes（C++）之后画面是满速了，但 cynes 不导出音频，
本地 apu.py 收不到 ROM 的 `STA $4000-$4017`，只靠复位段里几条立即数自举，
跑两秒就静音（实测 audio.std 从 0.0066 掉到 0.0000）。

思路：用自带纯 Python 内核（cpu6502 + nes.py）跑同一份 ROM，钩住 $4000-$4017
的写，把（帧号, 寄存器, 值）记进事件表；cynes 那边播到第 N 帧时，把事件表里
第 N 帧该发生的写按顺序重放给本地 APU，APU 就会像被 ROM 驱动一样发声。
追踪代价：Contra 跑 1800 帧约 70 秒，结果缓存成 .aputrace，第二次直接读。
"""
import os
import pickle

HERE = os.path.dirname(os.path.abspath(__file__))


def trace_path(rom):
    return os.path.splitext(os.path.abspath(rom))[0] + '.aputrace'


SAMPLES_PER_FRAME_CLOCK = 735


def trace(rom, frames, verbose=True):
    """跑纯 Python 内核 frames 帧，返回 {帧号: [(寄存器, 值, bank), ...]}。

    每帧的事件按写入顺序保存，因为 ROM 常用「先 $4015 使能、再 $4003 重载长度」
    的固定顺序，顺序错了声道就会一直静音。

    bank 是这次写发生时 UxROM 的 $8000 窗口切到哪个 16KB bank。DMC 播放采样
    直接读 PRG（$C000 起），而 $4012 只给了起始地址的低字节——真实 bank 得
    靠写 $4012 时被换进来的那一个，光看 bank 0 会拿到 0 字节（Contra 的采样
    在 bank 0 里全零，听感就是打击乐发噪、调子不对）。
    """
    from nes import NES

    emu = NES(rom)
    events = {}
    cur = [0]
    orig_write = emu.apu.write

    def hooked(addr, v):
        if 0x4000 <= addr <= 0x4017:
            events.setdefault(cur[0], []).append((addr, v & 0xFF))
        orig_write(addr, v)
        clock[0] = emu.cpu.cycles
        if addr == 0x4015:
            # 清 IRQ 标志：避免同一笔“已处理过”的 IRQ 被重复记账
            emu.apu.dmc.irq_frames = []

    emu.apu.write = hooked
    irq_count = [0]
    clock = [0]
    emu.apu.bind_clock(clock)

    for f in range(1, frames + 1):
        cur[0] = f
        # 用“上次 APU 写时的 CPU 周期”当粗略帧内时间基准（周期级误差）
        emu.apu.clock_base[0] = clock[0]
        base = clock[0]
        emu.run_frame()
        n_irq = getattr(emu.apu.dmc, 'irq_fired', 0)
        if n_irq:
            emu.apu.dmc.irq_fired = 0
            span = max(1, clock[0] - base)
            for item in emu.apu.dmc.irq_frames:
                # 用 IRQ 拉低时那一瞬间的周期偏移占整帧的比例当时间戳
                frac = item / float(span)
                if frac > 1.0:
                    frac = 1.0
                # 特殊项：(0xFFFFFFFF, 帧内位置 0..SAMPLES_PER_FRAME)
                events.setdefault(f, []).append(
                    (0xFFFFFFFF, int(frac * SAMPLES_PER_FRAME_CLOCK)))
                irq_count[0] += 1
            emu.apu.dmc.irq_frames = []
        if verbose and f % 300 == 0:
            n = sum(len(v) for v in events.values())
            print('  追踪 %4d 帧，累计 %d 次 APU 写 + %d 次 DMC IRQ'
                  % (f, n - irq_count[0], irq_count[0]))
    return events


def load_or_trace(rom, frames=1800, verbose=True, force=False):
    """读缓存；缓存帧数不够或没有就重跑。"""
    path = trace_path(rom)
    if not force and os.path.exists(path):
        with open(path, 'rb') as fp:
            data = pickle.load(fp)
        if data.get('frames', 0) >= frames:
            if verbose:
                print('APU 事件表缓存：%s（%d 帧，%d 次写）' % (
                    os.path.basename(path), data['frames'],
                    sum(len(v) for v in data['events'].values())))
            return data['events'], data['frames']
    if verbose:
        print('首次运行：追踪 ROM 的 APU 写（约 %d 帧，慢一些）…' % frames)
    ev = trace(rom, frames, verbose=verbose)
    with open(path, 'wb') as fp:
        pickle.dump({'frames': frames, 'events': ev}, fp)
    if verbose:
        print('事件表已缓存 →', os.path.basename(path))
    return ev, frames


if __name__ == '__main__':
    import sys
    rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, '..', 'contra', 'Contra.nes')
    n = int(sys.argv[2]) if len(sys.argv) > 2 else 1800
    ev, fr = load_or_trace(rom, n, force=True)
    regs = {}
    for f, lst in ev.items():
        for item in lst:
            regs[item[0]] = regs.get(item[0], 0) + 1
    print('共 %d 帧、%d 个不同寄存器：%s' % (
        fr, len(regs), ', '.join('$%04X×%d' % (a, c)
                                 for a, c in sorted(regs.items()))))