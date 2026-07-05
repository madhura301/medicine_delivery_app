using MedicineDelivery.Domain.Enums;

namespace MedicineDelivery.Domain.Entities
{
    /// <summary>
    /// Payout configuration for a chemist (medical store): the Razorpay Route
    /// linked account that receives the chemist's share of each order, plus the
    /// bank details used to create/settle it. One record per medical store.
    /// Kept separate from <see cref="MedicalStore"/> to isolate sensitive bank data.
    /// </summary>
    public class ChemistPayoutAccount
    {
        public int Id { get; set; }

        /// <summary>The medical store this payout account belongs to.</summary>
        public Guid MedicalStoreId { get; set; }

        // ----- Razorpay Route identifiers (populated during onboarding) -----

        /// <summary>Razorpay linked account id (acc_XXXX). Null until created.</summary>
        public string? RazorpayLinkedAccountId { get; set; }

        /// <summary>Razorpay stakeholder id (sth_XXXX). Null until created.</summary>
        public string? RazorpayStakeholderId { get; set; }

        /// <summary>Razorpay product configuration id (acc_prod_XXXX) for the "route" product.</summary>
        public string? RazorpayProductConfigurationId { get; set; }

        // ----- Business KYC details submitted to Razorpay -----

        /// <summary>Legal business name sent to Razorpay as `legal_business_name`.</summary>
        public string? BusinessName { get; set; }

        /// <summary>
        /// Legal business type sent to Razorpay as `business_type`. Named "Razorpay"
        /// (not "BusinessType") to avoid colliding with the unrelated
        /// Retailer/Wholesaler/Both business type collected at chemist registration.
        /// </summary>
        public BusinessType RazorpayBusinessType { get; set; } = BusinessType.PrivateLimited;

        // ----- Bank / settlement details -----
        // Benificier name what we see in Rout Account

        public string? BankAccountNumber { get; set; }
        public string? BankIfscCode { get; set; }
        public string? BankAccountHolderName { get; set; }

        // ----- Lifecycle -----

        public ChemistPayoutStatus OnboardingStatus { get; set; } = ChemistPayoutStatus.NotStarted;

        /// <summary>Last error / clarification message returned by Razorpay, if any.</summary>
        public string? OnboardingError { get; set; }

        /// <summary>When the linked account became usable (status Active).</summary>
        public DateTime? ActivatedOn { get; set; }

        public DateTime CreatedOn { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedOn { get; set; }

        public MedicalStore? MedicalStore { get; set; }
    }
}
