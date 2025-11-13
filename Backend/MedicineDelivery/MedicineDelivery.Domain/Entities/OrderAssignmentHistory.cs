using MedicineDelivery.Domain.Enums;

namespace MedicineDelivery.Domain.Entities
{
    public class OrderAssignmentHistory
    {
        public int AssignmentId { get; set; }
        public int OrderId { get; set; }
        public Guid MedicalStoreId { get; set; }
        public AssignedByType AssignedByType { get; set; } = AssignedByType.System;
        public Guid? AssignedByCustomerSupportId { get; set; }
        public DateTime AssignedOn { get; set; } = DateTime.UtcNow;
        public AssignmentStatus Status { get; set; } = AssignmentStatus.Assigned;
        public string? RejectNote { get; set; }
        public DateTime? UpdatedOn { get; set; }

        public Order? Order { get; set; }
        public MedicalStore? MedicalStore { get; set; }
        public CustomerSupport? CustomerSupport { get; set; }
    }
}

