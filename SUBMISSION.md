# SUBMISSION — Assignment 1

**Assignment:** Assignment 1 - Extend Walker Jumpman
**Student:** Tharun Maheswararao (`maheswararao.t@northeastern.edu`)
**Project name:** `walker-jumpman-tharun-m`

---

## Identification

| Field | Value |
| --- | --- |
| **GitHub repository/folder URL** | ⬜ *fill in after pushing* |
| **Submitted commit SHA** | ⬜ *fill in — this is the final commit, and by definition cannot be written inside itself. Put the real SHA in the Canvas note.* |
| **Game-source revision to be shown in the film** | `e138323` — *Correct a stale course width in the route-budget comment*. This is the **final game-source revision**; every commit after it is documentation only and must not touch `godot/`. |
| **Godot version** | `4.7.2.stable.official.ed1daf0bf` |
| **Operating system** | macOS 15.6 (Darwin 24.6.0), Apple M4 |
| **Final film URL** | ⬜ *pending render — see "Film status" below* |
| **Final film filename** | ⬜ *pending render* |
| **Final film SHA-256** | ⬜ *pending render* |

**Revision relationship.** The film demonstrates game source `e138323`. Any
commits after it add film documentation only and **do not change the
demonstrated game source**. Verify with:

```bash
git diff --stat e138323 <submitted-sha> -- godot/
```

That command must report no changes under `godot/`. If it reports changes, the
film no longer matches the submitted source and must be re-rendered.

## Summary of my changes

An extension of [nikbearbrown/walker-jumpman](https://github.com/nikbearbrown/walker-jumpman)
@ `9387542`. The unmodified starter is committed here first, as `8c9085d`, so
every change is a reviewable diff against the instructor's original.

**Character.** Replaced the starter's seven-rectangle, blue-visor figure with
**SPROCKET**, a wind-up tin automaton: a chamfered brass barrel torso, a narrow
domed head with a single round lens, piston legs that retract into a coil when
airborne, and a winding key on the back that always trails — so facing is
readable from the silhouette rather than from a sliding visor. `_draw()` only.
Physics, all eight tuning values, and the 18×28 collider are untouched and
asserted so by tests.

**Level.** Added section **03 / THE FORK**, taking the course from 960 px to
2080 px and moving the flag from x = 916 to x = 1824. Every original solid, the
original spike and the spawn keep their exact coordinates. Seven new landings
require a jump: The Junction, two 64 px stepping stones over real pits, a ground
run, the terrace, the post-spike landing, and the low road's climb-out. The fork
is a genuine decision — the **high road** is a 48 px climb onto a spiked terrace,
the **low road** is safe ground underneath but the only way up is past the flag,
forcing a double-back that costs a measured **2.28 s**.

**Correctness.** The starter builds physics from level data but drew the world
from numbers hard-coded to a 960 px course. Widening the level exposed four
visual/physics mismatches, three of which I predicted in advance. All are fixed
and `hazard_triangle()` is now the single definition of a spike's shape, called
by both the trigger builder and the renderer, so they cannot drift apart again.
`evidence/screens/bug-before-*.png` are real captures of the defect.

**Verification.** 56 automated checks, 0 failures — the starter's 25 mechanics
checks, its 9 keyboard checks byte-identical, and 22 new extension checks.
Level geometry is designed against a **measured** jump envelope
(`tools/probe_jump.gd`: real apex 56.0 px, not the textbook 53.3 px), not
against arithmetic.

## Known limitations

1. **No human playtest is recorded.** TEST-REPORT §7 is an unexecuted protocol
   with empty results. An automated input route is not a playtest and is not
   presented as one. This is the largest gap in the submission.
2. **No second playtester** is claimed.
3. **The film is not rendered.** See below.
4. **The terrace jump has 8 px of margin** against a 56 px apex. The scripted
   route makes it every time because it jumps on an exact tick; a human will
   not, and first-timers will likely bonk the underside before the painted
   guide teaches the timing.
5. **The winding key overhangs the collider by 3.50 px** on the trailing side —
   measured, declared and asserted, not hidden.
6. **8 px of headroom** under the terrace on the low road. Walking through is
   fine; jumping while under it bonks.
7. **The fork reconverges** rather than branching. CHANGE-BRIEF §3 shows with
   measured numbers why genuinely parallel stacked lanes are impossible in this
   engine without re-tuning the jump, which the assignment forbids.
8. **The launch guide's position is hand-placed** and not validated against the
   physics by any test — named in the film as the next concrete improvement.
9. **No web export, no packaged application**, no cherries, no settings screen.

## Film status

**The film is not rendered.** The required Brutalist `godot-waikthrough` skill
(walker modifier) is not present in this checkout and no course-provided copy
was available on the machine used. Per the assignment's own instruction — *"If
your checkout lacks the skill, request the course-provided version before
proceeding"* — the course-provided version has been requested rather than
substituting a public repository that may differ from it.

Prepared and committed: [`film/BEAT-SHEET.md`](film/BEAT-SHEET.md) (structure,
shot list, capture and labelling rules, quality gate) and
[`film/SCRIPT.md`](film/SCRIPT.md) (full narration), together with the real
captured gameplay evidence the edit cuts against.

**On render, update:** this table, the film table in README.md, and the Canvas
note — with filename, SHA-256, URL, and confirmation that the demonstrated
source revision is unchanged.

Compute the checksum with:

```bash
shasum -a 256 <final-film-file>
```

## Contributions

* **Human (Tharun Maheswararao):** direction and scope; chose the character
  concept; chose the film approach; owns the submission and the explanation.
* **AI (Claude Code, Opus 5):** wrote effectively all of the GDScript, the
  tests, the tooling, and the first draft of every document in this repository.
* **Film narration:** AI text-to-speech (Liam), permitted by the assignment.
* **Assets:** none imported. All art is original Godot vector drawing.

Full detail in [SOURCES.md](SOURCES.md) §4 and [FRICTIONAL.md](FRICTIONAL.md).

## Reviewer checklist

```bash
git clone <repo-url> && cd walker-jumpman-tharun-m
godot --path godot                                                      # play it
godot --headless --path godot --script res://tests/test_game.gd         # 25 / 0
godot --headless --path godot --script res://tests/test_keyboard.gd     #  9 / 0
godot --headless --path godot --script res://tests/test_extension.gd    # 22 / 0
git diff --stat 8c9085d HEAD -- godot/                                  # my diff vs the starter
```
