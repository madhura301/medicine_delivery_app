# Playwright Suite — Work Tracker (multi-session)

> **Purpose:** This is the single source of truth for *what is done* and *what is next*.
> The plan/technical details live in [`plan.md`](./plan.md). This file tracks **progress only**.
> This is a large project spanning multiple sessions — **do not redo finished work**.

---

## 🔁 Session protocol (read this first, every session)

1. **Start:** Read this file top-to-bottom. Read the **▶ RESUME HERE** pointer below.
2. **Verify before trusting checkmarks:** a `[x]` means "claimed done in a prior session."
   Spot-check the actual file/spec exists and passes before building on top of it.
3. **Work:** Pick the next unchecked item under the current phase. Don't skip phases —
   later phases depend on earlier ones (harness → API → WebApp → Flutter → CI).
4. **End of session:** (a) tick completed boxes, (b) update the **▶ RESUME HERE** pointer,
   (c) add a dated entry to the **Session Log**, (d) record any new blocker/decision.
5. Never mark a spec `[x]` unless it has been **run and is green** (or explicitly noted as
   `WIP`/`written-not-verified` in the Session Log).

**Status legend:** `[ ]` not started · `[~]` in progress · `[x]` done & verified · `[!]` blocked

---

## ▶ RESUME HERE

> **Last updated:** 2026-05-17 (Session 5 — Phase 2 COMPLETE)
> **Next action:** **Phase 3 — WebApp E2E.** Prereqs before writing specs:
> (a) `npx playwright install chromium`; (b) start WebApp dev server
> (`cd WebApp && npm install && npm run dev`, :5173) with
> `VITE_API_BASE_URL=http://localhost:5000/api`; (c) build the deferred
> `fixtures/auth.fixture.ts` — UI-login per web role and save Playwright
> `storageState` (WebApp keeps auth in localStorage: `auth_token`,
> `refresh_token`, `user_*`); (d) decide D1 selector approach in practice
> (Track B role/text first). Then work `webapp/auth/` → `admin/` → `chemist/`
> → `manager/` → `support/` → `shared/` per the Phase 3 checklist. Backend
> must be running (:5000) for the WebApp to talk to.
> **State:** Phase 2 DONE. Full API run = **211 passed / 5 skipped**
> (F1×1, F2×3, D2×1 — all tracked below). 18 API spec files, all green.
> Backend run cmd: `dotnet run --project MedicineDelivery.API --urls http://localhost:5000`.

---

## 📊 Progress at a glance

| Phase | Scope | Status | Done / Total |
|---|---|---|---|
| Analysis & Plan | Codebase analysis, `plan.md` | ✅ Done | 1 / 1 |
| Phase 0 | Prereqs & blocking decisions | 🟡 Defaulted | 4 / 6 |
| Phase 1 | Test harness / fixtures | 🟢 Core done & verified | 5 / 7 |
| Phase 2 | Backend API specs | ✅ Done & verified | 18 / 18 |
| Phase 3 | WebApp E2E specs | ⬜ Not started | 0 / 24 |
| Phase 4 | Flutter Web specs | ⬜ Not started | 0 / 13 |
| Phase 5 | CI + traceability | ⬜ Not started | 0 / 3 |
| Phase 6 | Hardening | ⬜ Not started | 0 / 3 |

---

## ⛔ Decisions Needed (blocking — resolve in Phase 0)

Record the decision + date inline when made. These gate implementation.

- [x] **D1 — Selector strategy.** → _Decision (2026-05-17, default by Claude, overridable):_ **Track B first** — Playwright role/label/text locators; add `data-testid` only where ambiguous. No app-code churn; unblocks WebApp phase. Revisit if WebApp specs prove flaky.
- [ ] **D2 — OTP retrieval.** SMS provider is `Console`. Test hook to read OTP: test-only API endpoint / log scrape / direct DB read? → _Decision: deferred to when first OTP-dependent spec is written (forgot-password reset / delivery-complete). Likely: read `UserOtp` from Postgres via a test DB helper._
- [ ] **D3 — Flutter Web renderer.** Confirm app builds & runs with `html` renderer. → _Decision: deferred to Phase 4 (Flutter not on PATH in current env anyway)._
- [x] **D4 — Test database.** → _Decision (2026-05-17, default by Claude, overridable):_ **Use existing `MedicineDeliveryNew`** + self-cleaning specs (unique mobile/email per test). No infra setup. ⚠️ See Findings F1 — shared DB has password drift on the `customer` account.
- [x] **D5 — Razorpay.** → _Decision (2026-05-17, default by Claude, overridable):_ **Defer** signature-verify specs (keys empty); test `create-order` request/response shape + negative (bad signature → reject). Stub later if a sandbox key is provided.
- [x] **D6 — CI runners.** → _Decision (2026-05-17, default by Claude, overridable):_ **Local-first.** API started manually / by CI step (not Playwright `webServer`); globalSetup only waits + seeds. Full CI runner story finalized in Phase 5.

---

## Phase 0 — Prerequisites

- [x] D1, D4, D5, D6 decided (defaults, overridable); D2, D3 deferred to their phases with documented workaround
- [ ] WebApp: `data-testid` added — N/A under D1 Track B (add ad-hoc only if flaky)
- [ ] Flutter: `Semantics`/`Key` added for plan §8 widgets — deferred to Phase 4 (D3)
- [ ] Flutter Web build verified — deferred to Phase 4 (Flutter not on PATH in this env)
- [ ] OTP-retrieval helper approach implemented — deferred to first OTP-dependent spec (D2)
- [ ] `helpers/selectors.ts` central selector map — deferred to Phase 3 (WebApp) start

## Phase 1 — Harness (`Playright/e2e/` workspace)

- [x] `e2e/` workspace: `package.json`, `tsconfig.json`, `@playwright/test` installed — verified (`npm install` ran, tests execute)
- [x] `playwright.config.ts` — projects `api` / `webapp-{chromium,firefox,webkit}` / `flutter-web`; reporters list+html+junit; `globalSetup`. NOTE: no `webServer` for API (D6 — API started manually); webapp/flutter `webServer` still TODO in their phases
- [x] `helpers/seed.ts` + `global-setup.ts` — calls `/api/setup/*` in order; verified (seed log shows 200/409-tolerated). Also `helpers/config.ts`, `helpers/jwt.ts`
- [ ] `fixtures/auth.fixture.ts` — WebApp `storageState` (localStorage) — **deferred to Phase 3** (not needed for API specs)
- [x] `fixtures/api.fixture.ts` — typed API request wrapper + `loginAs`/`apiAs` per role — verified green
- [ ] `fixtures/test-data.fixture.ts` + `fixtures/files/` — **deferred** to first spec that needs uploads (orders/medicalstores/bill)
- [x] `.env` + `.env.example` + `helpers/config.ts` wiring (API :5000, WebApp :5173, Flutter :8080) — verified

## Phase 2 — Backend API specs (`e2e/api/`) — ~110 endpoints

One file per controller. Each endpoint needs happy-path + auth-negative + validation-negative (see plan §7).

- [x] `auth.spec.ts` (login×5 roles, register, forgot-password, verify-otp-reset, change-password) — **16 passed / 1 tracked-skip** (customer login, see F1). Verified green 2026-05-17
- [x] `orders.spec.ts` — 25 endpoints: 401 gating, ListAll, by-id/customer/medicalstore/customersupport, delivery/my-orders(401 for admin), download negatives, mutation-not-found negatives, **serial: register customer+address → create text order (201) → read → list → record payment (201, PaymentsController happy path) → razorpay create-order**. `complete`-with-OTP is `test.fixme` (needs D2). — **24 passed / 1 fixme**, verified 2026-05-17
- [x] `customers.spec.ts` (8 endpoints: list/get/by-mobile/my-profile/register/create/update/delete + 401 gating + register→read→update→delete lifecycle) — **14 passed**, verified 2026-05-17. Found F3 (soft-delete).
- [x] `medicalstores.spec.ts` (7: register(200!)/list/by-id/by-email/update/check-availability/delete + 401 gating + lifecycle) — **13 passed**, verified 2026-05-17. (register returns 200 not 201 — analysis was wrong)
- [x] `deliveries.spec.ts` (7: create/list/by-id/by-store/by-store-active/update/delete + 401 gating + boy lifecycle) — **14 passed**, verified 2026-05-17. (POST works — no F2 bug here)
- [x] `products.spec.ts` (5 endpoints: list/get/create/update/delete + 401 + 404s) — **9 passed**, verified 2026-05-17
- [x] `users.spec.ts` (GET list, register, create-with-role, 401 gating, validation negatives) — **6 passed / 3 fixme (F2 backend bug)**, verified 2026-05-17
- [x] `payments.spec.ts` (3: record/by-order/total + 401 gating + unknown-order 404) — **6 passed**, verified 2026-05-17. (record-for-real-order deferred to orders lifecycle)
- [x] `razorpay.spec.ts` (create-order, verify-payment: 401 gating + validation + signature-mismatch negative; happy path deferred per D5) — **7 passed**, verified 2026-05-17
- [x] `customersupports.spec.ts` (7: register(200)/list/by-id/by-email/update/delete/photo + 401 gating + lifecycle) — **13 passed**, verified 2026-05-17. F3 idempotent soft-delete.
- [x] `managers.spec.ts` (7: register(200)/list/by-id/by-email/update/delete/photo + 401 gating + lifecycle) — **13 passed**, verified 2026-05-17. F3 idempotent soft-delete.
- [x] `customeraddresses.spec.ts` (7: get/by-customer/default/create/update/delete/set-default + 401 gating + full lifecycle) — **18 passed**, verified 2026-05-17. (address delete is HARD, not soft)
- [ ] `products.spec.ts` (5)
- [ ] `users.spec.ts` (4 incl. create-with-role, anon register)
- [x] `rolepermissions.spec.ts` (4: get-by-role/add/remove/roles-with-permissions + 401 gating + validation + non-destructive add/remove round-trip) — **13 passed**, verified 2026-05-17
- [x] `consents.spec.ts` (10: list/active/by-id/create/update/delete/accept/reject/logs/my-logs + 401 gating + lifecycle) — **14 passed**, verified 2026-05-17
- [x] `serviceregions.spec.ts` (route `/api/ServiceRegions`; class is `ServiceRegionsController` in file `CustomerSupportRegionsController.cs` — analysis had the name wrong; create/list/by-type/by-id/update/delete/add+remove-pincode/by-pincode/assign/assign-delivery + 401 gating + lifecycle) — **15 passed**, verified 2026-05-17. Found F4.
- [x] `setup.spec.ts` (predefined roles/perms/role-perms → 200; seed users idempotent 200|409; fix-missing-customer-numbers → 200; all anonymous) — **3 passed**, verified 2026-05-17
- [x] `authorization-matrix.spec.ts` — authn-vs-authz (401 vs 403 same endpoint), admin allowed on governance, chemist/support forbidden (403), each working role authorized on its entitled endpoint — **8 passed**, verified 2026-05-17. Full per-permission grid intentionally deferred (documented in-spec).
- [x] `negative-edge.spec.ts` — malformed JSON→400, garbage/forged/expired JWT→401, unknown route→404, wrong method→404/405, ModelState over-length→400, empty creds→400 — **10 passed**, verified 2026-05-17. (per-endpoint dup-registration/file-type negatives live in their own specs)

## Phase 3 — WebApp E2E specs (`e2e/webapp/`)

### auth/
- [ ] `login.spec.ts` (valid per web role, invalid, Customer/DeliveryBoy mobile-only block, remember-me, empty validation)
- [ ] `forgot-password.spec.ts`
- [ ] `reset-password.spec.ts`
- [ ] `change-password.spec.ts` (all 4 web roles)
- [ ] `logout.spec.ts`
- [ ] `session.spec.ts` (401 interceptor → clear + redirect)

### admin/
- [ ] `dashboard.spec.ts`
- [ ] `user-management.spec.ts` (5 tabs, 4 chips, search, delete+confirm)
- [ ] `create-user.spec.ts` (5 roles, role-specific fields)
- [ ] `all-orders.spec.ts` (5 filter chips)
- [ ] `order-details.spec.ts` (all panels, downloads, AuthImage)
- [ ] `service-regions.spec.ts` (create, search, type filter, pincodes, delete)
- [ ] `consent-logs.spec.ts`

### chemist/
- [ ] `dashboard.spec.ts`
- [ ] `orders.spec.ts` (4 tabs, accept, reject dialog, upload-bill multipart)
- [ ] `order-detail.spec.ts`
- [ ] `profile.spec.ts`

### manager/
- [ ] `dashboard.spec.ts`
- [ ] `orders.spec.ts`
- [ ] `delivery-boys.spec.ts`
- [ ] `profile.spec.ts`

### support/
- [ ] `dashboard.spec.ts`
- [ ] `assignments.spec.ts` (assign-to-chemist dialog)
- [ ] `profile.spec.ts`

### shared/
- [ ] `role-guard.spec.ts` (full role × 28-route grid + redirect targets)
- [ ] `navigation.spec.ts` + `common-components.spec.ts` + `error-handling.spec.ts` (+ Firefox/WebKit smoke subset)

## Phase 4 — Flutter Web specs (`e2e/flutter-web/`)

### customer/
- [ ] `auth.spec.ts` (login, multi-step register, forgot/reset/change)
- [ ] `dashboard.spec.ts`
- [ ] `create-order-image.spec.ts` (camera = `[API-SUBSTITUTE]`)
- [ ] `create-order-voice.spec.ts` (recording = `[API-SUBSTITUTE]`)
- [ ] `create-order-text.spec.ts`
- [ ] `address-selector.spec.ts`
- [ ] `order-tracking.spec.ts`
- [ ] `payment.spec.ts`
- [ ] `delivery-otp.spec.ts`

### delivery/
- [ ] `auth.spec.ts`
- [ ] `dashboard.spec.ts` (My/Completed tabs)
- [ ] `complete-delivery.spec.ts` (OTP digit entry → complete)
- [ ] `profile.spec.ts`

## Phase 5 — CI + traceability

- [ ] GitHub Actions workflow (Postgres + .NET 8 + WebApp + Flutter build/serve, per D6)
- [ ] `coverage-matrix.md` generator (every plan §6–§8 row → spec → status; fail on gaps)
- [ ] CI gating + artifact publish (html report, junit, traces)

## Phase 6 — Hardening

- [ ] Flake elimination pass (retries, waits, serial isolation)
- [ ] Cross-browser smoke subset stable on Firefox + WebKit
- [ ] (Optional) Coverlet on API for secondary ≥90% line-coverage figure

---

## 🔎 Findings (issues discovered while testing — keep, don't delete)

- **F1 — Seeded `customer` password drift (2026-05-17).** In the shared
  `MedicineDeliveryNew` DB, `POST /api/auth/login` for `6666666666` / `Customer@123`
  returns `400 {"errors":["Invalid mobile number or password"]}`. The other 4 roles
  (admin/manager/support/chemist) log in fine. Root cause: the user pre-existed and
  `POST /api/setup/users/customer` returns **409 Conflict without resetting the
  password**. Impact: any Customer-role spec (Flutter customer journeys) can't use
  the documented seeded creds in this DB. `auth.spec.ts` marks this one case
  `test.fixme` (tracked, not hidden). **Fix options:** (a) reset customer password
  via DB/admin before customer specs, (b) register a fresh customer per run and use
  that (preferred — aligns with D4 self-cleaning), (c) make the setup endpoint
  reset password on conflict (backend change — raise with team).

- **F2 — `/api/users` register & create-with-role throw 500 (2026-05-17). BACKEND BUG.**
  `POST /api/users/register` and `POST /api/users/create-with-role` return
  `500 {"error":"An error occurred while ..."}`. API log shows
  `System.InvalidCastException: Unable to cast object of type
  '...RegisterUser.ApplicationUserImpl' to type
  'MedicineDelivery.Infrastructure.Services.ApplicationUserWrapper'`
  thrown at `RegisterUserCommandHandler.cs:53` and the twin at
  `CreateUserWithRoleCommandHandler.cs:55`. The user row IS inserted (EF INSERT
  runs) *before* the cast throws, so failed calls still create orphan users.
  `POST /api/auth/register` is UNAFFECTED (separate IAuthService path) — that is
  why `auth.spec.ts` register tests pass. Impact: admin "create user" WebApp flow
  (plan §6.3 create-user.spec) and any spec needing programmatic user creation via
  these endpoints. **Tracked, not hidden:** 3 happy-path tests in `users.spec.ts`
  are `test.fixme` with F2 refs; validation/401 negatives still pass for real.
  **Action:** raise with backend team — `ApplicationUserImpl` vs
  `ApplicationUserWrapper` cast in both handlers. Flip `test.fixme`→`test` when fixed.

- **F3 — `DELETE /api/customers/{id}` is a SOFT delete (2026-05-17). BEHAVIOR (not a bug).**
  Returns `204` but the record stays retrievable via GET `/api/customers/{id}`
  with `isActive=false` (no 404 afterwards). Likely the same pattern on other
  entities (medicalstores, deliveries, etc.) — assert soft-delete semantics, not
  hard-delete, in their specs. Impact: WebApp "deleted" filter / admin user-mgmt
  expectations; self-cleaning specs can't rely on 404-after-delete.

- **F4 — Duplicate pincode-per-region-type returns 500, not 400 (2026-05-17). MINOR BACKEND NIT.**
  `POST /api/ServiceRegions` (and add-pincode) with a pin already assigned to
  another region of the same type throws `InvalidOperationException` in
  `CustomerSupportRegionService.cs:493` (`EnsurePinCodeUniquePerRegionTypeAsync`).
  The controller only catches `ArgumentException`→400, so this surfaces as **500**
  instead of a 400/409. Low severity (validation works, just wrong status code).
  Specs avoid it by using run-unique pin codes. Suggest backend catch
  InvalidOperationException → 400/409. Not blocking.

## 🧾 Session Log (append newest at top — never delete entries)

### 2026-05-17 — Session 5  (PHASE 2 COMPLETE ✅)
- **Done:** Remaining Phase 2 specs `customersupports`, `managers`, `consents`,
  `rolepermissions`, `serviceregions`, `razorpay`, `setup`, `orders`,
  `authorization-matrix`, `negative-edge` (read every controller + DTO + enum
  before asserting). **All 18 API spec files complete.**
- **State / verified green:** final full `--project=api` run =
  **211 passed / 5 skipped** (skips: F1×1 customer login, F2×3 user-create bug,
  D2×1 order-complete OTP — all tracked). Orders lifecycle proven end-to-end:
  customer register → address → text order (201) → payment recorded (201) →
  razorpay create. New finding **F4** (minor: dup-pincode → 500 not 400).
  Contract corrections logged in-spec: ServiceRegions class≠file name;
  medicalstore/CS by-unknown-guid → 400 not 200; CS/Manager delete idempotent
  soft (F3); assign-order unknown → 400 not 404.
- **Blockers:** none. F1/F2/F3/F4 + D2 tracked. Backend still on :5000.
- **Next (Phase 3 — WebApp E2E):** install chromium; run WebApp dev server;
  build `fixtures/auth.fixture.ts` (localStorage storageState per web role);
  then `webapp/auth → admin → chemist → manager → support → shared` per checklist.

### 2026-05-17 — Session 4
- **Done:** Phase 2 specs `customers`, `medicalstores`, `customeraddresses`,
  `deliveries`, `payments` (all read actual controllers + DTOs first).
- **State / verified green:** full `--project=api` run = **97 passed / 4 skipped**
  (8 specs). New finding **F3** (soft delete on /api/customers). Confirmed
  contract corrections: medicalstores `register` returns 200 (not 201);
  customeraddress delete is hard; delivery POST works (no F2 bug).
- **Blockers:** none. F1/F2/F3 tracked. Backend still running on :5000.
- **Next:** `customersupports`, `managers`, `rolepermissions`, `consents`,
  `serviceregions`, `razorpay`, `setup`; then `orders` serial lifecycle
  (customer+store+boy create paths all verified working); then
  `authorization-matrix` + `negative-edge`.

### 2026-05-17 — Session 3
- **Done:** Phase 2 specs `products.spec.ts` (full CRUD + 401 + 404s) and
  `users.spec.ts` (GET list, register, create-with-role, gating, validation).
  Read actual ProductsController/UsersController + User DTOs + role GUIDs from
  `PredefinedAuthorizationData.cs` before asserting.
- **State / verified green:** `npx playwright test --project=api` →
  **32 passed / 4 skipped**. products = 9/9 pass. users = 6 pass + 3 fixme (F2).
  Discovered + documented backend defect **F2**.
- **Blockers:** F2 is a backend bug (not ours) — affects future admin create-user
  WebApp spec; logged for the backend team. Nothing blocks continuing Phase 2.
- **Next:** `customers.spec.ts`, then `medicalstores.spec.ts` (both have anon
  `register`), then `customeraddresses.spec.ts`; build toward `orders.spec.ts`.

### 2026-05-17 — Session 2
- **Done:** Made default decisions D1/D4/D5/D6 (deferred D2/D3) — all recorded in
  Decisions section, overridable by team. Built & **verified** Phase 1 harness:
  `e2e/` workspace, `playwright.config.ts`, `global-setup.ts`, `helpers/{config,jwt,seed}.ts`,
  `fixtures/api.fixture.ts`, `.env(.example)`. Wrote & ran `api/auth.spec.ts`.
- **State / verified green:** API built (exit 0), runs on :5000, Postgres on 5432.
  Seed ran (roles/perms 200; users 200/409-tolerated). `npx playwright test
  --project=api` → **16 passed, 1 skipped** (F1). Harness proven end-to-end.
- **Blockers:** None blocking Phase 2. F1 affects Customer specs later (Phase 4).
  Backend is NOT auto-started by Playwright — must `dotnet run` it before specs.
- **Next:** Continue Phase 2 — write `products.spec.ts` / `users.spec.ts` next
  (low-dependency), copy the `auth.spec.ts` + `api.fixture.ts` pattern; build
  toward `orders.spec.ts` serial lifecycle. Read AuthController-style: confirm each
  controller's real DTO/status codes before asserting.

### 2026-05-17 — Session 1
- **Done:** Full codebase analysis (Backend / WebApp / Flutter). Wrote `plan.md`.
  Created this `task.md` tracker. Moved into `Playright/Documents/`.
- **State:** No test code yet. Phase 0 not started.
- **Blockers:** Decisions D1–D6 unresolved.
- **Next:** Resolve D1–D6, then Phase 1 harness scaffold.

### 2026-05-17 — Session 1
- **Done:** Full codebase analysis (Backend / WebApp / Flutter). Wrote `plan.md`.
  Created this `task.md` tracker. Moved into `Playright/Documents/`.
- **State:** No test code yet. Phase 0 not started.
- **Blockers:** Decisions D1–D6 unresolved.
- **Next:** Resolve D1–D6, then Phase 1 harness scaffold.

<!-- Template for next session:
### YYYY-MM-DD — Session N
- Done:
- State / what was verified green:
- Blockers:
- Next:
-->
