using MediatR;
using MedicineDelivery.Application.DTOs;

namespace MedicineDelivery.Application.Features.RolePermissions.Commands.AddRolePermission
{
    public class AddRolePermissionCommand : IRequest<RolePermissionResponseDto>
    {
        public int RoleId { get; set; }
        public int PermissionId { get; set; }
        public bool IsActive { get; set; } = true;
        public string? GrantedBy { get; set; }
    }
}
