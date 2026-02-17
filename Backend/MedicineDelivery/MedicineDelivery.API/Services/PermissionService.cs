using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using MedicineDelivery.Infrastructure.Data;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Domain.Interfaces;

namespace MedicineDelivery.API.Services
{
    public class PermissionService : IPermissionService
    {
        private readonly IRoleService _roleService;
        private readonly ILogger<PermissionService> _logger;

        public PermissionService(IRoleService roleService, ILogger<PermissionService> logger)
        {
            _roleService = roleService;
            _logger = logger;
        }

        public async Task<bool> HasPermissionAsync(string userId, string permissionName)
        {
            var result = await _roleService.HasPermissionAsync(userId, permissionName);
            _logger.LogDebug("Permission check: UserId {UserId}, Permission '{PermissionName}', Result: {Result}", userId, permissionName, result);
            return result;
        }

        public async Task<List<Permission>> GetUserPermissionsAsync(string userId)
        {
            var permissions = await _roleService.GetUserPermissionsAsync(userId);
            _logger.LogDebug("Retrieved {Count} permissions for UserId {UserId}", permissions.Count, userId);
            return permissions;
        }

        public async Task<bool> GrantPermissionAsync(string userId, int permissionId, string grantedBy)
        {
            // This method is now deprecated in favor of role-based permissions
            // Permissions should be granted through roles, not directly to users
            _logger.LogWarning("Deprecated method GrantPermissionAsync called for UserId {UserId}, PermissionId {PermissionId}", userId, permissionId);
            throw new NotImplementedException("Direct permission granting is not supported. Use role-based permissions instead.");
        }

        public async Task<bool> RevokePermissionAsync(string userId, int permissionId)
        {
            // This method is now deprecated in favor of role-based permissions
            // Permissions should be revoked through roles, not directly from users
            _logger.LogWarning("Deprecated method RevokePermissionAsync called for UserId {UserId}, PermissionId {PermissionId}", userId, permissionId);
            throw new NotImplementedException("Direct permission revoking is not supported. Use role-based permissions instead.");
        }
    }
}
