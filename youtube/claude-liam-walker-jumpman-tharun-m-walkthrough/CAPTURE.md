# CAPTURE.md — how this film's gameplay was recorded

## Build under capture

| Field | Value |
|---|---|
| Game | walker-jumpman-tharun-m |
| Revision | `3aa05bb` |
| Source-snapshot SHA-256 (`build_id`) | `97126e2f4b05ec29e3067b6f616459eab5758055dcebc44bfedd048b8dee1548` |
| Hash method | SHA-256 over `git ls-files godot` in sorted order; for each file the relative path, a NUL, then the SHA-256 of its bytes. 21 files. |
| Engine | `4.7.2.stable.official.ed1daf0bf` |
| Host | macOS 15.6 (Darwin 24.6.0), Apple M4, OpenGL Compatibility |
| Starter | nikbearbrown/walker-jumpman @ `9387542` |

## Method

Godot's **Movie Maker** (`--write-movie`), an offline deterministic render of
the real viewport. **This is not evidence of real-time frame rate.**

```bash
godot --path <capture-project>/godot \
      --write-movie clips/<clip>.avi --fixed-fps 30 \
      --script res://tools/capture_film.gd -- <clip>
```

Then transcoded to H.264 MP4 at CRF 16, 30fps, no audio.

## Resolution

The project's viewport is **640×360**. 640×360 × 6 = **3840×2160 exactly**, so
4K is reached by *integer scaling of the game's logical canvas*, not by
enlarging a smaller recording. Captures in `capture/` are natively rendered
3840×2160.

**Logical resolution is disclosed separately, as the reference requires:** the
game's logical canvas is 640×360; the captured frames are a crisp 6× scale of
that canvas. In the assembled film each capture is further inset to 3456×1944
(90%) inside the 3840×2160 frame so the game's own HUD — which sits at the very
top and bottom of its canvas — falls inside the title-safe box. The capture
files themselves are unscaled.

## Isolation

Harness/config changes were made on an **isolated copy** at `/tmp/filmwork`,
per the skill. The only difference from the submitted project is the window
size override (1280×720 → 3840×2160) in `project.godot`. The submitted
project's own `project.godot` is unchanged; `git status` was verified clean
after each capture run. The game writes no saves, so no separate user-data
directory was required.

## Input integrity

The driver (`godot/tools/capture_film.gd`, committed) writes **only** through
the real input path:

* `Input.action_press` / `Input.action_release` for `move_left`, `move_right`, `jump`
* parsed `InputEventKey` for Enter, Escape, R, M
* `test_control` is left **false**, so the player reads the same `Input`
  singleton a human keyboard drives

The driver observes position and state to decide *when* to press a key — which
the reference permits — and it never sets position, never sets velocity, never
sets state, never disables a collision check and never calls a completion
shortcut. Every input log records `no_teleport: true` and `no_state_writes: true`.

Held keys are released at the end of every run (`release_all()`).

Deaths are produced by the game's own fall and hazard checks; completions by
the goal `Area2D`.

## Clips

| Clip | Frames | Duration | Result |
|---|---:|---:|---|
| `high-road` | 412 | 13.77s | COMPLETE, 0 deaths |
| `low-road` | 478 | 15.97s | COMPLETE, 0 deaths |
| `failure-recovery` | 657 | 21.93s | COMPLETE, **1 real death** then recovery |
| `controls` | 256 | 8.57s | pause / resume / manual restart / menu, 0 deaths |
| `replay` | 491 | 16.40s | COMPLETE then replay with counters reset |

Each has a sibling `<clip>-inputs.jsonl`: a header line of run metadata, then
one line per input edge and per landmark crossing, with frame, seconds, x, y
and `on_floor`.

**Landmark naming.** Landmarks test the player's x only. They are therefore
named as positions ("reached x=1256"), never as outcomes ("landed on"), and
each record carries `on_floor` so a landing is distinguishable from a fall past
the same x. An earlier revision of this tool named them as landings and was
wrong in exactly the case that mattered — a failure clip where the player fell
past a stone rather than landing on it.

## The reconstructed before-frame (B07)

The "before" half of the cause-and-effect beat is a **real capture of a
deliberately reconstructed build**: the starter's `session.gd` and `hud.gd`
from commit `8c9085d`, run against the *new* level data, in a scratch
directory. It is not the shipped game and is labelled as such on screen for its
entire duration. Its purpose is to show the defect the fix removes.

## Audio

**The game is silent** — no sound is implemented in this build. Liam's
narration is the only audio. Nothing was muted, and no sound effects were
fabricated. No gameplay audio plays under the outro card.
