# SCRIPT — walker-jumpman-tharun-m explainer

**Narration:** AI text-to-speech (Liam / Kokoro `am_onyx`) via the Brutalist
`godot-waikthrough` walker workflow. Permitted by the assignment and disclosed
in the film's credits, README.md and SOURCES.md.

**Revision demonstrated:** `5bdd71e`
**Target:** ~3:30, landscape, native 4K.

Read at a measured pace. Every factual claim below is checkable against a
committed artifact; the cross-references in **[brackets]** are for the editor
and are not spoken.

> **Status: RENDERED.** The as-delivered narration is in the reel's
> `beat_sheet.json` (`narration_text` per beat); several gameplay beats were
> shortened during the build so narration would not outrun the action. Where
> this document and the reel differ, the reel is what was spoken.

---

### Beat 0 — Walker opening
*(skill template)*

---

### Beat 1 — What this is · 0:20
> This is walker-jumpman, Nik Bear Brown's First Steps starter, in Godot
> 4.7.2. On the left, the instructor's original at commit 9-3-8-7-5-4-2. On the
> right, my extension at 5-b-d-d-7-1-e.
>
> Two things changed. The character is new. And the course is roughly twice as
> long, with a fork in it, and the flag moved behind the new section so you
> can't finish without playing it.
>
> Everything else — the controls, the jump, the collider, the retry loop — is
> the starter's, untouched.

**[Split screen. Lower third: `STARTER 9387542` / `THIS BUILD 5bdd71e`.]**

---

### Beat 2 — The character · 0:30
> The starter's character is drawn in code, not from a sprite sheet: seven flat
> rectangles and a cream visor that slides left or right. Its outline is a plain
> rectangle in every state.
>
> This is SPROCKET, a wind-up tin automaton. A chamfered brass barrel instead of
> a rectangle. A narrow domed head with one round lens — the starter has no
> curves at all. Piston legs that stride when grounded and pull up into a coil
> in the air.
>
> And the part that does the real work: a winding key on the back. It always
> trails, so it flips sides when SPROCKET turns. You can read which way this
> character is facing from the silhouette alone.
>
> Here it is in all four states with the real collider drawn over it in
> magenta. The body stays inside the box. One thing doesn't — the key overhangs
> by three and a half pixels. That's deliberate, it's always on the trailing
> side, and it's asserted by a test rather than eyeballed. I'd rather declare it
> than hide it.

**[Live play, then the contact sheet. Label: `TOOL OUTPUT — NOT GAMEPLAY`.]**

---

### Beat 3 — Designing against measured physics · 0:25
> Before placing a single platform I measured the jump instead of calculating
> it. Textbook says the apex is v-squared over two-g: fifty-three point three
> pixels. The engine actually gives fifty-six.
>
> The sixty-hertz integrator applies the jump impulse for a full tick before
> gravity fully bites. Five percent — which is the difference between a landing
> that works and one that doesn't.
>
> So every gap in the new section is sized against this measured table, not
> against the formula. The widest gap is seventy-two pixels against a
> hundred-and-thirty pixel budget.

**[Terminal output from `probe_jump.gd`; envelope table as a lower third.
Label: `TOOL OUTPUT — NOT GAMEPLAY`.]**

---

### Beat 4 — The new section · 0:35
> Section three. The Fork.
>
> It opens with a sixty-four pixel gap onto The Junction — the same width as the
> starter's first gap, so it asks for something you've already proved you can
> do.
>
> Then it gets specific. Two stepping stones, sixty-four pixels wide. That's
> half the width of anything in the starter, and underneath them is a real pit.
> Miss, and you fall.
>
> That's four new landings already, and none of them can be walked onto.
>
> And there's a property of these stones worth knowing. At full speed you
> cannot overshoot one — the landing window always reaches further than the
> jump does, by about twenty-four pixels. So committing never kills you. The
> only way to miss is to leave early. When I played this, that's exactly the
> one attempt I lost.

**[Continuous live run. No cuts through the stones.]**

---

### Beat 5 — Failure and recovery · 0:25
> And this is what failure looks like. That's a real death, from the game's own
> collision check — I walked into the spike bank on the terrace.
>
> Retry card, a bit over half a second, and I'm back at the spawn. Retries are
> unlimited and pressing R yourself doesn't count as a death. That's the
> starter's behaviour and I didn't touch it.
>
> Second attempt. Over the spikes this time.

**[Real death → retry → respawn → successful second attempt. No cut between
death and respawn.]**

---

### Beat 6 — Cause and effect · 0:40
> Here's the one I want to show you properly, because it's the trap this
> starter sets.
>
> The starter builds spike *triggers* from the level data — but it draws spike
> *art* with the y coordinate hard-coded to the ground line. Two copies of the
> same geometry, and only one of them reads the data.
>
> So put a hazard up on a raised terrace and this happens.
>
> That is a real capture — the starter's drawing code running against my new
> level data. The spikes are painted on the ground, sixty-four pixels below the
> trigger SPROCKET is actually walking into. An invisible killer, and a
> decoration that can't hurt anyone.
>
> The same frame shows two more: the backdrop and grid just stop, because the
> background was a fixed eighteen-hundred-pixel rectangle. And the progress bar
> is already full, because the HUD divided by a hard-coded eight-five-two.
>
> I predicted those three before I wrote any code. I did not predict the fourth
> one, and you can see it right there — the finish pole is drawn from the same
> ground baseline, so it spears straight down through the terrace. I caught the
> hazard bug and missed the identical bug five lines below it.
>
> The fix is one function. `hazard_triangle` is now the only definition of a
> spike's shape, and both the trigger builder and the renderer call it. They
> can't drift apart, and a test asserts it.
>
> Same spot, after.

**[Before-frame MUST carry `STARTER DRAW CODE + NEW LEVEL DATA`. Source diff
on screen. Hard cut to the after-frame on "Same spot, after."]**

---

### Beat 7 — The fork, both roads · 0:30
> Now the decision.
>
> The high road is a forty-eight pixel climb onto that terrace — the hardest
> jump in the game, against a fifty-six pixel apex. It's direct, and it's
> spiked.
>
> The low road is the ground underneath. Nothing to miss, nothing to hit. But
> the only way back up is past the flag, so you overshoot and double back.
>
> And here's the thing I had to measure rather than assume. Horizontal speed in
> this engine is a constant one-sixty, in the air as well as on the ground. You
> cannot make a route faster by moving quicker — only by travelling less
> distance. So the safe road's cost is built out of the detour.
>
> High road: six hundred and sixty-six ticks. Low road: eight hundred and
> three. Two-point-two-eight seconds. That's asserted by a test, so if I ever
> flatten it the suite fails instead of the claim quietly becoming untrue.
>
> And if you mistime the terrace jump, you smack its edge, drop back down, and
> you're just on the low road. Failing the fast route costs time, not a life.

**[Both roads. Tick counters as a lower third. Label `SCRIPTED INPUT` on the
timed comparison.]**

---

### Beat 8 — Completion · 0:10
> The flag. Which is now at x eighteen-twenty-four, up on the terrace, where you
> can only reach it by finishing the new section either way round.

**[Live completion, completion card, Enter to replay.]**

---

### Beat 9 — Verdict · 0:25
> So. Fifty-seven automated checks, zero failures: the starter's twenty-five
> mechanics checks, its nine keyboard checks byte-identical, and twenty-three
> new ones for the extension.
>
> What I changed in the supplied route fixture, I extended — I didn't weaken it.
> The original five jump marks are still in there, and the failing run from
> before I updated it is committed, not deleted.
>
> What's uncertain. The terrace jump has eight pixels of margin. A script hits
> it every time because it jumps on an exact tick; a person won't, and I expect
> first-timers to bonk the underside before the painted guide teaches the
> timing.
>
> And the honest one. I did play this at a keyboard, and it went better than I
> predicted — I said a first-timer would smack the underside of that terrace
> before the painted guide taught the timing, and I didn't. That prediction is
> in my change brief, marked refuted, not quietly deleted.
>
> But one person played this, and it was me — the person who placed the
> platforms and already knew where the take-off window was. That's the weakest
> sample there is. It needs someone who hasn't seen the geometry.

**[Test totals on screen. State the playtest gap plainly — do not soften it.]**

---

### Beat 10 — Your Turn · 0:15
> One concrete next improvement, and it's the limitation I can name most
> precisely: that painted launch guide is positioned by hand. If I moved the
> terrace and forgot to move the guide, nothing would catch it — the paint and
> the physics would disagree, which is exactly the bug I just spent a minute
> showing you, reintroduced somewhere else.
>
> So the next change is to compute the guide from the measured take-off window
> at load time, the same way `hazard_triangle` already makes the spikes honest.
>
> Play it. Take the low road first. Then tell me whether doubling back reads as
> a decision, or just as getting lost.

**[Held frame of the fork. Label: `HELD FRAME`.]**

---

### Beat 11 — Walker summary + outro
*(skill template, then the credits card)*

> Starter: walker-jumpman by Nik Bear Brown, commit 9-3-8-7-5-4-2. This
> extension: revision 5-b-d-d-7-1-e, Godot 4.7.2.
>
> I set the direction, chose the character concept, and I'm accountable for
> this submission. Claude Code wrote effectively all of the GDScript, the
> tests, the tooling, and the first draft of this script. This narration is AI
> text-to-speech. All the art is original vector drawing — nothing imported,
> nothing purchased, nothing generated.
>
> One playtest, by me. No second playtester is claimed.

**[Attribution card held long enough to read.]**
