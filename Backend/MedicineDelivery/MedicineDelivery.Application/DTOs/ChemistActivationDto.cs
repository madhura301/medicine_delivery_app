using MedicineDelivery.Domain.Enums;

namespace MedicineDelivery.Application.DTOs
{
    /// <summary>Read model for a chemist's activation-fee payment.</summary>
    public class ChemistActivationDto
    {
        public Guid MedicalStoreId { get; set; }
        public decimal Amount { get; set; }
        public decimal Gst { get; set; }
        public decimal? GatewayCharges { get; set; }
        public decimal Total { get; set; }
        public ChemistActivationStatus Status { get; set; }
        public string StatusName => Status.ToString();
        public string? PaymentLinkUrl { get; set; }
        public string? PaymentLinkId { get; set; }
        public bool IsActivated { get; set; }
        public DateTime CreatedOn { get; set; }
        public DateTime? PaidOn { get; set; }

        /* ── Live reading from Razorpay ──────────────────────────────────────
         * Never stored. Taken fresh on each read, because the webhook that marks an activation
         * paid can be missed or misconfigured — in which case the stored status stays behind what
         * the gateway holds, and a chemist who has paid never becomes eligible for orders.
         */

        /// <summary>True when Razorpay answered this request.</summary>
        public bool RazorpayReachable { get; set; }

        /// <summary>Razorpay's own wording: created, partially_paid, paid, expired or cancelled.</summary>
        public string? RazorpayRawStatus { get; set; }

        /// <summary>Razorpay's state mapped onto ours; null when it could not be read.</summary>
        public ChemistActivationStatus? RazorpayStatus { get; set; }

        public string? RazorpayStatusName => RazorpayStatus?.ToString();

        /// <summary>Amount Razorpay says has been received, in rupees.</summary>
        public decimal? RazorpayAmountPaid { get; set; }

        /// <summary>The captured payment id Razorpay holds, which may be missing from our record.</summary>
        public string? RazorpayPaymentId { get; set; }

        /// <summary>Why the live lookup failed, when it did.</summary>
        public string? RazorpayError { get; set; }

        public DateTime? RazorpayCheckedAt { get; set; }

        /// <summary>
        /// Whether the stored status matched Razorpay when this request arrived. Null when it cannot be
        /// judged: no payment link exists, or the gateway was unreachable.
        /// </summary>
        public bool? InSync { get; set; }
    }

    /// <summary>Result wrapper for chemist-activation operations (service → controller).</summary>
    public class ChemistActivationResult
    {
        public bool Success { get; set; }
        public ChemistActivationDto? Data { get; set; }
        public List<string> Errors { get; set; } = new();

        public static ChemistActivationResult Ok(ChemistActivationDto data) =>
            new() { Success = true, Data = data };

        public static ChemistActivationResult Fail(params string[] errors) =>
            new() { Success = false, Errors = errors.ToList() };
    }
}
