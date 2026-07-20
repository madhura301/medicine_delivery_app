using System.ComponentModel.DataAnnotations;

namespace MedicineDelivery.Application.DTOs
{
    public class CancelOrderDto
    {
        [Required]
        [StringLength(250, MinimumLength = 1)]
        public string CancellationReason { get; set; } = string.Empty;
    }
}
