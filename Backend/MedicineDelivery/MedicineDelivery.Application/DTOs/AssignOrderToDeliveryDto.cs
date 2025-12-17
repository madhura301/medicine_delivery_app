using System.ComponentModel.DataAnnotations;

namespace MedicineDelivery.Application.DTOs
{
    public class AssignOrderToDeliveryDto
    {
        [Required]
        public int OrderId { get; set; }

        [Required]
        public int DeliveryId { get; set; }
    }
}

