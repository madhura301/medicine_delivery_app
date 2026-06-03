# Razorpay Route — Split Payment Plan (Phased)

> Status: **PLANNING — awaiting review.** No code is written until approved.
> Supersedes the split sections of [`paymentImplemendation.md`](./paymentImplemendation.md).
> Builds on the working single-account flow in [`paymentplan.md`](./paymentplan.md).

## Goal (in one picture)

```
Customer pays  ₹120  =  bill ₹100  +  ₹20 handling charge (added by frontend)
        │
        ▼  full ₹120 captured into the PHARMAISH (platform) Razorpay account
        │
        ├─ Razorpay Route transfer → CHEMIST linked account  (chemist's share of the ₹100)
        │
        └─ remainder stays in Pharmaish  (₹20 handling + Pharmaish's share of ₹100)
               └─ Razorpay debits its gateway + transfer fees from Pharmaish
```

- The **₹100 base** is split between chemist and Pharmaish **by a formula (TBD — you'll share)**.
- The **₹20 handling charge** stays with Pharmaish (covers Razorpay fees + margin).
- Splitting is done natively by **Razorpay Route** (Linked Accounts + Transfers).

We deliver this in **two phases**:
- **Phase 1 — Chemist:** capture chemist account info and create their Razorpay **Linked Account**. Nothing can be split until this exists.
- **Phase 2 — Order:** add the handling charge, capture the full amount, and split via Route.

---

# PHASE 1 — Chemist (Linked Account) Onboarding

**Objective:** every chemist who should receive money has a Razorpay **Linked Account**
(`acc_XXXX`) on the Pharmaish platform account, backed by their bank + KYC details.

> **Why first:** Route transfers can only target an *active* linked account. Until a
> chemist is onboarded, their orders can be captured but **not** split. So this phase is
> the hard prerequisite for Phase 2.

## 1.1 What we have today

[`MedicalStore`](../Backend/MedicineDelivery/MedicineDelivery.Domain/Entities/MedicalStore.cs)
already stores most KYC-adjacent data:
- `MedicalName`, owner name, full address, `City`, `State`, `PostalCode`
- `EmailId`, `MobileNumber`
- `GSTIN` (nullable), `PAN`, `DLNo` (drug licence), `FSSAINo`
- `RegistrationStatus`, `IsActive`, `UserId`

**Missing for payouts:** bank account number, IFSC, account-holder name, the Razorpay
`linkedAccountId`, and an onboarding status.

## 1.2 Data model changes

**New entity: `ChemistPayoutAccount`** (keep bank data isolated from `MedicalStore`).

| Field | Type | Purpose |
|-------|------|---------|
| `Id` | int PK | |
| `MedicalStoreId` | Guid FK → MedicalStore | one payout config per store |
| `RazorpayLinkedAccountId` | string? | `acc_XXXX`; null until created |
| `RazorpayStakeholderId` | string? | `sth_XXXX` from stakeholder step |
| `BankAccountNumber` | string? | |
| `BankIfscCode` | string? | |
| `BankAccountHolderName` | string? | should match PAN/legal name |
| `OnboardingStatus` | enum `ChemistPayoutStatus` | `NotStarted / Pending / NeedsClarification / Active / Rejected / Suspended` |
| `OnboardingError` | string? | last error/reason from Razorpay |
| `ActivatedOn` | DateTime? | when linked account became usable |
| `CreatedOn` / `UpdatedOn` | DateTime | audit |

**New enum:** `ChemistPayoutStatus` (in `Domain/Enums`).

Per backend rules: new entity → Fluent config in `Infrastructure/Data/Configurations/`,
new EF migration (never edited after creation).

## 1.3 Razorpay linked-account creation (the 4-step onboarding)

From the Route docs, creating an active linked account is a sequence:

1. **Create Linked Account** — `POST /v2/accounts` with business email, name, type,
   legal/business details → returns `account_id` (`acc_XXXX`).
2. **Create Stakeholder** — `POST /v2/accounts/{accId}/stakeholders` (owner/PAN details)
   → returns `stakeholder_id`.
3. **Request Route product configuration** — `POST /v2/accounts/{accId}/products`
   (product = `route`).
4. **Update product config with bank details** — supply bank account no + IFSC so the
   account can be settled to → moves the account toward `Active`.

We map most inputs from `MedicalStore` (name, email, PAN, GSTIN, address) plus the new
bank fields from `ChemistPayoutAccount`.

> **Prerequisite (ops, not code):** Razorpay **Route must be enabled** on the Pharmaish
> account (RBI turnover eligibility + payer-payee transparency). Confirm before building.

## 1.4 New backend surface

**Service:** `IChemistPayoutService` (Application interface) + `ChemistPayoutService`
(Infrastructure impl) wrapping the Razorpay onboarding calls and persisting results.

**Endpoints (new `ChemistPayoutController`):**
- `POST /api/chemist-payout/{storeId}/onboard` — submit bank + KYC; runs the 4-step
  creation; stores `RazorpayLinkedAccountId` + status. `[Authorize]` (Admin/Chemist).
- `GET  /api/chemist-payout/{storeId}` — current onboarding status + masked bank info.
- `PUT  /api/chemist-payout/{storeId}/bank` — update/correct bank details (re-submit).

**Webhook (optional but recommended):** Razorpay `account.activated` /
`account.needs_clarification` → flip `OnboardingStatus`. (Webhook infra is shared with
Phase 2 — see §2.7.)

## 1.5 Phase 1 — definition of done

- [ ] Route enabled on Pharmaish account (ops).
- [ ] `ChemistPayoutAccount` entity + `ChemistPayoutStatus` enum + EF config + migration.
- [ ] `IChemistPayoutService` + impl (4-step Razorpay onboarding).
- [ ] `ChemistPayoutController` endpoints.
- [ ] (Optional) `account.activated` webhook handling.
- [ ] At least one chemist onboarded end-to-end in **test mode** → status `Active`,
      `acc_XXXX` stored.
- [ ] Unit/integration coverage for the service mapping + status transitions.

---

# PHASE 2 — Order Payment & Split

**Objective:** customer pays bill + handling charge; full amount captured into Pharmaish;
the base bill split between chemist (linked account) and Pharmaish via Route.

> Depends on Phase 1: a chemist must have an `Active` linked account for the transfer to
> execute. Fallback handles the not-yet-onboarded case (§2.5).

## 2.1 Amounts & terminology

| Term | Example | Owned by |
|------|---------|----------|
| Bill / Medicine amount | ₹100 | base value, set from the uploaded bill |
| Handling charge | ₹20 | added by **frontend**, stays with Pharmaish |
| Final payable | ₹120 | what the customer pays |
| Chemist share | TBD (formula on ₹100) | → chemist linked account |
| Pharmaish share | ₹20 + (₹100 − chemist share) | stays in Pharmaish |
| Razorpay fees | ~2% PG fee on ₹120 + transfer fee + GST | debited from Pharmaish |

> **OPEN — split formula:** the rule that divides the **₹100 base** between chemist and
> Pharmaish is still pending from you. Until then, Phase 2 code uses a single injection
> point (`IPlatformShareCalculator`) so the formula can drop in without touching the flow.

## 2.2 Frontend (Flutter) changes — minimal

- Compute and **display** `final = billAmount + handlingCharge` (handling charge from
  config/server). Customer sees the breakdown.
- Call `create-order` with the **final** amount (₹120) — unchanged contract.
- Rest of the Razorpay checkout/verify flow is exactly as in [`paymentplan.md`](./paymentplan.md).

> Decision: is the **handling charge** a fixed ₹20, a %, or server-driven? Recommend the
> server returns it (single source of truth) so it can change without an app release.

## 2.3 Data model changes

**`Order`** ([entity](../Backend/MedicineDelivery/MedicineDelivery.Domain/Entities/Order.cs))
— add line-item clarity (today there's only `TotalAmount`):
- `BillAmount` (decimal?) — the ₹100 base.
- `HandlingCharge` (decimal?) — the ₹20.
- `TotalAmount` continues to hold the final payable (₹120).

**New entity: `PaymentSplit`** (audit of every split, one per captured payment):

| Field | Type |
|-------|------|
| `Id` | int PK |
| `OrderId` | int FK → Order |
| `RazorpayPaymentId` | string (`pay_XXXX`) |
| `TotalCaptured` | decimal (₹120) |
| `BillAmount` | decimal (₹100) |
| `HandlingCharge` | decimal (₹20) |
| `ChemistAmount` | decimal (→ linked account) |
| `PharmaishAmount` | decimal (retained) |
| `RazorpayTransferId` | string? (`trf_XXXX`) |
| `ChemistLinkedAccountId` | string? (`acc_XXXX`) |
| `TransferStatus` | enum `Pending / Completed / Failed / Skipped` |
| `CreatedAt` | DateTime |

## 2.4 Backend flow — extend `VerifyAndCapturePaymentAsync`

In [`RazorpayService`](../Backend/MedicineDelivery/MedicineDelivery.Infrastructure/Services/RazorpayService.cs),
after the existing HMAC verify + mark-Paid:

```
1. Load Order → MedicalStoreId → ChemistPayoutAccount.
2. chemistAmount = IPlatformShareCalculator.ChemistShare(order.BillAmount)   // formula TBD
3. If chemist linked account is Active:
     - Razorpay Transfers API on the captured payment:
         transfer chemistAmount → acc_XXXX
     - record trf_XXXX, TransferStatus = Completed
   Else:
     - TransferStatus = Skipped   (see §2.5)
4. Write PaymentSplit row (always).
5. Record Payment (existing) for the full captured amount.
6. SaveChanges (single transaction).
```

- **Transfer method:** *transfer-from-payment* (after capture) — lets us compute the
  split server-side with the final formula. (Alternative: `transfers[]` at order
  creation; not chosen because the split is computed later.)
- All money math in **decimal**; convert to **paise** only at the Razorpay boundary
  (mirrors existing `amount * 100`).
- `IPlatformShareCalculator` lives in Application (interface) + Infrastructure (impl);
  keeps the formula unit-testable and out of `RazorpayService`.

## 2.5 Fallback — chemist not yet onboarded

If `ChemistPayoutAccount` is missing or `OnboardingStatus != Active`:
- **Still capture the full payment** (customer unaffected).
- **Skip** the transfer; `TransferStatus = Skipped`.
- Still record the intended `ChemistAmount` / `PharmaishAmount` in `PaymentSplit` so the
  amount owed to the chemist is known and can be settled later (retro-transfer or manual).
- Log a warning + optional admin alert.

> This lets Phase 2 ship and run even before every chemist is onboarded.

## 2.6 Configuration

Extend `RazorpaySettings` in `appsettings.json`:

```jsonc
"RazorpaySettings": {
  "KeyId": "rzp_test_xxx",
  "KeySecret": "xxx",
  "Currency": "INR",
  "RouteEnabled": true,        // master kill-switch: false => behave as today (no split)
  "HandlingCharge": 20,        // server-driven handling charge (or % — TBD §2.2)
  "TransferOnHold": false      // optionally hold chemist funds until delivery/OTP
}
```

## 2.7 Webhooks (shared infra)

- `payment.captured` → safety net to reconcile if the client never calls verify.
- `transfer.processed` / `transfer.failed` → update `PaymentSplit.TransferStatus`;
  failed → retry queue + admin notify.
- (Phase 1) `account.activated` → flip chemist onboarding status.

## 2.8 Phase 2 — definition of done

- [ ] `Order.BillAmount` + `Order.HandlingCharge` + migration.
- [ ] `PaymentSplit` entity + EF config + migration.
- [ ] `IPlatformShareCalculator` + impl (drop in formula once provided).
- [ ] Razorpay Transfers API integration in `RazorpayService`.
- [ ] `VerifyAndCapturePaymentAsync` extended (§2.4) + fallback (§2.5).
- [ ] `RazorpaySettings` additions + `RouteEnabled` kill-switch honored.
- [ ] Flutter: show handling charge, send final amount.
- [ ] Webhooks for transfer status.
- [ ] Tests: split calc, transfer success, skipped-fallback, kill-switch off.

---

## Open questions (carry-over)

1. **Split formula** for the ₹100 base (chemist vs Pharmaish) — the one true blocker.
2. **Handling charge**: fixed ₹20, percentage, or server-driven? (§2.2)
3. **Route eligibility**: is Pharmaish approved for Route by Razorpay yet? (§1.3)
4. **Onboarding model**: API onboarding (we collect bank + IFSC) vs Razorpay-hosted link.
5. **Hold until delivery**: transfer immediately on capture, or `on_hold` until OTP/delivery?
6. **Refunds/cancellations**: reverse-transfer policy if an order is refunded post-transfer.

## Sequencing summary

```
Phase 1 (Chemist)                         Phase 2 (Order)
─────────────────                         ───────────────
Route enabled (ops)                       Order amount fields + handling charge
ChemistPayoutAccount + status      ──►     PaymentSplit + share calculator
Linked-account onboarding service          Transfer-after-capture in RazorpayService
Onboard ≥1 chemist (test) = Active         Fallback for un-onboarded chemists
                                           Webhooks + admin reconciliation
```
