using MediatR;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Domain.Interfaces;
using MedicineDelivery.Domain.Entities;

namespace MedicineDelivery.Application.Features.Users.Commands.CreateUserWithRole
{
    public class CreateUserWithRoleCommandHandler : IRequestHandler<CreateUserWithRoleCommand, CreateUserWithRoleResponseDto>
    {
        private readonly IUserManager _userManager;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IRoleService _roleService;

        public CreateUserWithRoleCommandHandler(
            IUserManager userManager,
            IUnitOfWork unitOfWork,
            IRoleService roleService)
        {
            _userManager = userManager;
            _unitOfWork = unitOfWork;
            _roleService = roleService;
        }

        public async Task<CreateUserWithRoleResponseDto> Handle(CreateUserWithRoleCommand request, CancellationToken cancellationToken)
        {
            // Check if user already exists
            var existingUser = await _userManager.FindByEmailAsync(request.Email);
            if (existingUser != null)
            {
                throw new InvalidOperationException("User with this email already exists.");
            }

            // Validate role exists (using Identity roles)
            var roleName = await _roleService.GetRoleByIdAsync(request.RoleId);
            if (string.IsNullOrEmpty(roleName))
            {
                throw new InvalidOperationException("Invalid or inactive role specified.");
            }

            IApplicationUser? identityUser = null;
            try
            {
                // Create Identity user using the wrapper
                identityUser = new ApplicationUserImpl
                {
                    UserName = request.Email,
                    Email = request.Email,
                    FirstName = request.FirstName,
                    LastName = request.LastName,
                    PhoneNumber = request.PhoneNumber,
                    EmailConfirmed = request.EmailConfirmed,
                    IsActive = request.IsActive
                };

                var result = await _userManager.CreateAsync(identityUser, request.Password);
                if (!result.Succeeded)
                {
                    var errors = string.Join(", ", result.Errors.Select(e => e.Description));
                    throw new InvalidOperationException($"Failed to create user: {errors}");
                }

                // Add to Identity role
                await _userManager.AddToRoleAsync(identityUser, roleName);

                // Return response
                return new CreateUserWithRoleResponseDto
                {
                    Id = identityUser.Id,
                    Email = identityUser.Email,
                    FirstName = identityUser.FirstName ?? string.Empty,
                    LastName = identityUser.LastName ?? string.Empty,
                    RoleId = request.RoleId,
                    RoleName = roleName,
                    IsActive = identityUser.IsActive,
                    CreatedAt = DateTime.UtcNow
                };
            }
            catch (Exception)
            {
                // Clean up the Identity user if it was created
                if (identityUser != null && !string.IsNullOrEmpty(identityUser.Id))
                {
                    try
                    {
                        await _userManager.DeleteAsync(identityUser);
                    }
                    catch (Exception ex)
                    {
                        // Log the cleanup failure but don't throw
                        Console.WriteLine($"Failed to cleanup Identity user {identityUser.Id}: {ex.Message}");
                    }
                }
                
                throw; // Re-throw the original exception
            }
        }
    }

    public class ApplicationUserImpl : IApplicationUser
    {
        public string Id { get; set; } = string.Empty;
        public string UserName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? PhoneNumber { get; set; }
        public bool EmailConfirmed { get; set; }
        public bool IsActive { get; set; }
    }
}
