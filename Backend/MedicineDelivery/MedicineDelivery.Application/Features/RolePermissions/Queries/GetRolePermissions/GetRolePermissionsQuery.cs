using MediatR;
using MedicineDelivery.Application.DTOs;

namespace MedicineDelivery.Application.Features.RolePermissions.Queries.GetRolePermissions
{
    public class GetRolePermissionsQuery : IRequest<RolePermissionsListDto>
    {
        public string RoleId { get; set; } = string.Empty;
    }
}
