using System.ComponentModel.DataAnnotations;

namespace MedicineDelivery.API.Models.Requests
{
    public class CreatePermissionRequest
    {
        [Required]
        [MaxLength(256)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(100)]
        public string? Module { get; set; }

        [MaxLength(500)]
        public string? Description { get; set; }
    }
}

