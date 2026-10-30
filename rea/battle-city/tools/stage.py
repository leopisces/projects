"""Battle City 关卡数据解码器。

格式 (经 cyneprepou4uk/NES-Games-Disassembly 交叉验证, 本 ROM 36 条记录字节级完全一致):
  - 表起始 $F07A, 每关 91 字节 (13 行 x 7 字节)
  - 每行 7 字节 = 14 个 nibble, 只用前 13 个 (第 14 个是跨行填充)
  - 每 nibble = 1 个 13x13 网格里的"格子", 高 nibble 在前
  - 关卡号 A: A >= $24 时 A -= $23; A = $FF (demo) 先当 $24 处理
"""
import sys

STAGE_TABLE = 0xF07A
STAGE_SIZE = 91
STAGE_COUNT = 36          # 35 关 + 1 条 stage_FF (demo/挑战)

# 地形码 -> 每格 4 个 tile id (来自 tbl_DACB_block_data)
TERRAIN = {
    0x00: ('半砖', 'a'), 0x01: ('半砖', 'b'), 0x02: ('半砖', 'c'), 0x03: ('半砖', 'd'),
    0x04: ('全砖', '#'),
    0x05: ('半钢', '1'), 0x06: ('半钢', '2'), 0x07: ('半钢', '3'), 0x08: ('半钢', '4'),
    0x09: ('全钢', '@'),
    0x0A: ('水',   '~'),
    0x0B: ('森林', 'F'),
    0x0C: ('冰',   'I'),
    0x0D: ('空',   '·'),
}


def load_stages(rom_path):
    data = open(rom_path, 'rb').read()
    assert data[:4] == b'NES\x1a', '不是 iNES 文件'
    prg_banks = data[4]
    prg = data[16:16 + prg_banks * 16384]
    base = 0xF07A - 0xC000
    out = []
    for i in range(STAGE_COUNT):
        off = base + i * STAGE_SIZE
        out.append(prg[off:off + STAGE_SIZE])
    return out


def decode(rec):
    """91 字节 -> 13x13 地形码网格"""
    grid = []
    for row in range(13):
        nib = []
        for b in rec[row * 7:(row + 1) * 7]:
            nib += [b >> 4, b & 0x0F]
        grid.append(nib[:13])
    return grid


def render(grid, legend=True):
    lines = []
    for r in grid:
        lines.append(''.join(TERRAIN.get(v, ('?', '?'))[1] for v in r))
    if legend:
        lines.append('')
        lines.append('· 空   # 全砖   @ 全钢   ~ 水   F 森林   I 冰')
        lines.append('a b c d 半砖(4 种朝向)   1 2 3 4 半钢(4 种朝向)')
    return '\n'.join(lines)


def main():
    rom = sys.argv[1] if len(sys.argv) > 1 else 'battle_city.nes'
    want = sys.argv[2:] or [str(i) for i in range(1, 6)]
    stages = load_stages(rom)
    for w in want:
        n = 0x24 if w.lower() == 'ff' else int(w, 10)
        idx = (n - 1) if n < 0x24 else 0x24 - 0x23
        if not (0 <= idx < STAGE_COUNT):
            print(f'关卡 {w} 超范围')
            continue
        rec = stages[idx]
        print(f'=== 关卡 {w}  (表偏移 ${STAGE_TABLE + idx * STAGE_SIZE:04X}, '
              f'md5={__import__("hashlib").md5(rec).hexdigest()[:12]}) ===')
        print(render(decode(rec)))
        print()


if __name__ == '__main__':
    main()
