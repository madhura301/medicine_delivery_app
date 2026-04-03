# Flutter UI — Mobile App

## Tech Stack

- Flutter SDK >=3.0.0 <4.0.0
- Dart with null safety
- BLoC pattern for state management (flutter_bloc 8.1.3)
- Dio for HTTP requests
- Geolocator + Geocoding for location
- Flutter Secure Storage + SharedPreferences for persistence
- Image Picker, Camera, File Picker for media
- Flutter Sound for audio
- Permission Handler for runtime permissions

## Project Structure

```
lib/
├── main.dart              # Entry point (staging env by default)
├── config/                # Environment config (dev, staging, prod)
├── core/
│   ├── app_routes.dart    # Named route definitions
│   ├── screens/           # Feature screens by role
│   │   ├── auth/          # Login, registration
│   │   ├── admin/         # Admin screens
│   │   ├── chemist/       # Chemist screens
│   │   └── ...
│   ├── dashboards/        # Role-based dashboard screens
│   ├── services/          # API services, business logic
│   └── theme/             # Material theme & styling
├── shared/
│   ├── models/            # Shared DTOs/data classes
│   └── widgets/           # Reusable UI components
└── utils/                 # Logging, helpers
```

## Conventions

- PascalCase for classes/enums, camelCase for variables/methods
- `Page` suffix for screen widgets, `Widget` for reusable components
- BLoC pattern for state management — events in, states out
- Services layer handles API calls
- Non-null by default, use `?` for nullable types
- Named routes for navigation

## Environments

Configured in `lib/config/environment_config.dart`:
- Development, Staging, Production
- Each has its own API URL, timeout, and logging settings

## Roles (Mobile)

- **Customer** — order creation, tracking, OTP verification, payment
- **DeliveryBoy** — order pickup, delivery, OTP collection

## Commands

```bash
flutter pub get              # install dependencies
flutter run                  # run in development
flutter build apk            # Android build
flutter build ios            # iOS build
flutter build web            # Web build
flutter test                 # run tests
```
