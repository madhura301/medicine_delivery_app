using System.ComponentModel.DataAnnotations;

namespace MedicineDelivery.Application.DTOs
{
    public class AssignOrderDto
    {
        [Required]
        [StringLength(10)]
        public string OrderNumber { get; set; } = string.Empty;

        [Required]
        public Guid MedicalStoreId { get; set; }
    }
}

