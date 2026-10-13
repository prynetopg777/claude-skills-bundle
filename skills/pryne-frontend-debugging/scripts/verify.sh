#!/bin/bash
# verify.sh — drift check for pryne-frontend-debugging/SKILL.md.
# Read-only (grep/sed/head). Exit 0 = no drift; 1 = drift found; 2 = repo missing.
REPO="${1:-$HOME/Documents/Coding Folder/Portfolio (test)}"
FAIL=0
pass()   { echo "PASS: $1"; }
drift()  { echo "DRIFT: $1 — $2"; FAIL=1; }
manual() { echo "MANUAL: $1"; }
line_has() { if sed -n "${2}p" "$1" | grep -qF -- "$3"; then pass "$4"; else drift "$4" "$5"; fi; }
file_has() { if grep -qF -- "$2" "$1" 2>/dev/null; then pass "$3"; else drift "$3" "$4"; fi; }

if [ ! -d "$REPO" ]; then
  echo "SKIP: repo not found at $REPO (pass repo path as \$1)"
  exit 2
fi
cd "$REPO" || exit 2
J=design-demos/js
H=design-demos/v4-d-hybrid.html

# --- head-comment convention + build layout ---
for f in design-demos/v4-*.html; do
  if head -1 "$f" | grep -q "<!--"; then pass "head comment present: $f"; else drift "head comment on $f" "'read the head comment first' convention broke for this file"; fi
done
SHARED=$(grep -l "roll-core.js" design-demos/*.html 2>/dev/null)
if [ "$SHARED" = "design-demos/v4-d-hybrid.html" ]; then
  pass "only v4-d uses shared roll-*.js (build-layout note)"
else
  drift "only v4-d uses shared modules" "build layout changed (now: $SHARED) — update the layout note and which builds the table applies to"
fi

# --- triage-table facts ---
line_has $J/roll-scroll.js 207 "classList.contains('in')" "plate visibility gating (row 1 / experiment 1)" "gating moved — re-verify row 1"
file_has "$H" "panel-inner { clip-path" "clip-path on inner wrapper (row 2)" "concept-C structure changed — re-verify row 2"
file_has $J/roll-cursor.js "catch (e) { Roll.cursorUpdate = null" "cursor restoring catch (row 3)" "cursor fail-safe contract changed — re-verify row 3"
line_has $J/roll-shader.js 95 "gl.clear" "per-frame clear (row 4)" "shader hygiene changed — re-verify row 4"
line_has $J/roll-shader.js 17 "premultipliedAlpha: false" "non-premultiplied alpha (row 4)" "shader hygiene changed — re-verify row 4"
line_has $J/roll-shader.js 90 "useGL = !Roll.reduced" "useGL setup gate (row 5a)" "setup gate moved — re-verify row 5"
line_has $J/roll-shader.js 120 "Roll.shader = {" "Roll.shader snapshot object at :120-121 (row 5 caveat)" "snapshot caveat lines moved — re-verify the useGL caveat"
line_has $J/roll-shader.js 130 "webglcontextlost" "context-lost handler at :130 (row 5b)" "handler moved — re-verify row 5 and the opacity check"
file_has "$H" 'id="tone"' "#tone canvas exists (row 5 opacity check target)" "canvas id changed — the getComputedStyle discriminator is stale"
line_has $J/roll-core.js 9 "prefers-reduced-motion" "Roll.reduced source (rows 6-7)" "flag moved — re-verify rows 6-7"
file_has $J/roll-scroll.js "new Lenis" "Lenis constructed in scroll module (row 8)" "Lenis wiring changed — re-verify row 8"
file_has "$H" "upgradeMotion" "GSAP onload hook (row 9 / experiment 4)" "enhancement hook changed — re-verify row 9"
file_has $J/roll-audio.js "ch001_muted" "mute persistence key (row 10)" "storage key changed — update row 10 and experiment snippet"
file_has $J/roll-scroll.js "faded" ".faded footer-fade fix (row 11)" "footer-fade fix changed — re-verify row 11"
file_has "$H" "beatmeter" "#beatmeter HUD element (row 11)" "HUD id changed — re-verify row 11"

# --- experiment snippets ---
line_has $J/roll-core.js 167 "Roll.featurePlate" "Roll.featurePlate at roll-core.js:167 (experiment 1)" "plate property moved — update experiment 1"
line_has $J/roll-core.js 168 "Roll.featurePlate2" "Roll.featurePlate2 at roll-core.js:168 (experiment 1)" "plate property moved — update experiment 1"
line_has $J/roll-core.js 23 "Roll.cursorUpdate = null" "cursorUpdate init at roll-core.js:23 (experiment 2 note)" "init moved — update experiment 2 note"
file_has design-demos/DECISIONS.md "console errors" "zero-console-error bar in DECISIONS.md" "rubric wording changed — re-verify the resting-state section"
line_has $J/roll-cursor.js 20 "catch (err) { Roll.cursorUpdate = null" "per-event cursor catch at roll-cursor.js:20 (cursor row: fixed 2026-07-22)" "guard moved/removed — cursor row status may be stale"
line_has $J/roll-core.js 28 "catch (err) { Roll.cursorUpdate = null" "call-site cursor catch at roll-core.js:28 (cursor row)" "guard moved/removed — cursor row status may be stale"
line_has "$H" 261 "z-index: 70" "#cur/#ring z-index 70 at v4-d:261 (cursor row)" "z-index changed — cursor row and flash-occlusion note may be stale"

exit $FAIL
