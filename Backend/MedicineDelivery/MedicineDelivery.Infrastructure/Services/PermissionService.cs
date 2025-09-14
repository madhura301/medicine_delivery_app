using Microsoft.EntityFrameworkCore;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Domain.Interfaces;

namespace MedicineDelivery.Infrastructure.Services
{
    public class PermissionService : IPermissionService
    {
        private readonly IRoleService _roleService;

        public PermissionService(IRoleService roleService)
        {
            _roleService = roleService;
        }

        public async Task<bool> HasPermissionAsync(string userId, string permissionName)
        {
            return await _roleService.HasPermissionAsync(userId, permissionName);
        }

        public async Task<List<Permission>> GetUserPermissionsAsync(string userId)
        {
            return await _roleService.GetUserPermissionsAsync(userId);
        }

        public async Task<bool> GrantPermissionAsync(string userId, int permissionId, string grantedBy)
        {
            // This method is now deprecated in favor of role-based permissions
            // Permissions should be granted through roles, not directly to users
            throw new NotImplementedException("Direct permission granting is not supported. Use role-based permissions instead.");
        }

        public async Task<bool> RevokePermissionAsync(string userId, int permissionId)
        {
            // This method is now deprecated in favor of role-based permissions
            // Permissions should be revoked through roles, not directly from users
            throw new NotImplementedException("Direct permission revoking is not supported. Use role-based permissions instead.");
        }

        public async Task<List<Permission>> GetAllPermissionsAsync()
        {
            return await _roleService.GetAllPermissionsAsync();
        }
    }
}
