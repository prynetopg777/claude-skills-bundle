---
name: pryne-validation-and-qa
description: Use when about to claim a design or code change is done, improved, or working in one of Pryne's projects; when scoring a section after a visual or motion change; when deciding whether evidence (screenshots, console output, Lighthouse scores, rubric scores) is sufficient to accept work; or when someone proposes accepting a change "because it looks good".
---

# Validation & QA — what counts as evidence

Core principle: **success is never judged by eye.** A claim of improvement needs a rubric score or a measurement — not adjectives. This skill defines Pryne's evidence bar, acceptance thresholds, and the working loop that produces them.

- **HOW to measure** (commands, MCP recipes, servers) lives in **pryne-browser-lab** — this skill only says WHAT must be measured.
- The generic evidence-before-claims discipline is **superpowers:verification-before-completion** — read it; this skill adds the project-specific bar on top.
- Choosing BETWEEN design variants is **pryne-design-direction-decision**. Whether a change is ALLOWED at all is **pryne-change-control**.

## When NOT to use this skill

- Picking a winner among competing design directions → **pryne-design-direction-decision**.
- Looking up the measurement commands themselves → **pryne-browser-lab**.
- Classifying/gating a change before building it → **pryne-change-control**.
- Writing up results → **pryne-docs-and-writing**.

## The working loop: BUILD → RUN → CRITIQUE → AUDIT → FIX

This is the project's established loop (named in `design-demos/DECISIONS.md`). Every meaningful change to a section goes through it.

| Stage | What it is |
|---|---|
| **BUILD** | Make the change. Smallest coherent unit — one section or one module. |
| **RUN** | Load the page in a real browser and exercise the change. Use the recipes in **pryne-browser-lab** (local server, console capture, screenshots). |
| **CRITIQUE** | Score the touched section(s) on the 5-dimension rubric below, 1–5 per dimension. |
| **AUDIT** | Measure: console errors, Lighthouse, reduced-motion pass, breakpoint screenshots — per **pryne-browser-lab**. |
| **FIX** | Address what CRITIQUE/AUDIT surfaced; re-enter the loop until thresholds hold. |

## CRITIQUE rubric (score 1–5 per dimension, per section)

From `design-demos/DECISIONS.md`, as of 2026-07-22. Benchmarked against the 4 analyzed reference sites: **PX Push, Cult, TRIONN, Lando Norris**. Run this scoring **after every meaningful change to a section**.

| Dimension | What "5" looks like |
|---|---|
| Craft | Typography, spacing, color, and detail execution read as intentional at every breakpoint — nothing feels like a placeholder or default. |
| Motion/interaction | Choreography feels physically coherent (consistent easing/timing language) and at least one interaction is genuinely novel, not a stock pattern. |
| Storytelling | Case studies read as a real problem→decision→outcome narrative, not a feature list; copy has a point of view. |
| Restraint | One organizing concept, one accent color discipline, no decorative filler ("data slop", icon slop, gradient slop). |
| Performance | Zero console errors, Lighthouse perf ≥90 / a11y ≥95, feels instant on interaction. |

Record scores as numbers per dimension (e.g. `Hero: Craft 4, Motion 3, Story 4, Restraint 5, Perf 5`). A score without a one-line justification is not evidence.

## Hard acceptance thresholds

A change is not accepted until ALL of these hold (thresholds from the rubric's Performance row):

- [ ] **Zero console errors** on load and during interaction.
- [ ] **Lighthouse performance ≥ 90.**
- [ ] **Lighthouse accessibility ≥ 95.**
- [ ] Feels **instant on interaction** (no visible lag on hover/click/scroll response).

Standing evidence bar on top of the thresholds:

- [ ] **Breakpoint screenshot matrix** — any visual claim ships with mobile AND desktop screenshots of the affected section.
- [ ] **Reduced-motion pass** — any motion change is re-run with `prefers-reduced-motion: reduce` emulated; the page must remain fully usable and readable.
- [ ] No "looks better", "feels smoother", "much cleaner" without an attached rubric delta or measurement.

## Whisper-level personality check (every section, every new element)

**pryne-change-control** owns this rubric's status as a non-negotiable; this skill owns *running* it. From `design-demos/DECISIONS.md`: the personality layer (dark academia × streetwear, K-fashion/editorial, indie nightlife; music/gaming/anime references) must never be visible without a deliberate interaction. Checklist for every section and every new element:

- [ ] Nothing personality-coded appears in nav, hero copy, section headers, or any element visible on a cold, zero-interaction screenshot.
- [ ] Every personality reference lives behind a deliberate trigger (hover-hold, long-press, `roll-eggs.js` word-trigger, negative-view hold) — never a passive/ambient element.
- [ ] A first-time viewer with zero context reads the site as a premium, professional software product, full stop.
- [ ] Only someone who already shares the specific interest would recognize a reference as a reference, not as decoration.

The cold zero-interaction screenshot from the breakpoint matrix doubles as the evidence artifact for item 1.

## Certified/golden inventory (as of 2026-07-22)

Honest state: **there is no automated test suite.** That is a known gap; adding a test harness is an open candidate, not an assumed fact — do not invent or reference tests that don't exist.

What exists as reference evidence, all in `design-demos/`:

- **v1 demo set**: `demo-desktop-full.png`, `demo-desktop-hero.png`, `demo-interact.png`, `demo-mobile-full.png`
- **v2 CARBON set**: `v2-desktop-hero.png`, `v2-desktop-work.png`, `v2-desktop-spec.png`, `v2-desktop-contact.png`, `v2-mobile-hero.png`, `v2-mobile-spec.png`
- **v3 NIGHT DRIVE set**: `v3-hero.png`, `v3-launch-rev.png`, `v3-speed.png`, `v3-beam.png`, `v3-finish.png`, `v3-mobile.png`
- **Direction thumbnails**: `1-cursor.png`, `2-ember.png`, `3-signal.png`
- **v3's verified state**: zero console errors at time of verification (2026-07-15) — the precedent for the console-zero threshold. Note v3 was later superseded on direction (see **pryne-failure-archaeology**): passing every measurement does not certify a *direction*.

New artifacts follow the canonical naming convention owned by **pryne-browser-lab**: `<version>-<breakpoint-or-subject>.png`.

## Adding evidence for something new

1. State the measurable claim before building ("Lighthouse perf stays ≥90 with the shader on", "section scores Restraint ≥4").
2. Pick the measurement recipe from **pryne-browser-lab**.
3. Capture the artifact into `design-demos/`, named per the convention in **pryne-browser-lab**.
4. Score the touched section on the CRITIQUE rubric; run the whisper checklist.
5. Record the result in `design-demos/DECISIONS.md` per **pryne-docs-and-writing**.

## Provenance and maintenance

Run `scripts/verify.sh` (in this skill's directory) to check all of the below at once.

Facts sourced from repo `~/Documents/Coding Folder/Portfolio (test)` on 2026-07-22. Re-verify before trusting:

- Rubrics still current: `cat "$HOME/Documents/Coding Folder/Portfolio (test)/design-demos/DECISIONS.md"`
- Golden screenshot inventory: `ls "$HOME/Documents/Coding Folder/Portfolio (test)/design-demos/" | grep '\.png$'`
- Still no test suite (expect no matches): `ls "$HOME/Documents/Coding Folder/Portfolio (test)" | grep -iE 'test|package.json'`
