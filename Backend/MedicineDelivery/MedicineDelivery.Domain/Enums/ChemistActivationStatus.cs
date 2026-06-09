namespace MedicineDelivery.Domain.Enums
{
    /// <summary>
    /// State of a chemist's one-time activation (onboarding) fee payment,
    /// collected via a Razorpay Payment Link.
    /// </summary>
    public enum ChemistActivationStatus
    {
        /// <summary>Payment link created; awaiting payment.</summary>
        Created = 1,

        /// <summary>Activation fee paid; store can be activated.</summary>
        Paid = 2,

        /// <summary>Payment failed / cancelled.</summary>
        Failed = 3,

        /// <summary>Payment link expired before payment.</summary>
        Expired = 4
    }
}
