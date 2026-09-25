# SOURCES — walker-jumpman-tharun-m

**Student:** Tharun Maheswararao · CSYE 7270, Fall 2026 · Assignment 1

## 1. The starter

| Item | Detail |
| --- | --- |
| Project | **walker-jumpman — First Steps** |
| Author | Nik Bear Brown (course instructor) |
| Source | <https://github.com/nikbearbrown/walker-jumpman> |
| Commit used | `9387542ca473b0a252c43bfe6d4fd39b61f8d439` |
| Engine | Godot 4.7.2 / GDScript |

**This project is an extension of that starter, not a new game.** The starter
was cloned and committed here **unmodified** as commit `8c9085d` before any
edit, so every subsequent commit is a reviewable diff against the instructor's
original. I did not work in the instructor's repository.

### What is the starter's, unchanged

* The whole engine/physics model: `tuning.gd` (all eight values), the
  `CharacterBody2D` controller, coyote and jump-buffer windows, `move_and_slide`
  handling, the left-wall clamp.
* Session state machine, retry timing, the `contact_settle_ticks`
  phantom-death guard, pause/focus handling, input map.
* The original course geometry: all five original solids, the original spike at
  `[320, 304, 24, 16]`, and the spawn at `[64, 320]` — asserted unchanged by
  `test_extension.gd`.
* `tests/test_keyboard.gd` — byte-identical.
* `tests/test_game.gd` — one number changed (route tick budget 900 → 1500);
  no assertion altered. Documented in TEST-REPORT §11.
* `tests/capture_game.gd`, `walker-jumpman.command`, `.gitignore`,
  `scripts/record-build.cjs`, and the starter's design package
  (`GDD.md`, `GAME-BRIEF.md`, `LEVEL-DESIGN.md`, `PRODUCTION-PLAN.md`,
  `PLAYTEST-PLAN.md`, `ASSET-PLAN.md`, `DESIGN-REVIEW.md`,
  `DESIGN-STATUS.json`, `BUILD-REPORT.md`, `design/`).
* The starter's own test evidence and screenshots, preserved in
  `evidence/baseline/`.

### What is mine (added or modified)

| File | Change |
| --- | --- |
| `godot/features/player/player.gd` | `_draw()` rewritten — the SPROCKET character. Collider constants extracted; physics untouched. |
| `godot/levels/first_steps.json` | Section 03 "The Fork"; flag relocated 916 → 1824; width 960 → 2080; new `hills`, `labels`, `guides` data. |
| `godot/game/session.gd` | `hazard_triangle()` added as the single spike-geometry definition; `_draw()` made data-driven. |
| `godot/ui/hud.gd` | Progress bar and title read from level data instead of hard-coded constants. |
| `godot/tests/route_driver.gd` | Extended to phases; the starter's five original marks preserved. |
| `godot/tests/test_extension.gd` | **New** — 22-check suite. |
| `godot/tools/probe_jump.gd` | **New** — measures the real jump envelope. |
| `godot/tools/capture_character.gd` | **New** — character contact sheet with collider overlay. |
| `godot/tools/capture_shots.gd` | **New** — captures the real game along the real routes. |
| `CHANGE-BRIEF.md`, `TEST-REPORT.md`, `FRICTIONAL.md`, `SOURCES.md`, `README.md`, `SUBMISSION.md`, `film/` | **New** |

## 2. Assets

**There are no imported assets of any kind.** No sprite sheets, no fonts, no
audio, no textures, no purchased or AI-generated art.

Every visual in this project is original vector drawing executed at runtime by
Godot's `draw_rect`, `draw_circle`, `draw_line`, `draw_colored_polygon` and
`draw_string` calls, in the same style as the starter. This matches the
starter's own provenance boundary in `ASSET-PLAN.md`.

* **SPROCKET** — drawn entirely in `player.gd::_draw()` from primitives.
  Original design; the palette (brass `#c0873c`, shadow `#8a5f27`, highlight
  `#ecc684`, casing `#2b2118`, lens `#3fa392`, glint `#d9f2ec`) was chosen by me
  to share no colour with the starter's blue/orange scheme.
* **Section 03 geometry and signage** — data in `first_steps.json`, rendered by
  the starter's existing drawing idiom.
* **Text** — Godot's `ThemeDB.fallback_font`, as the starter uses. No font file
  is shipped or required.

No paid service, no API credits, and no asset-generation service were used.

## 3. Tools

| Tool | Version | Used for |
| --- | --- | --- |
| Godot Engine | `4.7.2.stable.official.ed1daf0bf` | Running, testing and capturing the game |
| Homebrew | 7.0.2 | Installing Godot |
| Git | Apple git (macOS 15.6) | Version control |
| Python 3.13.7 | stdlib only | Small text edits to source files during the session |
| Claude Code (Opus 5) | Sept 2026 | See §4 |

Host: macOS 15.6 (Darwin 24.6.0), Apple M4.

## 4. AI contribution, stated plainly

AI assistance is expected in this course and I am stating the extent of it
rather than minimising it. A fuller account with specifics is in FRICTIONAL.md.

### What the AI (Claude Code, Opus 5) actually did

* Located and cloned the starter; installed and verified the engine.
* Read the starter and identified the hard-coded drawing coordinates that the
  assignment warns about.
* **Wrote effectively all of the GDScript in this project**: the SPROCKET
  `_draw()`, the `session.gd` and `hud.gd` changes, `hazard_triangle()`, the
  extended `route_driver.gd`, all of `test_extension.gd`, and all three tools in
  `godot/tools/`.
* Chose the concrete level coordinates, verified them against the measured jump
  envelope, and iterated when the low road failed.
* Ran every test and capture, and produced the before/after bug evidence.
* Wrote the first draft of every document in this repository, including this
  sentence.
* Drafted the film beat sheet and narration script.

### What the human (Tharun) did

* Set the goal and scope, and required that the work be original rather than
  matching other students' published extensions.
* **Chose the character concept** (the wind-up tin automaton) from options the
  AI proposed.
* Authorised the Godot installation.
* **Decided the film approach** — follow the assignment's instruction to request
  the course-provided Brutalist skill rather than substitute a public
  repository that might differ from it.
* Owns the submission and is accountable for being able to explain it.

### What is explicitly still outstanding

* **The human playtest was performed by the human**, not the AI: played at a
  keyboard on 2026-09-24, recorded in TEST-REPORT §7.2. It refuted one of the
  AI's predictions and found the "R: retry" labelling defect, which drove a
  source change.
* **No second playtester.** None is claimed.
* **The film is rendered** by the AI using the course-provided Brutalist
  toolkit the human supplied. Narration is AI text-to-speech (Liam, local
  Kokoro `am_onyx`), disclosed in the film's own credits.

### Narration and film

The film's narration script is AI-drafted (`film/SCRIPT.md`) and voiced by AI
text-to-speech (Liam, local Kokoro `am_onyx`, free and offline), which the
assignment permits and which the film's own credits state.

No gameplay footage is reconstructed, re-enacted or faked. Every gameplay frame
is the real engine running the committed source at revision `3aa05bb`, captured
through the real `Input` path with no teleports, no state writes and no disabled
collision checks. Scripted-input captures, held frames, and the one deliberately
reconstructed before-frame in the cause-and-effect beat are each labelled on
screen. The game is silent and no game audio was fabricated.

Additional tools used for the film: the course-provided
[nikbearbrown/brutalist.art](https://github.com/nikbearbrown/brutalist.art)
toolkit (Kokoro TTS, Remotion, Manim), ffmpeg 9.0.2, Node 20.19.5, and a
Python 3.12 virtualenv created because the toolkit's `manim` pin excludes the
machine's Python 3.13.

## 5. Collaborators

None. No classmate contributed code, assets, or text to this submission.

## 6. References consulted

* The starter's own documentation package (listed in §1).
* Godot 4.7 class reference for `CanvasItem` drawing, `CharacterBody2D`,
  `Area2D`, and `CollisionPolygon2D`.
* Public forks of the starter were seen in search results while locating the
  upstream repository. **No code, design, character concept, or level layout was
  taken from any of them.** Concepts already published by classmates (a ninja, a
  lamp-head courier, a one-eyed lighthouse robot) were deliberately avoided when
  choosing SPROCKET.
