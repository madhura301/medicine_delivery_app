# Pharmaish — Functional validation (reusable)

`validate_functional.py` drives a **locally-running** Pharmaish backend through
every business scenario in *Functional Specification & Requirements Sign-off v1.1*
and prints a PASS/FAIL report mapped to the document sections. Run it again and
again — it is idempotent and self-cleaning.

## What it covers

| Check | PDF ref |
|---|---|
| SMS provider is `Console` (no real SMS is ever sent; OTP is logged only) | §9 / §12 |
| Chemist eligibility gate — ineligible chemist ⇒ order blocked | §5 |
| Normal journey: create → accept → bill → out-for-delivery → pay → **OTP → Completed** | §6.1–6.7 |
| Reject (reason required) → assigned to Customer Support → CS reassigns to another chemist | §7 |
| Reject without a reason ⇒ 400 | §7.1 |
| **CR-1** — unserviceable area blocked with "service not available" message | §8 / §11 #1 |
| **CR-2** — no Customer Support for pincode ⇒ escalated to a Manager | §11 #3 |

## Prerequisites

1. **Postgres** running locally, database `MedicineDeliveryNew`.
2. **Backend** running locally against that DB and a real blob string, SMS left on Console:
   ```bash
   cd Backend/MedicineDelivery
   export ConnectionStrings__PostgresConnection='Host=localhost;Port=5432;Database=MedicineDeliveryNew;Username=postgres;Password=123'
   export FileStorage__Azure__ConnectionString='<real azure blob connection string>'
   dotnet run --project MedicineDelivery.API --urls http://localhost:5000
   ```
   > The app's `appsettings.Development.json` points at the shared **Azure** test DB by
   > default — the `ConnectionStrings__PostgresConnection` override above is what pins it
   > to local Postgres so this script can seed freely without touching the shared env.
3. `pip install psycopg2-binary`

## Run

```bash
python Playright/functional/validate_functional.py
```

Exit code `0` = all checks passed, `1` = at least one failed, `2` = backend unreachable.

## Config (env overrides)

`API_BASE` (default `http://localhost:5000`), `PGHOST/PGPORT/PGDATABASE/PGUSER/PGPASSWORD`,
`ADMIN_MOBILE`/`ADMIN_PASSWORD`.

## How it seeds (and why via DB)

One state has **no public API** (it is driven by Razorpay in production), so the
harness writes it directly to the local DB: the chemist payout account
`OnboardingStatus = Active` + activation fee `Status = Paid` (§5 conditions 2 & 3).

Everything else goes through the real REST API — including payment: recording a
successful payment that covers the bill amount auto-sets the order to `FullyPaid`,
releases the OTP, and lets the delivery be completed, all through the API.

## Known backend findings surfaced by this script

- **`CancellationReason` migration drift** — `20260720150528_AddOrderCancellationReason`
  must be applied to whatever DB the API uses, or every order read 500s
  (`column o.CancellationReason does not exist`).
- **[FIXED]** `CompleteOrder` used to return 500 (not a clean 4xx) when payment wasn't
  `FullyPaid` — `OrdersController.CompleteOrder` now catches `PaymentIncompleteException`.
- **[FIXED]** `/api/users/register` & `/api/users/create-with-role` returned 500
  (`InvalidCastException` in `UserManagerService.CreateAsync`) — now write the Id via
  the `IApplicationUser` interface.
- **[FIXED]** Creating/updating a service region with a pin code already used by another
  region of the same type returned 500 — the controller now catches
  `InvalidOperationException` → 400.

## Relationship to the Playwright suite

This is the **business-flow** layer. The endpoint-contract suite (auth, CRUD, 401/403,
validation for ~110 endpoints) lives in `Playright/e2e/` and runs with
`npx playwright test --project=api`. The two are complementary.
