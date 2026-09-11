# TRD — Nadodi v2.0

Derived from PRD_Nadodi_v2.md. Tech stack locked before implementation.

## 1. Stack

| Layer | v1.0 | v2.0 | Notes |
|---|---|---|---|
| Framework | Flutter 3.0+ | Flutter 3.44 (build), Dart 3.12 | SDK pinned for reproducible build |
| State mgmt | Provider 6.1.2 | Provider 6.1.2 | Keep |
| Maps | google_maps_flutter (stub, no key) | **flutter_map** + **latlong2** (OSM tiles) | No API key; works offline w/ tile cache |
| Location | geolocator 9 / permission_handler 11 | geolocator 9 / permission_handler 11 | Keep |
| Persistence | none | **shared_preferences** | Trip expenses + saved trip |
| Data | assets/data/*.json | same + coordinates added | Enriched with lat/lng |
| Theme | ColorScheme.fromSeed(green) | Custom `AppTheme` w/ Travelexa palette | From reference PDF |
| Currency | — | `intl` NumberFormat (₹, Indian locale) | intl already in deps |

## 2. Architecture

```
lib/
├── main.dart
├── app.dart                     # theme + providers + routes
├── theme/
│   └── app_theme.dart           # NEW: palette + ThemeData (PDF reference)
├── models/
│   ├── place_model.dart         # + copyWith coords already present
│   ├── hotel_model.dart
│   ├── restaurant_model.dart
│   ├── hidden_spot_model.dart
│   └── expense_item.dart        # NEW: trip expense model
├── providers/
│   ├── places_provider.dart
│   ├── hotels_provider.dart
│   ├── hidden_spots_provider.dart
│   └── expense_provider.dart    # NEW: trip expense state + persistence
├── services/
│   ├── dataset_service.dart
│   ├── location_service.dart
│   └── geo_service.dart         # NEW: haversine distance + nearby filter
├── screens/
│   ├── splash_screen.dart       # NEW animations
│   ├── home_screen.dart         # NEW hero/stagger + Trip Planner entry
│   ├── place_detail_screen.dart # themed + animated
│   ├── map_screen.dart          # NEW: flutter_map + nearby panel
│   ├── expense_screen.dart      # NEW: trip expense calculator
│   ├── hidden_places_screen.dart
│   ├── saved_places_screen.dart
│   └── profile_screen.dart
├── widgets/
│   ├── place_card.dart          # themed + animated
│   ├── category_chip.dart
│   ├── rating_widget.dart
│   └── page_route.dart          # NEW: fade+slide transition helper
└── routes.dart                  # + /map real, + /expenses
```

## 3. Key Decisions

1. **flutter_map over google_maps_flutter**: v1.0 declared google_maps_flutter but the
   map was a stub and no API key exists in the project. flutter_map + OpenStreetMap
   delivers a real interactive map with zero key/config, fitting the offline and
   solo-dev constraints. (OpenStreetMap tile usage policy: light read-only usage,
   acceptable for a demo app.)
2. **Coordinates added to bundled JSON**: The CSV datasets on-device have no usable
   coordinates and synthetic labels; the curated 8-place dataset gets real Kerala
   coordinates, giving the map meaningful markers immediately.
3. **shared_preferences for expense persistence**: no backend in v2.0; local JSON store.
4. **Custom route transitions**: a single `PageRouteBuilder` helper (fade + slight
   slide-up + ease curve) applied in `routes.dart`.

## 4. Non-Functional

- minSdk 24, targetSdk 36, compileSdk 36 (matches Flutter 3.44 default).
- App ID stays `com.example.nadodi` so the new build can install as an update.
- Version bumped to `2.0.0+2`.
- Build: `flutter build apk --release`, signed with a generated release keystore.
