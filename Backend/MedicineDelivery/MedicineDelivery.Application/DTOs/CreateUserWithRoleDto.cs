using System.ComponentModel.DataAnnotations;

namespace MedicineDelivery.Application.DTOs
{
    public class CreateUserWithRoleDto
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        [MinLength(6)]
        public string Password { get; set; } = string.Empty;

        [Required]
        public string FirstName { get; set; } = string.Empty;

        [Required]
        public string LastName { get; set; } = string.Empty;

        [Required]
        [Range(1, 5, ErrorMessage = "Role must be between 1 and 5")]
        public int RoleId { get; set; }

        public string? PhoneNumber { get; set; }

        public bool EmailConfirmed { get; set; } = false;

        public bool IsActive { get; set; } = true;
    }

    public class CreateUserWithRoleResponseDto
    {
        public string Id { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public int RoleId { get; set; }
        public string RoleName { get; set; } = string.Empty;
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
