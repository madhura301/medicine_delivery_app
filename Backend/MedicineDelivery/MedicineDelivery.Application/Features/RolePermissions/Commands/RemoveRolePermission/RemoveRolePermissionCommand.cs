using MediatR;

namespace MedicineDelivery.Application.Features.RolePermissions.Commands.RemoveRolePermission
{
    public class RemoveRolePermissionCommand : IRequest<bool>
    {
        public string RoleId { get; set; } = string.Empty;
        public int PermissionId { get; set; }
    }
}
