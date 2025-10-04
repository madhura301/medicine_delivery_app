using Microsoft.AspNetCore.Identity;
using MedicineDelivery.Domain.Interfaces;
using MedicineDelivery.Infrastructure.Data;

namespace MedicineDelivery.Infrastructure.Services
{
    public class UserManagerService : IUserManager
    {
        private readonly UserManager<Domain.Entities.ApplicationUser> _userManager;

        public UserManagerService(UserManager<Domain.Entities.ApplicationUser> userManager)
        {
            _userManager = userManager;
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

            return ConvertToDomainResult(result);
        }

        public async Task<MedicineDelivery.Domain.Interfaces.IdentityResult> AddToRoleAsync(IApplicationUser user, string role)
        {
            var appUser = await _userManager.FindByIdAsync(user.Id);
            if (appUser == null)
            {
                return new MedicineDelivery.Domain.Interfaces.IdentityResult { Succeeded = false, Errors = new[] { new MedicineDelivery.Domain.Interfaces.IdentityError { Description = "User not found" } } };
            }

            var result = await _userManager.AddToRoleAsync(appUser, role);
            return ConvertToDomainResult(result);
        }

        public async Task<string> GenerateEmailConfirmationTokenAsync(IApplicationUser user)
        {
            var appUser = await _userManager.FindByIdAsync(user.Id);
            if (appUser == null)
            {
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
                return new MedicineDelivery.Domain.Interfaces.IdentityResult { Succeeded = false, Errors = new[] { new MedicineDelivery.Domain.Interfaces.IdentityError { Description = "User not found" } } };
            }

            var result = await _userManager.DeleteAsync(appUser);
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
