# Audio Equalizer (MATLAB)

A 10-band graphic audio equalizer with a GUI, built in MATLAB App Designer.
Load an audio file, shape it with sliders or presets, visualize the waveform
and spectrogram, and export the result.

## Files

| File | Purpose |
|---|---|
| `Equalizer.m` | Main app class — GUI layout and all callbacks |
| `applyMultiBandEq.m` | FFT-domain multi-band equalizer (mono + stereo) |
| `simpleSpectrogram.m` | Custom STFT — avoids Signal Processing Toolbox |
| `equalizerPresets.m` | Named preset gain vectors |

Only **core MATLAB** is used. No Signal Processing Toolbox or Audio Toolbox
is required, so it runs on MATLAB Online Basic (the free tier).

## Running on MATLAB Online (free, nothing to install)

1. Go to https://matlab.mathworks.com and sign in with a MathWorks account.
   Create one for free if you don't have it (a personal email works).
2. The page opens MATLAB Online in the browser.
3. In the **Current Folder** panel on the left, create a folder, e.g. `Equalizer`,
   and double-click to enter it.
4. Get the project files into that folder — either way works:
   - **Drag & drop**: drag the four `.m` files from your computer onto the
     Current Folder panel.
   - **Git clone**: in the Command Window run
     ```matlab
     !git clone https://github.com/Omarmahmoud711/Equalizer.git
     cd Equalizer
     ```
5. Upload at least one audio file (`.wav`, `.mp3`, `.flac`, `.ogg`, `.m4a`) to
   the same folder by dragging it into the Current Folder panel.
6. In the Command Window, run:
   ```matlab
   Equalizer
   ```
7. The GUI window opens. Click **Browse...**, pick your audio file, move the
   10 band sliders or click a preset, then hit **Play**.

> The first time you play audio, your browser may ask for permission to play
> sound from `matlab.mathworks.com` — allow it.

## Controls

- **Browse...** — load an audio file
- **Save...** — export the current equalized output as a `.wav`
- **10 band sliders** — 30 Hz, 60 Hz, 170 Hz, 310 Hz, 600 Hz, 1 kHz, 3 kHz,
  6 kHz, 10 kHz, 20 kHz, each ±20 dB
- **Presets** — Flat, Party, Classical, Techno, Rock, Reggae, Pop
- **Play / Pause / Resume / Stop**
- **Volume** — 0–100 %

Any slider or preset change re-processes the audio and stops playback —
press **Play** again to hear the new setting.

## How the EQ works

`applyMultiBandEq.m` takes the FFT of the signal, builds a gain curve by
linearly interpolating the 10 band gains on a **log-frequency** axis, and
multiplies the spectrum by that curve bin-by-bin. The gain curve is folded
symmetrically around Nyquist so the inverse FFT is real-valued. This is an
**offline** EQ — it processes the whole file at once, which is ideal for the
load-tweak-play workflow here.

## Troubleshooting

- *"Undefined function or variable 'Equalizer'"* — make sure the Current
  Folder is the folder containing the four `.m` files.
- *No sound* — check your browser tab audio and the Volume slider.
- *"Unknown preset"* — only happens if you call `equalizerPresets` directly
  with a name other than Flat / Party / Classical / Techno / Rock / Reggae / Pop.
