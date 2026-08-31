namespace MedicineDelivery.Domain.Interfaces
{
    public interface IUserManager
    {
        Task<IApplicationUser?> FindByEmailAsync(string email);
        Task<IApplicationUser?> FindByPhoneNumberAsync(string phoneNumber);
        Task<IdentityResult> CreateAsync(IApplicationUser user, string password);
        Task<IdentityResult> AddToRoleAsync(IApplicationUser user, string role);
        Task<string> GenerateEmailConfirmationTokenAsync(IApplicationUser user);
        Task<IdentityResult> ConfirmEmailAsync(IApplicationUser user, string token);
        Task<IdentityResult> DeleteAsync(IApplicationUser user);

        /// <summary>Looks a user up by their Identity id.</summary>
        Task<IApplicationUser?> FindByIdAsync(string userId);

        /// <summary>Looks a user up by login name. Usernames are mobile numbers in this system.</summary>
        Task<IApplicationUser?> FindByUserNameAsync(string userName);

        /// <summary>
        /// Administrative rename: sets UserName, NormalizedUserName and PhoneNumber together
        /// (they are the same value here) and invalidates the user's existing sessions.
        /// </summary>
        Task<IdentityResult> ChangeUserNameAsync(string userId, string newUserName);

        /// <summary>
        /// Administrative password reset - does NOT require the user's current password.
        /// Uses a generated reset token internally and invalidates existing sessions.
        /// </summary>
        Task<IdentityResult> AdminResetPasswordAsync(string userId, string newPassword);
    }

    public interface IApplicationUser
    {
        string Id { get; set; }
        string UserName { get; set; }
        string Email { get; set; }
        string? FirstName { get; set; }
        string? LastName { get; set; }
        string? PhoneNumber { get; set; }
        bool EmailConfirmed { get; set; }
        bool IsActive { get; set; }
    }

    public class IdentityResult
    {
        public bool Succeeded { get; set; }
        public IEnumerable<IdentityError> Errors { get; set; } = new List<IdentityError>();
    }

    public class IdentityError
    {
        public string Code { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
    }
}
