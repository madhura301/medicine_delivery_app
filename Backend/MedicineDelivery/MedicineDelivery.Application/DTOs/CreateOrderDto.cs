using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Http;
using MedicineDelivery.Domain.Enums;

namespace MedicineDelivery.Application.DTOs
{
    public class CreateOrderDto
    {
        [Required]
        public Guid CustomerId { get; set; }

        [Required]
        public Guid CustomerAddressId { get; set; }

        [Required]
        public OrderType OrderType { get; set; } = OrderType.NotSet;

        [Required]
        public OrderInputType OrderInputType { get; set; }

        [StringLength(100)]
        public string? OrderInputFileLocation { get; set; }

        [MaxLength(5000)]
        public string? OrderInputText { get; set; }

        public IFormFile? OrderInputFile { get; set; }
    }
}

