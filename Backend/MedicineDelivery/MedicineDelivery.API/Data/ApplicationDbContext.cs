using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using MedicineDelivery.API.Models;

namespace MedicineDelivery.API.Data
{
    public class ApplicationDbContext : IdentityDbContext<ApplicationUser>
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {
        }

        public DbSet<Permission> Permissions { get; set; }
        public DbSet<UserPermission> UserPermissions { get; set; }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            // Configure UserPermission entity
            builder.Entity<UserPermission>()
                .HasKey(up => new { up.UserId, up.PermissionId });

            builder.Entity<UserPermission>()
                .HasOne(up => up.User)
                .WithMany()
                .HasForeignKey(up => up.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.Entity<UserPermission>()
                .HasOne(up => up.Permission)
                .WithMany()
                .HasForeignKey(up => up.PermissionId)
                .OnDelete(DeleteBehavior.Cascade);

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
        }
    }
}
