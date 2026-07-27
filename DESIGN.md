---
name: DSFH Internal Medicine Residency Portal
description: A warm, typeset record system — cream paper, terracotta ink, and cinematic leadership surfaces.
colors:
  terracotta: "#c96a4a"
  terracotta-deep: "#b5593a"
  terracotta-light: "#e8956d"
  ember: "#7c3820"
  blush: "#fde0c8"
  honors-gold: "#A47A28"
  gold-light: "#CBA155"
  cream: "#FEFBF3"
  parchment: "#F6EFE2"
  parchment-deep: "#ede5d4"
  ink: "#1F1A12"
  success-green: "#2a7a5a"
  sage: "#7FB89C"
  alert-red: "#b52040"
  excused-violet: "#7c3aed"
typography:
  display:
    fontFamily: "'Playfair Display', Georgia, serif"
    fontSize: "clamp(2.2rem, 4vw, 3.4rem)"
    fontWeight: 700
    lineHeight: 1.1
    letterSpacing: "-0.02em"
  headline:
    fontFamily: "'Playfair Display', Georgia, serif"
    fontSize: "1.8rem"
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: "-0.01em"
  title:
    fontFamily: "'Playfair Display', Georgia, serif"
    fontSize: "1.05rem"
    fontWeight: 700
    lineHeight: 1.3
  body:
    fontFamily: "'Inter', 'Segoe UI', system-ui, sans-serif"
    fontSize: "0.87rem"
    fontWeight: 400
    lineHeight: 1.5
  label:
    fontFamily: "'Inter', 'Segoe UI', system-ui, sans-serif"
    fontSize: "0.68rem"
    fontWeight: 700
    letterSpacing: "0.08em"
  eyebrow:
    fontFamily: "'Inter', 'Segoe UI', system-ui, sans-serif"
    fontSize: "0.62rem"
    fontWeight: 700
    letterSpacing: "0.15em"
rounded:
  sm: "6px"
  md: "8px"
  lg: "10px"
  xl: "12px"
  card: "14px"
  pill: "20px"
  full: "999px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "14px"
  lg: "18px"
  xl: "24px"
  gutter: "28px"
  section: "48px"
  stage: "64px"
components:
  button-primary:
    backgroundColor: "{colors.terracotta}"
    textColor: "{colors.cream}"
    rounded: "{rounded.md}"
    padding: "8px 20px"
  button-primary-hover:
    backgroundColor: "{colors.terracotta-deep}"
    textColor: "{colors.cream}"
  button-ghost:
    backgroundColor: "{colors.parchment}"
    textColor: "{colors.ink}"
    rounded: "{rounded.md}"
    padding: "8px 20px"
  button-ghost-hover:
    backgroundColor: "{colors.parchment-deep}"
  button-danger:
    backgroundColor: "{colors.alert-red}"
    textColor: "#ffffff"
    rounded: "{rounded.md}"
    padding: "8px 20px"
  button-success:
    backgroundColor: "{colors.success-green}"
    textColor: "#ffffff"
    rounded: "{rounded.md}"
    padding: "8px 20px"
  pill:
    backgroundColor: "transparent"
    textColor: "rgba(31,26,18,.45)"
    rounded: "{rounded.pill}"
    padding: "4px 14px"
  pill-on:
    backgroundColor: "{colors.terracotta}"
    textColor: "{colors.cream}"
  tab:
    backgroundColor: "transparent"
    textColor: "rgba(31,26,18,.38)"
    rounded: "0"
    padding: "7px 18px"
  tab-on:
    textColor: "{colors.terracotta}"
  input:
    backgroundColor: "{colors.cream}"
    textColor: "{colors.ink}"
    rounded: "{rounded.md}"
    padding: "9px 12px"
  statbox:
    backgroundColor: "{colors.parchment}"
    textColor: "{colors.ink}"
    rounded: "{rounded.lg}"
    padding: "16px"
  table-header:
    backgroundColor: "{colors.parchment}"
    textColor: "rgba(31,26,18,.4)"
    typography: "{typography.label}"
    padding: "10px 14px"
  modal-card:
    backgroundColor: "{colors.cream}"
    textColor: "{colors.ink}"
    rounded: "{rounded.xl}"
    padding: "28px"
    width: "400px"
---

# Design System: DSFH Internal Medicine Residency Portal

## Overview

**Creative North Star: "The Editorial Record"**

This is a clinical record set with the care of a printed journal. The page is warm paper stock (`#FEFBF3`), the ink is near-black brown (`#1F1A12`), and a single fired-clay accent (`#c96a4a`) does all the pointing. Headlines and every number that matters are set in Playfair Display; the interface text steps back into a neutral sans so the figures carry the voice. Structure comes from hairline rules and background shifts, not from outlines — a table of attendance reads like a typeset page, not a grid of widgets.

The system runs at two registers, and the difference is deliberate. **Working surfaces** — rota, attendance, on-call, admin, leave — are quiet, dense, and restrained enough to sit under a resident's eyes all day; terracotta appears only to mark what is active or actionable. **Leadership surfaces** — the Performance Report, Best Resident, the home hero — are cinematic: full-bleed clay gradients, a stacked serif title with its middle line dropped into italic, a 7.5rem cohort figure, gold rails and pulsing stars. When the program is being presented to executives, the interface is expected to produce an effect, not merely display data.

What it is not: it is not a hospital EMR (no grey chrome, no blue-on-white enterprise density), not a consumer analytics dashboard (no neon KPI cards, no gradient-on-black), and not a slide deck. It must never read as generically machine-generated or as a boring PowerPoint — and it does not use boring squares.

**Key Characteristics:**
- Warm paper canvas with zero pure white and zero pure black
- One accent color, used sparingly and always meaningfully
- Serif display for headings *and* for figures; sans for everything else
- Hairline rules and tonal shifts instead of card outlines
- Two registers: restrained in the working modules, cinematic in the leadership ones
- Radius everywhere; status and identity elements are pills or circles

## Colors

A warm earth palette — clay, gold, and two weights of paper — with a small, strictly functional status set borrowed from outside the warm range.

### Primary
- **Terracotta** (`#c96a4a`): The single accent. Primary buttons, the active tab underline, the selected block pill, the current-day rail on the on-call table, unread notification borders, section eyebrows, junior-tier identity, and the row-hover wash at 4% opacity. Its darker sibling **Terracotta Deep** (`#b5593a`) is hover-only. **Terracotta Light** (`#e8956d`) exists only inside gradients and avatar fills, never as a flat surface color.
- **Ember** (`#7c3820`) and **Blush** (`#fde0c8`): the two ends of the signature `148deg` clay gradient that renders the login screen, the loading screen, the home hero, and the Performance Report hero. They are gradient stops, not standalone colors.

### Secondary
- **Honors Gold** (`#A47A28`): appears only where something has been formally earned or formally imposed — first place, the senior tier, Hall of Fame rails, the countdown block underline, deadline alerts, the "current block" pill. **Gold Light** (`#CBA155`) is its gradient partner and the CTU column header tint.

### Neutral
- **Cream** (`#FEFBF3`): the entire page canvas, table bodies, modal and login card surfaces, input fields, and text on any dark or clay ground.
- **Parchment** (`#F6EFE2`): the tonal step up — stat boxes, table headers, ghost buttons, inline forms, weekend rows, module-tile hover, and every "this is a different surface" moment where a border would otherwise be used.
- **Parchment Deep** (`#ede5d4`): pressed and hover state for parchment surfaces only.
- **Ink** (`#1F1A12`): all body text, the sidebar, on-call table headers, and the modal scrim at 62%. Its alpha ladder does the rest of the work — `.55` for field labels, `.42`/`.40` for secondary text, `.38`/`.35` for tertiary, `.12`/`.10` for borders, `.08`/`.07`/`.06` for hairline rules.

### Tertiary — status only
- **Success Green** (`#2a7a5a`) Present · **Honors Gold** (`#A47A28`) Late · **Alert Red** (`#b52040`) Absent · **Excused Violet** (`#7c3aed`) Excused · **Ink at 30%** Outside rotation. **Sage** (`#7FB89C`) marks weekends and confirmations. These five are the attendance vocabulary and are used at ~8–10% tint for backgrounds with a darkened text pair.

### Named Rules

**The One Clay Rule.** Terracotta means *active, primary, or now* — nothing else. It is never used to decorate, never to fill a large area outside a gradient, and never to distinguish two things that are both inactive.

**The Earned Gold Rule.** Gold appears only where a thing was earned (rank 1, senior star, Hall of Fame) or formally set by authority (a deadline, the current block). Gold used for ordinary emphasis breaks the ranking language.

**The No Pure Values Rule.** No `#ffffff` and no `#000000` anywhere on a surface a user reads. Cream and Ink are the extremes. (White is permitted only as text on saturated status fills.)

## Typography

**Display Font:** Playfair Display (with Georgia, serif)
**Body Font:** Inter (with Segoe UI, system-ui, sans-serif)

**Character:** A high-contrast transitional serif carrying every heading and every number that matters, over a neutral grotesque doing all the labor. The pairing is what makes an attendance table feel typeset rather than tabulated — and what lets a cohort average at 7.5rem read as a statement instead of a metric.

> **Implementation note (27 Jul 2026):** Inter is now genuinely loaded (weights 400/500/600/700/800) alongside Playfair Display. Before that fix the CSS named Inter everywhere but never fetched it, so body text silently resolved to `Segoe UI` / `system-ui` and every user saw a different typeface. The Best Resident and Stars rules that declared a bare generic `sans-serif` were also pointed at the Inter stack in the same pass, so nothing renders in Helvetica while the rest of the page is Inter. **Never declare a family the document does not serve.**

### Hierarchy
- **Display** (Playfair 700, `clamp(2.2rem, 4vw, 3.4rem)`, line-height 1.1, tracking -0.02em): hero titles only. On the Performance Report the title stacks to three lines at a fixed `3.4rem` with the middle line italic at weight 400.
- **Hero Figure** (Playfair 700, up to `7.5rem`, tracking -0.03em, with a `2.8rem` weight-400 superscript unit): reserved for the single cohort number that anchors a leadership surface.
- **Headline** (Playfair 700, `1.8rem` / `1.55rem`): section titles on report and home surfaces.
- **Title** (Playfair 700, `1.05rem` / `1.15rem`): card and modal headings.
- **Statistic** (Playfair 700, `1.9rem`, tracking -0.02em): stat-box values, rank scores, countdown numerals.
- **Body** (sans 400, `0.87rem` for forms / `0.84rem` for tables, line-height ~1.5).
- **Label** (sans 700, `0.68rem`, tracking 0.08em, uppercase): table headers, stat captions.
- **Eyebrow** (sans 700, `0.62rem`, tracking 0.15em–0.2em, uppercase): the small line above every section title and hero.

### Named Rules

**The Serif-for-Numbers Rule.** Any figure a person is meant to *judge* — a score, a percentage, a rank, a countdown — is set in Playfair. Sans is for labels and prose. A KPI number in the body font is a defect.

**The Italic Second Line Rule.** When a hero title stacks, the middle line drops to weight 400 italic in cream at 82% opacity. That single tonal break is what makes a three-word title cinematic rather than a heading.

**The Eyebrow Always Rule.** Every section opens with an uppercase, wide-tracked eyebrow before its serif title — terracotta on cream, cream-at-45% on clay.

## Layout

A fixed 250px ink sidebar beside a scrolling main area; content constrained to `1040px` with `32px 28px` padding. Cinematic sections break that constraint deliberately and run full-bleed at `64px` horizontal padding, with the Performance Report hero clamped to `100vh`.

Spacing runs on an irregular but consistent warm rhythm — `4 / 8 / 14 / 18 / 24 / 28` inside components, `48 / 64` between staged sections. Grid helpers are plain `1fr` splits at 2, 3, and 4 columns with a `12–14px` gutter.

Three breakpoints: at **900px** the hero and module padding compress and the module grid drops to two columns; between **900px and 601px** the sidebar collapses to a 58px icon rail; below **600px** the sidebar becomes an off-canvas drawer behind a dark top bar, all grids collapse to one column, modals go full-screen and square-cornered, and the hero info card is dropped entirely rather than stacked.

**The Rail-Not-Reflow Rule.** On tablet the sidebar narrows to icons; it never becomes a hamburger until true mobile. Two different navigation models at two different widths is intentional.

## Elevation & Depth

The system is **softly lifted**: flat where content lives, gently raised where content is grouped or floating. Reading surfaces — cards, resident rows, ranking rows, the module grid — carry no shadow at all and are separated by 1px warm hairlines. Grouped summary objects and anything genuinely floating do lift, and the shadow is always long, low-opacity, and warm-tinted (`rgba(31,26,18,...)`, never neutral black).

### Shadow Vocabulary
- **Hover lift** (`0 6px 20px rgba(31,26,18,.10)` with `translateY(-2px)`): star cards and other grouped tiles responding to the pointer.
- **Resting group** (`0 2px 12px rgba(31,26,18,.08)`): countdown blocks and small standalone figures.
- **Glass card** (`0 8px 32px rgba(31,26,18,.15)` over `backdrop-filter: blur(20px)`): the hero info card floating on the clay gradient.
- **Floating panel** (`0 24px 60px rgba(31,26,18,.28)`): modals.
- **Stage** (`0 32px 80px rgba(31,26,18,.35)`): the login card against the full-bleed gradient.
- **Drawer** (`-4px 0 28px rgba(31,26,18,.15)`): the notification panel.
- **Accent glow** (`0 4px 12px rgba(232,160,0,.35)` / `rgba(201,106,74,.35)`): gold and clay avatar rings only.

### Named Rules

**The Lift-When-It-Floats Rule.** A shadow means "this is above the page" — a modal, a drawer, a glass card, a hovering tile. A surface that is simply a different kind of content gets parchment and a hairline instead.

**The Warm Shadow Rule.** Every shadow is tinted with `rgba(31,26,18,…)`. A neutral or blue-black shadow is out of system.

## Shapes

Radius is universal and graded by size: `6px` on small controls (icon buttons, inputs, badges, sidebar nav items), `8px` on buttons, alerts, and fields, `10px` on stat boxes, tables, and grouped tiles, `12–14px` on modals, login, and the glass card. Anything conveying **status or identity** — level badges, day pills, block selectors, attendance chips, sort toggles, tier labels — is a full pill (`20px` / `999px`), and anything conveying a **person** is a circle.

Borders are the exception, not the rule: most separation is a `1px` hairline at 6–8% ink on one edge only. Where an accent must mark a row, it does so as a left rail (`3px` solid, or `inset 4px 0 0` for today's on-call row) rather than a full outline. Gradients run at `135deg` on small objects and `148deg` on full-bleed grounds — never at 90°.

**The No Boring Square Rule.** Nothing ships with a `0` radius on a light surface. Full-screen mobile modals are the single sanctioned exception, because they meet the viewport edge.

## Components

### Buttons
Restrained inside working modules, expressive on leadership surfaces — the same shape either way.
- **Shape:** softly rounded rectangle (`8px`), `8px 20px` padding, inline-flex with a `6px` icon gap.
- **Primary:** terracotta ground, cream text; hover deepens to `#b5593a`. No lift, no scale.
- **Ghost:** parchment ground, ink text, hairline border at 12%; hover steps to `#ede5d4`. This is the default for secondary actions — an outline-only button is not in the system.
- **Danger / Success / Warn:** `#b52040` / `#2a7a5a` / `#A47A28` on white or cream text, each with a hand-darkened hover.
- **Transition:** `all .14s` — fast enough to feel immediate, never animated further.

### Pills & Tabs
- **Pill:** transparent with a 12% ink hairline and 45% ink text at rest; terracotta-filled with cream text when on; gold-filled when it marks the *current* block. `4px 14px`, fully rounded.
- **Tab:** text-only with a transparent 2px bottom border; when active the text goes terracotta and the border matches. Tabs never gain a background.

### Cards / Containers
- **Content card:** transparent, no radius, no shadow, `22px 0` padding, separated by a single `1px rgba(31,26,18,.07)` bottom rule that is dropped on the last child. This is the system's default container and the reason the page reads as a document.
- **Stat box:** parchment ground, `10px` radius, `16px` padding, centered — a serif value over an uppercase caption.
- **Grouped tile:** cream ground, `10px` radius, 8% hairline, `16–18px` padding, with a `4px` full-height accent bar on the leading edge (gold for senior, clay for junior) and a large low-opacity color blob bleeding from the top corner.

### Inputs / Fields
- Cream ground, 15% ink hairline, `8px` radius, `9px 12px` padding, full width by default.
- **Focus:** border goes terracotta with a `0 0 0 3px rgba(201,106,74,.1)` ring. No outline, no glow beyond that ring.
- **Label:** sans 600 at `0.78rem` in 55% ink, sitting `4px` above its field.

### Tables
Parchment header row in uppercase label type, sticky at the top; `10px 14px` cells over a 6% hairline; row hover washes terracotta at 4%. No zebra striping on standard tables. The on-call table is the deliberate exception: an ink header, alternating cream/`#faf8f3` rows, parchment weekend rows, and an inset clay rail on today.

### Navigation
Ink sidebar, cream-at-40% labels at `0.82rem`; hover raises to 78% on a 6% cream wash; active state fills with `rgba(201,106,74,.18)`, sets the text to `#f0c4a8`, and carries a 2px terracotta left border. Icons are 18px stroked SVG at 70% opacity, full opacity when active.

### Cinematic Surfaces (signature)
The register that separates this system from an admin tool. A cinematic surface is full-bleed, opens on the `148deg` clay gradient, and combines: a wide-tracked eyebrow, a stacked Playfair title with an italic middle line, one oversized serif figure with a superscript unit, and a hairline-divided stat rail across the base. Supporting motion is slow and ambient — drifting canvas confetti, a 3s star pulse, a 1.5s vote pulse, a light streak — never bouncing or attention-seeking. Currently: the Performance Report hero, the home hero, the Best Resident stars banner, the login and loading screens.

**The Two Registers Rule.** Cinematic treatment belongs to leadership and recognition surfaces. Working modules (attendance, rota, admin, leave) stay quiet — a gradient hero over an attendance grid is out of system.

## Do's and Don'ts

### Do:
- **Do** set every judged figure — score, percentage, rank, countdown — in Playfair Display.
- **Do** separate content with a `1px rgba(31,26,18,.07)` hairline or a shift to parchment, in that order of preference.
- **Do** use terracotta only for active, primary, or current, and gold only for earned or formally imposed.
- **Do** open every section with an uppercase wide-tracked eyebrow above its serif title.
- **Do** give leadership-facing surfaces a genuine cinematic moment — full-bleed gradient, oversized serif figure, stat rail.
- **Do** keep ambient motion slow (`0.08–0.5` drift speeds, 1.5–3s pulses) and state transitions fast (`.12–.16s`).
- **Do** use logical alignment and direction-neutral spacing where possible — Arabic/RTL support is a planned requirement and hard-coded left assumptions will block it.
- **Do** keep effects cheap enough for older hospital PCs: canvas confetti and CSS keyframes, no heavy compositing stacks.

### Don't:
- **Don't** use `#ffffff` or `#000000` on any surface a user reads.
- **Don't** put a `border: 1px solid` outline all the way around a content card — the system separates with one edge, not four.
- **Don't** ship a `0`-radius element on a light surface. No boring squares.
- **Don't** let it read like a hospital EMR — no grey chrome, no blue-on-white enterprise density, no windowed panel stacks.
- **Don't** let it read like a consumer analytics dashboard — no neon KPI cards, no gradient-on-black, no vanity sparklines.
- **Don't** let it read as generically machine-generated or as a slide deck. Every surface should look like someone decided it.
- **Don't** apply cinematic treatment to a working module, or leave a leadership surface flat.
- **Don't** build icons as emoji or via `el("svg", …)` — stroked 18–24px SVG through the namespaced builder only.
- **Don't** introduce a second accent color. One clay, one gold, five status colors, and that is the whole vocabulary.
