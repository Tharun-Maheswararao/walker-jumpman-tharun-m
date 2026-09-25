# PROMPTS.md — Walker Jumpman, Extended

## B00 — the opening ask (RECONSTRUCTED)

**This is an illustrative reconstruction, not a saved transcript.** It is
labelled as such on the card and in narration. No claim is made that this exact
text was ever sent, and no fictional build log or progress receipt is shown.

> Please use Walker to convert my game design document about a wind-up tin
> automaton crossing a broken causeway, where the player must choose between a
> direct spiked terrace and a safe but longer road, into a playable Godot
> project.

Card output lines (all checkable against the repository):

```
■ walker-jumpman-tharun-m  ·  Godot 4.7.2
  CHARACTER  SPROCKET, a wind-up tin automaton
  SECTION    03 / THE FORK  ·  course 960px → 2080px
  FLAG       moved x=916 → x=1824
  RECONSTRUCTED PROMPT — illustrative, not a transcript
```

## B11 — Your Turn

> Derive the launch-guide band from the measured take-off window at load time,
> so the paint and the physics cannot disagree.

Why this one: it is the last hand-placed number in the level. Every other
marker — spikes, finish pole, grid, backdrop, hills, progress bar — is derived
from level data. `hazard_triangle()` already proves the pattern.

## Narration

Full narration text is in `beat_sheet.json` under each beat's
`narration_text`, and reproduced in `../../film/SCRIPT.md`. Generated with
local Kokoro `am_onyx` (free, no key, no account). Durations in
`actual_duration_s` are measured from the generated audio and are the master
clock for the cut.
