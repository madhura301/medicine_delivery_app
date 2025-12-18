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
        public int? DeliveryId { get; set; }
        public AssignTo AssignTo { get; set; } = AssignTo.Chemist;
        public OrderType OrderType { get; set; } = OrderType.NotSet;
        public OrderInputType OrderInputType { get; set; }
        public string? OrderInputFileLocation { get; set; }
        public string? OrderInputText { get; set; }
        public string? OrderBillFileLocation { get; set; }
        public OrderStatus OrderStatus { get; set; } = OrderStatus.PendingPayment;
        public string? OrderNumber { get; set; }
        public string? OTP { get; set; }
        public decimal? TotalAmount { get; set; }
        public DateTime CreatedOn { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedOn { get; set; }

        public Customer? Customer { get; set; }
        public CustomerAddress? CustomerAddress { get; set; }
        public MedicalStore? MedicalStore { get; set; }
        public CustomerSupport? CustomerSupport { get; set; }
        public ICollection<OrderAssignmentHistory> AssignmentHistory { get; set; } = new List<OrderAssignmentHistory>();
        public ICollection<Payment> Payments { get; set; } = new List<Payment>();
    }
}

