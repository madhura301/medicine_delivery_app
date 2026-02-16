using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;
using MedicineDelivery.Domain.Interfaces;
using MedicineDelivery.Infrastructure.Data;

namespace MedicineDelivery.Infrastructure.Services
{
    public class UserManagerService : IUserManager
    {
        private readonly UserManager<Domain.Entities.ApplicationUser> _userManager;
        private readonly ILogger<UserManagerService> _logger;

        public UserManagerService(UserManager<Domain.Entities.ApplicationUser> userManager, ILogger<UserManagerService> logger)
        {
            _userManager = userManager;
            _logger = logger;
        }

        public async Task<IApplicationUser?> FindByEmailAsync(string email)
        {
            var user = await _userManager.FindByEmailAsync(email);
            return user != null ? new ApplicationUserWrapper(user) : null;
        }

        public async Task<MedicineDelivery.Domain.Interfaces.IdentityResult> CreateAsync(IApplicationUser user, string password)
        {
            var appUser = new Domain.Entities.ApplicationUser
            {
                UserName = user.UserName,
                Email = user.Email,
                FirstName = user.FirstName,
                LastName = user.LastName,
                PhoneNumber = user.PhoneNumber,
                EmailConfirmed = user.EmailConfirmed,
                IsActive = user.IsActive
            };

            var result = await _userManager.CreateAsync(appUser, password);
            
            // Update the user ID in the wrapper
            if (result.Succeeded)
            {
                ((ApplicationUserWrapper)user).Id = appUser.Id;
            }
            else
            {
                _logger.LogWarning("Failed to create user {Email}. Errors: {Errors}", user.Email, string.Join(", ", result.Errors.Select(e => e.Description)));
            }

            return ConvertToDomainResult(result);
        }

        public async Task<MedicineDelivery.Domain.Interfaces.IdentityResult> AddToRoleAsync(IApplicationUser user, string role)
        {
            var appUser = await _userManager.FindByIdAsync(user.Id);
            if (appUser == null)
            {
                _logger.LogWarning("AddToRoleAsync: User {UserId} not found when assigning role {Role}", user.Id, role);
                return new MedicineDelivery.Domain.Interfaces.IdentityResult { Succeeded = false, Errors = new[] { new MedicineDelivery.Domain.Interfaces.IdentityError { Description = "User not found" } } };
            }

            var result = await _userManager.AddToRoleAsync(appUser, role);
            if (!result.Succeeded)
            {
                _logger.LogWarning("AddToRoleAsync: Failed to assign role {Role} to user {UserId}. Errors: {Errors}", role, user.Id, string.Join(", ", result.Errors.Select(e => e.Description)));
            }
            return ConvertToDomainResult(result);
        }

        public async Task<string> GenerateEmailConfirmationTokenAsync(IApplicationUser user)
        {
            var appUser = await _userManager.FindByIdAsync(user.Id);
            if (appUser == null)
            {
                _logger.LogWarning("GenerateEmailConfirmationTokenAsync: User {UserId} not found", user.Id);
                throw new InvalidOperationException("User not found");
            }

            return await _userManager.GenerateEmailConfirmationTokenAsync(appUser);
        }

        public async Task<MedicineDelivery.Domain.Interfaces.IdentityResult> ConfirmEmailAsync(IApplicationUser user, string token)
        {
            var appUser = await _userManager.FindByIdAsync(user.Id);
            if (appUser == null)
            {
                return new MedicineDelivery.Domain.Interfaces.IdentityResult { Succeeded = false, Errors = new[] { new MedicineDelivery.Domain.Interfaces.IdentityError { Description = "User not found" } } };
            }

            var result = await _userManager.ConfirmEmailAsync(appUser, token);
            return ConvertToDomainResult(result);
        }

        public async Task<MedicineDelivery.Domain.Interfaces.IdentityResult> DeleteAsync(IApplicationUser user)
        {
            var appUser = await _userManager.FindByIdAsync(user.Id);
            if (appUser == null)
            {
                _logger.LogWarning("DeleteAsync: User {UserId} not found", user.Id);
                return new MedicineDelivery.Domain.Interfaces.IdentityResult { Succeeded = false, Errors = new[] { new MedicineDelivery.Domain.Interfaces.IdentityError { Description = "User not found" } } };
            }

            var result = await _userManager.DeleteAsync(appUser);
            if (!result.Succeeded)
            {
                _logger.LogWarning("DeleteAsync: Failed to delete user {UserId}. Errors: {Errors}", user.Id, string.Join(", ", result.Errors.Select(e => e.Description)));
            }
            return ConvertToDomainResult(result);
        }

        private static MedicineDelivery.Domain.Interfaces.IdentityResult ConvertToDomainResult(Microsoft.AspNetCore.Identity.IdentityResult aspNetResult)
        {
            return new MedicineDelivery.Domain.Interfaces.IdentityResult
            {
                Succeeded = aspNetResult.Succeeded,
                Errors = aspNetResult.Errors.Select(e => new MedicineDelivery.Domain.Interfaces.IdentityError
                {
                    Code = e.Code,
                    Description = e.Description
                })
            };
        }
    }

    public class ApplicationUserWrapper : IApplicationUser
    {
        private readonly Domain.Entities.ApplicationUser _user;

        public ApplicationUserWrapper(Domain.Entities.ApplicationUser user)
        {
            _user = user;
        }

        public string Id 
        { 
            get => _user.Id; 
            set => _user.Id = value; 
        }

        public string UserName 
        { 
            get => _user.UserName ?? string.Empty; 
            set => _user.UserName = value; 
        }

        public string Email 
        { 
            get => _user.Email ?? string.Empty; 
            set => _user.Email = value; 
        }

        public string? FirstName 
        { 
            get => _user.FirstName; 
            set => _user.FirstName = value; 
        }

        public string? LastName 
        { 
            get => _user.LastName; 
            set => _user.LastName = value; 
        }

        public string? PhoneNumber 
        { 
            get => _user.PhoneNumber; 
            set => _user.PhoneNumber = value; 
        }

        public bool EmailConfirmed 
        { 
            get => _user.EmailConfirmed; 
            set => _user.EmailConfirmed = value; 
        }

        public bool IsActive 
        { 
            get => _user.IsActive; 
            set => _user.IsActive = value; 
        }
    }
}
