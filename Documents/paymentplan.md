# Payment Integration Plan — Flutter (Razorpay, server-driven)

> Status: **PROPOSAL — awaiting review.** No code will be written until this is approved.

## 1. Goal

Wire the Flutter customer app into the **already-built backend Razorpay flow**, keeping
"maximum usage on the API side" as requested. The server does all the trust-sensitive work
(creating the Razorpay order, verifying the payment signature, recording the payment and
marking the order paid). The Flutter client only:

1. Asks the server to create a Razorpay order.
2. Opens the Razorpay checkout widget with the data the server returned.
3. Sends the three Razorpay result fields back to the server for verification.

The client never computes signatures, never decides the amount that gets recorded, and never
talks to Razorpay's REST API directly — it only opens the hosted checkout UI.

## 2. Backend contract (already implemented — for reference)

Base URL in Flutter already includes `/api` (`EnvironmentConfig.apiBaseUrl`), so relative
Dio paths are `/Razorpay/...`.

### `POST /api/Razorpay/create-order`  — `[Authorize]`
Request:
```json
{ "orderId": 45, "amount": 870.00 }
```
Response `200`:
```json
{ "razorpayOrderId": "order_Abc123", "amount": 870.00, "currency": "INR", "keyId": "rzp_test_xxx" }
```
- `keyId` is the **public** key — safe to use client-side to open checkout.
- `400` with `{ "message": "..." }` on validation/creation failure.

### `POST /api/Razorpay/verify-payment`  — `[Authorize]`
Request (the three fields come from the Razorpay success callback + our internal orderId):
```json
{
  "orderId": 45,
  "razorpayOrderId": "order_Abc123",
  "razorpayPaymentId": "pay_Xyz789",
  "razorpaySignature": "<hex signature>"
}
```
Response `200`: `{ "message": "Payment verified and recorded successfully." }`
Response `400`: `{ "message": "Payment verification failed. ..." }`
- Server re-computes `HMAC_SHA256(razorpayOrderId|razorpayPaymentId, keySecret)` and compares.
- On success it marks the `RazorpayOrder` as Paid and calls the existing `PaymentService`
  to record a `Payment` (amount taken from the **stored** order, not from the client).

> Net effect: the client cannot fake a payment or alter the recorded amount. Good.

## 3. Current Flutter state (what we're replacing)

- `lib/core/screens/payment/payment_summary_page.dart` — the live screen. Its `_handlePayment()`
  is a **stub**: it fabricates `TXN_...` and POSTs directly to `/Payments` with
  `paymentStatus: 1`, marking the order paid **without any real payment**. This must be
  replaced by the real Razorpay flow.
- `lib/core/screens/payment/payment_gateway_page.dart` — an older mock screen with a fake
  2-second delay. Unused (route is commented out). Proposal: leave as-is or delete (see Q4).
- Call sites of `PaymentSummaryPage` (constructor signature stays unchanged, so these keep working):
  - `customer_all_orders.dart` → `_goToPayment()` (real orders)
  - `app_routes.dart` → `paymentGateway` route
  - `order_tile_with_bill.dart` → `navigateToPayNowPage()` (hardcoded demo values)
  - `payment_summary_dialog.dart` → modal wrapper

## 4. The new client flow (sequence)

```
User taps "Pay Now"
  │
  ├─1─ POST /Razorpay/create-order { orderId, amount: totalAmount }
  │        └─ get { razorpayOrderId, amount, currency, keyId }
  │
  ├─2─ Razorpay.open({ key: keyId, order_id: razorpayOrderId,
  │                    amount: paise, currency, name, description, prefill })
  │        └─ user pays inside Razorpay's UI (UPI / card / netbanking handled there)
  │
  ├─3a─ EVENT_PAYMENT_SUCCESS (paymentId, orderId, signature)
  │        └─ POST /Razorpay/verify-payment { orderId, razorpayOrderId,
  │                                           razorpayPaymentId, razorpaySignature }
  │             ├─ 200 → show success dialog, call onPaymentSuccess()
  │             └─ 400 → show "verification failed" error
  │
  ├─3b─ EVENT_PAYMENT_ERROR (code, message)
  │        └─ show error / "cancelled" message; stay on page
  │
  └─3c─ EVENT_EXTERNAL_WALLET → (log only; success/error still arrive via the other events)
```

Important: the success dialog must only appear **after** step 3a's verify call returns `200`.
A Razorpay client-side success without a verified server response is not a confirmed payment.

## 5. Files to add / change

### 5.1 Dependency — `pubspec.yaml`
Add under `dependencies:`
```yaml
  # Payments
  razorpay_flutter: ^1.3.7
```
Then `flutter pub get`. (razorpay_flutter is the official package; mobile only — see Q3.)

### 5.2 Android platform config
- `android/app/build.gradle`: ensure `minSdkVersion >= 19` (project is already 21 — OK).
- `android/app/proguard-rules.pro` (only matters if/when minify is enabled) — add:
  ```
  -keep class com.razorpay.** { *; }
  -dontwarn com.razorpay.**
  -optimizations !method/inlining/*
  -keepclasseswithmembers class * { public void onPayment*(...); }
  ```
- No new runtime permissions required (checkout opens its own activity; internet already used).

### 5.3 iOS platform config
- No code change typically needed; `pod install` runs via the package. Confirm build on a Mac
  later (we develop on Windows, so iOS verification is deferred — see Q3).

### 5.4 New model — `lib/shared/models/razorpay_models.dart`
A small immutable class parsing the create-order response:
```dart
class RazorpayOrderResponse {
  final String razorpayOrderId;
  final double amount;     // rupees
  final String currency;   // "INR"
  final String keyId;      // public key
  factory RazorpayOrderResponse.fromJson(Map<String, dynamic> json) => ...
}
```
(Keys are camelCase from ASP.NET's default JSON serialization: `razorpayOrderId`, etc.)

### 5.5 New service — `lib/core/services/payment_service.dart`
Follows the existing static-method service pattern (`OrderService`, uses `DioClient.instance`):
```dart
class PaymentService {
  PaymentService._();
  static Dio get _dio => DioClient.instance;

  /// POST /Razorpay/create-order
  static Future<RazorpayOrderResponse> createRazorpayOrder({
    required int orderId, required double amount,
  }) async { ... }

  /// POST /Razorpay/verify-payment → true if server confirms (200)
  static Future<void> verifyPayment({
    required int orderId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async { ... }
}
```
Throws `DioException` on failure (callers handle UX), matching `OrderService`'s documented contract.

### 5.6 Rewrite — `lib/core/screens/payment/payment_summary_page.dart`
Keep the existing UI/layout (price card, security badges, disclaimers) and the **public
constructor unchanged** so all call sites keep working. Changes are internal:

- Add `late Razorpay _razorpay;` initialized in `initState()` with the three event listeners;
  `_razorpay.clear()` in `dispose()`.
- Replace `_handlePayment()` with:
  1. `setState(_isProcessing = true)`
  2. `final order = await PaymentService.createRazorpayOrder(orderId, totalAmount)`
  3. Store `_currentRazorpayOrderId = order.razorpayOrderId`
  4. `_razorpay.open({...})` with `amount` in **paise** (`(order.amount * 100).round()`),
     `order_id`, `key`, `currency`, `name: 'Pharmaish'`,
     `description: 'Order #${orderNumber ?? orderId}'`, optional `prefill` (customer email/phone).
- `_onPaymentSuccess(PaymentSuccessResponse r)`:
  - `await PaymentService.verifyPayment(orderId, _currentRazorpayOrderId!, r.paymentId!, r.signature!)`
  - on success → existing `_showSuccessDialog()`; on `DioException` → error snackbar.
  - reset `_isProcessing`.
- `_onPaymentError(PaymentFailureResponse r)`:
  - map common codes (e.g. user cancelled) to a friendly message; `AppSnackBar.error`; reset state.
- `_onExternalWallet(ExternalWalletResponse r)`: log only.
- Remove the fake `TXN_...` / direct `/Payments` POST path entirely.

Notes:
- The in-app UPI / Card / NetBanking selector currently in the UI is **cosmetic** under this
  flow — the real method is chosen inside the Razorpay sheet. We can either (a) drop the selector,
  or (b) keep it and pass the choice as a Razorpay `method`/`prefill` hint. See Q2.
- Keep all `mounted` guards before `setState`/dialogs/snackbars.

## 6. Edge cases to handle

| Case | Handling |
|------|----------|
| create-order fails (network/400) | snackbar with server `message`; stay on page; reset `_isProcessing` |
| User dismisses Razorpay sheet | arrives as `EVENT_PAYMENT_ERROR` (cancelled code) → neutral "Payment cancelled" message |
| Payment succeeds but verify returns 400 | show "could not verify payment, contact support" — do **not** show success |
| Payment succeeds but verify network-fails | same as above; payment may still be captured server-side via webhook later (note for support) |
| Double-tap Pay Now | guarded by `_isProcessing` |
| Widget disposed mid-checkout | `_razorpay.clear()` in dispose; `mounted` checks before UI |
| `orderId == 0` (demo call sites) | create-order will 400; surfaced as error. Demo call sites should pass real ids once live |

## 7. Out of scope (this plan)

- Backend changes — already done.
- Webhook handling (`POST /api/Payments` exists for provider webhooks; server-side concern).
- Partial payments / refunds.
- Web checkout (razorpay_flutter is mobile-only).

## 8. Open questions for you

1. **Razorpay keys**: backend reads `RazorpaySettings:KeyId/KeySecret` from config, and the client
   receives the public `keyId` at runtime from create-order — so the client needs **no** key config.
   Just confirm the backend is currently pointed at **test** keys for our testing.
2. **Payment method selector**: drop the in-app UPI/Card/NetBanking tiles (since Razorpay shows its
   own), or keep them as a prefill hint into the Razorpay sheet? (Recommend: keep visually, pass as hint.)
3. **Platforms**: Android + iOS only via razorpay_flutter, correct? (No Flutter Web payment needed.)
4. **Old mock screen**: delete the now-unused `payment_gateway_page.dart`, or leave it? (Recommend delete.)
5. **Prefill**: OK to prefill the customer's email/phone into the Razorpay sheet from the logged-in
   user/profile? (Improves UX; needs the values available on this screen.)

## 9. Implementation checklist (once approved)

- [ ] Add `razorpay_flutter` to `pubspec.yaml`; `flutter pub get`
- [ ] Android proguard rules + minSdk confirm
- [ ] `lib/shared/models/razorpay_models.dart`
- [ ] `lib/core/services/payment_service.dart`
- [ ] Rewrite `_handlePayment()` + add Razorpay lifecycle in `payment_summary_page.dart`
- [ ] Remove fake `/Payments` direct-post path
- [ ] (Optional) delete `payment_gateway_page.dart`
- [ ] `flutter analyze` clean
- [ ] Manual test: success, cancel, verify-failure paths
