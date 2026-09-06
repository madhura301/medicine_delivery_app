using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
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

        public async Task<IApplicationUser?> FindByPhoneNumberAsync(string phoneNumber)
        {
            if (string.IsNullOrWhiteSpace(phoneNumber))
            {
                return null;
            }

            var user = await _userManager.Users
                .FirstOrDefaultAsync(u => u.PhoneNumber == phoneNumber);
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
            
            // Write the generated Id back through the IApplicationUser interface.
            // (A hard cast to ApplicationUserWrapper here threw InvalidCastException
            // for callers that pass a different IApplicationUser implementation, e.g.
            // the /api/users register & create-with-role handlers' ApplicationUserImpl.)
            if (result.Succeeded)
            {
                user.Id = appUser.Id;
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

        public async Task<IApplicationUser?> FindByIdAsync(string userId)
        {
            if (string.IsNullOrWhiteSpace(userId)) return null;
            var user = await _userManager.FindByIdAsync(userId);
            return user != null ? new ApplicationUserWrapper(user) : null;
        }

        public async Task<IApplicationUser?> FindByUserNameAsync(string userName)
        {
            if (string.IsNullOrWhiteSpace(userName)) return null;
            var user = await _userManager.FindByNameAsync(userName);
            return user != null ? new ApplicationUserWrapper(user) : null;
        }

        public async Task<MedicineDelivery.Domain.Interfaces.IdentityResult> ChangeUserNameAsync(string userId, string newUserName)
        {
            var appUser = await _userManager.FindByIdAsync(userId);
            if (appUser == null)
            {
                _logger.LogWarning("ChangeUserNameAsync: User {UserId} not found", userId);
                return NotFound();
            }

            var previous = appUser.UserName;

            // UserName and PhoneNumber are the same value in this system - a login IS a mobile
            // number - so they must move together or the account desynchronises.
            var setName = await _userManager.SetUserNameAsync(appUser, newUserName);
            if (!setName.Succeeded)
            {
                _logger.LogWarning("ChangeUserNameAsync: SetUserName failed for {UserId}. Errors: {Errors}",
                    userId, string.Join(", ", setName.Errors.Select(e => e.Description)));
                return ConvertToDomainResult(setName);
            }

            var setPhone = await _userManager.SetPhoneNumberAsync(appUser, newUserName);
            if (!setPhone.Succeeded)
            {
                _logger.LogWarning("ChangeUserNameAsync: SetPhoneNumber failed for {UserId}. Errors: {Errors}",
                    userId, string.Join(", ", setPhone.Errors.Select(e => e.Description)));
                return ConvertToDomainResult(setPhone);
            }

            // Force existing tokens/sessions issued against the old identity to stop working.
            await _userManager.UpdateSecurityStampAsync(appUser);

            _logger.LogInformation("Username changed for {UserId}: {Previous} -> {New}", userId, previous, newUserName);
            return ConvertToDomainResult(setPhone);
        }

        public async Task<MedicineDelivery.Domain.Interfaces.IdentityResult> AdminResetPasswordAsync(string userId, string newPassword)
        {
            var appUser = await _userManager.FindByIdAsync(userId);
            if (appUser == null)
            {
                _logger.LogWarning("AdminResetPasswordAsync: User {UserId} not found", userId);
                return NotFound();
            }

            // Generate-and-consume a reset token so the caller never needs the current password,
            // while still going through Identity's password validation and hashing.
            var token = await _userManager.GeneratePasswordResetTokenAsync(appUser);
            var result = await _userManager.ResetPasswordAsync(appUser, token, newPassword);

            if (!result.Succeeded)
            {
                _logger.LogWarning("AdminResetPasswordAsync: reset failed for {UserId}. Errors: {Errors}",
                    userId, string.Join(", ", result.Errors.Select(e => e.Description)));
                return ConvertToDomainResult(result);
            }

            await _userManager.UpdateSecurityStampAsync(appUser);

            // Never log the password itself.
            _logger.LogInformation("Password reset by administrator for {UserId}", userId);
            return ConvertToDomainResult(result);
        }

        private static MedicineDelivery.Domain.Interfaces.IdentityResult NotFound() =>
            new()
            {
                Succeeded = false,
                Errors = new[] { new MedicineDelivery.Domain.Interfaces.IdentityError { Code = "UserNotFound", Description = "User not found" } }
            };

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
