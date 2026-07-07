using MedicineDelivery.Domain.Enums;

namespace MedicineDelivery.Application.Interfaces
{
    /// <summary>
    /// Thin wrapper over the Razorpay Route (v2 Accounts) onboarding APIs. Encapsulates
    /// the multi-step "create linked account → stakeholder → request product → submit
    /// bank details" sequence so the service layer deals only with business persistence.
    /// </summary>
    public interface IRazorpayRouteClient
    {
        /// <summary>
        /// Runs the full linked-account onboarding sequence for a chemist.
        /// On partial failure the result still carries whatever ids were obtained so the
        /// caller can persist progress and resume later.
        /// </summary>
        Task<RazorpayOnboardingResult> CreateLinkedAccountAsync(RazorpayOnboardingRequest request, CancellationToken ct = default);

        /// <summary>
        /// Re-submits/updates the Route product configuration (bank settlement details)
        /// for an already-created linked account.
        /// </summary>
        Task<RazorpayOnboardingResult> UpdateBankConfigurationAsync(string linkedAccountId, string? productConfigurationId, RazorpayBankDetails bank, CancellationToken ct = default);

        /// <summary>
        /// Transfers a portion of a captured payment to a chemist's linked account
        /// (Razorpay Route "transfer from payment").
        /// </summary>
        Task<RazorpayTransferResult> CreateTransferOnPaymentAsync(RazorpayTransferRequest request, CancellationToken ct = default);

        /// <summary>
        /// Fetches the live activation status of a linked account from Razorpay
        /// (GET /v2/accounts/{id}).
        /// </summary>
        Task<RazorpayAccountStatusResult> GetAccountStatusAsync(string linkedAccountId, CancellationToken ct = default);
    }

    public class RazorpayAccountStatusResult
    {
        public bool Success { get; set; }
        public RazorpayActivationState State { get; set; } = RazorpayActivationState.Pending;
        /// <summary>The raw status string returned by Razorpay (e.g. "created", "activated").</summary>
        public string? RawStatus { get; set; }
        public string? Error { get; set; }
    }

    public class RazorpayTransferRequest
    {
        /// <summary>The captured payment id (pay_XXXX) to transfer from.</summary>
        public string PaymentId { get; set; } = string.Empty;
        /// <summary>Destination linked account id (acc_XXXX).</summary>
        public string LinkedAccountId { get; set; } = string.Empty;
        public int AmountInPaise { get; set; }
        public string Currency { get; set; } = "INR";
        /// <summary>Hold the transfer (e.g. until delivery) instead of settling immediately.</summary>
        public bool OnHold { get; set; }
    }

    public class RazorpayTransferResult
    {
        public bool Success { get; set; }
        public string? TransferId { get; set; }
        public string? Error { get; set; }
    }

    /// <summary>Input for creating a linked account (mapped from MedicalStore + bank details).</summary>
    public class RazorpayOnboardingRequest
    {
        public string BusinessName { get; set; } = string.Empty;
        public BusinessType BusinessType { get; set; } = BusinessType.PrivateLimited;
        public string ContactName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Phone { get; set; } = string.Empty;

        // Registered address
        public string Street1 { get; set; } = string.Empty;
        public string Street2 { get; set; } = string.Empty;
        public string City { get; set; } = string.Empty;
        public string State { get; set; } = string.Empty;
        public string PostalCode { get; set; } = string.Empty;
        public string Country { get; set; } = "IN";

        // KYC
        /// <summary>Company-level PAN, sent as `legal_info.pan` (skipped for Individual/Proprietorship).</summary>
        public string? CompanyPan { get; set; }
        /// <summary>Individual owner/stakeholder's personal PAN, sent as the stakeholder's `kyc.pan`. Always required.</summary>
        public string OwnerPan { get; set; } = string.Empty;
        public string? Gst { get; set; }

        public RazorpayBankDetails Bank { get; set; } = new();

        // Resume support: ids from a previous (partial) onboarding attempt.
        // When present, the matching creation step is skipped.
        public string? ExistingLinkedAccountId { get; set; }
        public string? ExistingStakeholderId { get; set; }
        public string? ExistingProductConfigurationId { get; set; }
    }

    public class RazorpayBankDetails
    {
        public string AccountNumber { get; set; } = string.Empty;
        public string IfscCode { get; set; } = string.Empty;
        public string BeneficiaryName { get; set; } = string.Empty;
    }

    /// <summary>Normalised activation state returned by Razorpay.</summary>
    public enum RazorpayActivationState
    {
        Pending = 0,
        NeedsClarification = 1,
        Activated = 2,
        Rejected = 3,
        Suspended = 4
    }

    /// <summary>Result of an onboarding sequence (or a step of it).</summary>
    public class RazorpayOnboardingResult
    {
        public bool Success { get; set; }
        public string? LinkedAccountId { get; set; }
        public string? StakeholderId { get; set; }
        public string? ProductConfigurationId { get; set; }
        public RazorpayActivationState State { get; set; } = RazorpayActivationState.Pending;
        public string? Error { get; set; }
        /// <summary>The step that failed, for diagnostics (e.g. "CreateStakeholder").</summary>
        public string? FailedStep { get; set; }
    }
}
