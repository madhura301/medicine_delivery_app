namespace MedicineDelivery.Domain.Enums
{
    /// <summary>
    /// State of the Razorpay Route transfer of the chemist's share to their linked account.
    /// </summary>
    public enum TransferStatus
    {
        /// <summary>Transfer not yet attempted.</summary>
        Pending = 1,

        /// <summary>Transfer to the chemist's linked account succeeded.</summary>
        Completed = 2,

        /// <summary>Transfer was attempted but failed.</summary>
        Failed = 3,

        /// <summary>
        /// Transfer skipped (chemist not onboarded / Route disabled). The intended amount is
        /// still recorded so it can be settled later.
        /// </summary>
        Skipped = 4
    }
}
