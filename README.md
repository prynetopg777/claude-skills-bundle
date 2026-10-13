# claude-skills-bundle

Pryne's Claude Code setup, packaged for transfer: **11 personal skills** plus a one-command
installer that also pulls in the **8 marketplace plugins** he runs.

## Install

```bash
git clone https://github.com/prynetopg777/claude-skills-bundle
cd claude-skills-bundle
./install.sh
```

One-liner:

```bash
curl -fsSL https://raw.githubusercontent.com/prynetopg777/claude-skills-bundle/master/install.sh | bash
```

Then **restart Claude Code** — skills and settings are only read at session start.

### What `install.sh` does

1. Copies `skills/*` into `~/.claude/skills/` (backs up any same-named folder first).
2. Registers 6 git marketplaces and installs 8 plugins via the `claude` CLI.
3. Appends the `skill-router` `UserPromptSubmit` hook to `settings.json` — merged, not
   overwritten, with a timestamped backup. Re-running is safe and won't duplicate the hook.

### Flags

| Flag | Effect |
|---|---|
| `--skills-only` | Copy skill folders, skip all plugin installs |
| `--plugins-only` | Install plugins, don't touch `~/.claude/skills/` |
| `--no-hook` | Leave `settings.json` alone |
| `--with-huashu` | Also clone `huashu-design` from upstream (~62MB, see below) |

Nothing is overwritten in place: existing skill folders move to `<name>.backup.<timestamp>`,
and `settings.json` is copied to `settings.json.bak.<timestamp>` before any edit.

## What you get

**11 skills in this repo** — `skill-router` (survey the whole skill arsenal before acting)
and 10 `pryne-*` process skills covering onboarding, change control, QA gates, failure
archaeology, design-direction decisions, frontend architecture, debugging, motion theory,
browser measurement, and documentation.

**8 plugins installed for you** — `superpowers` (process discipline), `ecc` (262 skills /
64 agents / 84 commands), `vercel`, `ponytail`, `document-skills`, `gsap-skills`,
`obsidian`, `genjutsu`.

## Handing this to Claude

`pryne-skills.md` is written as an **executable runbook** — point Claude at it and it will do
the install itself, including the two steps `install.sh` can't cover (MCP servers, and
neutralizing the repo-specific `verify.sh` scripts). Every command in it is real and
copy-paste-ready; it ends with a self-check and tells Claude what to report back.

> Read pryne-skills.md in this repo and set it up on my machine.

Full breakdown of versions, sources and config also lives there:
**[pryne-skills.md](./pryne-skills.md)**.

## Two caveats worth reading

**The `pryne-*` skills encode one person's repo conventions.** They name real paths —
`design-demos/*.html`, `js/roll-*.js`, `window.Roll` IIFE modules, `DECISIONS.md` — that
won't exist in your projects. The *process shape* transfers (gate before changing, gate
before claiming done, score variants instead of polishing a favorite); the file paths don't.
Read them as reference, not law.

**`huashu-design` is not in this repo.** It's a third-party skill by
[alchaincyf](https://github.com/alchaincyf/huashu-design) with its own LICENSE and ~62MB of
bundled audio, so it isn't redistributed here. `./install.sh --with-huashu` clones it from
upstream. It's also primarily Chinese-language.

`pryne-browser-lab` additionally needs the **chrome-devtools MCP server**, which the
installer does not configure — see pryne-skills.md §3c.
