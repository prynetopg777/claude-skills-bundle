---
name: skill-router
description: Use at the very START of every task or request, before planning or acting, to inventory the full skill arsenal (global, plugin, and project skills) and deliberately apply EVERY skill that contextually fits — not just the first obvious one. Invoke when the user says "use my skills", "check my arsenal", "use everything that fits", or whenever you might otherwise reach for a default approach without first surveying available skills.
---

# Skill Router — survey the whole arsenal, then act

The failure this prevents: grabbing the first skill that comes to mind (or none) and missing three others that also fit. This skill forces a deliberate, exhaustive match of the request against every available skill before work begins.

It does not replace `superpowers:using-superpowers` — that rule says *invoke relevant skills first*. This skill says *make sure you found ALL of them, and in the right order*.

## When to run

- At the start of any non-trivial request, before EnterPlanMode or the first edit.
- Whenever the user asks to "use my skills / arsenal / everything that fits".
- Re-run mid-task only if the task changes shape (e.g. a design task turns into a debugging task).

Skip for pure chit-chat or a one-line factual answer with no task in it.

## Procedure

1. **Enumerate the arsenal.** Read the current `system-reminder` skill listing already in context (global `~/.claude/skills/`, plugin skills like `ecc:*` / `pryne-*` / `vercel:*`, and any directory-scoped project skills). If the listing isn't in context, list `~/.claude/skills/` and the project's `.claude/skills/`. Treat the descriptions as the match keys.

2. **Extract the request's dimensions.** Name the concrete facets of what's being asked, e.g.: *process* (brainstorm / debug / plan / review), *domain* (frontend / backend / data / infra), *stack* (React / Python / vanilla-JS…), *artifact* (UI / animation / doc / test / deploy), *phase* (build / verify / ship).

3. **Match every dimension to skills.** For EACH dimension, find every skill whose description covers it — not just one. A single request usually touches several skills (e.g. a UI change → a design skill + a motion skill + a validation skill + a project-convention skill). Prefer the most specific applicable skill; keep a generic one only if it adds something the specific one doesn't.

4. **Order them: process before implementation.** Process/discipline skills (brainstorming, systematic-debugging, change-control, project-onboarding, validation) set the approach and run first. Implementation skills (design, motion, frontend, testing) carry it out. Note the sequence explicitly.

5. **Announce the plan, then execute.** State in one or two lines: "Applying: A (why), B (why), C (why)." Then invoke them in order via the Skill tool and follow each. If two skills conflict, the more specific / project-scoped one wins; say so.

6. **Prune, don't pile.** Restraint applies to skills too — list only skills that genuinely change what you'll do. A skill you'd name but not actually follow is noise; drop it. Better five that shape the work than fifteen for show.

## Anti-patterns

- Naming skills you don't then invoke or follow — routing theater.
- Stopping at the first match when the request is multi-dimensional.
- Skipping process skills and jumping straight to an implementation skill.
- Re-running the full survey on every tiny follow-up in the same task — survey once per task shape.

## Guaranteeing it fires on EVERY prompt

A skill is invoked when its description matches the request (or when called explicitly). For *unconditional* firing on every prompt regardless of match, a `UserPromptSubmit` hook is the only reliable mechanism — it injects a reminder the model can't skip. If you want that hard guarantee, use the `update-config` skill to add a one-line hook that echoes: "Run skill-router: survey all available skills and apply every one that fits before acting." Until then, this skill's broad description is what pulls it in.
