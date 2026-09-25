# TYPECHECK.md — GATE T

Reel: `claude-liam-walker-jumpman-tharun-m-walkthrough`  |  Checked: 2026-09-24T20:59  |  Overall: **FAIL**  |  Beats checked: 13  |  FAILs: 1

Spec: `skills/make/kerning/reference/type-spec.md` §8.  Floor: 1.9% frame-height.  Contrast: 4.5:1 WCAG.  Kern threshold: 3.5× expected advance.  Wordy budget: 2 elements.

| beat | lane | polarity | worst finding | status | fix |
|------|------|----------|---------------|--------|-----|
| B00 | ? | light | min-size §8.1: hand-drawn pattern (ClaudeComposerAsk) — §8.1 hachure/crossbar fragments ar… | PASS | — |
| B01 | ? | light | min-size §8.1: min text-run height 81px >= floor 41px | PASS | — |
| B02 | ? | light | min-size §8.1: smallest text run 36px < floor 41px (1.9% of 2160px logical); likely a capt… | **FAIL** | Increase font_size in scenes.py or Remotion component |
| B03 | ? | light | min-size §8.1: min text-run height 82px >= floor 41px | PASS | — |
| B04 | ? | light | min-size §8.1: min text-run height 59px >= floor 41px | PASS | — |
| B05 | ? | light | min-size §8.1: min text-run height 82px >= floor 41px | PASS | — |
| B06 | ? | light | min-size §8.1: min text-run height 81px >= floor 41px | PASS | — |
| B07 | ? | light | min-size §8.1: min text-run height 172px >= floor 41px | PASS | — |
| B08 | ? | light | min-size §8.1: min text-run height 59px >= floor 41px | PASS | — |
| B09 | ? | light | min-size §8.1: min text-run height 82px >= floor 41px | PASS | — |
| B10 | ? | light | min-size §8.1: hand-drawn pattern (ClaudeVerdictArtifact) — §8.1 hachure/crossbar fragment… | PASS | — |
| B11 | ? | light | min-size §8.1: hand-drawn pattern (ClaudeComposerAsk) — §8.1 hachure/crossbar fragments ar… | PASS | — |
| B12 | ? | light | min-size §8.1: min text-run height 43px >= floor 41px | PASS | — |

---

## Failures requiring action before cut

### B02 (?)
- **min-size §8.1**: smallest text run 36px < floor 41px (1.9% of 2160px logical); likely a caption/label too small — increase font_size or check if this is a data label needing §7 treatment
- **Fix:** Increase font_size in scenes.py or Remotion component

---

## Check summary

| Check | Beats checked | FAILs |
|-------|---------------|-------|
| no-wordy-card §8.5 | 0 | 0 |
| min-size §8.1 | 13 | 1 |
| overflow §8.2 | 13 | 0 |
| contrast §8.3 | 13 | 0 |
| contrast-local §8.3b | 13 | 0 |
| bbox-overlap §8.6b | 13 | 0 |
| card-clip §8.13 | 13 | 0 |
| kerning §8.4 | 0 | 0 |
| redundancy §8.10 (advisory) | 1 | 0 (advisory — no exit effect) |

---

*GATE T: any FAIL blocks `./art run` and `./art final`. Fix the flagged beats and re-run `scripts/type_check.py` until green.*
