# UserFlow — Nadodi v2.0

## 1. Primary Flow

```
Splash (2.5s, animated) ──> Home
                              │
   ┌──────────────────────────┼───────────────────────────────┐
   ▼                          ▼                               ▼
Search / categories      Map (bottom nav)              Trip Planner card
   ▼                          │                               │
Place list                Map screen                    Expense screen
   ▼                          │  ├─ request location          │
Place detail                  │  ├─ show user marker          │  ├─ add expense
   │                          │  ├─ show nearby markers       │  ├─ categorize
   ├─ Save (heart)            │  ├─ radius slider             │  ├─ edit/delete
   ├─ Directions              │  └─ Nearby panel ──> place detail   └─ summary: total,
   └─ Share                                                                  category bars,
                                                                             per-person
```

## 2. Screen-by-Screen

### Splash
Logo scales+fades in (elastic), tagline fades, shimmer progress → auto-navigate `/home` after 2.5s.

### Home
- Staggered fade-in of category chips and place cards.
- Search bar (animated focus ring), "Popular Places", "Trip Planner" entry card.
- Bottom nav: Home / Map / Hidden Gems (+ Saved via appbar, Profile via appbar).

### Map (NEW)
1. Open → request location permission (if not granted, show center-of-Kerala fallback).
2. Get current position → center map, show pulsing blue user marker.
3. Load all dataset items with coordinates → plot markers (category-colored).
4. Compute distances (haversine) → "Nearby suggestions" bottom sheet lists items
   within radius (default 60 km) sorted by distance.
5. User adjusts radius slider → list + markers update.
6. Tap suggestion or marker → `/place-detail`.

### Expense Calculator (NEW)
1. Tap card → Expense screen with summary header + entry list.
2. "Add Expense" → bottom-sheet form: title, category, amount, date (default today).
3. Save → persists via shared_preferences; totals recompute.
4. Swipe/edit/delete entries. Traveler count stepper → per-person split.
5. Category breakdown bars update live.

### Place Detail
Themed (emerald), hero image transition from card, rating, info cards, nearby hotels/restaurants teaser, Directions/Call buttons.

## 3. Permissions

- Location: requested on Map open (ACCESS_FINE/COARSE in manifest + runtime).
- No other runtime permissions needed.

## 4. States

- No location permission → banner + default Kerala center view.
- No places within radius → friendly empty state with "increase radius" CTA.
- No expenses → empty state with "Add your first expense".
