using MediatR;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Domain.Interfaces;
using MedicineDelivery.Domain.Entities;

namespace MedicineDelivery.Application.Features.Users.Commands.RegisterUser
{
    public class RegisterUserCommandHandler : IRequestHandler<RegisterUserCommand, UserRegistrationResponseDto>
    {
        private readonly IUserManager _userManager;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IRoleService _roleService;

        public RegisterUserCommandHandler(
            IUserManager userManager,
            IUnitOfWork unitOfWork,
            IRoleService roleService)
        {
            _userManager = userManager;
            _unitOfWork = unitOfWork;
            _roleService = roleService;
        }

        public async Task<UserRegistrationResponseDto> Handle(RegisterUserCommand request, CancellationToken cancellationToken)
        {
            // Check if user already exists
            var existingUser = await _userManager.FindByEmailAsync(request.Email);
            if (existingUser != null)
            {
                throw new InvalidOperationException("User with this email already exists.");
            }

            // Get Customer role (ID = 4)
            var customerRole = await _unitOfWork.Roles.GetByIdAsync(4);
            if (customerRole == null || !customerRole.IsActive)
            {
                throw new InvalidOperationException("Customer role not found or inactive.");
            }

            // Create Identity user
            var identityUser = new ApplicationUserImpl
            {
                UserName = request.Email,
                Email = request.Email,
                FirstName = request.FirstName,
                LastName = request.LastName,
                PhoneNumber = request.PhoneNumber,
                EmailConfirmed = false, // New registrations start with unconfirmed email
                IsActive = true
            };

            var result = await _userManager.CreateAsync(identityUser, request.Password);
            if (!result.Succeeded)
            {
                var errors = string.Join(", ", result.Errors.Select(e => e.Description));
                throw new InvalidOperationException($"Failed to create user: {errors}");
            }

            // Add to Customer Identity role
            await _userManager.AddToRoleAsync(identityUser, "Customer");

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

            // Assign Customer role using role service (Role ID = 4)
            await _roleService.AssignRoleToUserAsync(identityUser.Id, 4, "system");

            // Return response
            return new UserRegistrationResponseDto
            {
                Id = identityUser.Id,
                Email = identityUser.Email,
                FirstName = identityUser.FirstName ?? string.Empty,
                LastName = identityUser.LastName ?? string.Empty,
                RoleName = customerRole.Name,
                IsActive = identityUser.IsActive,
                CreatedAt = DateTime.UtcNow,
                Message = "User registered successfully. Please check your email for confirmation."
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
