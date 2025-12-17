using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Http;

namespace MedicineDelivery.Application.DTOs
{
    public class UploadOrderBillDto
    {
        [Required]
        public int OrderId { get; set; }

        [Required]
        [Range(0.01, double.MaxValue, ErrorMessage = "Order amount must be greater than 0")]
        public decimal OrderAmount { get; set; }

        [Required]
        public IFormFile BillFile { get; set; } = null!;

        public int? DeliveryId { get; set; }
    }
}

