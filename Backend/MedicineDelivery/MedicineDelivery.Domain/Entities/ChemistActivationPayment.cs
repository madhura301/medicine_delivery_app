using MedicineDelivery.Domain.Enums;

namespace MedicineDelivery.Domain.Entities
{
    /// <summary>
    /// The one-time platform onboarding / activation fee a chemist (medical store)
    /// pays via a Razorpay Payment Link before going live. When paid, the store's
    /// <see cref="MedicalStore.ActivatedOn"/> is stamped (anchoring the 30-day-free window).
    /// </summary>
    public class ChemistActivationPayment
    {
        public int Id { get; set; }

        public Guid MedicalStoreId { get; set; }

        /// <summary>Base activation fee (e.g. 14999).</summary>
        public decimal Amount { get; set; }

        /// <summary>GST charged on the activation fee (e.g. 18% of Amount).</summary>
        public decimal Gst { get; set; }

        /// <summary>Optional gateway charges, if passed on to the chemist.</summary>
        public decimal? GatewayCharges { get; set; }

        /// <summary>Razorpay Payment Link id (plink_XXXX).</summary>
        public string? RazorpayPaymentLinkId { get; set; }

        /// <summary>Razorpay payment id (pay_XXXX) once the link is paid.</summary>
        public string? RazorpayPaymentId { get; set; }

        public ChemistActivationStatus Status { get; set; } = ChemistActivationStatus.Created;

        public DateTime CreatedOn { get; set; } = DateTime.UtcNow;
        public DateTime? PaidOn { get; set; }

        /// <summary>Total billed via the link (Amount + Gst + GatewayCharges).</summary>
        public decimal Total => Amount + Gst + (GatewayCharges ?? 0m);

        public MedicalStore? MedicalStore { get; set; }
    }
}
