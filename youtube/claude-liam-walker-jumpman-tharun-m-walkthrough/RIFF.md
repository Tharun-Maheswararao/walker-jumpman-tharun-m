# RIFF.md — Liam's commentary plan

Voice: Liam (in for Bear), local Kokoro `am_onyx`. Not a game character.
Register: walkthrough — inspect first, then name the mechanism and the trade-off.

## Rules followed

* **Inspected before narrating.** Every riff line was written after reading the
  capture's input log and the source that produces the behaviour, not from the
  beat plan alone.
* **Source-code facts are identified as such.** "The starter draws spikes with
  y hard-coded" is a source fact; "the fork reads as a decision" is a human
  judgment and is attributed to the playtest, not asserted by the narrator.
* **Untested judgments are marked.** The film says the terrace jump has 8px of
  margin (measured) and that *one* person played it and he designed the level
  (stated as the weakness it is). It does not say the jump is forgiving.
* **The human judges feel and fun.** The AI played, recorded, explained and
  checked. The only "does this feel right?" claim in the film comes from the
  recorded playtest.

## Per-beat riff intent

| Beat | Mechanism named | Trade-off named |
|---|---|---|
| B02 | Facing encoded in silhouette via the trailing key | Readability without relying on colour |
| B03 | Landing windows exceed max jump travel by 24px | Commitment is safe; hesitation is what kills you |
| B04 | Fall check below `fall_y`, 0.55s retry | Cheap death keeps the loop tight |
| B05 | 48px rise against a 56px apex; painted take-off window | Direct route costs precision and exposure |
| B06 | Same x, different y, proven from the logs | Safety costs distance, not danger |
| B07 | Two copies of one geometry, only one reading the data | Single source of truth removes a whole bug class |
| B08 | Pause freezes integration; resume re-arms jump release | Interrupting a jump must not hand back a free one |
| B09 | Replay resets counters | A second run is a clean measurement |

## Audio

The game is silent, so there is no gameplay audio to duck or retain. Narration
is the only audio bed. All audio stops before the outro card; only Liam's
spoken title and "At Nik Bear Brown" play there — no jingle, no game audio, no
invented character voice.
