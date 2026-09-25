"""Original STARBIT effects; deterministic synthesis, no external recordings.
Requires Python, numpy, scipy and ffmpeg. Run with the output folder as argument.
"""
from pathlib import Path
import json
import subprocess
import sys
import tempfile
import wave
import numpy as np
from scipy import signal

RATE = 44100
RNG = np.random.default_rng(250925)
OUT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("assets/audio/sfx")
OUT.mkdir(parents=True, exist_ok=True)
STATS = {}

def timeline(seconds):
    return np.arange(round(seconds * RATE), dtype=float) / RATE

def band(x, low, high):
    sos = signal.butter(2, [low, high], btype="bandpass", fs=RATE, output="sos")
    return signal.sosfilt(sos, x)

def envelope(t, attack=0.01, release=0.055):
    a = np.clip(t / attack, 0, 1)
    r = np.clip((len(t) / RATE - t) / release, 0, 1)
    return np.sin(a * np.pi / 2) ** 2 * np.sin(r * np.pi / 2) ** 2

def phase(frequency):
    return 2 * np.pi * np.cumsum(frequency) / RATE

def save(name, x, rms_db=-18):
    x = signal.sosfilt(signal.butter(2, 45, btype="highpass", fs=RATE, output="sos"), x)
    x *= envelope(np.arange(len(x)) / RATE, 0.0025, 0.018)
    x *= min(10 ** (rms_db / 20) / (np.sqrt(np.mean(x * x)) + 1e-12), .67 / (np.max(np.abs(x)) + 1e-12))
    pcm = np.rint(np.clip(x, -1, 1) * 32767).astype('<i2')
    with tempfile.TemporaryDirectory() as tmp:
        wav = Path(tmp) / (name + ".wav")
        with wave.open(str(wav), 'wb') as f:
            f.setnchannels(1); f.setsampwidth(2); f.setframerate(RATE); f.writeframes(pcm.tobytes())
        subprocess.run(['ffmpeg', '-hide_banner', '-loglevel', 'error', '-y', '-i', str(wav),
                        '-c:a', 'libvorbis', '-q:a', '5', str(OUT / (name + '.ogg'))], check=True)
    STATS[name] = {'seconds': round(len(x) / RATE, 3), 'peak_db': round(20 * np.log10(np.max(np.abs(x))), 2),
                   'rms_db': round(20 * np.log10(np.sqrt(np.mean(x * x))), 2)}

def bell(t, frequency, decay):
    # A rounded mallet attack with quiet glass overtones and no sharp click.
    x = np.zeros(len(t))
    for ratio, strength, tail in [(1, 1, 1), (2.003, .24, .7), (2.76, .10, .45), (4.08, .035, .3)]:
        x += strength * np.sin(2 * np.pi * frequency * ratio * t) * np.exp(-t / (decay * tail))
    return x * (1 - np.exp(-t / .0035))

for i, fundamental in enumerate([1318.51, 1567.98, 1760.0], 1):
    t = timeline(.36)
    x = bell(t, fundamental, .085)
    delay = round(.045 * RATE)
    x[delay:] += .36 * bell(t[:-delay], fundamental * 1.5, .065)
    # A small, short halo keeps repeated pickups distinct.
    d = round(.061 * RATE)
    x[d:] += x[:-d].copy() * .095
    save(f'diamond_{i:02}', x, -20)

for i, pitch in enumerate([1.0, 1.035], 1):
    t = timeline(.23); u = t / .23
    f = pitch * (260 + 400 * (1 - np.exp(-u * 3.6)))
    p = phase(f)
    spring = (np.sin(p) + .11 * np.sin(2 * p)) * np.sin(np.pi * u) ** 1.1 * np.exp(-u * 2.8)
    air = band(RNG.normal(0, 1, len(t)), 900, 3200) * np.sin(np.pi * u) ** 1.5
    save(f'jump_{i:02}', .75 * spring + .11 * air, -19)

t = timeline(.31); u = t / .31
p = phase(360 + 640 * (1 - np.exp(-u * 3)))
boost = (np.sin(p) + .13 * np.sin(p * 1.5)) * np.sin(np.pi * u) * np.exp(-u * 2)
boost += band(RNG.normal(0, 1, len(t)), 1100, 3500) * .10 * np.sin(np.pi * u)
save('boost_01', boost, -20)

def impact(seconds, heavy=False, variation=0):
    t = timeline(seconds)
    start = (125 if heavy else 195) * (1 + variation * .05)
    low = 65 if heavy else 105
    p = phase(low + (start - low) * np.exp(-t * 32))
    thump = np.sin(p) * np.exp(-t * (22 if heavy else 30))
    body = np.sin(2.06 * p) * .24 * np.exp(-t * 38)
    cloth = band(RNG.normal(0, 1, len(t)), 160, 2300) * np.exp(-t * 40)
    scuff = band(RNG.normal(0, 1, len(t)), 700, 2500) * np.exp(-((t - .058) / .038) ** 2)
    return (thump + body + .24 * cloth + .07 * scuff) * envelope(t, .004, .05)

for i in [1, 2]:
    save(f'land_{i:02}', impact(.20, False, i - 1), -20)
    save(f'bear_step_{i:02}', impact(.23, True, i - 1), -20)

def bear(seconds, pitch_from, pitch_to, breath=.22, roughness=.22, variant=0, double=False):
    t = timeline(seconds); u = t / seconds
    drift = signal.sosfilt(signal.butter(2, 14, fs=RATE, output='sos'), RNG.normal(0, 1, len(t)))
    f = pitch_from + (pitch_to - pitch_from) * u + 4.0 * np.sin(2 * np.pi * 3.2 * t) + 18 * drift
    p = phase(f)
    throat = np.zeros(len(t))
    # Low, breathy animal-like vocal tract, with tablet-audible harmonics.
    for h in range(1, 31):
        hz = f * h
        formants = (.32 * np.exp(-.5 * ((hz - 310) / 155) ** 2)
                    + .55 * np.exp(-.5 * ((hz - 690) / 240) ** 2)
                    + .20 * np.exp(-.5 * ((hz - 1230) / 320) ** 2))
        throat += np.sin(p * h + h * .19) * formants / h ** .55
    rasp = band(RNG.normal(0, 1, len(t)), 150, 1650)
    throat = throat * (1 - roughness + roughness * np.sin(p * .47 + .3)) + .11 * rasp
    puff = band(RNG.normal(0, 1, len(t)), 160, 2100)
    mouth = np.sin(np.pi * np.clip(u, 0, 1)) ** .7
    if double:
        mouth *= 1 - .52 * np.exp(-((u - .5) / .05) ** 2)
    voiced = throat * mouth * (1 - .42 * u)
    air = puff * breath * np.exp(-((u - .73) / .27) ** 2)
    return (voiced + air) * envelope(t, .025, .10)

for i in [1, 2]:
    save(f'bear_warn_{i:02}', bear(.86, 112 + i * 3, 84 + i * 2, .20, .32, i, True), -18)
    save(f'bear_charge_{i:02}', bear(.58, 145 + i * 2, 95 + i * 3, .42, .26, i), -18)
    voice = bear(.43, 170 + i * 3, 107 + i * 2, .19, .15, i)
    thud = impact(.21, True, i - 1)
    voice[:len(thud)] += thud * .34
    save(f'bear_hit_{i:02}', voice, -19)

save('bear_rest_01', bear(.51, 116, 77, .64, .13), -21)
t = timeline(.95)
released = np.zeros(len(t)); voice = bear(.67, 123, 143, .18, .06)
released[:len(voice)] += voice * .9
for delay, freq in [(.22, 659.25), (.31, 880), (.4, 1318.51)]:
    at = round(delay * RATE)
    released[at:] += bell(t[:len(t)-at], freq, .13) * .055
save('bear_free_01', released, -20)
print(json.dumps(STATS, ensure_ascii=False, indent=2))
