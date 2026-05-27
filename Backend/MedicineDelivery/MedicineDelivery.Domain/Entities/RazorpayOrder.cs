using MedicineDelivery.Domain.Enums;

namespace MedicineDelivery.Domain.Entities
{
    public class RazorpayOrder
    {
        public int Id { get; set; }
        public int OrderId { get; set; }
        public string RazorpayOrderId { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public string Currency { get; set; } = "INR";
        public RazorpayOrderStatus Status { get; set; }
        public DateTime CreatedAt { get; set; }
        public string? RazorpayPaymentId { get; set; }
        public string? RazorpaySignature { get; set; }

        public Order? Order { get; set; }
    }
}
