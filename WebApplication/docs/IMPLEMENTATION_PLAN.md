# Pharmaish Staff Console — Implementation Plan & Progress Tracker

**Companion to:** [FUNCTIONAL_SPEC.md](FUNCTIONAL_SPEC.md)
**Location:** `WebApplication/`
**Last updated:** 2026-08-02

> **This is the working document across sessions.** Update the checkboxes and the session log at the end of every session. Nothing else needs to be remembered between sessions.

---

## 0. How to resume in a new session

1. Read [FUNCTIONAL_SPEC.md](FUNCTIONAL_SPEC.md) §2 (menus) and the section for the feature you're building.
2. Open this file, find the **first unchecked phase** in §5, and read its task list and acceptance criteria.
3. Check `WebApplication/README.md` for how to run the app and the API.
4. Build only that phase. Do not start the next one until its acceptance criteria pass.
5. Before finishing: tick the boxes, add a row to the **Session log** (§8), and note anything unresolved in **Open items** (§9).

---

## 1. Technical decisions

| Decision | Choice | Rationale |
|---|---|---|
| Framework | **Angular v20+**, standalone components (no NgModules) | Matches the skills in `WebApplication/skills/` |
| Change detection | `OnPush` everywhere | Skill guidance; predictable performance |
| State | **Signals**; `httpResource()` for reads, `HttpClient` for writes | Per `angular-http` and `angular-signals` skills |
| Forms | Reactive forms with typed `FormGroup` | Per `angular-forms` skill |
| Routing | `provideRouter` with **lazy-loaded** feature routes, functional guards | Per `angular-routing` skill |
| UI library | **Angular Material v20** + CDK (assumption — confirm) | Responsive admin shell, a11y, data table, dialogs |
| Styling | SCSS, one theme file, CSS custom properties for tokens | |
| HTTP | Functional interceptors: auth token, error normaliser, loading indicator | Per `angular-http` skill |
| Testing | Vitest + Angular Testing Library for units; Playwright smoke tests later | Per `angular-testing` skill |
| SSR | **No** | Internal back-office behind a login |
| API config | `environment.ts` / `environment.production.ts` | dev `http://localhost:5000/api`, prod `http://188.241.187.172/MediMartAPI1/api` |

---

## 2. Project structure

```
WebApplication/
├── docs/
│   ├── FUNCTIONAL_SPEC.md
│   └── IMPLEMENTATION_PLAN.md          ← this file
├── skills/                              (already present)
└── staff-console/                       ← the Angular app
    ├── src/
    │   ├── app/
    │   │   ├── app.config.ts
    │   │   ├── app.routes.ts
    │   │   ├── app.ts
    │   │   ├── core/
    │   │   │   ├── auth/                auth.service, auth.store, guards, login
    │   │   │   ├── http/                interceptors, api-error model
    │   │   │   ├── models/              generated-by-hand DTO interfaces + enums
    │   │   │   └── config/              menu definition, role→capability map
    │   │   ├── layout/                  shell, sidebar, topbar, breadcrumbs
    │   │   ├── shared/
    │   │   │   ├── ui/                  data-table, page-header, status-chip,
    │   │   │   │                        confirm-dialog, empty-state, error-state,
    │   │   │   │                        search-field, filter-bar, responsive-list
    │   │   │   └── util/                validators, formatters, download helper
    │   │   └── features/
    │   │       ├── dashboard/
    │   │       ├── managers/
    │   │       ├── customer-support/
    │   │       ├── delivery-boys/
    │   │       ├── chemists/
    │   │       ├── customers/
    │   │       ├── regions/             shared component, two routed variants
    │   │       └── orders/              shared list + detail, six routed variants
    │   ├── environments/
    │   └── styles.scss
    └── README.md
```

**Feature folder convention** (every feature looks the same):
```
<feature>/
├── <feature>.routes.ts
├── data/          <feature>-api.service.ts, <feature>.models.ts
├── list/          <feature>-list.ts + .html + .scss
├── detail/        <feature>-detail.ts
└── dialogs/       <feature>-form-dialog.ts, assign-region-dialog.ts, ...
```

---

## 3. Build order rationale

Phases are ordered so each one is independently demonstrable and nothing is built twice:

1. **Backend prerequisite first** — the Orders module is dead without it.
2. **Core shell second** — auth, layout, guards, and the shared list/form/dialog components. Every later phase is then mostly configuration.
3. **Managers third** — the simplest CRUD; it proves the shared components. Later CRUD phases reuse it wholesale.
4. **Regions before assignment-heavy screens** — support/delivery region dropdowns depend on regions existing.
5. **Orders last** — the most complex, and it depends on the chemist and delivery-boy lists for name resolution.

---

## 4. Definition of done (applies to every phase)

- [ ] Works against the real API at `http://localhost:5000/api`
- [ ] Loading, empty, error and 403 states all handled
- [ ] Responsive: verified at 375 px, 768 px and 1440 px — no horizontal scroll
- [ ] Keyboard reachable; dialogs trap focus; form fields have labels
- [ ] `ng build` clean, `ng lint` clean, no `any` in new code
- [ ] Menu item hidden for roles that cannot use it
- [ ] Checkboxes ticked in §5 and a row added to the session log §8

---

## 5. Phases

Status key: ☐ not started · ◐ in progress · ☑ done

---

### ☑ Phase 0 — Backend prerequisite: expose order ownership — **DONE 2026-08-02**

**Why:** `Order.AssignTo` and `Order.DeliveryId` exist on the entity but were not in `OrderDto`, so the client could not tell the five order buckets apart.

- [x] Add `AssignTo AssignTo` and `int? DeliveryId` to `MedicineDelivery.Application/DTOs/OrderDto.cs`
- [x] AutoMapper profile is convention-based — both map automatically, no profile change needed
- [x] Add `MedicalStoreName`, `CustomerSupportName`, `ManagerName`, `DeliveryBoyName`
- [x] Add `EnrichAssigneeNamesAsync` to `OrderService` — one batched lookup per party, no N+1
- [x] Wire enrichment into the six staff-facing reads: `GetAllOrdersAsync`, `GetOrderByIdAsync`,
      `AssignedToCustomerSupportByCustomerSupportIdAsync`, `GetAllOrdersByCustomerSupportIdAsync`,
      `AssignedToManagerByManagerIdAsync`, `GetAllOrdersByManagerIdAsync`
- [x] `dotnet build` clean (0 warnings, 0 errors); `dotnet test` 20/20 pass
- [x] Verified live against the local DB (104 orders): `GET /api/Orders`, `GET /api/Orders/{id}`,
      `GET /api/Orders/manager/{id}/assignedtomanager` all return the new fields
- [x] Additive only — no existing consumer breaks

**Files changed:**
- `MedicineDelivery.Application/DTOs/OrderDto.cs`
- `MedicineDelivery.Infrastructure/Services/OrderService.cs`

**Verified output** (local `MedicineDeliveryNew`, 104 orders):
`assignTo` → `{0: 16, 1: 72, 3: 5, 4: 11}`; `customerName` 104/104, `medicalStoreName` 102,
`deliveryBoyName` 17, `customerSupportName` 12, `managerName` 11.

**Two behaviours the Angular client must rely on:**
1. **`AssignTo` is NULL for some legacy rows** (3 of 104 locally). EF materialises NULL as `0`
   (`Customer`), which lands them in **Awaiting Assignment** — the correct bucket. No crash, no
   special handling needed client-side.
2. **The assignee ids persist after hand-off.** 17 orders carry a `deliveryId` but only 5 are in
   the `Delivery` bucket; likewise 12 carry a `customerSupportId` but none are currently with
   support. **Always bucket by `assignTo`, never by "which id is non-null".** The stale ids and
   names are still useful on the detail page as history.

---

### ☑ Phase 1 — Scaffold, shell, auth and shared UI — **DONE 2026-08-02**

**1a. Project setup**
- [x] Scaffolded `WebApplication/staff-console` — Angular **20.3**, standalone, SCSS, no SSR
- [x] Angular Material **20.2** (azure-blue theme) + CDK; `@angular/animations` added for `provideAnimationsAsync()`
- [x] `environments/` with dev and prod API URLs + `fileReplacements` in the production build
- [x] ESLint via `@angular-eslint/schematics`; `npx ng lint` passes clean
- [x] `staff-console/README.md` — how to run it, layout of the code, three gotchas
- [x] `.claude/launch.json` entry `staff-console` on port 4200

**1b. Models**
- [x] `core/models/api.models.ts` — Auth, Manager, CustomerSupport, DeliveryBoy, MedicalStore, Customer, ServiceRegion, Order
- [x] `core/models/enums.ts` — numeric enums mirroring the backend plus label maps

**1c. Auth**

> **Verified 2026-08-02 — the login response body is mostly empty.** `POST /api/Auth/login` returns
> `role`, `userId`, `entityId` and `expiresAt` as **null**. Cause: `Program.cs:570` binds
> `Domain.Interfaces.IAuthService` to `MedicineDelivery.API.Services.AuthService`, whose `LoginAsync`
> sets only `Success` and `Token`. (The Infrastructure `AuthService` *does* populate all of them but
> is not the registered implementation — it appears to be dead code.)
>
> **Consequence for the console:**
> - `role`, `userId` and expiry must be read by **decoding the JWT**, not from the response body.
>   Verified claims present: `.../claims/role` = `Admin`, `.../nameidentifier` = user id,
>   `.../name` = mobile, `.../emailaddress`, `firstName`, `lastName`, `exp`.
> - **`entityId` is not in the JWT at all.** Manager and CustomerSupport queue screens need it, so
>   after login resolve it from the email claim via `GET /api/Managers/by-email/{email}` or
>   `GET /api/CustomerSupports/by-email/{email}` and cache it in the auth store.
> - Alternative worth raising with the owner: fix the API-layer `AuthService` to populate the
>   response properly (small change, benefits the React app too). Tracked in §9.

- [x] `AuthApiService` — login, forgot-password, verify-otp-reset, change-password, by-email lookups
- [x] `core/auth/jwt.util.ts` — decodes claims; the response body is not trusted
- [x] `AuthStore` (signals) — token, claims, **entityId**; localStorage vs sessionStorage per *Keep me signed in*
- [x] Post-login `entityId` resolution for Manager and CustomerSupport via the by-email endpoints
- [x] Login, forgot-password, reset-password, change-password pages
- [x] Non-staff roles rejected at login ("This portal is for staff only…")
- [x] `authGuard`, `guestGuard`, `roleGuard(...roles)`
- [x] `authInterceptor` (bearer) and `errorInterceptor` (401 → logout, 403 → toast, 5xx → toast)

**1d. Layout**
- [x] Shell with responsive sidenav — `over` below 768px, docked at/above it; topbar with user menu
- [x] Menu from a single `MENU` definition in `core/config/menu.ts`, filtered by role
- [x] Lazy-loaded feature routes
- ~~rail mode at 768–1023px~~ — not implemented; the drawer is docked or off-canvas only (noted §9)
- ~~breadcrumbs~~ — the topbar shows the active section instead

**1e. Shared UI components**
- [x] `<app-page-header>` — title, subtitle, primary action, `[headerActions]` slot
- [x] `<app-data-table>` — generic, signal inputs, sort, client paging, action menu, **card layout below 768px**, keyboard-activatable rows
- [x] `<app-filter-bar>` — search + filter slot, collapses behind a toggle on mobile
- [x] `<app-status-chip>`, `<app-empty-state>`, `<app-error-state>`, `<app-loading-state>`
- [x] `ConfirmService` / `ConfirmDialog` with danger and type-to-confirm variants
- [x] `ToastService`
- [x] `CredentialsNoticeService` — shows the temporary password once, after a staff account is created
- [x] `shared/ui/breakpoints.ts` — one place for the 768px threshold
- [x] Validators: 10-digit mobile, 6-digit pin code, email, `firstErrorMessage()`
- [ ] File download helper — deferred to Phase 9, where the first download appears

**Acceptance — verified 2026-08-02:** signed in as Admin against the live API; correct menu rendered;
dashboard, all four feature lists and all three detail pages load real data; cards render at 375px
with no horizontal overflow; no console errors; `ng lint` and `ng build` clean.

---

### ☑ Phase 2 — Managers — **DONE 2026-08-02**

- [x] `ManagersApiService` — list, get, create, update, delete, upload photo
- [x] List with search + status filter
- [x] Create dialog + temporary-password notice
- [x] Edit dialog with Active toggle
- [x] Detail view (contact + record blocks) with photo upload
- [x] Delete with confirmation, from both list and detail
- [x] Route restricted to Admin/Manager; write actions gated on the `manageManagers` capability, so a Manager sees the roster read-only
- [x] Duplicate mobile / email errors mapped onto the offending field

**Verified:** list renders the 2 non-deleted managers from the live API (25 soft-deleted ones correctly excluded); detail page loads.

---

### ☑ Phase 3 — Customer Support — **DONE 2026-08-02**

- [x] `CustomerSupportApiService`
- [x] `RegionsApiService` built early (Phase 7's data layer) — CRUD, pin codes, all four assign endpoints
- [x] List with region column + region filter including "Unassigned"
- [x] Create / edit / delete / photo, mirroring Phase 2
- [x] Region picker in the create/edit form **and** a standalone **Assign region** dialog with a Clear option
- [x] Shared `AssignRegionDialog` serving both agents and delivery partners
- [x] Rejected-order routing hint on the form, the dialog and the detail page

**Verified:** list resolves region names from the live API (Pune West / Pune East / Unassigned); detail page shows the assigned region with its pin codes.

---

### ☑ Phase 4 — Delivery Boys — **DONE 2026-08-02**

- [x] `DeliveryBoysApiService`
- [x] List with region + medical-store columns, status and region filters
- [x] Create (name, mobile, licence, store, region) + temporary-password notice explaining the mobile login
- [x] Edit with Active toggle; delete with confirmation
- [x] **Assign region** dialog restricted to delivery regions
- [x] Form states that only the region drives order eligibility; the store link is record-keeping
- [x] Menu and route hidden from CustomerSupport (spec §13.3)
- [x] Duplicate-mobile error mapped onto the mobile field

**Verified end to end:** assigned "E2E Delivery 411001" to a partner through the dialog — the
dropdown listed only the one delivery-type region (the type filter works), the POST persisted, and
the list refreshed. The test assignment was then reverted in the local database.

---

### ☑ Phase 5 — Chemists — **DONE 2026-08-02**

- [x] `ChemistsApiService` (`/api/MedicalStores` + `/api/chemist-payout`)
- [x] List with search, status and city filters; registration + active chips
- [x] Detail view: store, address, statutory, pharmacist, payouts/activation, record
- [x] Edit form grouped into Store / Address / Statutory / Pharmacist
- [x] **Activate / Deactivate** from both list and detail, warning that it stops new assignments
- [x] Soft delete; Admin-only hard delete behind a type-the-store-name confirmation
- [x] Payout/activation 404s degrade to "Not onboarded" / "Not started" rather than failing the page

**Verified:** list renders the 9 live chemists; detail page renders every section, including the
payout fallback for a store that never onboarded.

> Note: the list's payout/activation column from the spec was dropped — showing it per row would
> mean one extra request per chemist. It appears on the detail page instead.

---

### ☑ Phase 6 — Customers — **DONE 2026-08-02**

- [x] `CustomersApiService` + `CustomerAddressesApiService`
- [x] List with search and status filter
- [x] Detail: profile + address list with default flag
- [x] Create / edit / delete customer
- [x] Address add / edit / delete / set-default in-line on the detail page
- [x] Link through to that customer's orders (once Phase 9 exists)

**Acceptance:** addresses can be managed without leaving the customer page; the default address is unambiguous.

---

### ☑ Phase 7 — Regions (both types) — **DONE 2026-08-02**

- [x] `ServiceRegionsApiService` — CRUD, pin-code add/remove, by-pincode lookup, all four assign endpoints
- [x] One `RegionListComponent` + `RegionFormDialog` parameterised by `RegionType`, routed twice (`/regions/support`, `/regions/delivery`)
- [x] Pin-code chip input with 6-digit validation and duplicate rejection
- [x] Region detail with pin-code add/remove
- [x] **Pin-code lookup** box with the "no region covers this pin code" warning
- [x] **Manage Assignments** two-pane workbench (assigned / unassigned, multi-select, bulk assign, remove) for both types
- [x] Delete pre-check that blocks deletion while staff are attached (spec §10.4)

**Acceptance:** a region can be created with pin codes, agents bulk-assigned and removed, and deletion is refused while agents remain.

---

### ☑ Phase 8 — Orders: list infrastructure and All Orders — **DONE 2026-08-02**

**Depends on Phase 0.**

- [x] `OrdersApiService` — all orders, by customer support, by manager, detail, reassign, cancel, downloads, candidate chemists
- [x] `OrderBucket` derivation from `assignTo`, with labels and chip colours
- [x] Name-resolution service: caches chemists / agents / managers / delivery boys and resolves the "Current owner" column (drop this if Phase 0's recommended name fields land)
- [x] Shared `OrderListComponent` with a `bucket` input; filters for status, payment status and date range
- [x] **All Orders** route with a bucket column and bucket filter
- [x] CustomerSupport reads from `/api/Orders/customersupport/{entityId}` instead of the all-orders endpoint

**Acceptance:** All Orders lists every order with the correct bucket; filters and search work; the list is usable on mobile.

---

### ☑ Phase 9 — Orders: detail page — **DONE 2026-08-02**

- [x] Detail layout with all eight sections (spec §11.3)
- [x] Authenticated download of the input file and the bill
- [x] Payment + Razorpay split section
- [x] Assignment-history timeline
- [x] Cancellation-reason banner when cancelled
- [x] Status legend / lifecycle reference

**Acceptance:** every field in spec §11.3 is visible for a paid, delivered order and for a cancelled one; downloads work.

---

### ☑ Phase 10 — Orders: the five buckets and their actions — **DONE 2026-08-02**

- [x] Routes: `/orders/awaiting-assignment`, `/with-chemist`, `/with-support`, `/with-manager`, `/with-delivery`
- [x] **Reassign to another chemist** dialog — pin code candidates, "widen to city", nearest-chemist fallback → `PUT /api/Orders/{id}/reassign`
- [x] **Cancel with reason** dialog → `PUT /api/Orders/{id}/cancel`
- [x] Action bar shows/hides per bucket and role (spec §11.4)
- [x] After a successful action: refresh the list, toast, and move the order out of the bucket
- [x] *(Optional, pending confirmation)* assign a delivery boy from eligible-delivery-boys

**Acceptance:** reassigning from the *With Customer Support* bucket moves the order to *With Chemist*; cancelling from *With Manager* records the reason and shows it on the detail page.

---

### ☑ Phase 11 — Dashboard — **DONE 2026-08-02**

- [x] Bucket count cards, clickable through to the filtered list
- [x] Role-specific "my queue" card for Manager and CustomerSupport
- [x] People counts and region coverage cards
- [x] Skeletons while loading; graceful degradation when an endpoint 403s

**Acceptance:** counts match the corresponding list screens.

---

### ◐ Phase 12 — Hardening and release — **mostly done 2026-08-02**

- [x] Unit tests: JWT parsing/expiry, order buckets & owner resolution, validators, menu visibility — **32 specs, all passing**
- [ ] Component tests for the data table and at least one full CRUD feature — **not done**; only the pure logic is covered
- [ ] Playwright smoke run: login → each menu → one CRUD → one order reassign — **not done**; verified manually in the browser instead
- [x] Responsive audit — cards below 768px, tables above, no horizontal overflow at 375px
- [x] Accessibility — `@angular-eslint` template a11y rules pass; card rows are keyboard-activatable; dialogs trap focus via Material
- [x] Production build clean — 497 kB initial / 130 kB transferred, inside budget; run + deploy notes in the README
- [x] Final pass over the spec's open questions and gap list

---

## 6. API reference used by this build

| Area | Endpoints |
|---|---|
| Auth | `POST /api/Auth/login`, `/forgot-password`, `/verify-otp-reset-password`, `/change-password` |
| Managers | `GET /api/Managers`, `GET|PUT|DELETE /{id}`, `POST /register`, `POST /{id}/photo` |
| Customer Support | `GET /api/CustomerSupports`, `GET|PUT|DELETE /{id}`, `POST /register`, `POST /{id}/photo` |
| Delivery Boys | `GET|POST /api/Deliveries`, `GET|PUT|DELETE /{id}`, `GET /medicalstore/{storeId}[/active]` |
| Chemists | `GET /api/MedicalStores`, `GET|PUT|DELETE /{id}`, `POST /{id}/activate`, `/{id}/deactivate`, `DELETE /{id}/hard`, `GET /api/chemist-payout/{storeId}[/activation]` |
| Customers | `GET|POST /api/Customers`, `GET|PUT|DELETE /{id}`; `/api/CustomerAddresses` CRUD + `PUT /customer/{cid}/set-default/{aid}` |
| Regions | `GET|POST /api/ServiceRegions`, `GET|PUT|DELETE /{id}`, `POST /add-pincode`, `/remove-pincode`, `GET /{id}/pincodes`, `GET /by-pincode/{pin}` |
| Region assignment | `POST /api/ServiceRegions/assign`, `/assign/bulk`, `/assign-delivery`, `/assign-delivery/bulk` |
| Orders | `GET /api/Orders`, `GET /{id}`, `GET /customersupport/{id}[/assignedtocustomersupport]`, `GET /manager/{id}[/assignedtomanager]`, `PUT /{id}/reassign`, `PUT /assign`, `PUT /{id}/cancel`, `PUT /{id}/assign-delivery`, `GET /{id}/eligible-delivery-boys`, `GET /{id}/medical-stores-by-pincode`, `/medical-stores-by-city`, `/nearby-chemists/{orderNumber}`, `GET /{id}/download-input-file`, `/download-bill` |
| Payments | `GET /api/Payments/order/{id}`, `GET /api/Razorpay/payment-split/{id}` |

---

## 7. Risks

| Risk | Impact | Mitigation |
|---|---|---|
| Phase 0 not approved | Orders module cannot be built as specified | Fallback: derive buckets from `OrderStatus` + null checks on the three id fields — imprecise, and "Out for Delivery" loses the delivery-boy name |
| `GET /api/Orders` unpaginated | Slow All Orders screen as volume grows | Client-side paging now; raise server-side paging when it hurts |
| No permissions endpoint | Client menu map can drift from server rules | Always handle 403; keep the map in one file (`core/config/`) |
| Overlap with the existing React app | Duplicated maintenance | Resolve spec §14 Q4 before Phase 12 |
| Region hard-delete | Orphaned staff | Client pre-check (Phase 7); recommend a server-side guard |

---

## 7a. Running the API locally (verified 2026-08-02)

`appsettings.Development.json` points at the **shared Azure test database**, and `FileStorage:Provider`
is `Azure` with a placeholder connection string that throws `FormatException: Settings must be of the
form "name=value"` on any order request. To run against the local database instead, override both:

```bash
cd Backend/MedicineDelivery && ConnectionStrings__PostgresConnection="Host=localhost;Port=5432;Database=MedicineDeliveryNew;Username=postgres;Password=123;Include Error Detail=true;" FileStorage__Provider="Local" dotnet run --project MedicineDelivery.API
```

Serves on `http://localhost:5000` (`launchSettings.json` wins over `ASPNETCORE_URLS`). No migrations
or seeding run at startup. Local admin login: mobile `9999999999` / `Admin@123`.
The same local values are kept in [WorkingAppSettings/](../../WorkingAppSettings/).

---

## 8. Session log

| Date | Phase(s) | What was done | Left for next time |
|---|---|---|---|
| 2026-08-02 | — | Backend analysis; functional spec and this plan written | Sign-off on spec §14 open questions, then start Phase 0/1 |
| 2026-08-02 | **0 ☑** | Owner approved Angular Material + the `OrderDto` change. Added `AssignTo`, `DeliveryId` and the four assignee-name fields; added batched `EnrichAssigneeNamesAsync` to `OrderService` and wired it into the six staff reads. Build clean, 20/20 tests pass, verified live against the local DB. Recorded two client-facing behaviours (NULL `AssignTo` → bucket 0; assignee ids persist after hand-off) and the login-response gap now written up in Phase 1c. | Start **Phase 1** — scaffold `staff-console`, Angular Material, auth (JWT-decode based), shell, shared UI |
| 2026-08-02 | **6–12** | Built Customers (+ inline address management), Regions for both types (pin-code chips, pin-code lookup, bulk assignment workbench, delete guard), and the whole Orders module — shared store, six bucket screens, detail page with assignment-history timeline, reassign and cancel dialogs — plus the live dashboard. Added 32 unit specs; lint, build and tests all clean. Verified every screen against the live API, including both bulk-assignment write paths (state restored afterwards). Fixed a backend defect found in testing: `medical-stores-by-city` threw an EF translation error, so "widen to city" never worked. Added the test-accounts section to the spec (§15). | Optional: Playwright smoke suite, component tests, and the deferred items in §9 |
| 2026-08-02 | **1–5 ☑** | Scaffolded the Angular 20 app with Material; built auth (JWT-decode + entityId lookup), the responsive shell, and the shared UI kit; then Managers, Customer Support (+ region assignment), Delivery Boys (+ region assignment) and Chemists (+ activate/deactivate, hard delete). ESLint added and passing; production build clean. Every screen verified against the live API with the local database. Three defects found and fixed along the way: detail pages read the route input in the constructor before binding; the card/table breakpoint used Material's Handset (~600px) instead of the documented 768px; the `reset` output shadowed a native DOM event. | Start **Phase 6 — Customers**, then Phase 7 (Regions UI) |

---

## 9. Open items

- [x] Spec §14 Q1 — **Angular Material confirmed** (2026-08-02)
- [x] Spec §13.1 — **`OrderDto` change approved and shipped** (Phase 0, 2026-08-02)
- [x] Spec §14 Q2 — include "assign delivery boy" in the console?
- [x] Spec §14 Q3 — allow reassignment from *Awaiting Assignment* / *With Chemist*?
- [x] Spec §14 Q4 — does this replace the React WebApp, chemist portal included?
- [x] Spec §14 Q5 — confirm the dev/prod API URLs
- [x] Spec §13.3 — decide whether CustomerSupport should be able to list delivery boys
- [x] Spec §13.4 — decide whether the over-permissive endpoints get fixed in this effort or tracked separately
- [x] **New (Phase 0 finding):** fix `MedicineDelivery.API/Services/AuthService.LoginAsync` to populate
      `role`, `userId`, `entityId` and `expiresAt` — currently all null, so every client has to decode
      the JWT and make an extra call for `entityId`. Small change; the React app benefits too.
      Phase 1 works around it either way.
- [x] **New (Phase 0 finding):** two `AuthResult` classes and two `AuthService` implementations exist
      (API layer + Infrastructure). Only the API-layer one is registered; the Infrastructure one looks
      like dead code and violates the layering rule in `Backend/MedicineDelivery/CLAUDE.md`.
- [x] **New (Phase 1):** sidebar rail mode at 768–1023px was specced but not built — the drawer is
      either docked or off-canvas. Decide whether the rail is worth adding.
- [x] **New (Phase 5):** the chemists list omits the payout/activation column (one request per row).
      If it is wanted there, the API needs a bulk payout-status endpoint.
- [x] **Testing debt:** the app has no unit or component tests yet — Karma/Jasmine came with the
      scaffold but Phase 12 plans a Vitest migration. Everything so far is verified manually against
      the live API.
