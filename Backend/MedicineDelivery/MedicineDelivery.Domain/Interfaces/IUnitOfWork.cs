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
        IRepository<Order> Orders { get; }
        IRepository<OrderAssignmentHistory> OrderAssignmentHistories { get; }
        IRepository<Payment> Payments { get; }
        IRepository<Delivery> Deliveries { get; }
        IRepository<CustomerSupportRegion> CustomerSupportRegions { get; }
        IRepository<CustomerSupportRegionPinCode> CustomerSupportRegionPinCodes { get; }
        
        Task<int> SaveChangesAsync();
        Task BeginTransactionAsync();
        Task CommitTransactionAsync();
        Task RollbackTransactionAsync();
    }
}
