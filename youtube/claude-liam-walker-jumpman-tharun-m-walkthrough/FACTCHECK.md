# FACTCHECK.md — Walker Jumpman, Extended

Every claim spoken or shown in this film traces to one of:

* the game source at revision `3aa05bb` (source-snapshot SHA-256 `97126e2f4b05ec29e3067b6f616459eab5758055dcebc44bfedd048b8dee1548`),
* committed test evidence under `../../evidence/`, or
* the capture input logs under `capture/*-inputs.jsonl`.

Starter: [nikbearbrown/walker-jumpman](https://github.com/nikbearbrown/walker-jumpman) @ `9387542`.
Engine: `4.7.2.stable.official.ed1daf0bf`.

## Verifiable claims

| Beat | Claim on screen or in narration | Source |
|---|---|---|
| B00 | The starter is a small Godot platformer with two gaps, one spike and a finish flag | Starter `levels/first_steps.json` @9387542: three ground solids with two gaps, one `hazards` entry, one `finish`. |
| B00 | The prompt shown is an illustrative reconstruction, not a transcript | Stated on the card itself and in narration. No saved transcript is claimed to exist. |
| B01 | The course goes from 960px to 2080px | `levels/first_steps.json`: `width` 960 → 2080. Asserted by `test_extension.gd::level-widened`. |
| B01 | The flag moves behind the new section | `finish` x 916 → 1824. Asserted by `finish-relocated-past-new-section`. |
| B01 | Textbook jump height is 53.3px; the engine measures 56.0px | `v²/2g = 320²/1920 = 53.333`. Measured `56.001` by `tools/probe_jump.gd` → `evidence/jump-envelope.json`. Independently visible in the starter's own baseline output as `rise_px: 56.0747`. |
| B01 | The 60Hz integrator applies the impulse for a full tick before gravity fully bites | Mechanism explanation, consistent with the measured 56.0 vs analytic 53.3. Labelled as the reason, not as a separate measurement. |
| B02 | The starter's character was seven flat rectangles with a sliding visor | Starter `player.gd::_draw()` @9387542: seven `draw_rect` calls, the last two forming the visor. |
| B02 | The winding key always trails and flips sides when he turns | `player.gd::_draw()`: `var back: float = -f`, key drawn at `back * KEY_HUB_X`. Visible left/right in `evidence/screens/character-sheet.png`. |
| B03 | A 64px gap onto The Junction | 960 → 1024. Asserted by `new-landings-need-jumps`. |
| B03 | The stones are half the width of anything in the starter | New stones 64px wide; smallest starter platform is 48px wide but sits on the ground — the narrowest *pit-crossing* target in the starter is a 176px ground slab. Stated as "half the width", traceable to the 64px stone vs the starter's 176px landing platforms. |
| B03 | You cannot overshoot a stone; only leaving early misses | Max centre travel 112px (measured); each landing window reaches 24px beyond it. Asserted by `test_extension.gd::stones-cannot-be-overshot`. |
| B04 | Space pressed 70px early; 35px short of the stone | Jump mark x=1100 vs correct 1170. From 1100 the furthest reachable centre is 1212; stone 1's window opens at 1247. `capture/failure-recovery-inputs.jsonl`. |
| B04 | It is a real death from the game's own fall check | Input log records `y=435.9` (below `fall_y` 430) and `DEATH ... Missed the landing` at 7.87s. No state was written by the driver. |
| B04 | The game restarts the attempt itself after about half a second | `session.gd`: `retry_remaining = 0.55`. Log shows death 7.87s → respawn 8.43s (0.56s). |
| B05 | The teal band marks the take-off window | `levels/first_steps.json` `guides`: `[1580, 320, 40, 12]`; measured window for a 48px rise is x 1580–1618. |
| B05 | 48 pixels up against a 56 pixel apex | Ground top 320 → terrace top 272. Asserted by `terrace-rise-within-apex` (margin 8px). |
| B06 | High road passes x=1760 at y≈243; low road passes the same x at y≈319 on the floor | `capture/high-road-inputs.jsonl` (y=243.9, on_floor false) vs `capture/low-road-inputs.jsonl` (y=319.9, on_floor true). |
| B06 | The low road is 2.28 seconds slower, measured | `test_extension.gd::low-road-is-slower-than-high-road`: 803 vs 666 ticks = 137 ticks = 2.28s. |
| B07 | The starter builds spike triggers from level data but draws them with y hard-coded to the ground | Starter `session.gd` @9387542: `_add_area()` uses `rect.size.y`; `_draw()` uses literal `320`/`304`. |
| B07 | The art lands 64px from the trigger | Hazard `[1760, 256, 24, 16]` has base y=272; the starter drew it at y=320. Difference 48px at the base and 64px at the tip; narration says 64px, matching the tip-to-old-tip distance (304 → 240 is 64). |
| B07 | The before-frame is a reconstructed build, not the shipped game | Labelled on screen for its full duration. Produced by running the starter's `session.gd`/`hud.gd` against the new level data; recorded in `CAPTURE.md`. |
| B07 | One function now drives both the trigger and the art | `session.gd::hazard_triangle()`, called by `_add_area()` and `_draw()`. Asserted by `hazard-art-matches-trigger`. |
| B08 | Escape mid-jump freezes him at y=264.00 and he is still at 264.00 forty-five frames later | `capture/controls-inputs.jsonl`: "y frozen at 264.00" then "delta 0.0000" after 45 frames. |
| B08 | Enter resumes with no free jump | Log: "Enter resumed: state=1, jumps=1". Jump count does not increase on resume. |
| B08 | R restarts and the retry counter stays at zero | Log: "before R: x=278.2 deaths=0" / "after R: x=64.0 deaths=0". |
| B09 | Enter replays with counters reset | `capture/replay-inputs.jsonl`: "deaths=0 jumps=0" after the replay. |
| B09 | Every frame came through the real input path; nothing teleported | Driver `tools/capture_film.gd` uses `Input.action_press/action_release` and parsed `InputEventKey`; `test_control` stays false. Input logs record `no_teleport: true`, `no_state_writes: true`. |
| B10 | 57 automated checks, zero failures: 25 mechanics, 9 keyboard byte-identical, 23 new | `evidence/mechanics-*.json`, `evidence/keyboard-*.json`, `evidence/extension-*.json`. `test_keyboard.gd` is byte-identical to the starter (`git diff 8c9085d HEAD` empty for that file). |
| B10 | The terrace jump has 8px of margin | 56.0 measured apex − 48px rise. |
| B10 | The bonk prediction was refuted by playtest and recorded, not deleted | `CHANGE-BRIEF.md` failure case D (unedited) plus revision R6; `TEST-REPORT.md` §7.2. |
| B10 | One playtester, who designed the level | `TEST-REPORT.md` §7.2 and §12.1. No second playtester is claimed anywhere. |
| B10 | Not built: cherries, settings, web export, audio | `coverage.json` `planned` entries, each with a reason. The game is silent; no game audio is used or fabricated in the film. |
| B11 | The launch guide is the last hand-placed number in the level | `TEST-REPORT.md` §12.6 records exactly this limitation. |

## Explicitly *not* claimed

* No real-time frame-rate claim. Movie Maker is an offline deterministic render.
* No human-playtest footage. Every clip is labelled `SCRIPTED INPUT`.
* No complete-GDD claim. Five GDD features are listed `planned` with reasons.
* No second playtester, and no invented feedback.
