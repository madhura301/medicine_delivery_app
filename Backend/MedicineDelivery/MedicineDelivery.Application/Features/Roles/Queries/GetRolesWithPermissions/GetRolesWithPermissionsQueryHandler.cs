using MediatR;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Domain.Interfaces;

namespace MedicineDelivery.Application.Features.Roles.Queries.GetRolesWithPermissions
{
    public class GetRolesWithPermissionsQueryHandler : IRequestHandler<GetRolesWithPermissionsQuery, RolesWithPermissionsResponseDto>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IRoleService _roleService;

        public GetRolesWithPermissionsQueryHandler(IUnitOfWork unitOfWork, IRoleService roleService)
        {
            _unitOfWork = unitOfWork;
            _roleService = roleService;
        }

        public async Task<RolesWithPermissionsResponseDto> Handle(GetRolesWithPermissionsQuery request, CancellationToken cancellationToken)
        {
            // Get all roles (using Identity roles)
            var allRoleNames = await _roleService.GetAllRolesAsync();

            // Get all permissions
            var allPermissions = await _unitOfWork.Permissions.GetAllAsync();
            var activePermissions = allPermissions.Where(p => p.IsActive).ToList();

            // Get all role-permissions
            var allRolePermissions = await _unitOfWork.RolePermissions.GetAllAsync();
            var activeRolePermissions = allRolePermissions.Where(rp => rp.IsActive).ToList();

            var rolesWithPermissions = allRoleNames.Select(roleName =>
            {
                // Find the role ID for this role name
                var rolePermissionIds = activeRolePermissions
                    .Where(rp => rp.RoleId == roleName) // RoleId is now string
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
                    Id = 0, // Using 0 as placeholder since Identity roles use string IDs but DTO expects int
                    Name = roleName,
                    Description = $"Role: {roleName}", // Identity roles don't have descriptions
                    CreatedAt = DateTime.UtcNow, // Identity roles don't track creation date
                    IsActive = true, // All Identity roles are considered active
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
