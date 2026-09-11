# PRD — Nadodi v2.0 (Kerala Travel Discovery App)

Source: extracted from `Nadodi_PRD_TRD.docx` (v1.0, July 2026) + v2.0 upgrade request.
Owner: Sreejith R (Vynrix). Status: v2.0 upgrade in progress.

## 1. Product Overview

Nadodi ("wanderer") is a Kerala-focused travel discovery app. v1.0 ships a Flutter app
(Android APK `com.example.nadodi`, version 1.0.0) with a browsable, curated database of
Kerala destinations. v2.0 adds three headline capabilities on top of the existing
discovery flow:

1. **Map view with suggested spots nearby** — an interactive map that shows the user's
   current location and suggests nearby tourist places, hotels, restaurants, and hidden
   gems within a configurable radius.
2. **Trip expense calculator** — a trip planner that lets travelers add expenses
   (transport, stay, food, activities, misc) and see live totals, per-day breakdowns,
   and per-person cost.
3. **Full theme refresh** — the entire app adopts the design system defined in the
   reference PDF (`PDF_20260731120059.pdf`, a Travelexa-style travel UI): emerald-teal
   primary, light backgrounds, soft cards.
4. **Animations** — polished motion throughout (splash, screen transitions, list
   stagger-in, hero transitions, map marker pulses).

## 2. Problem Statement (unchanged from v1.0)

- Kerala tourism info is fragmented; no single reliable source.
- Map apps show a place exists but not *why it matters* or how it fits an itinerary.
- Offbeat places are underrepresented.

## 3. Target Users (unchanged)

- Domestic tourists, international tourists, local Malayali explorers, trip planners.

## 4. v2.0 Goals

| Goal | How v2.0 delivers it |
|---|---|
| Spatial discovery | Interactive map + "nearby suggestions" based on device location |
| Trip planning | Expense calculator with categories, totals, per-person split |
| Modern, memorable UX | Travelexa-inspired emerald theme + motion design |
| Offline-friendly | OSM map tiles + bundled JSON data; no API key required |

## 5. v2.0 Feature Set

### 5.1 Map view with suggested spots nearby
- Interactive map (flutter_map + OpenStreetMap — no API key, offline-friendly).
- Device-location marker with permission flow (geolocator).
- Markers for places, hotels, restaurants, hidden gems.
- "Nearby suggestions" panel: items within radius (default 60 km), sorted by distance,
  with distance badges and one-tap navigation to place detail.
- Radius slider (10 / 25 / 60 / 120 km).

### 5.2 Trip expense calculator
- Add expense entries: title, category (Transport / Stay / Food / Activities / Misc),
  amount (₹), optional per-day/date.
- Live summary: total, per-category breakdown bars, per-day list, per-person split
  (editable traveler count).
- Entries persist locally (shared_preferences JSON).
- Entry point: Home screen "Trip Planner" card + bottom-nav entry.

### 5.3 Theme refresh (from reference PDF)
- Primary emerald teal `#007860`, dark green `#286850`, soft surface `#F8F8F8`,
  secondary blue `#70A8B8`/`#88C0D8`, white cards, amber ratings.
- Applied app-wide: AppBar, cards, chips, buttons, splash, bottom nav, map controls.

### 5.4 Animations
- Splash: scale+fade logo, staggered tagline, gradient background, progress shimmer.
- Page transitions: fade-and-slide-up custom route.
- Home: staggered fade-in of cards, animated search, hero transition card→detail.
- Map: pulsing user-location marker, animated marker reveal, animated bottom sheet.

## 6. User Stories (v2.0 additions)

| As a... | I want to... | So that... |
|---|---|---|
| Traveler on the road | open the map and see what's near me | I can pick a nearby spot without researching |
| Trip planner | estimate costs before traveling | I budget correctly |
| Group traveler | split costs per person | I can settle the group bill |

## 7. Out of Scope (v2.0)

- Real-time crowd data, bookings/payments, full itinerary automation.
- Server-side sync; data remains bundled/local for now.
