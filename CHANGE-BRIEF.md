# CHANGE-BRIEF — walker-jumpman-tharun-m

**Author:** Tharun Maheswararao (maheswararao.t@northeastern.edu)
**Course:** CSYE 7270 · Fall 2026 · Assignment 1 — Extend Walker Jumpman
**Starter:** [nikbearbrown/walker-jumpman](https://github.com/nikbearbrown/walker-jumpman) @ `9387542`, Godot 4.7.2
**Written:** 2026-09-24, *before* any source edit. Baseline starter is commit `8c9085d` in this repo.

> **Status of this document.** This is the prediction record. Everything below the
> line "END OF ORIGINAL PREDICTIONS" was written before I changed a single file.
> Where a prediction turned out to be wrong, I did **not** edit it — I added a
> dated revision in the "Revisions" section at the bottom and in TEST-REPORT.md.

---

## 1. What I read first

Before predicting anything I read the starter's `README.md`, `BUILD-REPORT.md`,
`LEVEL-DESIGN.md`, and these five source files, which are the ones the change
actually touches:

| File | What it owns |
| --- | --- |
| `godot/features/player/player.gd` | Character physics **and** the entire character appearance, drawn in `_draw()` with `draw_rect` primitives. No sprite sheet. |
| `godot/features/player/tuning.gd` | The eight movement constants. **Must not change.** |
| `godot/levels/first_steps.json` | Level data: `width`, `fall_y`, `spawn`, `solids`, `hazards`, `finish`. |
| `godot/game/session.gd` | Reads the JSON, builds collision bodies from it, **and separately draws the world in `_draw()`**. |
| `godot/ui/hud.gd` | Overlay, menu/pause/complete cards, progress bar. |

The single most important thing I found: **`session.gd` builds physics from the
JSON but draws the world from partly hard-coded numbers.** `_add_area()` honours
`entry[1]`/`entry[3]` for hazard position and height, but `_draw()` throws them
away and draws every spike at `y = 320..304` and every finish pole from
`y = 320` to `y = 250`. The background, grid, and hills are hard-coded to a
960-wide level. So moving level data alone will *not* move the picture. This is
the trap the assignment warns about, and it drives most of my predicted failures.

## 2. The character concept

### SPROCKET — a wind-up tin automaton

The starter's character is a flat stack of rectangles: a dark 18×24 slab, a blue
inner slab, an orange belt, two leg blocks, and a cream visor that slides left or
right. Its silhouette is a plain rectangle in every state.

SPROCKET replaces that with a **clockwork tin toy**:

| Feature | Why it is a real identity change, not a recolour |
| --- | --- |
| **Octagonal brass barrel torso** | The straight-edged rectangle becomes a chamfered barrel. The corner cuts change the actual outline, so the silhouette differs even as a black shape. |
| **Domed, narrower head with a single round lens** | Breaks the starter's one-width-all-the-way-down profile into a head-and-shoulders shape. The lens is a circle — the starter has no curves at all. |
| **A brass winding key on the back** | The strongest feature. The key sits on the **trailing** side and flips sides when SPROCKET turns, so facing is readable from the silhouette alone rather than from the position of a light-coloured visor. Its prongs **rotate** while running and **stop** in the air, so "am I wound up / am I grounded" is visible. |
| **Piston legs that retract in the air** | Grounded: two pistons alternate as a stride. Airborne: both retract into the housing and the feet tuck. The airborne pose is distinguishable from the standing pose at a glance, which the starter's is not. |
| **Rivet seam and a wind-up ratchet plate** | Surface detail that reads as stamped tin rather than flat colour fields. |

**Palette** (all new, none shared with the starter's blue/orange scheme):
brass `#c0873c`, deep brass shadow `#8a5f27`, tin highlight `#ecc684`,
casing ink `#2b2118`, lens teal `#3fa392`, lens glint `#d9f2ec`.

**Prediction about the collider.** I will **not** change the collider
(`Vector2(18, 28)` at offset `(0, -14)`, i.e. x ∈ [−9, 9], y ∈ [−28, 0] with
`position` at the feet) and I will **not** change any value in `tuning.gd`.
I predict I can fit the whole body inside that box. The one part I expect to
push outside it is the **winding key**, by about 4 px behind the back. I am
allowing that deliberately because it always trails the direction of travel, so
it can never be the thing that visually "should" have hit a wall the player is
moving toward. I will measure the actual overhang and report it rather than
assert it.

## 3. The new section of level

### "03 / THE FORK" — extends the level from x = 960 to x = 1968

The starter is 960 wide: two gaps, one spike, a flag at x = 916. The extension
roughly doubles it and moves the flag to x = 1768.

**Shape of the new section, left to right:**

1. **The Junction** (`[1024, 320, 160, 64]`) — reached by a 64 px gap jump from
   the starter's last platform. Same gap width as the starter's first gap, so the
   section opens on something the player has already proved they can do.
2. **The Drop** — three pits with two **narrow 64 px stepping stones**
   (`[1256, 320, 64, 16]`, `[1392, 320, 64, 16]`) floating over them. The stones
   are half the width of anything in the starter and a miss is a real fall death.
   These are the section's precision beat.
3. **The Fork** — the player lands on a long ground run (`[1520, 320, 448, 64]`)
   and can see a **thin elevated terrace** (`[1592, 272, 264, 16]`) overhead with
   the flag on it. Two ways to the flag:

   * **HIGH ROAD** — jump straight up onto the terrace. This is a **48 px rise
     against a 53.3 px ceiling**, the hardest jump in the whole game, and the
     terrace carries a **spike bank** (`[1680, 256, 24, 16]`) that must be hopped
     before the flag. Direct, but two ways to die.
   * **LOW ROAD** — ignore the terrace and keep running right along the ground,
     **underneath** it. No spikes, no pit, nothing to miss. But the only place to
     climb up is past the terrace's right end, so the player **overshoots the
     flag by about 110 px and has to double back left** to reach it.

   The decision is *exposure versus distance*, and it is signposted in-world.

4. **The flag** moves to `[1768, 216, 24, 56]`, standing on the terrace. It is
   unreachable without completing the new section by one road or the other.

**New landings that require a jump:** the Junction, stone 1, stone 2, the ground
run, the terrace (high road), the post-spike landing (high road), and the
climb-back-up (low road). The assignment asks for two; the section has six.

**The original route is untouched.** Every original solid, the original spike,
and the original spawn keep their exact coordinates. Only the finish moves.

### Why a *vertically stacked* two-lane fork is NOT what I am building

My first design was two parallel lanes over the same pit — a high rail and a low
stone path — and I worked out on paper that this engine cannot support it:

* A jump is a **fixed** 53.3 px rise (`v²/2g = 320²/1920`). The body is 28 px
  tall. So a jumping player's head reaches **81.3 px** above the ground.
* For a platform to be walkable-under without head-bonking a jumper below, its
  underside must sit above 81.3 px, i.e. its top must be at **y ≤ 223**.
* But a platform at y = 223 is **97 px above the ground**, and the maximum rise
  is 53.3 px, so it is unreachable.
* Therefore **any platform you can jump onto is also a platform you will bonk
  your head on**, and two stacked lanes over the same ground are impossible
  without touching `tuning.gd` — which the assignment forbids.

I also checked stacking *downward* — a safe gallery below ground level — and the
**viewport** kills it: the camera is fixed at `y = 180` on a 360-tall viewport,
so anything below `y = 360` is off-screen, and the clearance arithmetic forces a
sub-ground shelf to `y ≥ 364`.

The fork I *am* building threads this needle: the low road is **continuous ground
that never requires a jump**, so the 4 px of headroom under the terrace is never
tested by a jumping player in normal play, and the terrace at y = 272 is a 48 px
rise — inside the 53.3 px budget with 5.3 px to spare.

**I predict that 5.3 px of margin is the riskiest number in this design** and
that the terrace jump will be the thing most likely to feel bad. See failure
case D.

## 4. What must remain unchanged

| Thing | Commitment |
| --- | --- |
| **Controls** | A/D + arrows move, Space jump, R retry, Esc/P pause, Enter confirm, M menu. No new keys, no remapping. |
| **Movement / jump tuning** | All eight values in `tuning.gd` stay exactly as they are: speed 160, accel 1280, decel 1920, jump −320, gravity 960, terminal 480, coyote 6, buffer 6. |
| **Collider** | `RectangleShape2D` 18×28 at offset `(0, −14)`. Unchanged. |
| **Collision behaviour** | Layers/masks unchanged (player 2, world 1, hazard 8, goal 16). Exact triangular spike triggers kept. No collision check removed or weakened. |
| **Retry** | Unlimited retries, 0.55 s death pause, respawn at the original spawn, manual R does not count as a death, the `contact_settle_ticks` phantom-death guard stays. |
| **Pause** | Esc/P toggles, focus-loss pauses, Enter resumes, jump-release requirement re-armed on resume. |
| **Completion** | Goal is an `Area2D` overlap, Enter replays, replay resets deaths and jumps. |
| **Original geometry** | Every original solid, the original spike, and the spawn keep their coordinates. |

**Changes I expect to need, and why they are not tuning changes:**

* `session.gd::_draw()` must become data-driven for hazards and the finish
  marker, and the background/grid/hills must span `level.width`. This changes
  **what is drawn**, never what is simulated — in fact it makes the drawing agree
  with the simulation, which it currently does not.
* `hud.gd`'s progress bar divides by a hard-coded `852`. That must come from the
  level data or the bar will be wrong.
* `tests/route_driver.gd` is authored for the old layout and **must** be extended;
  its fixture change is documented in TEST-REPORT.md.
* The menu blurb "Cross two gaps. Clear the spikes. Reach the flag." no longer
  describes the level and should be updated.

## 5. Predicted failure cases

Five, with the check for each. I expect at least A, B, and C to actually happen.

### A. The new spikes will be drawn at ground level instead of on the terrace
`session.gd::_draw()` hard-codes `Vector2(x, 320)` and `Vector2(x + 4, 304)` for
every hazard and ignores `entry[1]`/`entry[3]`. My new spike bank is at
`y = 256..272` on the terrace, but `_add_area()` *will* put its trigger there.
**Prediction: the trigger will be on the terrace and the drawing will be on the
ground, 64 px apart — an invisible killer plus a fake decoration.**
**Check:** run the game, stand on the terrace, screenshot; and assert in a test
that the drawn spike y and the `Area2D`'s global y agree.

### B. The new section will render on bare background with no grid or hills
The backdrop is `Rect2(-400, -200, 1800, 900)` (covers x −400..1400), the grid
loops `range(0, 961, 32)`, and the hills are at hard-coded x `[100, 470, 770]`.
The level now runs to 1968.
**Prediction: from roughly x = 1400 the world loses its backdrop and shows the
window clear colour; the grid stops at 960.**
**Check:** screenshot at the junction and at the flag.

### C. The HUD progress bar will hit 100% less than halfway through
`hud.gd` computes `(player.position.x - 64) / 852`, where 852 = old finish 916 −
spawn 64. The new finish is at 1768.
**Prediction: the bar saturates at x = 916, about 45% of the way to the flag.**
**Check:** read the bar at the junction (x ≈ 1100); it should be visibly full and
wrong.

### D. The 48 px terrace jump may be unreliable, and the 4 px headroom may catch
The terrace jump uses 48 of the 53.3 px budget. The low road runs under a
terrace whose underside is 288 while a standing player's head is at 292 — 4 px.
**Prediction (uncertain): the terrace jump works but feels tight; the 4 px
headroom does not catch a *running* player, but any jump under the terrace will
bonk. I am less sure about the headroom than about A–C.**
**Check:** a scripted low-road run that holds right from x = 1520 to x = 1960 and
asserts the player never enters `DYING` and actually arrives; plus a human
playtest of the terrace jump, plus a deliberate jump-under-the-terrace test.

### E. The existing `complete-real-route` regression test will fail
`tests/route_driver.gd` jumps at x `[138, 292, 424, 548, 712]` and `test_game.gd`
gives the route a 900-tick budget. The level is now 1968 px; at 160 px/s that is
738 ticks of pure running before any jump arcs.
**Prediction: the route runs off the end of its marks, fails to reach the new
flag, and `complete-real-route` fails on both the state check and the budget.**
**Check:** run `test_game.gd` headless *after* changing the level but *before*
touching the fixture, and paste the real failure output into TEST-REPORT.md.
I will then extend the fixture rather than relax the assertion.

## 6. How I will verify

1. Run both existing headless suites on the **unmodified** starter first to get a
   baseline. Preserve that output.
2. Make one bounded change at a time, re-running the suites after each.
3. Add a **new** regression suite for the extension: geometry reachability, the
   draw/collision agreement from failure case A, both road fixtures, and the
   relocated finish.
4. Extend `route_driver.gd` for the high road and add a second fixture for the
   low road, then compare their tick counts to test whether the fork's trade-off
   is real.
5. Play it myself with the actual keyboard and write down what actually happened,
   including anything that felt bad.

**A prediction I want on the record because I think it may be wrong:** I expect
the high road and the low road to differ in completion time by roughly a second.
But horizontal speed in this engine is a constant 160 px/s *whether or not the
player is airborne*, so route "speed" may depend only on horizontal distance and
the low road's backtrack. If the two routes come out nearly equal, my framing of
the trade-off is wrong and I will say so rather than quietly rewording it.

---

**END OF ORIGINAL PREDICTIONS** — everything above this line is unedited.

---

## Revisions

*Dated entries added after implementation and testing. Nothing above is rewritten.*

<!-- Revision entries are appended here as they occur. -->
