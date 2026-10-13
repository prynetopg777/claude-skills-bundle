#!/bin/bash
# verify.sh — drift check for pryne-frontend-architecture/SKILL.md.
# Read-only (grep/sed/wc/ls). Exit 0 = no drift; 1 = drift found; 2 = repo missing.
REPO="${1:-$HOME/Documents/Coding Folder/Portfolio (test)}"
FAIL=0
pass()   { echo "PASS: $1"; }
drift()  { echo "DRIFT: $1 — $2"; FAIL=1; }
manual() { echo "MANUAL: $1"; }
line_has() { if sed -n "${2}p" "$1" | grep -qF -- "$3"; then pass "$4"; else drift "$4" "$5"; fi; }
file_has() { if grep -qF -- "$2" "$1" 2>/dev/null; then pass "$3"; else drift "$3" "$4"; fi; }
count_is() { # file expected label
  N=$(wc -l < "$1" | tr -d ' ')
  if [ "$N" = "$2" ]; then pass "$3 ($2 lines)"; else drift "$3" "module map says $2 lines, file has $N — update the module map table"; fi
}

if [ ! -d "$REPO" ]; then
  echo "SKIP: repo not found at $REPO (pass repo path as \$1)"
  exit 2
fi
cd "$REPO" || exit 2
J=design-demos/js
H=design-demos/v4-d-hybrid.html

# --- script order (the dependency graph) ---
ORDER=$(grep -o 'src="js/[^"]*"' "$H" | sed 's/src="js\///;s/"//' | tr '\n' ' ')
EXPECT="roll-core.js roll-shader.js roll-field.js roll-audio.js roll-cursor.js vendor/lenis.min.js roll-scroll.js roll-contact-sheet.js roll-eggs.js "
if [ "$ORDER" = "$EXPECT" ]; then pass "script load order matches the documented chain"; else drift "script load order" "chain changed — now: $ORDER; update the module-contract diagram"; fi

# --- module map line counts ---
count_is $J/roll-core.js 192 "roll-core.js"
count_is $J/roll-scroll.js 226 "roll-scroll.js"
count_is $J/roll-field.js 136 "roll-field.js"
count_is $J/roll-shader.js 133 "roll-shader.js"
count_is $J/roll-eggs.js 83 "roll-eggs.js"
count_is $J/roll-audio.js 79 "roll-audio.js"
count_is $J/roll-contact-sheet.js 55 "roll-contact-sheet.js"
count_is $J/roll-cursor.js 36 "roll-cursor.js"

# --- invariant 1: reduced-motion gates ---
line_has $J/roll-core.js 9 "prefers-reduced-motion" "Roll.reduced captured at roll-core.js:9" "cited line moved — update invariant 1"
line_has $J/roll-shader.js 90 "Roll.reduced" "shader gate at roll-shader.js:90" "cited line moved — update invariant 1"
line_has $J/roll-shader.js 124 "Roll.reduced" "shader 2D gate at roll-shader.js:124" "cited line moved — update invariant 1"
line_has $J/roll-field.js 125 "Roll.reduced" "field gate at roll-field.js:125" "cited line moved — update invariant 1"
line_has $J/roll-field.js 135 "Roll.reduced" "field gate at roll-field.js:135" "cited line moved — update invariant 1"
line_has $J/roll-contact-sheet.js 12 "Roll.reduced" "contact-sheet gate at roll-contact-sheet.js:12" "cited line moved — update invariant 1"
line_has $J/roll-scroll.js 152 "Roll.reduced" "scroll/Lenis gate at roll-scroll.js:152" "cited line moved — update invariants 1 and 7"
line_has "$H" 293 "prefers-reduced-motion" "CSS reduced-motion block at v4-d:293" "cited line moved — update invariant 1"

# --- invariant 2: GSAP progressive enhancement ---
line_has "$H" 440 "integrity=" "GSAP async+SRI tag at v4-d:440" "tag moved/changed — update invariant 2"
file_has "$H" "upgradeMotion" "GSAP onload calls upgradeMotion" "enhancement hook gone — invariant 2 stale"
line_has $J/roll-core.js 12 "onMotionReady" "Roll.onMotionReady at roll-core.js:12" "cited range 10-15 moved — update invariant 2"
line_has $J/roll-core.js 186 "upgradeMotion" "Roll.upgradeMotion at roll-core.js:186" "cited range 186-191 moved — update invariant 2"

# --- invariant 3: cursor try/catch ---
file_has $J/roll-cursor.js "catch (e) { Roll.cursorUpdate = null" "cursor setup catch restores safe state" "restoring catch changed — update invariant 3"
file_has $J/roll-cursor.js "catch (err) { Roll.cursorUpdate = null" "cursor per-event catch present (fixed 2026-07-22)" "per-event guard removed — invariant 3 regressed"
file_has $J/roll-core.js "catch (err) { Roll.cursorUpdate = null" "pointermove call-site catch present (fixed 2026-07-22)" "call-site guard removed — invariant 3 regressed"

# --- invariant 4: concept-C fix ---
line_has "$H" 121 "panel-inner { clip-path" "clip-path on .panel-inner at v4-d:121" "cited lines 121-122 moved — update invariant 4"
line_has "$H" 185 "climax-inner { clip-path" "clip-path on .climax-inner at v4-d:185" "cited lines 185-186 moved — update invariant 4"

# --- invariant 5: visibility gating ---
line_has $J/roll-scroll.js 207 "classList.contains('in')" "plate development gated on .in at roll-scroll.js:207" "cited range 204-219 moved — update invariant 5"

# --- invariant 6: WebGL hygiene ---
line_has $J/roll-shader.js 17 "premultipliedAlpha: false" "non-premultiplied alpha at roll-shader.js:17" "cited line moved — update invariant 6"
line_has $J/roll-shader.js 95 "gl.clear" "per-frame gl.clear at roll-shader.js:95" "cited line moved — update invariant 6"
line_has $J/roll-shader.js 130 "webglcontextlost" "context-lost handler at roll-shader.js:130" "cited range 129-132 moved — update invariant 6"

# --- invariant 7: Lenis native scroll ---
if [ -f $J/vendor/lenis.min.js ]; then pass "Lenis vendored"; else drift "Lenis vendored" "invariant 7 stale — check DECISIONS.md for the fallback entry"; fi
file_has $J/roll-scroll.js "scrollY stays valid" "native-scroll comment present in roll-scroll.js" "zero-swap claim's code comment changed — re-verify invariant 7"

# --- tokens ---
line_has "$H" 51 "--bg: #0a0a0b" "token block starts at v4-d:51 (cited 50-63)" "token block moved — update the tokens section"
file_has "$H" "--accent: #d2232e" "accent token unchanged" "accent token changed — update the tokens excerpt"
file_has "$H" "--ease-out: cubic-bezier(0.22, 1, 0.36, 1)" "ease-out token unchanged" "easing token changed — update tokens excerpt and pryne-motion-reference"

# --- weak points still true ---
line_has "$H" 47 "fonts.googleapis.com" "fonts still CDN (weak-points note)" "fonts may be self-hosted now — update Known weak points (good news)"
manual "active build still v4-d: check design-demos/DECISIONS.md and latest git log"

exit $FAIL
