# SportHeroes Mobile

Flutter client for SportHeroes — email/phone + password auth (backend JWT), matches, teams, tournaments, stats, and leaderboards.

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable)
- Android Studio / Xcode (for emulators and device builds)
- A device or emulator
- Backend running when using **local** (default API: `http://localhost:3000/api`)

```sh
flutter pub get
```

Auth is **email or phone + password** against the SportHeroes API (no Firebase / Supabase Auth). See `lib/features/auth/AUTH_FLOW.md`.

---

## Environments

| Environment | Entrypoint | API base URL |
| --- | --- | --- |
| **Local** | `lib/main_local.dart` | `http://localhost:3000/api` |
| **Production** | `lib/main_production.dart` | `https://sportheroes-backend.vercel.app/api` |

Config lives in `lib/core/config/app_config.dart`.

### Local networking notes

- **Android emulator:** `localhost` on the device is the emulator itself. Point the app at the host machine with `10.0.2.2` instead of `localhost` (update `AppConfig` local `baseUrl` to `http://10.0.2.2:3000/api` if needed).
- **Physical device:** use your computer’s LAN IP, e.g. `http://192.168.1.10:3000/api`, and ensure the phone and PC are on the same network.
- **iOS simulator:** `localhost` usually works as-is.

---

## Run (debug)

### Local

```sh
flutter run -t lib/main_local.dart
```

Target a specific device:

```sh
flutter devices
flutter run -t lib/main_local.dart -d <device_id>
```

### Production

```sh
flutter run -t lib/main_production.dart
```

Target a specific device:

```sh
flutter run -t lib/main_production.dart -d <device_id>
```

Plain `flutter run` uses `lib/main.dart`, which defaults to **production**. Prefer the `-t` entrypoints above so the environment is explicit.

---

## Build

Builds use **`--split-per-abi`** so Flutter produces one APK per CPU architecture (`armeabi-v7a`, `arm64-v8a`, `x86_64`) instead of a single fat APK. That keeps each install package smaller.

Outputs are under `build/app/outputs/flutter-apk/`:

- `app-armeabi-v7a-release.apk`
- `app-arm64-v8a-release.apk`
- `app-x86_64-release.apk`

Most modern phones need **`arm64-v8a`**. Use `armeabi-v7a` for older 32-bit devices and `x86_64` mainly for emulators.

### Android APK — local

```sh
flutter build apk -t lib/main_local.dart --release --split-per-abi
```

### Android APK — production

```sh
flutter build apk -t lib/main_production.dart --release --split-per-abi
```

### Android App Bundle (Play Store) — production

Play Store prefers an AAB (Google splits by ABI for you):

```sh
flutter build appbundle -t lib/main_production.dart --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS — production

```sh
flutter build ipa -t lib/main_production.dart --release
```

### iOS — local (device / simulator testing)

```sh
flutter build ios -t lib/main_local.dart --release
```

---

## Quick reference

| Goal | Command |
| --- | --- |
| Run local | `flutter run -t lib/main_local.dart` |
| Run production | `flutter run -t lib/main_production.dart` |
| Build APK local (split ABI) | `flutter build apk -t lib/main_local.dart --release --split-per-abi` |
| Build APK production (split ABI) | `flutter build apk -t lib/main_production.dart --release --split-per-abi` |
| Build AAB production | `flutter build appbundle -t lib/main_production.dart --release` |

---

## Project layout (high level)

```
lib/
  main.dart                 # Shared bootstrap
  main_local.dart           # Local entrypoint
  main_production.dart      # Production entrypoint
  core/                     # Config, network, providers, mock data
  features/
    auth/                   # Email/phone + password login
    home/, matches/, teams/, tournaments/, leaderboard/, profile/
  routes/
```

Auth flow details: `lib/features/auth/AUTH_FLOW.md`  
Product overview: `docs/ProjectOverview.md`
