<div align="center">

# 🎚️ Audio Equalizer

**A 10-band graphic audio equalizer with a GUI, built in MATLAB App Designer.**

*Load any audio file, sculpt its frequency response with sliders or presets, watch the waveform and spectrogram update live, and export the result — all in the browser.*

![MATLAB](https://img.shields.io/badge/MATLAB-R2020a%2B-0076A8?logo=mathworks&logoColor=white)
![No Toolbox Required](https://img.shields.io/badge/Toolbox-not%20required-2EA44F)
![Runs on MATLAB Online Basic](https://img.shields.io/badge/MATLAB%20Online%20Basic-ready-blue)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

</div>

---

## 📸 Screenshot

![Audio Equalizer GUI](docs/screenshot.png)

<sub>*Drop a PNG at `docs/screenshot.png` to display it here.*</sub>

---

## ✨ Features

- 🎛️ **10-band graphic equalizer** — 30 Hz → 20 kHz, ±20 dB per band
- 🎵 **7 one-click presets** — Flat · Party · Classical · Techno · Rock · Reggae · Pop
- 📊 **Live visualization** — waveform + log-magnitude spectrogram
- 🎧 **Full transport controls** — Play · Pause · Resume · Stop · Volume
- 💾 **Export** the equalized audio as `.wav`
- 📼 **Stereo-aware** — mono or stereo input, preserved channel count
- 🔌 **Zero toolbox dependencies** — uses only core MATLAB, runs on the free tier

---

## 🚀 Quick Start — MATLAB Online (nothing to install)

1. Go to **[matlab.mathworks.com](https://matlab.mathworks.com)** and sign in (free MathWorks account is fine).
2. In the **Current Folder** pane on the left, open or create a folder.
3. Clone the repo from the Command Window:
   ```matlab
   !git clone https://github.com/Omarmahmoud711/Equalizer.git
   cd Equalizer
   ```
   *Alternative: drag the `.m` files from your computer into the Current Folder pane.*
4. Upload an audio file (`.wav`, `.mp3`, `.flac`, `.ogg`, or `.m4a`) to the same folder — drag-and-drop works.
5. Launch the app:
   ```matlab
   Equalizer
   ```
6. Click **Browse…** → pick the audio → drag sliders or hit a preset → **Play**.

> 🔔 The first time audio plays, your browser may ask for permission to play sound from `matlab.mathworks.com` — allow it.

---

## 🎛️ UI Layout

```
┌────────────────────────────────────────────────────────────────────────┐
│  [ Browse… ]   /path/to/audio.wav                         [ Save… ]    │
├────────────────────────────────────────────────────────────────────────┤
│                                                                        │
│   ┌── Waveform ────────────┐       ┌── Spectrogram (dB) ──────────┐    │
│   │    /\  /\    /\    /\  │       │  ▓▓▒▒░░   ▓▒░                │    │
│   │   /  \/  \__/  \__/  \ │       │  ▓▓▓▒▒░░░ ▓▓▒░               │    │
│   └────────────────────────┘       └──────────────────────────────┘    │
│                                                                        │
├────────────────────────── Equalizer ──────────┬──── Presets ───────────┤
│                                               │                        │
│    ║   ║   ║   ║   ║   ║   ║   ║   ║   ║     │  [Flat]  [Party]       │
│    ║   ║   ║   ║   ║   ║   ║   ║   ║   ║     │  [Classical] [Techno]  │
│    ║   ║   ║   ║   ║   ║   ║   ║   ║   ║     │  [Rock]  [Reggae]      │
│                                               │         [Pop]          │
│   30  60  170 310 600  1k  3k  6k  10k 20k   │                        │
├────────────────────────── Playback ────────────────────────────────────┤
│  [▶ Play]  [⏸ Pause]  [⏯ Resume]  [⏹ Stop]      Volume  ───●─── 80 %   │
│  Status: Ready. Click Browse to load an audio file.                    │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 🎚️ Controls Reference

| Control | What it does |
|---|---|
| **Browse…** | Open an audio file from MATLAB Drive |
| **Save…** | Export the current equalized output as a `.wav` |
| **10 band sliders** | Cut or boost each frequency band by ±20 dB |
| **Presets** | One-click genre curves — fills the sliders for you |
| **Play / Pause / Resume / Stop** | Standard transport |
| **Volume** | 0 – 100 % master gain (applies on next Play) |

> Any slider or preset change re-processes the audio and stops playback — press **Play** again to hear the new setting.

---

## 🎶 Presets (gain in dB per band)

| Band         | 30 Hz | 60 Hz | 170 Hz | 310 Hz | 600 Hz | 1 kHz | 3 kHz | 6 kHz | 10 kHz | 20 kHz |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| **Flat**      |  0 |  0 |  0 |  0 |  0 |  0 |  0 |  0 |  0 |  0 |
| **Party**     | +6 | +6 | +3 |  0 |  0 | +2 | +4 | +4 | +6 | +4 |
| **Classical** | +4 | +4 | +4 | +4 |  0 |  0 | −2 | −2 |  0 |  0 |
| **Techno**    | +6 | +6 | +4 |  0 | −3 | −3 |  0 | +4 | +6 | +6 |
| **Rock**      | +5 | +4 | +3 | −3 | −5 | −3 | +2 | +5 | +6 | +6 |
| **Reggae**    |  0 |  0 |  0 | −3 | −3 |  0 | +4 | +4 |  0 |  0 |
| **Pop**       | −2 | −1 |  0 | +2 | +4 | +4 | +2 |  0 | −1 | −2 |

---

## 🧠 How the EQ works

The equalizer operates in the **frequency domain** — simpler and more accurate than chaining 10 bandpass filters:

1. **FFT** the signal.
2. Build a **gain curve** by linearly interpolating the 10 band gains on a *log-frequency* axis. Below the lowest band and above the highest, the gain is held at the endpoint value.
3. **Fold** the curve symmetrically around Nyquist so the inverse FFT stays real-valued.
4. **Multiply** the spectrum bin-by-bin by the gain curve.
5. **IFFT** back to the time domain.
6. **Normalize** if any peak exceeds ±1 to prevent digital clipping.

The spectrogram display is a hand-rolled STFT — 1024-sample Hann window with 50 % overlap — so the Signal Processing Toolbox is not required.

---

## 🗂️ Project Structure

```
Equalizer/
├── Equalizer.m            ← Main app class (GUI + all callbacks)
├── applyMultiBandEq.m     ← FFT-domain 10-band EQ (stereo-aware)
├── simpleSpectrogram.m    ← Custom STFT, no toolbox needed
├── equalizerPresets.m     ← Named preset gain vectors
└── README.md
```

---

## 🛠️ Troubleshooting

| Symptom | Fix |
|---|---|
| `Undefined function or variable 'Equalizer'` | `cd` into the folder containing the four `.m` files |
| No sound when you press Play | Check the browser tab isn't muted; raise the Volume slider; the first play may require a browser permission |
| Browser blocks audio | Click the speaker icon in the address bar and allow sound for `matlab.mathworks.com` |
| `Unknown preset` error | Only happens if `equalizerPresets` is called with a name outside the 7 supported presets |
| Audio sounds clipped | Lower the Volume slider or reduce slider boosts — the EQ already normalizes, but very aggressive curves still reduce headroom |

---

<div align="center">

*Built with 🎧 and MATLAB.*

</div>
