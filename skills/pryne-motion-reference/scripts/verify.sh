#!/bin/bash
# verify.sh — drift check for pryne-motion-reference/SKILL.md.
# Read-only (grep/sed/ls). Exit 0 = no drift; 1 = drift found; 2 = repo missing.
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

# --- §1 the loop ---
line_has $J/roll-scroll.js 166 "(function loop" "main rAF loop starts at roll-scroll.js:166" "loop moved — update §1 (cited 166-222)"
line_has $J/roll-scroll.js 167 "lenis.raf" "lenis.raf(t) at :167 (step 1)" "loop body changed — re-verify the §1 step table"
line_has $J/roll-scroll.js 188 "ambientGain.gain.value = audio.muted ? 0 :" "ambient gain + mute guard at :188 (step 7 / §4)" "formula changed — update §4 second bullet"
line_has $J/roll-scroll.js 196 "Roll.enhanced" "skew gated on Roll.enhanced at :196 (step 9)" "enhancement gate moved — update §1 step 9"
line_has $J/roll-scroll.js 207 "classList.contains('in')" "plates gated on .in at :207 (step 10)" "visibility gate moved — update §1 step 10"
line_has $J/roll-scroll.js 182 "* 0.92" "pulse decay 0.92 at :182 (step 5)" "decay constant changed — update §1 step 5"
line_has $J/roll-scroll.js 183 "* 0.88" "advance decay 0.88 at :183 (step 5)" "decay constant changed — update §1 step 5"

# --- §1 IO thresholds ---
line_has $J/roll-scroll.js 104 "threshold: 0.35" "panel reveal threshold 0.35 at :104" "threshold moved/changed — update §1 scroll-triggered examples"
line_has $J/roll-scroll.js 110 "threshold: 0.4" "climax threshold 0.4 at :110" "threshold moved/changed — update §1"
line_has $J/roll-scroll.js 124 "threshold: 0.05" "footer threshold 0.05 at :124" "threshold moved/changed — update §1"
line_has $J/roll-field.js 132 "threshold: 0.08" "field visibility threshold 0.08 at roll-field.js:132" "threshold moved/changed — update §5 perf note"

# --- §2 Lenis ---
if [ -f $J/vendor/lenis.min.js ]; then pass "Lenis vendored at js/vendor/lenis.min.js"; else drift "Lenis vendored" "§2 stale — check DECISIONS.md for the executed fallback"; fi
line_has $J/roll-scroll.js 152 "new Lenis({ duration: 1.1" "Lenis gated + duration 1.1 at :152" "instantiation changed — update §2"
file_has $J/roll-scroll.js "scrollY stays valid" "native-scroll comment (zero-swaps claim, cited 148-151)" "comment changed — re-verify the zero-swaps statement in §2"
file_has design-demos/DECISIONS.md "Minimal, isolated swap" "DECISIONS.md swap-ceiling constraint quoted in §2" "DECISIONS.md Lenis entry changed — re-verify §2"

# --- §3 primitives ---
line_has $J/roll-core.js 17 "Roll.clamp" "clamp at roll-core.js:17" "line moved — update §3 table"
line_has $J/roll-core.js 18 "Roll.lerp" "lerp at roll-core.js:18" "line moved — update §3 table"
line_has $J/roll-core.js 34 "function hash2" "hash2 at roll-core.js:34 (cited 34-40)" "noise functions moved — update §3 table"
file_has "$H" "--ease-out: cubic-bezier(0.22, 1, 0.36, 1)" "ease-out token" "easing token changed — update §3 table"
file_has "$H" "--ease-snap: cubic-bezier(0.16, 1, 0.3, 1)" "ease-snap token" "easing token changed — update §3 table"

# --- §4 shared signal ---
line_has $J/roll-shader.js 98 "uVel" "uVel uniform fed from tone at roll-shader.js:98" "uniform moved — update §4 first bullet"
file_has $J/roll-audio.js "same signal the shader reacts to" "roll-audio comment ties audio to shader signal (cited 18-20)" "comment changed — re-verify §4"

# --- §5 reduced motion + perf ---
line_has $J/roll-core.js 9 "prefers-reduced-motion" "Roll.reduced at roll-core.js:9" "capture point moved — update §5"
line_has $J/roll-core.js 12 "onMotionReady" "onMotionReady at roll-core.js:12 (cited 12-15)" "range moved — update §5"
line_has $J/roll-field.js 25 "1.5" "field DPR cap 1.5 at roll-field.js:25" "DPR cap changed — update §5 perf note"
line_has $J/roll-shader.js 81 "1.5" "shader DPR cap 1.5 at roll-shader.js:81" "DPR cap changed — update §5 perf note"
line_has $J/roll-core.js 55 ", 2)" "plate DPR cap 2 at roll-core.js:55" "DPR cap changed — update §5 perf note"

manual "active build still v4-d-hybrid.html: check design-demos/DECISIONS.md and the vault status note (vault owns direction)"

exit $FAIL
