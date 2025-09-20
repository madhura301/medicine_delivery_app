namespace MedicineDelivery.Application.DTOs
{
    public class LoginDto
    {
        public string MobileNumber { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
    }

    public class RegisterDto
    {
        public string MobileNumber { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
    }

    public class AuthResponseDto
    {
        public bool Success { get; set; }
        public string? Token { get; set; }
        public string? RefreshToken { get; set; }
        public List<string> Errors { get; set; } = new();
    }

    public class ForgotPasswordDto
    {
        public string MobileNumber { get; set; } = string.Empty;
    }

    public class ResetPasswordDto
    {
        public string MobileNumber { get; set; } = string.Empty;
        public string Token { get; set; } = string.Empty;
        public string NewPassword { get; set; } = string.Empty;
    }

    public class ChangePasswordDto
    {
        public string MobileNumber { get; set; } = string.Empty;
        public string CurrentPassword { get; set; } = string.Empty;
        public string NewPassword { get; set; } = string.Empty;
    }
}
