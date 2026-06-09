using MedicineDelivery.Domain.Enums;

namespace MedicineDelivery.Domain.Entities
{
    /// <summary>
    /// Audit of how a captured order payment was split between the chemist (medicine sale,
    /// minus the platform technology fee) and Pharmaish (convenience fee + platform fee).
    /// One row per captured payment.
    /// </summary>
    public class PaymentSplit
    {
        public int Id { get; set; }

        public int OrderId { get; set; }

        /// <summary>Razorpay payment id (pay_XXXX) that was captured and split.</summary>
        public string RazorpayPaymentId { get; set; } = string.Empty;

        /// <summary>Full amount captured from the customer (bill + convenience fee).</summary>
        public decimal TotalCaptured { get; set; }

        /// <summary>The medicine/bill value the slab is applied to.</summary>
        public decimal BillAmount { get; set; }

        /// <summary>Convenience fee portion (retained by Pharmaish).</summary>
        public decimal ConvenienceFee { get; set; }

        /// <summary>Platform technology fee (slab on BillAmount; retained by Pharmaish).</summary>
        public decimal PlatformFee { get; set; }

        /// <summary>Amount transferred (or owed) to the chemist = BillAmount − PlatformFee.</summary>
        public decimal ChemistAmount { get; set; }

        /// <summary>Amount retained by Pharmaish = ConvenienceFee + PlatformFee.</summary>
        public decimal PharmaishAmount { get; set; }

        /// <summary>Razorpay transfer id (trf_XXXX), when a transfer was made.</summary>
        public string? RazorpayTransferId { get; set; }

        /// <summary>Chemist linked account the transfer targeted (acc_XXXX).</summary>
        public string? ChemistLinkedAccountId { get; set; }

        public TransferStatus TransferStatus { get; set; } = TransferStatus.Pending;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public Order? Order { get; set; }
    }
}
