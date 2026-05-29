# ClawDeck Design System — Implementation Guide
### For implementation in Rails + Tailwind CSS

> See `DESIGN.md` at repo root for the full token spec and narrative.

---

## Direction in one paragraph

ClawDeck is a warm, humanist interface. Parchment-cream canvas (`#f7f4ed`), charcoal text (`#1c1c1c`), Instrument Sans throughout. Borders are 1px hairlines (`#eceae4` passive, `rgba(28,28,28,0.4)` interactive). Cards round at 12px, buttons/inputs at 6px, action pills at 9999px. The signature detail is the inset shadow on dark buttons — a multi-layer technique that gives the primary CTA a tactile, pressed-into-surface quality. No tricolor stripes, no UPPERCASE display, no atmospheric darkness.

---

## Typography

**Family:** Instrument Sans (variable, weights 400/500/600) — Google Fonts.
**Mono:** JetBrains Mono — timestamps, tokens, counters.

```html
<link href="https://fonts.googleapis.com/css2?family=Instrument+Sans:ital,wght@0,400..700;1,400..700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
```

Tailwind tokens (`@theme` in `app/assets/tailwind/application.css`):
- `--font-sans: "Instrument Sans", ui-sans-serif, system-ui, sans-serif` → `font-sans` (default)
- `--font-display: "Instrument Sans", …` → `font-display`
- `--font-mono: "JetBrains Mono", monospace` → `font-mono`

**Weight scale:**
| Use | Weight | Tailwind |
|-----|--------|----------|
| Display headlines (h1/h2) | 600 | `font-semibold` |
| Card titles, buttons | 500 | `font-medium` |
| Body | 400 | `font-normal` |

**Size scale:**
| Element | Size | Tailwind |
|---------|------|----------|
| Hero h1 | 48–60px | `text-5xl` → `text-6xl` |
| Page title | 36px | `text-4xl` |
| Card title (detail) | 24px | `text-2xl` |
| Section label | 14px (500) | `text-sm font-medium` |
| Card title (surface) | 16–20px | `text-base` / `text-xl` |
| Body | 16px | `text-base` |
| Caption | 14px | `text-sm` |

**Letter spacing:**
- Display 60px / 48px / 36px: `tracking-[-0.025em]` (≈ -1.5px → -0.9px scaled)
- Body: default

---

## Colors

### Backgrounds
| Layer | Hex | Use | Tailwind token |
|-------|-----|-----|----------------|
| Canvas | `#f7f4ed` | Page floor — cream | `bg-bg-base` |
| Surface | `#f7f4ed` | Cards (sangram no canvas) | `bg-bg-surface` |
| Elevated | `#fcfbf8` | Nested chips, dropdowns | `bg-bg-elevated` / `bg-bg-dropdown` |
| Hover tint | `rgba(28,28,28,0.04)` | Subtle hover backgrounds | `bg-bg-hover` |

### Text
| Use | Hex | Tailwind |
|-----|-----|----------|
| Primary | `#1c1c1c` | `text-content` |
| Secondary | `rgba(28,28,28,0.82)` | `text-content-secondary` |
| Muted | `#5f5f5d` | `text-content-muted` |
| Dim (disabled) | `rgba(28,28,28,0.4)` | `text-content-dim` |
| Inverse (on dark) | `#fcfbf8` | `text-content-inverse` |

### Borders
- `#eceae4` → passive (`border-border`)
- `rgba(28,28,28,0.4)` → interactive / hover (`border-border-hover`)
- `#1c1c1c` → focus / active (`border-border-active`)

### Project colors
- ClawDeck `#b3261e` · tini.bio `#1e7a4e` · Gratu `#a07400` · nod.so `#1f5fa8` · mx.works `#6d4eb8`

### Functional
- Error / destructive: `#b3261e`
- Warning: `#a07400`
- Success: `#1e7a4e`
- Info: `#1f5fa8`

---

## Shape

| Token | Value | Use |
|---|---|---|
| `rounded` (6px) | 6px | Buttons, inputs, navigation menu |
| `rounded-lg` | 8px | Compact cards |
| `rounded-xl` | 12px | Standard cards, task cards |
| `rounded-2xl` | 16px | Large containers, dialogs |
| `rounded-full` | 9999px | Avatars, dots, filter chips, action pills |

Cards sangram no canvas (mesma cor `#f7f4ed`) — a borda `#eceae4` é o que define a forma.

---

## Spacing
- Base unit 8px.
- Tokens: 8 / 12 / 16 / 24 / 32 / 40 / 56 / 80 / 96.
- Cards: 14–24px internal padding.
- Major bands: 80–128px vertical spacing.
- Card stack gap: 12–16px.

---

## Components (Rails partials)

### Top nav (`shared/_navbar.html.erb`)
- ~56px height, `#f7f4ed` background.
- Wordmark + links Instrument Sans 16px weight 400.
- Botão CTA dark com `.btn-inset-shadow`.

### Task card (`boards/_task_card.html.erb`)
- `#f7f4ed` background, `1px solid #eceae4` border, `rounded-xl` (12px).
- Title: 16px 500 `#1c1c1c`.
- Tag chips: rounded-full, `bg-[#fcfbf8] border-[#eceae4]`, project color dot.

### Column header (`boards/_column.html.erb`)
- Dot colorido + label `text-sm font-medium text-content` (sem uppercase) + contador chip `border-[#eceae4] bg-[#fcfbf8] rounded-full px-2 py-0.5 text-xs`.

### Task panel (`boards/tasks/_panel.html.erb`)
- Slide-in da direita, ~420px wide.
- `#fcfbf8` background, `border-left: 1px solid #eceae4`.
- Title: Instrument Sans 24px 600, `tracking-[-0.02em]`.
- Status pill: `border-[#eceae4] rounded-full px-3 py-1 text-sm`.

### Filter bar (`shared/_filter_bar.html.erb`)
- Search input: `bg-[#f7f4ed] border border-[#eceae4] rounded-md focus-soft`.
- Active chips: rounded-full, `bg-[#fcfbf8] border-[#eceae4] px-3 py-1 text-sm`, com `×` para remover.
- "Clear" link sublinhado.

### Buttons
- **Primary (dark inset):** `bg-content text-content-inverse rounded-md px-4 py-2 font-medium btn-inset-shadow`.
- **Ghost:** `bg-transparent border border-[rgba(28,28,28,0.4)] text-content rounded-md px-4 py-2`.
- **Cream surface:** `bg-bg-base text-content rounded-md px-4 py-2`.

### Inputs
- `bg-bg-base border border-border rounded-md px-3 py-2 text-content focus-soft`.
- Placeholder: `text-content-muted`.

### Labels
Sem `.label-uppercase`. Use `text-sm font-medium text-content`.

---

## Anti-patterns (NEVER)

- ❌ Preto puro `#000000` ou canvas escuro.
- ❌ Saira / Saira Condensed / Plus Jakarta Sans / Clash Display.
- ❌ UPPERCASE em headlines ou labels.
- ❌ Weight ≥ 700.
- ❌ `.tricolor-stripe`, `.label-uppercase`.
- ❌ `rounded` = 0.
- ❌ Box-shadows pesadas para cards.
- ❌ Cores neon / saturadas.
- ❌ Atmospheric backgrounds (`bg-white/[0.04]` etc.).

---

## Checklist ao migrar uma view

1. Backgrounds dark (`bg-black`, `bg-[#0d0d0d]`, `bg-[#1a1a1a]`) → `bg-bg-base` ou remover (herda do body).
2. `text-white` → `text-content`; `text-[#bbbbbb]` → `text-content-secondary`; `text-[#7e7e7e]` → `text-content-muted`.
3. Hairlines escuras (`border-[#262626]`, `border-[#3c3c3c]`) → `border-border`.
4. Remover `font-display font-extrabold uppercase tracking-tight` → `font-semibold tracking-[-0.025em]`.
5. Remover `.label-uppercase` → `text-sm font-medium text-content`.
6. Remover `style="border-radius:0"`; aplicar `rounded-md` (buttons/inputs), `rounded-xl` (cards), `rounded-full` (chips).
7. CTAs primárias: `bg-content text-content-inverse rounded-md btn-inset-shadow`.
8. Remover qualquer `<div class="tricolor-stripe"></div>`.
9. Inputs: `bg-bg-base border border-border focus-soft`.
