using System.Security.Claims;

namespace MedicineDelivery.Application.Interfaces
{
    public interface IPermissionCheckerService
    {
        /// <summary>
        /// Checks if a user has a specific permission
        /// </summary>
        /// <param name="userId">The user ID to check</param>
        /// <param name="permissionName">The permission name to check for</param>
        /// <returns>True if user has the permission, false otherwise</returns>
        Task<bool> HasPermissionAsync(string userId, string permissionName);

        /// <summary>
        /// Gets all permissions for a given user
        /// </summary>
        /// <param name="userId">The user ID</param>
        /// <returns>List of permission names</returns>
        Task<List<string>> GetPermissionsByUserIdAsync(string userId);

        /// <summary>
        /// Checks if the current user (from ClaimsPrincipal) has a specific permission
        /// </summary>
        /// <param name="user">The ClaimsPrincipal representing the current user</param>
        /// <param name="permissionName">The permission name to check for</param>
        /// <returns>True if user has the permission, false otherwise</returns>
        Task<bool> HasPermissionAsync(ClaimsPrincipal user, string permissionName);
    }
}
