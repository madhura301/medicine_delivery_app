namespace MedicineDelivery.Domain.Interfaces
{
    public interface IUserManager
    {
        Task<IApplicationUser?> FindByEmailAsync(string email);
        Task<IdentityResult> CreateAsync(IApplicationUser user, string password);
        Task<IdentityResult> AddToRoleAsync(IApplicationUser user, string role);
        Task<string> GenerateEmailConfirmationTokenAsync(IApplicationUser user);
        Task<IdentityResult> ConfirmEmailAsync(IApplicationUser user, string token);
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
