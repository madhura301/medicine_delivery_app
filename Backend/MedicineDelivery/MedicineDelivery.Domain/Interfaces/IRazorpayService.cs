using MedicineDelivery.Domain.Entities;

namespace MedicineDelivery.Domain.Interfaces
{
    public interface IRazorpayService
    {
        /// <summary>
        /// Creates a Razorpay order for the given internal order and returns the
        /// Razorpay order details that the client needs to open the checkout widget.
        /// Optionally records the bill/convenience-fee breakdown for the payment split.
        /// </summary>
        Task<RazorpayOrderResult> CreateOrderAsync(int orderId, decimal amount, decimal? billAmount = null, decimal? convenienceFee = null);

        /// <summary>
        /// Verifies the HMAC-SHA256 signature sent back by the Razorpay checkout and,
        /// if valid, records the payment against the internal order and splits the funds
        /// between the chemist (Route transfer) and Pharmaish.
        /// </summary>
        Task<bool> VerifyAndCapturePaymentAsync(RazorpayVerifyRequest request);
    }

    public class RazorpayOrderResult
    {
        public bool Success { get; set; }
        public string? RazorpayOrderId { get; set; }
        public decimal Amount { get; set; }
        public string Currency { get; set; } = "INR";
        public string? KeyId { get; set; }
        public List<string> Errors { get; set; } = new();
    }

    public class RazorpayVerifyRequest
    {
        public int OrderId { get; set; }
        public string RazorpayOrderId { get; set; } = string.Empty;
        public string RazorpayPaymentId { get; set; } = string.Empty;
        public string RazorpaySignature { get; set; } = string.Empty;
    }
}
