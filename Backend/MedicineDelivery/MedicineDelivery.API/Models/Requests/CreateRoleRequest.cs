using System.ComponentModel.DataAnnotations;

namespace MedicineDelivery.API.Models.Requests
{
    public class CreateRoleRequest
    {
        [Required]
        [MaxLength(256)]
        public string Name { get; set; } = string.Empty;
    }
}

