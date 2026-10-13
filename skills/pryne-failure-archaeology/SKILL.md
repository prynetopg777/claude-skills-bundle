---
name: pryne-failure-archaeology
description: Use when about to propose reintroducing, removing, or re-litigating something in a Pryne project (a library, an organizing design concept, an easter egg, an architecture choice), when re-investigating why a demo file or feature exists or was abandoned, when a spec label like "non-negotiable" conflicts with what the code actually does, or when you open an old demo file and need to know whether it is a build target or a relic.
---

# Pryne Failure Archaeology

The chronicle of settled battles in Pryne's projects, so no session re-fights one. Each entry: what happened, root cause, evidence you can still check, current status, and the rule it produced. The **rules** themselves live in `pryne-change-control`; the variant-selection method the v3 lesson produced lives in `pryne-design-direction-decision`. This skill owns the narratives.

All facts date-stamped **as of 2026-07-22**. Repo: `~/Documents/Coding Folder/Portfolio (test)`.

## When NOT to use this skill

- Debugging a live bug → `pryne-browser-lab` (measure it) and systematic-debugging discipline.
- Deciding whether a NEW change is allowed → `pryne-change-control`.
- Running the v4 direction decision → `pryne-design-direction-decision`.
- This skill answers "has this been tried/decided before, and how did it end?"

## Demo lineage map (place any file you open)

| File | What it is | Status |
|---|---|---|
| `design-demos/1-cursor.html`, `2-ember.html`, `3-signal.html` | Three initial direction variants | Superseded by the Mix decision |
| `design-demos/portfolio-demo.html` | v1 — "Mix: Ember type × Signal structure" | Superseded |
| `design-demos/portfolio-demo-v2.html` | v2 — CARBON (premium dark, Geist, carmine accent, quiet automotive motifs; 2026-07-14) | Superseded as build target; aesthetic brief lives on |
| `design-demos/portfolio-demo-v3.html` | v3 — NIGHT DRIVE (automotive engine concept) | **Superseded 2026-07-15.** Reference only — see Entry 1 |
| `design-demos/v4-a-midnight-issue.html`, `v4-b-first-pressing.html`, `v4-c-ch001.html` | v4 direction candidates | Live decision — see `pryne-design-direction-decision` |
| `design-demos/v4-d-hybrid.html` | v4 — "ROLL 01" hybrid, the active build | **Current build target** (commits `1575051`→`457868a`) |

## Entry 1 — v3 NIGHT DRIVE supersession (the costliest lesson)

- **Period:** ~2026-07-14 → 2026-07-15.
- **What happened:** A complete, unified automotive-engine concept was built on top of v2 CARBON: launch-control hold-to-rev entry, velocity-driven canvas speed field, g-force type skew, HUD (live scroll-RPM tach, gear-per-section indicator, odometer), throttle-blip project hovers, headlight-beam cursor. It was verified working with zero console errors — and then superseded the next day because Pryne dropped the automotive organizing concept entirely in favor of a new unifying idea (which became v4).
- **Root cause:** Polish was invested before the organizing concept was validated with the owner. Technical success (zero errors, everything works) said nothing about whether the concept was right.
- **Evidence:** `design-demos/portfolio-demo-v3.html` (39 KB, dated Jul 14) exists but no v4 file builds on it; the v4 candidates all moved to non-automotive metaphors (print/darkroom/film for a/c/d, record/vinyl for b). The supersession date and verdict (2026-07-15, "kept as design-system/fallback-pattern reference") come from Pryne's project status log, corroborated by file dates — v3 untouched since Jul 14, v4 files created Jul 15.
- **Status:** v3 is kept as a design-system and fallback-pattern reference, **not** a build target. The automotive *organizing metaphor* is retired. Do not overgeneralize: quiet automotive *accents* from the CARBON personal-aesthetic brief remain legitimate — it is the engine-as-concept that is dead.
- **Rule produced:** Concept before polish. Direction changes are the most expensive class of change (see `pryne-change-control`); validate the organizing idea cheaply before building the full experience.

## Entry 2 — The Lenis saga (spec drift)

- **Period:** original spec → 2026-07-20.
- **What happened:** Lenis smooth-scroll was originally specced as "non-negotiable". The active v4-d build shipped without it, using native `html { scroll-behavior: smooth }`. Nobody recorded the removal decision, so the spec and the code silently disagreed. On 2026-07-20 Lenis was reintroduced deliberately: vendored (`design-demos/js/vendor/lenis.min.js`, not CDN — consistent with font self-hosting), gated behind `prefers-reduced-motion`, and timeboxed with an explicit fallback ("document why native smooth-scroll is sufficient and move on"). DECISIONS.md permitted "a minimal, isolated swap of `window.scrollY` reads" as the ceiling; in practice the shipped code needed **zero swaps** — native scrolling and `window.scrollY` stay real, Lenis only smooths the feel (see `pryne-motion-reference` for the integration facts).
- **Root cause:** A spec label ("non-negotiable") lived outside the repo with no in-repo decision record, so drift between spec and build went unnoticed.
- **Evidence:** commits `727c133` (Phase 0 decisions doc) and `457868a` (Phase 1 reintroduction); `design-demos/DECISIONS.md` section "Decision: Lenis smooth-scroll — reintroduce, scoped & timeboxed"; `design-demos/js/vendor/lenis.min.js`.
- **Status:** Reintroduction active and timeboxed as of 2026-07-22. If it produced disproportionate regressions, the documented fallback applies — check `DECISIONS.md` and git log for the outcome before assuming either way.
- **Rules produced:** Decision records live in the repo (`DECISIONS.md`), not only in external notes. "Non-negotiable" is falsifiable — re-verify labels against the running build. Timeboxed experiments state their fallback up front.

## Entry 3 — The v4 hybrid two-metaphor audit

- **Period:** v4 exploration → settled in current `v4-d-hybrid.html`.
- **What happened:** The original v4-d hybrid ran two unreconciled metaphors in parallel — Midnight Issue's darkroom entry plus Ch.001's panel grammar. A creativity audit forced a single bridging concept: a roll of film ("inherently both a sequence of frames AND something developed by hand"), with vocabulary unified around roll/frame/develop. The flourishes (shader, cursor, kinetic type, sound) were retrofitted to be facets of the develop mechanic instead of parallel premium-site checkboxes.
- **What the technical audit also caught (all fixed in v4-d):** develop-plates ticked from page load and finished resolving before anyone scrolled to them (fixed: gated on their panel's own visibility — flagged in the head comment as "the single highest-priority fix"); WebGL context now explicit-clears each frame with non-premultiplied alpha; custom cursor wrapped in try/catch so a setup failure can never leave the OS cursor hidden with no replacement; CDN scripts pinned with SRI hashes. Separately, v4-d *carries forward* (pre-existing, not caught by this audit) the "concept-C fix": clip-path reveals live on an inner wrapper, never on the element IntersectionObserver watches.
- **Root cause:** Hybridizing two winners by concatenation rather than by finding the bridge concept; effects animated on wall-clock time instead of visibility.
- **Evidence:** the head comment of `design-demos/v4-d-hybrid.html` (lines 1–30) documents the entire audit trail.
- **Status:** Settled. Don't reintroduce parallel metaphors, unconditional animation ticking, or clip-path on observed elements. Addendum 2026-07-22: a follow-up audit found and fixed a gap in the cursor fail-safe (the per-event path was unguarded; cursor z-index raised 50→70 above `#flash`) — details in `pryne-frontend-debugging` (cursor row).
- **Rule produced:** One organizing concept per build (also enforced by the CRITIQUE rubric's Restraint dimension, `design-demos/DECISIONS.md`).

## Entry 4 — Konami code rejected

- **What happened:** The easter-egg trigger was deliberately changed from a Konami code to a bespoke "develop" word trigger — type the site's own verb and every plate redevelops live.
- **Root cause of rejection:** Konami is "cliché, ubiquitous" (v4-d head comment); the egg should be on-brand, not a borrowed meme.
- **Evidence:** `design-demos/v4-d-hybrid.html` head comment; `design-demos/js/roll-eggs.js` lines 9–19 (the `devBuf === 'develop'` trigger).
- **Status:** Settled. Do not propose Konami codes or other stock meme triggers; eggs must pass the whisper-level personality rubric in `DECISIONS.md`.

## Adding a future entry

An investigation earns an entry when any of these happened:
- a **revert** or supersession of shipped/verified work,
- a **rejected fix or feature** that a future session might plausibly re-propose,
- a **spec/code contradiction** that took real time to untangle.

Routine bugs fixed on the first attempt do not earn entries. Use this template, newest entries higher:

```markdown
## Entry N — <name> (<one-phrase lesson>)
- **Period:** <dates>
- **What happened:** <2-4 sentences>
- **Root cause:** <one sentence — the decision failure, not just the technical fault>
- **Evidence:** <file paths / commit hashes / DECISIONS.md sections that still exist>
- **Status:** settled | retired | timeboxed-pending — and what a newcomer should NOT redo
- **Rule produced:** <one line; put the enforceable version in pryne-change-control>
```

## Provenance and maintenance

Run `scripts/verify.sh` (in this skill's directory) to check all of the below at once.

Written 2026-07-22 from repo state at commit `457868a`, plus owner-confirmed session context for vault-sourced facts (the v3 supersession date/verdict and the v2 CARBON date — these have no in-repo record). Re-verify before trusting:

- Lineage & status table: `ls ~/Documents/Coding\ Folder/Portfolio\ \(test\)/design-demos/*.html`
- Lenis entry: `cd ~/Documents/Coding\ Folder/Portfolio\ \(test\) && git log --oneline -5 && grep -n "Lenis" design-demos/DECISIONS.md`
- v4 audit entry: `head -30 ~/Documents/Coding\ Folder/Portfolio\ \(test\)/design-demos/v4-d-hybrid.html`
- Konami entry: `grep -n develop ~/Documents/Coding\ Folder/Portfolio\ \(test\)/design-demos/js/roll-eggs.js`
- Timeboxed items (Lenis outcome, v4 winner): check `git log` and `DECISIONS.md` for entries newer than 2026-07-20 — this file may be stale on those.
