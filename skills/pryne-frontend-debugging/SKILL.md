---
name: pryne-frontend-debugging
description: Use when a Pryne demo page misbehaves - animations fire before their section is visible, a reveal clips wrongly, the OS cursor vanishes, WebGL shows ghosting or wrong blending, scroll choreography goes dead while the page otherwise works, all motion is dead for one user, scroll feel differs across devices, hover/kinetic effects are missing, scrolling feels janky or slow, audio is silent, or any console error appears. Covers the vanilla-JS window.Roll module builds (roll-*.js) in design-demos.
---

# Pryne Frontend Debugging Playbook

Symptom→triage for Pryne's vanilla-JS demo builds: single-file HTML pages driven by a `window.Roll` module spine (`design-demos/js/roll-*.js`), a WebGL grain shader with 2D fallback, one rAF render loop, vendored Lenis smooth-scroll, and GSAP loaded async from CDN as a progressive enhancement.

**REQUIRED BACKGROUND:** superpowers:systematic-debugging owns the generic root-cause discipline (no fixes without investigation). Follow it; this skill only supplies the project-specific symptom table and traps.

**Tooling:** for how to drive the browser, capture consoles, emulate reduced-motion, and take traces, use pryne-browser-lab. This skill assumes you can already run those commands.

## Read the head comment first

Every v4 demo (`v4-a` through `v4-d` in `design-demos/`) carries its audit history as an HTML comment at the very top of the file — what was found broken, what was fixed, and why. Verified across all four files as of 2026-07-22. **Before re-diagnosing anything, `head -30` the demo you're debugging.** Several "bugs" you will find are documented as already-fixed regressions; if one is back, you're looking for what reverted it, not a new cause.

Also know the build layout (as of 2026-07-22): only `v4-d-hybrid.html` uses the shared `roll-*.js` modules. `v4-a/b/c` are scoped-down comparison builds with their own inline JS — this table's Roll-specific checks don't apply to them, but the same failure classes do.

## Zero console errors is the resting state

The standard is zero console errors (the CRITIQUE rubric in `design-demos/DECISIONS.md` requires it). v3 was verified at zero per the project status log; the v4 variants are uncertified pending the direction campaign (`pryne-design-direction-decision`). Any console error is a defect to be triaged, never ambient noise to scroll past.

## Symptom → triage table

| Symptom | Likely cause | Discriminating check |
|---|---|---|
| Animation/develop-plate runs (or finishes) before its section is scrolled into view | Visibility-gating regression. The v4-d head comment records this as the single highest-priority audit fix: feature plates "ticked unconditionally from page load and finished resolving before anyone scrolled to them." Development must be gated on the panel's `.in` class. | Experiment 1 below |
| Reveal animation clips wrongly, jumps, or never triggers | `clip-path` applied to the element the IntersectionObserver watches, instead of an inner wrapper. The concept-C fix (carried into v4-d, per its head comment): the clip-path reveal lives on an inner wrapper, **never** on the observed element. | Inspect the element: is the observed node and the clipped node the same node? |
| OS cursor disappears, no custom cursor replaces it | Should not recur — **fixed 2026-07-22** (found by a cold-test audit, fixed same day): the per-event handler (`roll-cursor.js:17-20`) and its `pointermove` call site (`roll-core.js:26-29`) now both catch-and-restore (null `Roll.cursorUpdate`, remove `.custom-cursor`), on top of the original setup-time catch; `#cur`/`#ring` z-index raised 50→70 above `#flash` (60) so the climax pulse can't paint over the cursor. If the symptom reappears, one of those guards regressed or new code hides the cursor outside this contract. | `document.body.classList.contains('custom-cursor')` vs `Roll.cursorUpdate` — `true`/`null` together is the broken state; if both look intact, check `getComputedStyle(cur).opacity` and whether it vanishes only at the climax flash |
| WebGL ghosting/trails, or colors blend wrong against the page | Missing per-frame clear, or premultiplied-alpha mismatch. `roll-shader.js` calls `gl.clear(gl.COLOR_BUFFER_BIT)` every frame and creates the context with `{ alpha: true, premultipliedAlpha: false }` (both audit fixes, per the v4-d head comment). | Diff `roll-shader.js` against git: `git diff HEAD -- design-demos/js/roll-shader.js` |
| Shader canvas blank, no grain at all | (a) Reduced motion — GL is intentionally never set up (`useGL = !Roll.reduced && setupGL()`); (b) WebGL context lost — the `webglcontextlost` handler sets the canvas to opacity 0 and fails quiet; (c) a 2D context was acquired before WebGL got its chance (one context per canvas, ever — documented at the top of `roll-shader.js`). | `Roll.reduced` first. For context loss, check the handler's observable effect: `getComputedStyle(document.getElementById('tone')).opacity === '0'`. Caveat: `Roll.shader.useGL` is a setup-time snapshot (`roll-shader.js:120-121`) — the `webglcontextlost` handler flips only the closure variable (`roll-shader.js:130-132`), so `Roll.shader.useGL` stays `true` after context loss; don't use it to rule loss out |
| Scroll choreography dead but the page renders and scrolls fine | Script load-order or `window.Roll` namespace break. Script order is load-bearing — the chain and check commands live in **pryne-frontend-architecture**. Every module is an IIFE sharing state only via `window.Roll`; one thrown error in an early module starves everything after it. | Experiment 2 below; console will show `Roll.X is undefined` naming the starved module |
| All motion dead for one user report; fine on your machine | `prefers-reduced-motion` is active for them. This is **correct behavior**, not a bug: `roll-core.js` sets `Roll.reduced` from the media query, and every module gates on it (cover removed, plates render fully developed instantly, Lenis skipped, shader off). Do not "fix" it. | Experiment 3 below |
| Scroll feel inconsistent across trackpad/wheel/touch | Raw scroll-delta variance — the documented rationale for vendoring Lenis (see `design-demos/DECISIONS.md`). Lenis wraps native scrolling, so `window.scrollY` stays valid; it's a feel upgrade only, null under reduced motion. | `typeof Lenis` (loaded?), then check the demo constructs it in its scroll module |
| Baseline works but hover/kinetic/cursor polish missing | GSAP CDN failed or was blocked. GSAP loads `async` from jsdelivr (SRI-pinned) and flips `Roll.enhanced = true` via `Roll.upgradeMotion()` only when it lands. Progressive enhancement is by design: baseline choreography must still work without it. If baseline is *also* broken, this is not your cause. | Experiment 4 below |
| Audio silent | Muted is the default: `roll-audio.js` starts muted, persists the choice in `localStorage['ch001_muted']`, and only starts the ambient hum from the `#mute-toggle` click (a user gesture, satisfying autoplay policy). All synthesis is try/catch-wrapped and asset-free. Check the SND toggle state before suspecting the code. | `Roll.audio.muted`, and `localStorage.getItem('ch001_muted')` |
| Fixed HUD overlaps/obscures the footer | Regression of the footer-fade fix: an IntersectionObserver on `footer` toggles `.faded` on the beat-meter and mute button (`roll-scroll.js`). | Scroll to footer; check `.faded` appears on `#beatmeter` |

## Discriminating experiments

Run these in the page console or via `evaluate_script` (see pryne-browser-lab). Each answers one question before you touch code.

**1 — Is plate development correctly gated on visibility?**

```js
({ workVisible: document.getElementById('work').classList.contains('in'),
   plate1: { d: Roll.featurePlate.d, done: !!Roll.featurePlate.done },
   plate2: { d: Roll.featurePlate2.d, done: !!Roll.featurePlate2.done } })
```

On a fresh load, before scrolling to the work section: `workVisible: false` and both `d` values near 0. If `d` is climbing (or `done: true`) while `workVisible` is false, the gating regressed.

**2 — Is the Roll spine intact?**

```js
({ core: !!window.Roll, reduced: Roll?.reduced, enhanced: Roll?.enhanced,
   shader: !!Roll?.shader, audio: !!Roll?.audio, plates: !!Roll?.plates,
   cursorUpdate: Roll?.cursorUpdate === null ? 'null' : typeof Roll?.cursorUpdate })
```

Note on `cursorUpdate`: it is *initialized* null (`roll-core.js:23`) and is also null before GSAP loads and on non-`pointer: fine` devices — null alone proves nothing. "Failed-safe" is indicated only when `document.body.classList.contains('custom-cursor')` is true **and** `cursorUpdate` is null (see the cursor row in the triage table).

Any `false`/`undefined` names the module that didn't finish — check the console for the error it threw, and check script order in the HTML against the load-bearing order above.

**3 — Is "all motion dead" just reduced-motion?**

```js
({ mediaQuery: matchMedia('(prefers-reduced-motion: reduce)').matches, roll: Roll.reduced })
```

Both `true` → working as designed; reproduce the report by emulating reduced-motion (pryne-browser-lab). `mediaQuery: true` but `roll: false` (or vice versa) → a module is reading the wrong source of truth.

**4 — Did the GSAP enhancement layer load?**

```js
({ gsapLoaded: !!window.gsap, enhanced: Roll.enhanced, reduced: Roll.reduced })
```

`gsapLoaded: false` → CDN blocked/failed (check the network panel for the jsdelivr request; SRI mismatch also lands here). `gsapLoaded: true, enhanced: false, reduced: false` → `upgradeMotion()` didn't run — check the script tag's `onload` hook.

## Traps that cost real time

| Trap | The story (one line) | The fence |
|---|---|---|
| "Verified working" ≠ right direction | v3 NIGHT DRIVE was fully built, zero console errors, verified — then superseded because the unifying concept was wrong (full account: pryne-failure-archaeology). | Don't spend polish/debug effort defending a build whose concept hasn't been confirmed as the current direction. Check `DECISIONS.md` and the vault status first. |
| Re-diagnosing a documented fix | Every v4 head comment is a changelog of already-found, already-fixed defects. | Read the head comment before opening devtools. If a listed fix appears broken, hunt the revert, not the symptom. |
| "Fixing" reduced-motion | All motion off is the designed behavior for `prefers-reduced-motion` users, gated in one place (`Roll.reduced`). | Run experiment 3 before treating a no-motion report as a defect. |
| Acquiring a 2D context "to test something" | A canvas can only ever have one context type; grabbing 2D first silently makes WebGL impossible on that canvas forever (documented in `roll-shader.js`). | Never call `getContext('2d')` on `#tone` in console experiments. |

## When NOT to use this skill

- **Generic debugging discipline** (hypotheses, minimal changes, root-cause-before-fix) → superpowers:systematic-debugging.
- **How to drive the browser/measure** (MCP tool anatomy, traces, Lighthouse, screenshots) → pryne-browser-lab.
- **Deciding whether behavior violates a design invariant** (reduced-motion gating, whisper-level personality, vendoring) → pryne-frontend-architecture.
- **The full history of why something was built/reverted** → pryne-failure-archaeology.
- **Other stacks** (React/framework builds, non-Pryne projects): the table above is specific to the `window.Roll` demo family; only the generic discipline transfers.

## Provenance and maintenance

Run `scripts/verify.sh` (in this skill's directory) to check all of the below at once.

Facts current as of 2026-07-22, verified against repo `~/Documents/Coding Folder/Portfolio (test)` at commit 457868a. Re-verify before trusting:

- Module list & sizes: `wc -l design-demos/js/*.js`
- Script load order: `grep -n "<script" design-demos/v4-d-hybrid.html`
- Which demos use the shared modules: `grep -l "roll-core.js" design-demos/*.html`
- Head-comment convention still holds: `for f in design-demos/v4-*.html; do echo "== $f"; head -5 "$f"; done`
- Reduced-motion gate: `grep -n "prefers-reduced-motion\|Roll.reduced" design-demos/js/*.js`
- Plate visibility gating: `grep -n "classList.contains('in')" design-demos/js/roll-scroll.js`
- Lenis vendored & wired: `ls design-demos/js/vendor/ && grep -n "new Lenis" design-demos/js/roll-scroll.js`
- GSAP enhancement hook: `grep -n "upgradeMotion" design-demos/js/roll-core.js design-demos/v4-d-hybrid.html`
- Audio mute default & storage key: `grep -n "ch001_muted" design-demos/js/roll-audio.js`
- Zero-console-error bar: `grep -n "console errors" design-demos/DECISIONS.md`
