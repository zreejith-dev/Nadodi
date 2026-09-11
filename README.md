# Nadodi - Kerala Tourism Explorer

A modern Flutter app for discovering tourist places, hotels, restaurants, and hidden gems across Kerala. Built with Supabase backend, offline-first architecture, and Google Play 2027 compliance.

## Features

- 🗺️ **Explore 1050+ tourist places** across all Kerala districts
- 🏨 **600+ hotels & homestays** with pricing and ratings
- 🍽️ **700+ restaurants** by cuisine type
- 💎 **150+ hidden spots** with difficulty ratings
- 🔐 **Zero-Tap Sign-In** with Google/Apple (Supabase Auth)
- 💾 **Offline-first** with local JSON + cloud sync
- 📍 **Map view** with nearby places (OpenStreetMap)
- ⭐ **Bookmarks & Trip planning** synced across devices
- 🌙 **Light/Dark theme** with Material 3

## Tech Stack

- **Framework**: Flutter 3.19+
- **Language**: Dart 3.3+
- **State Management**: Provider
- **Backend**: Supabase (PostgreSQL + Auth + Realtime)
- **Maps**: flutter_map (OpenStreetMap, no API key needed)
- **Images**: cached_network_image (memory optimized)
- **Location**: geolocator + permission_handler

## Project Structure

```
lib/
├── app.dart                 # App entry with providers
├── main.dart               # Supabase initialization
├── core/
│   ├── config/
│   │   └── supabase_config.dart
│   └── services/
│       └── supabase_service.dart
├── features/
│   ├── auth/
│   │   └── auth_provider.dart      # Zero-tap auth
│   ├── places/
│   │   └── places_provider.dart
│   ├── hidden/
│   │   └── hidden_provider.dart
│   └── profile/
├── screens/
│   ├── splash_screen.dart
│   ├── auth_screen.dart
│   ├── home_screen.dart
│   ├── place_detail_screen.dart
│   ├── hidden_places_screen.dart
│   ├── saved_places_screen.dart
│   ├── profile_screen.dart
│   └── map_screen.dart
├── shared/
│   ├── models/
│   │   └── place.dart
│   ├── services/
│   │   └── data_service.dart      # Local + cloud sync
│   └── widgets/
│       ├── cards.dart
│       └── optimized_image.dart
└── theme/
    └── app_theme.dart
```

## Getting Started

### Prerequisites

- Flutter SDK 3.19+
- Dart 3.3+
- Android Studio / Xcode
- Java 17+ (for Android builds)

### Installation

```bash
# Clone and navigate
cd Nadodi-rebuild/Nadodi-main

# Install dependencies
flutter pub get

# Run on device/emulator
flutter run
```

### Building APK

```bash
# Debug APK
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk

# Release APK (requires signing config)
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# App Bundle for Play Store (recommended)
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

## Google Play 2027 Compliance

This app is built to meet Google Play's 2027 Core Quality Standards:

### Memory Optimization (Feb 2027)
- ✅ R8 code shrinking + resource shrinking enabled
- ✅ App Bundle with dynamic delivery (ABI, density, language splits)
- ✅ Optimized image loading with downsampling (`cached_network_image`)
- ✅ Lifecycle-aware memory cache eviction
- ✅ No memory leaks (no long-lived Context/Activity references)
- ✅ Lazy pagination for all lists

### Zero-Tap Sign-In (Apr 2027)
- ✅ Supabase Auth with Google/Apple OAuth
- ✅ PKCE flow for security
- ✅ Auto session restore on cold start
- ✅ Credential Manager ready (AndroidX dependencies added)

## Supabase Setup

The app uses an existing Supabase project: **Nadodi** (`nmhuylseiqaziyeymbkl`)

### Database Schema
Run the migration in Supabase SQL Editor:
```sql
-- See supabase_schema.sql for full schema
-- Tables: places, hotels, restaurants, hidden_spots
--         user_bookmarks, user_trips, reviews
-- RLS policies + PostGIS nearby functions
```

### Data Import
Import CSV data to Supabase:
```bash
# 1050 places, 600 hotels, 700 restaurants, 150 hidden spots
# Use Supabase Dashboard > Table Editor > Import CSV
# Or run the generated SQL batch files
```

### Auth Configuration
In Supabase Dashboard > Authentication:
1. Enable Google provider (add OAuth credentials)
2. Enable Apple provider (add Service ID)
3. Add redirect URL: `io.supabase.nadodi://login-callback`

## Configuration

### Update Supabase Config
Edit `lib/core/config/supabase_config.dart`:
```dart
static const String url = 'https://your-project.supabase.co';
static const String anonKey = 'your-anon-key';
```

### Android Signing (Release)
Create `android/key.properties`:
```properties
storeFile=../nadodi-release.keystore
storePassword=your_password
keyAlias=nadodi
keyPassword=your_password
```

Generate keystore:
```bash
keytool -genkey -v -keystore nadodi-release.keystore \
  -alias nadodi -keyalg RSA -keysize 2048 -validity 10000
```

## Data Files

JSON assets in `assets/data/`:
- `places.json` - 1050 tourist places
- `hotels.json` - 600 hotels & homestays
- `restaurants.json` - 700 restaurants
- `hidden_spots.json` - 150 hidden gems

## Architecture Highlights

### Offline-First Data Flow
```
App Start
    │
    ▼
Load local JSON (instant) ──▶ Show UI immediately
    │
    ▼
If authenticated ──▶ Sync with Supabase
    │                    (bookmarks, trips, reviews)
    ▼
Update local cache with cloud data
```

### Memory Optimization
- `OptimizedImage` widget: automatic downsampling to display size
- `memCacheWidth/Height` set on all network images
- `ListView.builder` for all lists (lazy rendering)
- Provider state management (no unnecessary rebuilds)

### Zero-Tap Auth Flow
```
App Launch
    │
    ▼
Supabase.restoreSession() (silent)
    │
    ├─ Success ──▶ User authenticated ──▶ Home
    │
    └─ No session ──▶ AuthScreen (Google/Apple buttons)
                          │
                          ▼
                     OAuth → Deep link → Home
```

## Building for Production

```bash
# 1. Verify everything works
flutter analyze
flutter test

# 2. Build App Bundle (Play Store)
flutter build appbundle --release

# 3. Upload to Play Console
# 4. Configure App Signing by Google Play
# 5. Roll out to internal testing
```

## License

MIT License - Built with ❤️ for Kerala Tourism