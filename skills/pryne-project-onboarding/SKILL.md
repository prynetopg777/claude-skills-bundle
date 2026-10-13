---
name: pryne-project-onboarding
description: Use when opening any of Pryne's repos for the first time in a session, when unsure what the current build target or project status is, when repo files and session context seem to disagree, or before making any change in a repo you have not worked in during this session.
---

# Pryne Project Onboarding

The first-30-minutes runbook for entering one of Pryne's repos. This is the **Pryne-specific delta** on top of generic repo reconnaissance — for analyzing an unfamiliar third-party codebase's stack and structure, use `ecc:codebase-onboarding`; use this skill for the conventions that generic reconnaissance will not find.

**When NOT to use this skill:** a repo that is not Pryne's (client work, OSS clone, third-party audit) → `ecc:codebase-onboarding` alone. Already onboarded this session and just need a specific answer → go straight to the sibling that owns it (see cross-reference table at the end).

## 1. The source-of-truth convention (read this first)

Pryne's projects keep **design direction, status, and research in an Obsidian vault folder named after the project**. The repo is build output. A SessionStart hook injects the vault's project note into Claude sessions — look for it near the top of the session under a heading like "Obsidian project context".

| Disagreement | Winner |
|---|---|
| Direction, status, "what are we building" — repo vs. vault/session context | **Vault** |
| Code facts — what a file contains, what a command does | **Code** (verify by reading/running) |

Corollary: if you change direction or status during a session (pick a variant, retire a concept, finish a milestone), that change **must be reflected back to the vault** — use the `obsidian:obsidian-cli` skill if available, or tell Pryne explicitly so they update it. A repo-only record of a direction change will be lost to the next session.

Do not hardcode vault paths in scripts or docs; the vault location is injected per-session and is Pryne's private machine layout.

## 2. Repo conventions to look for

Each convention below is verified in the Portfolio repo (`~/Documents/Coding Folder/Portfolio (test)`) as the worked example, as of 2026-07-22. Expect the same shapes in other Pryne repos; verify before relying.

| Convention | What it looks like | Worked example |
|---|---|---|
| In-repo decision record | `DECISIONS.md` near the work it governs — decisions, rationale, rubrics | `design-demos/DECISIONS.md` (Lenis reintroduction decision, whisper-level personality rubric, 5-dimension CRITIQUE rubric) |
| Vendored community skills | `skills-lock.json` at repo root pins source + hash; skill contents mirrored into **both** `.claude/skills/` and `.agents/skills/` | `design-dna` (zanwei/design-dna), `motion-design` (LottieFiles/motion-design-skill) |
| Browser-session artifact dump | `.playwright-mcp/` holds console logs + page snapshots from MCP browser sessions; **gitignored** | `.gitignore` lists `.DS_Store` and `.playwright-mcp/` |
| Self-contained demos | Design demos are single-file HTML in `design-demos/`; shared JS modules in `design-demos/js/` are used **only by the active build** — comparison variants are fully self-contained inline builds | Only `v4-d-hybrid.html` loads `js/roll-*.js`; `v4-a/b/c` are inline (verified by grep) |
| Vendored third-party JS | No CDN as a load-bearing dependency; libraries live in `js/vendor/` (see `pryne-change-control` for the rule and its rationale) | `design-demos/js/vendor/lenis.min.js` |

## 3. First-30-minutes checklist

Run from the repo root. Commands verified against the Portfolio repo as of 2026-07-22.

1. **Read the injected vault context** (top of session, if present). Note stated direction, status checkboxes, and anything marked "superseded".
2. **Recent history** — what changed, what the commit messages claim:
   ```bash
   git log --oneline -15 && git status
   ```
3. **Find and read every decision record:**
   ```bash
   find . -name "DECISIONS.md" -not -path "./node_modules/*" -not -path "./.git/*"
   ```
   Decisions there are binding until superseded — do not re-litigate them (see `pryne-change-control`).
4. **Check the failure chronicle** — load `pryne-failure-archaeology` and scan for settled battles relevant to your task before proposing anything that resembles a past dead end.
5. **Identify the current build target.** As of 2026-07-22 in the Portfolio repo: **`design-demos/v4-d-hybrid.html` ("ROLL 01")** is the active build; `v4-a-midnight-issue.html`, `v4-b-first-pressing.html`, `v4-c-ch001.html` are competing variants; `portfolio-demo.html` (v1) and `-v2` (CARBON) are superseded; `-v3` (NIGHT DRIVE) is additionally kept as a design-system/fallback-pattern reference (that verdict is v3-specific — see `pryne-failure-archaeology`).
6. **Check the vendoring state:**
   ```bash
   cat skills-lock.json 2>/dev/null; ls design-demos/js/vendor/ 2>/dev/null
   ```
7. **Only then** open the code. For the module architecture of the active build, load `pryne-frontend-architecture`; to run and measure it, `pryne-browser-lab`.

## 4. Portfolio project snapshot (dated — re-verify before relying)

As of **2026-07-22**:

| Item | State |
|---|---|
| Hardest live problem | Choosing/finalizing the v4 design direction (four variants, no committed winner) — campaign runbook: `pryne-design-direction-decision` |
| Smooth scroll | Lenis reintroduced, vendored + `prefers-reduced-motion`-gated, per commit `457868a`; scoped and timeboxed per `design-demos/DECISIONS.md` |
| Content | Bio, case studies, links still placeholder — real content pending |
| Git state | 3 commits on `master`, clean tree |

## 5. Pryne's global preferences (apply in every repo)

Source: `~/AGENTS.md` (global agent instructions), summarized:

| Area | Rule |
|---|---|
| Communication | Short, focused, bullets over paragraphs; ask instead of assuming intent |
| TypeScript | Strict mode, no `any` |
| Before creating | Check for existing utilities/components/duplicates first |
| CSS | Design tokens / CSS vars only — never hardcode colors or sizes |
| Typography/spacing | Prefer `clamp()` for fluid values |
| Layout | Always consider mobile AND desktop |

## Sibling cross-reference

| Need | Skill |
|---|---|
| What changes are gated, non-negotiables + rationale | `pryne-change-control` |
| Module contract of the active build | `pryne-frontend-architecture` |
| Serve, screenshot, trace, audit the demo | `pryne-browser-lab` |
| A bug or unexpected behavior | `pryne-frontend-debugging` |
| What counts as evidence / done | `pryne-validation-and-qa` |
| Picking between design variants | `pryne-design-direction-decision` |
| Past dead ends and settled battles | `pryne-failure-archaeology` |
| Writing DECISIONS.md entries, vault sync, house style | `pryne-docs-and-writing` |
| Scroll/motion domain theory as applied here | `pryne-motion-reference` |

## Provenance and maintenance

Run `scripts/verify.sh` (in this skill's directory) to check all of the below at once.

Verified 2026-07-22 against `~/Documents/Coding Folder/Portfolio (test)`: repo tree, `.gitignore` contents, `skills-lock.json` contents, `design-demos/js/vendor/` contents, `design-demos/DECISIONS.md` contents, git log (3 commits, head `457868a`), v4 variant filenames, `~/AGENTS.md` preference list, SessionStart vault-context injection observed live in-session.

Re-verify volatile facts:
- Current build target + variants: `ls "$HOME/Documents/Coding Folder/Portfolio (test)/design-demos/"*.html`
- Git state: `git -C "$HOME/Documents/Coding Folder/Portfolio (test)" log --oneline -5`
- Vendored skills: `cat "$HOME/Documents/Coding Folder/Portfolio (test)/skills-lock.json"`
- Decision record: `cat "$HOME/Documents/Coding Folder/Portfolio (test)/design-demos/DECISIONS.md"`
- Global prefs: `cat ~/AGENTS.md`
