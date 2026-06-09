# Razorpay Route Split Payment — Implementation Plan

> Status: **PLANNING — awaiting review.** No code until approved.
> Companion to [`paymentRoutePlan.md`](./paymentRoutePlan.md) (design rationale).
> This document = the **build plan**: phased, with **Backend** and **Frontend** work
> segregated, ordered so each phase ships independently.

## Legend
- 🟦 **Backend** = `.NET 8` (`Backend/MedicineDelivery/…`)
- 🟩 **Frontend-Web** = React WebApp (`WebApp/…`) — Admin/Chemist (chemist is a web role)
- 🟪 **Frontend-Mobile** = Flutter (`Flutter_UI/…`) — Customer payment
- ⚙️ **Ops** = Razorpay dashboard / config, no code

## Phase map (ship order)

| Phase | Theme | Blocks on |
|-------|-------|-----------|
| **0** | Prerequisites & config | Razorpay Route approval |
| **1** | Chemist linked-account onboarding | Phase 0 |
| **2** | Order payment + split | Phase 1 (≥1 active chemist) |
| **3** | Webhooks, reconciliation, admin reporting | Phase 2 |

> **Hard external blocker:** Razorpay **Route enabled** on the Pharmaish account (RBI
> eligibility + payer-payee transparency). The split rule is now defined (flat Platform
> Technology Fee by **order value** — slab in Phase 2), so it no longer blocks Phase 2.

---

# PHASE 0 — Prerequisites & Configuration

### ⚙️ Ops
- [ ] Request/confirm **Razorpay Route** enabled on the Pharmaish account (RBI turnover
      eligibility + payer-payee transparency).
- [ ] Obtain **test-mode** keys; confirm Route APIs callable in test.

### 🟦 Backend
- [ ] Extend `RazorpaySettings` in `appsettings.json` + a typed `RazorpayOptions` class:
      `RouteEnabled` (kill-switch), `ConvenienceFee`, `TransferOnHold`, `ActivationFee` (14999), `ActivationGstPercent` (18).
- [ ] Bind options via DI (`IOptions<RazorpayOptions>`); inject where needed.
- [x] Add a Razorpay Route API client/wrapper (HttpClient) registered in DI. **(built — `RazorpayRouteClient`)**

**DoD:** config loads; `RouteEnabled=false` ⇒ system behaves exactly as today.

---

# PHASE 1 — Chemist Linked-Account Onboarding

**Goal:** every payable chemist has an **Active** Razorpay linked account (`acc_XXXX`)
backed by bank + KYC. Prerequisite for any split.

## 🟦 Backend

### Domain (`MedicineDelivery.Domain`)
- [x] New enum `ChemistPayoutStatus` (`NotStarted/Pending/NeedsClarification/Active/Rejected/Suspended`). **(built)**
- [x] New entity `ChemistPayoutAccount` (FK `MedicalStoreId`, `RazorpayLinkedAccountId`,
      `RazorpayStakeholderId`, `RazorpayProductConfigurationId`, `BankAccountNumber`, `BankIfscCode`,
      `BankAccountHolderName`, `OnboardingStatus`, `OnboardingError`, `ActivatedOn`, audit fields). **(built)**
- [ ] **Activation fee:** new entity `ChemistActivationPayment` (`MedicalStoreId`, `Amount`,
      `Gst`, `GatewayCharges?`, `RazorpayPaymentLinkId`, `RazorpayPaymentId?`, `Status`
      `Created/Paid/Failed/Expired`, `CreatedOn`, `PaidOn?`) + enum `ChemistActivationStatus`.

### Application (`MedicineDelivery.Application`)
- [ ] DTOs (record, `Dto` suffix): `OnboardChemistPayoutDto`, `ChemistPayoutStatusDto`,
      `UpdateChemistBankDto`.
- [ ] Interface `IChemistPayoutService`.
- [ ] CQRS (per layer rules): `Features/ChemistPayout/Commands/OnboardChemistPayout/…`,
      `…/Commands/UpdateChemistBank/…`, `Features/ChemistPayout/Queries/GetChemistPayoutStatus/…`.
- [ ] Validators (FluentValidation): IFSC format, account number, required KYC fields.

### Infrastructure (`MedicineDelivery.Infrastructure`)
- [ ] `ChemistPayoutAccountConfiguration` (Fluent API) in `Data/Configurations/`.
- [ ] EF migration `AddChemistPayoutAccount` (never edited post-creation).
- [ ] `ChemistPayoutService : IChemistPayoutService` implementing the **4-step Razorpay
      onboarding**: create account → create stakeholder → request `route` product →
      submit bank details; persist `acc_XXXX`/status.
- [ ] Map inputs from existing `MedicalStore` (name, email, PAN, GSTIN, address) + new bank fields.
- [ ] Register service + Route client in DI.

### API (`MedicineDelivery.API`)
- [x] `ChemistPayoutController` (thin): `onboard` / `status` / `bank` endpoints. **(built — reuses existing `ChemistRead`/`ChemistUpdate` policies; no plain CQRS — service-based like `RazorpayController`)**
- [ ] **Activation fee endpoints:** `POST /api/chemist-payout/{storeId}/activation-link`
      (generate Razorpay Payment Link), `GET .../activation` (status).

### Activation fee (₹14,999 + 18% GST via Razorpay Payment Links) — 🟦 new
- [ ] `IChemistActivationService` + impl: create Payment Link (amount = fee + GST), persist `ChemistActivationPayment`.
- [ ] **Webhook** `payment_link.paid` → set `Status=Paid`, stamp `MedicalStore.ActivatedOn` (anchors the 30-day-free window).
- [ ] EF migration `AddChemistActivationPayment`.
- [ ] Config: `RazorpaySettings:ActivationFee` (14999) + `ActivationGstPercent` (18).

### Tests
- [ ] Unit: service mapping + status transitions (mock Route client).
- [ ] Integration (SpecFlow): onboard happy-path → status `Active`, `acc_XXXX` stored.
- [ ] Activation: payment-link generated; `payment_link.paid` webhook sets `ActivatedOn`.

## 🟪 Frontend-Mobile (Flutter — Pharmacy onboarding)
> Pharmacy registration + pricing live in the **Flutter** app (`TransparentPricingDialog` →
> `registerPharmacist`), not React. So Phase-1 onboarding UI is mobile.
- [x] **Transparent Pricing dialog** showing ₹14,999 + GST + slab. **(built — `transparent_pricing_dialog.dart`)**
- [ ] ⚠️ **Fix the slab table** in that dialog: it currently shows *"Monthly Successfully
      Completed Orders" / "First Month After Activation"*; change to **order-value bands**
      (₹0–200 → ₹5 …) with **first-30-days-free**.
- [ ] **Activation payment**: open the Razorpay Payment Link (checkout/`url_launcher`), then
      poll/confirm activation status.
- [ ] **Payout bank form**: bank account no, IFSC, holder → `POST .../onboard`; show `OnboardingStatus`.

## 🟩 Frontend-Web (React — Admin oversight)
- [ ] Admin: list chemists with **activation** + **payout** status columns; filter "not onboarded".
- [ ] (Optional) Admin "resubmit bank details" / view Razorpay onboarding errors.

**Phase 1 DoD:** chemist pays ₹14,999 activation (test) → `ActivatedOn` stamped → onboarded
end-to-end → `Active` + `acc_XXXX`; status visible to admin.

---

# PHASE 2 — Order Payment & Split

**Goal:** customer pays bill + convenience fee (full amount captured into Pharmaish);
the ₹100 base split to the chemist linked account via **transfer-after-capture**.

> Needs Phase 1 (active chemist) **and** the **split formula**. Fallback (§ below) lets it
> ship before all chemists are onboarded.

## 🟦 Backend

### Domain
- [ ] `Order`: add `BillAmount` (decimal?), `ConvenienceFee` (decimal?). `TotalAmount`
      stays = final payable.
- [ ] New entity `PaymentSplit` (`OrderId`, `RazorpayPaymentId`, `TotalCaptured`,
      `BillAmount`, `ConvenienceFee`, `ChemistAmount`, `PharmaishAmount`,
      `RazorpayTransferId`, `ChemistLinkedAccountId`, `TransferStatus`, `CreatedAt`).
- [ ] Enum `TransferStatus` (`Pending/Completed/Failed/Skipped`).

### Application
- [ ] Interface `IPlatformFeeCalculator` — computes the flat **Platform Technology Fee by
      order value** (slab) + 30-day-free rule. `chemistAmount = orderValue − fee`.
- [ ] Update `RazorpayCreateOrderDto` only if needed (keep full-amount contract).
- [ ] `RecordPaymentDto` / mapping unchanged; add `PaymentSplitDto` for reporting.

**Platform Technology Fee slab (order-value based, flat ₹ per order):**

| Order value (₹) | Fee |
|-----------------|----:|
| First 30 days after activation | ₹0 (free) |
| 0 – 200 | ₹5 |
| 201 – 500 | ₹10 |
| 501 – 1,500 | ₹15 |
| 1,501 – 3,000 | ₹20 |
| 3,001 – 5,000 | ₹50 |
| Above 5,000 | ₹100 |

> Fee is applied to the **bill amount** (order/medicine value), not the ₹120 final payable.
> Free period = first **30 days** after `store.ActivatedOn`.

### Infrastructure
- [ ] `PlatformFeeCalculator : IPlatformFeeCalculator` (pure, unit-testable); slab boundaries
      config/table-driven (no magic numbers), 30-day-free in code.
- [ ] `PaymentSplitConfiguration` + EF migration `AddPaymentSplit` and `AddOrderAmountBreakup`.
- [ ] `MedicalStore.ActivatedOn` (or reuse existing activation date) + migration — anchors the 30-day-free window.
- [ ] Extend `RazorpayService.VerifyAndCapturePaymentAsync`:
  1. load Order → store → `ChemistPayoutAccount`;
  2. `platformFee = feeCalculator.Fee(order.BillAmount, store.ActivatedOn)`; `chemistAmount = order.BillAmount − platformFee`;
  3. if linked account `Active` → Razorpay **Transfers API** on the captured payment →
     record `trf_XXXX`, `TransferStatus=Completed`; **else** `Skipped` (fallback);
  4. write `PaymentSplit` (incl. `PlatformFee`); record `Payment` (full) as today; single transaction.
- [ ] Honor `RouteEnabled` kill-switch (false ⇒ no transfer, current behavior).
- [ ] Decimal math; convert to paise only at Razorpay boundary.

### API
- [ ] No change to `create-order` / `verify-payment` contracts (split is internal).
- [ ] (Optional) `GET /api/orders/{id}/payment-split` for reporting.

### Fallback (un-onboarded chemist)
- [ ] If no active linked account: capture full, `TransferStatus=Skipped`, still record
      intended `ChemistAmount`/`PharmaishAmount`, log warning + admin flag.

### Tests
- [ ] Unit: `PlatformFeeCalculator` — every slab boundary (200/500/1500/3000/5000), above-5000, and 30-day-free.
- [ ] Integration: verify-payment → correct `PaymentSplit`; transfer success; skipped
      fallback; kill-switch off path.

## 🟪 Frontend-Mobile (Flutter — Customer)
- [ ] Fetch/derive **convenience fee** (server-driven preferred) and **display the breakdown**
      on the payment summary: bill + convenience fee = final. **(already implemented in `payment_summary_page.dart`)**
- [x] Call `create-order` with the **final** amount (e.g. ₹120) — built in
      `payment_summary_page.dart` / `payment_service.dart` (`razorpay_flutter` checkout). **(built)**
- [x] No change to verify-payment handling; success only after server 200. **(built)**

> Phase 2 Flutter is essentially done — the split is server-side and invisible to the customer.

## 🟩 Frontend-Web
- None required for the customer flow. (Reporting view optional — see Phase 3.)

**Phase 2 DoD:** test payment of ₹120 → ₹100-base split: chemist linked account credited,
remainder retained, `PaymentSplit` row correct; fallback + kill-switch verified.

---

# PHASE 3 — Webhooks, Reconciliation & Admin Reporting

**Goal:** make settlement observable and self-healing.

## 🟦 Backend
- [ ] Razorpay **webhook endpoint** (`POST /api/razorpay/webhook`) with signature verification.
- [ ] Handle: `payment.captured` (reconcile if client never verified), `transfer.processed`
      / `transfer.failed` (update `PaymentSplit.TransferStatus`), `account.activated`
      (flip chemist onboarding status from Phase 1).
- [ ] **Retry queue** for failed transfers + admin notification.
- [ ] Reconciliation job: settle `TransferStatus=Skipped` once a chemist becomes `Active`.
- [ ] Reporting queries: platform revenue, chemist settlements, pending/failed transfers.

## 🟩 Frontend-Web (Admin)
- [ ] Settlement dashboard: per-order split, transfer status, retry action.
- [ ] Chemist payout report (amounts owed/settled), CSV export.

## 🟪 Frontend-Mobile
- None.

**Phase 3 DoD:** webhook-driven status updates; failed transfers retried/visible; admin
can reconcile.

---

# Backend ↔ Frontend dependency view

```
PHASE 1   🟦 ChemistPayoutAccount + onboarding API ──► 🟩 Web onboarding form/status
PHASE 2   🟦 split in VerifyAndCapture + PaymentSplit ─► 🟪 Flutter shows convenience fee
          (fee = order-value slab; calculator is self-contained, nothing blocked)
PHASE 3   🟦 webhooks/reconciliation ────────────────► 🟩 Web settlement dashboard
```

# Cross-cutting checklist
- [ ] `dotnet build` + `dotnet test` clean each phase.
- [ ] `npm run lint` / `npm run build` (web), `flutter analyze` (mobile) clean.
- [ ] All amounts **decimal** server-side; paise only at Razorpay edge.
- [ ] No business logic in controllers; services/handlers per layer rules.
- [ ] Migrations never edited after creation.

# Open decisions (carry-over)
1. ~~**Split formula**~~ — **RESOLVED:** flat Platform Technology Fee by **order value** (slab above);
   chemist gets the remainder. Slab applies to the **bill amount** (₹100, not the ₹120 payable);
   free period = first **30 days** after store activation.
2. **Convenience fee** (frontend: *"Convenience / Payment Processing Fee"*): fixed ₹20 / % / server-driven (recommend server-driven).
3. **Onboarding model**: API onboarding (we collect bank) vs Razorpay-hosted link.
4. **Hold funds**: immediate transfer vs `on_hold` until delivery/OTP.
5. **Refunds**: reverse-transfer policy on post-transfer refund.
