#!/bin/bash
# verify.sh — drift check for pryne-project-onboarding/SKILL.md.
# Read-only (grep/ls/cat/git log). Exit 0 = no drift; 1 = drift found; 2 = repo missing.
REPO="${1:-$HOME/Documents/Coding Folder/Portfolio (test)}"
FAIL=0
pass()   { echo "PASS: $1"; }
drift()  { echo "DRIFT: $1 — $2"; FAIL=1; }
manual() { echo "MANUAL: $1"; }
file_has() { if grep -qF -- "$2" "$1" 2>/dev/null; then pass "$3"; else drift "$3" "$4"; fi; }

# --- repo-independent checks ---
if [ -f "$HOME/AGENTS.md" ] && grep -q "design tokens" "$HOME/AGENTS.md"; then
  pass "~/AGENTS.md exists with global preferences (§5 source)"
else
  drift "~/AGENTS.md global preferences" "§5 summary table may be stale — re-read ~/AGENTS.md"
fi
manual "SessionStart vault-context injection (§1) can only be confirmed in a live session — look for the 'Obsidian project context' block"

if [ ! -d "$REPO" ]; then
  echo "SKIP: repo not found at $REPO (pass repo path as \$1)"
  exit 2
fi
cd "$REPO" || exit 2

# --- §2 repo conventions ---
file_has .gitignore ".playwright-mcp/" ".playwright-mcp/ gitignored (§2 artifact-dump row)" "gitignore changed — update the artifact-dump convention row"
file_has skills-lock.json "design-dna" "skills-lock.json pins design-dna (§2 vendored-skills row)" "vendored-skills row stale — re-read skills-lock.json"
file_has skills-lock.json "motion-design" "skills-lock.json pins motion-design (§2 vendored-skills row)" "vendored-skills row stale — re-read skills-lock.json"
for d in .claude/skills/design-dna .agents/skills/design-dna; do
  if [ -d "$d" ]; then pass "skill mirror dir $d exists (§2)"; else drift "skill mirror dir $d" "dual-mirror claim in §2 is stale"; fi
done
if [ -f design-demos/DECISIONS.md ]; then pass "DECISIONS.md exists (§2 decision-record row)"; else drift "DECISIONS.md exists" "§2/§3 steps reference a missing decision record"; fi
if [ -f design-demos/js/vendor/lenis.min.js ]; then pass "vendored lenis.min.js (§2 vendored-JS row)"; else drift "vendored lenis.min.js" "§2 vendored-JS example is stale"; fi

# --- §3/§4 build target and variants ---
for f in v4-a-midnight-issue v4-b-first-pressing v4-c-ch001 v4-d-hybrid; do
  if [ -f "design-demos/$f.html" ]; then pass "variant $f.html exists (§3.5)"; else drift "variant $f.html exists" "§3.5/§4 variant list is stale — the v4 field changed"; fi
done
SHARED=$(grep -l "roll-core.js" design-demos/*.html 2>/dev/null)
if [ "$SHARED" = "design-demos/v4-d-hybrid.html" ]; then
  pass "only v4-d loads shared roll-*.js modules (§2 self-contained-demos row)"
else
  drift "only v4-d loads shared roll-*.js" "module-sharing claim changed — now: $SHARED"
fi
if git rev-parse --quiet --verify 457868a^{commit} >/dev/null 2>&1; then pass "snapshot commit 457868a exists (§4)"; else drift "snapshot commit 457868a" "history rewritten? §4 snapshot invalid"; fi
if [ "$(git rev-parse --short HEAD)" != "457868a" ]; then
  manual "HEAD has advanced past 457868a — §4 project snapshot is dated; re-verify current build target and status"
else
  pass "HEAD still at snapshot commit 457868a (§4 current)"
fi

exit $FAIL
