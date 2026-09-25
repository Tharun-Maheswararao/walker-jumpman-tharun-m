# BEAT SHEET — walker-jumpman-tharun-m explainer

**Student:** Tharun Maheswararao · CSYE 7270, Fall 2026
**Workflow:** Brutalist `godot-waikthrough`, **walker** modifier
**Format:** landscape, native 4K (3840×2160), per the skill's own rendering and
quality checks
**Target duration:** ~3:30. Duration follows the explanation; there is no
runtime to fill.
**Game-source revision to demonstrate:** `5bdd71e` (the final game-source revision; later commits are documentation only)

> **Status: RENDERED.** 3840×2160, 4:10, 13 beats. The authoritative, as-built
> beat sheet is `youtube/claude-liam-walker-jumpman-tharun-m-walkthrough/beat_sheet.json`,
> with the as-built shot list in that folder's `SHOTLIST.md`. This document is
> the plan it was built from; where the two differ, the reel folder is correct.

---

## Required structure

| Block | Source |
| --- | --- |
| Walker opening | Skill template |
| Body — beats 1–8 below | This document |
| Walker summary | Skill template |
| **Verdict** | Beat 9 |
| **Your Turn** | Beat 10 |
| Regular outro | Skill template |

## Capture rules for this film

These are constraints on the edit, not decoration.

1. **Every gameplay frame is the real game** running the committed source at
   revision `5bdd71e`. Nothing is re-enacted, re-created, or mocked up.
2. **On-screen labels are mandatory** for anything that is not live human play:
   * `SCRIPTED INPUT` — footage driven by `tests/route_driver.gd`
   * `HELD FRAME` — any frozen frame held for narration
   * `TOOL OUTPUT — NOT GAMEPLAY` — the character contact sheet, the jump
     envelope table, terminal output
   * `STARTER DRAW CODE + NEW LEVEL DATA` — the before-frame in beat 6, which
     is a real capture of a **deliberately reconstructed** build and must never
     be presented as the shipped game
3. **The failure in beat 5 is a real death** produced by the game's own
   collision check. No faked completion, and the film does not hide a defect.
4. Live human play is used wherever it exists; scripted-input capture is used
   only where a precise, repeatable line is needed, and is labelled.

## Shot list

| # | Beat | Duration | Visual | Label |
| --- | --- | --- | --- | --- |
| 0 | Walker opening | ~0:12 | Skill template | — |
| 1 | What this is | 0:20 | Split: starter running at `8c9085d` / this build at `5bdd71e`, same opening seconds | `STARTER 9387542` vs `5bdd71e` |
| 2 | The character | 0:30 | Live play in the original section, then cut to the contact sheet with the collider overlay | `TOOL OUTPUT — NOT GAMEPLAY` on the sheet |
| 3 | Designing against measured physics | 0:25 | `probe_jump.gd` terminal output; envelope table as a lower third | `TOOL OUTPUT — NOT GAMEPLAY` |
| 4 | The new section | 0:35 | Continuous live run: Junction → stone → stone → ground run | — |
| 5 | **Failure and recovery** | 0:25 | Real death on the terrace spike bank, retry card, respawn, second attempt succeeds | — |
| 6 | **Cause and effect** | 0:40 | Before/after on the raised spike bank, with the source diff on screen | `STARTER DRAW CODE + NEW LEVEL DATA` on the before-frame |
| 7 | The fork, both roads | 0:30 | High road to the flag; then low road under the terrace, buttress, doubling back. Tick counters as a lower third | `SCRIPTED INPUT` if the timed comparison uses the fixtures |
| 8 | Completion | 0:10 | Reaching the flag, completion card, Enter to replay | — |
| 9 | **Verdict** | 0:25 | Test totals; the refuted bonk prediction and the single-playtester bias stated plainly | — |
| 11 | **Your Turn + credits** | 0:51 | One concrete experiment, then the human/AI credits and the revision demonstrated | — |
| 11 | Walker summary + outro | ~0:15 | Skill template + credits card | — |

## Beat 6 in detail — the required cause-and-effect

This is the beat the assignment specifically asks for, so it gets the most time.

**The source change.** `session.gd` built spike *triggers* from the level data
but drew spike *art* with the y coordinate hard-coded to the ground line:

```gdscript
# starter
draw_colored_polygon(PackedVector2Array([
    Vector2(x, 320), Vector2(x + 4, 304), Vector2(x + 8, 320)]), ...)
```

**The behaviour on screen.** Put a hazard on a raised terrace and the trigger
goes where the data says while the picture stays on the ground — 64 px apart.
The before-frame shows SPROCKET walking into a killer that is not drawn, above
a decoration that cannot hurt anyone.

**The fix.** One function, `hazard_triangle()`, is now the single definition of
a spike's shape, called by **both** the trigger builder and the renderer. They
cannot drift apart. `test_extension.gd::hazard-art-matches-trigger` asserts the
trigger polygons really are rebuilt from it.

**The proof.** Cut between the two real captures:
`evidence/screens/bug-before-15-terrace-and-raised-spikes.png` →
`evidence/screens/15-terrace-and-raised-spikes.png`.

This is also the honest beat: the same frame shows two more predicted failures
(missing backdrop, saturated progress bar) **and** one I did not predict — the
finish pole drawn from the old ground baseline, spearing through the terrace.

## Evidence the edit cuts against

| Asset | Use |
| --- | --- |
| `evidence/screens/character-sheet.png` | Beat 2 |
| `evidence/jump-envelope.json` + probe terminal output | Beat 3 |
| `evidence/screens/12-junction-and-stones.png`, `13-stone-hop.png` | Beat 4 reference |
| `evidence/screens/21-terrace-spike-failure.png`, `22-missed-landing-failure.png` | Beat 5 reference |
| `evidence/screens/bug-before-15-*.png` → `15-*.png` | Beat 6 |
| `evidence/screens/14-the-fork.png`, `18-low-road-under-terrace.png`, `19-climb-out-buttress.png` | Beats 7, 10 |
| `evidence/screens/17-complete.png`, `20-low-road-complete.png` | Beat 8 |
| `evidence/extension-*.json`, `mechanics-*.json`, `keyboard-*.json` | Beat 9 |

## Attribution card (beat 11, on screen and read aloud)

* **Revision demonstrated:** `5bdd71e`. Starter: `nikbearbrown/walker-jumpman`
  @ `9387542`, Godot 4.7.2.
* **Human (Tharun Maheswararao):** direction and scope; chose the character
  concept; chose the film approach; owns the submission and the explanation.
* **AI (Claude Code, Opus 5):** wrote effectively all of the GDScript, the
  tests, the tooling, the first draft of every document, and this script.
* **Narration:** AI text-to-speech (Liam), permitted by the assignment.
* **Art:** original Godot vector drawing. No imported, purchased or
  AI-generated assets.
* **Not claimed:** only one playtester, the author; no second playtester.

## Quality gate before publishing

1. Watch the whole export end to end. No skipping.
2. Text legible at 100% and at half size; narration intelligible throughout.
3. Every non-live-gameplay shot carries its label.
4. The revision shown on screen matches the committed source being submitted.
5. Record the final filename and SHA-256 in README.md and SUBMISSION.md.
