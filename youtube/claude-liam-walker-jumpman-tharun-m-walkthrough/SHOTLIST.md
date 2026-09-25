# SHOTLIST.md — Walker Jumpman, Extended

Revision demonstrated: `3aa05bb` · 13 beats · 4:10 (250.1s) · landscape 3840×2160 @30fps

Durations below are the **as-built** `render_duration_s` from `beat_sheet.json`, not plan estimates.

| # | Act | Source | What is on screen | Label |
|---|---|---|---|---|
| B00 | ASK | Remotion `ClaudeComposerAsk` | Walker prompt describing this game's actual idea | "RECONSTRUCTED PROMPT — illustrative, not a transcript" on the card |
| B01 | BLUF | Remotion `BrutalistHesitantWriter` | What was built, and the 53.3 → 56.0 correction | — |
| B02 | MECHANISM | `high-road` 0.00–8.20 + 101f hold | SPROCKET, the winding-key facing tell, the starter's own course | SCRIPTED INPUT · HELD FRAME |
| B03 | MECHANISM | `high-road` 6.20–11.60 + 129f hold | The Junction, both stepping stones, the ground run | SCRIPTED INPUT · HELD FRAME |
| B04 | MECHANISM | `failure-recovery` 5.60–21.13 | Early jump → 35px short → real death → auto-retry → completion | SCRIPTED INPUT |
| B05 | MECHANISM | `high-road` 9.30–13.77 + 127f hold | Launch guide, 48px terrace climb, spike hop, flag | SCRIPTED INPUT · HELD FRAME |
| B06 | MECHANISM | `low-road` 6.20–15.96 + 79f hold | Under the terrace, buttress, doubling back to the flag | SCRIPTED INPUT · HELD FRAME |
| B07 | MECHANISM | Stills comparison, 855f + 134f | The hazard draw bug, before and after, with callouts | "BEFORE — STARTER DRAW CODE + NEW LEVEL DATA · reconstructed build, not the shipped game" |
| B08 | MECHANISM | `controls` 0.00–8.53 + 125f hold | Title card, Enter, pause mid-jump, resume, R, M | SCRIPTED INPUT · HELD FRAME |
| B09 | FALSIFIABILITY | `replay` 8.00–16.40 + 52f hold | Completion card, Enter, counters reset | SCRIPTED INPUT · HELD FRAME |
| B10 | VERDICT | Remotion `ClaudeVerdictArtifact` | Observed working / uncertain / not built | — |
| B11 | YOUR TURN | Remotion `ClaudeComposerAsk` | One concrete experiment, then the human/AI credits and the revision demonstrated; Liam signs off | — |
| B12 | OUTRO | Remotion `ClaudeTitleOutro` | Title restate, @NikBearBrown, mascot | — |

## Cutting rules applied

1. **Action is never slowed or sped.** Where narration runs longer than the
   action, the clip ends on a **labelled final-frame hold**. Hold lengths are
   listed above; the longest is 129 frames (4.3s).
2. **No replay is presented as a second independent test.** Each capture
   appears in disjoint time ranges across beats; where the same capture is used
   more than once, the ranges do not overlap.
3. **Every non-live frame is labelled**, including the reconstructed before-frame.
4. **`render_duration_s` equals the media clip's frame count / 30** for every
   beat, so no beat is retimed by the compiler. Frame counts were verified with
   `ffprobe -count_frames` after assembly.

## As-built durations

| Beat | Seconds | Frames @30 |
| --- | ---: | ---: |
| B00 | 18.87 | 566 |
| B01 | 31.07 | 932 |
| B02 | 11.57 | 347 |
| B03 | 9.70 | 291 |
| B04 | 15.53 | 466 |
| B05 | 8.70 | 261 |
| B06 | 12.40 | 372 |
| B07 | 32.97 | 989 |
| B08 | 11.23 | 337 |
| B09 | 10.13 | 304 |
| B10 | 32.70 | 981 |
| B11 | 51.47 | 1544 |
| B12 | 3.80 | 114 |
| **Total** | **250.1** | **7504** |
