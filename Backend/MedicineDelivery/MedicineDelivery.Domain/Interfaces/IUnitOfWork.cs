using MedicineDelivery.Domain.Entities;

namespace MedicineDelivery.Domain.Interfaces
{
    public interface IUnitOfWork : IDisposable
    {
        IRepository<Permission> Permissions { get; }
        IRepository<RolePermission> RolePermissions { get; }
        IRepository<Product> Products { get; }
        IRepository<MedicalStore> MedicalStores { get; }
        IRepository<CustomerSupport> CustomerSupports { get; }
        IRepository<Manager> Managers { get; }
        IRepository<Customer> Customers { get; }
        IRepository<CustomerAddress> CustomerAddresses { get; }
        
        Task<int> SaveChangesAsync();
        Task BeginTransactionAsync();
        Task CommitTransactionAsync();
        Task RollbackTransactionAsync();
    }
}
