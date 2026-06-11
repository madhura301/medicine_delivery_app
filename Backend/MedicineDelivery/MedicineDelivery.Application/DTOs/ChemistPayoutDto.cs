using MedicineDelivery.Domain.Enums;

namespace MedicineDelivery.Application.DTOs
{
    /// <summary>
    /// Request to onboard a chemist (medical store) as a Razorpay Route linked account.
    /// Most KYC details (name, email, PAN, GST, address) are pulled from the stored
    /// MedicalStore; the client supplies the bank/settlement details here.
    /// </summary>
    public class OnboardChemistPayoutDto
    {
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
