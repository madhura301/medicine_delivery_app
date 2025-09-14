using MedicineDelivery.Domain.Entities;

namespace MedicineDelivery.Domain.Interfaces
{
    public interface IPermissionService
    {
        Task<bool> HasPermissionAsync(string userId, string permissionName);
        Task<List<Permission>> GetUserPermissionsAsync(string userId);
        Task<bool> GrantPermissionAsync(string userId, int permissionId, string grantedBy);
        Task<bool> RevokePermissionAsync(string userId, int permissionId);
        Task<List<Permission>> GetAllPermissionsAsync();
    }
}
