---
name: pryne-browser-lab
description: Use when you need to run, screenshot, trace, audit, or otherwise measure one of Pryne's HTML demos in a real browser — serving a demo locally, capturing console output, taking breakpoint screenshots, running a performance trace or Lighthouse audit, or emulating reduced motion. Also use when unsure which browser-automation MCP tools exist or where measurement artifacts belong.
---

# Pryne Browser Lab — run and measure, don't eyeball

How to serve Pryne's static demos and produce **measurements** (console logs, screenshots, traces, audits) instead of visual impressions. Every quality claim about a demo should be backed by an artifact produced with a recipe from this file.

**Division of labor:** this skill = HOW to run and measure. What counts as passing evidence and the acceptance thresholds → `pryne-validation-and-qa`. Symptom→cause triage when a measurement looks bad → `pryne-frontend-debugging`.

## When NOT to use this skill

- Deciding whether results are *good enough* to promote a change → `pryne-validation-and-qa`.
- Debugging *why* something is broken → `pryne-frontend-debugging` (it will send you back here to gather evidence).
- Editing code or docs with no need to observe the running page.

## 1. Serving a demo

Demos are self-contained static HTML files under `design-demos/` (e.g. `v4-d-hybrid.html`). Nothing in the repo uses `fetch()`/XHR (verified 2026-07-22), so `file://` renders most modules — but the standard is a local HTTP server, which avoids any file-URL restrictions and gives stable URLs for automation tools:

```bash
cd "$PROJECT_ROOT"
python3 -m http.server 8000
# → http://localhost:8000/design-demos/v4-d-hybrid.html
```

Verified on this Mac 2026-07-22: `python3` is Python 3.14.3 at `/opt/homebrew/bin/python3`; the URL above returns 200.

Constraints that are browser policy, not serving mode:
- **Audio**: `roll-audio.js` synthesizes sound via a lazily created `AudioContext` inside event handlers — it needs a real user gesture (click/keypress) before sound can play. (It also calls `startAmbient()` at load when `localStorage` remembers an unmuted state — `roll-audio.js:43` — but the `AudioContext` stays suspended until a gesture, so the guidance stands.) Automation must dispatch an interaction first.
- **WebGL / fonts**: shaders are inline and fonts load from Google Fonts over HTTPS; both work under `file://` and `http://` alike. (Candidate, not verified per-browser: some Chromium `file://` canvas readback restrictions — irrelevant if you use the server, so use the server.)

## 2. Browser-automation tooling (as of 2026-07-22 — tool names drift; re-verify)

Two MCP families are available in Pryne's sessions. Both are **deferred tools**: load schemas first with `ToolSearch("select:<tool_name>")` or a keyword query, or direct calls fail with InputValidationError.

| Family | Tool-name anatomy | Use for |
|---|---|---|
| Chrome DevTools MCP | `mcp__chrome-devtools-official__<verb>` — `new_page`, `navigate_page`, `list_console_messages`, `evaluate_script`, `take_screenshot`, `resize_page`, `performance_start_trace` / `performance_stop_trace`, `performance_analyze_insight`, `lighthouse_audit`, `emulate` | Default choice. Performance traces, Lighthouse, viewport/CPU/network emulation, everything below. Note (verified 2026-07-22): its `emulate` tool has **no** `prefers-reduced-motion` option — for reduced motion use the initScript technique in recipe (e). Prior v4 sessions used this family (per the prior-session summary; the `.playwright-mcp/` logs are Playwright-MCP artifacts from Jul 15–16 sessions). |
| Playwright MCP | `mcp__playwright__browser_<verb>` — `navigate`, `console_messages`, `evaluate`, `take_screenshot`, `resize`, `snapshot` | Fallback when the DevTools MCP is unavailable, or when you want an accessibility-tree `snapshot` of the page. |

A third family (`mcp__plugin_ecc_chrome-devtools__*`) mirrors the DevTools tools; treat it as equivalent if the primary is missing.

## 3. Standard measurement recipes

Run these against the served URL. Each produces an artifact you can cite.

### (a) Console-zero check
1. `new_page` / `navigate_page` to the demo URL.
2. Interact like a visitor: `evaluate_script` → `window.scrollTo({top: document.body.scrollHeight, behavior: 'smooth'})`, then back to 0; click once (satisfies the audio-gesture gate); hover a project panel.
3. `list_console_messages`.
4. Record the count. Expected: **zero errors** (the threshold, owned by `pryne-validation-and-qa`); warnings are recorded in the artifact but not thresholded. Any error → `pryne-frontend-debugging`.

### (b) Breakpoint screenshot matrix
1. `resize_page` to **390×844** (mobile) → `take_screenshot`.
2. `resize_page` to **1440×900** (desktop) → `take_screenshot`.
3. Screenshot both the cold top-of-page state and at least one mid-scroll section per breakpoint.
4. Name and place per §4 below.

### (c) Performance trace of a scroll interaction
1. `performance_start_trace`.
2. `evaluate_script` → a scripted scroll through the full page (smooth scroll to bottom over several seconds).
3. `performance_stop_trace`.
4. `performance_analyze_insight` on the flagged insights; read §5 to interpret.

### (d) Lighthouse audit
1. `lighthouse_audit` on the demo URL (desktop and mobile passes).
2. Compare against the acceptance thresholds — **perf ≥ 90, a11y ≥ 95** — owned and explained by `pryne-validation-and-qa`.

### (e) Reduced-motion check
1. The DevTools MCP `emulate` tool cannot emulate `prefers-reduced-motion` (verified 2026-07-22 against its schema: viewport/CPU/network/colorScheme only). Instead, reload with an init script that overrides `matchMedia` **before any page script runs** — `navigate_page` with `type: "reload"` and `initScript`:
   ```js
   const orig = window.matchMedia; window.matchMedia = q => q.includes('prefers-reduced-motion') ? {matches:true, media:q, addEventListener(){}, removeEventListener(){}, addListener(){}, removeListener(){}} : orig.call(window, q);
   ```
   (Playwright MCP emulation is the alternative if available.)
2. Then repeat recipe (a)'s interaction pass on the reloaded page.
3. Verify choreography is gated: `evaluate_script` → `window.Roll && Roll.reduced` must be `true`, and scroll-linked animation (kinetic type, shader pulses, smooth-scroll takeover) must not run. Reduced-motion gating is an invariant (`pryne-frontend-architecture`); a violation is a blocking finding.

## 4. Where artifacts go

| Artifact | Location | Notes |
|---|---|---|
| Automation console logs / page snapshots | `.playwright-mcp/` in the repo | Auto-collected scratch. **Gitignored** (verified in `.gitignore` 2026-07-22) — never evidence of record. |
| Screenshots that ARE evidence of record | `design-demos/`, next to the demo | **Canonical library-wide convention (owned here):** `<version>-<breakpoint-or-subject>.png` — real examples in-repo: `v3-mobile.png`, `v3-hero.png`, `v2-desktop-hero.png`, `v2-mobile-spec.png`, `demo-desktop-full.png`. Follow the same pattern (e.g. `v4-d-mobile-hero.png`). The variant-selection campaign extends this with a section token (see `pryne-design-direction-decision`). |
| Traces / Lighthouse output | Session scratchpad | Summarize numbers into the conversation or decision doc; raw dumps don't belong in the repo. |

## 5. Interpretation quick guide

| Observation | Reading (one line — deep triage → `pryne-frontend-debugging`) |
|---|---|
| Long task (>50 ms) during scroll in a trace | Something in the shared rAF loop (roll-core/roll-scroll spine) is doing too much per frame — suspect per-frame layout reads or unthrottled canvas work. |
| Console error only appears mid-scroll | A scroll-linked module (`roll-scroll.js`, `roll-shader.js`, `roll-field.js`) reading state that isn't ready — not the page boot path. |
| Screenshot fine at 1440 but broken at 390 | Fluid-type/`clamp()` or fixed-width HUD element failing the mobile breakpoint — check the resized state, not zoom. |
| Lighthouse perf below threshold (per `pryne-validation-and-qa`) with good trace | Usually load-phase weight (fonts, GSAP CDN script) rather than runtime jank — different fix category. |
| Animation runs under reduced-motion emulation | Gating bug: module didn't check `Roll.reduced`. Invariant violation — stop and report. |

## Provenance and maintenance

Run `scripts/verify.sh` (in this skill's directory) to check all of the below at once (it never starts servers — the server smoke test stays manual).

Facts here were verified against the repo and this Mac on **2026-07-22**. Re-verify before trusting:

- Server + URL: `cd "$PROJECT_ROOT" && python3 -m http.server 8000` then `curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/design-demos/v4-d-hybrid.html` (expect 200).
- No network fetches in demos: `grep -rn "fetch(\|XMLHttpRequest" design-demos/` (expect no hits).
- Audio gesture gate: `grep -n "AudioContext" design-demos/js/roll-audio.js` (expect lazy creation inside handlers).
- MCP tool names: `ToolSearch("chrome devtools screenshot trace")` and confirm the `mcp__chrome-devtools-official__*` names above still exist.
- Artifact naming + gitignore: `ls design-demos/*.png` and `cat .gitignore` (expect `.playwright-mcp/`).
- Reduced-motion flag: `grep -n "prefers-reduced-motion" design-demos/js/roll-core.js` (expect `Roll.reduced = matchMedia(...)`).
