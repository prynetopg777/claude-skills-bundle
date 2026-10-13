---
name: pryne-design-direction-decision
description: Use when multiple built design variants exist in a repo and one direction must be chosen and committed — e.g. comparing v4-a/v4-b/v4-c/v4-d demo files, picking a "winner" concept, finalizing a design direction, or any request like "which variant should we go with". Also use when tempted to keep polishing one favorite variant while siblings sit unscored.
---

# Design Direction Decision Campaign

Decision-gated procedure for committing to ONE design direction out of N built variants. Success is measurable — rubric scores, console output, Lighthouse numbers — never "this one looks best." That fence exists because v3 NIGHT DRIVE was polished to verified-working (zero console errors) and still got superseded because the *concept* was wrong; full story in **pryne-failure-archaeology**. Concept fit is scored before polish depth.

## When NOT to use this skill

- Only one variant exists → nothing to decide; use **pryne-validation-and-qa** to score it.
- Deciding a small element (button style, easing curve) inside an already-committed direction → **pryne-validation-and-qa** rubric pass, no campaign.
- Measuring or debugging a page → **pryne-browser-lab** / **pryne-frontend-debugging**.
- The decision was already signed off and recorded in DECISIONS.md → don't reopen it; see **pryne-failure-archaeology** before re-litigating.

## Live instance (as of 2026-07-22)

Repo: `~/Documents/Coding Folder/Portfolio (test)`. Candidates in `design-demos/`:

| File | Organizing concept (from each file's own head comment) |
|---|---|
| `v4-a-midnight-issue.html` | Site = Issue 01 of a fashion/culture magazine developed in a darkroom in front of you |
| `v4-b-first-pressing.html` | Site = a record; your visit IS the recording |
| `v4-c-ch001.html` | Site = chapter one of a serialized long-strip (webtoon panel grammar) |
| `v4-d-hybrid.html` | Site = a roll of film — "ROLL 01" |

`v4-d` is the current *build target* (commit `1575051` "Baseline: ROLL 01 static demo before award-caliber overhaul", plus `design-demos/DECISIONS.md`), but the direction is not finally committed — this campaign is how it gets committed.

## Phase 0 — Preconditions (disqualification gate)

Run the whisper-level personality checklist from `design-demos/DECISIONS.md` against every candidate: nothing personality-coded visible on a cold zero-interaction screenshot; every personality reference behind a deliberate trigger.

- **Gate:** a variant that violates an invariant is DISQUALIFIED from scoring now — not "we'll fix it after it wins." Fixing it first (via normal change flow) re-admits it.
- **Expected observation:** all candidates pass; on the v4 set this should be true by construction since the rubric predates them. If one fails → that's a finding worth recording in DECISIONS.md regardless of the campaign outcome.

## Phase 1 — Evidence collection (per variant, identical protocol)

Collect with the recipes in **pryne-browser-lab** (it owns the exact commands):

1. Breakpoint screenshot matrix — same breakpoints, same scroll positions, for every variant. Name artifacts `<variant>-<breakpoint>-<section>.png` — the campaign extension of the standard convention owned by **pryne-browser-lab** (adds a section token so the matrix is diffable).
2. Console log after a full top-to-bottom scroll plus one pass of each deliberate interaction.
3. Lighthouse performance + accessibility run.

- **Expected observation:** zero console errors per variant.
- **Branch:** any variant that errors FORFEITS until fixed → fix via **pryne-frontend-debugging**, then re-collect *that variant's entire evidence set* (stale evidence is treated as no evidence).
- **Fence:** never score from memory of how a variant looked last week. Fresh artifacts only.

## Phase 2 — Rubric scoring

Score each variant per section with the CRITIQUE rubric (Craft / Motion-interaction / Storytelling / Restraint / Performance, 1–5). **pryne-validation-and-qa** owns the rubric definitions and thresholds; do not restate them here.

**Anchor rule:** score each variant against the four analyzed reference sites (PX Push, Cult, TRIONN, Lando Norris), NOT against each other. Relative scoring lets a weak field inflate a mediocre winner.

Empty matrix template (one per variant, then a totals table):

```
Variant: v4-_
| Section  | Craft | Motion | Story | Restraint | Perf | Notes |
|----------|-------|--------|-------|-----------|------|-------|
| Cover    |       |        |       |           |      |       |
| Work     |       |        |       |           |      |       |
| About    |       |        |       |           |      |       |
| Contact  |       |        |       |           |      |       |

Totals:
| Variant | Rubric total | Console errors | LH perf | LH a11y | Coherence defects |
|---------|--------------|----------------|---------|---------|-------------------|
```

(Adjust section rows to the variant's actual sections; keep the same rows across variants.)

## Phase 3 — Concept-coherence test (the v3 lesson, operationalized)

1. State each variant's organizing concept in ONE sentence (the head comments above are the source).
2. Walk every distinct element/interaction of the variant and ask: *can this element be explained using only that one sentence?* Any element that needs a **second metaphor** to explain is a coherence defect. Count them.

This is exactly the audit v4-d's own head comment records: the original hybrid was found to be "two unreconciled metaphors running in parallel" (Midnight's darkroom entry + Ch.001's panel grammar) and was bridged with the roll-of-film concept precisely because a roll of film is *inherently both* a sequence of frames and something developed by hand. That audit is the precedent: coherence defects are findable and fixable, but only if you count them instead of squinting.

- **Expected observation:** the strongest candidate has 0–1 coherence defects. If every candidate has several → branch: the field is weak; consider a bridging concept (the v4-d precedent) rather than crowning the least-bad variant.

## Phase 4 — Decision gate

Produce a ranked menu with numbers — one page, no more:

1. Rank by rubric total.
2. **Tiebreak** (totals within ~5% of each other — proposed convention, not yet exercised; adjust on first use): fewest coherence defects wins; still tied → best Lighthouse performance.
3. Output: recommendation naming the winner, its totals, its coherence-defect count, and the one-sentence concept; runner-up with the same numbers; one line per eliminated variant saying which gate eliminated it.

**Fence:** if you notice you've been polishing one variant during Phases 1–3, stop — polish after the decision, or you're paying the v3 cost again (sunk polish biasing the pick).

## Phase 5 — Promotion protocol

1. The recommendation routes through **pryne-change-control**: a design direction is a Pryne-sign-off change. **An agent never auto-commits a direction** — present the one-pager and stop.
2. On sign-off: record the decision in `design-demos/DECISIONS.md` (entry format per **pryne-docs-and-writing**) — decision, evidence pointers, rejected variants with one-line reasons.
3. Mark losing variants as superseded references. **Do not delete them** — the v3 precedent: NIGHT DRIVE was kept as a design-system/fallback-pattern reference after supersession, and losing v4 variants carry reusable section patterns the same way.
4. Sync the outcome to the project's source-of-truth vault note (repo is build output; the vault carries status).

## Known wrong paths (fenced)

- **Polishing a favorite before scoring all variants** — sunk cost decides instead of evidence (the v3 failure mode).
- **Scoring from memory / stale screenshots** — evidence must postdate the last edit to every variant.
- **Letting an agent pick** — agents assemble the menu and the numbers; Pryne picks.
- **Deleting losing variants** — supersede and keep; they are pattern quarries.
- **Re-running the campaign because the winner "feels wrong" later** — reopening requires new evidence, through change control, not vibes.

## Provenance and maintenance

Run `scripts/verify.sh` (in this skill's directory) to check all of the below at once.

Facts date-stamped 2026-07-22. Re-verify before relying:

- Candidate files still exist: `ls "$HOME/Documents/Coding Folder/Portfolio (test)/design-demos/"v4-*.html`
- v4-d still current build target: `git -C "$HOME/Documents/Coding Folder/Portfolio (test)" log --oneline -3`
- Rubric + whisper checklist unchanged: `cat "$HOME/Documents/Coding Folder/Portfolio (test)/design-demos/DECISIONS.md"`
- Organizing-concept sentences still match: `head -5 "$HOME/Documents/Coding Folder/Portfolio (test)/design-demos/"v4-*.html`
- If the v4 decision has since been made, the "Live instance" section is historical: check DECISIONS.md for a direction entry, and treat this skill as the template for the *next* N-variant decision.
