---
name: pryne-motion-reference
description: Use when working on scroll-linked animation, smooth-scroll (Lenis), scroll velocity effects, WebGL/canvas grain shaders, kinetic type, reduced-motion gating, or easing choices in Pryne's front-end builds — or when a term like "choreography spine", "develop plate", or "rAF loop" appears in code or docs and you need the domain theory behind it.
---

# Pryne Motion Reference

The domain knowledge pack for scroll choreography as practiced in Pryne's builds. Facts below are grounded in the Portfolio repo (`~/Documents/Coding Folder/Portfolio (test)`, active build `design-demos/v4-d-hybrid.html` + `design-demos/js/roll-*.js`) as of 2026-07-22.

**When NOT to use this skill:**
- Module structure, load order, the `window.Roll` namespace, or the concept-C clip-path rule → use **pryne-frontend-architecture** (it owns structure; this skill owns motion theory).
- Evidence standards, Lighthouse thresholds, rubric scoring → use **pryne-validation-and-qa**.
- General motion principles (timing scales, Disney principles) → the vendored **motion-design** skill. GSAP API details → **gsap-skills:\***. React/Next animation patterns → **ecc:motion-patterns**. Don't reload those here; this skill is only the delta specific to Pryne's codebases.

## 1. The scroll-linked animation model

**Core idea:** one `requestAnimationFrame` (rAF) loop per page reads scroll position every frame and drives *all* choreography from shared state. Nothing animates on its own timeline against the scroll; everything is a function of where the user is and how fast they're moving.

The real loop lives at `roll-scroll.js:166–222` (an IIFE named `loop`). Per frame it:

| Step | What it does | Where it writes |
|---|---|---|
| 1 | `lenis.raf(t)` if Lenis is active | (drives smooth scroll) |
| 2 | `dy = scrollY - lastY` → velocity `vel = Math.abs(dy)` | local |
| 3 | Lerps velocity into a smoothed 0–1 "tone" signal | `Roll.panelState.tone` |
| 4 | Fires one-time flashbulb pulse when climax section enters | `panelState.pulse`, `#flash` opacity |
| 5 | Decays transient signals (`pulse *= 0.92`, `advance *= 0.88`) | `panelState` |
| 6 | Renders the grain shader | `Roll.shader.render(t)` |
| 7 | Sets ambient audio gain from tone | `Roll.audio.ambientGain` |
| 8 | Updates frame-counter HUD (scroll progress → "Frame N of 36") | DOM |
| 9 | Applies velocity-driven `skewX` to headings (clamped ±1.6°, only if `Roll.enhanced`) | inline transforms |
| 10 | Advances feature "develop plates" — only while their panel has class `in` | plate canvases |

**Two distinct mechanisms — don't conflate them:**
- **Scroll-linked** (continuous): value is a pure function of scroll position/velocity, updated every frame. Examples: tone, frame counter, skew.
- **Scroll-triggered** (discrete): an `IntersectionObserver` (IO — a browser API that reports when an element crosses into the viewport, without scroll-event polling) fires once at a threshold. Examples: panel `.in` reveals (threshold 0.35), climax aura (0.4), footer HUD fade (0.05), film-advance beat on section crossings.

The film-advance transition (`roll-scroll.js:86–93`) deliberately *only reads* IO state and never touches scroll position itself, so it can't fight native input. Preserve that property in any new transition.

## 2. Why Lenis exists (smooth scroll)

Raw scroll deltas differ across trackpad, mouse wheel, and touch — a wheel "tick" is a large jump, trackpad is fine-grained. Any effect driven by per-frame scroll delta (step 2 above) therefore feels inconsistent across input devices. That is the exact rationale recorded in `design-demos/DECISIONS.md` for reintroducing Lenis: `roll-scroll.js` is a scroll-linked choreography spine, the case where delta inconsistency is most visible.

**What Lenis does:** intercepts scroll input and interpolates the page's real scroll position toward the target over time (here `duration: 1.1`, cubic ease-out `t => 1 - Math.pow(1 - t, 3)`), producing smooth, device-independent deltas. Crucially, as the code comment at `roll-scroll.js:148–151` states, real native scrolling still happens under the hood — **`window.scrollY` stays valid**, so the loop keeps reading `scrollY` directly; Lenis is purely a feel upgrade, not a rewiring. (DECISIONS.md allows at most a "minimal, isolated swap" of scroll reads; the shipped implementation needed zero swaps.)

Operational constraints (all from DECISIONS.md, all verified in code):
- **Vendored, not CDN:** `design-demos/js/vendor/lenis.min.js`, loaded before `roll-scroll.js` (script order in `v4-d-hybrid.html:434–435`).
- **Reduced-motion gated:** `const lenis = Roll.reduced ? null : new Lenis(...)` (`roll-scroll.js:152`).
- **Timeboxed:** if Lenis causes disproportionate regressions, the documented fallback is native `scroll-behavior: smooth` (already set on `html` in the CSS) — remove the instantiation and the `lenis.raf(t)` call, nothing else depends on it. Executing the fallback is a class-4 change under **pryne-change-control** — record the outcome in DECISIONS.md; don't remove it silently.

## 3. Core primitives (the repo's own implementations)

| Primitive | Definition | Where |
|---|---|---|
| `clamp(v, a, b)` | Pin a value to a range | `roll-core.js:17` |
| `lerp(a, b, t)` | Linear interpolation: `a + (b-a)*t`. Called every frame with small `t` (e.g. 0.08), it becomes an exponential smoother — the standard way this codebase softens any raw signal | `roll-core.js:18` |
| `hash2` / `noise2` | 2D value noise (smooth pseudo-random field). Deliberately the *same math family* as the WebGL grain shader's `hash`/`noise` (`roll-shader.js:24–31`), so canvas develop-plates and the GL grain resolve through visually matching drifting noise | `roll-core.js:34–40` |
| Easing tokens | CSS custom properties, the shared easing language for all CSS transitions: `--ease-out: cubic-bezier(0.22, 1, 0.36, 1)`, `--ease-snap: cubic-bezier(0.16, 1, 0.3, 1)` | `v4-d-hybrid.html` `:root` |

Rule of thumb: new CSS motion uses the existing easing tokens; new JS motion uses `lerp` smoothing against a `panelState` signal. Inventing a third easing vocabulary breaks the "one easing language" coherence.

## 4. One physical signal, many facets

The smoothed scroll-velocity signal `panelState.tone` drives, simultaneously:
- **Shader grain intensity** — uploaded as the `uVel` uniform (`roll-shader.js:98`);
- **Ambient audio level** — `ambientGain.gain.value = audio.muted ? 0 : clamp(tone * 0.05, 0, 0.05)` (`roll-scroll.js:188` — note the mute guard), noted in `roll-audio.js:18–20` as "the same signal the shader reacts to";
- **Beat-meter HUD readout** (`bm-tone` text);
- **Develop-plate speed** — velocity accelerates plate development (`+ vel * 0.0009`).

This is the house principle: **derive many facets from one physical signal** rather than giving each effect its own trigger. It's what makes choreography feel "physically coherent" — the quality the CRITIQUE rubric's Motion/interaction dimension scores (see pryne-validation-and-qa). When adding an effect, first ask which existing `panelState` signal it should be a facet of; only add a new signal if none fits.

## 5. Reduced-motion discipline

`prefers-reduced-motion` is a user OS/browser setting requesting minimal animation (vestibular disorders make large motion physically unpleasant). Honoring it is an accessibility requirement, not a preference.

Captured once at `roll-core.js:9`: `Roll.reduced = matchMedia('(prefers-reduced-motion: reduce)').matches`. Every module gates on it — the per-module gate inventory (with file:line) is owned by **pryne-frontend-architecture**, invariant 1. Behaviorally: the cover entry is removed entirely, plates render fully developed, the launch event fires immediately, Lenis is not instantiated, and the shader and hero field never start.

**The invariant: reduced-motion users get a complete, readable page — content is never gated behind an animation they'll never see.** Any new motion module must have a `Roll.reduced` branch that short-circuits to the final state. (The related structural rule — clip-path reveals live on an inner wrapper, never on the IO-observed element — is owned by pryne-frontend-architecture.)

Also note the progressive-enhancement split: `Roll.enhanced` flips true only when GSAP loads from CDN (`Roll.onMotionReady`, `roll-core.js:12–15`); baseline motion works without it. Perf patterns worth copying: hero field throttles to ~30fps and pauses when offscreen via IO (`roll-field.js:123–126, 132`); the field and shader canvases cap `devicePixelRatio` at 1.5 (`roll-field.js:25`, `roll-shader.js:81`), develop-plates at 2 (`roll-core.js:55`).

## 6. Glossary

| Term | Meaning here |
|---|---|
| rAF | `requestAnimationFrame` — browser callback before each repaint (~60/s); the only correct place for per-frame animation work |
| Scroll-linked | Continuous: value computed from scroll position/velocity every frame |
| Scroll-triggered | Discrete: fires once when an IntersectionObserver threshold is crossed |
| lerp | Linear interpolation; applied per-frame with small `t`, an exponential smoother |
| Easing | The rate-of-change curve of a transition (e.g. `cubic-bezier`); this codebase has exactly two CSS tokens |
| Value noise | Smooth pseudo-random 2D field; drives grain and develop-plate dissolve |
| Develop plate | Canvas image that resolves from noise to clarity as its `d` (0–1) rises; engine in `roll-core.js` |
| Progressive enhancement | Baseline works with no GSAP/WebGL/audio; libraries upgrade feel when available |
| HUD | The fixed overlay instruments (beat meter, frame counter, mute toggle) |
| Choreography spine | `roll-scroll.js` — the file owning the main loop and scroll beats |

## Provenance and maintenance

Run `scripts/verify.sh` (in this skill's directory) to check all of the below at once.

Grounded in repo state at commit `457868a` (2026-07-22). Re-verify before trusting:

- Main loop still at `roll-scroll.js:166`: `grep -n "function loop\|(function loop" design-demos/js/roll-scroll.js`
- Lenis still vendored + gated: `ls design-demos/js/vendor/ && grep -n "new Lenis" design-demos/js/roll-scroll.js`
- Reduced-motion gates intact: `grep -rn "Roll.reduced" design-demos/js/`
- Easing tokens unchanged: `grep -n "ease-out\|ease-snap" design-demos/v4-d-hybrid.html | head -3`
- Shared-signal wiring: `grep -n "uVel\|ambientGain.gain.value" design-demos/js/roll-shader.js design-demos/js/roll-scroll.js`
- Active build is still `v4-d-hybrid.html`: check `design-demos/DECISIONS.md` and the Obsidian vault status note (vault is source of truth for direction).
