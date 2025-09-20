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

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto request)
        {
            var result = await _authService.LoginAsync(request.MobileNumber, request.Password);
            
            if (!result.Success)
            {
                return BadRequest(result);
            }

            return Ok(result);
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto request)
        {
            var registerRequest = new RegisterRequest
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
                return BadRequest(result);
            }

            return Ok(result);
        }

        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordDto request)
        {
            var result = await _authService.ForgotPasswordAsync(request.MobileNumber);
            
            if (!result.Success)
            {
                return BadRequest(result);
            }

            return Ok(result);
        }

        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordDto request)
        {
            var result = await _authService.ResetPasswordAsync(request.MobileNumber, request.Token, request.NewPassword);
            
            if (!result.Success)
            {
                return BadRequest(result);
            }

            return Ok(result);
        }

        [HttpPost("change-password")]
        [Authorize]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordDto request)
        {
            var result = await _authService.ChangePasswordAsync(request.MobileNumber, request.CurrentPassword, request.NewPassword);
            
            if (!result.Success)
            {
                return BadRequest(result);
            }

            return Ok(result);
        }
    }
}