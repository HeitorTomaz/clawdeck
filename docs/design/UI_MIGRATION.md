# ClawDeck UI Migration — v2 → v3 Cockpit

The system moved from a low-contrast neutral-dark palette (v2) to a high-contrast cockpit aesthetic (v3): pure-black canvas, white UPPERCASE display, Saira Condensed type, sharp 0-radius rectangles, hairline borders, and a tricolor brand stripe.

> Token spec: `DESIGN.md` (repo root).
> Component spec: `DESIGN_SYSTEM.md` (this folder).

---

## What changed at the token level

| Token | v2 | v3 |
|---|---|---|
| `--color-bg-base` | `#161619` | **`#000000`** |
| `--color-bg-surface` | `#161619` | `#0d0d0d` |
| `--color-bg-card` | `#1e1e22` | `#1a1a1a` |
| `--color-content` | `#f0f0f0` | **`#ffffff`** |
| `--color-border` | `rgba(255,255,255,0.05)` | **`#262626`** (solid hairline) |
| Display font | Plus Jakarta Sans 800 | **Saira Condensed 800 UPPERCASE** |
| Body font | Plus Jakarta Sans 500 | **Saira 300 (Light)** |
| Default radius | 8–14px | **0px** |
| Accent | red `#ef4444` only | tricolor `#0066b1 / #1c69d4 / #e22718` |

---

## Migration order (when porting a view)

1. **Audit hardcoded colors.** Search for `#161619`, `#1e1e22`, `#f0f0f0`, `#e0e0e0`, `#888`, `rgba(255,255,255,0.0` — these are v2 literals. Map them to v3 (`#000000`, `#1a1a1a`, `#ffffff`, `#7e7e7e`, `#262626`).
2. **Drop atmospheric chrome.** Replace `bg-white/[0.04]` / `border-white/[0.08]` with solid hairlines (`bg-[#1a1a1a]`, `border-[#262626]`).
3. **Sharpen corners.** Remove every `rounded-lg`, `rounded-xl`, `rounded-2xl`, `rounded-[14px]`, `border-radius:10px`. Default to `border-radius:0`. Keep `rounded-full` for avatars / dots only.
4. **Promote headlines.** Wrap h1/h2 with `font-display font-extrabold uppercase tracking-tight`. Convert section labels to `.label-uppercase` utility.
5. **Lighten body.** Body text moves to `font-light` (300). Never go heavier than `font-normal` (400) for running text.
6. **CTAs invert.** Primary action becomes white-on-black with uppercase letterspaced label. Red is reserved for destructive only.
7. **Brand moments get the stripe.** Add `<div class="tricolor-stripe"></div>` at the top of major surfaces (login card, task panel, settings header).

---

## Files migrated in v3 baseline

- `app/assets/tailwind/application.css` — `@theme` tokens, base layer rules, `.label-uppercase` + `.tricolor-stripe` utilities.
- `app/views/layouts/application.html.erb` — Saira font links, `bg-black` body.
- `app/views/layouts/landing.html.erb` — Saira font links, plain black background (removed `.stars` / `.nebula` decorations).
- `app/views/shared/_navbar.html.erb` — canvas-black navbar, Saira Condensed UPPERCASE board name.
- `app/views/boards/_task_card.html.erb` — solid hairline card, sharp corners, white title.
- `app/views/boards/_column.html.erb` — UPPERCASE column header, hairline count chip, sharp corners.
- `app/views/boards/show.html.erb` — sharp-corner "Add column" CTA.
- `app/views/boards/tasks/_panel.html.erb` — tricolor stripe header, Saira Condensed title, hairline status pill.
- `app/views/home/show.html.erb` — Saira Condensed greeting, UPPERCASE section labels, solid hairline cards.
- `app/views/sessions/new.html.erb` — full v3 login form.
- `app/views/pages/home.html.erb` — landing hero + login card in v3.

---

## Still on v2 (migrate as touched)

These views still use v2 chrome and will inherit the new tokens via `@theme` but won't pick up the Saira Condensed / UPPERCASE display unless their headlines are explicitly migrated:

- `app/views/admin/**`
- `app/views/passwords/**`
- `app/views/registrations/new.html.erb`
- `app/views/columns/_manage_modal.html.erb`, `columns/_form_modal.html.erb`
- `app/views/agents/**`
- `app/views/profiles/show.html.erb`
- `app/views/shared/_command_bar.html.erb`, `_new_board_modal.html.erb`, `_task_activities.html.erb`
- `app/views/boards/_header.html.erb`, `boards/tasks/_agent_assignment.html.erb`, `boards/tasks/_subtasks.html.erb`

When migrating any of these, follow the 7-step checklist above.

---

## How to verify a migrated view

1. Boot the dev server, navigate to the view in a browser.
2. Confirm canvas is pure black (`#000000`) — not `#161619` or `#0c0c0f`.
3. Confirm h1/h2 are UPPERCASE in Saira Condensed.
4. Confirm body copy is Saira Light (300 weight).
5. Confirm corners are square (no `rounded-*` showing in DevTools).
6. Confirm borders are solid hairlines, not translucent whites.
7. Selection color (`::selection`) should highlight in tricolor-red `#e22718`.
