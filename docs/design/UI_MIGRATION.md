# ClawDeck UI Migration — Cockpit → Cream

The system moved from a high-contrast cockpit aesthetic (pure-black canvas, Saira Condensed UPPERCASE display, sharp 0-radius rectangles, tricolor BMW stripe) to the current warm humanist system: parchment cream canvas, Instrument Sans throughout, rounded corners, hairline `#eceae4` borders.

> Token spec: `DESIGN.md` (repo root).
> Component spec: `DESIGN_SYSTEM.md` (this folder).

---

## What changed at the token level

| Token | Old (cockpit) | New (cream) |
|---|---|---|
| `--color-bg-base` | `#000000` | **`#f7f4ed`** |
| `--color-bg-surface` | `#141414` | `#f7f4ed` |
| `--color-bg-card` | `#1f1f1f` | `#f7f4ed` |
| `--color-bg-elevated` | `#262626` | `#fcfbf8` |
| `--color-content` | `#ffffff` | **`#1c1c1c`** |
| `--color-content-secondary` | `#bbbbbb` | `rgba(28,28,28,0.82)` |
| `--color-border` | `#3a3a3a` | **`#eceae4`** |
| `--color-border-hover` | `#5c5c5c` | `rgba(28,28,28,0.4)` |
| Display font | Saira Condensed 800 UPPERCASE | **Instrument Sans 600** |
| Body font | Saira 300 (Light) | **Instrument Sans 400** |
| Default radius | 0px | **6px (buttons), 12px (cards)** |
| Accent | Tricolor `#0066b1 / #1c69d4 / #e22718` | Charcoal `#1c1c1c` (dark inset shadow) |
| Project red | `#e22718` | `#b3261e` |

Utilitários removidos: `.tricolor-stripe`, `.tricolor-stripe-vertical`, `.label-uppercase`.
Utilitários adicionados: `.btn-inset-shadow`, `.focus-soft`.

---

## Migration order (when porting a view)

1. **Audit dark literals.** Search for `#000000`, `#0d0d0d`, `#1a1a1a`, `#141414`, `#1f1f1f`, `#262626`, `#3a3a3a`, `#3c3c3c`, `#7e7e7e`, `#bbbbbb`. Mapear para os equivalentes cream (ver tabela acima).
2. **Drop atmospheric chrome.** Replace `bg-white/[0.04]`, `border-white/[0.08]` por sólidos (`bg-bg-elevated`, `border-border`).
3. **Round corners.** Adicionar `rounded-md` (6px) em botões/inputs, `rounded-xl` (12px) em cards, `rounded-full` em chips/dots. Remover `style="border-radius:0"`.
4. **Demote headlines.** Trocar `font-display font-extrabold uppercase tracking-tight` por `font-semibold tracking-[-0.025em]`. Sentence case.
5. **Heavier body.** Body sai de `font-light` (300) para `font-normal` (400). Buttons/card titles `font-medium` (500).
6. **CTAs invert.** Primary action passa a ser `bg-content text-content-inverse rounded-md btn-inset-shadow` (charcoal com inset shadow). Sem uppercase, sem letter-spacing extra.
7. **Strip the stripe.** Remover qualquer `<div class="tricolor-stripe"></div>`.
8. **Soft focus.** Inputs ganham `.focus-soft` em vez de `border-white` no focus.

---

## Arquivos migrados na passagem Cockpit → Cream

- `app/assets/tailwind/application.css` — `@theme` reescrito, utilitários novos.
- `app/views/layouts/application.html.erb` — fontes Instrument Sans, body cream.
- `app/views/layouts/landing.html.erb` — idem.
- `app/views/layouts/admin.html.erb` — Plus Jakarta Sans → Instrument Sans.
- `app/views/layouts/auth.html.erb` — Clash Display/Satoshi → Instrument Sans.
- `app/views/shared/_navbar.html.erb` — chrome cream, remove Discord, GitHub aponta para `HeitorTomaz/clawdeck`.
- `app/views/application/_navbar.html.erb` — idem.
- `app/views/shared/_filter_bar.html.erb` — chips pill cream.
- `app/views/shared/_command_bar.html.erb`, `_new_board_modal.html.erb`, `_task_activities.html.erb`.
- `app/views/application/_delete_modal.html.erb`.
- `app/views/boards/show.html.erb`, `list.html.erb`, `_header.html.erb`, `_column.html.erb`, `_task_card.html.erb`.
- `app/views/boards/tasks/new.html.erb`, `show.html.erb`, `_panel.html.erb`, `_agent_assignment.html.erb`, `_subtasks.html.erb`.
- `app/views/agents/index.html.erb`, `new.html.erb`, `edit.html.erb`.
- `app/views/sessions/new.html.erb`, `passwords/new.html.erb`, `passwords/edit.html.erb`, `registrations/new.html.erb`, `profiles/show.html.erb`.
- `app/views/home/show.html.erb`, `pages/home.html.erb`.
- `app/views/columns/_manage_modal.html.erb`, `columns/_form_modal.html.erb`.
- `app/helpers/application_helper.rb` — `board_hex_color` / `activity_icon_bg` ajustados para paleta cream.

Protótipos JSX removidos (`docs/design/clawdeck-board-v3.jsx`, `clawdeck-home-v4.jsx`).

---

## Verificação pós-migração

1. `bin/dev` ou `bin/rails s`, navegar pela view.
2. Canvas é cream (`#f7f4ed`) — não `#000000`.
3. h1/h2 em Instrument Sans 600 sentence-case.
4. Corpo em Instrument Sans 400.
5. Cantos arredondados (`rounded-md`, `rounded-xl`, `rounded-full` apenas).
6. Bordas são hairlines `#eceae4` ou interativa `rgba(28,28,28,0.4)`.
7. Seleção (`::selection`) destaca em charcoal `#1c1c1c` sobre `#fcfbf8`.
8. Botão primário tem inset shadow (DevTools mostra `.btn-inset-shadow`).
