#!/bin/bash
# verify.sh — drift check for pryne-failure-archaeology/SKILL.md.
# Read-only (grep/ls/git log/head). Exit 0 = no drift; 1 = drift found; 2 = repo missing.
REPO="${1:-$HOME/Documents/Coding Folder/Portfolio (test)}"
FAIL=0
pass()   { echo "PASS: $1"; }
drift()  { echo "DRIFT: $1 — $2"; FAIL=1; }
manual() { echo "MANUAL: $1"; }
file_has() { if grep -qF -- "$2" "$1" 2>/dev/null; then pass "$3"; else drift "$3" "$4"; fi; }

if [ ! -d "$REPO" ]; then
  echo "SKIP: repo not found at $REPO (pass repo path as \$1)"
  exit 2
fi
cd "$REPO" || exit 2

# --- lineage map files ---
for f in 1-cursor.html 2-ember.html 3-signal.html portfolio-demo.html portfolio-demo-v2.html portfolio-demo-v3.html v4-a-midnight-issue.html v4-b-first-pressing.html v4-c-ch001.html v4-d-hybrid.html; do
  if [ -f "design-demos/$f" ]; then pass "lineage file $f exists"; else drift "lineage file $f" "the lineage map row for this file is stale (deleted or renamed)"; fi
done

# --- evidence commits ---
for c in 1575051 727c133 457868a; do
  if git rev-parse --quiet --verify "$c^{commit}" >/dev/null 2>&1; then pass "evidence commit $c exists"; else drift "evidence commit $c" "history rewritten? entry evidence pointers invalid"; fi
done

# --- Entry 2 (Lenis saga) ---
file_has design-demos/DECISIONS.md "Lenis smooth-scroll — reintroduce, scoped & timeboxed" "DECISIONS.md Lenis section (Entry 2 evidence)" "section renamed/removed — re-verify Entry 2"
if [ -f design-demos/js/vendor/lenis.min.js ]; then pass "vendored lenis.min.js (Entry 2 status)"; else drift "vendored lenis.min.js" "Lenis may have been removed — Entry 2 status 'reintroduction active' is stale; check DECISIONS.md for the outcome"; fi
file_has design-demos/js/roll-scroll.js "scrollY stays valid" "zero-swaps code comment (Entry 2 correction)" "roll-scroll comment changed — re-verify the zero-swaps statement"

# --- Entry 3 (two-metaphor audit) ---
if head -30 design-demos/v4-d-hybrid.html | grep -qF -- "two unreconciled metaphors"; then pass "v4-d head records the two-metaphor audit (Entry 3)"; else drift "two-metaphor audit in v4-d head" "head comment changed — re-verify Entry 3 evidence"; fi
if head -30 design-demos/v4-d-hybrid.html | grep -qF -- "highest-priority fix"; then pass "v4-d head records the plate-gating fix (Entry 3)"; else drift "plate-gating fix note in v4-d head" "head comment changed — re-verify Entry 3"; fi

# --- Entry 4 (Konami rejection) ---
if head -30 design-demos/v4-d-hybrid.html | grep -qF -- "ubiquitous"; then pass "Konami-rejection rationale in v4-d head (Entry 4)"; else drift "Konami rationale in v4-d head" "head comment changed — re-verify Entry 4"; fi
file_has design-demos/js/roll-eggs.js "devBuf" "'develop' word-trigger in roll-eggs.js (Entry 4)" "egg trigger changed — update Entry 4"

# --- staleness watch for timeboxed items ---
NEWER=$(git log --oneline --since=2026-07-21 | wc -l | tr -d ' ')
if [ "$NEWER" -gt 0 ]; then
  manual "$NEWER commit(s) newer than 2026-07-20 — check git log and DECISIONS.md: the Lenis outcome or v4 winner may now be decided (Entries 1-2 status lines)"
else
  pass "no commits newer than 2026-07-20 (timeboxed statuses still current)"
fi

exit $FAIL
