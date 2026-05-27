---
name: add-page
description: Scaffold a new page in the React WebApp with MobX store and API integration
user_invocable: true
---

# Add Page Skill

When the user invokes `/add-page <PageName> <Role>`, scaffold a new page in the WebApp.

## Steps

1. Ask the user for:
   - Page name (e.g., "PaymentHistory")
   - Role it belongs to (admin, chemist, manager, support)
   - Whether it needs a new MobX store
   - Whether it needs new API endpoints

2. Create the following files:

### Page Component (`WebApp/src/pages/{role}/`)
- `{PageName}Page.tsx` — Main page component using MUI components
- Use functional component with hooks
- Integrate with MobX store via `observer` wrapper

### API Client (if needed) (`WebApp/src/api/`)
- `{feature}Api.ts` — Axios API client with typed requests/responses

### MobX Store (if needed) (`WebApp/src/stores/`)
- `{Feature}Store.ts` — MobX store with `makeAutoObservable`
- Register in `RootStore`

### Models (`WebApp/src/models/`)
- TypeScript interfaces with `Dto` suffix matching backend DTOs

### Routing (`WebApp/src/App.tsx`)
- Add route under the appropriate role's route group
- Ensure RoleGuard protects the route

## Rules
- Functional components only, no class components
- TypeScript strict — no `any` types
- camelCase variables, PascalCase components/types
- Use MUI components for consistent UI
- React Hook Form + Yup for any forms
- Axios for API calls with proper error handling
