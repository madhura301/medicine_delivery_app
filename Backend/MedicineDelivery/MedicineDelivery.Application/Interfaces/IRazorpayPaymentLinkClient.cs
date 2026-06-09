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
}
