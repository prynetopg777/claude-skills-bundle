#!/bin/bash
# verify.sh — drift check for pryne-design-direction-decision/SKILL.md.
# Read-only (grep/ls/git log/head). Exit 0 = no drift; 1 = drift found; 2 = repo missing.
REPO="${1:-$HOME/Documents/Coding Folder/Portfolio (test)}"
FAIL=0
pass()   { echo "PASS: $1"; }
drift()  { echo "DRIFT: $1 — $2"; FAIL=1; }
manual() { echo "MANUAL: $1"; }
file_has() { if grep -qF -- "$2" "$1" 2>/dev/null; then pass "$3"; else drift "$3" "$4"; fi; }
head_has() { # file substring label claim — search the head comment (first 30 lines)
  if head -30 "$1" | grep -qiF -- "$2"; then pass "$3"; else drift "$3" "$4"; fi
}

if [ ! -d "$REPO" ]; then
  echo "SKIP: repo not found at $REPO (pass repo path as \$1)"
  exit 2
fi
cd "$REPO" || exit 2
D=design-demos/DECISIONS.md

# --- live-instance candidates ---
for f in v4-a-midnight-issue v4-b-first-pressing v4-c-ch001 v4-d-hybrid; do
  if [ -f "design-demos/$f.html" ]; then pass "candidate $f.html exists"; else drift "candidate $f.html exists" "the Live instance table is stale — the candidate field changed"; fi
done

# --- organizing-concept sentences still anchored in head comments ---
head_has design-demos/v4-a-midnight-issue.html "Issue 01" "v4-a concept (magazine Issue 01)"      "v4-a head comment changed — update the concept table"
head_has design-demos/v4-b-first-pressing.html "record"    "v4-b concept (record/pressing)"        "v4-b head comment changed — update the concept table"
head_has design-demos/v4-c-ch001.html         "chapter"    "v4-c concept (serialized chapter)"     "v4-c head comment changed — update the concept table"
head_has design-demos/v4-d-hybrid.html        "roll of film" "v4-d concept (roll of film)"         "v4-d head comment changed — update the concept table"
head_has design-demos/v4-d-hybrid.html "two unreconciled metaphors" "v4-d records the two-metaphor audit (Phase 3 precedent)" "audit paragraph changed — re-verify Phase 3's quoted precedent"

# --- build-target claim ---
if git rev-parse --quiet --verify 1575051^{commit} >/dev/null 2>&1; then pass "commit 1575051 (ROLL 01 baseline) exists"; else drift "commit 1575051 exists" "history rewritten? build-target sourcing invalid"; fi
if git log --oneline | grep -q "Baseline: ROLL 01"; then pass "'Baseline: ROLL 01' commit message present"; else drift "'Baseline: ROLL 01' message" "build-target evidence line is stale"; fi

# --- gates this campaign depends on ---
file_has "$D" "cold, zero-interaction screenshot" "whisper checklist available for Phase 0" "DECISIONS.md checklist changed — Phase 0 gate needs re-verification"
file_has "$D" "PX Push, Cult, TRIONN, Lando Norris" "anchor reference sites for Phase 2" "benchmark set changed — update the anchor rule"

# --- has the decision since been made? ---
NDEC=$(grep -c "^## Decision" "$D" 2>/dev/null || echo 0)
if [ "$NDEC" -gt 1 ]; then
  manual "DECISIONS.md now has $NDEC decision entries — check whether a direction entry exists; if so, the Live instance section is historical"
else
  pass "no direction decision recorded yet (Live instance section still current)"
fi

exit $FAIL
