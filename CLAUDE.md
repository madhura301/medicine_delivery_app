# Medicine Delivery App (Pharmaish)

Multi-platform medicine delivery management system with .NET 8 backend, React 19 web app, and Flutter mobile app.

## Project Structure

```
medicine_delivery_app/
├── Backend/MedicineDelivery/     # .NET 8 Clean Architecture backend
│   ├── MedicineDelivery.API/     # REST API (controllers, middleware, auth)
│   ├── MedicineDelivery.Application/  # Use cases (CQRS, DTOs, validators)
│   ├── MedicineDelivery.Domain/  # Core entities, enums, interfaces
│   ├── MedicineDelivery.Infrastructure/  # EF Core, services, repos
│   └── MedicineDelivery.IntegrationTests/  # SpecFlow BDD tests
├── WebApp/                       # React 19 + TypeScript + Vite web app
└── Flutter_UI/                   # Flutter mobile app (BLoC pattern)
```

## User Roles

Six roles with permission-based access control:
- **Admin** — Full system access (web)
- **Chemist** — Medical store operators (web)
- **Manager** — Logistics/delivery management (web)
- **CustomerSupport** — Support staff for rejected order reassignment (web)
- **Customer** — End users (mobile only)
- **DeliveryBoy** — Delivery personnel (mobile only)

## Business Flow

1. Customer creates order (image/text/audio) with delivery address
2. Order auto-assigned to medical store based on pin code
3. Medical store accepts → uploads bill → assigns delivery boy
4. Medical store rejects → order goes to CustomerSupport → reassigned to another store
5. Delivery boy picks up → delivers → verifies with OTP from customer
6. Customer receives OTP after payment

## Quick Commands

### Backend (.NET 8)
```bash
cd Backend/MedicineDelivery
dotnet restore
dotnet build
dotnet run --project MedicineDelivery.API
dotnet test  # runs SpecFlow integration tests
```

### Database Migrations
```bash
cd Backend/MedicineDelivery
dotnet ef migrations add {Name} --project MedicineDelivery.Infrastructure --startup-project MedicineDelivery.API
dotnet ef database update --project MedicineDelivery.Infrastructure --startup-project MedicineDelivery.API
```

### WebApp (React + Vite)
```bash
cd WebApp
npm install
npm run dev      # development server
npm run build    # production build
npm run lint     # ESLint check
```

### Flutter
```bash
cd Flutter_UI
flutter pub get
flutter run
flutter build apk   # Android
flutter build ios    # iOS
```

## Architecture Rules

### Clean Architecture Dependency Flow
```
API → Application → Domain ← Infrastructure
```
- **Domain**: ZERO external dependencies. Entities, enums, interfaces only.
- **Application**: References Domain only. DTOs, CQRS handlers, validators.
- **Infrastructure**: References Domain + Application. EF Core, services, repos.
- **API**: References Application + Infrastructure (DI only). Controllers must be thin.

### Key Conventions
- Async/await everywhere — never use `.Result` or `.Wait()`
- Record types for DTOs with `Dto` suffix
- CQRS: Commands change state, Queries read-only
- Controllers are plural (`OrdersController`), entities singular (`Order`)
- Permission-based authorization, not just role-based
- Never edit EF Core migrations after creation
- Never put business logic in controllers — delegate to services/handlers

## Tech Stack Summary

| Layer | Stack |
|-------|-------|
| Backend | C# .NET 8, EF Core, PostgreSQL, MediatR, AutoMapper, FluentValidation, Serilog |
| Web | React 19, TypeScript, Vite, MobX, MUI v7, Axios, React Hook Form, Yup |
| Mobile | Flutter/Dart, BLoC, Dio, Geolocator |
| Auth | JWT Bearer tokens, ASP.NET Core Identity |
| Testing | SpecFlow (BDD), xUnit |

## Database

- **Primary**: PostgreSQL (localhost:5432, database: MedicineDeliveryNew)
- **ORM**: EF Core 8 with Fluent API configurations
- **Default users**: admin@medimart.com / Admin123!, user@medimart.com / User123!
