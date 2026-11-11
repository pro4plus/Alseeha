#!/usr/bin/env python3
"""Generate all Alseeja v4.0 sound effects as 44.1 kHz 16-bit mono WAVs.

Sound world: Sudanese dalluka (goblet drum: deep *doum*, sharp *tak*),
tambour (Nubian lyre) plucked in an anhemitonic pentatonic scale
(C D F G A), clay and wood knocks. No music, no synth beeps.

Synthesis: damped sinusoid modes for clay/wood, pitch-dropping sine
plus filtered noise for the *doum*, band-passed noise for the *tak*,
Karplus-Strong plucked strings for the tambour, a light plate-style
reverb tail (80-150 ms) on win/lose only. Three variants of the
frequent sounds (place, slide, capture) for round-robin playback.

Every file is normalised to -3 dBFS peak with 4 ms fades to avoid clicks.

Usage: python3 tools/make_sounds.py   (run from the project root)
Output: assets/sounds/*.wav (21 files, see SPECS below)
Requires: numpy
"""
import math
import os
import wave

import numpy as np

SR = 44100
OUT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                       "assets", "sounds")

# Pentatonic (anhemitonic): C D F G A
PENTA = {
    "C": 261.63, "D": 293.66, "F": 349.23, "G": 392.00, "A": 440.00,
    "C5": 523.25, "D5": 587.33, "F5": 698.46, "G5": 783.99, "A5": 880.00,
}

# ---------------------------------------------------------------- helpers


def _fade(x: np.ndarray, ms: float = 4.0) -> np.ndarray:
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


def noise(seconds, amp=1.0, decay=None, seed=1234):
    t = _t(seconds)
    rng = np.random.default_rng(seed)
    x = rng.standard_normal(len(t)) * amp
    env = np.exp(-t / (decay if decay is not None else seconds / 3.0))
    return x * env


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


def karplus_strong(freq: float, seconds: float, amp: float = 0.7,
                   damping: float = 0.996, seed: int = 7) -> np.ndarray:
    """Plucked string: a noise burst circulated through a feedback
    delay line of one period. Damping < 1 shortens the ring."""
    n = int(SR * seconds)
    period = max(2, int(round(SR / freq)))
    rng = np.random.default_rng(seed)
    buf = rng.uniform(-1.0, 1.0, period)
    out = np.zeros(n)
    idx = 0
    prev = 0.0
    for i in range(n):
        cur = buf[idx]
        out[i] = cur
        nxt = 0.5 * (cur + prev) * damping
        buf[idx] = nxt
        prev = cur
        idx += 1
        if idx >= period:
            idx = 0
    # Gentle attack + overall decay so the pluck settles.
    t = _t(seconds)
    env = np.exp(-t / max(seconds / 2.5, 0.05))
    env[: max(1, int(0.002 * SR))] *= np.linspace(0.0, 1.0,
                                                max(1, int(0.002 * SR)))
    return amp * out * env


def doum(seconds: float = 0.28, amp: float = 1.0) -> np.ndarray:
    """Dalluka deep *doum*: pitch-dropping sine (170 -> 65 Hz)
    plus a low thump of filtered noise."""
    body = tone(170, seconds, attack=0.004, decay=0.11, amp=amp,
                freq_end=65)
    thump = bandpass(noise(0.06, amp=0.5, decay=0.02, seed=99), 60, 300)
    return mix(body, thump)


def tak(amp: float = 0.9, seed: int = 5) -> np.ndarray:
    """Dalluka sharp *tak*: short band-passed noise burst."""
    return bandpass(noise(0.05, amp=amp, decay=0.012, seed=seed),
                    1600, 4200)


def reverb_tail(x: np.ndarray, tail_ms: float = 120.0,
                wet: float = 0.18) -> np.ndarray:
    """Light plate-style tail: a few decaying delayed taps."""
    tail_n = int(SR * tail_ms / 1000.0)
    out = np.zeros(len(x) + tail_n)
    out[:len(x)] += x
    taps = [(0.011, 0.55), (0.023, 0.38), (0.037, 0.27), (0.053, 0.18),
            (0.071, 0.12), (0.094, 0.08)]
    for delay_s, gain in taps:
        d = int(delay_s * SR)
        out[d:d + len(x)] += x * (wet * gain)
    return out


def pluck_note(freq: float, seconds: float, amp: float = 0.6,
               seed: int = 7) -> np.ndarray:
    """Tambour note: Karplus-Strong fundamental + a soft octave shimmer."""
    return mix(karplus_strong(freq, seconds, amp=amp, seed=seed),
               karplus_strong(freq * 2, seconds * 0.7, amp=amp * 0.22,
                              damping=0.994, seed=seed + 1))


# ---------------------------------------------------------------- specs

def s_ui_tap():
    # Dry wood tick, 60 ms.
    return mix(tone(1200, 0.06, decay=0.015, amp=0.8),
               noise(0.012, amp=0.5, decay=0.004, seed=11))


def s_select():
    # Clay pebble lifted: short rising knock, 110 ms.
    return mix(tone(520, 0.11, freq_end=920, decay=0.05, amp=0.8),
               tone(1040, 0.11, freq_end=1500, decay=0.04, amp=0.25))


def _place_variant(seed: int, base: float):
    # Stone set on a woven mat: soft clay thud + tiny rattle, 200 ms.
    return mix(tone(base, 0.20, decay=0.05, amp=1.0),
               tone(base * 2.3, 0.10, decay=0.03, amp=0.45),
               noise(0.03, amp=0.35, decay=0.008, seed=seed))


def s_place1():
    return _place_variant(21, 140)


def s_place2():
    return _place_variant(22, 150)


def s_place3():
    return _place_variant(23, 132)


def _slide_variant(seed: int, lo: float, hi: float):
    # Stone dragged over straw: filtered noise swell, 240 ms.
    n = noise(0.24, amp=0.7, decay=0.12, seed=seed)
    n = bandpass(n, lo, hi)
    t = _t(0.24)
    n = n * (0.5 + 0.5 * np.sin(np.pi * t / 0.24))
    return n


def s_slide1():
    return _slide_variant(31, 300, 1600)


def s_slide2():
    return _slide_variant(32, 380, 1900)


def s_slide3():
    return _slide_variant(33, 260, 1400)


def s_land():
    # Stone meets wood: short dull knock, 120 ms.
    return mix(tone(180, 0.12, decay=0.035, amp=0.9),
               tone(360, 0.06, decay=0.02, amp=0.4),
               noise(0.015, amp=0.4, decay=0.005, seed=41))


def _capture_variant(note: str, seed: int):
    # Dalluka *tak* + clay crack + a tambour pluck, 380 ms.
    crack = mix(noise(0.03, amp=0.8, decay=0.008, seed=seed),
                tone(220, 0.12, decay=0.04, amp=0.6))
    pluck = pluck_note(PENTA[note], 0.38, amp=0.55, seed=seed)
    out = np.zeros(int(SR * 0.38))
    out[:len(crack)] += crack
    out[:len(tak(0.9, seed))] += tak(0.9, seed)
    out[int(0.03 * SR):] += pluck[:len(out) - int(0.03 * SR)]
    return out


def s_capture1():
    return _capture_variant("C", 51)


def s_capture2():
    return _capture_variant("D", 52)


def s_capture3():
    return _capture_variant("F", 53)


def s_capture_multi():
    # *doum-tak-tak* roll + two tambour notes up the scale, 600 ms.
    out = np.zeros(int(SR * 0.60))
    d = doum(0.28, amp=0.9)
    out[:len(d)] += d
    t1 = tak(0.9, 61)
    off = int(0.14 * SR)
    out[off:off + len(t1)] += t1
    t2 = tak(0.8, 62)
    off = int(0.28 * SR)
    out[off:off + len(t2)] += t2
    for note, start in [("F", 0.16), ("A", 0.32)]:
        p = pluck_note(PENTA[note], 0.30, amp=0.5, seed=63)
        o = int(start * SR)
        seg = p[: len(out) - o]
        out[o:o + len(seg)] += seg
    return out


def s_invalid():
    # Muted wooden double knock, 150 ms.
    out = np.zeros(int(SR * 0.15))
    knock = mix(tone(95, 0.06, decay=0.025, amp=0.9),
                noise(0.01, amp=0.3, decay=0.004, seed=71))
    out[:len(knock)] += knock
    off = int(SR * 0.075)
    out[off:off + len(knock)] += knock * 0.8
    return out


def s_turn():
    # Single soft tambour note (D) when the turn comes to you, 220 ms.
    return pluck_note(PENTA["D"], 0.22, amp=0.55, seed=81)


def s_hint():
    # Two-harmonic bell pluck, 320 ms.
    return mix(pluck_note(PENTA["G"], 0.32, amp=0.5, seed=91),
               karplus_strong(PENTA["G"] * 2, 0.25, amp=0.2, seed=92))


def s_undo():
    # Reverse straw swish: noise rising then cut, 220 ms.
    n = noise(0.22, amp=0.6, decay=10.0, seed=101)
    n = bandpass(n, 500, 2400)
    t = _t(0.22)
    env = (t / 0.22) ** 2
    return n * env


def s_start():
    # Three tambour notes ascending (C-F-A) over a *doum*, 750 ms.
    out = np.zeros(int(SR * 0.75))
    d = doum(0.35, amp=0.8)
    out[:len(d)] += d
    for note, start in [("C", 0.0), ("F", 0.20), ("A", 0.40)]:
        p = pluck_note(PENTA[note], 0.34, amp=0.55, seed=111)
        o = int(start * SR)
        out[o:o + len(p)] += p
    return out


def s_win():
    # Ascending tambour pentatonic run with dalluka accents and a
    # bright final chord, 1.8 s + reverb tail.
    out = np.zeros(int(SR * 1.8))
    for i, note in enumerate(["C", "D", "F", "G", "A"]):
        p = pluck_note(PENTA[note], 0.5, amp=0.55, seed=121 + i)
        o = int(i * 0.16 * SR)
        out[o:o + len(p)] += p
    for start in [0.0, 0.48, 0.96]:
        d = doum(0.25, amp=0.55)
        o = int(start * SR)
        out[o:o + len(d)] += d
    chord = mix(pluck_note(PENTA["C5"], 0.7, amp=0.5, seed=131),
                pluck_note(PENTA["F5"], 0.7, amp=0.45, seed=132),
                pluck_note(PENTA["A5"], 0.7, amp=0.45, seed=133))
    o = int(1.05 * SR)
    out[o:o + len(chord)] += chord
    return reverb_tail(out, tail_ms=150.0, wet=0.18)


def s_lose():
    # Two falling tambour notes, soft *doum*, 1.2 s + reverb tail.
    out = np.zeros(int(SR * 1.2))
    for note, start in [("A", 0.0), ("F", 0.45)]:
        p = pluck_note(PENTA[note], 0.6, amp=0.5, seed=141)
        o = int(start * SR)
        out[o:o + len(p)] += p
    d = doum(0.3, amp=0.5)
    o = int(0.55 * SR)
    out[o:o + len(d)] += d
    return reverb_tail(out, tail_ms=120.0, wet=0.15)


def s_draw():
    # Two level notes, 800 ms.
    out = np.zeros(int(SR * 0.8))
    for note, start in [("G", 0.0), ("G", 0.35)]:
        p = pluck_note(PENTA[note], 0.4, amp=0.5, seed=151)
        o = int(start * SR)
        out[o:o + len(p)] += p
    return out


SPECS = [
    ("ui_tap.wav", 0.06, s_ui_tap),
    ("select.wav", 0.11, s_select),
    ("place1.wav", 0.20, s_place1),
    ("place2.wav", 0.20, s_place2),
    ("place3.wav", 0.20, s_place3),
    ("slide1.wav", 0.24, s_slide1),
    ("slide2.wav", 0.24, s_slide2),
    ("slide3.wav", 0.24, s_slide3),
    ("land.wav", 0.12, s_land),
    ("capture1.wav", 0.38, s_capture1),
    ("capture2.wav", 0.38, s_capture2),
    ("capture3.wav", 0.38, s_capture3),
    ("capture_multi.wav", 0.60, s_capture_multi),
    ("invalid.wav", 0.15, s_invalid),
    ("turn.wav", 0.22, s_turn),
    ("hint.wav", 0.32, s_hint),
    ("undo.wav", 0.22, s_undo),
    ("start.wav", 0.75, s_start),
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
