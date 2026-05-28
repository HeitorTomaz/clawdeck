---
version: alpha
name: cockpit-design-analysis
description: A motorsport-engineering interface anchored on a pure-black canvas with white display headlines in confident UPPERCASE. The system carries no decorative voltage — its energy comes from sharp rectangular silhouettes, generous negative space, and weight-pair typography (heavy display vs. light body). A tricolor accent stripe (blue → indigo → red) is used sparingly as a brand signature on dividers, badges, and active states. Type stays light to medium weight to feel European-engineered, never American-bombastic.

colors:
  primary: "#ffffff"
  ink: "#ffffff"
  body: "#bbbbbb"
  body-strong: "#e6e6e6"
  muted: "#7e7e7e"
  hairline: "#3c3c3c"
  hairline-strong: "#262626"
  canvas: "#000000"
  surface-card: "#1a1a1a"
  surface-elevated: "#262626"
  surface-soft: "#0d0d0d"
  on-primary: "#000000"
  on-dark: "#ffffff"
  accent-blue-light: "#0066b1"
  accent-blue-dark: "#1c69d4"
  accent-red: "#e22718"
  heritage-blue: "#1c69d4"
  electric-blue: "#0653b6"
  carbon-gray: "#2b2b2b"
  warning: "#f4b400"
  success: "#0fa336"

typography:
  display-xl:
    fontFamily: "Saira Condensed, sans-serif"
    fontSize: 80px
    fontWeight: 800
    lineHeight: 1
    letterSpacing: 0
  display-lg:
    fontFamily: "Saira Condensed, sans-serif"
    fontSize: 56px
    fontWeight: 800
    lineHeight: 1.05
    letterSpacing: 0
  display-md:
    fontFamily: "Saira Condensed, sans-serif"
    fontSize: 40px
    fontWeight: 700
    lineHeight: 1.1
    letterSpacing: 0
  display-sm:
    fontFamily: "Saira Condensed, sans-serif"
    fontSize: 32px
    fontWeight: 700
    lineHeight: 1.15
    letterSpacing: 0
  title-lg:
    fontFamily: "Saira, sans-serif"
    fontSize: 24px
    fontWeight: 700
    lineHeight: 1.3
    letterSpacing: 0
  title-md:
    fontFamily: "Saira, sans-serif"
    fontSize: 20px
    fontWeight: 400
    lineHeight: 1.4
    letterSpacing: 0
  title-sm:
    fontFamily: "Saira, sans-serif"
    fontSize: 18px
    fontWeight: 400
    lineHeight: 1.4
    letterSpacing: 0
  label-uppercase:
    fontFamily: "Saira, sans-serif"
    fontSize: 14px
    fontWeight: 700
    lineHeight: 1.3
    letterSpacing: 1.5px
  body-md:
    fontFamily: "Saira, sans-serif"
    fontSize: 16px
    fontWeight: 300
    lineHeight: 1.5
    letterSpacing: 0
  body-sm:
    fontFamily: "Saira, sans-serif"
    fontSize: 14px
    fontWeight: 300
    lineHeight: 1.5
    letterSpacing: 0
  caption:
    fontFamily: "Saira, sans-serif"
    fontSize: 12px
    fontWeight: 400
    lineHeight: 1.4
    letterSpacing: 0.5px
  button:
    fontFamily: "Saira, sans-serif"
    fontSize: 14px
    fontWeight: 700
    lineHeight: 1
    letterSpacing: 1.5px
  nav-link:
    fontFamily: "Saira, sans-serif"
    fontSize: 14px
    fontWeight: 400
    lineHeight: 1.4
    letterSpacing: 0.5px

rounded:
  none: 0px
  xs: 2px
  sm: 4px
  md: 6px
  full: 9999px

spacing:
  xxs: 4px
  xs: 8px
  sm: 12px
  md: 16px
  lg: 24px
  xl: 40px
  xxl: 64px
  section: 96px
---

## Overview

A near-pure black canvas (`{colors.canvas}` — #000) holds white display headlines in **confident UPPERCASE**. The system has no decorative voltage of its own; visual interest comes from sharp rectangular silhouettes, the contrast between heavy display (800) and light body (300), and generous negative space. UI chrome stays minimal: thin sans-serif copy, dividers as 1px hairlines (`{colors.hairline}`), all-caps button labels with no fill until hovered.

The **accent tricolor stripe** — `{colors.accent-blue-light}` (#0066b1) → `{colors.accent-blue-dark}` (#1c69d4) → `{colors.accent-red}` (#e22718) — appears sparingly as the brand signature, used on logo accents, divider rules, and active-state indicators. It is never a CTA color and never used as a background fill — the tricolor is exclusively a brand-identity marker.

Type voice runs **Saira Condensed** for display (uppercase, weight 700–800) and **Saira** for body (weight 300–400). The contrast between heavy display and light body is the system's editorial signature.

**Key Characteristics:**
- Pure black canvas (`{colors.canvas}` — #000) with white type. No light-mode surface.
- Display headlines in UPPERCASE at weight 700–800. Sub-heads stay sentence-case at lighter weight.
- The tricolor stripe is used as a 4px divider, logo accent, and active-state marker — never as a button or fill.
- Buttons are flat with `{rounded.none}` (0px) corners and uppercase letterspaced labels. The "industrial precision" rectangular silhouette IS the brand.
- Border radius is mostly zero. Exceptions: `{rounded.full}` on circular icon buttons and `{rounded.sm}` (4px) on small toggle pills.
- Spacing is generous and grid-aligned: `{spacing.section}` (96px) between major bands; `{spacing.xxl}` (64px) inside hero bands; `{spacing.xl}` (40px) inside content cards.

## Colors

### Brand & Accent
- **Primary** (`#ffffff`): The system's primary type and CTA color. Used for h1/h2/h3 display, body text on dark, and primary button labels.
- **Accent Blue Light** (`#0066b1`): First stop in the tricolor stripe. Used on badge accents and motorsport chrome.
- **Accent Blue Dark** (`#1c69d4`): Middle stop. Heritage corporate blue, repurposed as the middle band.
- **Accent Red** (`#e22718`): Third stop. Signature power red, used in the stripe and pace callouts.
- **Electric Blue** (`#0653b6`): Distinct electric/digital accent — colder than the heritage blue.

### Surface
- **Canvas** (`#000000`): Default page floor. True black.
- **Surface Soft** (`#0d0d0d`): Spec table cells, footer-adjacent strips.
- **Surface Card** (`#1a1a1a`): Cards, secondary buttons, icon-button backgrounds.
- **Surface Elevated** (`#262626`): Nested cards inside dark bands.
- **Carbon Gray** (`#2b2b2b`): Carbon-fiber-inspired surface on technical-spec cards.

### Hairlines & Borders
- **Hairline** (`#3c3c3c`): 1px divider tone on dark surfaces.
- **Hairline Strong** (`#262626`): Borders that feel like one-step elevations.

### Text
- **Ink / On Dark** (`#ffffff`): Headline and primary text on dark canvas.
- **Body** (`#bbbbbb`): Default running-text color.
- **Body Strong** (`#e6e6e6`): Emphasized body / lead paragraph.
- **Muted** (`#7e7e7e`): Footer links, breadcrumbs, captions.

### Semantic
- **Warning** (`#f4b400`)
- **Success** (`#0fa336`)

## Typography

### Font Family
**Saira Condensed** for display (700/800) and **Saira** for body (300/400). Fallback: `-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif`.

The weight pair is deliberate:
- Display (700–800) — the "stamped" voice
- Light (300) — the "engineered" voice

Never blur the contrast with regular display or medium body.

### Hierarchy

| Token | Size | Weight | Line Height | Letter Spacing | Use |
|---|---|---|---|---|---|
| `display-xl` | 80 | 800 | 1.0 | 0 | Hero h1 |
| `display-lg` | 56 | 800 | 1.05 | 0 | Section heads |
| `display-md` | 40 | 700 | 1.1 | 0 | Sub-section heads |
| `display-sm` | 32 | 700 | 1.15 | 0 | CTA-band heads |
| `title-lg` | 24 | 700 | 1.3 | 0 | Card titles |
| `title-md` | 20 | 400 | 1.4 | 0 | Card sub-titles |
| `title-sm` | 18 | 400 | 1.4 | 0 | Spec callouts |
| `label-uppercase` | 14 | 700 | 1.3 | 1.5px | Tabs, inline labels |
| `body-md` | 16 | 300 | 1.5 | 0 | Default body |
| `body-sm` | 14 | 300 | 1.5 | 0 | Footer, fine print |
| `caption` | 12 | 400 | 1.4 | 0.5px | Captions |
| `button` | 14 | 700 | 1.0 | 1.5px | Button labels — uppercase |
| `nav-link` | 14 | 400 | 1.4 | 0.5px | Top-nav menu items |

### Principles
Heavy headlines (800) contrast against light body (300) at all times — the gap is the editorial signature. Letter-spacing is non-trivial: button labels and category labels carry 1.5px tracking that makes them feel machined. UPPERCASE display is the default voice for h1/h2.

## Layout

### Spacing System
- Base unit 4px. Tokens: 4 / 8 / 12 / 16 / 24 / 40 / 64 / 96.
- Section padding (vertical): 96px between major bands.
- Hero bands: 64px internal padding.
- Card internal padding: 24px content / 40px spec cells.
- Gutters: 24px between cards in grids; 16px inside footer columns.

### Grid & Container
- Max content width: ~1440px centered.
- Card grids: 3-up desktop, 2-up tablet, 1-up mobile.

### Whitespace Philosophy
Empty space stays as pure black canvas — never gradients, never atmospheric backdrops.

## Elevation & Depth

| Level | Treatment | Use |
|---|---|---|
| Flat | No shadow, no border | Body sections, nav, footer |
| Soft hairline | 1px `{colors.hairline}` border | Section dividers, card outlines, table rows |
| Card surface | `{colors.surface-card}` over canvas — no shadow | Feature cards, chatbot launcher |

No drop shadows. No layered chrome. Depth comes from the contrast between black canvas and slightly-elevated surface.

### Decorative Depth
- **Tricolor stripe**: A 4px horizontal divider carrying blue → indigo → red. Used sparingly as a brand-identity marker. The only true "decorative" element in the system.
- **Carbon-fiber surfaces**: `{colors.carbon-gray}` (#2b2b2b) cells with subtle texture overlay on technical-spec pages.

## Shapes

### Border Radius Scale

| Token | Value | Use |
|---|---|---|
| `none` | 0px | All buttons, cards, photo containers, spec cells, inputs — the dominant radius |
| `xs` | 2px | Almost no use |
| `sm` | 4px | Small toggle pills |
| `md` | 6px | Rare — small dropdown menu items |
| `full` | 9999px | Circular icon buttons, carousel arrows |

The radius hierarchy is "almost always 0, sometimes circular." Sharp rectangles read as engineered precision; circles read as functional controls. Nothing in between.

## Components

### Top Navigation
**`top-nav`** — Black nav bar pinned to top. 64px tall, canvas background. Logo at left, primary horizontal menu, right-side cluster.

### Buttons

**`button-primary`** — Background canvas, white text, 1px white border, `rounded.none`, padding 16×32, height 48. Type: uppercase 14/700/1.5px tracking.

**`button-primary-outline`** — Transparent background, white outline.

**`button-icon`** — Circular 48×48, surface-card background, white icon, `rounded.full`.

**`text-link`** — Inline uppercase letterspaced links. White, no underline. Chevron arrow → glyph next to most labels.

### Cards & Containers

**`hero-band`** — Full-width black band with UPPERCASE display headline at left, sub-headline below. 64px vertical padding.

**`feature-card`** — Surface-card background, `rounded.none`, 24px internal padding.

**`model-card`** — Canvas background (no card surface), `rounded.none`.

**`spec-cell`** — Surface-soft background, `rounded.none`, 24px padding. Value at top in display-sm, label below in label-uppercase.

**`chatbot-launcher`** — Right-side card on homepage. Surface-card, `rounded.none`, 24px padding.

**`category-tab`** + **`category-tab-active`** — Text-only labels in label-uppercase. Active gets white color + 2px white underline. No background, no rounded corners.

### Inputs

**`text-input`** — Surface-card background, white text, body-md, `rounded.none`, padding 12×16, height 48. 1px hairline border, white on focus.

### Signature Components

**`tricolor-stripe`** — The 4px horizontal stripe (blue light → blue dark → red). Used as divider on motorsport chrome, between brand sections, and as hover-state indicator on category tabs.

**`cta-band`** — Pre-footer CTA carrying a centered headline in display-md and a button-primary-outline below. 80px vertical padding.

### Footer
**`footer`** — Black footer. 4-column link list at desktop, vertical padding 64px.

## Do's and Don'ts

### Do
- Use UPPERCASE display headlines. Sentence-case display reads as off-brand.
- Pair heavy display (700–800) with light body (300). The weight contrast IS the editorial signature.
- Reserve the tricolor stripe for brand-identity moments — never as a button fill or surface.
- Use `rounded.none` by default. `rounded.full` only for circular icon buttons.
- Letter-space all-caps labels at 1.5px.
- Use 96px between major bands for grid-aligned vertical rhythm.

### Don't
- Don't introduce brand colors outside the tricolor.
- Don't bold body type. Body stays at 300 (Light).
- Don't use rounded buttons. The rectangular silhouette IS the brand.
- Don't put gradient backdrops behind hero type. The page floor stays pure black.
- Don't repeat the same surface mode in two consecutive bands.
- Don't use the tricolor stripe as a button fill — it's a divider/accent.

## Responsive Behavior

| Name | Width | Key Changes |
|---|---|---|
| Mobile | < 768px | Hamburger nav; hero h1 scales 80→48px; grids 1-up; footer 4→1 |
| Tablet | 768–1024px | Top nav tightens; 2-up grids; spec tables 2-up |
| Desktop | 1024–1440px | Full top-nav; 3-up grids; spec tables 4-up |
| Wide | > 1440px | Same as desktop; max content 1440px |

### Touch Targets
- `button-primary` 48×48 minimum (WCAG AAA).
- `button-icon` 48×48.
- `text-input` height 48.

### Collapsing Strategy
- Top nav collapses to hamburger sheet at < 768px; menu opens as full-screen black overlay with tricolor stripe at top.
- Card grids reduce columns rather than scaling cards down.
- Spec tables collapse 4-up → 2-up → 1-up; values stay at display-sm regardless of column count.
- Tricolor stripe stays 4px height across all breakpoints.

## Iteration Guide

1. Focus on ONE component at a time.
2. New components default to `rounded.none` (0px).
3. Variants (`-active`, `-disabled`) live as separate entries.
4. Use token references everywhere — never inline hex.
5. Never document hover states. Default and Active/Pressed only.
6. Display headlines stay UPPERCASE 700–800; body stays sentence-case 300.
7. The tricolor is brand-identity-only — never extend it to "primary action" tokens.
8. When in doubt about emphasis: bigger headline before bigger anything else.
