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

            // Seed permissions
            builder.Entity<Permission>().HasData(
                new Permission { Id = 1, Name = "ReadUsers", Description = "Can view user information", Module = "Users" },
                new Permission { Id = 2, Name = "CreateUsers", Description = "Can create new users", Module = "Users" },
                new Permission { Id = 3, Name = "UpdateUsers", Description = "Can update user information", Module = "Users" },
                new Permission { Id = 4, Name = "DeleteUsers", Description = "Can delete users", Module = "Users" },
                new Permission { Id = 5, Name = "ReadProducts", Description = "Can view products", Module = "Products" },
                new Permission { Id = 6, Name = "CreateProducts", Description = "Can create new products", Module = "Products" },
                new Permission { Id = 7, Name = "UpdateProducts", Description = "Can update products", Module = "Products" },
                new Permission { Id = 8, Name = "DeleteProducts", Description = "Can delete products", Module = "Products" },
                new Permission { Id = 9, Name = "ReadOrders", Description = "Can view orders", Module = "Orders" },
                new Permission { Id = 10, Name = "CreateOrders", Description = "Can create new orders", Module = "Orders" },
                new Permission { Id = 11, Name = "UpdateOrders", Description = "Can update orders", Module = "Orders" },
                new Permission { Id = 12, Name = "DeleteOrders", Description = "Can delete orders", Module = "Orders" }
            );

            // Seed roles
            builder.Entity<Role>().HasData(
                new Role { Id = 1, Name = "Admin", Description = "Full system access", IsActive = true },
                new Role { Id = 2, Name = "Manager", Description = "Management level access", IsActive = true },
                new Role { Id = 3, Name = "Employee", Description = "Basic employee access", IsActive = true },
                new Role { Id = 4, Name = "Customer", Description = "Customer access", IsActive = true }
            );

            // Seed role-permission mappings
            builder.Entity<RolePermission>().HasData(
                // Admin gets all permissions
                new RolePermission { RoleId = 1, PermissionId = 1, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 2, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 3, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 4, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 5, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 6, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 7, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 8, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 9, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 10, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 11, IsActive = true },
                new RolePermission { RoleId = 1, PermissionId = 12, IsActive = true },

                // Manager gets read and update permissions
                new RolePermission { RoleId = 2, PermissionId = 1, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 3, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 5, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 7, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 9, IsActive = true },
                new RolePermission { RoleId = 2, PermissionId = 11, IsActive = true },

                // Employee gets read permissions for products and orders
                new RolePermission { RoleId = 3, PermissionId = 5, IsActive = true },
                new RolePermission { RoleId = 3, PermissionId = 9, IsActive = true },
                new RolePermission { RoleId = 3, PermissionId = 10, IsActive = true },

                // Customer gets read permissions for products and create/read for orders
                new RolePermission { RoleId = 4, PermissionId = 5, IsActive = true },
                new RolePermission { RoleId = 4, PermissionId = 9, IsActive = true },
                new RolePermission { RoleId = 4, PermissionId = 10, IsActive = true }
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
