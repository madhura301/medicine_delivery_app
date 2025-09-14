using Microsoft.AspNetCore.Identity;
using MedicineDelivery.Infrastructure.Data;
using MedicineDelivery.Infrastructure.Services;
using MedicineDelivery.Domain.Interfaces;

namespace MedicineDelivery.API.Data
{
    public static class SeedData
    {
        public static async Task Initialize(MedicineDelivery.Infrastructure.Data.ApplicationDbContext context, UserManager<MedicineDelivery.Infrastructure.Data.ApplicationUser> userManager, RoleManager<IdentityRole> roleManager, IRoleService roleService)
        {
            // Create roles
            if (!await roleManager.RoleExistsAsync("Admin"))
            {
                await roleManager.CreateAsync(new IdentityRole("Admin"));
            }

            if (!await roleManager.RoleExistsAsync("User"))
            {
                await roleManager.CreateAsync(new IdentityRole("User"));
            }

            // Create admin user
            var adminEmail = "admin@medimart.com";
            var adminUser = await userManager.FindByEmailAsync(adminEmail);
            if (adminUser == null)
            {
                adminUser = new MedicineDelivery.Infrastructure.Data.ApplicationUser
                {
                    UserName = adminEmail,
                    Email = adminEmail,
                    FirstName = "Admin",
                    LastName = "User",
                    EmailConfirmed = true
                };

                await userManager.CreateAsync(adminUser, "Admin123!");
                await userManager.AddToRoleAsync(adminUser, "Admin");

                // Create domain user
                var domainUser = new MedicineDelivery.Domain.Entities.User
                {
                    Id = adminUser.Id,
                    Email = adminUser.Email,
                    FirstName = adminUser.FirstName ?? string.Empty,
                    LastName = adminUser.LastName ?? string.Empty,
                    CreatedAt = DateTime.UtcNow,
                    IsActive = true
                };

                context.Users.Add(domainUser);
                await context.SaveChangesAsync();

                // Assign admin role to admin user (role 1 = Admin)
                await roleService.AssignRoleToUserAsync(adminUser.Id, 1, "system");
            }

            // Create regular user
            var userEmail = "user@medimart.com";
            var regularUser = await userManager.FindByEmailAsync(userEmail);
            if (regularUser == null)
            {
                regularUser = new MedicineDelivery.Infrastructure.Data.ApplicationUser
                {
                    UserName = userEmail,
                    Email = userEmail,
                    FirstName = "Regular",
                    LastName = "User",
                    EmailConfirmed = true
                };

                await userManager.CreateAsync(regularUser, "User123!");
                await userManager.AddToRoleAsync(regularUser, "User");

                // Create domain user
                var domainUser = new MedicineDelivery.Domain.Entities.User
                {
                    Id = regularUser.Id,
                    Email = regularUser.Email,
                    FirstName = regularUser.FirstName ?? string.Empty,
                    LastName = regularUser.LastName ?? string.Empty,
                    CreatedAt = DateTime.UtcNow,
                    IsActive = true
                };

                context.Users.Add(domainUser);
                await context.SaveChangesAsync();

                // Assign customer role to regular user (role 4 = Customer)
                await roleService.AssignRoleToUserAsync(regularUser.Id, 4, "system");
            }
        }
    }
}