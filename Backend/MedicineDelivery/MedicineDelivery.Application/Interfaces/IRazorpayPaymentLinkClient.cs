namespace MedicineDelivery.Application.Interfaces
{
    /// <summary>
    /// Thin wrapper over the Razorpay Payment Links API (v1/payment_links).
    /// Used to collect the chemist's one-time activation/onboarding fee — this is a
    /// standalone Razorpay product, independent of Route / linked accounts.
    /// </summary>
    public interface IRazorpayPaymentLinkClient
    {
        Task<PaymentLinkResult> CreatePaymentLinkAsync(PaymentLinkRequest request, CancellationToken ct = default);

        /// <summary>
        /// Reads a payment link's current state straight from Razorpay.
        ///
        /// This is how the console shows gateway state beside stored state, and how a payment that
        /// arrived while the webhook was misconfigured can still be reconciled — the webhook is
        /// otherwise the only thing that marks an activation paid.
        /// </summary>
        Task<PaymentLinkStatusResult> GetPaymentLinkAsync(string paymentLinkId, CancellationToken ct = default);
    }

    public class PaymentLinkRequest
    {
        public int AmountInPaise { get; set; }
        public string Currency { get; set; } = "INR";
        public string Description { get; set; } = string.Empty;
        public string CustomerName { get; set; } = string.Empty;
        public string CustomerEmail { get; set; } = string.Empty;
        public string CustomerContact { get; set; } = string.Empty;
        /// <summary>Stored on the link as a note so the webhook can correlate it.</summary>
        public string ReferenceNote { get; set; } = string.Empty;
    }

    public class PaymentLinkResult
    {
        public bool Success { get; set; }
        public string? PaymentLinkId { get; set; }
        public string? ShortUrl { get; set; }
        public string? Status { get; set; }
        public string? Error { get; set; }
    }

    /// <summary>What Razorpay currently holds for one payment link.</summary>
    public class PaymentLinkStatusResult
    {
        /// <summary>False when Razorpay could not be reached or rejected the request — see <see cref="Error"/>.</summary>
        public bool Success { get; set; }

        /// <summary>Razorpay's own wording: created, partially_paid, paid, expired or cancelled.</summary>
        public string? RawStatus { get; set; }

        /// <summary>Amount received so far, in rupees.</summary>
        public decimal? AmountPaid { get; set; }

        /// <summary>The captured payment behind a paid link, when there is one.</summary>
        public string? PaymentId { get; set; }

        /// <summary>When that payment was captured, per Razorpay.</summary>
        public DateTime? PaidAt { get; set; }

        public string? Error { get; set; }

        public static PaymentLinkStatusResult Fail(string error) => new() { Success = false, Error = error };
    }
}
