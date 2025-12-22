namespace MedicineDelivery.Application.DTOs
{
    public class OrderAssignmentHistoryExtendedDto : OrderAssignmentHistoryDto
    {
        public new string AssignTo { get; set; } = string.Empty;
        public new string AssignmentStatus { get; set; } = string.Empty;
        public string AssigneeName { get; set; } = string.Empty;
    }
}

