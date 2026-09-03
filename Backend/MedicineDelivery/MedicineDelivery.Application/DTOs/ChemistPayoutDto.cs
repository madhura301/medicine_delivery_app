using MedicineDelivery.Domain.Enums;

namespace MedicineDelivery.Application.DTOs
{
    /// <summary>
    /// Request to onboard a chemist (medical store) as a Razorpay Route linked account.
    /// Contact/address/PAN/GST KYC details are pulled from the stored MedicalStore; the
    /// client supplies the business name/type and bank/settlement details here.
    /// </summary>
    public class OnboardChemistPayoutDto
    {
        /// <summary>Legal business name, sent to Razorpay as `legal_business_name`.</summary>
        public string BusinessName { get; set; } = string.Empty;

        /// <summary>Legal business type, sent to Razorpay as `business_type`.</summary>
        public BusinessType RazorpayBusinessType { get; set; } = BusinessType.PrivateLimited;

        /// <summary>Individual owner/stakeholder's personal PAN, sent to Razorpay as the stakeholder's `kyc.pan`.</summary>
        public string OwnerPan { get; set; } = string.Empty;

        public string BankAccountNumber { get; set; } = string.Empty;
        public string BankIfscCode { get; set; } = string.Empty;
        public string BankAccountHolderName { get; set; } = string.Empty;
    }

    /// <summary>Request to update/correct a chemist's bank details and re-submit.</summary>
    public class UpdateChemistBankDto
    {
        public string BankAccountNumber { get; set; } = string.Empty;
        public string BankIfscCode { get; set; } = string.Empty;
        public string BankAccountHolderName { get; set; } = string.Empty;
    }

    /// <summary>Read model returned to clients. Bank account number is masked.</summary>
    public class ChemistPayoutStatusDto
    {
        public Guid MedicalStoreId { get; set; }
        public string? RazorpayLinkedAccountId { get; set; }
        public string? BusinessName { get; set; }
        public BusinessType RazorpayBusinessType { get; set; }
        public string RazorpayBusinessTypeName => RazorpayBusinessType.ToString();
        public string? OwnerPanMasked { get; set; }
        public ChemistPayoutStatus OnboardingStatus { get; set; }
        public string OnboardingStatusName => OnboardingStatus.ToString();
        public string? OnboardingError { get; set; }
        public string? BankAccountNumberMasked { get; set; }
        public string? BankIfscCode { get; set; }
        public string? BankAccountHolderName { get; set; }
        public DateTime? ActivatedOn { get; set; }
        public DateTime CreatedOn { get; set; }
        public DateTime? UpdatedOn { get; set; }

        // ----- Live view from Razorpay -----
        // Populated per-request from the payment gateway and never persisted. Webhooks can be
        // missed, so the stored status above can lag reality; these fields let the console show
        // what Razorpay says right now, alongside what we hold.

        /// <summary>True when Razorpay was reachable and answered for this request.</summary>
        public bool RazorpayReachable { get; set; }

        /// <summary>Razorpay's own status string (e.g. "created", "activated"), as returned.</summary>
        public string? RazorpayRawStatus { get; set; }

        /// <summary>Razorpay's status mapped onto our onboarding states. Null when unreachable.</summary>
        public ChemistPayoutStatus? RazorpayStatus { get; set; }

        public string? RazorpayStatusName => RazorpayStatus?.ToString();

        /// <summary>Why the live lookup failed, when it did. Not stored.</summary>
        public string? RazorpayError { get; set; }

        /// <summary>When this live lookup ran (UTC). Null when no lookup was attempted.</summary>
        public DateTime? RazorpayCheckedAt { get; set; }

        /// <summary>
        /// True when the stored status matches Razorpay's. Null when it could not be determined -
        /// no linked account yet, or Razorpay was unreachable.
        /// </summary>
        public bool? InSync { get; set; }
    }

    /// <summary>Summary returned by the "refresh pending statuses" job.</summary>
    public class ChemistPayoutRefreshResultDto
    {
        public int Checked { get; set; }
        public int Updated { get; set; }
        public int Activated { get; set; }
        public List<ChemistPayoutRefreshItemDto> Items { get; set; } = new();
    }

    /// <summary>Per-account outcome of a status refresh.</summary>
    public class ChemistPayoutRefreshItemDto
    {
        public Guid MedicalStoreId { get; set; }
        public string? RazorpayLinkedAccountId { get; set; }
        public string PreviousStatus { get; set; } = string.Empty;
        public string NewStatus { get; set; } = string.Empty;
        public bool Changed { get; set; }
        public string? RazorpayRawStatus { get; set; }
        public string? Error { get; set; }
    }

    /// <summary>Result wrapper for chemist-payout operations (service → controller).</summary>
    public class ChemistPayoutResult
    {
        public bool Success { get; set; }
        public ChemistPayoutStatusDto? Data { get; set; }
        public List<string> Errors { get; set; } = new();

        public static ChemistPayoutResult Ok(ChemistPayoutStatusDto data) =>
            new() { Success = true, Data = data };

        public static ChemistPayoutResult Fail(params string[] errors) =>
            new() { Success = false, Errors = errors.ToList() };
    }
}
