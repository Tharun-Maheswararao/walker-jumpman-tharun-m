# _qc/HUMAN-REVIEW.md — review by looking, not only by gate

`_qc/REPORT.md` is written by GATE V and is overwritten on every run. This file
is the review a person/agent performed by inspecting frames and logs, which the
machine gates explicitly do not certify.

Revision reviewed: `3aa05bb` · reel `claude-liam-walker-jumpman-tharun-m-walkthrough`

## Gate results

| Gate | Result |
|---|---|
| `type_check.py` (GATE T) | **PASS**, 0 FAILs, 13 beats |
| GATE V frame-level visual QC | **PASS**, 0 BLOCKER, 0 MAJOR, 26 frames sampled |
| GATE F (`FACTCHECK.md`, `PROMPTS.md`) | Present and complete |
| `verify_walkthrough.py` | **PASS** — 20 implemented, 5 planned, 20 evidence intervals, all captures 3840×2160 16:9 |

## Three gate findings, and what each one actually was

**1. GATE T §8.1 min-size — a real defect in the game, fixed in the game.**
A 36px text run against a 41px floor. Rather than exempt the beat, I extracted
the frame, ran the checker's own `text_run_bboxes` detector, and cropped the
blob at (1967,1545)–(2021,1581). It was the word **"Two"** in the in-world sign
*"Two stones. Then pick a road."* at font size 13. The checker was right: the
signage was below a sensible 4K legibility floor. Fixed by raising label sizes
13→17 and 15→20 in level data — no geometry, no physics. The signs are now
easier to read while playing, not only on film.

**2. GATE T §8.2 overflow — a framing problem, fixed in the film.**
Text outside title-safe on three gameplay beats: the game's **own HUD**, which
lives at the very top and bottom of its canvas. Moving the game's UI to satisfy
a film check would be changing the game to suit the film. Instead each capture
is inset to 3456×1944 (exactly 90%) on the game's own cream, which is what the
toolkit's `GodotDesignFigure` figure slot does for engine captures. The files in
`capture/` remain unscaled native 4K.

**3. GATE V low-contrast — the documented mixed-footage case.**
Five gameplay beats measured 0.26–0.28 whole-frame ink separation against a 0.30
floor. The frame average is dominated by the game's cream sky and pale parallax
hills — the game's intended background, not a scrim over text. Used the
sanctioned `qc.contrast_regions` mechanism to declare the two HUD bands where
the essential readable text actually lives, with a written `contrast_reason`.
That replaces **only** the whole-frame average; empty-frame, safe-area and fill
checks still ran and still passed.

**GATE V edge-bleed/underfill on B01 was my own layout defect**, not a false
positive: the card's text crossed the title-safe right edge and filled 28% of
the safe area. Rewritten as eight shorter lines at fontSize 130.

## Frames inspected by eye

| Beat | Checked | Result |
|---|---|---|
| B02 | SPROCKET legible at 100% and half size; winding key on the trailing side | OK |
| B03 | Both stones and both pits readable; "03 / THE FORK" legible after the size fix | OK |
| B04 | Death reads as a fall, not a cut; retry card readable; recovery in the same take | OK |
| B05 | Chevron band clearly visible before the jump; climb and spike hop both on screen | OK |
| B06 | SPROCKET visibly on the ground under the terrace; buttress and return legible | OK |
| B07 | Callouts point at the right pixels; reconstruction banner legible for the full before half | OK |
| B08 | Pause, resume, R and menu all legible; retry counter readable at "00" | OK |
| B09 | Completion card and reset counters readable | OK |
| B10–B12 | Verdict, Your Turn and outro legible; `@NikBearBrown` present | OK |

## Claims verified against logs rather than by eye

* B06 "same x, different y": `high-road` x=1760.9 y=243.9 `on_floor:false` vs
  `low-road` x=1760.9 y=319.9 `on_floor:true`.
* B04 death: `y=435.9`, below the `fall_y` of 430, `on_floor:false`.
* B08 pause: y=264.00 before, delta 0.0000 after 45 frames.

## Two capture defects found by reading logs, and fixed

1. **Landmarks named as outcomes.** They test x only, but were named "landed on
   stone 2". In the failure clip the player was *falling past* that x at
   y=314.6, so the label was false. Renamed to positions; `on_floor` added.
2. **A failure clip that failed for the wrong reason.** An earlier take died by
   running off stone 2 after the route ran out of jump marks, while its label
   claimed an early jump. The route was changed so the clip fails the way the
   narration says.

Neither was caught by any gate. Both came from reading the input logs.

## Limits of this review

* Native-render provenance is asserted from the capture method (`CAPTURE.md`),
  not independently re-derived.
* Feature-inventory completeness is my own source reading. Five GDD features are
  listed `planned` with reasons; if a grader finds an implemented feature I
  failed to list, the "complete walkthrough" claim is overstated.
* **No human-playtest footage is in this film.** Every clip is scripted input
  and labelled as such. The human playtest is written up in
  `../../TEST-REPORT.md` §7, not shown here.
