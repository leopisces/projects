"""音频层：按 NES 原版 APU 的 4 声道模型播放。

原版只有 4 个发声单元（方波1 / 方波2 / 三角 / 噪音），
同一时刻每个单元只能发一个声音，音序槽号小的优先抢占。
这里复刻这个仲裁，而不是让 16 个 pygame 声道随意叠加 ——
随意叠加就是"声音很吵、很乱"的根源。

音乐走独立通道（不参与仲裁），因为主旋律本身占用 1、2、3 三个槽。
"""
import os

import pygame

# 事件名 → (wav 文件, 音量, 硬件声道, 优先级, 是否中断正在播的同类音)
# 硬件声道: 1=方波1 2=方波2 3=三角 4=噪音  （来自每个音序槽的头部字节）
SOUND_MAP = {
    'fire':       ('seq_15.wav', 0.45, 1, 10, True),
    'brick':      ('seq_12.wav', 0.40, 3, 20, True),
    'steel':      ('seq_13.wav', 0.40, 2, 20, True),
    'hit':        ('seq_07.wav', 0.55, 4, 30, True),
    'armor':      ('seq_14.wav', 0.40, 2, 25, True),
    'spawn_item': ('seq_09.wav', 0.55, 2, 15, True),
    'get_item':   ('seq_06.wav', 0.55, 2, 10, True),
    'bonus':      ('seq_10.wav', 0.50, 4, 10, False),
    'bump':       ('seq_16.wav', 0.35, 1, 5, False),
    'engine':     ('seq_17.wav', 0.22, 3, 1, False),   # 履带声，循环
    'tick':       ('seq_19.wav', 0.30, 2, 5, False),
}

# 音乐：槽 1,2,3 / 21,22,23 / 24,25,26 / 27 / 0
MUSIC_MAP = {
    'bgm':      ('bgm_stage_start.wav', 0.55),
    'hiscore':  ('bgm_hiscore.wav',     0.50),
    'gameover': ('jingle_gameover.wav', 0.65),
    'result':   ('jingle_result.wav',   0.65),
    'pause':    ('jingle_pause.wav',    0.70),
}


def find_sound_dir():
    here = os.path.dirname(os.path.abspath(__file__))
    for cand in (os.path.join(os.path.dirname(here), 'sound'),
                 os.path.join(here, 'sound'),
                 os.path.join(os.getcwd(), 'sound')):
        if os.path.isdir(cand):
            return cand
    return None


class Audio:
    def __init__(self, sound_dir=None, enabled=True, volume=0.8):
        self.enabled = False
        self.sounds = {}
        self.music = {}
        self.volume = volume
        self.chan = {}          # 硬件声道号 → pygame Channel
        self.owner = {}         # 硬件声道号 → 当前占用者 (名字, 优先级)
        self.engine_on = False
        if not enabled:
            return
        d = sound_dir or find_sound_dir()
        if not d:
            return
        try:
            pygame.mixer.init(frequency=44100, size=-16, channels=1, buffer=256)
            pygame.mixer.set_num_channels(8)
        except pygame.error:
            return

        self.music_ch = pygame.mixer.Channel(0)
        for hw in (1, 2, 3, 4):
            self.chan[hw] = pygame.mixer.Channel(hw)

        self._load(d)
        self.enabled = bool(self.sounds or self.music)

    def _load(self, d):
        for name, (fn, vol, *_rest) in SOUND_MAP.items():
            s = self._sound(d, fn, vol)
            if s:
                self.sounds[name] = s
        for name, (fn, vol) in MUSIC_MAP.items():
            s = self._sound(d, fn, vol)
            if s:
                self.music[name] = s

    def _sound(self, d, fn, vol):
        path = os.path.join(d, fn)
        if not os.path.isfile(path):
            return None
        try:
            s = pygame.mixer.Sound(path)
            s.set_volume(vol * self.volume)
            return s
        except pygame.error:
            return None

    # ---------- 音效（走 4 声道仲裁）----------
    def play(self, name):
        if not self.enabled or name not in self.sounds:
            return
        _, vol, hw, prio, preempt = SOUND_MAP[name]
        ch = self.chan[hw]

        cur = self.owner.get(hw)
        if ch.get_busy():
            # 同一声道正在发声：只有更高优先级（数值更小）才抢占
            if cur and cur[1] <= prio and not preempt:
                return
            if cur and cur[1] < prio:
                return

        ch.play(self.sounds[name])
        self.owner[hw] = (name, prio)

    def set_engine(self, on):
        """履带声：移动时循环播放，松开即停（模拟原版的移动音效保持逻辑）。"""
        if not self.enabled:
            return
        if on and not self.engine_on and 'engine' in self.sounds:
            ch = self.chan[SOUND_MAP['engine'][2]]
            if not ch.get_busy():
                ch.play(self.sounds['engine'], loops=-1)
            self.owner[SOUND_MAP['engine'][2]] = ('engine', 1)
            self.engine_on = True
        elif not on and self.engine_on:
            self.chan[SOUND_MAP['engine'][2]].fadeout(60)
            self.owner.pop(SOUND_MAP['engine'][2], None)
            self.engine_on = False

    # ---------- 音乐（独立通道，不参与仲裁）----------
    def play_music(self, name):
        if not self.enabled or name not in self.music:
            return
        ch = self.music_ch
        # 同曲已在播就不重来
        if ch.get_busy() and getattr(self, '_cur_music', None) == name:
            return
        ch.stop()
        ch.play(self.music[name])
        self._cur_music = name

    def stop_music(self):
        if self.enabled:
            self.music_ch.stop()
            self._cur_music = None

    def stop_all(self):
        if self.enabled:
            pygame.mixer.stop()
            self.owner.clear()
            self.engine_on = False
            self._cur_music = None
