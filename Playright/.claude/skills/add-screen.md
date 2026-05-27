---
name: add-screen
description: Scaffold a new Flutter screen with BLoC pattern and API service
user_invocable: true
---

# Add Screen Skill

When the user invokes `/add-screen <ScreenName> <Role>`, scaffold a new Flutter screen.

## Steps

1. Ask the user for:
   - Screen name (e.g., "OrderHistory")
   - Role it belongs to (customer, delivery, admin, chemist)
   - Whether it needs a new BLoC
   - Whether it needs new API service methods

2. Create the following files:

### Screen (`Flutter_UI/lib/core/screens/{role}/`)
- `{screen_name}_page.dart` — Main screen widget with `Page` suffix
- Use StatelessWidget or StatefulWidget as appropriate

### BLoC (if needed)
- Create BLoC with events and states
- Follow flutter_bloc patterns

### Service (if needed) (`Flutter_UI/lib/core/services/`)
- API service methods using Dio
- Proper error handling

### Models (if needed) (`Flutter_UI/lib/shared/models/`)
- Dart data classes matching backend DTOs

### Route (`Flutter_UI/lib/core/app_routes.dart`)
- Add named route constant
- Register in route generator

## Rules
- PascalCase for classes, camelCase for variables/methods
- `Page` suffix for screens, `Widget` for reusable components
- Null safety — non-null by default
- BLoC pattern: events in, states out
- snake_case for file names
