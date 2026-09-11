# DesignBrief — Nadodi v2.0

Design system derived from reference PDF `PDF_20260731120059.pdf` (Travelexa-style
travel UI, extracted programmatically: page renders OCR'd as "Welcome to Travelexa",
"Explore new horizons", destination cards, Trip Planner, auth screens; color sampling
yielded the palette below).

## 1. Color Palette

| Token | Hex | Usage |
|---|---|---|
| `primary` | `#007860` | Primary buttons, AppBar, active nav, key accents |
| `primaryDark` | `#286850` | Pressed states, gradients, headers |
| `secondary` | `#70A8B8` | Secondary accents, links, map control tint |
| `accentLight` | `#88C0D8` | Highlights, badge backgrounds, gradients |
| `background` | `#F8F8F8` | App scaffold background |
| `surface` | `#FFFFFF` | Cards, sheets, inputs |
| `textPrimary` | `#1A1D1B` | Headings / body emphasis |
| `textSecondary` | `#6B7A76` | Body secondary |
| `rating` | `#F5B301` | Star ratings |
| `danger` | `#D64545` | Destructive actions |

Derived from sampled colors: `#007860` (deep emerald teal), `#307058`/`#286850`
(dark greens), `#F8F8F8` (bg), `#70A8B8`/`#88C0D8` (light blue secondary).

## 2. Typography

- Family: Poppins (declared; falls back to system on device if not bundled).
- Headings: w700 28 / w600 18-20; Body: w400 14-16; Captions: w400 12.
- Numbers/currency: tabular-ish (monospace fallback not required), ₹ prefix via intl.

## 3. Shape & Elevation

- Cards: 16dp radius, surface white, subtle shadow (elevation 2-4).
- Chips: pill (radius 20), selected = primary bg white text.
- Buttons: 12dp radius, primary fill; secondary = outlined primary.
- Bottom sheets: rounded 20dp top corners.

## 4. Motion

- Route transition: 300ms fade + 24dp slide-up, easeOutCubic.
- List stagger: 60ms interval fade+slide per item.
- Hero: card image → detail header (default 300ms).
- Splash: logo scale 0.6→1.0 elastic, tagline fade at 0.5 interval, shimmer progress.
- Map user marker: repeating 1.2s ripple pulse.

## 5. Iconography & Imagery

- Material icons; category icons: Beach=pool, Hill Station=terrain, Waterfall=water,
  Historical=fort, Backwaters=waves, Trek=forest, Hotel=hotel, Food=restaurant.
- Images: network URLs with graceful gradient fallback (landscape icon + primary tint).

## 6. Screens Mapped to Reference

| Reference screen | Nadodi v2.0 screen |
|---|---|
| Welcome/Explore hero | Splash + Home header |
| Destination cards | PlaceCard (emerald chip + rating) |
| Place detail ("Bali… Reviews / Read More") | PlaceDetailScreen |
| Trip Planner ("Navigate the world") | Expense Screen entry card |
| Auth screens | Out of scope (no accounts in v2.0) |
