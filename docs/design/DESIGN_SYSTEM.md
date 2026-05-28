# ClawDeck Design System v3 — Cockpit / High-Contrast
### For implementation in Rails + Tailwind CSS

> See `DESIGN.md` at repo root for the full token spec.
> Visual prototypes `clawdeck-home-v4.jsx` and `clawdeck-board-v3.jsx` document the v2 layout — translate the *structure* to v3 typography / chrome.

---

## Direction in one paragraph

ClawDeck is a cockpit. Pure-black canvas, white display headlines in UPPERCASE, light body type, and sharp rectangular silhouettes. The contrast between heavy display (800) and light body (300) is the editorial signature. Borders are 1px hairlines, never atmospheric glows. The system has one decorative element: a 4px tricolor stripe (blue → indigo → red) used sparingly as a brand-identity marker.

---

## Typography

**Display:** Saira Condensed (Google Fonts) — weights 700/800, UPPERCASE.
**Body:** Saira — weights 300/400/500/700.
**Mono:** JetBrains Mono — for timestamps, counts, technical values.

```html
<link href="https://fonts.googleapis.com/css2?family=Saira+Condensed:wght@500;700;800&family=Saira:wght@300;400;500;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
```

Tailwind tokens (`@theme` block in `app/assets/tailwind/application.css`):
- `--font-display: "Saira Condensed", "Saira", sans-serif` → `font-display`
- `--font-sans: "Saira", sans-serif` → `font-sans` (default)
- `--font-mono: "JetBrains Mono", monospace` → `font-mono`

**Weight scale:**
| Use | Weight | Tailwind |
|-----|--------|----------|
| Display headlines (h1/h2) | 800 | `font-extrabold` |
| Display sub-heads | 700 | `font-bold` |
| Labels / buttons (uppercase) | 700 | `font-bold` |
| Body | 300 (Light) | `font-light` |
| Emphasized body | 400 | `font-normal` |

**Size scale (display = Saira Condensed UPPERCASE):**
| Element | Size | Tailwind |
|---------|------|----------|
| Hero h1 | 48–80px | `text-5xl` → `text-8xl` |
| Page title / greeting | 44px | `text-[44px]` |
| Card title (detail) | 24px | `text-2xl` |
| Section header (label-uppercase) | 11px / 0.12em tracking | `.label-uppercase` |
| Card title (surface) | 13px | `text-[13px]` |
| Body | 14px | `text-sm` |

**Letter spacing:**
- Display: `tracking-tight` (-0.005em)
- Uppercase labels: `tracking-[0.12em]` to `tracking-[0.18em]`
- Body: default

---

## Colors

### Backgrounds
| Layer | Hex | Use | Tailwind token |
|-------|-----|-----|----------------|
| Canvas | `#000000` | Page floor — true black | `bg-bg-base` / `bg-black` |
| Surface soft | `#0d0d0d` | Spec cells, footer strips | `bg-bg-surface` |
| Surface card | `#1a1a1a` | Cards, secondary buttons | `bg-bg-card` / `bg-bg-elevated` |
| Surface elevated | `#262626` | Nested cards | matches `--color-border` |

### Text
| Use | Hex | Tailwind |
|-----|-----|----------|
| Primary (display, body on dark) | `#ffffff` | `text-white` / `text-content` |
| Secondary (body) | `#bbbbbb` | `text-[#bbbbbb]` / `text-content-secondary` |
| Muted (labels, captions) | `#7e7e7e` | `text-[#7e7e7e]` / `text-content-muted` |
| Dim (disabled) | `#555555` | `text-content-dim` |

### Borders
All hairlines are solid 1px lines — never atmospheric opacities:
- `#262626` → default hairline (`border-border`)
- `#3c3c3c` → strong hairline / hover (`border-border-hover`)
- `#ffffff` → focus / active (`border-border-active`)

### Tricolor accent
Used only for the brand stripe and active-state markers:
- `#0066b1` (blue-light)
- `#1c69d4` (blue-dark)
- `#e22718` (red)

Helper: `.tricolor-stripe` class (4px horizontal stripe). Never use as a button fill.

### Project colors (per-board accents — pills, dots, mini progress bars)
- ClawDeck `#e22718` · tini.bio `#0fa336` · Gratu `#f4b400` · nod.so `#1c69d4` · mx.works `#a78bfa`

### Functional
- Error / destructive: `#e22718`
- Warning: `#f4b400`
- Success: `#0fa336`
- Info: `#1c69d4`
- Agent: `#f4b400`

---

## Shape

**Default border-radius is 0.** Sharp rectangles read as engineered precision.

| Token | Value | Use |
|---|---|---|
| `none` | 0px | All buttons, cards, inputs, surfaces — the dominant radius |
| `sm` | 4px | Small toggle pills (rare) |
| `full` | 9999px | Avatars, circular icon buttons, dots |

There is no `rounded-lg` / `rounded-xl` / `rounded-2xl` in this system. If you're tempted to round a corner, ask whether it should be 0 or `rounded-full` instead.

---

## Spacing
- Base unit 4px.
- Tokens: 4 / 8 / 12 / 16 / 24 / 40 / 64 / 96.
- Cards: 14–24px internal padding.
- Major bands: 64–96px vertical spacing.
- Card stack gap: 5–8px (tight grid alignment).

---

## Components (Rails partials)

### Top nav (`shared/_navbar.html.erb`)
- 52px height, `#000000` background, bottom border `#262626`.
- Board name in **Saira Condensed UPPERCASE**, 13px, 800 weight, 0.02em tracking.
- Dropdowns: `#1a1a1a` background, `#3c3c3c` border, sharp corners.

### Task card (`boards/_task_card.html.erb`)
- `#0d0d0d` background, `#262626` 1px border, `#262626` left border (2px).
- Hover: left border + frame go white.
- Title: 13px, 500 weight, `#ffffff`.
- Project pill: project color text on `project-color @ 7% opacity`, 1px `project-color @ 9%` border, 0 radius.

### Column header (`boards/_column.html.erb`)
- Colored dot + UPPERCASE label (white) + count chip (hairline border, no fill).

### Task panel (`boards/tasks/_panel.html.erb`)
- Slide-in from right, 400px wide.
- `#000000` background, `#262626` left border.
- Tricolor stripe at top of panel.
- Title: Saira Condensed 24px UPPERCASE 800.
- Status pill: hairline border, uppercase 10px label, 0 radius.

### Buttons
- **Primary:** white background, black text, 12px uppercase 0.18em tracking, height 44–48px, 0 radius.
- **Secondary:** `#1a1a1a` background, white text, 1px `#3c3c3c` border, uppercase 0.14em tracking.
- **Icon-only / avatar:** `rounded-full` only when explicitly circular.

### Inputs
- `#1a1a1a` background, 1px `#3c3c3c` border, focus border `#ffffff`.
- Height 48px, 0 radius.
- Body type stays at 300 weight even in inputs.

### Labels
Use the `.label-uppercase` utility: `font-bold uppercase tracking-[0.12em] text-[11px]`.

---

## Anti-patterns (NEVER)

- ❌ Rounded corners on buttons or cards (use 0 or `rounded-full`).
- ❌ Atmospheric backgrounds — no gradients, no `bg-white/[0.04]` glow chrome. Use solid hairlines.
- ❌ Body type at weight 500+ (stays at 300).
- ❌ Sentence-case display headlines (h1/h2 are UPPERCASE).
- ❌ Tricolor stripe as a button fill — it's a divider/accent only.
- ❌ Inter, Plus Jakarta Sans, Satoshi, Clash Display, system fonts (use Saira / Saira Condensed).
- ❌ Multiple accent colors on the same surface — black + white + one project color, max.
- ❌ Tooltips containing critical info, dense small-text tables, confetti animations.

---

## Implementation checklist when migrating a view

1. Replace `rounded-*` with `style="border-radius:0"` (or remove entirely).
2. Replace `rgba(255,255,255,0.0X)` backgrounds with `#0d0d0d` / `#1a1a1a` solid surfaces.
3. Replace `rgba(255,255,255,0.0X)` borders with `#262626` / `#3c3c3c` hairlines.
4. Replace headline elements with `font-display font-extrabold uppercase tracking-tight`.
5. Replace `text-[#bbb]` body labels with the `.label-uppercase` utility where they're labels (Status, Priority, Today, Boards…).
6. Replace `bg-accent` red CTAs with white-on-black primary buttons.
7. Verify the page reads cleanly against pure-black canvas — no muddy mid-grays.
