using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Domain.Interfaces;
using MedicineDelivery.Infrastructure.Data;

namespace MedicineDelivery.Infrastructure.Services
{
    public class AuthService : IAuthService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly SignInManager<ApplicationUser> _signInManager;
        private readonly IConfiguration _configuration;
        private readonly IUnitOfWork _unitOfWork;

        public AuthService(
            UserManager<ApplicationUser> userManager,
            SignInManager<ApplicationUser> signInManager,
            IConfiguration configuration,
            IUnitOfWork unitOfWork)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _configuration = configuration;
            _unitOfWork = unitOfWork;
        }

        public async Task<AuthResult> LoginAsync(string mobileNumber, string password)
        {
            var user = await _userManager.FindByNameAsync(mobileNumber);
            if (user == null)
            {
                return new AuthResult
                {
                    Success = false,
                    Errors = new List<string> { "Invalid mobile number or password" }
                };
            }

            var result = await _signInManager.CheckPasswordSignInAsync(user, password, false);
            if (!result.Succeeded)
            {
                return new AuthResult
                {
                    Success = false,
                    Errors = new List<string> { "Invalid mobile number or password" }
                };
            }

            var domainUser = await _unitOfWork.Users.FirstOrDefaultAsync(u => u.Id == user.Id);
            if (domainUser == null)
            {
                return new AuthResult
                {
                    Success = false,
                    Errors = new List<string> { "User not found" }
                };
            }

            var token = await GenerateJwtTokenAsync(domainUser);
            return new AuthResult
            {
                Success = true,
                Token = token
            };
        }

        public async Task<AuthResult> RegisterAsync(RegisterRequest request)
        {
            var user = new ApplicationUser
            {
                UserName = request.MobileNumber,
                Email = request.Email ?? $"{request.MobileNumber}@user.local",
                PhoneNumber = request.MobileNumber,
                FirstName = request.FirstName,
                LastName = request.LastName
            };

            var result = await _userManager.CreateAsync(user, request.Password);
            if (!result.Succeeded)
            {
                return new AuthResult
                {
                    Success = false,
                    Errors = result.Errors.Select(e => e.Description).ToList()
                };
            }

            // Assign Admin role to the user
            await _userManager.AddToRoleAsync(user, "Admin");

            var domainUser = new User
            {
                Id = user.Id,
                Email = user.Email,
                FirstName = user.FirstName ?? string.Empty,
                LastName = user.LastName ?? string.Empty,
                CreatedAt = DateTime.UtcNow,
                IsActive = true
            };

            await _unitOfWork.Users.AddAsync(domainUser);
            await _unitOfWork.SaveChangesAsync();

            var token = await GenerateJwtTokenAsync(domainUser);
            return new AuthResult
            {
                Success = true,
                Token = token
            };
        }

        public async Task<string> GenerateJwtTokenAsync(User user)
        {
            var jwtSettings = _configuration.GetSection("JwtSettings");
            var secretKey = jwtSettings["SecretKey"];
            var issuer = jwtSettings["Issuer"];
            var audience = jwtSettings["Audience"];

            var claims = new List<Claim>
            {
                new(ClaimTypes.NameIdentifier, user.Id),
                new(ClaimTypes.Email, user.Email),
                new(ClaimTypes.Name, user.Email),
                new("firstName", user.FirstName),
                new("lastName", user.LastName)
            };

            // Add role claims
            var identityUser = await _userManager.FindByIdAsync(user.Id);
            if (identityUser != null)
            {
                var roles = await _userManager.GetRolesAsync(identityUser);
                foreach (var role in roles)
                {
                    claims.Add(new Claim(ClaimTypes.Role, role));
                }
            }

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));
            var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: issuer,
                audience: audience,
                claims: claims,
                expires: DateTime.UtcNow.AddHours(1),
                signingCredentials: credentials
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        public async Task<bool> ValidateTokenAsync(string token)
        {
            try
            {
                var jwtSettings = _configuration.GetSection("JwtSettings");
                var secretKey = jwtSettings["SecretKey"];
                var issuer = jwtSettings["Issuer"];
                var audience = jwtSettings["Audience"];

                var tokenHandler = new JwtSecurityTokenHandler();
                var key = Encoding.UTF8.GetBytes(secretKey);

                tokenHandler.ValidateToken(token, new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(key),
                    ValidateIssuer = true,
                    ValidIssuer = issuer,
                    ValidateAudience = true,
                    ValidAudience = audience,
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.Zero
                }, out SecurityToken validatedToken);

                return true;
            }
            catch
            {
                return false;
            }
        }

        public async Task<AuthResult> ForgotPasswordAsync(string mobileNumber)
        {
            var user = await _userManager.FindByNameAsync(mobileNumber);
            if (user == null)
            {
                return new AuthResult
                {
                    Success = false,
                    Errors = new List<string> { "User with this mobile number not found" }
                };
            }

            var token = await _userManager.GeneratePasswordResetTokenAsync(user);
            
            // In a real application, you would send this token via SMS or email
            // For now, we'll return it in the response for testing purposes
            return new AuthResult
            {
                Success = true,
                Token = token // This should be sent via SMS in production
            };
        }

        public async Task<AuthResult> ResetPasswordAsync(string mobileNumber, string token, string newPassword)
        {
            var user = await _userManager.FindByNameAsync(mobileNumber);
            if (user == null)
            {
                return new AuthResult
                {
                    Success = false,
                    Errors = new List<string> { "User with this mobile number not found" }
                };
            }

            var result = await _userManager.ResetPasswordAsync(user, token, newPassword);
            if (!result.Succeeded)
            {
                return new AuthResult
                {
                    Success = false,
                    Errors = result.Errors.Select(e => e.Description).ToList()
                };
            }

            return new AuthResult
            {
                Success = true
            };
        }

        public async Task<AuthResult> ChangePasswordAsync(string mobileNumber, string currentPassword, string newPassword)
        {
            var user = await _userManager.FindByNameAsync(mobileNumber);
            if (user == null)
            {
                return new AuthResult
                {
                    Success = false,
                    Errors = new List<string> { "User with this mobile number not found" }
                };
            }

            var result = await _userManager.ChangePasswordAsync(user, currentPassword, newPassword);
            if (!result.Succeeded)
            {
                return new AuthResult
                {
                    Success = false,
                    Errors = result.Errors.Select(e => e.Description).ToList()
                };
            }

            return new AuthResult
            {
                Success = true
            };
        }
    }
}
