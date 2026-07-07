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
