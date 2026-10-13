# Pryne's Claude Code Setup — Full Manifest

> **For the reader (Claude):** this describes a complete Claude Code configuration so it can
> be replicated. If `install.sh` in this repo has already been run, §1 and §2 are done — skip
> to §3 for the optional config (MCP servers, permission mode) that the installer does not
> touch. If you are replicating by hand, work top to bottom.
>
> Snapshot: 2026-10-13, from `~/.claude/settings.json` + `~/.claude/plugins/installed_plugins.json`.
> Claude Code 2.1.296.

---

## 1. Plugins — 8 enabled

`install.sh` does all of this. The equivalent by hand, using the `claude` CLI:

```bash
claude plugin marketplace add https://github.com/affaan-m/ECC.git
claude plugin marketplace add kepano/obsidian-skills
claude plugin marketplace add DietrichGebert/ponytail
claude plugin marketplace add anthropics/skills
claude plugin marketplace add greensock/gsap-skills
claude plugin marketplace add AThevon/genjutsu
# claude-plugins-official is built in — no need to add it

claude plugin install superpowers@claude-plugins-official -y
claude plugin install vercel@claude-plugins-official -y
claude plugin install ecc@ecc -y
claude plugin install obsidian@obsidian-skills -y
claude plugin install ponytail@ponytail -y
claude plugin install document-skills@anthropic-agent-skills -y
claude plugin install gsap-skills@gsap-skills -y
claude plugin install genjutsu@genjutsu -y
```

The same commands work as `/plugin install ...` slash commands inside a session.

| Plugin | Version | Source | What it adds |
|---|---|---|---|
| `superpowers` | 6.4.1 | built-in | 14 process-discipline skills: `brainstorming`, `systematic-debugging`, `test-driven-development`, `writing-plans`, `executing-plans`, `requesting-code-review`, `verification-before-completion`, `using-git-worktrees`, `writing-skills`, `subagent-driven-development`. **The backbone** — establishes "invoke a relevant skill before responding". |
| `ecc` | 2.0.0 | [affaan-m/ECC](https://github.com/affaan-m/ECC) | The big one: **262 skills, 64 agents, 84 commands**. Per-language reviewers and build-resolvers (TS, Python, Go, Rust, Swift, Kotlin, C++, Java, PHP, Dart/Flutter), orchestration pipelines (`orch-*`), GAN build/design loops, hookify, security/a11y/perf agents. |
| `vercel` | 0.50.0 | built-in | 30 skills, 3 agents, 5 commands. Next.js App Router, AI SDK, AI Gateway, Fluid Compute, deployments, `vercel env`, caching, marketplace integrations. |
| `ponytail` | 4.4.0 | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) | 5 skills. A "lazy senior developer" behavior layer — YAGNI ladder, shortest-working-diff bias. Installs its own `SessionStart` hook, so it is **active on every response** once installed. Uninstall or `/ponytail` to change level if you don't want that. |
| `document-skills` | `dbd4588f` | [anthropics/skills](https://github.com/anthropics/skills) | `docx`, `pptx`, `xlsx`, `pdf` — real Office/PDF generation and editing. |
| `gsap-skills` | 1.0.0 | [greensock/gsap-skills](https://github.com/greensock/gsap-skills) | 8 skills: `gsap-core`, `gsap-timeline`, `gsap-scrolltrigger`, `gsap-plugins`, `gsap-react`, `gsap-frameworks`, `gsap-performance`, `gsap-utils`. |
| `obsidian` | 1.0.1 | [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) | 5 skills: `obsidian-cli`, `obsidian-markdown`, `obsidian-bases`, `json-canvas`, `defuddle`. Only useful with an actual Obsidian vault. |
| `genjutsu` | 3.0.1 | [AThevon/genjutsu](https://github.com/AThevon/genjutsu) | 3 skills: `cast`, `paint`. Visual/creative generation. |

### Installed but deliberately disabled

In Pryne's cache with `enabledPlugins: false`. Listed so the omission reads as intentional —
don't install unless you want them.

```
andrej-karpathy-skills@karpathy-skills       (forrestchang/andrej-karpathy-skills)
minimalist-entrepreneur@minimalist-entrepreneur   (slavingia/skills)
bmad@bmad-method                             (PabloLION/bmad-plugin)
example-skills@anthropic-agent-skills
```

---

## 2. Personal skills — 11, shipped in `skills/` here

No marketplace exists for these; they are plain folders, each with a `SKILL.md`. Claude Code
discovers anything in `~/.claude/skills/` at session start — no registration step.

```bash
cp -R skills/* ~/.claude/skills/     # what install.sh does, with backups
```

### 2a. Start here

| Skill | Purpose |
|---|---|
| `skill-router` | **The keystone.** Forces a survey of *every* available skill at the start of a task rather than grabbing the first match: enumerate the arsenal, extract the request's dimensions, match each one, order process-before-implementation, then prune to the skills that genuinely change the work. Paired with the hook in §3a so it fires on every prompt. |

### 2b. The `pryne-*` library — 10 process skills

Four of these are **gates** (run before an action); six are **references** (consulted during).

| Skill | Kind | Purpose |
|---|---|---|
| `pryne-project-onboarding` | gate | Read first in an unfamiliar repo. Establishes current build target and status before any change; resolves repo-vs-context disagreements. |
| `pryne-change-control` | gate | Before modifying/adding/removing anything — code, copy, styles, motion, deps, design direction. Decides what needs sign-off; blocks casual CDN dependencies. |
| `pryne-validation-and-qa` | gate | Before claiming anything is done, improved, or working. Defines what counts as sufficient evidence (screenshots, console output, Lighthouse, rubric scores) and rejects "it looks good" as an acceptance criterion. |
| `pryne-failure-archaeology` | gate | Before re-litigating a past decision — why a library/concept/easter-egg/architecture was abandoned, and whether an old demo file is a live build target or a relic. |
| `pryne-design-direction-decision` | gate | When several built variants exist and one must win. Forces scoring all siblings instead of polishing a favorite. |
| `pryne-frontend-architecture` | ref | Where new interactive JS belongs in a vanilla-JS build: script order, reduced-motion gating, progressive enhancement, CSS design tokens. |
| `pryne-frontend-debugging` | ref | Symptom-indexed debugging: animations firing before their section is visible, clipped reveals, vanished OS cursor, WebGL ghosting/blending, dead scroll choreography, motion dead for one user, silent audio. |
| `pryne-motion-reference` | ref | Domain theory for scroll-linked animation, Lenis smooth-scroll, scroll velocity, WebGL/canvas grain shaders, kinetic type, reduced-motion gating, easing choice. Defines in-house terms like "choreography spine" and "develop plate". |
| `pryne-browser-lab` | ref | Measuring a demo in a real browser: serve locally, capture console, breakpoint screenshots, perf traces, Lighthouse, reduced-motion emulation. Also the canonical screenshot-naming convention. **Needs the chrome-devtools MCP server (§3c).** |
| `pryne-docs-and-writing` | ref | Where documentation belongs — `DECISIONS.md`, demo head comments, Obsidian vault sync. |

> **Portability.** These name real conventions from their author's repos — `design-demos/*.html`,
> `js/roll-*.js`, `window.Roll` IIFE modules, `DECISIONS.md`, `v4-d-hybrid.html`, CSS tokens
> `--ease-out` / `--ease-snap`. Machine-specific absolute paths were replaced with
> `$PROJECT_ROOT`, but the *file* references are intact and will not resolve in your projects.
> Some skills ship a `scripts/verify.sh` that asserts specific lines in specific files; those
> will fail outside the original repo. The discipline transfers; the paths don't.

### 2c. Not included — third party

`huashu-design` (花叔Design) — hi-fi HTML prototyping, interactive/animation demos,
design-variant exploration, 5-dimension design review, MP4/GIF export, anti-"AI-slop" rules.
Primarily Chinese-language. Not redistributed here: it's
[alchaincyf/huashu-design](https://github.com/alchaincyf/huashu-design), carries its own
LICENSE, and bundles ~62MB of audio.

```bash
./install.sh --with-huashu
# or: git clone --depth 1 https://github.com/alchaincyf/huashu-design.git ~/.claude/skills/huashu-design
```

### 2d. Project-scoped skills

These live in a **repo** at `.claude/skills/`, not in `~/.claude/`, and travel with the
project rather than the user. Pryne's portfolio repo carries two — noted for completeness,
not shipped here:

- `design-dna` — extract/define/apply design DNA across three dimensions: system tokens, qualitative style, and visual effects (Canvas/WebGL/3D/particles/shaders/scroll).
- `motion-design` — motion principles: timing, easing, choreography, Disney principles adapted for UI. Stack-agnostic (CSS, Framer Motion, GSAP, Lottie, Spring).

### 2e. On disk but switched off

Disabled via `skillOverrides`, mostly because `ecc` and the plugin skills cover the same
ground better. Not shipped:

```
ui-ux-pro-max  design  banner-design  ui-styling  brand  code-review
slides  emil-design-eng  design-system  commit-message  review-animations
```

To replicate the off-switches (only needed if you have skills by those names):

```json
"skillOverrides": {
  "ui-ux-pro-max": "off", "design": "off", "banner-design": "off",
  "ui-styling": "off", "brand": "off", "code-review": "off",
  "slides": "off", "emil-design-eng": "off", "design-system": "off",
  "commit-message": "off", "review-animations": "off"
}
```

---

## 3. Config — what makes it behave this way

Without §3a the skills are installed but largely inert.

### 3a. The skill-router hook — `install.sh` adds this

A skill normally loads only when its description matches the request. A `UserPromptSubmit`
hook is the only mechanism that fires unconditionally on every prompt.

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "printf '{\"hookSpecificOutput\":{\"hookEventName\":\"UserPromptSubmit\",\"additionalContext\":\"Reminder: invoke the skill-router skill first — survey the full skill arsenal (global, plugin, project) and apply every skill that fits before acting.\"}}'"
          }
        ]
      }
    ]
  }
}
```

`ponytail` and `vercel` register their own `SessionStart` hooks on install — that's how
ponytail stays active across every response. Pryne also runs a personal
`~/.claude/hooks/obsidian-context.sh` at session start to inject vault context; not
reproduced here, since it depends on his vault.

### 3b. MCP servers — installer does NOT configure these

| Server | Why | Needed by |
|---|---|---|
| `chrome-devtools` | Browser automation, Lighthouse, perf traces, console + network inspection | **`pryne-browser-lab`** — that skill is inert without it |
| `context7` | Live library/framework documentation lookup | `ecc:docs-lookup`, any "how do I use X" question |
| `time` | Current time, timezone conversion | occasional |

Add with `claude mcp add`, or via `/mcp` in a session.

### 3c. Remaining settings

```json
{ "model": "opus", "theme": "dark", "permissions": { "defaultMode": "auto" } }
```

⚠️ `defaultMode: "auto"` runs tools without prompting far more often than the default.
Decide for yourself rather than copying it — it is a meaningful reduction in confirmation
friction, and in oversight.

---

## 4. Verifying

```bash
claude plugin list        # expect 8 enabled
ls ~/.claude/skills/      # expect 11 folders (12 with huashu-design)
```

Restart Claude Code, then confirm the in-context skill listing includes `ecc:*`,
`superpowers:*`, `vercel:*`, and the `pryne-*` entries. Skills and settings are read **only**
at session start, so a restart is required after any install or edit.
