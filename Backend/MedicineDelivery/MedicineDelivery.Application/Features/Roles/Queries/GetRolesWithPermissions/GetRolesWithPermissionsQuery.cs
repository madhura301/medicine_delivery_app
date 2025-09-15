using MediatR;
using MedicineDelivery.Application.DTOs;

namespace MedicineDelivery.Application.Features.Roles.Queries.GetRolesWithPermissions
{
    public class GetRolesWithPermissionsQuery : IRequest<RolesWithPermissionsResponseDto>
    {
        public bool IncludeInactiveRoles { get; set; } = false;
    }
}
