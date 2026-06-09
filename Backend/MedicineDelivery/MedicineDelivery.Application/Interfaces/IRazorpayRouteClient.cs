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
    }

    /// <summary>Input for creating a linked account (mapped from MedicalStore + bank details).</summary>
    public class RazorpayOnboardingRequest
    {
        public string BusinessName { get; set; } = string.Empty;
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
        public string? Pan { get; set; }
        public string? Gst { get; set; }

        public RazorpayBankDetails Bank { get; set; } = new();
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
