---
name: pryne-change-control
description: Use when about to modify, add, or remove anything in one of Pryne's repos — before editing code, copy, styles, motion, dependencies, or design direction; when deciding whether a change needs sign-off; when tempted to add a CDN dependency or surface a personality reference; or when a spec labeled "non-negotiable" seems wrong.
---

# Pryne Change Control

How changes are classified and gated in Pryne's projects, and the standing rules with the incident behind each. The projects are small (often single-file static demos), so the gates are discipline, not bureaucracy: each one exists because skipping it already cost real time once.

**Jargon:** "DECISIONS.md" = the in-repo decision log (e.g. `design-demos/DECISIONS.md` in Portfolio). "Organizing concept" = the single metaphor a design is built around (e.g. ROLL 01's roll-of-film). "Whisper-level" = personality references invisible until deliberately triggered.

## When NOT to use this skill

- Entering a repo cold for the first time → **pryne-project-onboarding**
- Deciding *between design variants* (not gating a change) → **pryne-design-direction-decision**
- Wondering if an approach was already tried and rejected → **pryne-failure-archaeology**
- Writing the decision record itself → **pryne-docs-and-writing**
- Generic "verify before claiming done" discipline → **superpowers:verification-before-completion**

## Change classes and their gates

Classify every change before making it. When a change spans classes, apply the highest gate.

| Class | Examples | Gate before it counts as done |
|---|---|---|
| **1. Content/copy** | Bio text, case-study copy, meta tags | Whisper-level checklist (below); cold-screenshot check if visible text changed |
| **2. Visual polish** | Spacing, color, type tweaks within the current direction | Validation pass per **pryne-validation-and-qa** (console-zero + breakpoint screenshots) |
| **3. Motion/interaction** | New animation, scroll choreography, hover behavior | Class 2 gate + reduced-motion gating verified + rubric score per **pryne-validation-and-qa** |
| **4. Architectural** | Touching the module spine, load order, shared state, adding/swapping a dependency | Class 3 gate + conforms to **pryne-frontend-architecture** contract + DECISIONS.md entry for anything a future session would ask "why?" about |
| **5. Direction/concept** | Changing or replacing the organizing concept | **Explicit sign-off from Pryne. Never autonomous.** Run **pryne-design-direction-decision**; record in DECISIONS.md |

Class 5 is the most expensive class in this project's history: v3 NIGHT DRIVE was fully built and verified working (zero console errors), then superseded on 2026-07-15 because the organizing concept itself was wrong — all polish was sunk cost. Full story: **pryne-failure-archaeology**. Corollary: validate the concept *before* polishing (gate 5 before gates 2–3).

## Non-negotiables

Each rule states its rationale and the incident that created it. "Non-negotiable" means *you don't waive it silently* — see the last rule for how they legitimately change.

### 1. Vendor-first dependencies (self-host over CDN)

**Rule:** New runtime dependencies are vendored into the repo (e.g. `design-demos/js/vendor/lenis.min.js`), not loaded from a CDN. Never add an npm/build-step dependency to a static-demo project.
**Rationale:** DECISIONS.md, on Lenis: "Self-hosted (vendored file), not CDN — consistent with the font self-hosting decision."
**Sanctioned exception pattern** (the only acceptable CDN shape, modeled by the existing GSAP tag in `v4-d-hybrid.html:440`): exact pinned version + SRI integrity hash (Subresource Integrity — the browser refuses the script if its hash doesn't match) + `async` + graceful absence (page fully works if the script never loads; GSAP upgrades motion via `Roll.upgradeMotion` only when present).
**Known drift, as of 2026-07-22:** `v4-d-hybrid.html` still loads Google Fonts from `fonts.googleapis.com` (lines 40–41) and GSAP from jsdelivr. Font self-hosting is decided but not yet executed. Don't cite this drift as precedent for new CDN deps. Fixing it is welcome but is its **own class-4 change with its own DECISIONS.md entry** — never a silent rider on unrelated work in the same file.

### 2. Whisper-level personality gating (invariant, not preference)

**Rule:** The personality layer (fashion/music/gaming/anime references) must never be visible without a deliberate interaction — e.g. "Nothing personality-coded appears in nav, hero copy, section headers, or any element visible on a cold, zero-interaction screenshot" (first item of the checklist). Full runnable checklist: **pryne-validation-and-qa** (text of record: `design-demos/DECISIONS.md`).

Run that checklist for **every section and every new element** in classes 1–3. A violation is a blocking defect, same severity as a console error.

### 3. Reduced-motion gating

**Rule:** Every motion module gates behind `prefers-reduced-motion`. The shared flag is `Roll.reduced` (`design-demos/js/roll-core.js:9`); new motion code reads it, never re-queries ad hoc. Details of the module contract: **pryne-frontend-architecture**.

### 4. Decisions of record live in the repo

**Rule:** Any decision a future session would need (a rule, a reversal, a timebox, a rubric) goes in the repo's DECISIONS.md — format owned by **pryne-docs-and-writing**.
**Incident:** DECISIONS.md itself opens by admitting the failure mode: "Previously all status lived only in the Obsidian vault; this file exists so the repo carries its own record." A repo you can't reconstruct decisions from inside the repo is broken for agents.

### 5. "Non-negotiable" specs are still falsifiable — but only in writing

**Rule:** A standing rule may be suspended or reversed, but only via a DECISIONS.md entry stating scope, rationale, and — for reintroductions and experiments — a **timebox and a written fallback before starting**.
**Incident:** Lenis smooth-scroll was originally specced "non-negotiable," then dropped (native `scroll-behavior: smooth` shipped instead), then reintroduced — correctly this time: scoped, vendored, reduced-motion gated, and timeboxed with an explicit fallback ("if it produces disproportionate regressions after a focused session, fall back to documenting why native smooth-scroll is sufficient and move on" — DECISIONS.md). That entry is the template for every future rule change.

## Before you change anything — checklist

1. Read the repo's DECISIONS.md end to end (it's short).
2. Check **pryne-failure-archaeology** — is your idea a settled battle?
3. Classify the change (table above); note the gate you'll owe.
4. Class 4–5, or any rule suspension → draft the DECISIONS.md entry (or get sign-off) *before* building.
5. After building: gate per class; claim done only with evidence (**pryne-validation-and-qa**, **superpowers:verification-before-completion**).

## Escalation rule

Agents never autonomously: change the organizing concept or design direction (class 5), waive a non-negotiable, delete a decision record, or publish/deploy anything outward-facing. All four require explicit sign-off from Pryne in the current session. When in doubt whether a change is class 4 or 5: it's 5.

## Provenance and maintenance

Run `scripts/verify.sh` (in this skill's directory) to check all of the below at once.

Verified 2026-07-22 against the Portfolio (test) repo: DECISIONS.md quotes; `Roll.reduced` at roll-core.js:9; Google Fonts links at v4-d-hybrid.html:47–48; GSAP CDN tag with SRI at v4-d-hybrid.html:440; vendored `js/vendor/lenis.min.js`; git log (3 commits, ROLL 01 era). The v3 NIGHT DRIVE supersession (2026-07-15) comes from the project status log, not git — see pryne-failure-archaeology for sourcing.

Re-verify before relying on volatile facts:

```bash
cd "$REPO" && cat design-demos/DECISIONS.md                                  # rules/rubrics current?
grep -n "prefers-reduced-motion" design-demos/js/roll-core.js                # flag still at core
grep -n "fonts.googleapis.com\|cdn.jsdelivr" design-demos/*.html             # CDN drift status
ls design-demos/js/vendor/                                                   # what's vendored now
```

If font self-hosting has been executed or DECISIONS.md has moved/grown, update the "known drift" note above.
