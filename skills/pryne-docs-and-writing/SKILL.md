---
name: pryne-docs-and-writing
description: Use when recording a decision, updating DECISIONS.md, writing or editing a demo's head comment, syncing project status to the Obsidian vault, or unsure where a piece of project documentation belongs in one of Pryne's repos.
---

# Pryne — Docs and Writing

Maintaining the docs of record across Pryne's projects: which surface a fact belongs on, the templates for each, and the house voice. Facts below verified against the Portfolio (test) repo as of 2026-07-22.

## When NOT to use this skill

- Deciding **whether** a change needs a decision record, or what gates it → `pryne-change-control` (this skill owns only formats and voice).
- Writing a commit message → personal skill `commit-message` (Conventional Commits) **where no repo style is established**. In a repo with an established non-Conventional history — e.g. Portfolio (test)'s sentence-style subjects ("Phase 1: …", "Baseline: …", "Add Phase 0 decisions doc: …") — match the existing style, and flag the mismatch to Pryne once in conversation rather than switching mid-repo.
- Authoring a new SKILL.md for this library → `superpowers:writing-skills`.
- Mechanical vault file operations → `obsidian:obsidian-cli`.

## The three documentation surfaces

One home per fact. Cross-reference from the other surfaces instead of duplicating.

| Surface | What lives there | What never lives there |
|---|---|---|
| **In-repo `DECISIONS.md`** (e.g. `design-demos/DECISIONS.md`) | Decisions with constraints, rubrics, checklists — anything an agent must re-apply while working in the repo; the decision entry for every direction change, reversal, or supersession | Status checkboxes, research links, inspiration narrative |
| **Demo head comment** (top-of-file HTML comment, every `design-demos/*.html`) | That file's design rationale, concept spine, scope notes, PLACEHOLDER inventory, audit changelog | Cross-demo decisions, rubrics, anything another file needs |
| **Obsidian vault project note** | Direction of record, status checklist (`- [x]` items), research/inspiration links | Constraints an agent needs mid-build (repo must carry its own record — `DECISIONS.md` exists precisely because status once lived only in the vault) |

Direction decisions and supersessions are recorded in **both** places, per `pryne-change-control` rule 4: the decision entry (with rationale and constraints) goes in `DECISIONS.md`, and the status/verdict checkbox goes in the vault. Neither alone is sufficient.

The vault is source of truth for **direction**; the repo is build output. The repo carries its own record for anything needed **during** a build session.

## DECISIONS.md entry template

Derived from the real Lenis entry (the file's first decision). Structure:

```markdown
## Decision: <thing> — <verdict, scoped>

<One paragraph of context. Name what contradicts what, plainly. State why now.>

Constraints on the <reintroduction/change/experiment>:
- <hard constraint, with its consistency rationale in-line>
- <hard constraint>
- Timeboxed: if <failure condition>, fall back to <documented alternative> and move on.
```

Worked example (verbatim from `design-demos/DECISIONS.md`):

```markdown
## Decision: Lenis smooth-scroll — reintroduce, scoped & timeboxed

Lenis was originally specced as "non-negotiable" but is absent from the current
active build (`v4-d-hybrid.html` uses native `scroll-behavior: smooth`).
Reintroducing it because `roll-scroll.js` is a scroll-linked choreography spine
(kinetic type, panel reveals, HUD sync) — exactly the case where raw
scroll-delta inconsistency across trackpad/wheel/touch is most visible, and
motion/interaction quality is a co-equal priority for this overhaul.

Constraints on the reintroduction:
- Self-hosted (vendored file), not CDN — consistent with the font self-hosting decision.
- Minimal, isolated swap of `window.scrollY` reads in the render loop — no restructuring of the spine.
- Gated behind `prefers-reduced-motion` exactly like the other modules.
- Timeboxed: if it produces disproportionate regressions after a focused session,
  fall back to documenting why native smooth-scroll is sufficient and move on.
```

Rules the example demonstrates:
- Verdict in the heading, em-dash-scoped, so the index is scannable.
- The contradiction stated outright ("specced as non-negotiable but is absent") — never smoothed over.
- Every constraint carries its rationale in the same line where one exists.
- Experiments always end with a timebox + named fallback.

Rubrics and checklists also live in this file (see the whisper-level rubric and the 1–5 CRITIQUE table there): anything that must be **re-run** is a checklist or a scoring table, not prose.

## Demo head-comment style

Every demo HTML file opens with an HTML comment before `<!DOCTYPE html>` (verified across `portfolio-demo-v2/-v3.html` and all four `v4-*.html`). It is the file's changelog and rationale, in narrative paragraphs:

1. **Identity line** — version, concept name, one-line premise ("Site = Issue 01 of a fashion/culture magazine…").
2. **Concept spine** — the unifying state/mechanic and its variables (`panel { beat, tone, aura }`).
3. **Scope note** — what this build deliberately is/isn't ("SCOPED-DOWN comparison build (…) — not the full section set").
4. **PLACEHOLDER inventory** — real vs. invented content, marked for future replacement, with a search token ("search \"PLACEHOLDER\"").
5. **Audit changelog** — appended paragraphs per audit, in "Per the <name> audit: <what changed and why>" form (see `v4-d-hybrid.html` for two such paragraphs, creativity + technical).

**Update the head comment whenever you make a structural change to the demo.** A change with no head-comment paragraph explaining it is undocumented.

## House voice

Observable across the corpus, matching Pryne's global AGENTS.md preferences:

- Short and specific; bullets over paragraphs; no filler, no throat-clearing.
- State contradictions plainly and name both sides ("X was specced as non-negotiable but is absent from the active build").
- Verdicts are em-dash-scoped and qualified exactly as far as the evidence goes ("reintroduce, scoped & timeboxed" — never bare "yes").
- Anything that must be re-verified or re-run becomes a checklist (`- [ ]`) or a scoring table, never prose instructions.
- Parenthetical file/symbol references inline (`roll-scroll.js`), backticked.
- No oversell: unproven things stay labeled placeholder/candidate/open.

## Vault sync discipline

After any direction or status change (demo superseded, decision taken, phase completed): update the vault project note's status checklist **the same session** — via `obsidian:obsidian-cli`, or by telling Pryne explicitly that the vault needs the update. A repo-only record leaves the source of truth stale; a vault-only record repeats the failure `DECISIONS.md` exists to prevent (v3's supersession predates `DECISIONS.md` and so has no in-repo record — exactly the gap rule 4 closes). Both surfaces, same session.

## Writing for agents (this library included)

- Date-stamp volatile facts ("as of 2026-07-22"); a stale-looking date is a feature, not a bug — it prompts re-verification.
- One home per fact; cross-reference by skill/file name elsewhere.
- Every skill in this library ends with a Provenance and maintenance section of one-line re-verification commands; when you change a fact a skill states, re-run that skill's commands and update it.
- New skills: follow `superpowers:writing-skills` (trigger-rich description, no workflow summary in frontmatter).

## Provenance and maintenance

Run `scripts/verify.sh` (in this skill's directory) to check all of the below at once.

Verified 2026-07-22 against Portfolio (test) @ 457868a. Re-verify:

- DECISIONS.md exists and entry format unchanged: `sed -n '1,40p' "design-demos/DECISIONS.md"`
- Head-comment convention still holds: `for f in design-demos/*.html; do head -3 "$f"; done`
- Commit style in history: `git log --oneline -10`
- Vault still source of truth / status-checklist convention: check the session-start Obsidian context block, or `obsidian:obsidian-cli` search for the project note.
