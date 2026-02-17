using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.Domain.Interfaces;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;
using System.Security.Claims;

namespace MedicineDelivery.Infrastructure.Services
{
    public class PermissionCheckerService : IPermissionCheckerService
    {
        private readonly IRoleService _roleService;
        private readonly ILogger<PermissionCheckerService> _logger;

        public PermissionCheckerService(IRoleService roleService, ILogger<PermissionCheckerService> logger)
        {
            _roleService = roleService;
            _logger = logger;
        }

        public async Task<bool> HasPermissionAsync(string userId, string permissionName)
        {
            try
            {
                return await _roleService.HasPermissionAsync(userId, permissionName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking permission {PermissionName} for user {UserId}. Returning false", permissionName, userId);
                return false;
            }
        }

        public async Task<List<string>> GetPermissionsByUserIdAsync(string userId)
        {
            try
            {
                var permissions = await _roleService.GetUserPermissionsAsync(userId);
                return permissions.Select(p => p.Name).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving permissions for user {UserId}. Returning empty list", userId);
                return new List<string>();
            }
        }

        public async Task<bool> HasPermissionAsync(ClaimsPrincipal user, string permissionName)
        {
            try
            {
                var userId = user.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId)) return false;

                return await HasPermissionAsync(userId, permissionName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking permission {PermissionName} for claims principal. Returning false", permissionName);
                return false;
            }
        }
    }
}
