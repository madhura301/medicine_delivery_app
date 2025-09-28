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

        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordDto request)
        {
            _logger.LogInformation("Forgot password request for mobile number: {MobileNumber}", request.MobileNumber);
            
            try
            {
                var result = await _authService.ForgotPasswordAsync(request.MobileNumber);
                
                if (!result.Success)
                {
                    _logger.LogWarning("Forgot password failed for mobile number: {MobileNumber}. Errors: {Errors}", 
                        request.MobileNumber, string.Join(", ", result.Errors));
                    return BadRequest(result);
                }

                _logger.LogInformation("Forgot password successful for mobile number: {MobileNumber}", request.MobileNumber);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during forgot password for mobile number: {MobileNumber}", request.MobileNumber);
                return StatusCode(500, "An error occurred during forgot password");
            }
        }

        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordDto request)
        {
            _logger.LogInformation("Reset password request for mobile number: {MobileNumber}", request.MobileNumber);
            
            try
            {
                var result = await _authService.ResetPasswordAsync(request.MobileNumber, request.Token, request.NewPassword);
                
                if (!result.Success)
                {
                    _logger.LogWarning("Reset password failed for mobile number: {MobileNumber}. Errors: {Errors}", 
                        request.MobileNumber, string.Join(", ", result.Errors));
                    return BadRequest(result);
                }

                _logger.LogInformation("Reset password successful for mobile number: {MobileNumber}", request.MobileNumber);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during reset password for mobile number: {MobileNumber}", request.MobileNumber);
                return StatusCode(500, "An error occurred during reset password");
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