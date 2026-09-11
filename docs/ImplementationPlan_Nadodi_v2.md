# ImplementationPlan — Nadodi v2.0

Build order for the v2.0 upgrade. Each step is verifiable.

## Phase 1 — Foundations
1. [x] Environment: Flutter 3.44.8 (aarch64), Android SDK 36, build-tools 36.
2. [x] pubspec: add `flutter_map`, `latlong2`, `shared_preferences`; bump version
   to `2.0.0+2`.
3. [x] `flutter pub get` → verify resolves.
4. [x] `lib/theme/app_theme.dart`: palette + ThemeData (DesignBrief tokens).
5. [x] `lib/widgets/page_route.dart`: fade+slide route helper; wire into routes.dart.
6. [x] AndroidManifest: add INTERNET (already), ACCESS_FINE/COARSE_LOCATION.
7. [x] Android: generate release keystore, signing config.

## Phase 2 — Theme + Animations
8. [x] app.dart: apply AppTheme; keep providers; route transitions.
9. [x] splash_screen.dart: gradient bg + staggered animations (scale, fade, shimmer).
10. [x] home_screen.dart: themed appbar/cards, staggered list animation,
    Trip Planner entry card, hero on PlaceCard.
11. [x] place_card.dart / category_chip.dart / rating_widget.dart: themed tokens.
12. [x] place_detail_screen.dart / hidden / saved / profile: themed + transitions.

## Phase 3 — Data & Geo
13. [x] Enrich assets/data/*.json with real Kerala coordinates.
14. [x] `lib/services/geo_service.dart`: haversine + nearby(radiusKm) + category icon/color helpers.
15. [x] models: keep; add `ExpenseItem` model + category helpers.

## Phase 4 — Map view (nearby suggestions)
16. [x] `lib/screens/map_screen.dart`: flutter_map (OSM), user location via
    LocationService, pulsing user marker, category-colored markers, radius slider,
    "Nearby suggestions" bottom sheet with distances.
17. [x] routes.dart: real `/map` → MapScreen.
18. [x] home bottom nav: Map tab navigates to MapScreen.

## Phase 5 — Trip expense calculator
19. [x] `lib/providers/expense_provider.dart`: state + shared_preferences persistence.
20. [x] `lib/screens/expense_screen.dart`: summary header (total, per-person),
    category breakdown bars, per-day list, add/edit/delete via bottom sheet,
    traveler count stepper.
21. [x] routes.dart: `/expenses`; home Trip Planner card → ExpenseScreen.

## Phase 6 — Verify & Ship
22. [x] `flutter analyze` clean.
23. [x] `flutter test` (existing widget test updated to new theme).
24. [x] `flutter build apk --release` → signed `nadodi_v2.0.0.apk`.
25. [x] aapt badging check + install on device.

## Verification commands
- Analyze: `flutter analyze`
- Test: `flutter test`
- Build: `flutter build apk --release`
- Inspect: `aapt dump badging build/app/outputs/flutter-apk/app-release.apk`

## Build environment notes (arm64 Linux host, 2026-07-31)
The release APK was built on Ubuntu aarch64. Google ships no linux-aarch64
Android NDK or android engine host artifacts, so the following workarounds are
in place for this host only (they do not affect the APK itself):
- `android/gradle.properties` sets `android.aapt2FromMavenOverride=/opt/aapt2/aapt2`
  (qemu-wrapped x86_64 aapt2 with amd64 libc installed).
- `pubspec.yaml` pins `path_provider_android: 2.2.14` via `dependency_overrides`
  to avoid the `jni` package's native CMake/NDK build.
- Flutter SDK Gradle plugin patched: `forceNdkDownload` in
  `flutter_tools/gradle/src/main/kotlin/FlutterPluginUtils.kt` is a no-op
  (no plugin compiles native code at build time).
- Android engine artifacts: `android-*-release/linux-arm64/gen_snapshot` wrapper
  scripts run the x86_64 binaries via `qemu-x86_64`.
- NDK `llvm-strip` wrapper points at native arm64 `llvm-strip`
  (`/data/data/com.termux/files/usr/bin/llvm-strip`) so AGP can strip engine
  symbols (this is what keeps the APK at ~53MB universal / ~19MB arm64).

Deliverables (2026-07-31):
- `build/app/outputs/flutter-apk/app-release.apk` → `nadodi_v2.0.0-universal.apk` (53.5MB, all ABIs)
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` → `nadodi_v2.0.0.apk` (19.0MB, arm64)
- Both signed with `keys/nadodi-release.keystore`, package `com.example.nadodi`,
  versionName `2.0.0`, versionCode `2` (split APKs use ABI-encoded codes).
