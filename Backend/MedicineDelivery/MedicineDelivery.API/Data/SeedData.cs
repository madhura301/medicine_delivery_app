using Microsoft.AspNetCore.Identity;
using MedicineDelivery.Domain.Interfaces;

namespace MedicineDelivery.API.Data
{
    public static class SeedData
    {
        public static async Task Initialize(MedicineDelivery.Infrastructure.Data.ApplicationDbContext context, UserManager<MedicineDelivery.Domain.Entities.ApplicationUser> userManager, RoleManager<IdentityRole> roleManager, IRoleService roleService)
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
                adminUser = new MedicineDelivery.Domain.Entities.ApplicationUser
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
            }

            // Create manager user
            var managerMobile = "8888888888";
            var managerUser = await userManager.FindByNameAsync(managerMobile);
            if (managerUser == null)
            {
                managerUser = new MedicineDelivery.Domain.Entities.ApplicationUser
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
            }

            // Create customer support user
            var supportMobile = "7777777777";
            var supportUser = await userManager.FindByNameAsync(supportMobile);
            if (supportUser == null)
            {
                supportUser = new MedicineDelivery.Domain.Entities.ApplicationUser
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
            }

            // Create customer user
            var customerMobile = "6666666666";
            var customerUser = await userManager.FindByNameAsync(customerMobile);
            if (customerUser == null)
            {
                customerUser = new MedicineDelivery.Domain.Entities.ApplicationUser
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
            }

            // Create chemist user
            var chemistMobile = "5555555555";
            var chemistUser = await userManager.FindByNameAsync(chemistMobile);
            if (chemistUser == null)
            {
                chemistUser = new MedicineDelivery.Domain.Entities.ApplicationUser
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
            }

            await context.SaveChangesAsync();
        }
    }
}