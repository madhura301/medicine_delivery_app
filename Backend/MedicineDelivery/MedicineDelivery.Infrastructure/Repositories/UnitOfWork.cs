using Microsoft.EntityFrameworkCore;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Domain.Interfaces;
using MedicineDelivery.Infrastructure.Data;

namespace MedicineDelivery.Infrastructure.Repositories
{
    public class UnitOfWork : IUnitOfWork
    {
        private readonly ApplicationDbContext _context;
        private IRepository<User>? _users;
        private IRepository<Permission>? _permissions;
        private IRepository<Role>? _roles;
        private IRepository<UserRole>? _userRoles;
        private IRepository<RolePermission>? _rolePermissions;
        private IRepository<Product>? _products;
        private IRepository<Order>? _orders;
        private IRepository<OrderItem>? _orderItems;
        private IRepository<MedicalStore>? _medicalStores;

        public UnitOfWork(ApplicationDbContext context)
        {
            _context = context;
        }

        public IRepository<User> Users => _users ??= new Repository<User>(_context);
        public IRepository<Permission> Permissions => _permissions ??= new Repository<Permission>(_context);
        public IRepository<Role> Roles => _roles ??= new Repository<Role>(_context);
        public IRepository<UserRole> UserRoles => _userRoles ??= new Repository<UserRole>(_context);
        public IRepository<RolePermission> RolePermissions => _rolePermissions ??= new Repository<RolePermission>(_context);
        public IRepository<Product> Products => _products ??= new Repository<Product>(_context);
        public IRepository<Order> Orders => _orders ??= new Repository<Order>(_context);
        public IRepository<OrderItem> OrderItems => _orderItems ??= new Repository<OrderItem>(_context);
        public IRepository<MedicalStore> MedicalStores => _medicalStores ??= new Repository<MedicalStore>(_context);

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
