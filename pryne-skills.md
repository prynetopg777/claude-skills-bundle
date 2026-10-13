# Pryne's Claude Code Setup — Executable Runbook

> **Claude: you can do this entire setup yourself. Start at §0 and run the commands.**
> Everything here is real and copy-paste-ready — no placeholders to fill in, nothing that
> needs the user to go click something in a browser. Work top to bottom, then report what
> landed using the self-check in §5.
>
> Stop and ask the user only if: §0's preflight finds existing skill folders with the same
> names (the installer will back them up — say so rather than deciding for them), or you
> reach §3c, which changes how much Claude asks permission. Otherwise proceed.
>
> Snapshot: 2026-10-13 · Claude Code 2.1.296 · verified on macOS (bash 3.2) and Linux.

---

## §0. Do this first — the whole install in one command

```bash
curl -fsSL https://raw.githubusercontent.com/prynetopg777/claude-skills-bundle/master/install.sh | bash
```

That single command does §1, §2 and §3a: copies 11 skills, registers 6 marketplaces,
installs 8 plugins, and merges the skill-router hook into `settings.json`. It backs up
anything it would overwrite and is safe to re-run.

**Then do §3b (MCP servers) and §4 (cleanup) — the installer deliberately skips both.**
Finish with §5 and report the result.

If `curl | bash` isn't acceptable in this environment, clone and read it first:

```bash
git clone https://github.com/prynetopg777/claude-skills-bundle /tmp/csb
cd /tmp/csb && cat install.sh    # then:
./install.sh
```

### Preflight — know what you're about to change

```bash
echo "claude CLI: $(command -v claude || echo MISSING)"
echo "git:        $(command -v git || echo MISSING)"
echo "python3:    $(command -v python3 || echo MISSING)"
echo "existing skills:"; ls ~/.claude/skills/ 2>/dev/null || echo "  (none — clean install)"
echo "settings.json: $([ -f ~/.claude/settings.json ] && echo present || echo absent)"
```

- `claude` missing → install Claude Code first, or run `./install.sh --skills-only`.
- `python3` missing → the hook step is skipped; apply §3a by hand.
- A conflicting skill name → the installer renames the old one to
  `<name>.backup.<timestamp>`. Tell the user this happened; don't silently absorb it.

### Installer flags

| Flag | Effect |
|---|---|
| `--skills-only` | Copy skill folders, skip all plugin installs |
| `--plugins-only` | Install plugins, leave `~/.claude/skills/` alone |
| `--no-hook` | Don't touch `settings.json` |
| `--with-huashu` | Also clone the third-party `huashu-design` skill (~62MB, see §2c) |

---

## §1. Plugins — 8 of them

The installer does this. Use these commands to do it by hand, or to repair one that failed:

```bash
claude plugin marketplace add https://github.com/affaan-m/ECC.git
claude plugin marketplace add kepano/obsidian-skills
claude plugin marketplace add DietrichGebert/ponytail
claude plugin marketplace add anthropics/skills
claude plugin marketplace add greensock/gsap-skills
claude plugin marketplace add AThevon/genjutsu
# claude-plugins-official is built in — nothing to add

claude plugin install superpowers@claude-plugins-official -y
claude plugin install vercel@claude-plugins-official -y
claude plugin install ecc@ecc -y
claude plugin install obsidian@obsidian-skills -y
claude plugin install ponytail@ponytail -y
claude plugin install document-skills@anthropic-agent-skills -y
claude plugin install gsap-skills@gsap-skills -y
claude plugin install genjutsu@genjutsu -y
```

`ecc` is large — expect a few minutes. The same commands work as `/plugin install …` slash
commands inside a session.

| Plugin | Version | Source | What it adds |
|---|---|---|---|
| `superpowers` | 6.4.1 | built-in | 14 process-discipline skills: `brainstorming`, `systematic-debugging`, `test-driven-development`, `writing-plans`, `executing-plans`, `requesting-code-review`, `verification-before-completion`, `using-git-worktrees`, `writing-skills`, `subagent-driven-development`. **The backbone** — establishes "invoke a relevant skill before responding". |
| `ecc` | 2.0.0 | [affaan-m/ECC](https://github.com/affaan-m/ECC) | The big one: **262 skills, 64 agents, 84 commands**. Per-language reviewers and build-resolvers (TS, Python, Go, Rust, Swift, Kotlin, C++, Java, PHP, Dart/Flutter), orchestration pipelines (`orch-*`), GAN build/design loops, hookify, security/a11y/perf agents. **Also bundles the chrome-devtools MCP server** — see §3b. |
| `vercel` | 0.50.0 | built-in | 30 skills, 3 agents, 5 commands. Next.js App Router, AI SDK, AI Gateway, Fluid Compute, deployments, `vercel env`, caching. Ships an MCP server needing one-time OAuth — see §3b. |
| `ponytail` | 4.4.0 | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) | 5 skills. A "lazy senior developer" behavior layer — YAGNI ladder, shortest-working-diff bias. Installs its own `SessionStart` hook, so it is **active on every response** once installed. `/ponytail lite\|full\|ultra` changes intensity; "stop ponytail" disables it for a session. |
| `document-skills` | `dbd4588f` | [anthropics/skills](https://github.com/anthropics/skills) | `docx`, `pptx`, `xlsx`, `pdf` — real Office/PDF generation and editing. |
| `gsap-skills` | 1.0.0 | [greensock/gsap-skills](https://github.com/greensock/gsap-skills) | 8 skills: `gsap-core`, `gsap-timeline`, `gsap-scrolltrigger`, `gsap-plugins`, `gsap-react`, `gsap-frameworks`, `gsap-performance`, `gsap-utils`. |
| `obsidian` | 1.0.1 | [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) | 5 skills: `obsidian-cli`, `obsidian-markdown`, `obsidian-bases`, `json-canvas`, `defuddle`. Only useful with an actual Obsidian vault — skip if the user has none. |
| `genjutsu` | 3.0.1 | [AThevon/genjutsu](https://github.com/AThevon/genjutsu) | 3 skills: `cast`, `paint`. Visual/creative generation. |

### Deliberately NOT installed

Present in the source machine's cache with `enabledPlugins: false`. **Do not install these** —
the omission is intentional, not an oversight:

```
andrej-karpathy-skills@karpathy-skills     minimalist-entrepreneur@minimalist-entrepreneur
bmad@bmad-method                           example-skills@anthropic-agent-skills
```

---

## §2. Skills — 11, shipped in `skills/` in this repo

No marketplace exists for these. They're plain folders, each with a `SKILL.md`; Claude Code
discovers anything under `~/.claude/skills/` at session start, with no registration step.

```bash
# what the installer does, minus the backup logic:
cp -R skills/* ~/.claude/skills/
```

### 2a. The keystone

| Skill | Purpose |
|---|---|
| `skill-router` | Forces a survey of *every* available skill at the start of a task instead of grabbing the first match: enumerate the arsenal → extract the request's dimensions → match each one → order process-before-implementation → prune to the skills that genuinely change the work. Paired with §3a's hook so it fires on every prompt. |

### 2b. The `pryne-*` library — 10 process skills

Four are **gates** (run before acting); six are **references** (consulted while acting).

| Skill | Kind | Purpose |
|---|---|---|
| `pryne-project-onboarding` | gate | Read first in an unfamiliar repo. Establishes build target and status before any change; resolves repo-vs-context disagreements. |
| `pryne-change-control` | gate | Before modifying/adding/removing anything — code, copy, styles, motion, deps, design direction. Decides what needs sign-off; blocks casual CDN dependencies. |
| `pryne-validation-and-qa` | gate | Before claiming anything is done, improved, or working. Defines sufficient evidence (screenshots, console output, Lighthouse, rubric scores) and rejects "it looks good" as acceptance. |
| `pryne-failure-archaeology` | gate | Before re-litigating a past decision — why a library/concept/architecture was abandoned, and whether an old file is a live build target or a relic. |
| `pryne-design-direction-decision` | gate | When several built variants exist and one must win. Forces scoring all siblings instead of polishing a favorite. |
| `pryne-frontend-architecture` | ref | Where new interactive JS belongs in a vanilla-JS build: script order, reduced-motion gating, progressive enhancement, CSS design tokens. |
| `pryne-frontend-debugging` | ref | Symptom-indexed: animations firing before their section is visible, clipped reveals, vanished OS cursor, WebGL ghosting/blending, dead scroll choreography, motion dead for one user, silent audio. |
| `pryne-motion-reference` | ref | Theory for scroll-linked animation, Lenis smooth-scroll, scroll velocity, WebGL/canvas grain shaders, kinetic type, reduced-motion gating, easing choice. Defines in-house terms like "choreography spine" and "develop plate". |
| `pryne-browser-lab` | ref | Measuring a page in a real browser: serve locally, capture console, breakpoint screenshots, perf traces, Lighthouse, reduced-motion emulation. Needs a chrome-devtools MCP server — §3b. |
| `pryne-docs-and-writing` | ref | Where documentation belongs — `DECISIONS.md`, file head comments, Obsidian vault sync. |

### 2c. Not included — third party

`huashu-design` (花叔Design) — hi-fi HTML prototyping, interactive/animation demos,
design-variant exploration, 5-dimension design review, MP4/GIF export, anti-"AI-slop" rules.
Primarily Chinese-language. Not redistributed here: it is
[alchaincyf/huashu-design](https://github.com/alchaincyf/huashu-design), carries its own
LICENSE, and bundles ~62MB of audio.

```bash
./install.sh --with-huashu
# or directly:
git clone --depth 1 https://github.com/alchaincyf/huashu-design.git ~/.claude/skills/huashu-design
```

### 2d. Project-scoped skills — not shipped

These live in a **repo** at `.claude/skills/` and travel with the project, not the user. The
source machine's portfolio repo carries two, noted only for completeness: `design-dna`
(design DNA across system tokens, qualitative style, and visual effects) and `motion-design`
(timing, easing, choreography, Disney principles adapted for UI).

### 2e. On disk but switched off — not shipped

Disabled via `skillOverrides`, mostly because `ecc` and the plugin skills cover the same
ground better. This script **only disables what's actually installed**, so it's a no-op on a
clean machine rather than dead config:

```bash
python3 - <<'PY'
import json, os, shutil, time
p = os.path.expanduser("~/.claude/settings.json")
s = json.load(open(p)) if os.path.exists(p) and os.path.getsize(p) else {}
names = ["ui-ux-pro-max","design","banner-design","ui-styling","brand","code-review",
         "slides","emil-design-eng","design-system","commit-message","review-animations"]
skills = os.path.expanduser("~/.claude/skills")
present = [n for n in names if os.path.isdir(os.path.join(skills, n))]
if not present:
    print("none of those skills are installed — nothing to disable")
else:
    if os.path.exists(p): shutil.copy(p, p + ".bak." + time.strftime("%Y%m%d%H%M%S"))
    s.setdefault("skillOverrides", {}).update({n: "off" for n in present})
    json.dump(s, open(p, "w"), indent=2)
    print("disabled:", ", ".join(present))
PY
```

---

## §3. Config

### 3a. The skill-router hook — the installer adds this

Without it the skills are installed but largely inert: a skill normally loads only when its
description matches the request, and a `UserPromptSubmit` hook is the only mechanism that
fires unconditionally on every prompt.

To add it by hand — merges into existing settings, backs up first, won't duplicate:

```bash
python3 - <<'PY'
import json, os, shutil, time
p = os.path.expanduser("~/.claude/settings.json")
s = json.load(open(p)) if os.path.exists(p) and os.path.getsize(p) else {}
MSG = ("Reminder: invoke the skill-router skill first — survey the full skill "
       "arsenal (global, plugin, project) and apply every skill that fits before acting.")
cmd = ("printf '{\"hookSpecificOutput\":{\"hookEventName\":\"UserPromptSubmit\","
       '"additionalContext":"' + MSG + "\"}}'")
groups = s.setdefault("hooks", {}).setdefault("UserPromptSubmit", [])
if any(h.get("command") == cmd for g in groups for h in g.get("hooks", [])):
    print("hook already present")
else:
    if os.path.exists(p): shutil.copy(p, p + ".bak." + time.strftime("%Y%m%d%H%M%S"))
    groups.append({"hooks": [{"type": "command", "command": cmd}]})
    json.dump(s, open(p, "w"), indent=2)
    print("hook added")
PY
```

`ponytail` and `vercel` register their own `SessionStart` hooks automatically on install —
that's how ponytail stays active across every response. The source machine also runs a
personal `~/.claude/hooks/obsidian-context.sh` at session start to inject vault context;
not reproduced here, since it depends on that specific vault.

### 3b. MCP servers — run these yourself; the installer does not

**Check what you already have first — `ecc` and `vercel` bring their own:**

```bash
claude mcp list
```

`plugin:ecc:chrome-devtools` appears automatically once `ecc` is installed, and that's what
`pryne-browser-lab` needs. **If it's listed, skip the chrome-devtools line below.**

Add whatever is missing:

```bash
# browser automation, Lighthouse, perf traces, console + network — needed by pryne-browser-lab
# (skip if plugin:ecc:chrome-devtools already appears above)
claude mcp add chrome-devtools -- npx -y chrome-devtools-mcp@latest --isolated

# live library/framework docs — used by ecc:docs-lookup and any "how do I use X" question
claude mcp add --transport http context7 https://mcp.context7.com/mcp

# current time / timezone conversion (needs uv — https://docs.astral.sh/uv/)
claude mcp add time -- uvx mcp-server-time
```

Optional — present on the source machine, but no skill here requires them:

```bash
claude mcp add playwright -- npx -y @playwright/mcp@latest
claude mcp add fetch -- uvx mcp-server-fetch
claude mcp add git -- uvx mcp-server-git
claude mcp add sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking
claude mcp add memory -- npx -y @modelcontextprotocol/server-memory
```

The `vercel` plugin's MCP server needs a one-time interactive OAuth login. **Don't try to
automate it** — tell the user to run `/mcp` in a session and authenticate there.

### 3c. Remaining settings — ask the user before applying

```json
{ "model": "opus", "theme": "dark", "permissions": { "defaultMode": "auto" } }
```

⚠️ **`defaultMode: "auto"` runs tools without prompting far more often than the default.**
That's a real reduction in human oversight, not a cosmetic preference. Do not set it
silently — surface it and let the user decide. `model` and `theme` are harmless:

```bash
python3 - <<'PY'
import json, os, shutil, time
p = os.path.expanduser("~/.claude/settings.json")
s = json.load(open(p)) if os.path.exists(p) and os.path.getsize(p) else {}
if os.path.exists(p): shutil.copy(p, p + ".bak." + time.strftime("%Y%m%d%H%M%S"))
s.setdefault("model", "opus"); s.setdefault("theme", "dark")
json.dump(s, open(p, "w"), indent=2); print("model/theme set (any existing values kept)")
PY
```

---

## §4. Required cleanup — the `verify.sh` scripts

Nine of the `pryne-*` skills ship a `scripts/verify.sh` that asserts **specific lines in
specific files of the original author's portfolio repo** — things like
`design-demos/v4-d-hybrid.html` line 51 containing `--bg: #0a0a0b`, or the token
`--accent: #d2232e`. Those files don't exist here, so the scripts will fail or report
nonsense if a skill invokes one.

**Neutralize them.** This keeps them readable as a record of what the author checked, while
making sure nothing executes them:

```bash
find ~/.claude/skills -path '*/pryne-*/scripts/verify.sh' -print0 2>/dev/null |
while IFS= read -r -d '' f; do
  chmod -x "$f" && mv "$f" "${f}.reference" && echo "neutralized ${f#$HOME/}"
done
echo "done (no output above = nothing to neutralize)"
```

If a `SKILL.md` later tells you to run its `verify.sh`, treat that instruction as
inapplicable — then verify the *equivalent* property against this project's real files.
That substitution is the intent behind every one of those scripts.

### Portability — pass this on to the user

The `pryne-*` skills name real conventions from one person's repos: `design-demos/*.html`,
`js/roll-*.js`, `window.Roll` IIFE modules, `DECISIONS.md`, `v4-d-hybrid.html`, and the CSS
tokens `--ease-out` / `--ease-snap`. Machine-specific absolute paths were replaced with
`$PROJECT_ROOT`, but those *file* references are intact and won't resolve elsewhere.

**Read these skills for their process shape, not their paths.** The transferable part — gate
before changing, gate before claiming done, score all variants instead of polishing a
favorite, require evidence over impressions — is the point. When a skill cites a path that
doesn't exist, substitute the equivalent file in the current project and carry on; don't
report it as a broken install.

---

## §5. Self-check — run this, then report the output

```bash
echo "=== plugins (expect 8 enabled) ==="
claude plugin list 2>/dev/null || echo "claude CLI unavailable"

echo; echo "=== skills (expect 11, or 12 with huashu-design) ==="
ls ~/.claude/skills/ 2>/dev/null

echo; echo "=== skill-router hook ==="
python3 -c "
import json, os
p = os.path.expanduser('~/.claude/settings.json')
s = json.load(open(p)) if os.path.exists(p) else {}
hooks = [h.get('command','') for g in s.get('hooks',{}).get('UserPromptSubmit',[])
         for h in g.get('hooks',[])]
print('present' if any('skill-router' in h for h in hooks) else 'MISSING — see 3a')
" 2>/dev/null || echo "python3 unavailable"

echo; echo "=== MCP: chrome-devtools reachable? ==="
claude mcp list 2>/dev/null | grep -i chrome-devtools || echo "MISSING — see 3b"

echo; echo "=== verify.sh neutralized? ==="
find ~/.claude/skills -path '*/pryne-*/scripts/verify.sh' 2>/dev/null | grep . \
  && echo "^ still live — run section 4" || echo "clean"
```

**Then restart Claude Code.** Skills, hooks and settings are read *only* at session start, so
nothing above takes effect until a new session. After restarting, confirm the in-context
skill listing includes `ecc:*`, `superpowers:*`, `vercel:*` and the `pryne-*` entries.

### What to tell the user

State plainly: how many plugins and skills landed, whether the hook is wired, which MCP
servers are live, anything that failed, and that a restart is required. Two things to raise
explicitly rather than leave implied:

- Whether §3c's `defaultMode: "auto"` was applied — if you skipped it, say so and let them choose.
- Any skill folder the installer backed up, and the backup's name.
