#!/bin/bash
# verify.sh — drift check for pryne-change-control/SKILL.md.
# Read-only (grep/ls/sed/git log). Exit 0 = no drift; 1 = drift found; 2 = repo missing.
REPO="${1:-$HOME/Documents/Coding Folder/Portfolio (test)}"
FAIL=0
pass()   { echo "PASS: $1"; }
drift()  { echo "DRIFT: $1 — $2"; FAIL=1; }
manual() { echo "MANUAL: $1"; }
line_has() { if sed -n "${2}p" "$1" | grep -qF -- "$3"; then pass "$4"; else drift "$4" "$5"; fi; }
file_has() { if grep -qF -- "$2" "$1" 2>/dev/null; then pass "$3"; else drift "$3" "$4"; fi; }

# --- repo-independent checks ---
for sib in pryne-validation-and-qa pryne-failure-archaeology pryne-docs-and-writing pryne-design-direction-decision pryne-frontend-architecture pryne-project-onboarding; do
  if [ -f "$HOME/.claude/skills/$sib/SKILL.md" ]; then pass "sibling skill $sib exists"; else drift "sibling skill $sib exists" "cross-references in SKILL.md point to a missing sibling"; fi
done
manual "plugin skills (superpowers:verification-before-completion, ecc:architecture-decision-records) can't be checked from bash — confirm in-session they still appear in the skill list"

if [ ! -d "$REPO" ]; then
  echo "SKIP: repo not found at $REPO (pass repo path as \$1)"
  exit 2
fi
cd "$REPO" || exit 2

# --- DECISIONS.md quotes the skill relies on ---
D="design-demos/DECISIONS.md"
if [ -f "$D" ]; then pass "DECISIONS.md exists"; else drift "DECISIONS.md exists" "non-negotiable 4 and the checklist assume it"; fi
file_has "$D" "Self-hosted (vendored file), not CDN" "vendoring rationale quote (non-negotiable 1)" "quote in non-negotiable 1 no longer matches DECISIONS.md"
file_has "$D" "cold, zero-interaction screenshot" "whisper checklist first item (non-negotiable 2)" "quoted first checklist item changed in DECISIONS.md"
file_has "$D" "disproportionate regressions" "Lenis timebox/fallback quote (non-negotiable 5)" "quoted fallback sentence changed in DECISIONS.md"
file_has "$D" "Previously all status lived only in the Obsidian vault" "vault-only-status admission (non-negotiable 4 incident)" "quoted incident line changed in DECISIONS.md"

# --- code facts ---
line_has design-demos/js/roll-core.js 9 "prefers-reduced-motion" "Roll.reduced at roll-core.js:9 (non-negotiable 3)" "cited line moved — update the file:line in non-negotiable 3"
line_has design-demos/v4-d-hybrid.html 47 "fonts.googleapis.com" "Google Fonts CDN drift still present at v4-d:47 (known-drift note)" "font CDN drift may be fixed — update the known-drift note in non-negotiable 1 (good news, verify lines 47-48)"
line_has design-demos/v4-d-hybrid.html 440 "cdn.jsdelivr.net/npm/gsap" "GSAP CDN tag at v4-d:440 (sanctioned-exception model)" "GSAP tag moved/changed — update the sanctioned-exception example line ref"
line_has design-demos/v4-d-hybrid.html 440 "integrity=" "GSAP tag carries SRI integrity hash" "SRI hash removed — the sanctioned-exception pattern claim is stale"
if [ -f design-demos/js/vendor/lenis.min.js ]; then pass "Lenis vendored at js/vendor/lenis.min.js"; else drift "Lenis vendored" "vendoring example in non-negotiable 1 is stale — check DECISIONS.md for a fallback entry"; fi
if git rev-parse --quiet --verify 457868a^{commit} >/dev/null 2>&1; then pass "provenance commit 457868a exists"; else drift "provenance commit 457868a exists" "history rewritten? provenance baseline invalid"; fi

exit $FAIL
