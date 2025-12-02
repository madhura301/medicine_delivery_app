using System.ComponentModel.DataAnnotations;

namespace MedicineDelivery.Application.DTOs
{
    public class CompleteOrderDto
    {
        [Required]
        [StringLength(4)]
        public string OTP { get; set; } = string.Empty;
    }
}

