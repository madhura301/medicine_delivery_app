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
            // Create Identity roles (these are separate from our domain roles)
            var identityRoles = new[] { "Admin", "Manager", "CustomerSupport", "Customer", "Chemist" };
            
            foreach (var role in identityRoles)
            {
                if (!await roleManager.RoleExistsAsync(role))
                {
                    await roleManager.CreateAsync(new IdentityRole(role));
                }
            }

            // Create admin user with mobile number
            var adminMobile = "9999999999";
            var adminUser = await userManager.FindByNameAsync(adminMobile);
            if (adminUser == null)
            {
                adminUser = new MedicineDelivery.Infrastructure.Data.ApplicationUser
                {
                    UserName = adminMobile,
                    Email = "admin@medicine.com",
                    PhoneNumber = adminMobile,
                    FirstName = "System",
                    LastName = "Administrator",
                    EmailConfirmed = true,
                    IsActive = true
                };

                await userManager.CreateAsync(adminUser, "Admin@123");
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

            // Create manager user
            var managerMobile = "8888888888";
            var managerUser = await userManager.FindByNameAsync(managerMobile);
            if (managerUser == null)
            {
                managerUser = new MedicineDelivery.Infrastructure.Data.ApplicationUser
                {
                    UserName = managerMobile,
                    Email = "manager@medicine.com",
                    PhoneNumber = managerMobile,
                    FirstName = "John",
                    LastName = "Manager",
                    EmailConfirmed = true,
                    IsActive = true
                };

                await userManager.CreateAsync(managerUser, "Manager@123");
                await userManager.AddToRoleAsync(managerUser, "Manager");

                // Create domain user
                var domainUser = new MedicineDelivery.Domain.Entities.User
                {
                    Id = managerUser.Id,
                    Email = managerUser.Email,
                    FirstName = managerUser.FirstName ?? string.Empty,
                    LastName = managerUser.LastName ?? string.Empty,
                    CreatedAt = DateTime.UtcNow,
                    IsActive = true
                };

                context.Users.Add(domainUser);
                await context.SaveChangesAsync();

                // Assign manager role to manager user (role 2 = Manager)
                await roleService.AssignRoleToUserAsync(managerUser.Id, 2, "system");
            }

            // Create customer support user
            var supportMobile = "7777777777";
            var supportUser = await userManager.FindByNameAsync(supportMobile);
            if (supportUser == null)
            {
                supportUser = new MedicineDelivery.Infrastructure.Data.ApplicationUser
                {
                    UserName = supportMobile,
                    Email = "support@medicine.com",
                    PhoneNumber = supportMobile,
                    FirstName = "Jane",
                    LastName = "Support",
                    EmailConfirmed = true,
                    IsActive = true
                };

                await userManager.CreateAsync(supportUser, "Support@123");
                await userManager.AddToRoleAsync(supportUser, "CustomerSupport");

                // Create domain user
                var domainUser = new MedicineDelivery.Domain.Entities.User
                {
                    Id = supportUser.Id,
                    Email = supportUser.Email,
                    FirstName = supportUser.FirstName ?? string.Empty,
                    LastName = supportUser.LastName ?? string.Empty,
                    CreatedAt = DateTime.UtcNow,
                    IsActive = true
                };

                context.Users.Add(domainUser);
                await context.SaveChangesAsync();

                // Assign customer support role to support user (role 3 = CustomerSupport)
                await roleService.AssignRoleToUserAsync(supportUser.Id, 3, "system");
            }

            // Create customer user
            var customerMobile = "6666666666";
            var customerUser = await userManager.FindByNameAsync(customerMobile);
            if (customerUser == null)
            {
                customerUser = new MedicineDelivery.Infrastructure.Data.ApplicationUser
                {
                    UserName = customerMobile,
                    Email = "customer@medicine.com",
                    PhoneNumber = customerMobile,
                    FirstName = "Alice",
                    LastName = "Customer",
                    EmailConfirmed = true,
                    IsActive = true
                };

                await userManager.CreateAsync(customerUser, "Customer@123");
                await userManager.AddToRoleAsync(customerUser, "Customer");

                // Create domain user
                var domainUser = new MedicineDelivery.Domain.Entities.User
                {
                    Id = customerUser.Id,
                    Email = customerUser.Email,
                    FirstName = customerUser.FirstName ?? string.Empty,
                    LastName = customerUser.LastName ?? string.Empty,
                    CreatedAt = DateTime.UtcNow,
                    IsActive = true
                };

                context.Users.Add(domainUser);
                await context.SaveChangesAsync();

                // Assign customer role to customer user (role 4 = Customer)
                await roleService.AssignRoleToUserAsync(customerUser.Id, 4, "system");
            }

            // Create chemist user
            var chemistMobile = "5555555555";
            var chemistUser = await userManager.FindByNameAsync(chemistMobile);
            if (chemistUser == null)
            {
                chemistUser = new MedicineDelivery.Infrastructure.Data.ApplicationUser
                {
                    UserName = chemistMobile,
                    Email = "chemist@medicine.com",
                    PhoneNumber = chemistMobile,
                    FirstName = "Bob",
                    LastName = "Chemist",
                    EmailConfirmed = true,
                    IsActive = true
                };

                await userManager.CreateAsync(chemistUser, "Chemist@123");
                await userManager.AddToRoleAsync(chemistUser, "Chemist");

                // Create domain user
                var domainUser = new MedicineDelivery.Domain.Entities.User
                {
                    Id = chemistUser.Id,
                    Email = chemistUser.Email,
                    FirstName = chemistUser.FirstName ?? string.Empty,
                    LastName = chemistUser.LastName ?? string.Empty,
                    CreatedAt = DateTime.UtcNow,
                    IsActive = true
                };

                context.Users.Add(domainUser);
                await context.SaveChangesAsync();

                // Assign chemist role to chemist user (role 5 = Chemist)
                await roleService.AssignRoleToUserAsync(chemistUser.Id, 5, "system");
            }
        }
    }
}