using System.ComponentModel.DataAnnotations;

namespace MedicineDelivery.Application.DTOs
{
    public class AssignOrderDto
    {
        [Required]
        public int OrderId { get; set; }

        [Required]
        public Guid MedicalStoreId { get; set; }
    }
}

