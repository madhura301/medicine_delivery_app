using MedicineDelivery.Domain.Enums;

namespace MedicineDelivery.Application.DTOs
{
    public class OrderDto
    {
        public int OrderId { get; set; }
        public Guid CustomerId { get; set; }
        public Guid CustomerAddressId { get; set; }
        public Guid? MedicalStoreId { get; set; }
        public AssignedByType AssignedByType { get; set; }
        public Guid? CustomerSupportId { get; set; }
        public OrderType OrderType { get; set; }
        public OrderInputType OrderInputType { get; set; }
        public string? OrderInputFileLocation { get; set; }
        public string? OrderInputText { get; set; }
        public OrderStatus OrderStatus { get; set; }
        public string? OrderNumber { get; set; }
        public string? OTP { get; set; }
        public decimal? TotalAmount { get; set; }
        public DateTime CreatedOn { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public IEnumerable<OrderAssignmentHistoryDto>? AssignmentHistory { get; set; }
        public IEnumerable<PaymentDto>? Payments { get; set; }
    }
}

