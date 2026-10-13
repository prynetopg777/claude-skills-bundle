---
name: pryne-frontend-architecture
description: Use when adding, editing, reordering, or reviewing JavaScript modules or HTML structure in one of Pryne's vanilla-JS demo builds (files like design-demos/*.html and js/roll-*.js, or any window.<Namespace> IIFE-module site), when deciding where new interactive code should live, or when a change might touch script order, reduced-motion gating, progressive enhancement, or CSS design tokens.
---

# Pryne Frontend Architecture Contract

The load-bearing structural decisions of Pryne's vanilla-JS builds, why they exist, and the invariants you must not break. Reference implementation: `design-demos/` in the Portfolio (test) repo (`~/Documents/Coding Folder/Portfolio (test)`), active build `v4-d-hybrid.html` + `js/roll-*.js`, as of 2026-07-22.

**Jargon, defined once:** *IIFE* = Immediately Invoked Function Expression, `(function () { ... })();` — a file-scoped closure, so nothing leaks except what the file explicitly puts on the shared namespace. *Progressive enhancement* = the page is fully usable with zero JS enhancement; richer behavior layers on only when its dependency actually loads. *Develop-plate* = this project's canvas artwork that "develops" (resolves from noise) as the user engages.

## When NOT to use this skill

- Animation timing, easing, choreography theory → **pryne-motion-reference**
- Whether a change is even allowed, and how it's gated → **pryne-change-control**
- Something is broken and you're diagnosing → **pryne-frontend-debugging**
- Proving a change works (screenshots, Lighthouse, rubric) → **pryne-validation-and-qa**
- React/Next.js or any bundler project — this contract is for no-build vanilla sites only.

## The module contract

One concern per file. One IIFE per file. No bundler, no imports.

All cross-module state lives on a single global namespace object — `window.Roll` here. `roll-core.js` creates it and loads first; every other module opens with `const Roll = window.Roll;` and reads/writes properties on it (`roll-core.js:1-7` states this explicitly). Modules that must not know about each other communicate via DOM events instead (e.g. `roll-scroll.js` dispatches `roll:launch`; `roll-contact-sheet.js` listens — see `roll-scroll.js:35-37`).

**Script order in the HTML is the dependency graph.** From `v4-d-hybrid.html:429-437`:

```
roll-core.js → roll-shader.js → roll-field.js → roll-audio.js → roll-cursor.js
→ vendor/lenis.min.js → roll-scroll.js → roll-contact-sheet.js → roll-eggs.js
```

**Invariant: never reorder or insert a `<script>` without first grepping what the module reads from `Roll` and confirming every producer loads earlier.** There is no import system to save you; a reorder fails silently or throws at load.

```bash
grep -n "Roll\.\w*" design-demos/js/<module>.js   # what it reads/writes
```

GSAP is deliberately NOT in that chain — see Invariant 2.

## Module map (as of 2026-07-22)

| File | One concern | Lines |
|---|---|---|
| `roll-core.js` | Namespace, shared state, develop-plate engine, `upgradeMotion` | 192 |
| `roll-scroll.js` | The spine: entry, scroll choreography, HUD, main rAF (requestAnimationFrame) loop, Lenis | 226 |
| `roll-field.js` | Background canvas field | 136 |
| `roll-shader.js` | WebGL grain/light shader + canvas-2D fallback | 133 |
| `roll-eggs.js` | Hidden personality triggers (whisper-level only) | 83 |
| `roll-audio.js` | Quiet ambient sound tied to scroll velocity | 79 |
| `roll-contact-sheet.js` | Contact-sheet reveal on launch | 55 |
| `roll-cursor.js` | Custom cursor (desktop only, GSAP-gated) | 36 |

New interactive feature? It's a new `roll-*.js` file (or a clearly-fenced section of the one module that owns that concern), added to the script chain in dependency position — not inline `<script>` in the HTML.

## Invariants (verified in code — keep them true)

1. **Reduced motion gates every motion module.** `Roll.reduced = matchMedia('(prefers-reduced-motion: reduce)').matches` (`roll-core.js:9`). Every module consults it: shader skips WebGL (`roll-shader.js:90,124`), field skips its rAF loop (`roll-field.js:125,135`), contact-sheet returns early (`roll-contact-sheet.js:12`), scroll skips the hold-to-develop entry and Lenis (`roll-scroll.js:39-40,152`), and CSS unsets clip-path transitions (`v4-d-hybrid.html:293-295`). **Any new motion must check `Roll.reduced` (JS) or sit under the reduced-motion media query (CSS).**
2. **GSAP is a progressive enhancement, never a dependency.** It loads `async` from CDN with an SRI hash (`v4-d-hybrid.html:440`); on load it calls `Roll.upgradeMotion()`, which flips `Roll.enhanced` and flushes callbacks registered via `Roll.onMotionReady` (`roll-core.js:10-15,186-191`). If GSAP never arrives, the site must remain fully functional — cursor, hero type, and skew simply stay at baseline (`roll-cursor.js:34-35`, `roll-scroll.js:32-33,89,196`). Register GSAP-dependent code with `Roll.onMotionReady(fn)`; never call `gsap.*` unconditionally.
3. **Risky visual takeovers are defensively wrapped — on the recurring path, not just setup.** The custom cursor is guarded at three layers, each with a restoring catch that nulls `Roll.cursorUpdate` and removes `.custom-cursor` (which hides the OS cursor): setup (`roll-cursor.js:9-32`, catch at 32), the per-event handler body (`roll-cursor.js:17-20`), and the `pointermove` call site (`roll-core.js:26-29`). A failure at any point — setup-time or any later mousemove — restores the OS cursor (fixed 2026-07-22; fail-safe contract in the file header, `roll-cursor.js:1-5`). When applying this pattern to anything that hides/replaces a native affordance, guard the recurring path too, not just setup.
4. **clip-path reveals live on an inner wrapper, never on the element IntersectionObserver watches** (the "concept-C fix" — named for v4 concept C, `v4-c-ch001.html`, where it originated before being carried into v4-d). The IO watches `.panel`; the clip-path animates `.panel-inner` (`v4-d-hybrid.html:121-122,185-186`). Rationale: clipping the observed element changes its intersection geometry and the reveal fights the trigger.
5. **Engagement-driven visuals gate on their own visibility, not page load.** Feature plates only develop while their panel has `.in` (`roll-scroll.js:204-219`); the code comment records the original bug: plates finished resolving before anyone scrolled to them, "silently defeating the 'develops as you engage' interaction." The head comment of `v4-d-hybrid.html` calls the fix the single highest-priority one from the technical audit.
6. **WebGL is explicit and fallback-safe.** Non-premultiplied alpha at context creation (`roll-shader.js:17`), explicit `gl.clear` every frame (`roll-shader.js:95`), 2D context acquired only after WebGL has had its chance — a canvas can only ever have one context type (`roll-shader.js:9-12`), and `webglcontextlost` fails quietly instead of letting the render loop throw (`roll-shader.js:129-132`). Callers use the single `Roll.shader.render(t)` entry point and never know GL vs 2D.
7. **Scrolling stays native under Lenis.** Lenis is vendored (`js/vendor/lenis.min.js`, not CDN), instantiated only when `!Roll.reduced`, and keeps `window.scrollY` valid — it's a feel upgrade, not a scroll hijack (`roll-scroll.js:148-152,167`). The render loop reads `scrollY` as before.

## Single-file demo philosophy + design tokens

Each design variant is one self-contained HTML file (inline CSS, shared `js/` modules) so variants can be diffed, screenshotted, and A/B'd as whole artifacts — see **pryne-design-direction-decision**. A long head comment in each file records what the variant is and which audit findings it carries (read it before editing; it is the file's local changelog).

All colors, spacing, and easing are CSS custom properties in `:root` (`v4-d-hybrid.html:50-63`):

```css
:root {
  --bg: #0a0a0b;  --accent: #d2232e;  --ink: #f4f3f1;  --dim: #86868c;
  --pad-x: clamp(1.25rem, 6vw, 6rem);
  --ease-out: cubic-bezier(0.22, 1, 0.36, 1);
  --ease-snap: cubic-bezier(0.16, 1, 0.3, 1);
}
```

Per Pryne's global rules: never hardcode a color/size where a token exists; fluid values use `clamp()`. New motion must reuse `--ease-out`/`--ease-snap` unless pryne-motion-reference says otherwise — one easing language per build.

## Checklist: adding a module

- [ ] New `roll-*.js` (or correct existing owner module), top-level IIFE, `const Roll = window.Roll;`
- [ ] `<script>` inserted after everything it reads from `Roll`, before anything that reads it
- [ ] Checks `Roll.reduced`; GSAP usage only inside `Roll.onMotionReady`
- [ ] Anything hiding a native affordance is try/catch-wrapped with a restoring catch
- [ ] Visibility-gated if engagement-driven; IO target ≠ clip-path target
- [ ] Tokens, not hardcoded values
- [ ] Then validate per **pryne-validation-and-qa**

## Known weak points (open, stated plainly)

- **No build step**: no minification, no bundling; fine for demos, unresolved for production deploy.
- **Fonts load from Google Fonts CDN** (`v4-d-hybrid.html:47-48`) despite the project's vendor-first intent (self-hosting is referenced in `design-demos/DECISIONS.md` only in passing, inside the Lenis entry; the decision record itself predates the file; not yet done). GSAP is also still CDN (pinned + SRI). See pryne-change-control before "fixing" either.
- **No automated tests** — validation is browser-based evidence only (pryne-validation-and-qa).
- **Placeholder content**: case studies/bio are not final; don't polish copy as if it were.

## Provenance and maintenance

Run `scripts/verify.sh` (in this skill's directory) to check all of the below at once.

Grounded in Portfolio (test) repo at commit `457868a`, 2026-07-22. Re-verify before trusting volatile facts:

- Script order: `grep -n "<script" design-demos/v4-d-hybrid.html`
- Line counts / module list: `wc -l design-demos/js/*.js`
- Reduced-motion coverage: `grep -rn "Roll.reduced\|prefers-reduced-motion" design-demos/`
- GSAP still CDN+SRI, fonts still CDN: `grep -n "cdn.jsdelivr\|fonts.googleapis" design-demos/v4-d-hybrid.html`
- Lenis still vendored: `ls design-demos/js/vendor/`
- Active build is still v4-d: check `design-demos/DECISIONS.md` and latest `git log --oneline`
