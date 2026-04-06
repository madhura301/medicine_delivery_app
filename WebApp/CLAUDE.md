# WebApp — React 19 + TypeScript + Vite

## Tech Stack

- React 19 with functional components and hooks
- TypeScript (strict mode)
- Vite 5 for build tooling
- MobX for state management (`makeAutoObservable`)
- MUI v7 for UI components
- Axios for HTTP requests
- React Hook Form + Yup for form validation
- React Router DOM v7 for routing
- Notistack for notifications

## Project Structure

```
src/
├── api/          # Axios API clients by feature (authApi, orderApi, etc.)
├── stores/       # MobX stores (AuthStore, OrderStore, UserManagementStore, etc.)
├── pages/        # Page components organized by role
│   ├── auth/     # Login, password reset
│   ├── admin/    # Admin dashboards & management
│   ├── chemist/  # Chemist order management
│   ├── manager/  # Manager operations
│   └── support/  # Customer support operations
├── components/   # Reusable UI components
├── layouts/      # AuthLayout, DashboardLayout
├── routes/       # RoleGuard and route access control
├── models/       # TypeScript interfaces (Dto suffix)
├── theme/        # MUI theme configuration
├── utils/        # Helpers (JWT decode, storage, validation)
├── config/       # API configuration
└── assets/       # Static assets
```

## Conventions

- Functional components only — no class components
- MobX stores with `makeAutoObservable` for reactivity
- `Dto` suffix on TypeScript interfaces matching backend DTOs
- camelCase for variables/functions, PascalCase for components/types
- No `any` types — use proper typing
- API services organized by feature in `api/` directory
- JWT token handled via Axios interceptors

## State Management (MobX)

```
RootStore
├── AuthStore         # Auth, token, user info, computed dashboardRoute
├── OrderStore        # Order list, filtering, details
├── UserManagementStore  # User CRUD
├── ChemistStore      # Chemist operations
├── RegionStore       # Service regions & pin codes
├── ConsentStore      # Consent management
└── UIStore           # Notifications, modals
```

## Routing & Auth

- Role-based routing: `/admin/*`, `/chemist/*`, `/manager/*`, `/support/*`
- `RoleGuard` component restricts access by user role
- Web app blocks Customer and DeliveryBoy roles (mobile only)
- Unauthenticated users redirect to `/login`

## Commands

```bash
npm install          # install dependencies
npm run dev          # start dev server
npm run build        # TypeScript compile + Vite production build
npm run lint         # ESLint check
npm run preview      # preview production build
```

## Environment Config

- `.env.development` / `.env.staging` / `.env.production`
- `VITE_API_BASE_URL` for backend API endpoint
