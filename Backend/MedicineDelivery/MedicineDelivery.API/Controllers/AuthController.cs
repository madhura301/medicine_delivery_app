using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Domain.Interfaces;

namespace MedicineDelivery.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly ILogger<AuthController> _logger;

        public AuthController(IAuthService authService, ILogger<AuthController> logger)
        {
            _authService = authService;
            _logger = logger;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto request)
        {
            _logger.LogInformation("Login attempt for mobile number: {MobileNumber}", request.MobileNumber);
            
            try
            {
                var result = await _authService.LoginAsync(request.MobileNumber, request.Password, request.StayLoggedIn);
                
                if (!result.Success)
                {
                    _logger.LogWarning("Login failed for mobile number: {MobileNumber}. Errors: {Errors}", 
                        request.MobileNumber, string.Join(", ", result.Errors));
                    return BadRequest(result);
                }

                _logger.LogInformation("Login successful for mobile number: {MobileNumber}", request.MobileNumber);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during login for mobile number: {MobileNumber}", request.MobileNumber);
                return StatusCode(500, "An error occurred during login");
            }
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto request)
        {
            _logger.LogInformation("Registration attempt for mobile number: {MobileNumber}, email: {Email}", 
                request.MobileNumber, request.Email);
            
            try
            {
            var registerRequest = new Domain.Interfaces.RegisterRequest
            {
                MobileNumber = request.MobileNumber,
                Email = request.Email,
                Password = request.Password,
                FirstName = request.FirstName,
                LastName = request.LastName
            };

                var result = await _authService.RegisterAsync(registerRequest);
                
                if (!result.Success)
                {
                    _logger.LogWarning("Registration failed for mobile number: {MobileNumber}. Errors: {Errors}", 
                        request.MobileNumber, string.Join(", ", result.Errors));
                    return BadRequest(result);
                }

                _logger.LogInformation("Registration successful for mobile number: {MobileNumber}", request.MobileNumber);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during registration for mobile number: {MobileNumber}", request.MobileNumber);
                return StatusCode(500, "An error occurred during registration");
            }
        }

        /// <summary>
        /// Sends a 6-digit OTP to the given phone number via SMS.
        /// Always returns 200 OK — the response body does not reveal whether the number is registered.
        /// </summary>
        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword([FromBody] SendOtpRequestDto request)
        {
            _logger.LogInformation("Forgot-password OTP request for phone: {PhoneNumber}", request.PhoneNumber);

            if (string.IsNullOrWhiteSpace(request.PhoneNumber))
                return BadRequest(new { message = "Phone number is required." });

            await _authService.SendForgotPasswordOtpAsync(request.PhoneNumber);

            // Always return 200 so callers cannot enumerate registered phone numbers.
            return Ok(new { message = "If this number is registered, an OTP has been sent." });
        }

        /// <summary>
        /// Verifies the OTP and resets the user's password.
        /// </summary>
        [HttpPost("verify-otp-reset-password")]
        public async Task<IActionResult> VerifyOtpAndResetPassword([FromBody] VerifyOtpResetPasswordDto request)
        {
            _logger.LogInformation("Verify OTP and reset password for phone: {PhoneNumber}", request.PhoneNumber);

            if (request.NewPassword != request.ConfirmPassword)
                return BadRequest(new { message = "Passwords do not match." });

            try
            {
                var result = await _authService.VerifyOtpAndResetPasswordAsync(
                    request.PhoneNumber, request.OtpCode, request.NewPassword);

                if (!result.Success)
                {
                    _logger.LogWarning("OTP reset failed for phone: {PhoneNumber}. Errors: {Errors}",
                        request.PhoneNumber, string.Join(", ", result.Errors));
                    return BadRequest(new { message = result.Errors.FirstOrDefault() ?? "OTP verification failed." });
                }

                _logger.LogInformation("Password reset via OTP successful for phone: {PhoneNumber}", request.PhoneNumber);
                return Ok(new { message = "Password has been reset successfully." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during OTP reset for phone: {PhoneNumber}", request.PhoneNumber);
                return StatusCode(500, "An error occurred. Please try again.");
            }
        }

        [HttpPost("change-password")]
        [Authorize]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordDto request)
        {
            _logger.LogInformation("Change password request for mobile number: {MobileNumber}", request.MobileNumber);
            
            try
            {
                var result = await _authService.ChangePasswordAsync(request.MobileNumber, request.CurrentPassword, request.NewPassword);
                
                if (!result.Success)
                {
                    _logger.LogWarning("Change password failed for mobile number: {MobileNumber}. Errors: {Errors}", 
                        request.MobileNumber, string.Join(", ", result.Errors));
                    return BadRequest(result);
                }

                _logger.LogInformation("Change password successful for mobile number: {MobileNumber}", request.MobileNumber);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during change password for mobile number: {MobileNumber}", request.MobileNumber);
                return StatusCode(500, "An error occurred during change password");
            }
        }
    }
}