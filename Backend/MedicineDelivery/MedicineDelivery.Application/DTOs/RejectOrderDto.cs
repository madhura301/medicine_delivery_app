using System.ComponentModel.DataAnnotations;

namespace MedicineDelivery.Application.DTOs
{
    public class RejectOrderDto
    {
        [Required]
        [StringLength(250)]
        public string RejectNote { get; set; } = string.Empty;
    }
}

