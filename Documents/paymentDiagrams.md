# Razorpay Route Split Payment — Diagrams

> Companion to [`paymentRoutePlan.md`](./paymentRoutePlan.md) and
> [`paymentImplementationPlan.md`](./paymentImplementationPlan.md).
> Diagrams use **Mermaid** (renders in GitHub / VS Code / most Markdown viewers).
>
> Legend: 🟦 backend · 🟩 web · 🟪 mobile · ☁️ external (Razorpay).
> **Phase 1** = chemist linked-account onboarding (built). **Phase 2** = order payment + split (planned).

---

## 1. System Architecture

```mermaid
flowchart TB
    subgraph CLIENTS["Clients"]
        FLUTTER["🟪 Flutter App<br/>Customer payment"]
        WEB["🟩 React WebApp<br/>Admin / Chemist onboarding"]
    end

    subgraph API["🟦 MedicineDelivery.API"]
        RZC["RazorpayController<br/>create-order / verify-payment"]
        CPC["ChemistPayoutController<br/>onboard / status / bank"]
    end

    subgraph APP["🟦 MedicineDelivery.Application (interfaces, DTOs)"]
        IRS["IRazorpayService"]
        ICPS["IChemistPayoutService"]
        IRRC["IRazorpayRouteClient"]
        IPFC["IPlatformFeeCalculator<br/>(Phase 2)"]
    end

    subgraph INFRA["🟦 MedicineDelivery.Infrastructure (implementations)"]
        RS["RazorpayService"]
        CPS["ChemistPayoutService"]
        RRC["RazorpayRouteClient<br/>(typed HttpClient)"]
        PFC["PlatformFeeCalculator<br/>(Phase 2)"]
        UOW["UnitOfWork / EF Core"]
    end

    subgraph DOMAIN["🟦 MedicineDelivery.Domain"]
        ENT["Entities: MedicalStore, Order,<br/>ChemistPayoutAccount, RazorpayOrder,<br/>Payment, PaymentSplit (Phase 2)"]
    end

    DB[("PostgreSQL<br/>MedicineDeliveryNew")]
    RZP["☁️ Razorpay<br/>Route v2 Accounts API<br/>Orders / Payments / Transfers"]

    FLUTTER -->|"JWT REST"| RZC
    WEB -->|"JWT REST"| CPC

    RZC --> IRS
    CPC --> ICPS
    IRS -.implemented by.-> RS
    ICPS -.implemented by.-> CPS
    IRRC -.implemented by.-> RRC
    IPFC -.implemented by.-> PFC

    RS --> UOW
    RS --> IPFC
    RS -->|"orders / transfers"| RZP
    CPS --> UOW
    CPS --> IRRC
    RRC -->|"v2/accounts ..."| RZP

    UOW --> ENT
    UOW --> DB
```

---

## 2. Sequence — Phase 1: Chemist Linked-Account Onboarding

```mermaid
sequenceDiagram
    autonumber
    actor Admin as 🟩 Admin / Chemist (Web)
    participant API as 🟦 ChemistPayoutController
    participant SVC as 🟦 ChemistPayoutService
    participant CLI as 🟦 RazorpayRouteClient
    participant RZP as ☁️ Razorpay v2 Accounts
    participant DB as 🟦 PostgreSQL

    Admin->>API: POST /chemist-payout/{storeId}/onboard<br/>{bank account, IFSC, holder}
    API->>SVC: OnboardAsync(storeId, dto)
    SVC->>SVC: Validate bank + IFSC format
    SVC->>DB: Load MedicalStore (KYC: name, PAN, GST, address)
    SVC->>DB: Load existing ChemistPayoutAccount?

    alt already Active
        SVC-->>API: Fail "already onboarded"
        API-->>Admin: 400 errors
    else fresh / resume
        SVC->>CLI: CreateLinkedAccountAsync(request)
        CLI->>RZP: POST /v2/accounts  (linked account)
        RZP-->>CLI: acc_XXXX
        CLI->>RZP: POST /v2/accounts/{acc}/stakeholders
        RZP-->>CLI: sth_XXXX
        CLI->>RZP: POST /v2/accounts/{acc}/products (route)
        RZP-->>CLI: acc_prod_XXXX
        CLI->>RZP: PATCH .../products/{prod} (bank settlement)
        RZP-->>CLI: activation_status
        CLI-->>SVC: result {acc, sth, prod, state}
        SVC->>SVC: Map state to ChemistPayoutStatus<br/>(Pending / NeedsClarification / Active ...)
        SVC->>DB: Persist ChemistPayoutAccount
        SVC-->>API: ChemistPayoutStatusDto (bank masked)
        API-->>Admin: 200 status
    end

    Note over RZP,DB: Activation is async. A later<br/>account.activated webhook (Phase 3)<br/>flips status to Active.
```

---

## 3. Sequence — Phase 2: Order Payment & Split

```mermaid
sequenceDiagram
    autonumber
    actor Cust as 🟪 Customer (Flutter)
    participant API as 🟦 RazorpayController
    participant RS as 🟦 RazorpayService
    participant FEE as 🟦 PlatformFeeCalculator
    participant RZP as ☁️ Razorpay
    participant DB as 🟦 PostgreSQL

    Note over Cust: Bill ₹100 + Convenience ₹20 = ₹120 (frontend adds convenience fee)

    Cust->>API: POST /Razorpay/create-order { orderId, amount=120 }
    API->>RS: CreateOrderAsync(orderId, 120)
    RS->>RZP: Orders.Create(amount=12000 paise)
    RZP-->>RS: order_XXXX
    RS->>DB: Save RazorpayOrder (Created)
    RS-->>API: { razorpayOrderId, amount, keyId }
    API-->>Cust: order details

    Cust->>RZP: Open Checkout, pay ₹120
    RZP-->>Cust: success { paymentId, signature }

    Cust->>API: POST /Razorpay/verify-payment { ids, signature }
    API->>RS: VerifyAndCapturePaymentAsync(req)
    RS->>RS: Verify HMAC-SHA256 signature
    alt signature invalid
        RS-->>API: false
        API-->>Cust: 400 verification failed
    else valid
        RS->>DB: Mark RazorpayOrder Paid
        RS->>DB: Load Order(bill=100) + ChemistPayoutAccount
        RS->>FEE: Fee(billAmount=100, store.ActivatedOn)
        FEE-->>RS: platformFee = 5  (slab 0-200)
        RS->>RS: chemistAmount = 100 - 5 = 95

        alt chemist linked account Active
            RS->>RZP: Transfers.Create(payment, 95 to acc_XXXX)
            RZP-->>RS: trf_XXXX
            RS->>DB: PaymentSplit (TransferStatus=Completed)
        else not onboarded / RouteEnabled=false
            RS->>DB: PaymentSplit (TransferStatus=Skipped, amount owed recorded)
        end

        RS->>DB: Record Payment (full 120) + mark Order Paid
        RS-->>API: true
        API-->>Cust: 200 success
    end
```

---

## 4. Flowchart — Chemist Onboarding State Machine

```mermaid
flowchart TD
    START([Store registered + KYC on file]) --> SUBMIT[/Submit bank account + IFSC + holder/]
    SUBMIT --> VALID{Valid bank<br/>+ IFSC?}
    VALID -->|No| ERR1[Return validation errors] --> SUBMIT
    VALID -->|Yes| HAS{Linked account<br/>already exists?}

    HAS -->|No| CREATE[Create linked account →<br/>stakeholder → route product →<br/>submit bank]
    HAS -->|Yes, not Active| UPDATE[Re-submit bank config<br/>on existing account]

    CREATE --> RESP{Razorpay<br/>result}
    UPDATE --> RESP

    RESP -->|step failed| PFAIL[Persist partial ids<br/>status = Pending / NotStarted<br/>store error] --> RETRY([Admin can retry / fix bank])
    RESP -->|activated| ACTIVE([Status = Active<br/>set ActivatedOn<br/>ready for Phase 2 transfers])
    RESP -->|needs_clarification| NEEDS([Status = NeedsClarification]) --> RETRY
    RESP -->|under review| PEND([Status = Pending]) -.->|account.activated webhook| ACTIVE
    RESP -->|rejected| REJ([Status = Rejected]) --> RETRY
```

---

## 5. Flowchart — Payment Split & Platform Fee Slab

```mermaid
flowchart TD
    PAY([Payment captured ₹120<br/>signature verified]) --> LOAD[Load Order bill=₹100<br/>+ ChemistPayoutAccount]
    LOAD --> KILL{RouteEnabled?}
    KILL -->|No| NOSPLIT[No transfer<br/>full amount stays in Pharmaish<br/>behaves like today] --> RECORD

    KILL -->|Yes| FREE{Within 30 days<br/>of activation?}
    FREE -->|Yes| FEE0[platformFee = ₹0] --> CALC
    FREE -->|No| SLAB[Apply slab on bill amount]

    SLAB --> S1{Bill value band}
    S1 -->|0-200| F5[₹5]
    S1 -->|201-500| F10[₹10]
    S1 -->|501-1500| F15[₹15]
    S1 -->|1501-3000| F20[₹20]
    S1 -->|3001-5000| F50[₹50]
    S1 -->|above 5000| F100[₹100]

    F5 --> CALC
    F10 --> CALC
    F15 --> CALC
    F20 --> CALC
    F50 --> CALC
    F100 --> CALC

    CALC[chemistAmount = bill - platformFee<br/>e.g. 100 - 5 = 95] --> ACT{Chemist linked<br/>account Active?}

    ACT -->|Yes| XFER[Razorpay Transfer<br/>chemistAmount → acc_XXXX] --> DONE[PaymentSplit:<br/>TransferStatus = Completed]
    ACT -->|No| SKIP[Skip transfer<br/>record amount owed] --> DONE2[PaymentSplit:<br/>TransferStatus = Skipped]

    DONE --> RECORD
    DONE2 --> RECORD
    RECORD[Record Payment full ₹120<br/>mark Order Paid] --> END([Done])
```

---

## 6. Money Split (worked example, ₹100 bill)

```mermaid
flowchart LR
    C["Customer pays ₹120"] --> P["Pharmaish Razorpay account<br/>captures ₹120"]
    P -->|"Route transfer ₹95"| CH["Chemist linked account<br/>acc_XXXX"]
    P -->|"retain ₹25"| PH["Pharmaish<br/>₹20 convenience + ₹5 platform fee"]
    PH -->|"debited by Razorpay"| FEE["PG fee ~2% of ₹120<br/>+ transfer fee + 18% GST"]
```

> Notes: the ₹20 convenience fee and the platform fee (slab on the ₹100 bill) both stay
> with Pharmaish; Razorpay's own fees are deducted from the Pharmaish balance, not from
> the chemist's ₹95 transfer.
