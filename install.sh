#!/usr/bin/env bash
# Plug-and-play installer for Pryne's Claude Code skills + plugins.
#   curl -fsSL https://raw.githubusercontent.com/prynetopg777/claude-skills-bundle/master/install.sh | bash
# or: git clone https://github.com/prynetopg777/claude-skills-bundle && cd claude-skills-bundle && ./install.sh
#
# Flags:
#   --skills-only    copy skill folders, skip all plugin installs
#   --plugins-only   install plugins, skip copying skill folders
#   --no-hook        don't add the skill-router UserPromptSubmit hook
#   --with-huashu    also clone the third-party huashu-design skill (~62MB)
set -uo pipefail

SKILLS_ONLY=0; PLUGINS_ONLY=0; NO_HOOK=0; WITH_HUASHU=0
for a in "$@"; do case "$a" in
  --skills-only) SKILLS_ONLY=1 ;;
  --plugins-only) PLUGINS_ONLY=1 ;;
  --no-hook) NO_HOOK=1 ;;
  --with-huashu) WITH_HUASHU=1 ;;
  -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
  *) echo "unknown flag: $a" >&2; exit 2 ;;
esac; done

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SKILLS_DIR="$CLAUDE_DIR/skills"
SETTINGS="$CLAUDE_DIR/settings.json"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ok()   { printf '  \033[32m✓\033[0m %s\n'  "$1"; }
warn() { printf '  \033[33m!\033[0m %s\n'  "$1"; }
step() { printf '\n\033[1m%s\033[0m\n'     "$1"; }

# If piped from curl there is no local checkout — fetch one.
if [ ! -d "$SRC/skills" ]; then
  step "Fetching bundle"
  command -v git >/dev/null || { echo "git is required" >&2; exit 1; }
  TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
  git clone --depth 1 -q https://github.com/prynetopg777/claude-skills-bundle "$TMP/b" || {
    echo "clone failed" >&2; exit 1; }
  SRC="$TMP/b"; ok "cloned to a temp dir"
fi

# ---------------------------------------------------------------- 1. skills
if [ "$PLUGINS_ONLY" -eq 0 ]; then
  step "Installing skills → $SKILLS_DIR"
  mkdir -p "$SKILLS_DIR"
  for d in "$SRC"/skills/*/; do
    n="$(basename "$d")"
    if [ -e "$SKILLS_DIR/$n" ]; then
      bk="$SKILLS_DIR/$n.backup.$(date +%Y%m%d%H%M%S)"
      mv "$SKILLS_DIR/$n" "$bk"
      warn "$n already existed → backed up to $(basename "$bk")"
    fi
    cp -R "$d" "$SKILLS_DIR/$n" && ok "$n"
  done

  if [ "$WITH_HUASHU" -eq 1 ]; then
    if [ -e "$SKILLS_DIR/huashu-design" ]; then
      warn "huashu-design already present — skipping"
    else
      git clone --depth 1 -q https://github.com/alchaincyf/huashu-design.git \
        "$SKILLS_DIR/huashu-design" && ok "huashu-design (cloned from upstream)"
    fi
  fi
fi

# --------------------------------------------------------------- 2. plugins
if [ "$SKILLS_ONLY" -eq 0 ]; then
  if ! command -v claude >/dev/null; then
    warn "the 'claude' CLI is not on PATH — skipping plugins."
    warn "install Claude Code, then re-run: ./install.sh --plugins-only"
  else
    step "Registering marketplaces"
    while read -r src; do
      [ -z "$src" ] && continue
      claude plugin marketplace add "$src" >/dev/null 2>&1 \
        && ok "$src" || warn "$src (already added, or failed)"
    done <<'MARKETS'
https://github.com/affaan-m/ECC.git
kepano/obsidian-skills
DietrichGebert/ponytail
anthropics/skills
greensock/gsap-skills
AThevon/genjutsu
MARKETS

    step "Installing plugins (ecc is large — this takes a few minutes)"
    while read -r p; do
      [ -z "$p" ] && continue
      claude plugin install "$p" -y >/dev/null 2>&1 \
        && ok "$p" || warn "$p FAILED — retry manually: claude plugin install $p"
    done <<'PLUGINS'
superpowers@claude-plugins-official
vercel@claude-plugins-official
ecc@ecc
obsidian@obsidian-skills
ponytail@ponytail
document-skills@anthropic-agent-skills
gsap-skills@gsap-skills
genjutsu@genjutsu
PLUGINS
  fi
fi

# ------------------------------------------------------ 3. skill-router hook
if [ "$NO_HOOK" -eq 0 ] && [ "$PLUGINS_ONLY" -eq 0 ]; then
  step "Wiring the skill-router hook into settings.json"
  if ! command -v python3 >/dev/null; then
    warn "python3 not found — add the hook by hand (see pryne-skills.md §3a)"
  else
    [ -f "$SETTINGS" ] && cp "$SETTINGS" "$SETTINGS.bak.$(date +%Y%m%d%H%M%S)"
    SETTINGS="$SETTINGS" python3 <<'PY'
import json, os, sys
p = os.environ["SETTINGS"]
try:
    s = json.load(open(p)) if os.path.exists(p) and os.path.getsize(p) else {}
except json.JSONDecodeError:
    print("  \033[33m!\033[0m settings.json is not valid JSON — left untouched"); sys.exit(0)

MSG = ("Reminder: invoke the skill-router skill first — survey the full skill "
       "arsenal (global, plugin, project) and apply every skill that fits before acting.")
cmd = ("printf '{\"hookSpecificOutput\":{\"hookEventName\":\"UserPromptSubmit\","
       '"additionalContext":"' + MSG + "\"}}'")

groups = s.setdefault("hooks", {}).setdefault("UserPromptSubmit", [])
if any(h.get("command") == cmd for g in groups for h in g.get("hooks", [])):
    print("  \033[32m✓\033[0m hook already present — nothing to do")
else:
    groups.append({"hooks": [{"type": "command", "command": cmd}]})
    json.dump(s, open(p, "w"), indent=2)
    print("  \033[32m✓\033[0m hook added (previous settings.json backed up)")
PY
  fi
fi

step "Done"
cat <<'EOF'
  Restart Claude Code — skills and settings are read at session start.
  Verify with:   claude plugin list
  Read next:     pryne-skills.md  (what each piece does, MCP servers, optional config)

  Note: the pryne-* skills reference their author's repo conventions
  (vanilla-JS window.Roll modules, design-demos/*.html, DECISIONS.md).
  The process shape transfers; the file paths will not match your projects.
EOF
