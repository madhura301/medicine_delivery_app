using MedicineDelivery.Domain.Enums;

namespace MedicineDelivery.Application.DTOs
{
    /// <summary>Read model describing how a captured order payment was split.</summary>
    public class PaymentSplitDto
    {
        public int Id { get; set; }
        public int OrderId { get; set; }
        public string RazorpayPaymentId { get; set; } = string.Empty;
        public decimal TotalCaptured { get; set; }
        public decimal BillAmount { get; set; }
        public decimal ConvenienceFee { get; set; }
        public decimal PlatformFee { get; set; }
        public decimal ChemistAmount { get; set; }
        public decimal PharmaishAmount { get; set; }
        public string? RazorpayTransferId { get; set; }
        public string? ChemistLinkedAccountId { get; set; }
        public TransferStatus TransferStatus { get; set; }
        public string TransferStatusName => TransferStatus.ToString();
        public DateTime CreatedAt { get; set; }
    }
}
