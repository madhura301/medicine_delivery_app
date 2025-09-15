using MediatR;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Domain.Interfaces;

namespace MedicineDelivery.Application.Features.Roles.Queries.GetRolesWithPermissions
{
    public class GetRolesWithPermissionsQueryHandler : IRequestHandler<GetRolesWithPermissionsQuery, RolesWithPermissionsResponseDto>
    {
        private readonly IUnitOfWork _unitOfWork;

        public GetRolesWithPermissionsQueryHandler(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<RolesWithPermissionsResponseDto> Handle(GetRolesWithPermissionsQuery request, CancellationToken cancellationToken)
        {
            // Get all roles
            var allRoles = await _unitOfWork.Roles.GetAllAsync();
            var roles = request.IncludeInactiveRoles 
                ? allRoles 
                : allRoles.Where(r => r.IsActive).ToList();

            // Get all permissions
            var allPermissions = await _unitOfWork.Permissions.GetAllAsync();
            var activePermissions = allPermissions.Where(p => p.IsActive).ToList();

            // Get all role-permissions
            var allRolePermissions = await _unitOfWork.RolePermissions.GetAllAsync();
            var activeRolePermissions = allRolePermissions.Where(rp => rp.IsActive).ToList();

            var rolesWithPermissions = roles.Select(role =>
            {
                var rolePermissionIds = activeRolePermissions
                    .Where(rp => rp.RoleId == role.Id)
                    .Select(rp => rp.PermissionId)
                    .ToList();

                var rolePermissions = activePermissions
                    .Where(p => rolePermissionIds.Contains(p.Id))
                    .Select(p => new PermissionDto
                    {
                        Id = p.Id,
                        Name = p.Name,
                        Description = p.Description,
                        Module = p.Module,
                        CreatedAt = p.CreatedAt,
                        IsActive = p.IsActive
                    })
                    .ToList();

                return new RoleWithPermissionsDto
                {
                    Id = role.Id,
                    Name = role.Name,
                    Description = role.Description,
                    CreatedAt = role.CreatedAt,
                    IsActive = role.IsActive,
                    Permissions = rolePermissions
                };
            }).ToList();

            return new RolesWithPermissionsResponseDto
            {
                Roles = rolesWithPermissions,
                TotalCount = rolesWithPermissions.Count
            };
        }
    }
}
