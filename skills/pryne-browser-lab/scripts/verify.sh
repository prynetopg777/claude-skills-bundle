#!/bin/bash
# verify.sh — drift check for pryne-browser-lab/SKILL.md.
# Read-only (grep/ls/command -v). Never starts servers. Exit 0 = no drift; 1 = drift; 2 = repo missing.
REPO="${1:-$HOME/Documents/Coding Folder/Portfolio (test)}"
FAIL=0
pass()   { echo "PASS: $1"; }
drift()  { echo "DRIFT: $1 — $2"; FAIL=1; }
manual() { echo "MANUAL: $1"; }
line_has() { if sed -n "${2}p" "$1" | grep -qF -- "$3"; then pass "$4"; else drift "$4" "$5"; fi; }
file_has() { if grep -qF -- "$2" "$1" 2>/dev/null; then pass "$3"; else drift "$3" "$4"; fi; }

# --- repo-independent checks ---
if command -v python3 >/dev/null 2>&1; then pass "python3 available ($(command -v python3))"; else drift "python3 available" "§1 serving recipe assumes python3 -m http.server"; fi
manual "MCP tool names (§2): re-verify in-session with ToolSearch(\"chrome devtools screenshot trace\") — bash cannot see MCP tools"
manual "server smoke test (§1): scripts never start servers — run python3 -m http.server manually and curl the demo URL for 200"

if [ ! -d "$REPO" ]; then
  echo "SKIP: repo not found at $REPO (pass repo path as \$1)"
  exit 2
fi
cd "$REPO" || exit 2

# --- §1 serving assumptions ---
if grep -rn "fetch(\|XMLHttpRequest" design-demos --include="*.html" --include="*.js" >/dev/null 2>&1; then
  drift "no fetch()/XHR in demos" "a demo now fetches over the network — the file:// viability claim in §1 is stale"
else
  pass "no fetch()/XHR anywhere in design-demos (§1 claim)"
fi
file_has design-demos/js/roll-audio.js "AudioContext" "roll-audio uses AudioContext (§1 gesture constraint)" "audio implementation changed — re-verify §1 audio bullet"
line_has design-demos/js/roll-audio.js 43 "startAmbient" "startAmbient()-at-load nuance at roll-audio.js:43" "cited line moved — update §1 audio bullet"

# --- §4 artifact conventions ---
file_has .gitignore ".playwright-mcp/" ".playwright-mcp/ gitignored (§4)" "gitignore changed — update §4 scratch-artifact row"
for p in v3-mobile.png v2-desktop-hero.png demo-desktop-full.png; do
  if [ -f "design-demos/$p" ]; then pass "naming exemplar design-demos/$p exists (§4)"; else drift "naming exemplar $p" "§4 canonical-convention examples are stale — re-list design-demos/*.png"; fi
done

# --- §3(e) reduced-motion flag ---
line_has design-demos/js/roll-core.js 9 "prefers-reduced-motion" "Roll.reduced flag for recipe (e)" "flag moved — update recipe (e) and defer inventory to pryne-frontend-architecture"

exit $FAIL
