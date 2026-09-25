# BUILD-PROMPT.md — how this reel was produced

Skill: `godot-waikthrough` with the `walker` modifier, from the course-provided
[nikbearbrown/brutalist.art](https://github.com/nikbearbrown/brutalist.art).

```text
godot-waikthrough walker /Users/tharunmaheswararao/Documents/csye7270/walker-jumpman-tharun-m
```

## Order of operations

1. Read `SKILL.md`, `references/capture-and-coverage.md`, `RENDER-TARGETS.md`,
   `docs/PIPELINE-SAFETY.md`, `OUTRO-LOCK.md` and the `riff` skill.
2. Inventory implemented vs planned features from source plus a real run.
3. Capture on an isolated project copy with a real-Input driver (`CAPTURE.md`).
4. Author `coverage.json` against measured times from the input logs.
5. Author `beat_sheet.json`; generate Kokoro audio; audio durations set the clock.
6. Pre-trim each `media/Bxx.mp4` to exactly `render_duration_s × 30` frames.
7. Render bookends with `runtime/scripts/remotion_scenes.py`.
8. `./art final REEL --height 2160 --fps 30`.
9. `verify_walkthrough.py REEL` and visual review in `_qc/REPORT.md`.

## Toolchain notes for anyone reproducing this

Two environment problems were hit and are recorded rather than hidden:

* **`./setup` exits before its readiness table.** Its ElevenLabs guard matches
  the toolkit's own bundled examples under `youtube/brutalist/…` and exits 1.
  `./setup --install` still installs (the install block runs first), but the
  readiness table never prints. Dependencies were verified by hand instead.
  The toolkit was **not** modified to work around this.
* **Python 3.13 cannot satisfy `requirements.txt`.** `manim>=0.18,<0.19`
  requires Python `<3.13`, and that single unsatisfiable pin aborts the whole
  `pip install`, so kokoro-onnx and mutagen never install either. Fixed by
  creating a Python 3.12 virtualenv for the toolkit. `manimpango` additionally
  needs native `pango`/`cairo` (`brew install pango cairo pkg-config`), and
  `ffmpeg` is required but not installed by `--install`.

## Gates

| Gate | Result |
|---|---|
| GATE T (`type_check.py`) | PASS, 0 FAILs — after a real legibility fix, see `_qc/REPORT.md` |
| GATE F (`FACTCHECK.md`) | Present and complete |
| `verify_walkthrough.py` | PASS — 20 implemented features, 20 evidence intervals, all captures 3840×2160 |
