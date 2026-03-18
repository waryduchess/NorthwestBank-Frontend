# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter mobile banking application (NorthwestBank) targeting Android/iOS primarily. Uses Material Design 3 with a dark blue color palette. Integrates with a backend REST API via JWT authentication.

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Analyze code (linting)
flutter analyze

# Format code
dart format lib/

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Build APK
flutter build apk

# Sync feature branches with main
./sync-main.sh
```

## Environment Setup

Requires a `.env` file in the project root (already exists, ignored by git):
```
API_URL=http://<backend-ip>:3000/api
```

The app loads this via `flutter_dotenv` in `main.dart`. Update `API_URL` to point to your local backend instance.

## Architecture

### Routing
Named routes defined in `lib/main.dart`. Initial route is `/start`. Navigation uses simple `Navigator.pushNamed` / `pushReplacementNamed` — no advanced routing library.

### State Management
No state management library. Uses `StatefulWidget` + `setState()` for local state. Persistent data (JWT tokens, user name) is stored via `SharedPreferences`.

### API Layer
`lib/services/api_service.dart` — singleton class wrapping the `http` package. Reads `API_URL` from `.env`. Handles auth endpoints (login, register). JWT token is retrieved from `SharedPreferences` and attached as a Bearer token on authenticated requests.

### Services
- `ApiService` — REST API calls (auth)
- `BiometricService` — wraps `local_auth` for fingerprint/Face ID
- `CardService` — currently uses **mock data** (real API integration is pending)

### Models
`CardModel` and `Transaction` are plain Dart classes with `fromJson`/`toJson` factory constructors.

### Theme
Centralized in `lib/theme/app_theme.dart`. Primary color `#1A237E` (dark blue), accent green `#00C853`. Uses Material 3.

## Key Notes

- `CardService` returns mock data — comments in the file indicate where API calls should be added.
- Android requires `FlutterFragmentActivity` (already configured) for biometric dialogs to work.
- The `.env` file is declared as an asset in `pubspec.yaml` and must be present at runtime.
- Feature branches are organized by feature (`feature/auth`, `feature/dashboard`, etc.) and merged to `main` via PRs.
