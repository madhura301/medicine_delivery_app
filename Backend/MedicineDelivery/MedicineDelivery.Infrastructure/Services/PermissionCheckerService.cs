using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.Domain.Interfaces;
using Microsoft.AspNetCore.Identity;
using System.Security.Claims;

namespace MedicineDelivery.Infrastructure.Services
{
    public class PermissionCheckerService : IPermissionCheckerService
    {
        private readonly IRoleService _roleService;

        public PermissionCheckerService(IRoleService roleService)
        {
            _roleService = roleService;
        }

        public async Task<bool> HasPermissionAsync(string userId, string permissionName)
        {
            try
            {
                return await _roleService.HasPermissionAsync(userId, permissionName);
            }
            catch
            {
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
            catch
            {
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
            catch
            {
                return false;
            }
        }
    }
}
