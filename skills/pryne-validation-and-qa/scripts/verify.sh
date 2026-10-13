#!/bin/bash
# verify.sh — drift check for pryne-validation-and-qa/SKILL.md.
# Read-only (grep/ls). Exit 0 = no drift; 1 = drift found; 2 = repo missing.
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
D=design-demos/DECISIONS.md

# --- rubrics quoted from DECISIONS.md ---
file_has "$D" "BUILD→RUN→CRITIQUE→AUDIT→FIX" "working-loop name in DECISIONS.md" "loop renamed — update the loop section"
file_has "$D" "PX Push, Cult, TRIONN, Lando Norris" "4 reference benchmark sites" "benchmark set changed — update the rubric intro"
for dim in "Craft" "Motion/interaction" "Storytelling" "Restraint" "Performance"; do
  file_has "$D" "$dim" "rubric dimension '$dim'" "rubric dimensions changed — re-copy the CRITIQUE table"
done
file_has "$D" "Lighthouse perf ≥90 / a11y ≥95" "Lighthouse thresholds ≥90/≥95" "thresholds changed — update Hard acceptance thresholds"
file_has "$D" "Zero console errors" "zero-console-errors bar" "performance row changed — update thresholds"

# --- whisper checklist (this skill owns the full copy) ---
file_has "$D" "cold, zero-interaction screenshot" "whisper item 1" "checklist text changed — re-copy all 4 items from DECISIONS.md"
file_has "$D" "hover-hold, long-press" "whisper item 2 trigger list" "checklist text changed — re-copy all 4 items"
file_has "$D" "premium, professional software product" "whisper item 3" "checklist text changed — re-copy all 4 items"
file_has "$D" "recognize a reference as a reference" "whisper item 4" "checklist text changed — re-copy all 4 items"

# --- golden inventory ---
PNGS=$(ls design-demos/*.png 2>/dev/null | wc -l | tr -d ' ')
if [ "$PNGS" = "19" ]; then pass "golden PNG inventory count is 19"; else drift "golden PNG count (19)" "inventory now $PNGS files — re-list the certified/golden section"; fi
for p in demo-desktop-full.png v2-desktop-hero.png v3-hero.png 1-cursor.png; do
  if [ -f "design-demos/$p" ]; then pass "inventory spot-check: $p"; else drift "inventory spot-check: $p" "a listed golden artifact is missing — re-list the inventory"; fi
done

# --- still no test harness ---
if [ -f package.json ] || [ -d tests ] || [ -d test ]; then
  drift "no automated test suite" "a test harness appeared — the 'known gap' paragraph is stale (good news; update it)"
else
  pass "no test harness present (known-gap claim holds)"
fi

exit $FAIL
