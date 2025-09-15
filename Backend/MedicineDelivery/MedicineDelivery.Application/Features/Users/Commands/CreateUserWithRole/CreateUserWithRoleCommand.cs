using MediatR;
using MedicineDelivery.Application.DTOs;

namespace MedicineDelivery.Application.Features.Users.Commands.CreateUserWithRole
{
    public class CreateUserWithRoleCommand : IRequest<CreateUserWithRoleResponseDto>
    {
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public int RoleId { get; set; }
        public string? PhoneNumber { get; set; }
        public bool EmailConfirmed { get; set; } = false;
        public bool IsActive { get; set; } = true;
    }
}
