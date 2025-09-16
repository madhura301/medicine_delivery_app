using MedicineDelivery.Domain.Entities;

namespace MedicineDelivery.Domain.Interfaces
{
    public interface IUnitOfWork : IDisposable
    {
        IRepository<User> Users { get; }
        IRepository<Permission> Permissions { get; }
        IRepository<Role> Roles { get; }
        IRepository<UserRole> UserRoles { get; }
        IRepository<RolePermission> RolePermissions { get; }
        IRepository<Product> Products { get; }
        IRepository<Order> Orders { get; }
        IRepository<OrderItem> OrderItems { get; }
        IRepository<MedicalStore> MedicalStores { get; }
        
        Task<int> SaveChangesAsync();
        Task BeginTransactionAsync();
        Task CommitTransactionAsync();
        Task RollbackTransactionAsync();
    }
}
