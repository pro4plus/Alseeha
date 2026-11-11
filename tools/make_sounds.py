#!/usr/bin/env python3
"""Generate all Alseeja v3.0 sound effects as 44.1 kHz 16-bit mono WAVs.

Character: wood, stone and soft chimes — no beeps, no music.
Every file is normalised to -3 dBFS peak with 5 ms fade-in/out to avoid clicks.

Usage: python3 tools/make_sounds.py   (run from the project root)
Output: assets/sounds/*.wav (15 files, see SPECS below)
Requires: numpy
"""
import math
import os
import wave

import numpy as np

SR = 44100
OUT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                       "assets", "sounds")

# ---------------------------------------------------------------- helpers

def _fade(x: np.ndarray, ms: float = 5.0) -> np.ndarray:
    n = max(1, int(SR * ms / 1000.0))
    if len(x) <= 2 * n:
        return x
    ramp = np.linspace(0.0, 1.0, n)
    x = x.copy()
    x[:n] *= ramp
    x[-n:] *= ramp[::-1]
    return x


def _norm(x: np.ndarray, peak_db: float = -3.0) -> np.ndarray:
    peak = float(np.max(np.abs(x))) if len(x) else 0.0
    if peak <= 0:
        return x
    target = 10.0 ** (peak_db / 20.0)
    return x * (target / peak)


def _write(name: str, x: np.ndarray) -> None:
    x = _norm(_fade(np.asarray(x, dtype=np.float64)))
    pcm = np.clip(np.round(x * 32767.0), -32768, 32767).astype(np.int16)
    os.makedirs(OUT_DIR, exist_ok=True)
    path = os.path.join(OUT_DIR, name)
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())
    print(f"{name:18s} {len(pcm) / SR:5.2f}s  peak={float(np.max(np.abs(pcm))) / 32767:.2f}")


def _t(seconds: float) -> np.ndarray:
    return np.arange(int(SR * seconds), dtype=np.float64) / SR


def tone(freq, seconds, attack=0.005, decay=None, amp=1.0,
         freq_end=None):
    """Sine with exponential decay; optional linear pitch glide."""
    t = _t(seconds)
    f = np.full_like(t, float(freq)) if freq_end is None else np.linspace(
        freq, freq_end, len(t))
    phase = 2.0 * np.pi * np.cumsum(f) / SR
    env = np.exp(-t / (decay if decay is not None else seconds / 3.0))
    a = min(attack, seconds / 2.0)
    na = max(1, int(a * SR))
    env[:na] *= np.linspace(0.0, 1.0, na)
    return amp * np.sin(phase) * env


def noise(seconds, amp=1.0, decay=None):
    t = _t(seconds)
    rng = np.random.default_rng(1234)
    x = rng.standard_normal(len(t)) * amp
    env = np.exp(-t / (decay if decay is not None else seconds / 3.0))
    return x * env


def lowpass(x: np.ndarray, alpha: float) -> np.ndarray:
    """One-pole low-pass (alpha 0..1, smaller = darker)."""
    y = np.empty_like(x)
    acc = 0.0
    for i, v in enumerate(x):
        acc += alpha * (v - acc)
        y[i] = acc
    return y


def bandpass(x: np.ndarray, lo: float, hi: float) -> np.ndarray:
    """Crude band-pass via FFT masking (fine for short effects)."""
    n = len(x)
    spec = np.fft.rfft(x)
    freqs = np.fft.rfftfreq(n, 1.0 / SR)
    mask = (freqs >= lo) & (freqs <= hi)
    spec = spec * mask
    return np.fft.irfft(spec, n)


def mix(*parts):
    n = max(len(p) for p in parts)
    out = np.zeros(n)
    for p in parts:
        out[:len(p)] += p
    return out

# ---------------------------------------------------------------- specs
# name -> (seconds, builder). Builders return float arrays in [-1, 1].


def s_ui_tap():
    # Soft wooden tick, 60 ms: short 1200 Hz blip + tiny click.
    return mix(tone(1200, 0.06, decay=0.015, amp=0.8),
               noise(0.012, amp=0.5, decay=0.004))


def s_select():
    # Light stone lift: short rising woody blip, 120 ms.
    return mix(tone(520, 0.12, freq_end=920, decay=0.05, amp=0.8),
               tone(1040, 0.12, freq_end=1500, decay=0.04, amp=0.25))


def s_place():
    # Stone dropped on wood: low thud + short click, 180 ms.
    return mix(tone(140, 0.18, decay=0.05, amp=1.0),
               tone(320, 0.10, decay=0.03, amp=0.5),
               noise(0.02, amp=0.6, decay=0.006))


def s_slide():
    # Stone sliding on wood: filtered noise sweep, 240 ms.
    n = noise(0.24, amp=0.7, decay=0.12)
    n = bandpass(n, 300, 1600)
    t = _t(0.24)
    n = n * (0.5 + 0.5 * np.sin(np.pi * t / 0.24))
    return n


def s_land():
    # Dull knock when a moved stone lands, 120 ms.
    return mix(tone(180, 0.12, decay=0.035, amp=0.9),
               tone(360, 0.06, decay=0.02, amp=0.4),
               noise(0.015, amp=0.4, decay=0.005))


def s_capture():
    # Stone cracked/popped: sharp transient + falling sparkle, 350 ms.
    sparkle = mix(tone(1800, 0.35, freq_end=620, decay=0.12, amp=0.45),
                  tone(2400, 0.20, decay=0.06, amp=0.2))
    return mix(noise(0.03, amp=0.9, decay=0.008),
               tone(220, 0.12, decay=0.04, amp=0.7),
               sparkle)


def s_capture_multi():
    # Capture layered with a rising two-note chime, 500 ms.
    base = s_capture()
    chime = mix(tone(660, 0.25, decay=0.12, amp=0.5),
                tone(880, 0.30, decay=0.15, amp=0.5))
    out = np.zeros(int(SR * 0.5))
    out[:len(base)] += base
    out[int(SR * 0.05):int(SR * 0.05) + len(chime)] += chime
    return out


def s_invalid():
    # Low dull double-knock, 150 ms.
    out = np.zeros(int(SR * 0.15))
    knock = mix(tone(95, 0.06, decay=0.025, amp=0.9),
                noise(0.01, amp=0.3, decay=0.004))
    out[:len(knock)] += knock
    off = int(SR * 0.075)
    out[off:off + len(knock)] += knock * 0.8
    return out


def s_turn():
    # Very soft single chime when the turn changes to you, 200 ms.
    return mix(tone(880, 0.20, decay=0.09, amp=0.55),
               tone(1320, 0.20, decay=0.07, amp=0.25))


def s_hint():
    # Gentle bell (two harmonics), 300 ms.
    return mix(tone(660, 0.30, decay=0.14, amp=0.6),
               tone(990, 0.30, decay=0.11, amp=0.35),
               tone(1320, 0.20, decay=0.08, amp=0.15))


def s_undo():
    # Reverse swoosh: noise rising in amplitude then cut, 220 ms.
    n = noise(0.22, amp=0.6, decay=10.0)
    n = bandpass(n, 500, 2400)
    t = _t(0.22)
    env = (t / 0.22) ** 2
    return n * env


def s_start():
    # Warm three-note ascending phrase (pentatonic), 700 ms.
    notes = [(523.25, 0.0), (659.25, 0.16), (783.99, 0.32)]
    out = np.zeros(int(SR * 0.7))
    for freq, start in notes:
        part = mix(tone(freq, 0.34, decay=0.18, amp=0.6),
                   tone(freq * 2, 0.34, decay=0.12, amp=0.18))
        off = int(start * SR)
        out[off:off + len(part)] += part
    return out


def s_win():
    # Bright ascending arpeggio + shimmer, 1.8 s.
    notes = [523.25, 659.25, 783.99, 1046.50, 1318.51]
    out = np.zeros(int(SR * 1.8))
    for i, freq in enumerate(notes):
        part = mix(tone(freq, 0.55, decay=0.30, amp=0.55),
                   tone(freq * 2, 0.40, decay=0.20, amp=0.2))
        off = int(i * 0.13 * SR)
        out[off:off + len(part)] += part
    # Shimmer: high sine with tremolo over the tail.
    t = _t(1.8)
    shim = 0.12 * np.sin(2 * np.pi * 2093 * t) * (0.5 + 0.5 * np.sin(
        2 * np.pi * 6 * t))
    shim[t < 0.7] = 0.0
    return out + shim


def s_lose():
    # Soft descending two-note phrase, 1.2 s.
    out = np.zeros(int(SR * 1.2))
    for freq, start in [(392.0, 0.0), (329.63, 0.45)]:
        part = mix(tone(freq, 0.6, decay=0.32, amp=0.55),
                   tone(freq * 2, 0.4, decay=0.2, amp=0.15))
        off = int(start * SR)
        out[off:off + len(part)] += part
    return out


def s_draw():
    # Two neutral notes, 800 ms.
    out = np.zeros(int(SR * 0.8))
    for freq, start in [(440.0, 0.0), (493.88, 0.35)]:
        part = tone(freq, 0.4, decay=0.2, amp=0.55)
        off = int(start * SR)
        out[off:off + len(part)] += part
    return out


SPECS = [
    ("ui_tap.wav", 0.06, s_ui_tap),
    ("select.wav", 0.12, s_select),
    ("place.wav", 0.18, s_place),
    ("slide.wav", 0.24, s_slide),
    ("land.wav", 0.12, s_land),
    ("capture.wav", 0.35, s_capture),
    ("capture_multi.wav", 0.50, s_capture_multi),
    ("invalid.wav", 0.15, s_invalid),
    ("turn.wav", 0.20, s_turn),
    ("hint.wav", 0.30, s_hint),
    ("undo.wav", 0.22, s_undo),
    ("start.wav", 0.70, s_start),
    ("win.wav", 1.80, s_win),
    ("lose.wav", 1.20, s_lose),
    ("draw.wav", 0.80, s_draw),
]


def main():
    for name, seconds, fn in SPECS:
        x = fn()
        want = int(SR * seconds)
        if len(x) > want:
            x = x[:want]
        elif len(x) < want:
            x = np.pad(x, (0, want - len(x)))
        _write(name, x)
    print(f"\nWrote {len(SPECS)} files to {OUT_DIR}")


if __name__ == "__main__":
    main()
