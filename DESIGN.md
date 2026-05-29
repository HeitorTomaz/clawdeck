# ClawDeck Design System

## 1. Visual Theme & Atmosphere

ClawDeck radiates warmth through restraint. The entire interface sits on a creamy, parchment-toned background (`#f7f4ed`) that separates it from the cold-white conventions of most developer tool dashboards. This isn't minimalism for minimalism's sake — it's a deliberate choice to feel approachable, almost analog, like a well-crafted notebook. The near-black text (`#1c1c1c`) against this warm cream creates a contrast ratio that's easy on the eyes while maintaining sharp readability.

Instrument Sans is the system's typographic backbone. A humanist variable sans-serif, it brings warmth and editorial calm where geometric sans-serifs would feel clinical. At display sizes (48px–60px), weight 600 with aggressive negative letter-spacing (-0.9px to -1.5px) compresses headlines into confident, editorial statements. The fallback stack — `ui-sans-serif, system-ui` — keeps the page legible even before web fonts load.

What makes the system distinctive is its opacity-driven depth model. Rather than using a traditional gray scale, the system modulates `#1c1c1c` at varying opacities (0.03, 0.04, 0.4, 0.82–0.83) to create a unified tonal range. Every shade of gray on the page is technically the same hue — just more or less transparent. This creates a visual coherence that's nearly impossible to achieve with arbitrary hex values. The border system follows suit: `1px solid #eceae4` for light divisions and `1px solid rgba(28, 28, 28, 0.4)` for stronger interactive boundaries.

**Key Characteristics:**
- Warm parchment background (`#f7f4ed`) — not white, not beige, a deliberate cream
- Instrument Sans variable typeface with humanist warmth and editorial letter-spacing at display sizes
- Opacity-driven color system: all grays derived from `#1c1c1c` at varying transparency levels
- Inset shadow technique on buttons: `rgba(255,255,255,0.2) 0px 0.5px 0px 0px inset, rgba(0,0,0,0.2) 0px 0px 0px 0.5px inset`
- Warm neutral border palette: `#eceae4` for subtle, `rgba(28,28,28,0.4)` for interactive elements
- Full-pill radius (`9999px`) used selectively for action toggles and icon containers
- Focus state uses `rgba(0,0,0,0.1) 0px 4px 12px` shadow for soft, warm emphasis
- Tailwind utility styling on Rails ERB partials — no JS UI framework

## 2. Color Palette & Roles

### Primary
- **Cream** (`#f7f4ed`): Page background, card surfaces, button surfaces. The foundation — warm, paper-like, human.
- **Charcoal** (`#1c1c1c`): Primary text, headings, dark button backgrounds. Not pure black — organic warmth.
- **Off-White** (`#fcfbf8`): Button text on dark backgrounds, subtle highlight surfaces.

### Neutral Scale (Opacity-Based)
- **Charcoal 100%** (`#1c1c1c`): Primary text, headings, dark surfaces.
- **Charcoal 83%** (`rgba(28,28,28,0.83)`): Strong secondary text.
- **Charcoal 82%** (`rgba(28,28,28,0.82)`): Body copy.
- **Muted Gray** (`#5f5f5d`): Secondary text, descriptions, captions.
- **Charcoal 40%** (`rgba(28,28,28,0.4)`): Interactive borders, button outlines.
- **Charcoal 4%** (`rgba(28,28,28,0.04)`): Subtle hover backgrounds, micro-tints.
- **Charcoal 3%** (`rgba(28,28,28,0.03)`): Barely-visible overlays, background depth.

### Surface & Border
- **Light Cream** (`#eceae4`): Card borders, dividers, image outlines. The warm divider line.
- **Cream Surface** (`#f7f4ed`): Card backgrounds, section fills — same as page background for seamless integration.

### Functional / Project Accents
Saturation kept low for legibility on cream:
- Error / destructive: `#b3261e`
- Success: `#1e7a4e`
- Warning: `#a07400`
- Info: `#1f5fa8`
- Agent: `#a07400`

Per-board accents (chips, dots, mini progress):
- ClawDeck `#b3261e` · tini.bio `#1e7a4e` · Gratu `#a07400` · nod.so `#1f5fa8` · mx.works `#6d4eb8`

### Interactive
- **Focus Shadow** (`rgba(0,0,0,0.1) 0px 4px 12px`): Focus and active state shadow — soft, warm, diffused.

### Inset Shadows
- **Button Inset** (`rgba(255,255,255,0.2) 0px 0.5px 0px 0px inset, rgba(0,0,0,0.2) 0px 0px 0px 0.5px inset, rgba(0,0,0,0.05) 0px 1px 2px 0px`): The signature multi-layer inset shadow on dark buttons.

## 3. Typography Rules

### Font Family
- **Primary**: `Instrument Sans`, with fallbacks: `ui-sans-serif, system-ui, sans-serif`
- **Mono**: `JetBrains Mono` — timestamps, counters, tokens.
- **Weight range used**: 400 (body/UI), 500 (subtle emphasis), 600 (headings/emphasis).
- **Style**: Variable font, supports italic axis. Keep weight ≤ 600.

### Hierarchy

| Role | Size | Weight | Line Height | Letter Spacing | Notes |
|------|------|--------|-------------|----------------|-------|
| Display Hero | 60px (3.75rem) | 600 | 1.00–1.10 (tight) | -1.5px | Maximum impact, editorial |
| Section Heading | 48px (3.00rem) | 600 | 1.00 (tight) | -1.2px | Feature section titles |
| Sub-heading | 36px (2.25rem) | 600 | 1.10 (tight) | -0.9px | Sub-sections |
| Card Title | 20px (1.25rem) | 500 | 1.25 (tight) | normal | Card headings |
| Body Large | 18px (1.13rem) | 400 | 1.38 | normal | Introductions |
| Body | 16px (1.00rem) | 400 | 1.50 | normal | Standard reading text |
| Button | 16px (1.00rem) | 500 | 1.50 | normal | Button labels |
| Button Small | 14px (0.88rem) | 500 | 1.50 | normal | Compact buttons |
| Link | 16px (1.00rem) | 400 | 1.50 | normal | Underline decoration |
| Caption | 14px (0.88rem) | 400 | 1.50 | normal | Metadata, small text |

### Principles
- **Warm humanist voice**: Instrument Sans gives ClawDeck its approachable personality. Slightly open apertures and organic curves contrast with the sharp geometric sans-serifs used by most developer tools.
- **Compression at scale**: Headlines use negative letter-spacing (-0.9px to -1.5px) for editorial impact. Body text stays at normal tracking for comfortable reading.
- **Narrow weight range**: 400 (body/UI/links), 500 (buttons, card titles), 600 (headings). Never 700+. Hierarchy comes from size and spacing, not heavy weight contrast.

## 4. Component Stylings

### Buttons

**Primary Dark (Inset Shadow)**
- Background: `#1c1c1c`
- Text: `#fcfbf8`
- Padding: 8px 16px
- Radius: 6px
- Shadow: `rgba(255,255,255,0.2) 0px 0.5px 0px 0px inset, rgba(0,0,0,0.2) 0px 0px 0px 0.5px inset, rgba(0,0,0,0.05) 0px 1px 2px 0px`
- Active: opacity 0.8
- Focus: `rgba(0,0,0,0.1) 0px 4px 12px` shadow
- Use: Primary CTAs (login, create board, save task)
- Class helper: `.btn-inset-shadow`

**Ghost / Outline**
- Background: transparent
- Text: `#1c1c1c`
- Padding: 8px 16px
- Radius: 6px
- Border: `1px solid rgba(28,28,28,0.4)`
- Active: opacity 0.8
- Use: Secondary actions (cancel, ghost menu items)

**Cream Surface**
- Background: `#f7f4ed`
- Text: `#1c1c1c`
- Padding: 8px 16px
- Radius: 6px
- No border
- Use: Tertiary actions, toolbar buttons

**Pill / Icon Button**
- Background: `#fcfbf8`
- Text: `#1c1c1c`
- Radius: 9999px (full pill)
- Optional inset shadow same as primary dark
- Use: Filter chips, toggle pills, icon-only actions

### Cards & Containers
- Background: `#f7f4ed` (matches page)
- Border: `1px solid #eceae4`
- Radius: 12px (standard), 16px (featured), 8px (compact)
- No box-shadow by default — borders define boundaries

### Inputs & Forms
- Background: `#f7f4ed`
- Text: `#1c1c1c`
- Border: `1px solid #eceae4`
- Radius: 6px
- Focus: `.focus-soft` (warm diffused shadow)
- Placeholder: `#5f5f5d`

### Navigation
- Sticky horizontal nav on cream, no border by default
- Logo left-aligned
- Links: Instrument Sans 14–16px weight 400, `#1c1c1c`
- CTA: dark button with inset shadow
- Mobile: hamburger menu with 6px radius

### Links
- Color: `#1c1c1c`
- Decoration: underline (default)
- Hover: opacity 0.8
- No color change on hover — decoration carries the interactive signal

### Distinctive Components

**Filter Bar (`shared/_filter_bar`)**
- Search input + active filter chips
- Active chips: pill (`rounded-full`) with `bg-[#fcfbf8] border border-[#eceae4]`, label + dismiss `×`
- Active count badge: `text-sm font-medium text-[#5f5f5d]`
- "Clear filters" link: underlined

**Task Card (`boards/_task_card`)**
- Background `#f7f4ed`, border `1px solid #eceae4`, radius 12px, padding 14–16px
- Title: 16px weight 500 `#1c1c1c`
- Tags as small pills with project color dot

**Task Panel (`boards/tasks/_panel`)**
- Slide-in right, ~420px wide, `#fcfbf8` background, `border-left: 1px solid #eceae4`
- Title: Instrument Sans 24px 600 letter-spacing -0.5px
- Status pill: hairline border, rounded-full, 14px

**Agent Card (`agents/index`)**
- Cream card with `#eceae4` border, 12px radius
- API token in `font-mono` chip with `bg-[#fcfbf8]`

## 5. Layout Principles

### Spacing System
- Base unit: 8px
- Scale: 8 / 10 / 12 / 16 / 24 / 32 / 40 / 56 / 80 / 96 / 128 / 176 / 192 / 208

### Grid & Container
- Max content width: ~1200px (centered)
- Hero: centered single-column with massive vertical padding (96px+)
- Feature sections: 2–3 column grids
- Showcase / list views: cards in responsive grids

### Whitespace Philosophy
- Editorial generosity at section boundaries (80px–208px)
- Tight internal spacing within cards (12–24px)
- Sections defined by spacing rather than border lines

### Border Radius Scale
- Micro (4px): Small interactive elements
- Standard (6px): Buttons, inputs, navigation menu
- Comfortable (8px): Compact cards
- Card (12px): Standard cards, image containers
- Container (16px): Large containers, dialog frames
- Full Pill (9999px): Action pills, icon buttons, filter chips

## 6. Depth & Elevation

| Level | Treatment | Use |
|-------|-----------|-----|
| Flat (Level 0) | No shadow, cream background | Page surface, most content |
| Bordered (Level 1) | `1px solid #eceae4` | Cards, images, dividers |
| Inset (Level 2) | `.btn-inset-shadow` utility | Dark buttons, primary actions |
| Focus (Level 3) | `.focus-soft` utility | Active/focus states |

**Shadow Philosophy**: ClawDeck's depth system is intentionally shallow. Instead of floating cards with dramatic drop-shadows, the system relies on warm borders (`#eceae4`) against the cream surface to create gentle containment. The only notable shadow pattern is the inset shadow on dark buttons — a subtle multi-layer technique where a white highlight line sits at the top edge while a dark ring and soft drop handle the bottom. This creates a tactile, pressed-into-surface feeling rather than a hovering-above-surface feeling.

## 7. Do's and Don'ts

### Do
- Use the warm cream background (`#f7f4ed`) as the page foundation
- Use Instrument Sans at display sizes with negative letter-spacing (-0.9px to -1.5px)
- Derive all grays from `#1c1c1c` at varying opacity levels for tonal unity
- Use the inset shadow technique on dark buttons for tactile depth
- Use `#eceae4` borders instead of shadows for card containment
- Keep the weight system narrow: 400 for body, 500 for buttons/card titles, 600 for headings
- Use full-pill radius (9999px) for action pills, filter chips, icon toggles
- Apply opacity 0.8 on active states for responsive tactile feedback

### Don't
- Don't use pure white (`#ffffff`) or pure black (`#000000`) as backgrounds — cream and charcoal are intentional
- Don't use heavy box-shadows for cards — borders are the containment mechanism
- Don't introduce saturated accent colors — the palette is intentionally warm-neutral
- Don't use weight 700+ — 600 is the maximum
- Don't UPPERCASE display headlines — Instrument Sans runs sentence-case
- Don't apply 9999px radius on rectangular buttons — pills are for chips/toggles
- Don't use sharp focus outlines — the system uses soft shadow-based focus indicators
- Don't increase letter-spacing on headings — runs tight at scale
- Don't bring back tricolor stripes, Saira, or any cockpit-era chrome

## 8. Responsive Behavior

### Breakpoints
| Name | Width | Key Changes |
|------|-------|-------------|
| Mobile Small | <600px | Tight single column, reduced padding |
| Mobile | 600–640px | Standard mobile layout |
| Tablet Small | 640–700px | 2-column grids begin |
| Tablet | 700–768px | Card grids expand |
| Desktop Small | 768–1024px | Multi-column layouts |
| Desktop | 1024–1280px | Full feature layout |
| Large Desktop | 1280–1536px | Maximum content width, generous margins |

### Collapsing Strategy
- Hero: 60px → 48px → 36px headline scaling with proportional letter-spacing
- Navigation: horizontal links → hamburger menu at 768px
- Feature cards: 3-column → 2-column → single column stacked
- Section spacing: 128px+ → 64px on mobile

## 9. Agent Prompt Guide

### Quick Color Reference
- Primary CTA: Charcoal (`#1c1c1c`) with inset shadow
- Background: Cream (`#f7f4ed`)
- Heading text: Charcoal (`#1c1c1c`)
- Body text: Charcoal 82% (`rgba(28,28,28,0.82)`) or Muted Gray (`#5f5f5d`)
- Border: `#eceae4` (passive), `rgba(28,28,28,0.4)` (interactive)
- Focus: `.focus-soft`
- Button text on dark: `#fcfbf8`

### Example Component Prompts
- "Create a hero on cream (#f7f4ed). Headline at 60px Instrument Sans weight 600, line-height 1.10, letter-spacing -1.5px, color #1c1c1c. Subtitle at 18px weight 400, line-height 1.38, color #5f5f5d. Dark CTA button (#1c1c1c bg, #fcfbf8 text, 6px radius, 8px 16px padding, .btn-inset-shadow) and ghost button (transparent bg, 1px solid rgba(28,28,28,0.4) border, 6px radius)."
- "Design a card on cream (#f7f4ed). Border: 1px solid #eceae4. Radius 12px. No box-shadow. Title at 20px Instrument Sans weight 500, line-height 1.25, color #1c1c1c. Body at 14px weight 400, color #5f5f5d."
- "Build a filter bar: search input (cream bg, #eceae4 border, 6px radius) followed by active filter chips. Each chip: rounded-full, bg-[#fcfbf8] border-[#eceae4], label + × dismiss. 'Clear filters' link with underline."
- "Create navigation: sticky on cream. Instrument Sans 16px weight 400 for links, #1c1c1c text. Dark CTA button right-aligned with inset shadow. Mobile: hamburger menu with 6px radius."

### Iteration Guide
1. Always use cream (`#f7f4ed`) as the base — never pure white or pure black
2. Derive grays from `#1c1c1c` at opacity levels rather than using distinct hex values
3. Use `#eceae4` borders for containment, not shadows
4. Letter-spacing scales with size: -1.5px at 60px, -1.2px at 48px, -0.9px at 36px, normal at 16px
5. Three weights: 400 (body), 500 (buttons/card titles), 600 (headings)
6. The inset shadow on dark buttons is the signature detail — don't skip it
7. Keep palette warm — no neon, no saturated reds, no cockpit black
