# TEST-REPORT — walker-jumpman-tharun-m

**Student:** Tharun Maheswararao · **Course:** CSYE 7270, Fall 2026
**Starter:** [nikbearbrown/walker-jumpman](https://github.com/nikbearbrown/walker-jumpman) @ `9387542`
**Engine:** Godot `4.7.2.stable.official.ed1daf0bf` — the exact build string the
starter records as its tested engine.
**Host:** macOS 15.6 (Darwin 24.6.0), Apple M4, OpenGL Compatibility renderer.
**Source revision under test:** `67eebe3` (see the revision table at the bottom).

> **What this document is and is not.** Everything below marked *machine* is a
> real run of the real engine whose raw output is committed under `evidence/`.
> Everything marked *human* is me at the keyboard. §7 records a human playtest
> that was actually performed on 2026-09-24; it overturned one of my
> predictions and found one defect, both written up rather than smoothed over.
> There is still no second playtester and none is claimed.

---

## 1. Baseline before I changed anything

Both starter suites were run against the **unmodified** starter before a single
edit, so that later results have something to be compared to.

| Suite | Command | Result |
| --- | --- | --- |
| Mechanics | `godot --headless --path godot --script res://tests/test_game.gd` | **25 checks / 0 failures** |
| Keyboard | `godot --headless --path godot --script res://tests/test_keyboard.gd` | **9 checks / 0 failures** |

Raw output preserved in `evidence/baseline/`. Baseline screenshots from the
starter (showing the starter's own character) are in
`evidence/baseline/screens/` and were not deleted or overwritten.

Two numbers from the baseline that mattered later:

* `fixed-jump-and-no-double` observed `rise_px = 56.0747`. The starter's own
  test asserts this is within 5 px of 53.3333, so a 5% discrepancy between the
  textbook jump height and the real one was sitting in the baseline output all
  along. I only noticed because I went looking for it.
* `complete-real-route` observed `ticks = 325`, final position `(912.88, 319.93)`.

## 2. Measuring the engine instead of trusting the formula

*machine* · `godot --headless --path godot --script res://tools/probe_jump.gd`
→ `evidence/jump-envelope.json`

Before placing any geometry I measured the actual jump arc of the shipped player
on a flat runway at full run speed.

```
rise   0.0 px -> centre travel  112.00 px, max gap  130.00 px
rise  24.0 px -> centre travel   96.00 px, max gap  114.00 px
rise  32.0 px -> centre travel   88.00 px, max gap  106.00 px
rise  48.0 px -> centre travel   74.67 px, max gap   92.67 px
rise  56.0 px -> centre travel   56.00 px, max gap   74.00 px
--- measured apex rise: 56.001 px (paper: 53.333)
--- airborne ticks: 42 (0.700 s)
--- steady run speed: 160.000 px/s
--- a jumping player's HEAD reaches 84.001 px above the floor
```

"Max gap" is edge-to-edge between two solids and accounts for the 18 px collider.
Every gap in section 03 is sized against this table. The largest is 72 px against
a 130 px budget; the tightest constraint in the level is the 48 px Terrace rise
against the 56 px apex, an 8 px margin.

**This also settles the design question in CHANGE-BRIEF §3.** A jumping player's
head reaches 84 px. For a platform to be walk-under-able by a *jumping* player
below, its underside must clear 84 px; a platform that high is itself 100 px up
and unreachable against a 56 px apex. Vertically stacked parallel routes are
therefore impossible in this engine without touching `tuning.gd`. The fork I
shipped works because the low road is **continuous ground that never requires a
jump**, so the headroom is never tested in normal play.

## 3. Startup and controls

| Check | Method | Result |
| --- | --- | --- |
| Project boots from `main.tscn` | *machine* — `godot --path godot`, 12 s | Clean boot, no errors or warnings on stdout |
| `walker-jumpman.command` launcher | *machine* — inspected; resolves `/Applications/Godot.app`, falls back to `godot` on PATH | Unmodified from the starter and still correct |
| Enter starts | *machine* — `test_keyboard.gd` `enter-start` | PASS |
| A/D and arrows move | *machine* — `keyboard-move`, `speed-cap`, `neutral-stop`, `simultaneous-directions` | PASS ×4 |
| Space jumps, no double jump | *machine* — `keyboard-jump`, `fixed-jump-and-no-double`, `held-jump-no-bounce` | PASS ×3 |
| Esc/P pause, Enter resume | *machine* — `escape-pause`, `enter-resume`, `pause-freezes`, `pause-main-menu` | PASS ×4 |
| Focus loss pauses | *machine* — `focus-loss-pauses` | PASS |
| R retries without counting a death | *machine* — `r-retry`, `manual-restart-not-death` | PASS ×2 |
| Coyote / buffer windows intact | *machine* — `coyote-5/6/7`, `buffer-5/6/7` | PASS ×6, inclusive at 6, expired at 7 |
| Controls unchanged | *machine* — `_setup_input()` diffed against baseline | No key added, removed or remapped |

**Nothing in the control scheme changed.** `test_keyboard.gd` is byte-identical
to the starter's and passes 9/9.

## 4. Character appearance

*machine* · `godot --path godot --script res://tools/capture_character.gd`
→ `evidence/screens/character-sheet.png`

The contact sheet renders SPROCKET in all four required states with the real
collider rectangle drawn over each one in magenta, read from the player's own
`COLLIDER_SIZE` / `COLLIDER_OFFSET` constants rather than re-typed.

| State | What the sheet shows |
| --- | --- |
| Standing, facing right | Both pistons level, key horizontal on the left (trailing) side |
| Running right | Pistons alternating, key prongs rotated, key still on the left |
| Running left | Pistons alternating, **key flipped to the right**, lens moved to the left |
| Airborne | Pistons retracted into a visible coil, foot pads splayed — unmistakably not the standing pose |

| Check | Result |
| --- | --- |
| Body art inside the collider | PASS — `body-art-within-collider`: topmost drawn pixel is `-27.5`, collider top is `-28.0` |
| Declared overhang | PASS — `key-overhang-small-and-declared`: **3.50 px**, derived from `KEY_HUB_X + KEY_ARM - COLLIDER_SIZE.x/2`, the same constants `_draw()` uses |
| Collider unchanged | PASS — `collider-unchanged`: 18×28 at offset (0, −14) |
| Tuning unchanged | PASS — `tuning-unchanged`: all eight values match the starter |

**The one honest visual/collision caveat.** The winding key extends 3.50 px past
the collider's side wall. This is deliberate and it is the only art outside the
box. It is always drawn on the **trailing** side (`back = -facing`), so it can
never be the part of the character that appears to touch a wall the player is
moving *toward*. The test asserts the overhang from the drawing's own constants,
so if I ever lengthened the key the check would fail rather than silently drift.
I am not claiming this is invisible — a player pressed against a right-hand wall
while facing right has a key poking 3.5 px into the wall behind them.

## 5. Extended route

*machine* · both roads driven by scripted input through the real physics. The
driver only writes the same `test_axis` / `test_jump_pressed` fields A/D/Space
write. It cannot teleport, re-tune, or disable a collision check.

| Route | Ticks | Clock | Deaths | Jump marks | Final position | Result |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| High road | 666 | 11.15 s | 0 | 11 | (1822.2, 227.9) | **COMPLETE** |
| Low road | 803 | 13.43 s | 0 | 11 | (1851.5, 271.9) | **COMPLETE** |

New landings that require a jump, all within the measured envelope:

| Landing | Gap | Budget at that rise | Margin |
| --- | ---: | ---: | ---: |
| The Junction | 64 px | 130 px | 66 px |
| Stone 1 (64 px wide, over a pit) | 72 px | 130 px | 58 px |
| Stone 2 (64 px wide, over a pit) | 72 px | 130 px | 58 px |
| The ground run | 64 px | 130 px | 66 px |
| The Terrace (high road, 48 px rise) | — | 56 px apex | 8 px |
| Post-spike landing (high road) | — | 130 px | comfortable |
| The buttress (low road, 36 px rise) | — | 56 px apex | 20 px |

The assignment asks for two new landings requiring jumps. There are seven.

| Check | Result |
| --- | --- |
| `finish-relocated-past-new-section` | PASS — flag moved 916 → **1824** |
| `level-widened` | PASS — 960 → **2080** |
| `new-landings-need-jumps` | PASS — every gap > 0, so none can be walked onto |
| `new-landings-within-measured-envelope` | PASS — max gap 72 px vs 130 px budget |
| `original-solids-unchanged` | PASS — all five starter solids byte-identical |
| `original-spike-unchanged` | PASS — `[320, 304, 24, 16]` |
| `original-spawn-unchanged` | PASS — `[64, 320]` |
| `terrace-rise-within-apex` | PASS — 48 px rise, 8 px margin |
| `low-road-headroom` | PASS — 8 px clearance under the Terrace |
| `low-road-is-slower-than-high-road` | PASS — **137 ticks / 2.28 s** |

**Is the fork a real decision?** The check above measures it rather than assuming
it. Horizontal speed in this engine is a constant 160 px/s airborne as well as
grounded, so route choice cannot be made faster by "moving quicker" — the only
thing that separates the two roads is distance travelled plus the braking needed
to land on a 56 px buttress. The safe road costs a measured 2.28 s. If a future
geometry change flattened that, the suite would fail instead of the claim
quietly becoming false.

## 6. Failure and recovery

| Check | Method | Result |
| --- | --- | --- |
| New spike bank kills | *machine* — `terrace-spikes-kill` | PASS, state DYING, deaths 1 |
| …and respawns at the original spawn | *machine* — `terrace-spikes-retry-respawns` | PASS, back at (64, 320) |
| Missing a new stone kills | *machine* — `new-pit-fall-retries` | PASS, fall past `fall_y` 430 → DYING |
| Original spike still kills | *machine* — `actual-spike-collision` | PASS |
| No phantom double death | *machine* — `duplicate-death-ignored` | PASS, deaths stays 1 |
| 20 consecutive retries | *machine* — `twenty-retries` | PASS, deaths 21, worst retry 34 ticks (≤ 60) |
| Death beats finish on the same tick | *machine* — `death-before-finish` | PASS |
| Replay after completion | *machine* — `replay-idempotent`, `enter-replay` | PASS, deaths and jumps reset to 0 |

Captured failure frames: `evidence/screens/21-terrace-spike-failure.png` (walked
into the raised spike bank on the Terrace) and
`evidence/screens/22-missed-landing-failure.png` (missed a stepping stone).
Both are real deaths produced by the game's own collision checks.

## 7. Human playtest — **PROTOCOL, NOT YET RUN**

> **This section is deliberately empty of results.** An automated input route is
> not a playtest and I will not write one up as if it were. The protocol below
> is what I will execute at the keyboard; results go in §7.2 and any defect it
> finds gets its own revision entry.

**7.1 Protocol.** Launch with `walker-jumpman.command` (or
`godot --path godot`). For each item, record what actually happened, not what
should have happened.

1. Enter to start. Play the original section to x ≈ 960 with no guidance.
2. Cross The Junction and both stepping stones. Note how many attempts.
3. At the fork, **without having read this document**, try the high road first.
   Record whether the painted chevron band actually reads as "jump here", and
   whether you bonk the Terrace underside on the first try.
4. Hop the Terrace spike bank. Record whether the spikes are legible against
   the walkway at normal speed.
5. Die on purpose twice — once on the spikes, once by missing a stone. Confirm
   the retry card, the 0.55 s pause and the respawn all feel right.
6. Replay the level and take the **low road**: run under the Terrace, climb the
   buttress, double back to the flag. Record whether the doubling back reads as
   intended design or as getting lost.
7. Pause with Esc mid-jump, resume with Enter, and confirm you do not get a
   free jump on resume.
8. Complete the level. Press Enter to play again.

**7.2 Results — executed 2026-09-24, revision `67eebe3`, by me (Tharun).**

Played with a real keyboard on the build in this repository. Two runs: one
taking the high road, one taking the low road.

| # | Step | What actually happened |
| --- | --- | --- |
| 1–2 | Original section, Junction, both stones | **Completed the level on the second attempt.** The one failed attempt was **"jumped too early"** — left the stone before building the distance. See §7.5: this is the *only* failure mode the geometry permits. |
| 3 | Painted chevron guide at the fork | **Seen, and it read correctly as "jump here."** |
| 3 | First attempt at the 48 px Terrace jump | **Did not bonk the underside.** Made it without a failed attempt. **This refutes the prediction in CHANGE-BRIEF failure case D.** |
| 4 | Terrace spike bank legibility | **Legible at normal running speed.** |
| 5 | Deliberate death | Died on purpose. **Did not press R — the game restarted on its own,** which was unexpected. See §7.4. |
| 6 | Low road: under the Terrace, buttress, double back | Completed. |
| 7 | Does doubling back read as a decision? | **"It felt like another choice"** — the fork's intent landed rather than reading as getting lost. |
| 8 | Pause mid-jump (Esc), resume (Enter) | **No free jump on resume.** The jump-release re-arm works against a human, not just against `pause-freezes`. |

**Two predictions overturned by playing it, both in the design's favour:**

* **Failure case D is refuted.** I predicted the 8 px margin on the Terrace jump
  would make first-timers bonk the underside before the guide taught the timing.
  It did not happen on the first attempt. I have left the original prediction
  unedited and added CHANGE-BRIEF revision R6. One player is one data point, not
  proof the jump is forgiving — but it is evidence, and it points the opposite
  way from what I wrote.
* **The fork reads as a decision to a human**, which no automated check can
  establish. `low-road-is-slower-than-high-road` proves the roads *differ*; only
  a person can say the difference feels like a choice.

**7.3 Second playtester.** *Still none. Not invented.*

**7.4 Defect found by the playtest, and what I changed**

The one thing that did not behave as the player expected. Dying auto-restarts
after 0.55 s, but the persistent HUD hint read **"R: retry"** — which implies R
is how you come back from a death. The playtester died deliberately, waited to
press R, and the game restarted without them.

The game was also inconsistent with itself: the pause card has always called the
same key **"R: restart attempt"**, while the HUD called it "retry".

**Changed** the HUD hint to **"R: restart"**, matching the pause card and
describing what the key actually does — restart the attempt on demand at any
time. **Behaviour is untouched**: no timing, no input mapping, no state change.
One UI string. Suites re-run after the change: 25/25, 9/9, 22/22.

This is the third revise cycle and the only one driven by a human at the
keyboard rather than by a test or a screenshot.

**7.5 The failed attempt was the only failure the geometry allows**

The playtester's single miss was *jumping too early*. That is not incidental.
At full run speed the furthest the player's centre can travel in one flat jump
is **112 px**, and for every stone jump the landing window reaches further than
that from the latest possible take-off:

| Jump | Furthest reachable centre | Landing window ends | Spare |
| --- | ---: | ---: | ---: |
| Junction → stone 1 | 1305 | 1329 | **24 px** |
| Stone 1 → stone 2 | 1441 | 1465 | **24 px** |
| Stone 2 → ground run | 1577 | 2089 | 512 px |

**A full-commitment jump always lands. Overshooting is impossible.** So the only
way to miss a stone is to leave early — which is exactly what happened. The
player is never punished for holding right, only for letting go of the timing.

That was a property of the layout I had not articulated until the playtest
produced the failure that demonstrates it. It is now asserted by
`stones-cannot-be-overshot`, so if the geometry ever moves and overshooting
becomes possible, the suite fails.

## 8. Camera and presentation

| Check | Method | Result |
| --- | --- | --- |
| Camera reaches the new finish | *machine* — clamp is `clampf(x + 100, 320, width - 320)`; with width 2080 the right limit is 1760, framing x 1440–2080 | Flag at 1824 and buttress at 1960 both on screen |
| Nothing important below the viewport | *machine* — camera y fixed at 180, viewport 360, so y 0–360 is visible; lowest gameplay element is the ground top at 320 | PASS — this is **why** the rejected sub-ground gallery design was dropped |
| Backdrop spans the level | *machine* — backdrop width now `level.width + 800` | PASS, see §9 before/after |
| Grid spans the level | *machine* — loops to `level.width` | PASS |
| Progress bar scales to the real finish | *machine* — `progress-bar-rescaled`: reads **0.484** at the old finish x, where the starter read 1.000 | PASS |
| Labels readable, not overlapped | *human, visual* — see §10 revise cycle | Fixed after inspection |

Presentation frames: `10-menu`, `11-original-section`, `12-junction-and-stones`,
`13-stone-hop`, `14-the-fork`, `15-terrace-and-raised-spikes`,
`16-finish-approach`, `17-complete`, `18-low-road-under-terrace`,
`19-climb-out-buttress`, `20-low-road-complete`, all in `evidence/screens/`.

## 9. The predicted drawing failures, and proof they were real

CHANGE-BRIEF §5 predicted A, B and C before any edit. Rather than assert I fixed
them, I rebuilt the project with the **starter's** `session.gd` and `hud.gd` and
**my** level data, and captured the result:

**`evidence/screens/bug-before-15-terrace-and-raised-spikes.png`** — one frame,
three confirmed predictions:

* **A** — the raised spike bank is painted on the **ground**, 64 px below the
  trigger SPROCKET is walking into on the Terrace. An invisible killer and a
  decorative fake, exactly as predicted. `_add_area()` honoured `entry[1]`;
  `_draw()` hard-coded `y = 320`.
* **B** — the backdrop and grid are absent through the whole new region. The
  backdrop was `Rect2(-400, -200, 1800, 900)`, covering x −400…1400.
* **C** — the progress bar is already full at x ≈ 1700 with the flag ahead,
  because `hud.gd` divided by a hard-coded `852`.
* **Not predicted:** the finish pole is *also* drawn from the hard-coded ground
  baseline, so it spears down through the Terrace instead of standing on it. I
  predicted the hazard baseline bug and missed the identical bug five lines
  below it in the same function.

**After:** `evidence/screens/15-terrace-and-raised-spikes.png`.

The fix makes `hazard_triangle()` the single definition of a spike's shape,
called by both the trigger builder and the renderer, and
`hazard-art-matches-trigger` asserts the trigger polygons really are rebuilt
from it. They can no longer drift apart.

## 10. Inspect-and-revise cycles

**Cycle 1 — found by a test, fixed by geometry.** The first low-road fixture
failed: the player stuck at `x = 1935`, still PLAYING after 2000 ticks, pinned
against the climb step. Diagnosis: the jump mark at 1900 was *under* the Terrace
(which then ran to 1904), so the jump bonked the 8 px headroom and fell back.
Working it backwards, the safe road's climb-out had an **8 px take-off window**,
about 0.05 s — an absurd demand on the route whose job is to be forgiving.

Fixed by moving geometry: Terrace shortened to end at 1880, climb-out replaced
with a 36 px buttress at 1960, widening the window to **39 px**. I did not
change `tuning.gd`, did not delete the assertion, and did not lower the tick
budget to hide it.

**Cycle 2 — found by looking, no crash involved.** Reading
`evidence/screens/14-the-fork.png` I saw the level never tells the player where
the high road starts. The measured take-off window is x 1580–1618, *before* the
Terrace begins at 1664, so the instinctive move — run up under the Terrace, then
jump — bonks. No assertion would have caught this; the fixture already knew the
right number. Added a painted chevron band on the ground at exactly that window,
driven from level data so the paint and the physics describe the same span, and
moved the road captions to their own elevations because the low-road caption was
being read straight through the character. Commit `b3b4d19`.

## 11. Automated checks — commands and results

Run from the repository root.

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path godot --script res://tests/test_game.gd
```
```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path godot --script res://tests/test_keyboard.gd
```
```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path godot --script res://tests/test_extension.gd
```

| Suite | Checks | Failures | Notes |
| --- | ---: | ---: | --- |
| `test_game.gd` (starter's) | 25 | **0** | One line changed — see below |
| `test_keyboard.gd` (starter's) | 9 | **0** | Byte-identical to the starter |
| `test_extension.gd` (mine) | 23 | **0** | New, additive |
| **Total** | **57** | **0** | |

### What changed in the supplied fixture, and why

**`tests/route_driver.gd` — extended.** The starter's driver held right and
jumped at five x thresholds, which is exactly right for a 960 px course and
cannot express the low road's doubling back. It now runs a short list of phases,
each with a direction, its own jump marks, and a handover threshold. **The
starter's five original marks `[138, 292, 424, 548, 712]` are preserved
unchanged as the first five marks of `HIGH_ROAD`.** The driver still has no way
to set position or velocity; a route that cannot make a jump falls and fails.

**`tests/test_game.gd` — one number.** The route tick budget went 900 → 1500.
The course is 2080 px instead of 960 px; at the unchanged 160 px/s that is 738
ticks of running before a single jump arc is counted, so 900 could not fit the
course at any skill level. **The assertion itself is unchanged** — still
`COMPLETE`, still zero deaths, still scripted input only. The route now reports
`ticks = 666`, comfortably inside the new budget.

**Nothing was deleted or weakened.** `evidence/predicted-failures/E-route-fixture-fails-before-update.txt`
is the real output of the suite run *after* the level change and *before* the
fixture change, showing `complete-real-route` FAIL with the player dead at
`(1017.06, 435.93)`. That failure is preserved rather than papered over.

### New checks added for the extension

`original-solids-unchanged`, `original-spike-unchanged`,
`original-spawn-unchanged`, `tuning-unchanged`, `collider-unchanged`,
`body-art-within-collider`, `key-overhang-small-and-declared`,
`finish-relocated-past-new-section`, `level-widened`, `new-landings-need-jumps`,
`new-landings-within-measured-envelope`, `terrace-rise-within-apex`,
`low-road-headroom`, `hazard-art-matches-trigger`, `new-hazard-is-raised`,
`terrace-spikes-kill`, `terrace-spikes-retry-respawns`, `new-pit-fall-retries`,
`progress-bar-rescaled`, `high-road-completes`, `low-road-completes`,
`low-road-is-slower-than-high-road`, `stones-cannot-be-overshot`.

## 12. Known limitations and things I am not sure about

1. **Only one playtester, and it was me.** §7 records a real playtest, but a
   single run by the person who designed the level is the weakest possible
   sample. I already knew where the take-off window was — which is exactly the
   bias that makes my "did not bonk the Terrace" result worth less than it
   looks. A player who has not seen the geometry is what this needs.
2. **The Terrace jump has 8 px of margin** on a 56 px apex. I predicted a
   first-timer would bonk the underside before the chevron band taught the
   timing; my own playtest did not (§7.2), and CHANGE-BRIEF R6 records that as
   a refuted prediction. I am **not** upgrading that into "the jump is
   forgiving" — one biased data point does not support the claim.
3. **The winding key overhangs the collider by 3.50 px** on the trailing side
   (§4). Measured and declared, not hidden.
4. **The low road's 8 px headroom is real.** A player who jumps while under the
   Terrace bonks and stops rising. It is survivable and the starter's own
   `low-ceiling` check covers the mechanism, but it will feel odd the first
   time it happens.
5. **The fork is a decision, not a branch in the level graph.** Both roads cross
   the same x-range and reconverge at the flag. CHANGE-BRIEF §3 sets out, with
   the measured numbers, why genuinely parallel stacked lanes are impossible in
   this engine without re-tuning the jump — which the assignment forbids.
6. **Guides and labels are data but not validated against physics.** The chevron
   band is placed at the measured take-off window by hand. If the geometry moved
   and I forgot to move the band, no test would currently notice. The hazard and
   finish marker no longer have this problem; the guide band still does.
7. **`test_extension.gd`'s `_hazard_size()` matches a hazard by its position.**
   Two hazards at the identical position would confuse it. Not currently possible
   in this level, but it is a latent weakness in the test, not in the game.
8. **One suite is slow.** `test_extension.gd` drives two full routes and takes
   roughly 40 s headless.

## 13. Revision table

| Revision | What it is |
| --- | --- |
| `9387542` | Instructor's starter, upstream |
| `8c9085d` | That starter imported here unmodified, as the baseline commit |
| `76f2938` | SPROCKET character |
| `394bd91` | Section 03 The Fork, data-driven drawing, route fixture |
| `b3b4d19` | Launch guide and label revision |
| `e138323` | Stale comment corrected |
| `67eebe3` | Playtest: R relabelled, prediction D refuted — **the final game-source revision, and the one this report describes** |
