using MedicineDelivery.Domain.Enums;

namespace MedicineDelivery.Application.DTOs
{
    public record RecordPaymentDto
    {
        public int OrderId { get; init; }
        public string PaymentMode { get; init; } = string.Empty;
        public string TransactionId { get; init; } = string.Empty;
        public decimal Amount { get; init; }
        public PaymentStatus PaymentStatus { get; init; }
        public string? ProviderReference { get; init; }  // For future third-party integration
    }
}
