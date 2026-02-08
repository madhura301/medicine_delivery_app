using Microsoft.EntityFrameworkCore;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Domain.Interfaces;
using MedicineDelivery.Infrastructure.Data;

namespace MedicineDelivery.Infrastructure.Repositories
{
    public class UnitOfWork : IUnitOfWork
    {
        private readonly ApplicationDbContext _context;
        private IRepository<Permission>? _permissions;
        private IRepository<RolePermission>? _rolePermissions;
        private IRepository<Product>? _products;
        private IRepository<MedicalStore>? _medicalStores;
        private IRepository<CustomerSupport>? _customerSupports;
        private IRepository<Manager>? _managers;
        private IRepository<Customer>? _customers;
        private IRepository<CustomerAddress>? _customerAddresses;
        private IRepository<Order>? _orders;
        private IRepository<OrderAssignmentHistory>? _orderAssignmentHistories;
        private IRepository<Payment>? _payments;
        private IRepository<Delivery>? _deliveries;
        private IRepository<ServiceRegion>? _serviceRegions;
        private IRepository<ServiceRegionPinCode>? _serviceRegionPinCodes;
        private IRepository<Consent>? _consents;
        private IRepository<ConsentLog>? _consentLogs;

        public UnitOfWork(ApplicationDbContext context)
        {
            _context = context;
        }

        public IRepository<Permission> Permissions => _permissions ??= new Repository<Permission>(_context);
        public IRepository<RolePermission> RolePermissions => _rolePermissions ??= new Repository<RolePermission>(_context);
        public IRepository<Product> Products => _products ??= new Repository<Product>(_context);
        public IRepository<MedicalStore> MedicalStores => _medicalStores ??= new Repository<MedicalStore>(_context);
        public IRepository<CustomerSupport> CustomerSupports => _customerSupports ??= new Repository<CustomerSupport>(_context);
        public IRepository<Manager> Managers => _managers ??= new Repository<Manager>(_context);
        public IRepository<Customer> Customers => _customers ??= new Repository<Customer>(_context);
        public IRepository<CustomerAddress> CustomerAddresses => _customerAddresses ??= new Repository<CustomerAddress>(_context);
        public IRepository<Order> Orders => _orders ??= new Repository<Order>(_context);
        public IRepository<OrderAssignmentHistory> OrderAssignmentHistories => _orderAssignmentHistories ??= new Repository<OrderAssignmentHistory>(_context);
        public IRepository<Payment> Payments => _payments ??= new Repository<Payment>(_context);
        public IRepository<Delivery> Deliveries => _deliveries ??= new Repository<Delivery>(_context);
        public IRepository<ServiceRegion> ServiceRegions => _serviceRegions ??= new Repository<ServiceRegion>(_context);
        public IRepository<ServiceRegionPinCode> ServiceRegionPinCodes => _serviceRegionPinCodes ??= new Repository<ServiceRegionPinCode>(_context);
        public IRepository<Consent> Consents => _consents ??= new Repository<Consent>(_context);
        public IRepository<ConsentLog> ConsentLogs => _consentLogs ??= new Repository<ConsentLog>(_context);

        public async Task<int> SaveChangesAsync()
        {
            return await _context.SaveChangesAsync();
        }

        public async Task BeginTransactionAsync()
        {
            await _context.Database.BeginTransactionAsync();
        }

        public async Task CommitTransactionAsync()
        {
            await _context.Database.CommitTransactionAsync();
        }

        public async Task RollbackTransactionAsync()
        {
            await _context.Database.RollbackTransactionAsync();
        }

        public void Dispose()
        {
            _context.Dispose();
        }
    }
}
