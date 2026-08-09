using MedicineDelivery.Domain.Enums;

namespace MedicineDelivery.Domain.Entities
{
    public class Order
    {
        public int OrderId { get; set; }
        public Guid CustomerId { get; set; }
        public Guid CustomerAddressId { get; set; }
        public Guid? MedicalStoreId { get; set; }
        public AssignedByType AssignedByType { get; set; } = AssignedByType.System;
        public Guid? CustomerSupportId { get; set; }
        public Guid? ManagerId { get; set; }
        public int? DeliveryId { get; set; }
        public AssignTo AssignTo { get; set; } = AssignTo.Chemist;
        public OrderType OrderType { get; set; } = OrderType.NotSet;
        public OrderInputType OrderInputType { get; set; }
        public string? OrderInputFileLocation { get; set; }
        public string? OrderInputText { get; set; }
        public string? OrderBillFileLocation { get; set; }
        public OrderStatus OrderStatus { get; set; } = OrderStatus.PendingPayment;
        public OrderPaymentStatus OrderPaymentStatus { get; set; } = OrderPaymentStatus.NotPaid;
        public string? OrderNumber { get; set; }
        public string? OTP { get; set; }

        /// <summary>Reason captured when the order is cancelled (by customer support, manager or admin). Null unless cancelled.</summary>
        public string? CancellationReason { get; set; }
        public decimal? TotalAmount { get; set; }

        /// <summary>The medicine/bill value (slab is applied to this). Set at payment time.</summary>
        public decimal? BillAmount { get; set; }

        /// <summary>Convenience / payment-processing fee added on top of the bill.</summary>
        public decimal? ConvenienceFee { get; set; }

        public DateTime CreatedOn { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedOn { get; set; }

        public Customer? Customer { get; set; }
        public CustomerAddress? CustomerAddress { get; set; }
        public MedicalStore? MedicalStore { get; set; }
        public CustomerSupport? CustomerSupport { get; set; }
        public Manager? Manager { get; set; }
        public ICollection<OrderAssignmentHistory> AssignmentHistory { get; set; } = new List<OrderAssignmentHistory>();
        public ICollection<Payment> Payments { get; set; } = new List<Payment>();
        public ICollection<PaymentSplit> PaymentSplits { get; set; } = new List<PaymentSplit>();
    }
}

