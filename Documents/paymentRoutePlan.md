# Razorpay Route — Split Payment Plan (Phased)

> Status: **PLANNING — awaiting review.** No code is written until approved.
> Supersedes the split sections of [`paymentImplemendation.md`](./paymentImplemendation.md).
> Builds on the working single-account flow in [`paymentplan.md`](./paymentplan.md).

## Goal (in one picture)

```
Customer pays  ₹120  =  bill ₹100  +  ₹20 convenience fee (added by frontend)
        │
        ▼  full ₹120 captured into the PHARMAISH (platform) Razorpay account
        │
        ├─ Razorpay Route transfer → CHEMIST linked account  (chemist's share of the ₹100)
        │
        └─ remainder stays in Pharmaish  (₹20 convenience fee + Pharmaish's share of ₹100)
               └─ Razorpay debits its gateway + transfer fees from Pharmaish
```

- The **₹100 base** is split: Pharmaish keeps a **Platform Technology Fee** decided by the
  **order value** (see [slab table](#platform-technology-fee-slab-order-value-based)); the
  chemist gets the rest. (e.g. ₹100 order → ₹5 fee → chemist ₹95.)
- The **₹20 convenience fee** stays with Pharmaish (covers Razorpay fees + margin).
- Splitting is done natively by **Razorpay Route** (Linked Accounts + Transfers).

We deliver this in **two phases**:
- **Phase 1 — Chemist:** capture chemist account info and create their Razorpay **Linked Account**. Nothing can be split until this exists.
- **Phase 2 — Order:** add the convenience fee, capture the full amount, and split via Route.

## Frontend status & known discrepancies (as of this revision)

What the Flutter app already implements:
- ✅ **Customer payment** (`payment_summary_page.dart`): `medicinesTotal + convenienceFee (₹20)`
  → `create-order` with the full total → `razorpay_flutter` checkout → server `verify-payment`.
  Matches Phase 2's customer flow; the Phase 2 Flutter work is largely done.
- ✅ Razorpay models / `payment_service.dart` match the backend contract.
- ✅ **Pricing dialog** (`transparent_pricing_dialog.dart`) advertises the **₹14,999 + GST**
  onboarding fee (now in scope — see §1.5) and the platform-fee slab.

⚠️ **Frontend follow-ups needed (code change, not docs):**
- The pricing dialog shows the slab as **"Monthly Successfully Completed Orders"** with
  **"First Month After Activation"**. Per the confirmed rule it must be **order-value based**
  (₹0–200 → ₹5 …) with a **first-30-days-free** window. Update the dialog's table + caption.
- Terminology in docs aligned to the frontend's **"Convenience / Payment Processing Fee"**.

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

## 1.5 Chemist activation fee — ₹14,999 + 18% GST (Razorpay Payment Links)

The Flutter **Transparent Pricing** dialog (`transparent_pricing_dialog.dart`) advertises a
**one-time Platform Onboarding Fee of ₹14,999 + 18% GST** (+ gateway charges as applicable)
to pharmacies at registration. We collect it via **Razorpay Payment Links** (a separate
Razorpay product from Route — no linked account needed to charge it).

**Flow:** chemist registers → (KYC/approval) → generate Payment Link for ₹14,999 + GST →
chemist pays → `payment_link.paid` webhook → mark store activated → proceed to linked-account
onboarding (§1.3). Activation gates "go-live"; the ₹0 first-30-days fee window (Phase 2) is
anchored on this activation date.

- **New entity `ChemistActivationPayment`:** `Id`, `MedicalStoreId`, `Amount`, `Gst`,
  `GatewayCharges?`, `RazorpayPaymentLinkId`, `RazorpayPaymentId?`, `Status`
  (`Created/Paid/Failed/Expired`), `CreatedOn`, `PaidOn?`.
- **Service/endpoint:** `POST /api/chemist-payout/{storeId}/activation-link` → returns a
  Razorpay Payment Link URL; `GET .../activation` → status.
- **Webhook:** `payment_link.paid` → set `Status=Paid`, stamp `MedicalStore.ActivatedOn`.
- **Config:** `RazorpaySettings:ActivationFee` (14999) + `ActivationGstPercent` (18).

> Status: **not yet implemented** — the linked-account onboarding (§1.2–1.4) is built; this
> activation-fee stream is newly added to scope (per the frontend) and still to be built.

## 1.6 Phase 1 — definition of done

- [ ] Route enabled on Pharmaish account (ops).
- [ ] `ChemistPayoutAccount` entity + `ChemistPayoutStatus` enum + EF config + migration.
- [ ] `IChemistPayoutService` + impl (4-step Razorpay onboarding).
- [ ] `ChemistPayoutController` endpoints.
- [ ] (Optional) `account.activated` webhook handling.
- [ ] **Activation fee:** `ChemistActivationPayment` + Payment Links generation + `payment_link.paid` webhook + sets `ActivatedOn`.
- [ ] At least one chemist onboarded end-to-end in **test mode** → status `Active`,
      `acc_XXXX` stored.
- [ ] Unit/integration coverage for the service mapping + status transitions.

---

# PHASE 2 — Order Payment & Split

**Objective:** customer pays bill + convenience fee; full amount captured into Pharmaish;
the base bill split between chemist (linked account) and Pharmaish via Route.

> Depends on Phase 1: a chemist must have an `Active` linked account for the transfer to
> execute. Fallback handles the not-yet-onboarded case (§2.5).

## 2.1 Amounts & terminology

| Term | Example | Owned by |
|------|---------|----------|
| Bill / Medicine amount (order value) | ₹100 | base value, set from the uploaded bill |
| Convenience fee | ₹20 | added by **frontend**, stays with Pharmaish |
| Final payable | ₹120 | what the customer pays |
| Platform Technology Fee | ₹5 (slab for a ₹100 order) | stays in Pharmaish |
| Chemist share | ₹100 − ₹5 = ₹95 | → chemist linked account |
| Pharmaish share | ₹20 + ₹5 = ₹25 | stays in Pharmaish |
| Razorpay fees | ~2% PG fee on ₹120 + transfer fee + GST | debited from Pharmaish |

### Platform Technology Fee slab (order-value based)

The Platform Technology Fee is a **flat ₹ amount per order, decided by the order value**
(the bill/medicine amount). It is **not** a percentage and **not** based on monthly order
counts.

| Order value (₹) | Platform Technology Fee |
|-----------------|------------------------:|
| First 30 days after activation | **Free (₹0)** |
| 0 – 200      | ₹5   |
| 201 – 500    | ₹10  |
| 501 – 1,500  | ₹15  |
| 1,501 – 3,000| ₹20  |
| 3,001 – 5,000| ₹50  |
| Above 5,000  | ₹100 |

So: `platformFee = slab(order value)`, `chemistAmount = orderValue − platformFee`.

**Confirmed rules:**
- The slab is applied to the **bill amount** (the order/medicine value, e.g. ₹100) — **not**
  the final payable (₹120).
- The free grace period is the **first 30 days after the chemist's store activation date**
  (i.e. `order.CreatedOn <= store.ActivatedOn + 30 days` ⇒ fee ₹0).

> Implemented behind a single injection point (`IPlatformFeeCalculator`) so the slab
> values / 30-day-free rule can change without touching the payment flow.

## 2.2 Frontend (Flutter) changes — minimal

- Compute and **display** `final = billAmount + convenienceFee` (convenience fee from
  config/server). Customer sees the breakdown.
- Call `create-order` with the **final** amount (₹120) — unchanged contract.
- Rest of the Razorpay checkout/verify flow is exactly as in [`paymentplan.md`](./paymentplan.md).

> Decision: is the **convenience fee** a fixed ₹20, a %, or server-driven? Recommend the
> server returns it (single source of truth) so it can change without an app release.

## 2.3 Data model changes

**`Order`** ([entity](../Backend/MedicineDelivery/MedicineDelivery.Domain/Entities/Order.cs))
— add line-item clarity (today there's only `TotalAmount`):
- `BillAmount` (decimal?) — the ₹100 base.
- `ConvenienceFee` (decimal?) — the ₹20.
- `TotalAmount` continues to hold the final payable (₹120).

**New entity: `PaymentSplit`** (audit of every split, one per captured payment):

| Field | Type |
|-------|------|
| `Id` | int PK |
| `OrderId` | int FK → Order |
| `RazorpayPaymentId` | string (`pay_XXXX`) |
| `TotalCaptured` | decimal (₹120) |
| `BillAmount` | decimal (₹100) — order value used for the slab |
| `ConvenienceFee` | decimal (₹20) |
| `PlatformFee` | decimal (₹5) — slab fee on the order value |
| `ChemistAmount` | decimal (→ linked account) = BillAmount − PlatformFee |
| `PharmaishAmount` | decimal (retained) = ConvenienceFee + PlatformFee |
| `RazorpayTransferId` | string? (`trf_XXXX`) |
| `ChemistLinkedAccountId` | string? (`acc_XXXX`) |
| `TransferStatus` | enum `Pending / Completed / Failed / Skipped` |
| `CreatedAt` | DateTime |

## 2.4 Backend flow — extend `VerifyAndCapturePaymentAsync`

In [`RazorpayService`](../Backend/MedicineDelivery/MedicineDelivery.Infrastructure/Services/RazorpayService.cs),
after the existing HMAC verify + mark-Paid:

```
1. Load Order → MedicalStoreId → ChemistPayoutAccount.
2. platformFee  = IPlatformFeeCalculator.Fee(order.BillAmount, store activation date)  // slab
   chemistAmount = order.BillAmount − platformFee
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
- `IPlatformFeeCalculator` lives in Application (interface) + Infrastructure (impl);
  keeps the order-value slab unit-testable and out of `RazorpayService`. Slab boundaries
  are config/table-driven (no magic numbers), with the 30-day-free rule in code.

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
  "ConvenienceFee": 20,        // server-driven convenience fee (or % — TBD §2.2)
  "TransferOnHold": false      // optionally hold chemist funds until delivery/OTP
}
```

## 2.7 Webhooks (shared infra)

- `payment.captured` → safety net to reconcile if the client never calls verify.
- `transfer.processed` / `transfer.failed` → update `PaymentSplit.TransferStatus`;
  failed → retry queue + admin notify.
- (Phase 1) `account.activated` → flip chemist onboarding status.

## 2.8 Phase 2 — definition of done

- [ ] `Order.BillAmount` + `Order.ConvenienceFee` + migration.
- [ ] `MedicalStore.ActivatedOn` (or reuse existing activation date) for the 30-day-free rule + migration.
- [ ] `PaymentSplit` entity + EF config + migration.
- [ ] `IPlatformFeeCalculator` + impl — order-value slab + 30-day-free; config/table-driven boundaries.
- [ ] Razorpay Transfers API integration in `RazorpayService`.
- [ ] `VerifyAndCapturePaymentAsync` extended (§2.4) + fallback (§2.5).
- [ ] `RazorpaySettings` additions + `RouteEnabled` kill-switch honored.
- [ ] Flutter: show convenience fee, send final amount.
- [ ] Webhooks for transfer status.
- [ ] Tests: split calc, transfer success, skipped-fallback, kill-switch off.

---

## Open questions (carry-over)

1. ~~**Split formula** for the ₹100 base~~ — **RESOLVED:** flat Platform Technology Fee by
   **order value** ([slab](#platform-technology-fee-slab-order-value-based)); chemist gets
   the rest. Confirmed: slab applies to the **bill amount** (₹100, not the ₹120 payable);
   free period = **first 30 days after store activation**.
2. **Convenience fee** (frontend calls it *"Convenience / Payment Processing Fee"*): fixed ₹20, percentage, or server-driven? (§2.2)
3. **Route eligibility**: is Pharmaish approved for Route by Razorpay yet? (§1.3)
4. **Onboarding model**: API onboarding (we collect bank + IFSC) vs Razorpay-hosted link.
5. **Hold until delivery**: transfer immediately on capture, or `on_hold` until OTP/delivery?
6. **Refunds/cancellations**: reverse-transfer policy if an order is refunded post-transfer.

## Sequencing summary

```
Phase 1 (Chemist)                         Phase 2 (Order)
─────────────────                         ───────────────
Route enabled (ops)                       Order amount fields + convenience fee
ChemistPayoutAccount + status      ──►     PaymentSplit + share calculator
Linked-account onboarding service          Transfer-after-capture in RazorpayService
Onboard ≥1 chemist (test) = Active         Fallback for un-onboarded chemists
                                           Webhooks + admin reconciliation
```
