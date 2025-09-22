using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using MedicineDelivery.Domain.Entities;

namespace MedicineDelivery.Infrastructure.Data
{
    public class ApplicationDbContext : IdentityDbContext<ApplicationUser>
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {
        }

        public new DbSet<User> Users { get; set; }
        public DbSet<Permission> Permissions { get; set; }
        public new DbSet<Role> Roles { get; set; }
        public new DbSet<UserRole> UserRoles { get; set; }
        public DbSet<RolePermission> RolePermissions { get; set; }
        public DbSet<Product> Products { get; set; }
        public DbSet<Order> Orders { get; set; }
        public DbSet<OrderItem> OrderItems { get; set; }
        public DbSet<MedicalStore> MedicalStores { get; set; }
        public DbSet<CustomerSupport> CustomerSupports { get; set; }
        public DbSet<Manager> Managers { get; set; }
        public DbSet<Customer> Customers { get; set; }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            // Configure UserRole entity
            builder.Entity<UserRole>()
                .HasKey(ur => new { ur.UserId, ur.RoleId });

            builder.Entity<UserRole>()
                .HasOne(ur => ur.User)
                .WithMany(u => u.UserRoles)
                .HasForeignKey(ur => ur.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.Entity<UserRole>()
                .HasOne(ur => ur.Role)
                .WithMany(r => r.UserRoles)
                .HasForeignKey(ur => ur.RoleId)
                .OnDelete(DeleteBehavior.Cascade);

            // Configure RolePermission entity
            builder.Entity<RolePermission>()
                .HasKey(rp => new { rp.RoleId, rp.PermissionId });

            builder.Entity<RolePermission>()
                .HasOne(rp => rp.Role)
                .WithMany(r => r.RolePermissions)
                .HasForeignKey(rp => rp.RoleId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.Entity<RolePermission>()
                .HasOne(rp => rp.Permission)
                .WithMany(p => p.RolePermissions)
                .HasForeignKey(rp => rp.PermissionId)
                .OnDelete(DeleteBehavior.Cascade);

            // Configure OrderItem entity
            builder.Entity<OrderItem>()
                .HasOne(oi => oi.Order)
                .WithMany(o => o.OrderItems)
                .HasForeignKey(oi => oi.OrderId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.Entity<OrderItem>()
                .HasOne(oi => oi.Product)
                .WithMany()
                .HasForeignKey(oi => oi.ProductId)
                .OnDelete(DeleteBehavior.Restrict);

            // Configure MedicalStore entity
            builder.Entity<MedicalStore>()
                .HasKey(ms => ms.MedicalStoreId);

            builder.Entity<MedicalStore>()
                .Property(ms => ms.MedicalStoreId)
                .HasDefaultValueSql("NEWID()");

            builder.Entity<MedicalStore>()
                .Property(ms => ms.MedicalName)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<MedicalStore>()
                .Property(ms => ms.OwnerFirstName)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<MedicalStore>()
                .Property(ms => ms.OwnerLastName)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<MedicalStore>()
                .Property(ms => ms.OwnerMiddleName)
                .HasMaxLength(100);

            // Address fields
            builder.Entity<MedicalStore>()
                .Property(ms => ms.AddressLine1)
                .HasMaxLength(300)
                .IsRequired();

            builder.Entity<MedicalStore>()
                .Property(ms => ms.AddressLine2)
                .HasMaxLength(300);

            builder.Entity<MedicalStore>()
                .Property(ms => ms.City)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<MedicalStore>()
                .Property(ms => ms.State)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<MedicalStore>()
                .Property(ms => ms.PostalCode)
                .HasMaxLength(20)
                .IsRequired();

            builder.Entity<MedicalStore>()
                .Property(ms => ms.Latitude)
                .HasColumnType("decimal(18,6)");

            builder.Entity<MedicalStore>()
                .Property(ms => ms.Longitude)
                .HasColumnType("decimal(18,6)");

            builder.Entity<MedicalStore>()
                .Property(ms => ms.MobileNumber)
                .HasMaxLength(15)
                .IsRequired();

            builder.Entity<MedicalStore>()
                .Property(ms => ms.EmailId)
                .HasMaxLength(50)
                .IsRequired();

            builder.Entity<MedicalStore>()
                .Property(ms => ms.AlternativeMobileNumber)
                .HasMaxLength(15);

            // Registration and tax information
            builder.Entity<MedicalStore>()
                .Property(ms => ms.RegistrationStatus)
                .IsRequired();

            builder.Entity<MedicalStore>()
                .Property(ms => ms.GSTIN)
                .HasMaxLength(100);

            builder.Entity<MedicalStore>()
                .Property(ms => ms.PAN)
                .HasMaxLength(100);

            builder.Entity<MedicalStore>()
                .Property(ms => ms.FSSAINo)
                .HasMaxLength(100);

            builder.Entity<MedicalStore>()
                .Property(ms => ms.DLNo)
                .HasMaxLength(100);

            // Pharmacist information
            builder.Entity<MedicalStore>()
                .Property(ms => ms.PharmacistFirstName)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<MedicalStore>()
                .Property(ms => ms.PharmacistLastName)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<MedicalStore>()
                .Property(ms => ms.PharmacistRegistrationNumber)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<MedicalStore>()
                .Property(ms => ms.PharmacistMobileNumber)
                .HasMaxLength(15)
                .IsRequired();

            builder.Entity<MedicalStore>()
                .Property(ms => ms.CreatedOn)
                .HasColumnType("datetime2(7)");

            builder.Entity<MedicalStore>()
                .Property(ms => ms.UpdatedOn)
                .HasColumnType("datetime2(7)");

            builder.Entity<MedicalStore>()
                .HasOne(ms => ms.User)
                .WithMany()
                .HasForeignKey(ms => ms.UserId)
                .OnDelete(DeleteBehavior.SetNull);

            // Configure CustomerSupport entity
            builder.Entity<CustomerSupport>()
                .HasKey(cs => cs.CustomerSupportId);

            builder.Entity<CustomerSupport>()
                .Property(cs => cs.CustomerSupportId)
                .HasDefaultValueSql("NEWID()");

            builder.Entity<CustomerSupport>()
                .Property(cs => cs.CustomerSupportFirstName)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<CustomerSupport>()
                .Property(cs => cs.CustomerSupportLastName)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<CustomerSupport>()
                .Property(cs => cs.CustomerSupportMiddleName)
                .HasMaxLength(100);

            builder.Entity<CustomerSupport>()
                .Property(cs => cs.Address)
                .HasMaxLength(300)
                .IsRequired();

            builder.Entity<CustomerSupport>()
                .Property(cs => cs.City)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<CustomerSupport>()
                .Property(cs => cs.State)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<CustomerSupport>()
                .Property(cs => cs.MobileNumber)
                .HasMaxLength(15)
                .IsRequired();

            builder.Entity<CustomerSupport>()
                .Property(cs => cs.EmailId)
                .HasMaxLength(50)
                .IsRequired();

            builder.Entity<CustomerSupport>()
                .Property(cs => cs.AlternativeMobileNumber)
                .HasMaxLength(15);

            // Employee and photo information
            builder.Entity<CustomerSupport>()
                .Property(cs => cs.EmployeeId)
                .HasMaxLength(50)
                .IsRequired();

            builder.Entity<CustomerSupport>()
                .Property(cs => cs.CustomerSupportPhoto)
                .HasMaxLength(255);

            builder.Entity<CustomerSupport>()
                .Property(cs => cs.CreatedOn)
                .HasColumnType("datetime2(7)");

            builder.Entity<CustomerSupport>()
                .Property(cs => cs.UpdatedOn)
                .HasColumnType("datetime2(7)");

            builder.Entity<CustomerSupport>()
                .HasOne(cs => cs.User)
                .WithMany()
                .HasForeignKey(cs => cs.UserId)
                .OnDelete(DeleteBehavior.SetNull);

            // Configure Manager entity
            builder.Entity<Manager>()
                .HasKey(m => m.ManagerId);

            builder.Entity<Manager>()
                .Property(m => m.ManagerId)
                .HasDefaultValueSql("NEWID()");

            builder.Entity<Manager>()
                .Property(m => m.ManagerFirstName)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<Manager>()
                .Property(m => m.ManagerLastName)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<Manager>()
                .Property(m => m.ManagerMiddleName)
                .HasMaxLength(100);

            builder.Entity<Manager>()
                .Property(m => m.Address)
                .HasMaxLength(300)
                .IsRequired();

            builder.Entity<Manager>()
                .Property(m => m.City)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<Manager>()
                .Property(m => m.State)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<Manager>()
                .Property(m => m.MobileNumber)
                .HasMaxLength(15)
                .IsRequired();

            builder.Entity<Manager>()
                .Property(m => m.EmailId)
                .HasMaxLength(50)
                .IsRequired();

            builder.Entity<Manager>()
                .Property(m => m.AlternativeMobileNumber)
                .HasMaxLength(15);

            // Employee and photo information
            builder.Entity<Manager>()
                .Property(m => m.EmployeeId)
                .HasMaxLength(50)
                .IsRequired();

            builder.Entity<Manager>()
                .Property(m => m.ManagerPhoto)
                .HasMaxLength(255);

            builder.Entity<Manager>()
                .Property(m => m.CreatedOn)
                .HasColumnType("datetime2(7)");

            builder.Entity<Manager>()
                .Property(m => m.UpdatedOn)
                .HasColumnType("datetime2(7)");

            builder.Entity<Manager>()
                .HasOne(m => m.User)
                .WithMany()
                .HasForeignKey(m => m.UserId)
                .OnDelete(DeleteBehavior.SetNull);

            // Configure Customer entity
            builder.Entity<Customer>()
                .HasKey(c => c.CustomerId);

            builder.Entity<Customer>()
                .Property(c => c.CustomerId)
                .HasDefaultValueSql("NEWID()");

            builder.Entity<Customer>()
                .Property(c => c.CustomerFirstName)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<Customer>()
                .Property(c => c.CustomerLastName)
                .HasMaxLength(100)
                .IsRequired();

            builder.Entity<Customer>()
                .Property(c => c.CustomerMiddleName)
                .HasMaxLength(100);

            builder.Entity<Customer>()
                .Property(c => c.MobileNumber)
                .HasMaxLength(15)
                .IsRequired();

            builder.Entity<Customer>()
                .Property(c => c.AlternativeMobileNumber)
                .HasMaxLength(15);

            builder.Entity<Customer>()
                .Property(c => c.EmailId)
                .HasMaxLength(50);

            builder.Entity<Customer>()
                .Property(c => c.Address)
                .HasMaxLength(300);

            builder.Entity<Customer>()
                .Property(c => c.City)
                .HasMaxLength(100);

            builder.Entity<Customer>()
                .Property(c => c.State)
                .HasMaxLength(100);

            builder.Entity<Customer>()
                .Property(c => c.PostalCode)
                .HasMaxLength(20);

            builder.Entity<Customer>()
                .Property(c => c.Gender)
                .HasMaxLength(10);

            builder.Entity<Customer>()
                .Property(c => c.CustomerPhoto)
                .HasMaxLength(255);

            builder.Entity<Customer>()
                .Property(c => c.CreatedOn)
                .HasColumnType("datetime2(7)");

            builder.Entity<Customer>()
                .Property(c => c.UpdatedOn)
                .HasColumnType("datetime2(7)");

            builder.Entity<Customer>()
                .HasOne(c => c.User)
                .WithMany()
                .HasForeignKey(c => c.UserId)
                .OnDelete(DeleteBehavior.SetNull);

            // Seed permissions
            builder.Entity<Permission>().HasData(
                // Original permissions
                new Permission { Id = 1, Name = "ReadUsers", Description = "Can view user information", Module = "Users", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 2, Name = "CreateUsers", Description = "Can create new users", Module = "Users", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 3, Name = "UpdateUsers", Description = "Can update user information", Module = "Users", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 4, Name = "DeleteUsers", Description = "Can delete users", Module = "Users", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 5, Name = "ReadProducts", Description = "Can view products", Module = "Products", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 6, Name = "CreateProducts", Description = "Can create new products", Module = "Products", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 7, Name = "UpdateProducts", Description = "Can update products", Module = "Products", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 8, Name = "DeleteProducts", Description = "Can delete products", Module = "Products", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 9, Name = "ReadOrders", Description = "Can view orders", Module = "Orders", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 10, Name = "CreateOrders", Description = "Can create new orders", Module = "Orders", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 11, Name = "UpdateOrders", Description = "Can update orders", Module = "Orders", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 12, Name = "DeleteOrders", Description = "Can delete orders", Module = "Orders", CreatedAt = DateTime.UtcNow, IsActive = true },
                
                // Admin User Management Permissions
                new Permission { Id = 13, Name = "AdminReadUsers", Description = "Admin can view all user information", Module = "UserManagement", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 14, Name = "AdminCreateUsers", Description = "Admin can create users", Module = "UserManagement", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 15, Name = "AdminUpdateUsers", Description = "Admin can update user information", Module = "UserManagement", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 16, Name = "AdminDeleteUsers", Description = "Admin can delete users", Module = "UserManagement", CreatedAt = DateTime.UtcNow, IsActive = true },
                
                // Manager User Management Permissions
                new Permission { Id = 17, Name = "ManagerReadUsers", Description = "Manager can view user information", Module = "UserManagement", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 18, Name = "ManagerCreateUsers", Description = "Manager can create users", Module = "UserManagement", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 19, Name = "ManagerUpdateUsers", Description = "Manager can update user information", Module = "UserManagement", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 20, Name = "ManagerDeleteUsers", Description = "Manager can delete users", Module = "UserManagement", CreatedAt = DateTime.UtcNow, IsActive = true },
                
                // CustomerSupport User Management Permissions
                new Permission { Id = 21, Name = "CustomerSupportReadUsers", Description = "CustomerSupport can view user information", Module = "UserManagement", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 22, Name = "CustomerSupportCreateUsers", Description = "CustomerSupport can create users", Module = "UserManagement", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 23, Name = "CustomerSupportUpdateUsers", Description = "CustomerSupport can update user information", Module = "UserManagement", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 24, Name = "CustomerSupportDeleteUsers", Description = "CustomerSupport can delete users", Module = "UserManagement", CreatedAt = DateTime.UtcNow, IsActive = true },
                
                // Chemist User Management Permissions
                new Permission { Id = 25, Name = "ChemistReadUsers", Description = "Chemist can view user information", Module = "UserManagement", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 26, Name = "ChemistCreateUsers", Description = "Chemist can create users", Module = "UserManagement", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 27, Name = "ChemistUpdateUsers", Description = "Chemist can update user information", Module = "UserManagement", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 28, Name = "ChemistDeleteUsers", Description = "Chemist can delete users", Module = "UserManagement", CreatedAt = DateTime.UtcNow, IsActive = true },
                
                // Role Permission Management Permission
                new Permission { Id = 29, Name = "ManageRolePermission", Description = "Can manage role permissions", Module = "RoleManagement", CreatedAt = DateTime.UtcNow, IsActive = true },
                
                // Chemist CRUD Permissions
                new Permission { Id = 30, Name = "ChemistRead", Description = "Can read chemist information", Module = "Chemist", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 31, Name = "ChemistCreate", Description = "Can create chemist accounts", Module = "Chemist", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 32, Name = "ChemistUpdate", Description = "Can update chemist information", Module = "Chemist", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 33, Name = "ChemistDelete", Description = "Can delete chemist accounts", Module = "Chemist", CreatedAt = DateTime.UtcNow, IsActive = true },
                
                // CustomerSupport CRUD Permissions
                new Permission { Id = 34, Name = "CustomerSupportRead", Description = "Can read customer support information", Module = "CustomerSupport", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 35, Name = "CustomerSupportCreate", Description = "Can create customer support accounts", Module = "CustomerSupport", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 36, Name = "CustomerSupportUpdate", Description = "Can update customer support information", Module = "CustomerSupport", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 37, Name = "CustomerSupportDelete", Description = "Can delete customer support accounts", Module = "CustomerSupport", CreatedAt = DateTime.UtcNow, IsActive = true },
                
                // Manager CRUD Permissions
                new Permission { Id = 38, Name = "ManagerSupportRead", Description = "Can read manager information", Module = "Manager", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 39, Name = "ManagerSupportCreate", Description = "Can create manager accounts", Module = "Manager", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 40, Name = "ManagerSupportUpdate", Description = "Can update manager information", Module = "Manager", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 41, Name = "ManagerSupportDelete", Description = "Can delete manager accounts", Module = "Manager", CreatedAt = DateTime.UtcNow, IsActive = true },
                
                // Customer CRUD Permissions (for own records only)
                new Permission { Id = 42, Name = "CustomerRead", Description = "Can read own customer information", Module = "Customer", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 43, Name = "CustomerCreate", Description = "Can create customer accounts", Module = "Customer", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 44, Name = "CustomerUpdate", Description = "Can update own customer information", Module = "Customer", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 45, Name = "CustomerDelete", Description = "Can delete own customer account", Module = "Customer", CreatedAt = DateTime.UtcNow, IsActive = true },
                
                // All Customer CRUD Permissions (for all customer records)
                new Permission { Id = 46, Name = "AllCustomerRead", Description = "Can read all customer information", Module = "Customer", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 47, Name = "AllCustomerUpdate", Description = "Can update any customer information", Module = "Customer", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 48, Name = "AllCustomerDelete", Description = "Can delete any customer account", Module = "Customer", CreatedAt = DateTime.UtcNow, IsActive = true },

                // All Chemist CRUD Permissions (for all Chemist records)
                new Permission { Id = 49, Name = "AllChemistRead", Description = "Can read all Chemist information", Module = "Chemist", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 50, Name = "AllChemistUpdate", Description = "Can update any Chemist information", Module = "Chemist", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Permission { Id = 51, Name = "AllChemistDelete", Description = "Can delete any Chemist account", Module = "Chemist", CreatedAt = DateTime.UtcNow, IsActive = true }
            );

            // Seed roles
            builder.Entity<Role>().HasData(
                new Role { Id = 1, Name = "Admin", Description = "Full system access", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Role { Id = 2, Name = "Manager", Description = "Management level access", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Role { Id = 3, Name = "CustomerSupport", Description = "Customer support access", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Role { Id = 4, Name = "Customer", Description = "Customer access", CreatedAt = DateTime.UtcNow, IsActive = true },
                new Role { Id = 5, Name = "Chemist", Description = "Chemist/pharmacist access", CreatedAt = DateTime.UtcNow, IsActive = true }
            );

            // Seed role-permission mappings
            builder.Entity<RolePermission>().HasData(
                // Admin gets all permissions (including all user management permissions)
                new RolePermission { RoleId = 1, PermissionId = 1, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 2, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 3, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 4, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 5, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 6, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 7, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 8, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 9, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 10, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 11, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 12, GrantedAt = DateTime.UtcNow, IsActive = true },
                // Admin User Management Permissions
                new RolePermission { RoleId = 1, PermissionId = 13, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 14, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 15, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 16, GrantedAt = DateTime.UtcNow, IsActive = true },
                // Manager User Management Permissions
                new RolePermission { RoleId = 1, PermissionId = 17, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 18, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 19, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 20, GrantedAt = DateTime.UtcNow, IsActive = true },
                // CustomerSupport User Management Permissions
                new RolePermission { RoleId = 1, PermissionId = 21, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 22, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 23, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 24, GrantedAt = DateTime.UtcNow, IsActive = true },
                // Chemist User Management Permissions
                new RolePermission { RoleId = 1, PermissionId = 25, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 26, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 27, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 28, GrantedAt = DateTime.UtcNow, IsActive = true },
                // Role Permission Management Permission
                new RolePermission { RoleId = 1, PermissionId = 29, GrantedAt = DateTime.UtcNow, IsActive = true },
                // Chemist CRUD Permissions for Admin
                new RolePermission { RoleId = 1, PermissionId = 30, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 31, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 32, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 33, GrantedAt = DateTime.UtcNow, IsActive = true },
                // CustomerSupport CRUD Permissions for Admin
                new RolePermission { RoleId = 1, PermissionId = 34, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 35, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 36, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 37, GrantedAt = DateTime.UtcNow, IsActive = true },
                // Manager CRUD Permissions for Admin
                new RolePermission { RoleId = 1, PermissionId = 38, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 39, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 40, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 41, GrantedAt = DateTime.UtcNow, IsActive = true },
                // All Customer CRUD Permissions for Admin
                new RolePermission { RoleId = 1, PermissionId = 46, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 47, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 48, GrantedAt = DateTime.UtcNow, IsActive = true },
                // CustomerCreate permission for Admin (can create customers)
                new RolePermission { RoleId = 1, PermissionId = 43, GrantedAt = DateTime.UtcNow, IsActive = true },
                // All MedicalStore CRUD Permissions for Admin
                new RolePermission { RoleId = 1, PermissionId = 49, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 50, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 51, GrantedAt = DateTime.UtcNow, IsActive = true },

                // Manager gets read and update permissions + Manager User Management Permissions
                new RolePermission { RoleId = 2, PermissionId = 1, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 3, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 5, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 7, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 9, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 11, GrantedAt = DateTime.UtcNow, IsActive = true },
                // Manager User Management Permissions
                new RolePermission { RoleId = 2, PermissionId = 17, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 18, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 19, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 20, GrantedAt = DateTime.UtcNow, IsActive = true },
                // CustomerSupport User Management Permissions
                new RolePermission { RoleId = 2, PermissionId = 21, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 22, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 23, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 24, GrantedAt = DateTime.UtcNow, IsActive = true },
                // Chemist User Management Permissions
                new RolePermission { RoleId = 2, PermissionId = 25, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 26, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 27, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 28, GrantedAt = DateTime.UtcNow, IsActive = true },
                // Chemist CRUD Permissions for Manager
                new RolePermission { RoleId = 2, PermissionId = 30, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 31, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 32, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 33, GrantedAt = DateTime.UtcNow, IsActive = true },
                // CustomerSupport CRUD Permissions for Manager
                new RolePermission { RoleId = 2, PermissionId = 34, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 35, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 36, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 37, GrantedAt = DateTime.UtcNow, IsActive = true },
                // Manager CRUD Permissions for self-management (own information only)
                new RolePermission { RoleId = 2, PermissionId = 38, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 40, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 41, GrantedAt = DateTime.UtcNow, IsActive = true },
                // Note: Manager doesn't get ManagerSupportCreate permission as they can't create other managers
                // All Customer CRUD Permissions for Manager
                new RolePermission { RoleId = 2, PermissionId = 46, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 47, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 48, GrantedAt = DateTime.UtcNow, IsActive = true },
                // CustomerCreate permission for Manager (can create customers)
                new RolePermission { RoleId = 2, PermissionId = 43, GrantedAt = DateTime.UtcNow, IsActive = true },
                // All MedicalStore CRUD Permissions for Manager
                new RolePermission { RoleId = 2, PermissionId = 49, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 50, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 51, GrantedAt = DateTime.UtcNow, IsActive = true },

                // CustomerSupport gets read permissions for products and orders, plus create orders + CustomerSupport User Management Permissions
                new RolePermission { RoleId = 3, PermissionId = 5, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 3, PermissionId = 9, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 3, PermissionId = 10, GrantedAt = DateTime.UtcNow, IsActive = true },
                // CustomerSupport User Management Permissions
                new RolePermission { RoleId = 3, PermissionId = 21, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 3, PermissionId = 22, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 3, PermissionId = 23, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 3, PermissionId = 24, GrantedAt = DateTime.UtcNow, IsActive = true },
                // Chemist User Management Permissions
                new RolePermission { RoleId = 3, PermissionId = 25, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 3, PermissionId = 26, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 3, PermissionId = 27, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 3, PermissionId = 28, GrantedAt = DateTime.UtcNow, IsActive = true },
                // Chemist CRUD Permissions for CustomerSupport
                new RolePermission { RoleId = 3, PermissionId = 30, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 3, PermissionId = 31, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 3, PermissionId = 32, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 3, PermissionId = 33, GrantedAt = DateTime.UtcNow, IsActive = true },
                // CustomerSupport CRUD Permissions for self-management (own information only)
                new RolePermission { RoleId = 3, PermissionId = 34, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 3, PermissionId = 36, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 3, PermissionId = 37, GrantedAt = DateTime.UtcNow, IsActive = true },
                // Note: CustomerSupport doesn't get CustomerSupportCreate permission as they can't create other customer support
                // All Customer CRUD Permissions for CustomerSupport
                new RolePermission { RoleId = 3, PermissionId = 46, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 3, PermissionId = 47, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 3, PermissionId = 48, GrantedAt = DateTime.UtcNow, IsActive = true },
                // CustomerCreate permission for CustomerSupport (can create customers)
                new RolePermission { RoleId = 3, PermissionId = 43, GrantedAt = DateTime.UtcNow, IsActive = true },
                // All MedicalStore CRUD Permissions for CustomerSupport
                new RolePermission { RoleId = 3, PermissionId = 49, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 3, PermissionId = 50, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 3, PermissionId = 51, GrantedAt = DateTime.UtcNow, IsActive = true },

                // Customer gets read permissions for products and create/read for orders
                new RolePermission { RoleId = 4, PermissionId = 5, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 4, PermissionId = 9, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 4, PermissionId = 10, GrantedAt = DateTime.UtcNow, IsActive = true },
                // Customer CRUD Permissions for self-management (own information only)
                new RolePermission { RoleId = 4, PermissionId = 42, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 4, PermissionId = 44, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 4, PermissionId = 45, GrantedAt = DateTime.UtcNow, IsActive = true },

                // Chemist gets full access to products and orders (can manage inventory and process orders)
                new RolePermission { RoleId = 5, PermissionId = 5, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 5, PermissionId = 6, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 5, PermissionId = 7, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 5, PermissionId = 8, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 5, PermissionId = 9, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 5, PermissionId = 10, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 5, PermissionId = 11, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 5, PermissionId = 12, GrantedAt = DateTime.UtcNow, IsActive = true },
                // Chemist CRUD Permissions for self-management (own information only)
                new RolePermission { RoleId = 5, PermissionId = 30, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 5, PermissionId = 32, GrantedAt = DateTime.UtcNow, IsActive = true },
                new RolePermission { RoleId = 5, PermissionId = 33, GrantedAt = DateTime.UtcNow, IsActive = true }
                // Note: Chemist doesn't get ChemistCreate permission as they can't create other chemists
            );
        }
    }

    public class ApplicationUser : Microsoft.AspNetCore.Identity.IdentityUser
    {
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? LastLoginAt { get; set; }
        public bool IsActive { get; set; } = true;
    }
}
