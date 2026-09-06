using System.ComponentModel.DataAnnotations;

namespace MedicineDelivery.Application.DTOs
{
    /// <summary>Administrative rename of a user's login (which is their mobile number).</summary>
    public class ChangeUserNameDto
    {
        [Required]
        [RegularExpression(@"^\d{10}$", ErrorMessage = "The username must be a 10-digit mobile number.")]
        public string NewUserName { get; set; } = string.Empty;
    }

    /// <summary>Administrative password reset - deliberately does not take the current password.</summary>
    public class AdminResetPasswordDto
    {
        [Required]
        [MinLength(6, ErrorMessage = "The password must be at least 6 characters.")]
        public string NewPassword { get; set; } = string.Empty;
    }

    /// <summary>Result of an account-maintenance operation.</summary>
    public class UserAccountUpdateResultDto
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;

        /// <summary>Set when the username changed, so the caller can confirm what was applied.</summary>
        public string? UserName { get; set; }

        /// <summary>Which profile table, if any, had its mobile number kept in step.</summary>
        public string? ProfileUpdated { get; set; }

        public List<string> Errors { get; set; } = new();
    }
}
