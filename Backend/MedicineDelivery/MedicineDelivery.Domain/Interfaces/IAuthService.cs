using MedicineDelivery.Domain.Entities;

namespace MedicineDelivery.Domain.Interfaces
{
    public interface IAuthService
    {
        Task<AuthResult> LoginAsync(string mobileNumber, string password);
        Task<AuthResult> RegisterAsync(RegisterRequest request);
        Task<string> GenerateJwtTokenAsync(User user);
        Task<bool> ValidateTokenAsync(string token);
        Task<AuthResult> ForgotPasswordAsync(string mobileNumber);
        Task<AuthResult> ResetPasswordAsync(string mobileNumber, string token, string newPassword);
        Task<AuthResult> ChangePasswordAsync(string mobileNumber, string currentPassword, string newPassword);
    }

    public class AuthResult
    {
        public bool Success { get; set; }
        public string? Token { get; set; }
        public string? RefreshToken { get; set; }
        public List<string> Errors { get; set; } = new();
    }

    public class RegisterRequest
    {
        public string MobileNumber { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
    }
}
