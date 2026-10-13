#!/bin/bash
# verify.sh — drift check for pryne-docs-and-writing/SKILL.md.
# Read-only (grep/head/git log). Exit 0 = no drift; 1 = drift found; 2 = repo missing.
REPO="${1:-$HOME/Documents/Coding Folder/Portfolio (test)}"
FAIL=0
pass()   { echo "PASS: $1"; }
drift()  { echo "DRIFT: $1 — $2"; FAIL=1; }
manual() { echo "MANUAL: $1"; }
file_has() { if grep -qF -- "$2" "$1" 2>/dev/null; then pass "$3"; else drift "$3" "$4"; fi; }

# --- repo-independent checks ---
if grep -q "Conventional Commits" "$HOME/.claude/skills/commit-message/SKILL.md" 2>/dev/null; then
  pass "commit-message skill exists and is Conventional Commits (When-NOT-to-use claim)"
else
  drift "commit-message skill (Conventional Commits)" "the commit-style rule references a skill that changed or is missing"
fi
manual "vault status-checklist convention: confirm via the session-start Obsidian context block or obsidian:obsidian-cli — not checkable from bash"

if [ ! -d "$REPO" ]; then
  echo "SKIP: repo not found at $REPO (pass repo path as \$1)"
  exit 2
fi
cd "$REPO" || exit 2

# --- DECISIONS.md worked example ---
file_has design-demos/DECISIONS.md "## Decision: Lenis smooth-scroll — reintroduce, scoped & timeboxed" "Lenis entry heading (template's worked example)" "the worked example changed — re-quote it and re-derive the template"
file_has design-demos/DECISIONS.md "Timeboxed:" "timebox constraint line in the worked example" "entry structure changed — re-derive the template rules"

# --- head-comment convention ---
BAD=""
for f in design-demos/*.html; do
  head -1 "$f" | grep -q "<!--" || BAD="$BAD $f"
done
if [ -z "$BAD" ]; then pass "every demo HTML opens with a head comment"; else drift "head-comment convention" "no head comment on:$BAD — the five-part structure claim is stale for those files"; fi
file_has design-demos/portfolio-demo-v2.html "PLACEHOLDER" "PLACEHOLDER inventory in v2 (structure part 4 exemplar)" "v2 head comment changed — pick a new exemplar"
file_has design-demos/v4-c-ch001.html "panel { beat, tone" "concept-spine exemplar in v4-c (structure part 2; wraps across lines 4-5)" "v4-c head comment changed — pick a new exemplar"
file_has design-demos/v4-a-midnight-issue.html "SCOPED-DOWN" "scope-note exemplar in v4-a (structure part 3)" "v4-a head comment changed — pick a new exemplar"

# --- commit style observation ---
if git log --oneline | grep -q "Baseline: ROLL 01"; then pass "sentence-style commit history observed (commit-style note)"; else drift "sentence-style commit history" "history changed — re-verify the commit-style guidance"; fi

exit $FAIL
