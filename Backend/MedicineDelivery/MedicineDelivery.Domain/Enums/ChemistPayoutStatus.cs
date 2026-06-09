namespace MedicineDelivery.Domain.Enums
{
    /// <summary>
    /// Onboarding state of a chemist's Razorpay Route linked account.
    /// Mirrors the Razorpay account/product activation lifecycle.
    /// </summary>
    public enum ChemistPayoutStatus
    {
        /// <summary>No onboarding attempted yet.</summary>
        NotStarted = 0,

        /// <summary>Linked account created / product requested; awaiting Razorpay review.</summary>
        Pending = 1,

        /// <summary>Razorpay requires more information/documents before activation.</summary>
        NeedsClarification = 2,

        /// <summary>Linked account is active and can receive Route transfers.</summary>
        Active = 3,

        /// <summary>Razorpay rejected the linked account.</summary>
        Rejected = 4,

        /// <summary>Previously active account that has been suspended.</summary>
        Suspended = 5
    }
}
