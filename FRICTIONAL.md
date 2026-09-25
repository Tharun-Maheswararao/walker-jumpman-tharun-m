# FRICTIONAL — the honest log

**Project:** walker-jumpman-tharun-m · **Student:** Tharun Maheswararao
**Session date:** 2026-09-24

## How to read the attribution in this file

This assignment expects AI assistance and expects me to say exactly where the
line is. I am not going to blur it.

* **Human (Tharun)** — decisions I made and things I am accountable for.
* **AI (Claude Code, Opus 5)** — work the assistant actually performed.

**The blunt summary: in this session the AI wrote effectively all of the
GDScript, the tests, the tooling and the first drafts of the documentation.**
My contribution was direction, selection between options, authorisation, and
accountability. Entries below say which is which per item. Section 9 lists what
is still mine to do and cannot be delegated.

---

## 1. The starting position was worse than I expected

**What I tried.** Open the project folder and start work.

**What happened.** The folder `~/Documents/csye7270` was completely empty. No
starter checkout, no Godot, no Brutalist toolkit, no `ffmpeg`, no `gh`. The
assignment links to the starter but the link text in Canvas does not carry the
URL into a terminal.

**Response.** *AI* searched the web and found `nikbearbrown/walker-jumpman`,
confirmed it against several classmates' public forks that name it as their
upstream, and cloned it. *Human* authorised installing Godot through Homebrew.

**What I learned / checked.** Homebrew's `godot` cask is **4.7.2**, and after
installing, `Godot --version` returned
`4.7.2.stable.official.ed1daf0bf` — character-for-character the build string the
starter's README names as its tested engine. That is worth more than it sounds:
it means my test evidence is directly comparable to the starter's own, and any
difference in results is my change rather than an engine difference.

**Unresolved.** I did not verify that the public GitHub starter is identical to
whatever the instructor considers canonical. I pinned the commit I used
(`9387542`) in every document so a grader can check.

## 2. I ran the starter's tests before touching anything, and nearly didn't

**Human decision.** Take a baseline first.

**What happened.** 25/25 mechanics and 9/9 keyboard, all green
(`evidence/baseline/`).

**Why it mattered later.** Having the baseline is the only reason I can claim my
changes did not break anything, rather than just asserting it. It also handed me
a number I would otherwise have missed — see §3.

**Honest note.** My first instinct was to skip this and start editing, because
the tests "obviously" passed on the instructor's own code. That instinct was
wrong for a reason that has nothing to do with whether they pass: the baseline is
the *comparison*, not the *reassurance*.

## 3. My jump maths was wrong and the starter's own test output said so

**What I expected.** The standard projectile result: apex rise = `v²/2g` =
`320²/(2·960)` = **53.33 px**. I did the arithmetic by hand and started laying
out platforms against it.

**What happened.** The baseline output contained
`"rise_px": 56.0747`. The starter's own `fixed-jump-and-no-double` check asserts
the rise is within 5 px of 53.3333, so a 5% gap between textbook and reality had
been sitting in the passing test output the whole time, hidden inside a
deliberately loose tolerance.

**Response.** *AI* wrote `godot/tools/probe_jump.gd`, which measures the real
arc of the real player on a flat runway and dumps a reachability table
(`evidence/jump-envelope.json`). Measured apex **56.0 px**; max flat gap
**130 px**, not the 124 px I had computed.

**What I learned.** The discrete 60 Hz integrator applies the jump impulse for a
full tick before gravity fully bites, so the stepped result beats the continuous
one. More usefully: a passing test with a loose tolerance is not evidence that
your model of the system is right. I had a *correct* formula for the *wrong*
system.

**Traceability.** `godot/tools/probe_jump.gd`, `evidence/jump-envelope.json`,
CHANGE-BRIEF revision R1.

## 4. The two-lane fork I wanted is impossible, and it took me a long time to accept that

This is the entry I would most like to delete and won't.

**What I wanted.** A proper branching fork: a high rail and a low stone path
crossing the same pit, reconverging at the flag. It is the design that would
most obviously read as "a clear player decision."

**What I tried.** *AI* and I went through this repeatedly. Roughly:

1. High rail directly above the low stones → the player on the low stones jumps
   and bonks the rail.
2. Offset the lanes horizontally → they stop being parallel routes and become
   one route.
3. Rails placed above the *gaps* rather than above the stones → a stone-to-stone
   hop flies through exactly that airspace and lands on the rail instead.
4. Two landing targets from one take-off, near-low and far-high → the far target
   has to be within ~87 px of the take-off, and the near target has to fit
   before it without overlapping, which leaves about 17 px for a platform.
5. A safe gallery *below* ground level instead → the camera is fixed at y = 180
   on a 360 px viewport, so anything below y = 360 is off-screen, and the
   clearance arithmetic forces the shelf to y ≥ 364.

**What finally settled it.** Numbers, not opinion. A jump is a fixed 56 px rise
and the body is 28 px tall, so a jumping player's head reaches **84 px**. For a
platform to be safely walk-under-able by a jumper below, its underside must clear
84 px — meaning its top sits ~100 px up, against a 56 px apex. **Any platform you
can jump onto is a platform you can bonk.** Stacked lanes are arithmetically
impossible here without editing `tuning.gd`, which the assignment forbids.

**What I changed in response.** I stopped trying to force the shape and used the
one thing the constraint permits: the low road is **continuous ground requiring
no jump at all**, so the headroom is never tested in normal play, and the high
road is a 48 px climb onto a thin terrace. The decision is real — direct and
spiked versus safe and longer — and it fits the engine instead of fighting it.

**What I learned.** I spent far longer on this than on anything else in the
assignment, and the output is one paragraph of rejected design in CHANGE-BRIEF
§3. I think that paragraph is the most valuable thing I produced, because it is
the only part where I can show *why* the level looks the way it does rather than
just that it works.

**Unresolved.** I still do not love that the fork reconverges rather than
branching. If I had permission to touch `jump_velocity` I would raise it to
about −380 and the whole design space opens up. I did not touch it.

## 5. Things that broke, in order

**5.1 A one-line compile error I caused and did not predict.** *AI* added
`var title` to `hud.gd::_draw()`, where a `var title` already existed 25 lines
below for the menu card. Godot: `There is already a variable named "title"`.
The symptom was confusing — the test harness hung for three minutes rather than
reporting a parse error, because the failure cascaded through `preload` and the
suite kept awaiting frames on a null game object. *Response:* renamed to
`level_title`; also learned to run `--check-only` on a single script rather than
inferring a syntax error from a hung suite.

**5.2 My character contact sheet lied about one of its four cells.** First
render showed "RUN RIGHT" in the airborne pose. Not a character bug — the test
floor I had built was only 118 px wide, so the right-running instance ran off
the end of it while building up speed. *Response:* widened the test floor to
1200 px. *What I learned:* the harness is as capable of being wrong as the thing
it measures, and a rendered image is worth more than a passing assertion
precisely because it shows you the thing you didn't think to assert.

**5.3 Predicted failure E, exactly as written.** The starter's route fixture ran
out of jump marks and died at `(1017.06, 435.93)` in the first new pit. This one
I called in advance in CHANGE-BRIEF §5. *Response:* preserved the failing output
in `evidence/predicted-failures/` **before** extending the fixture, so the
failure is on the record instead of being quietly fixed.

**5.4 The one that was a genuine design defect.** The low-road fixture failed:
stuck at `x = 1935`, still PLAYING after 2000 ticks, pinned against the climb
step. The jump mark sat *under* the terrace, so it bonked the 8 px headroom and
fell back. Working the geometry backwards, the safe road's climb-out had an
**8 px take-off window** — about 0.05 s.

That is the part that stung. The low road's entire purpose is to be the
forgiving option, and I had accidentally made its one required jump the hardest
input in the level. *Response:* fixed the **geometry** — shortened the terrace,
replaced the step with a 36 px buttress moved 56 px further out — widening the
window to 39 px. I did not retune the jump, did not delete the assertion, and
did not raise the tick budget to hide it.

*What I learned:* I had been reviewing my geometry by checking "is each jump
reachable?" A jump can be reachable and still be unfair, because reachability is
about the existence of a solution and fairness is about the width of the window.
I now check both.

## 5.5 I committed a batch of work into the wrong repository

Worth logging because it is the kind of mistake that silently corrupts a
submission, and because I only caught it by reading output I could easily have
skimmed.

**What happened.** While collecting the starter's upstream SHA I ran
`cd .../_starter && git rev-parse HEAD` as the tail of a compound command. The
shell's working directory persists between commands in this environment, so
every later shell command ran inside the **scratch clone of the instructor's
starter** rather than in my project. The documentation commit landed there.

**How I caught it.** The `git log --oneline` I printed after committing showed
two commits instead of six, and the parent was `9387542` — the instructor's
hash, not my baseline `8c9085d`. I was printing that log to copy SHAs into the
docs, not to check for this.

**What was actually damaged.** Less than it looked. Every document was written
with an **absolute** path, so all of them landed in the right project. Only the
shell operations went astray: the `git mv` of the starter's README into
`starter-docs/`, and the commit itself.

**Response.** Recreated `starter-docs/STARTER-README.md` in the project from
`git show 8c9085d:README.md` — recoverable precisely *because* the pristine
starter is the first commit — and `git reset --hard 9387542` on the scratch
clone so it is byte-identical to upstream again. Verified the project's history
still reads `8c9085d → 76f2938 → 394bd91 → b3b4d19`, then re-committed properly.

**What I learned.** Two things. Using absolute paths for file writes is what
kept this to a five-minute fix instead of a lost afternoon. And the reason the
damage was trivially reversible is the decision from §2 — committing the
unmodified starter as the first commit. That was done so graders could diff my
work; it turned out to be the backup that let me restore a file I had clobbered.

## 6. The most useful thing I did: proving the bug instead of asserting the fix

CHANGE-BRIEF §5 predicted three drawing failures (A, B, C) before I edited
anything. I then fixed all three in the same pass as the level change — which
meant I had *predicted* them and *fixed* them but never actually *seen* them.
That is a weak claim.

**Response.** *AI* rebuilt the project in a scratch directory with the
**starter's** `session.gd` and `hud.gd` and **my** level data, and captured a
frame: `evidence/screens/bug-before-15-terrace-and-raised-spikes.png`. All three
predictions are visible in that single image — spikes painted 64 px below their
own trigger, no backdrop or grid in the new region, progress bar already full.

**And it caught something I had missed.** The finish pole is *also* drawn from
the hard-coded ground baseline, so with the flag moved onto the raised terrace
the pole spears down through the walkway. I predicted the hazard-baseline bug
and did not notice the identical bug five lines below it in the same function.

**What I learned.** "I fixed it" and "here is the defect, and here is the same
frame after the fix" are not the same claim, and only the second one is
checkable by someone who is not me.

## 7. A revision that came from looking, not from a test

Reading `evidence/screens/14-the-fork.png`, the level never tells the player
where the high road begins. The take-off window is x 1580–1618 — *before* the
terrace starts at 1664 — so the instinctive move, run up under the terrace and
jump, puts you in the headroom and bonks. No assertion would have caught this:
the route fixture already knew the right number.

*Response:* painted a chevron band on the ground slab at exactly the measured
window, driven from level data so the paint and the physics describe the same
span; and moved the road captions to their own elevations, because the low-road
caption was being read straight through the character. Commit `b3b4d19`.

**Still unresolved and written into TEST-REPORT §12.6:** the band's position is
placed by hand. If the geometry moved and I forgot to move the band, no test
would notice. The hazard and finish marker no longer have that weakness because
they share one geometry function; the guide band still does.

## 8. The film toolkit — four environment failures before a single frame

**Human decision.** I supplied the course-provided toolkit,
[nikbearbrown/brutalist.art](https://github.com/nikbearbrown/brutalist.art),
rather than the public fork the AI had found by search.

Four things broke before anything could render. None of them were fixed by
editing the toolkit.

**8.1 `./setup` never prints its readiness table.** Its ElevenLabs guard greps
the whole tree and matches the toolkit's *own* bundled examples under
`youtube/brutalist/…`, then exits 1 — before the dependency table. `--install`
still installs, because the install block runs first. *Response:* verified every
dependency by hand instead. The guard was left alone; it is the toolkit's bug,
not mine to silently patch.

**8.2 Python 3.13 cannot satisfy `requirements.txt`.** `manim>=0.18,<0.19`
requires Python `<3.13`. pip resolves the whole file atomically, so that one
unsatisfiable pin aborted the install and kokoro-onnx and mutagen never landed
either — the failure looked like "nothing installed" rather than "manim is
incompatible". *Response:* a Python 3.12 virtualenv for the toolkit.

**8.3 `manimpango` needs native pango/cairo**, not on the machine.
*Response:* `brew install pango cairo pkg-config`.

**8.4 Homebrew's ffmpeg has no `drawtext`** (built without libfreetype), so
on-screen labels could not be burned the obvious way. The toolkit anticipates
this — `compile.py` has a `has_drawtext()` check with a PIL fallback.
*Response:* generated label PNGs with PIL and composited them with `overlay`.

**What I learned.** Every one of these presented as a different symptom than its
cause. The most misleading was 8.2: the visible failure was two unrelated
packages missing, and the actual cause was a version pin on a third package I
was not even using yet.

## 9. What is still mine, and cannot be delegated

Listing this explicitly because the rubric asks me to distinguish my work from
the AI's, and the honest answer is that the implementation was the AI's.

1. **The human playtest is done** — see §12 below. It refuted one of the AI's
   predictions and found a defect. What is *not* done is a playtest by anyone
   who did not design the level; one run by the author is the weakest possible
   sample and TEST-REPORT §12.1 says so.
2. **A second playtester.** Still none recorded. Not invented.
3. **The film.** Rendered — see §13. What I own about it: I am accountable for
   every claim in it, and for the decision to fix the two QC findings in the
   game and the framing rather than in the checker.
4. **Being able to explain all of it.** The concepts I need to be able to defend
   without notes: why the measured apex is 56 px and not 53.3 px; why stacked
   lanes are impossible here (the 84 px head-reach argument); why
   `hazard_triangle()` exists and what breaks without it; what the 8 px terrace
   margin and the 39 px climb-out window mean for a human player; and what
   changed in `route_driver.gd` and why that is an extension rather than a
   weakening.

## 10. Traceability

| Entry | Evidence |
| --- | --- |
| §2 baseline | `evidence/baseline/`, commit `8c9085d` |
| §3 jump maths | `godot/tools/probe_jump.gd`, `evidence/jump-envelope.json`, CHANGE-BRIEF R1 |
| §4 rejected fork | CHANGE-BRIEF §3 and R1, TEST-REPORT §2 |
| §5.1 compile error | commit `394bd91`, `hud.gd` `level_title` |
| §5.2 contact sheet | `godot/tools/capture_character.gd`, `evidence/screens/character-sheet.png` |
| §5.3 predicted failure E | `evidence/predicted-failures/E-route-fixture-fails-before-update.txt` |
| §5.4 low-road defect | CHANGE-BRIEF R3, TEST-REPORT §10 cycle 1, commit `394bd91` |
| §6 before/after | `evidence/screens/bug-before-*.png` vs `15-terrace-and-raised-spikes.png` |
| §7 revise cycle | commit `b3b4d19`, TEST-REPORT §10 cycle 2 |
| §8 film | `film/BEAT-SHEET.md`, `film/SCRIPT.md` |

## 11. Things that worked first time

Recording these so the log is not artificially dramatic. The rubric says an
unsuccessful attempt earns full credit and invented struggle earns none; the
reverse is also true, so:

* The SPROCKET drawing rendered correctly on the first run and needed only one
  0.4 px adjustment where the airborne foot pads dipped below the collider floor.
  I checked it by rendering the collider over the art rather than by eye.
* Physics was untouched by the character change, confirmed by 25/25 and 9/9
  producing observations identical to the baseline.
* The camera needed **no** changes. I expected to have to touch it; the starter's
  clamp is already `clampf(x + 100, 320, level.width - 320)`, so widening the
  level was enough. I verified the flag and buttress are on screen rather than
  assuming it.
* The `walker-jumpman.command` launcher needed no changes.

## 12. The playtest, and the prediction it killed

**What I did.** Played the built game at a keyboard on revision `e138323`. Two
runs: one taking the high road, one taking the low road. Full record in
TEST-REPORT §7.2.

**What I expected.** The AI had written, in CHANGE-BRIEF failure case D and
again in the limitations, that the 48 px terrace jump has only 8 px of margin
against a 56 px apex and that a first-timer would probably smack the underside
of the terrace before the painted chevron guide taught them the timing.

**What actually happened.** I completed the level on my second attempt. I saw
the chevron band, it read as "jump here", and **I did not bonk the terrace** —
the high-road jump landed first time. The spikes on the walkway were easy to
see at running speed. Pausing mid-jump with Esc and resuming gave me no free
jump.

**What I checked in response.** The prediction is left unedited and marked
**refuted** in CHANGE-BRIEF R6. I deliberately did **not** turn this into "the
jump is forgiving," because I am the person who placed those platforms and
already knew where the take-off window was. That is the most biased sample
available, and it is now limitation 1 in TEST-REPORT §12 rather than a result.

**The one thing that did not behave as I expected.** I died on purpose, waited
to press R — and the game restarted by itself. That is the starter's designed
behaviour (death auto-restarts after 0.55 s), but the HUD hint said
**"R: retry"**, which reads as "press R to come back from a death." The game
was also inconsistent with itself: the pause card has always called the same key
**"R: restart attempt."**

**What I changed.** The HUD string, to **"R: restart"**. One UI string; no
timing, no input map, no state change. Suites re-run after it: 25/25, 9/9,
22/22.

**What I learned.** Two things worth keeping. First, a prediction being wrong in
the design's favour is still a wrong prediction, and the honest move is to mark
it refuted rather than quietly delete it and look prescient. Second, the defect
I found was not in anything the AI built — it was an inconsistency the starter
already had, which only became visible because a person sat there expecting
something and it did not happen. No assertion in 56 checks could have found it,
because nothing was broken. It was just wrong.

**Human/AI split on this entry.** The playing, the observation and the decision
to change the label are mine. The AI wrote the one-line change, re-ran the
suites, and drafted this write-up from the notes I gave it.

**One more thing the playtest taught me about my own level.** My single failed
attempt was *jumping too early*. Chasing that, the AI checked the arithmetic:
at full speed the centre travels at most 112 px, and every stone's landing
window reaches 24 px further than that from the latest take-off. **You cannot
overshoot a stone.** Committing always lands; the only way to miss is to leave
early. That was true of the layout all along and neither of us had said it out
loud until my failure demonstrated it. It is now asserted by
`stones-cannot-be-overshot`, so the property cannot silently disappear.

I like this one because the causation runs the useful way round: the playtest
did not just find a bug, it explained a design property back to me.

**Traceability.** TEST-REPORT §7.2, §7.4 and §7.5, CHANGE-BRIEF R6,
`godot/ui/hud.gd`, `stones-cannot-be-overshot` in `godot/tests/test_extension.gd`.

## 13. The film, and three gates that were right

The walkthrough rendered at 3840×2160, 3:47, thirteen beats, with local Kokoro
narration. `./art final` refused it three times first, and each refusal was
correct.

**GATE T said my level's signage was too small.** A 36px text run against a
41px floor. I did not take the checker's word for it: I extracted the frame, ran
its own `text_run_bboxes` detector, and cropped the blob. It was the word
**"Two"** in my own in-world sign *"Two stones. Then pick a road."*, at font
size 13. The checker was right. Fixed in the **game** — label sizes 13→17 and
15→20 — so the signs are easier to read while playing, not only on film. I did
not add the beat to the exemption list, and I did not crop the capture to dodge
the measurement. Cost: re-capturing every clip and re-rendering.

**GATE T also said text crossed the title-safe box.** That text was the game's
*own HUD*, which lives at the very frame edge. Moving a game's UI to satisfy a
film check would be changing the game to suit the film, so instead each capture
is inset to exactly 90% on the game's own cream — which is what the toolkit's
own `GodotDesignFigure` slot does for engine captures. The files in `capture/`
stay unscaled native 4K.

**GATE V said five beats were low-contrast.** Here the check was measuring the
wrong thing: the frame average is dominated by the game's cream sky and pale
hills, which is the intended background, not a scrim over text. The toolkit has
a documented mechanism for exactly this — `qc.contrast_regions` with a written
reason — which replaces *only* the whole-frame average while every other check
still runs. I used it and wrote down why.

**And one blocker that was purely my fault:** the B01 card's text crossed the
title-safe right edge and filled 28% of the safe area. Rewritten as eight
shorter lines.

**Two defects no gate caught.** Both came from reading my own capture logs:
landmarks named as outcomes ("landed on stone 2") when they only test x — false
in the one clip where the player was falling past that x — and a failure clip
that died by running off a platform while its own label claimed an early jump.
Both fixed so the footage fails the way the narration says it does.

**Human/AI split.** The AI built the pipeline, drove the captures, authored the
beat sheet and coverage contract, and diagnosed all three gates. I supplied the
toolkit, and I own every claim the film makes.

## 14. The film shipped without saying who made it

**What happened.** After the render was finished and verified, Tharun asked a
simple question: why does the last card say `@NikBearBrown`?

The direct answer is that it is not a choice. `OUTRO-LOCK.md` in the course
toolkit specifies the handle as **hardcoded** — "never derived from a persona /
skin / channel variable. It is the one channel" — and the `godot-waikthrough`
skill orders walker mode to obey that lock. Every `claude-liam-*` Brutalist reel
ends on that card. It is the toolkit's channel branding, not a claim about
authorship.

**But checking it found a real defect.** Grepping the delivered narration for
any attribution returned **zero** matches. The assignment requires the film to
"identify human and AI contributions and the game revision being demonstrated."
The revision was on screen in two places; the human/AI split was nowhere. I had
planned an attribution card in `film/BEAT-SHEET.md` and then silently dropped it
when I authored the actual beat sheet.

**Response.** The outro card is locked and cannot carry it, so the credits went
into **Your Turn**, which is where the skill says Liam signs off before the
final card: four on-screen lines naming the human, the AI, the AI voice and the
art provenance, plus the revision, and the same read aloud. B11 went from 28.9s
to 51.4s and the film from 3:47 to 4:10. Gates re-run: GATE T PASS, GATE V 0/0.

**What I learned.** I verified the film against every machine gate the toolkit
has, and all of them passed while the film was missing an explicit assignment
requirement. The gates check what they were built to check. Nothing in that
pipeline was ever going to ask "does this say who made it?" — and I stopped
looking once the gates were green.

**Human/AI split on this entry.** Tharun asked the question that found it. I
diagnosed it and made the fix.
