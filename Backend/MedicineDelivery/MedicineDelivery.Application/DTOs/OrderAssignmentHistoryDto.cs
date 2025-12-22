using MedicineDelivery.Domain.Enums;

namespace MedicineDelivery.Application.DTOs
{
    public class OrderAssignmentHistoryDto
    {
        public int AssignmentId { get; set; }
        public int OrderId { get; set; }
        public Guid CustomerId { get; set; }
        public Guid? MedicalStoreId { get; set; }
        public AssignedByType AssignedByType { get; set; }
        public Guid? AssignedByCustomerSupportId { get; set; }
        public int? DeliveryId { get; set; }
        public AssignTo AssignTo { get; set; }
        public DateTime AssignedOn { get; set; }
        public AssignmentStatus Status { get; set; }
        public string? RejectNote { get; set; }
        public DateTime? UpdatedOn { get; set; }
    }
}

