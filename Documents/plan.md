# Playwright Test Automation Plan — Pharmaish Medicine Delivery App

> **Goal:** A Playwright test suite that gives **100% coverage** of the user-facing
> and API surface across the three deliverables:
> **Backend (.NET 8 API)**, **WebApp (React 19)**, and **Flutter_UI (Flutter Web build)**.
>
> Status: PLAN ONLY — no code written yet. This document is the blueprint.

---

## 1. What "100% coverage" means here

Playwright is a black-box browser/HTTP automation tool — it does not produce C#
line/branch coverage. "100% coverage" in this plan is defined as **full surface
coverage**, measured by explicit traceability matrices:

| Coverage dimension | Target | How it is measured |
|---|---|---|
| **API endpoints** | Every controller action (~110 endpoints across 16 controllers) hit with at least one happy-path + one auth-negative + one validation-negative test | API endpoint matrix (§7) — every row has ≥1 passing spec |
| **WebApp routes** | All 28 routes rendered & asserted per allowed role and per forbidden role | Route matrix (§6) |
| **WebApp UI elements** | Every form (15+), dialog, table filter, tab, search box exercised | UI element checklist (§6) |
| **User journeys** | Every documented end-to-end flow per role (Admin, Chemist, Manager, CustomerSupport on web; Customer, DeliveryBoy on Flutter Web) | Journey matrix (§6, §8) |
| **Auth/permission model** | All 6 roles × permission-gated endpoints — positive (allowed) and negative (403/redirect) | Authorization matrix (§7.3) |
| **Backend code coverage (optional add-on)** | ≥90% line coverage as a *secondary* metric | Coverlet on the API process while Playwright runs (§10) |

A test run is "100%" when every row of every matrix in §6–§8 maps to at least one
green spec, and the traceability report (§11) shows no gaps.

---

## 2. Scope & boundaries

### In scope
- **WebApp** — primary E2E target. React SPA, 4 web roles (Admin, Chemist, Manager, CustomerSupport).
- **Backend API** — full REST surface via Playwright's `request` fixture (API testing project).
- **Flutter_UI** — tested via its **Flutter Web build** (`flutter build web` / `flutter run -d chrome`). Covers Customer & DeliveryBoy journeys.

### Explicit limitations (must be documented in the suite README)
Playwright **cannot** drive native mobile. For Flutter Web these device features are **out of scope for Playwright** and must be covered by Flutter `integration_test` / native tests instead:
- Camera capture (`camera` package — no web support)
- Microphone / audio recording (`flutter_sound` — restricted on web)
- Native geolocation (`geolocator`/`geocoding` — no web support)
- OS permission prompts, `flutter_secure_storage` native vault

For these flows the plan substitutes **API-level tests** (e.g. order creation via
`POST /api/orders` with a fixture file) so the *business flow* still reaches 100%
even though the *native UI widget* is not driven by Playwright. These substitutions
are flagged `[API-SUBSTITUTE]` in the matrices.

---

## 3. Tooling & dependencies

- **Playwright Test** (`@playwright/test`) — TypeScript.
- Node 18+ (repo already uses Node 24 types).
- Browsers: Chromium (primary), Firefox + WebKit (smoke subset for cross-browser).
- Reporters: `html`, `list`, `junit` (for CI), plus `allure-playwright` (optional).
- `dotenv` for environment config.
- Backend run dependencies: .NET 8 SDK, PostgreSQL (`MedicineDeliveryNew` @ localhost:5432).

### Recommended repo layout (new top-level folder)

```
e2e/                                  # new Playwright workspace (sibling of WebApp)
├── package.json
├── playwright.config.ts              # projects: api, webapp, flutter-web
├── .env.example
├── tsconfig.json
├── fixtures/
│   ├── auth.fixture.ts               # per-role authenticated storage state
│   ├── api-client.fixture.ts         # typed API request wrapper
│   ├── test-data.fixture.ts          # seeded entities (customer, store, order)
│   └── files/                        # sample prescription.jpg, prescription.pdf, voice.m4a, bill.pdf
├── helpers/
│   ├── seed.ts                       # calls /api/setup/* to seed roles+users
│   ├── jwt.ts                        # decode/inspect tokens
│   ├── selectors.ts                  # central selector map (see §5)
│   └── order-flow.ts                 # reusable order-lifecycle steps
├── api/                              # Backend API specs (§7)
│   ├── auth.spec.ts
│   ├── orders.spec.ts
│   ├── customers.spec.ts
│   ├── medicalstores.spec.ts
│   ├── deliveries.spec.ts
│   ├── payments.spec.ts
│   ├── razorpay.spec.ts
│   ├── customersupports.spec.ts
│   ├── managers.spec.ts
│   ├── customeraddresses.spec.ts
│   ├── products.spec.ts
│   ├── users.spec.ts
│   ├── rolepermissions.spec.ts
│   ├── consents.spec.ts
│   ├── serviceregions.spec.ts
│   ├── setup.spec.ts
│   └── authorization-matrix.spec.ts  # role × endpoint negative grid
├── webapp/                           # React E2E specs (§6)
│   ├── auth/
│   ├── admin/
│   ├── chemist/
│   ├── manager/
│   ├── support/
│   └── shared/                       # guards, 401 handling, layout/nav
├── flutter-web/                      # Flutter Web specs (§8)
│   ├── customer/
│   └── delivery/
└── reports/
```

> Keeping `e2e/` separate avoids polluting `WebApp/package.json` and lets the
> suite test all three apps from one place.

---

## 4. Environment & test-data strategy

### 4.1 Services under test

| Service | Start command | Default URL |
|---|---|---|
| Backend API | `dotnet run --project MedicineDelivery.API` | `http://localhost:5000` (Swagger at `/swagger`) |
| WebApp | `npm run dev` (in `WebApp/`) | `http://localhost:5173` |
| Flutter Web | `flutter run -d chrome` or serve `flutter build web` output | `http://localhost:8080` (configurable) |

`playwright.config.ts` uses **`webServer`** entries to auto-start WebApp and a
static server for the Flutter build; the API is started/seeded by global setup.

Set `WebApp` env: `VITE_API_BASE_URL=http://localhost:5000/api`,
`VITE_DOC_BASE_URL=http://localhost:5000`.
Set Flutter env to the same API base (override staging in `environment_config.dart`
or via a `--dart-define`).

### 4.2 Seeding (global setup)

`helpers/seed.ts`, run once in `globalSetup`, calls the **`/api/setup`**
`[AllowAnonymous]` endpoints in order:

1. `POST /api/setup/roles/predefined`
2. `POST /api/setup/permissions/predefined`
3. `POST /api/setup/role-permissions/predefined`
4. `POST /api/setup/users/admin/firstuser`
5. `POST /api/setup/users/admin`
6. `POST /api/setup/users/manager`
7. `POST /api/setup/users/customer-support`
8. `POST /api/setup/users/customer`
9. `POST /api/setup/users/chemist`

### 4.3 Seeded test accounts (from `SetupController`)

| Role | Mobile | Password |
|---|---|---|
| Admin (first) | 8793583675 | Admin@123 |
| Admin (alt) | 9999999999 | Admin@123 |
| Manager | 8888888888 | Manager@123 |
| CustomerSupport | 7777777777 | Support@123 |
| Customer | 6666666666 | Customer@123 |
| Chemist | 5555555555 | Chemist@123 |

### 4.4 Authentication fixtures

`auth.fixture.ts` logs in each web role once via `POST /api/auth/login`, decodes
the JWT, and writes Playwright **storage state** files
(`.auth/admin.json`, `.auth/chemist.json`, etc.). The WebApp stores auth in
`localStorage` (`auth_token`, `refresh_token`, `user_*`), so storage state must
seed `localStorage`, not just cookies — use a setup spec that performs a real UI
login and saves `storageState`, OR inject `localStorage` via an init script.
Playwright projects then attach `storageState` per role.

### 4.5 Data isolation

- Each spec that mutates state creates its own entities (unique mobile/email via
  timestamp) and cleans up via DELETE endpoints in `afterEach` where supported.
- Order-lifecycle specs run **serially** within a worker (use `test.describe.serial`)
  because they share order state across steps.
- Consider a dedicated test DB (`MedicineDeliveryTest`) restored/reset between
  full runs to keep determinism.

---

## 5. Selector strategy (critical — read first)

**Finding from analysis: the WebApp and Flutter Web currently have NO `data-testid`
attributes.** All selectors must rely on MUI semantics / accessible roles / text.
This is fragile. The plan has two tracks:

- **Track A (recommended, do first):** Add `data-testid` attributes to the WebApp
  (and `Semantics`/`Key` to Flutter widgets) for every element the matrices touch.
  Maintain a single `helpers/selectors.ts` map. ~1–2 days of WebApp edits; makes
  the suite stable. This is a prerequisite task, not optional, for *reliable* 100%.
- **Track B (fallback):** Use role/label/text selectors
  (`getByRole`, `getByLabel`, `getByText`) only. Works without code changes but
  is brittle for tables/dialogs and non-unique text.

Decision required from the team before implementation starts (see §12 open questions).

---

## 6. WebApp E2E coverage (React — primary target)

### 6.1 Route matrix (28 routes)

For **every** route: test (a) renders for the allowed role, (b) redirects to
`/login` when unauthenticated, (c) redirects to own dashboard when accessed by a
wrong role (RoleGuard), (d) Customer/DeliveryBoy login is rejected with the
mobile-only error.

**Public:** `/login`, `/forgot-password`, `/reset-password`, `/` → `/login`, `*` → `/login`

**Admin (role=Admin):** `/admin/dashboard`, `/admin/users`, `/admin/users/create`,
`/admin/orders`, `/admin/orders/:id`, `/admin/regions`, `/admin/consent-logs`,
`/admin/change-password`

**Chemist:** `/chemist/dashboard`, `/chemist/orders`, `/chemist/orders/:id`,
`/chemist/profile`, `/chemist/change-password`

**Manager:** `/manager/dashboard`, `/manager/orders`, `/manager/orders/:id`,
`/manager/delivery-boys`, `/manager/profile`, `/manager/change-password`

**CustomerSupport:** `/support/dashboard`, `/support/assignments`,
`/support/profile`, `/support/change-password`

### 6.2 Auth specs (`webapp/auth/`)

- `login.spec.ts` — valid login per web role → lands on role dashboard; invalid
  password → error alert; Customer/DeliveryBoy → "only accessible on mobile app"
  error; "Remember me" toggles `stayLoggedIn`; empty-field validation.
- `forgot-password.spec.ts` — submit mobile → success message; uses console SMS
  (read OTP via `/api/setup` or DB helper — see §12).
- `reset-password.spec.ts` — mismatched passwords blocked client-side; valid
  OTP + new password → redirect to `/login`; then login with new password.
- `change-password.spec.ts` — for **each** web role: wrong current password →
  error; mismatch → blocked; success → "Password changed successfully"; re-login.
- `logout.spec.ts` — clears `localStorage`, redirects to `/login`, back-nav blocked.
- `session.spec.ts` — expired/invalid token → 401 interceptor → `clearAll()` +
  redirect to `/login`.

### 6.3 Admin specs (`webapp/admin/`)

- `dashboard.spec.ts` — 4 stat cards show numeric values; clicking each card /
  quick-action navigates to `/admin/users|orders|regions|consent-logs`.
- `user-management.spec.ts` — all 5 tabs (Customers, Support, Chemists, Managers,
  Delivery Boys); 4 filter chips (All/Active/Inactive/Deleted); search by
  name/email/mobile; delete user → ConfirmDialog → row removed.
- `create-user.spec.ts` — step 1 role pick (all 5 roles); common fields; Chemist
  extra fields (Medical Store Name/DL/GSTIN); DeliveryBoy DL field; submit →
  success → redirect to `/admin/users`; verify created user appears.
- `all-orders.spec.ts` — 5 filter chips (All/Pending/Active/Completed/Rejected);
  table columns; view icon → `/admin/orders/:id`.
- `order-details.spec.ts` — all panels (Order info, Customer, Chemist, Address,
  Prescription w/ download, Bill w/ download, Assignment history timeline); back
  button; download buttons fetch authed image (AuthImage component).
- `service-regions.spec.ts` — create region (name/city/type CustomerSupport &
  DeliveryBoy); search; type filter chips; manage pin codes (add + delete);
  delete region (ConfirmDialog).
- `consent-logs.spec.ts` — table renders rows (user, type, Accepted/Rejected,
  IP, device, date); empty state when none.

### 6.4 Chemist specs (`webapp/chemist/`)

- `dashboard.spec.ts` — 4 count cards (Pending/Accepted/Completed/Rejected);
  recent pending preview (≤5) clickable to detail.
- `orders.spec.ts` — 4 tabs; **Accept** (PUT accept) → order moves to Accepted;
  **Reject** dialog (reason required) → moves to Rejected; **Upload Bill** dialog
  (amount + image/pdf file, multipart) when status=3 → moves forward.
- `order-detail.spec.ts` — panels + assignment history; back nav.
- `profile.spec.ts` — read-only store profile fields render.

### 6.5 Manager specs (`webapp/manager/`)

- `dashboard.spec.ts` — Total/Pending/In-Delivery/Completed-Today cards; quick
  actions navigate.
- `orders.spec.ts` — filter chips; view → `/manager/orders/:id` (reuses admin
  OrderDetailsPage — assert it renders for Manager).
- `delivery-boys.spec.ts` — table (name/mobile/license/status), read-only.
- `profile.spec.ts` — read-only fields.

### 6.6 CustomerSupport specs (`webapp/support/`)

- `dashboard.spec.ts` — Total/Assigned-to-Support/Pending/Completed cards.
- `assignments.spec.ts` — filter chips; for status 0/8 orders → "Assign to
  Chemist" dialog → select active chemist → assign; verify order state changes.
- `profile.spec.ts` — read-only fields.

### 6.7 Shared/cross-cutting (`webapp/shared/`)

- `role-guard.spec.ts` — full role × route grid (correct redirect targets).
- `navigation.spec.ts` — DashboardLayout sidebar shows only role-appropriate
  links; every link routes correctly.
- `common-components.spec.ts` — StatusBadge labels/colors per status enum;
  ConfirmDialog cancel vs confirm; LoadingSpinner during fetch; EmptyState on no
  data; AuthImage sends Bearer token.
- `error-handling.spec.ts` — API 4xx/5xx surfaces user-facing alerts; network
  failure handled.
- Cross-browser smoke subset run on Firefox + WebKit.

---

## 7. Backend API coverage (Playwright `request` project)

Each endpoint gets **happy path + auth-negative (401 no token / 403 wrong role) +
validation-negative (bad/missing DTO)**. Project `api` uses no `storageState`;
tokens acquired per role from `auth.fixture.ts`.

### 7.1 Endpoint inventory by controller (≈110 actions — all must be covered)

- **AuthController** `/api/auth`: `login`, `register`, `forgot-password`,
  `verify-otp-reset-password`, `change-password` (5)
- **OrdersController** `/api/orders`: get by id; by customer (+active); by
  medicalstore (+active/accepted/rejected); accept; reject; complete; assign;
  create (multipart); upload-bill (multipart); assign-to-delivery; list all;
  download-input-file; download-bill; medical-stores-by-city; by customersupport
  (+assigned); eligible-delivery-boys; delivery/my-orders;
  nearby-chemists/{orderNumber}; medical-stores-by-pincode (~25)
- **RazorpayController** `/api/razorpay`: create-order, verify-payment (2)
- **CustomersController** `/api/customers`: list, by id, by-mobile, my-profile,
  register (anon), create, update, delete (8)
- **MedicalStoresController** `/api/medicalstores`: register (anon), list, by id,
  by-email, update, check-availability, delete (7)
- **DeliveriesController** `/api/deliveries`: create, list, by id, by store,
  by store active, update, delete (7)
- **PaymentsController** `/api/payments`: create, by order, total (3)
- **CustomerSupportsController** `/api/customersupports`: register, list, by id,
  by-email, update, delete, photo upload (7)
- **CustomerAddressesController** `/api/customeraddresses`: by id, by customer,
  default, create, update, delete, set-default (7)
- **ProductsController** `/api/products`: list, by id, create, update, delete (5)
- **UsersController** `/api/users`: list, create, create-with-role, register (4)
- **RolePermissionsController** `/api/rolepermissions`: get by role, add, remove,
  roles-with-permissions (4)
- **ManagersController** `/api/managers`: register, list, by id, by-email,
  update, delete, photo (7)
- **ConsentsController** `/api/consents`: list, active, by id, create, update,
  delete, accept, reject, logs, my-logs (10)
- **ServiceRegionsController** `/api/ServiceRegions`: create, list, by id, update,
  delete, assign, assign/bulk, assign-delivery, assign-delivery/bulk,
  add-pincode, remove-pincode, pincodes, by-pincode (13)
- **SetupController** `/api/setup`: roles, permissions, predefined×3, users×6,
  fix-missing-customer-numbers (12) — covered by seed + dedicated smoke

### 7.2 Order-lifecycle integration spec (`api/orders.spec.ts` — serial)

End-to-end via API, asserting `OrderStatus` transitions at each step:

1. `POST /api/customers/register` (anon) → customer + address
2. `POST /api/orders` (multipart, image input) → status `PendingPayment`/`PendingAssignment`
3. Assign: `PUT /api/orders/assign` (or auto) → store assigned
4. `PUT /api/orders/{id}/accept` (chemist) → `ChemistAccepted`
5. Reject branch: `PUT /api/orders/{id}/reject` → `ChemistRejected` →
   appears in `customersupport/{id}/assignedtocustomersupport`
6. `POST /api/orders/{id}/upload-bill` (multipart) → `PendingDelivery`
7. `POST /api/orders/assign-to-delivery` → delivery assigned;
   visible in `GET /api/orders/delivery/my-orders`
8. Razorpay: `POST /api/razorpay/create-order` → `POST /api/razorpay/verify-payment`
9. `POST /api/payments` recorded; `GET /api/payments/order/{id}/total` correct
10. `PUT /api/orders/{id}/complete` with OTP → `Delivered`/`Completed`
11. `GET /api/orders/{id}/download-bill` and `download-input-file` return files

### 7.3 Authorization matrix spec (`api/authorization-matrix.spec.ts`)

Data-driven grid: for each of the 6 roles × each permission-gated endpoint,
assert allowed (2xx) vs forbidden (403) per the role→permission map:

- Admin → all permissions
- Manager / CustomerSupport / Customer / Chemist / DeliveryBoy → only their
  mapped permission IDs (per `PredefinedAuthorizationData`)
- Unauthenticated → 401 on every `[Authorize]` endpoint
- `[AllowAnonymous]` endpoints (`/api/customers/register`,
  `/api/medicalstores/register`, `/api/users/register`, all `/api/setup/*`,
  auth login/register/forgot/verify) reachable without token

### 7.4 Negative / edge specs

- Invalid/missing DTO fields → 400 with validation messages
- Expired OTP & max-attempts (5) on `verify-otp-reset-password`
- Invalid Razorpay signature on `verify-payment` → rejected
- File upload validation: wrong type / oversize on `upload-bill`, `register`
- Not-found IDs → 404; duplicate registration (mobile/email) → conflict
- JWT expiry (token expires in 1h) → 401
- Concurrent order assignment (optimistic conflict) if applicable

---

## 8. Flutter Web coverage (`flutter-web/`)

Built via `flutter build web`; served statically; driven by Playwright. Flutter
renders to canvas/HTML — **prefer the HTML renderer** (`--web-renderer html`) and
add `Semantics`/keys so Playwright can find elements (otherwise CanvasKit makes DOM
selectors impossible). This is a hard prerequisite — flag in §12.

### 8.1 Customer journey specs (`flutter-web/customer/`)

- `auth.spec.ts` — Login (mobile/password/remember); multi-step Customer
  registration (credentials → personal → address); forgot/reset/change password.
- `dashboard.spec.ts` — Customer dashboard renders name from JWT; drawer nav.
- `create-order-image.spec.ts` — Upload Prescription 3-step (file pick PDF/JPG
  ≤10MB → details → review → submit). `[API-SUBSTITUTE]` for camera capture.
- `create-order-voice.spec.ts` — Voice order UI steps; **recording itself is
  `[API-SUBSTITUTE]`** (post `POST /api/orders` OrderInputType=voice with
  fixture audio) — assert UI review/submit path otherwise.
- `create-order-text.spec.ts` — WhatsApp/text order (OrderInputType=text).
- `address-selector.spec.ts` — address dropdown populated from
  `GET /api/customers/by-mobile/{m}`; default preselected; add-new nav.
- `order-tracking.spec.ts` — All orders list + filters; order details page
  (status, type, files, assignment history, address).
- `payment.spec.ts` — Payment summary (medicines total + convenience fee = total);
  UPI selection; Pay Now → success callback.
- `delivery-otp.spec.ts` — 4-digit OTP entry, validation, `PUT /api/orders/{id}/complete`.

### 8.2 DeliveryBoy journey specs (`flutter-web/delivery/`)

- `auth.spec.ts` — login as delivery boy.
- `dashboard.spec.ts` — tabs: My Deliveries / Completed Deliveries; list loads
  from API filtered to current delivery boy.
- `complete-delivery.spec.ts` — open assigned order → enter OTP digit-by-digit
  → complete → success dialog → order moves to Completed tab.
- `profile.spec.ts` — delivery profile renders.

### 8.3 Out-of-Playwright (documented, not skipped silently)

Camera, mic recording, native geolocation, OS permissions — listed in suite
README with a pointer to recommended Flutter `integration_test` coverage so the
gap is explicit and owned.

---

## 9. `playwright.config.ts` design

- **Projects:**
  - `setup` — global seed + auth state generation (dependency for others)
  - `api` — `testDir: api/`, `baseURL` = API, no storageState
  - `webapp-chromium` / `webapp-firefox` / `webapp-webkit` — `baseURL` = WebApp
  - `flutter-web` — `baseURL` = Flutter build server
- `webServer`: auto-start WebApp dev server and Flutter static server; assume API
  is started by CI step / globalSetup checks `/swagger` health before seeding.
- `use`: `trace: 'on-first-retry'`, `screenshot: 'only-on-failure'`,
  `video: 'retain-on-failure'`.
- `retries: 2` in CI, `0` locally. `fullyParallel: true` except serial describe
  blocks for order lifecycle.
- Reporters: `list`, `html`, `junit` → `reports/`.

---

## 10. Optional: real backend code coverage

For a secondary numeric coverage figure, run the API under **Coverlet**:

```
coverlet bin/.../MedicineDelivery.API.dll --target "dotnet" \
  --targetargs "run --project MedicineDelivery.API" --format cobertura
```

Run the full Playwright `api` + E2E suites against that instance, stop the
process, collect the Cobertura report. Target ≥90% line coverage; gaps feed back
into new negative/edge specs until matrices + line coverage both satisfied.

---

## 11. Traceability & reporting

- A `coverage-matrix.md` (generated) maps every matrix row (§6–§8) → spec file →
  last run status. CI fails if any row is unmapped or red.
- HTML report + JUnit XML published as CI artifacts.
- A short dashboard: % routes covered, % endpoints covered, % journeys covered,
  optional % backend line coverage.

---

## 12. Phased implementation roadmap

| Phase | Deliverable | Est. |
|---|---|---|
| **0. Prereqs** | Decide selector strategy (§5); add `data-testid` to WebApp + `Semantics`/keys to Flutter; confirm Flutter `html` renderer build; OTP-retrieval helper for console SMS | 2–3 d |
| **1. Harness** | `e2e/` workspace, `playwright.config.ts`, seed helper, auth fixtures, API client, sample files | 2 d |
| **2. API suite** | All §7 specs incl. order-lifecycle + authorization matrix + negatives | 5–6 d |
| **3. WebApp suite** | All §6 specs (auth → admin → chemist → manager → support → shared) | 6–8 d |
| **4. Flutter Web suite** | All §8 specs incl. API-substitutes for native features | 4–5 d |
| **5. CI + traceability** | GitHub Actions workflow, matrix generator, gating | 2 d |
| **6. Hardening** | Flake elimination, cross-browser smoke, optional Coverlet | 2–3 d |

### Open questions to resolve before Phase 1
1. **Selector strategy** — approve adding `data-testid`/`Semantics` (Track A) vs role/text-only (Track B)? (Strongly recommend Track A.)
2. **OTP retrieval** — SMS provider is `Console`. Need a test hook to read the
   generated OTP (a test-only API endpoint, log scrape, or direct DB read). Which?
3. **Flutter Web renderer** — confirm the app builds & runs correctly with the
   `html` renderer (CanvasKit blocks DOM-based Playwright selectors).
4. **Test database** — use a dedicated `MedicineDeliveryTest` DB with reset
   between runs, or run against `MedicineDeliveryNew` with self-cleaning specs?
5. **Razorpay** — keys are empty in `appsettings.json`. Is there a mock/sandbox
   mode, or should `create-order`/`verify-payment` be tested against a stub?
6. **CI runners** — can CI host PostgreSQL + .NET 8 + Flutter SDK (for the web
   build), or should the Flutter build artifact be produced upstream and only
   served in CI?

---

## 13. Summary

This plan delivers **100% surface coverage** through explicit, gated traceability
matrices rather than an unverifiable claim:

- **WebApp:** 28 routes, 20 pages, ~15 forms, all dialogs/filters/tabs, 4 roles,
  guard/redirect/401 behavior — full E2E.
- **Backend:** ~110 endpoints across 16 controllers, full order lifecycle, a 6-role
  × permission authorization grid, and negative/edge cases — via Playwright API.
- **Flutter Web:** Customer & DeliveryBoy journeys end-to-end, with native-only
  features explicitly covered by API substitutes and flagged for separate
  Flutter integration testing.

The single biggest risk is **selector stability** (no test IDs today) and the
**Flutter Web renderer**; both are called out as Phase 0 prerequisites with a
recommended path. Resolve the six open questions in §12 to unblock implementation.
