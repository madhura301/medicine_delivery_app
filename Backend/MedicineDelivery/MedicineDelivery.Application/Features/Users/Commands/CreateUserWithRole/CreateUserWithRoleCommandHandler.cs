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

            // Validate role exists
            var role = await _unitOfWork.Roles.GetByIdAsync(request.RoleId);
            if (role == null || !role.IsActive)
            {
                throw new InvalidOperationException("Invalid or inactive role specified.");
            }

            // Create Identity user using the wrapper
            var identityUser = new ApplicationUserImpl
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
            var identityRoleName = role.Name;
            await _userManager.AddToRoleAsync(identityUser, identityRoleName);

            // Create domain user
            var domainUser = new User
            {
                Id = identityUser.Id,
                Email = identityUser.Email,
                FirstName = identityUser.FirstName ?? string.Empty,
                LastName = identityUser.LastName ?? string.Empty,
                CreatedAt = DateTime.UtcNow,
                IsActive = identityUser.IsActive
            };

            await _unitOfWork.Users.AddAsync(domainUser);
            await _unitOfWork.SaveChangesAsync();

            // Assign role using role service
            await _roleService.AssignRoleToUserAsync(identityUser.Id, request.RoleId, "system");

            // Return response
            return new CreateUserWithRoleResponseDto
            {
                Id = identityUser.Id,
                Email = identityUser.Email,
                FirstName = identityUser.FirstName ?? string.Empty,
                LastName = identityUser.LastName ?? string.Empty,
                RoleId = request.RoleId,
                RoleName = role.Name,
                IsActive = identityUser.IsActive,
                CreatedAt = DateTime.UtcNow
            };
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
