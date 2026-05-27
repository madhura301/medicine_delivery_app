namespace MedicineDelivery.Application.DTOs
{
    /// <summary>Request body for POST /api/razorpay/create-order.</summary>
    public class RazorpayCreateOrderDto
    {
        public int OrderId { get; set; }
        public decimal Amount { get; set; }
    }

    /// <summary>Response returned to the client so it can open the Razorpay checkout widget.</summary>
    public class RazorpayOrderResponseDto
    {
        public string RazorpayOrderId { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public string Currency { get; set; } = "INR";
        /// <summary>Public key — safe to expose to the client.</summary>
        public string KeyId { get; set; } = string.Empty;
    }

    /// <summary>
    /// Request body for POST /api/razorpay/verify-payment.
    /// The client sends these three fields back after a successful checkout.
    /// </summary>
    public class RazorpayVerifyPaymentDto
    {
        public int OrderId { get; set; }
        public string RazorpayOrderId { get; set; } = string.Empty;
        public string RazorpayPaymentId { get; set; } = string.Empty;
        public string RazorpaySignature { get; set; } = string.Empty;
    }
}
