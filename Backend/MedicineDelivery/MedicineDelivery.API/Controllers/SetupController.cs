using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MedicineDelivery.API.Authorization;
using MedicineDelivery.API.Models.Requests;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Infrastructure.Data;

namespace MedicineDelivery.API.Controllers
{
    [ApiController]
    [Route("api/setup")]
    public class SetupController : ControllerBase
    {
        private readonly RoleManager<IdentityRole> _roleManager;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly ApplicationDbContext _context;

        public SetupController(
            RoleManager<IdentityRole> roleManager,
            UserManager<ApplicationUser> userManager,
            ApplicationDbContext context)
        {
            _roleManager = roleManager;
            _userManager = userManager;
            _context = context;
        }

        /// <summary>
        /// Adds a single Identity role to the system.
        /// </summary>
        [HttpPost("roles")]
        [AllowAnonymous]
        public async Task<IActionResult> CreateRole([FromBody] CreateRoleRequest request)
        {
            if (!ModelState.IsValid)
            {
                return ValidationProblem(ModelState);
            }

            var roleName = request.Name.Trim();
            if (string.IsNullOrWhiteSpace(roleName))
            {
                return BadRequest("Role name must be provided.");
            }

            var existingRole = await _roleManager.FindByNameAsync(roleName);
            if (existingRole != null)
            {
                return Conflict($"Role '{roleName}' already exists.");
            }

            var role = new IdentityRole
            {
                Name = roleName,
                NormalizedName = roleName.ToUpperInvariant(),
                ConcurrencyStamp = Guid.NewGuid().ToString()
            };

            var result = await _roleManager.CreateAsync(role);
            if (!result.Succeeded)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, result.Errors);
            }

            return Ok(new { Message = "Role created successfully.", Role = new { role.Id, role.Name } });
        }

        /// <summary>
        /// Adds a single permission record.
        /// </summary>
        [HttpPost("permissions")]
        [AllowAnonymous]
        public async Task<IActionResult> CreatePermission([FromBody] CreatePermissionRequest request)
        {
            if (!ModelState.IsValid)
            {
                return ValidationProblem(ModelState);
            }

            var permissionName = request.Name.Trim();
            if (string.IsNullOrWhiteSpace(permissionName))
            {
                return BadRequest("Permission name must be provided.");
            }

            var exists = await _context.Permissions
                .AnyAsync(p => p.Name.ToLower() == permissionName.ToLower());
            if (exists)
            {
                return Conflict($"Permission '{permissionName}' already exists.");
            }

            var module = string.IsNullOrWhiteSpace(request.Module)
                ? "General"
                : request.Module!.Trim();
            var description = string.IsNullOrWhiteSpace(request.Description)
                ? $"{permissionName} permission"
                : request.Description!.Trim();

            var permission = new Permission
            {
                Name = permissionName,
                Module = module,
                Description = description,
                CreatedAt = DateTime.UtcNow,
                IsActive = true,
                Id = request.Id.HasValue ? request.Id.Value : default
            };

            try
            {
                _context.Permissions.Add(permission);
                await _context.SaveChangesAsync();
            }
            catch (Exception e)
            {

                throw;
            }
            

            return Ok(new { Message = "Permission created successfully.", Permission = new { permission.Id, permission.Name } });
        }

        /// <summary>
        /// Creates all predefined Identity roles with deterministic IDs.
        /// </summary>
        [HttpPost("roles/predefined")]
        [AllowAnonymous]
        public async Task<IActionResult> CreatePredefinedRoles()
        {
            var created = new List<string>();
            var skipped = new List<string>();

            foreach (var roleDef in PredefinedAuthorizationData.Roles)
            {
                var existingRole = await _roleManager.FindByIdAsync(roleDef.Id)
                    ?? await _roleManager.FindByNameAsync(roleDef.Name);

                if (existingRole != null)
                {
                    skipped.Add(roleDef.Name);
                    continue;
                }

                var role = new IdentityRole
                {
                    Id = roleDef.Id,
                    Name = roleDef.Name,
                    NormalizedName = roleDef.NormalizedName,
                    ConcurrencyStamp = Guid.NewGuid().ToString()
                };

                var result = await _roleManager.CreateAsync(role);
                if (!result.Succeeded)
                {
                    return StatusCode(StatusCodes.Status500InternalServerError, result.Errors);
                }

                created.Add(role.Name);
            }

            return Ok(new { Created = created, Skipped = skipped });
        }

        /// <summary>
        /// Inserts or updates all predefined permission records (based on controller attributes).
        /// </summary>
        [HttpPost("permissions/predefined")]
        [AllowAnonymous]
        public async Task<IActionResult> CreatePredefinedPermissions()
        {
            var created = new List<string>();
            var updated = new List<string>();

            foreach (var permissionDef in PredefinedAuthorizationData.Permissions)
            {
                var existing = await _context.Permissions
                    .FirstOrDefaultAsync(p => p.Id == permissionDef.Id || p.Name == permissionDef.Name);

                if (existing == null)
                {
                    var permission = new Permission
                    {
                        Id = permissionDef.Id,
                        Name = permissionDef.Name,
                        Module = permissionDef.Module,
                        Description = permissionDef.Description,
                        CreatedAt = DateTime.UtcNow,
                        IsActive = true
                    };

                    _context.Permissions.Add(permission);
                    created.Add(permission.Name);
                }
                else
                {
                    var shouldUpdate = false;

                    if (!string.Equals(existing.Module, permissionDef.Module, StringComparison.Ordinal))
                    {
                        existing.Module = permissionDef.Module;
                        shouldUpdate = true;
                    }

                    if (!string.Equals(existing.Description, permissionDef.Description, StringComparison.Ordinal))
                    {
                        existing.Description = permissionDef.Description;
                        shouldUpdate = true;
                    }

                    if (!existing.IsActive)
                    {
                        existing.IsActive = true;
                        shouldUpdate = true;
                    }

                    if (shouldUpdate)
                    {
                        updated.Add(existing.Name);
                    }
                }
            }

            await _context.SaveChangesAsync();
            return Ok(new { Created = created, Updated = updated });
        }

        /// <summary>
        /// Maps predefined roles to their predefined permission sets.
        /// </summary>
        [HttpPost("role-permissions/predefined")]
        [AllowAnonymous]
        public async Task<IActionResult> MapPredefinedRolePermissions()
        {
            var created = new List<string>();
            var missingRoles = new List<string>();
            var missingPermissions = new List<int>();

            var existingRolePermissionPairs = await _context.RolePermissions
                .Select(rp => new { rp.RoleId, rp.PermissionId })
                .ToListAsync();

            var existingSet = existingRolePermissionPairs
                .Select(pair => (pair.RoleId, pair.PermissionId))
                .ToHashSet();

            var permissionIds = await _context.Permissions
                .Select(p => p.Id)
                .ToListAsync();
            var permissionIdSet = permissionIds.ToHashSet();

            foreach (var mapping in PredefinedAuthorizationData.RolePermissions)
            {
                var role = await _roleManager.FindByIdAsync(mapping.Key);
                if (role == null)
                {
                    missingRoles.Add(mapping.Key);
                    continue;
                }

                foreach (var permissionId in mapping.Value)
                {
                    if (!permissionIdSet.Contains(permissionId))
                    {
                        missingPermissions.Add(permissionId);
                        continue;
                    }

                    if (existingSet.Contains((role.Id, permissionId)))
                    {
                        continue;
                    }

                    _context.RolePermissions.Add(new RolePermission
                    {
                        RoleId = role.Id,
                        PermissionId = permissionId,
                        GrantedAt = DateTime.UtcNow,
                        GrantedBy = "setup-endpoint",
                        IsActive = true
                    });

                    existingSet.Add((role.Id, permissionId));
                    created.Add($"{role.Name}:{permissionId}");
                }
            }

            await _context.SaveChangesAsync();

            return Ok(new
            {
                Created = created,
                MissingRoles = missingRoles.Distinct().ToArray(),
                MissingPermissions = missingPermissions.Distinct().ToArray()
            });
        }

        /// <summary>
        /// Creates the Admin user with predefined credentials if it does not already exist.
        /// Mobile: 9999999999, Email: admin@medicine.com, Password: Admin@123
        /// </summary>
        [HttpPost("users/admin/firstuser")]
        [AllowAnonymous]
        public async Task<IActionResult> CreateAdminFirstUser()
        {
            const string roleName = "Admin";
            const string mobileNumber = "8793583675";
            const string email = "dipmala.patil@medicine.com";
            const string password = "Admin@123";
            const string firstName = "System";
            const string lastName = "Administrator";

            return await CreateUserAsync(roleName, mobileNumber, email, password, firstName, lastName);
        }

        /// <summary>
        /// Creates the Admin user with predefined credentials if it does not already exist.
        /// Mobile: 9999999999, Email: admin@medicine.com, Password: Admin@123
        /// </summary>
        [HttpPost("users/admin")]
        [AllowAnonymous]
        public async Task<IActionResult> CreateAdminUser()
        {
            const string roleName = "Admin";
            const string mobileNumber = "9999999999";
            const string email = "admin@medicine.com";
            const string password = "Admin@123";
            const string firstName = "System";
            const string lastName = "Administrator";

            return await CreateUserAsync(roleName, mobileNumber, email, password, firstName, lastName);
        }

        /// <summary>
        /// Creates the Manager user with predefined credentials if it does not already exist.
        /// </summary>
        [HttpPost("users/manager")]
        [AllowAnonymous]
        public async Task<IActionResult> CreateManagerUser()
        {
            const string roleName = "Manager";
            const string mobileNumber = "8888888888";
            const string email = "manager@medicine.com";
            const string password = "Manager@123";
            const string firstName = "John";
            const string lastName = "Manager";

            return await CreateUserAsync(roleName, mobileNumber, email, password, firstName, lastName);
        }

        /// <summary>
        /// Creates the CustomerSupport user with predefined credentials if it does not already exist.
        /// </summary>
        [HttpPost("users/customer-support")]
        [AllowAnonymous]
        public async Task<IActionResult> CreateCustomerSupportUser()
        {
            const string roleName = "CustomerSupport";
            const string mobileNumber = "7777777777";
            const string email = "support@medicine.com";
            const string password = "Support@123";
            const string firstName = "Jane";
            const string lastName = "Support";

            return await CreateUserAsync(roleName, mobileNumber, email, password, firstName, lastName);
        }

        /// <summary>
        /// Creates the Customer user with predefined credentials if it does not already exist.
        /// </summary>
        [HttpPost("users/customer")]
        [AllowAnonymous]
        public async Task<IActionResult> CreateCustomerUser()
        {
            const string roleName = "Customer";
            const string mobileNumber = "6666666666";
            const string email = "customer@medicine.com";
            const string password = "Customer@123";
            const string firstName = "Alice";
            const string lastName = "Customer";

            return await CreateUserAsync(roleName, mobileNumber, email, password, firstName, lastName);
        }

        /// <summary>
        /// Creates the Chemist user with predefined credentials if it does not already exist.
        /// </summary>
        [HttpPost("users/chemist")]
        [AllowAnonymous]
        public async Task<IActionResult> CreateChemistUser()
        {
            const string roleName = "Chemist";
            const string mobileNumber = "5555555555";
            const string email = "chemist@medicine.com";
            const string password = "Chemist@123";
            const string firstName = "Bob";
            const string lastName = "Chemist";

            return await CreateUserAsync(roleName, mobileNumber, email, password, firstName, lastName);
        }

        /// <summary>
        /// Helper method to create a user with the specified role and credentials.
        /// </summary>
        private async Task<IActionResult> CreateUserAsync(
            string roleName,
            string mobileNumber,
            string email,
            string password,
            string firstName,
            string lastName)
        {
            // Check if user already exists
            var existingUser = await _userManager.FindByNameAsync(mobileNumber)
                ?? await _userManager.FindByEmailAsync(email);

            if (existingUser != null)
            {
                return Conflict(new
                {
                    Message = $"User with mobile {mobileNumber} or email {email} already exists.",
                    User = new { existingUser.Id, existingUser.UserName, existingUser.Email, existingUser.FirstName, existingUser.LastName }
                });
            }

            // Ensure role exists
            if (!await _roleManager.RoleExistsAsync(roleName))
            {
                var role = new IdentityRole
                {
                    Name = roleName,
                    NormalizedName = roleName.ToUpperInvariant(),
                    ConcurrencyStamp = Guid.NewGuid().ToString()
                };

                var roleResult = await _roleManager.CreateAsync(role);
                if (!roleResult.Succeeded)
                {
                    return StatusCode(StatusCodes.Status500InternalServerError, new
                    {
                        Message = $"Failed to create role {roleName}.",
                        Errors = roleResult.Errors.Select(e => e.Description)
                    });
                }
            }

            // Create user
            var user = new ApplicationUser
            {
                UserName = mobileNumber,
                Email = email,
                PhoneNumber = mobileNumber,
                EmailConfirmed = true,
                PhoneNumberConfirmed = true,
                FirstName = firstName,
                LastName = lastName,
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            };

            var createResult = await _userManager.CreateAsync(user, password);
            if (!createResult.Succeeded)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, new
                {
                    Message = $"Failed to create user {mobileNumber}.",
                    Errors = createResult.Errors.Select(e => e.Description)
                });
            }

            // Add to role
            var addToRoleResult = await _userManager.AddToRoleAsync(user, roleName);
            if (!addToRoleResult.Succeeded)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, new
                {
                    Message = $"Failed to assign role {roleName} to user {mobileNumber}.",
                    Errors = addToRoleResult.Errors.Select(e => e.Description)
                });
            }

            return Ok(new
            {
                Message = $"{roleName} user created successfully.",
                User = new { user.Id, user.UserName, user.Email, user.FirstName, user.LastName, Role = roleName }
            });
        }
    }
}

