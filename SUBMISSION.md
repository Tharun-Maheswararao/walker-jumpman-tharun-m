# SUBMISSION — Assignment 1

**Assignment:** Assignment 1 - Extend Walker Jumpman
**Student:** Tharun Maheswararao (`maheswararao.t@northeastern.edu`)
**Project name:** `walker-jumpman-tharun-m`

---

## Identification

| Field | Value |
| --- | --- |
| **GitHub repository/folder URL** | <https://github.com/Tharun-Maheswararao/walker-jumpman-tharun-m> |
| **Submitted commit SHA** | See the Canvas note. A commit's own SHA cannot be written inside itself; the Canvas note carries the final one. |
| **Game-source revision to be shown in the film** | `5bdd71e` — *Correct a stale course width in the route-budget comment*. This is the **final game-source revision**; every commit after it is documentation only and must not touch `godot/`. |
| **Godot version** | `4.7.2.stable.official.ed1daf0bf` |
| **Operating system** | macOS 15.6 (Darwin 24.6.0), Apple M4 |
| **Final film URL** | <https://drive.google.com/file/d/1zdl23QL100QzlWFBuYtc76-CeBIeO9Gm/view?usp=sharing> (Google Drive) |
| **Final film filename** | `claude-liam-walker-jumpman-tharun-m-walkthrough.mp4` |
| **Final film SHA-256** | `3a91091eefa6065949d43d4b310944b48431f01cdac1813d4855a4432e97a8a5` |

**Revision relationship.** The film demonstrates game source `5bdd71e`. Any
commits after it add film documentation only and **do not change the
demonstrated game source**. Verify with:

```bash
git diff --stat 5bdd71e <submitted-sha> -- godot/
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

**Verification.** 57 automated checks, 0 failures — the starter's 25 mechanics
checks, its 9 keyboard checks byte-identical, and 23 new extension checks.
Level geometry is designed against a **measured** jump envelope
(`tools/probe_jump.gd`: real apex 56.0 px, not the textbook 53.3 px), not
against arithmetic.

## Known limitations

1. **Only one playtester, and it was the author.** TEST-REPORT §7 records a
   real keyboard playtest which refuted one prediction and found one defect
   (the "R: retry" label). A single run by the level's designer is still the
   weakest possible sample.
2. **No second playtester** is claimed.
3. **The film shows revision `3aa05bb`**, which is the final game-source
   revision. Later commits are documentation only.
4. **The terrace jump has 8 px of margin** against a 56 px apex. I predicted a
   first-timer would bonk the underside; the playtest refuted that
   (CHANGE-BRIEF R6). One biased data point, not proof the jump is forgiving.
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

**Rendered.** `godot-waikthrough` (walker modifier) from the course-provided
[nikbearbrown/brutalist.art](https://github.com/nikbearbrown/brutalist.art).

| Field | Value |
| --- | --- |
| Path | `youtube/claude-liam-walker-jumpman-tharun-m-walkthrough/exports/landscape/claude-liam-walker-jumpman-tharun-m-walkthrough.mp4` |
| Duration | 4:10 (250.1 s) · 13 beats |
| Format | 3840×2160 H.264, 30 fps, AAC 48 kHz stereo, mean −27.0 dB |
| SHA-256 | `3a91091eefa6065949d43d4b310944b48431f01cdac1813d4855a4432e97a8a5` |
| Narration | Liam, local Kokoro `am_onyx` (free, no key) |
| Game-source revision shown | `3aa05bb` |

Structure is walker mode: B00 ClaudeComposerAsk (labelled a reconstruction,
not a transcript) → B01 what was built → gameplay body → **Verdict** → **Your
Turn** → regular outro under OUTRO-LOCK.

**Gates:** GATE T typography 0 failures · GATE V visual QC 0 blockers, 0 majors
· `verify_walkthrough.py` PASS with 20 implemented features, 20 evidence
intervals, every capture natively 3840×2160.

All gameplay is real engine output captured through the real `Input` path — no
teleports, no state writes, no disabled collision checks. Scripted-input
captures, held frames and the one deliberately reconstructed before-frame are
each labelled on screen. The game is silent; no game audio was fabricated.

**The MP4 is excluded from git by size.** It is hosted at:

<https://drive.google.com/file/d/1zdl23QL100QzlWFBuYtc76-CeBIeO9Gm/view?usp=sharing>

Interim location pending confirmation of the course's designated media
storage.

Verify the checksum with:

```bash
shasum -a 256 youtube/claude-liam-walker-jumpman-tharun-m-walkthrough/exports/landscape/claude-liam-walker-jumpman-tharun-m-walkthrough.mp4
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
git clone https://github.com/Tharun-Maheswararao/walker-jumpman-tharun-m.git && cd walker-jumpman-tharun-m
godot --path godot                                                      # play it
godot --headless --path godot --script res://tests/test_game.gd         # 25 / 0
godot --headless --path godot --script res://tests/test_keyboard.gd     #  9 / 0
godot --headless --path godot --script res://tests/test_extension.gd    # 22 / 0
git diff --stat 8c9085d HEAD -- godot/                                  # my diff vs the starter
```
