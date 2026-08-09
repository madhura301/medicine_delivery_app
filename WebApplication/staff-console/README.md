# Pharmaish Staff Console

Angular 20 back-office console for **Admin**, **Manager** and **CustomerSupport** staff.

- What it does: [../docs/FUNCTIONAL_SPEC.md](../docs/FUNCTIONAL_SPEC.md)
- What's built and what's next: [../docs/IMPLEMENTATION_PLAN.md](../docs/IMPLEMENTATION_PLAN.md)

Customers, delivery partners and chemists never sign in here — they are only *managed* from it.

## Running it

The console needs the .NET API running. Point the API at the local database and use local file
storage, otherwise every order request fails on the placeholder Azure Blob connection string:

```bash
cd ../../Backend/MedicineDelivery && ConnectionStrings__PostgresConnection="Host=localhost;Port=5432;Database=MedicineDeliveryNew;Username=postgres;Password=123;Include Error Detail=true;" FileStorage__Provider="Local" dotnet run --project MedicineDelivery.API
```

That serves on `http://localhost:5000`. Then, in this folder:

```bash
npm start
```

The app runs on `http://localhost:4200`. Local admin sign-in: mobile `9999999999`, password `Admin@123`.

## Commands

```bash
npm start
```

```bash
npm run build
```

```bash
npx ng lint
```

## Environments

| File | API base URL |
|---|---|
| `src/environments/environment.ts` | `http://localhost:5000/api` |
| `src/environments/environment.production.ts` | `http://188.241.187.172/MediMartAPI1/api` |

`ng build` swaps the file via `fileReplacements` in the production configuration.

## How the code is arranged

```
src/app/
├── core/            auth (store, guards, JWT), HTTP interceptors, models, menu + capability map
├── layout/          the app shell — responsive sidenav, topbar, user menu
├── shared/          reusable UI: data table, filter bar, page header, dialogs, state panels
└── features/        one folder per menu item; each has data/ list/ detail/ dialogs/
```

Conventions follow the skills in `../skills/`: standalone components, `OnPush`, signal inputs,
signals for state, functional guards and interceptors, lazy-loaded feature routes.

## Three things that will bite you

**The login response is almost empty.** `POST /api/Auth/login` returns `role`, `userId`,
`entityId` and `expiresAt` as `null` — the registered `AuthService` only fills in `success` and
`token`. `AuthStore` therefore decodes the JWT for role, user id and expiry, and looks up
`entityId` (the ManagerId / CustomerSupportId that the order queues need) via the `by-email`
endpoints. Don't "simplify" that back to reading the response body.

**Permissions are server-side only.** The JWT has no permission claims and there is no
"my permissions" endpoint, so `core/config/capabilities.ts` is a hand-maintained mirror of the
server's rules. It can drift — every screen must still handle a `403`.

**Route inputs are not available in a constructor.** Detail components bind `:id` via
`withComponentInputBinding()`, and that value is set *after* construction. Load data from an
`effect()` reading the input, never from the constructor.
