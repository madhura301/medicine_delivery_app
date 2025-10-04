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

            // Customer role will be assigned via Identity

            // Begin transaction to ensure atomicity
            await _unitOfWork.BeginTransactionAsync();
            
            IApplicationUser? identityUser = null;
            try
            {
                // Create Identity user
                identityUser = new ApplicationUserImpl
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
                    await _unitOfWork.RollbackTransactionAsync();
                    var errors = string.Join(", ", result.Errors.Select(e => e.Description));
                    throw new InvalidOperationException($"Failed to create user: {errors}");
                }

                // Add to Customer Identity role
                await _userManager.AddToRoleAsync(identityUser, "Customer");

                await _unitOfWork.CommitTransactionAsync();

                // Return response
                return new UserRegistrationResponseDto
                {
                    Id = identityUser.Id,
                    Email = identityUser.Email,
                    FirstName = identityUser.FirstName ?? string.Empty,
                    LastName = identityUser.LastName ?? string.Empty,
                    RoleName = "Customer",
                    IsActive = identityUser.IsActive,
                    CreatedAt = DateTime.UtcNow,
                    Message = "User registered successfully. Please check your email for confirmation."
                };
            }
            catch (Exception)
            {
                // Rollback the transaction
                await _unitOfWork.RollbackTransactionAsync();
                
                // Clean up the Identity user if it was created
                if (identityUser != null && !string.IsNullOrEmpty(identityUser.Id))
                {
                    try
                    {
                        await _userManager.DeleteAsync(identityUser);
                    }
                    catch (Exception ex)
                    {
                        // Log the cleanup failure but don't throw - the main transaction is already rolled back
                        // This could be logged to a proper logging system
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
