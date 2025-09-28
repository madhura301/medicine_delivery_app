using Microsoft.AspNetCore.Identity;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using MedicineDelivery.Infrastructure.Data;
using MedicineDelivery.Domain.Interfaces;

namespace MedicineDelivery.API.Services
{
    public class AuthService : Domain.Interfaces.IAuthService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly SignInManager<ApplicationUser> _signInManager;
        private readonly IConfiguration _configuration;
        private readonly ILogger<AuthService> _logger;

        public AuthService(
            UserManager<ApplicationUser> userManager,
            SignInManager<ApplicationUser> signInManager,
            IConfiguration configuration,
            ILogger<AuthService> logger)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _configuration = configuration;
            _logger = logger;
        }

        public async Task<Domain.Interfaces.AuthResult> LoginAsync(string mobileNumber, string password, bool stayLoggedIn = false)
        {
            _logger.LogInformation("Attempting login for mobile number: {MobileNumber}", mobileNumber);
            
            try
            {
                var user = await _userManager.FindByNameAsync(mobileNumber);
                if (user == null)
                {
                    _logger.LogWarning("Login failed - user not found for mobile number: {MobileNumber}", mobileNumber);
                    return new Domain.Interfaces.AuthResult
                    {
                        Success = false,
                        Errors = new List<string> { "Invalid mobile number or password" }
                    };
                }

                var result = await _signInManager.CheckPasswordSignInAsync(user, password, false);
                if (!result.Succeeded)
                {
                    _logger.LogWarning("Login failed - invalid password for mobile number: {MobileNumber}", mobileNumber);
                    return new Domain.Interfaces.AuthResult
                    {
                        Success = false,
                        Errors = new List<string> { "Invalid mobile number or password" }
                    };
                }

                var token = await GenerateJwtTokenAsync(user);
                _logger.LogInformation("Login successful for mobile number: {MobileNumber}, user ID: {UserId}", mobileNumber, user.Id);
                
                return new Domain.Interfaces.AuthResult
                {
                    Success = true,
                    Token = token
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during login for mobile number: {MobileNumber}", mobileNumber);
                return new Domain.Interfaces.AuthResult
                {
                    Success = false,
                    Errors = new List<string> { "An error occurred during login" }
                };
            }
        }

        public async Task<Domain.Interfaces.AuthResult> RegisterAsync(Domain.Interfaces.RegisterRequest request)
        {
            _logger.LogInformation("Attempting registration for email: {Email}, mobile: {MobileNumber}", 
                request.Email, request.MobileNumber);
            
            try
            {
                var user = new ApplicationUser
                {
                    UserName = request.MobileNumber,
                    Email = request.Email,
                    FirstName = request.FirstName,
                    LastName = request.LastName
                };

                var result = await _userManager.CreateAsync(user, request.Password);
                if (!result.Succeeded)
                {
                    _logger.LogWarning("Registration failed for email: {Email}. Errors: {Errors}", 
                        request.Email, string.Join(", ", result.Errors.Select(e => e.Description)));
                    return new Domain.Interfaces.AuthResult
                    {
                        Success = false,
                        Errors = result.Errors.Select(e => e.Description).ToList()
                    };
                }

                var token = await GenerateJwtTokenAsync(user);
                _logger.LogInformation("Registration successful for email: {Email}, user ID: {UserId}", 
                    request.Email, user.Id);
                
                return new Domain.Interfaces.AuthResult
                {
                    Success = true,
                    Token = token
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during registration for email: {Email}", request.Email);
                return new Domain.Interfaces.AuthResult
                {
                    Success = false,
                    Errors = new List<string> { "An error occurred during registration" }
                };
            }
        }

        public async Task<string> GenerateJwtTokenAsync(ApplicationUser user)
        {
            _logger.LogDebug("Generating JWT token for user ID: {UserId}", user.Id);
            
            try
            {
                var jwtSettings = _configuration.GetSection("JwtSettings");
                var secretKey = jwtSettings["SecretKey"];
                var issuer = jwtSettings["Issuer"];
                var audience = jwtSettings["Audience"];

                var claims = new List<Claim>
                {
                    new(ClaimTypes.NameIdentifier, user.Id),
                    new(ClaimTypes.Email, user.Email ?? string.Empty),
                    new(ClaimTypes.Name, user.UserName ?? string.Empty),
                    new("firstName", user.FirstName ?? string.Empty),
                    new("lastName", user.LastName ?? string.Empty)
                };

                // Add user roles
                var roles = await _userManager.GetRolesAsync(user);
                foreach (var role in roles)
                {
                    claims.Add(new Claim(ClaimTypes.Role, role));
                }

                _logger.LogDebug("JWT token generated with {ClaimCount} claims and {RoleCount} roles for user ID: {UserId}", 
                    claims.Count, roles.Count, user.Id);

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
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating JWT token for user ID: {UserId}", user.Id);
                throw;
            }
        }

        public async Task<bool> ValidateTokenAsync(string token)
        {
            _logger.LogDebug("Validating JWT token");
            
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

                _logger.LogDebug("JWT token validation successful");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "JWT token validation failed");
                return false;
            }
        }

        public async Task<Domain.Interfaces.AuthResult> ForgotPasswordAsync(string mobileNumber)
        {
            _logger.LogInformation("Forgot password request for mobile number: {MobileNumber}", mobileNumber);
            
            try
            {
                var user = await _userManager.FindByNameAsync(mobileNumber);
                if (user == null)
                {
                    _logger.LogWarning("Forgot password failed - user not found for mobile number: {MobileNumber}", mobileNumber);
                    return new Domain.Interfaces.AuthResult
                    {
                        Success = false,
                        Errors = new List<string> { "User not found" }
                    };
                }

                // TODO: Implement actual password reset logic (email/SMS)
                _logger.LogInformation("Forgot password successful for mobile number: {MobileNumber}", mobileNumber);
                
                return new Domain.Interfaces.AuthResult
                {
                    Success = true
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during forgot password for mobile number: {MobileNumber}", mobileNumber);
                return new Domain.Interfaces.AuthResult
                {
                    Success = false,
                    Errors = new List<string> { "An error occurred during forgot password" }
                };
            }
        }

        public async Task<Domain.Interfaces.AuthResult> ResetPasswordAsync(string mobileNumber, string token, string newPassword)
        {
            _logger.LogInformation("Reset password request for mobile number: {MobileNumber}", mobileNumber);
            
            try
            {
                var user = await _userManager.FindByNameAsync(mobileNumber);
                if (user == null)
                {
                    _logger.LogWarning("Reset password failed - user not found for mobile number: {MobileNumber}", mobileNumber);
                    return new Domain.Interfaces.AuthResult
                    {
                        Success = false,
                        Errors = new List<string> { "User not found" }
                    };
                }

                // TODO: Implement actual password reset logic with token validation
                var result = await _userManager.ResetPasswordAsync(user, token, newPassword);
                if (!result.Succeeded)
                {
                    _logger.LogWarning("Reset password failed for mobile number: {MobileNumber}. Errors: {Errors}", 
                        mobileNumber, string.Join(", ", result.Errors.Select(e => e.Description)));
                    return new Domain.Interfaces.AuthResult
                    {
                        Success = false,
                        Errors = result.Errors.Select(e => e.Description).ToList()
                    };
                }

                _logger.LogInformation("Reset password successful for mobile number: {MobileNumber}", mobileNumber);
                
                return new Domain.Interfaces.AuthResult
                {
                    Success = true
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during reset password for mobile number: {MobileNumber}", mobileNumber);
                return new Domain.Interfaces.AuthResult
                {
                    Success = false,
                    Errors = new List<string> { "An error occurred during reset password" }
                };
            }
        }

        public async Task<Domain.Interfaces.AuthResult> ChangePasswordAsync(string mobileNumber, string currentPassword, string newPassword)
        {
            _logger.LogInformation("Change password request for mobile number: {MobileNumber}", mobileNumber);
            
            try
            {
                var user = await _userManager.FindByNameAsync(mobileNumber);
                if (user == null)
                {
                    _logger.LogWarning("Change password failed - user not found for mobile number: {MobileNumber}", mobileNumber);
                    return new Domain.Interfaces.AuthResult
                    {
                        Success = false,
                        Errors = new List<string> { "User not found" }
                    };
                }

                var result = await _userManager.ChangePasswordAsync(user, currentPassword, newPassword);
                if (!result.Succeeded)
                {
                    _logger.LogWarning("Change password failed for mobile number: {MobileNumber}. Errors: {Errors}", 
                        mobileNumber, string.Join(", ", result.Errors.Select(e => e.Description)));
                    return new Domain.Interfaces.AuthResult
                    {
                        Success = false,
                        Errors = result.Errors.Select(e => e.Description).ToList()
                    };
                }

                _logger.LogInformation("Change password successful for mobile number: {MobileNumber}", mobileNumber);
                
                return new Domain.Interfaces.AuthResult
                {
                    Success = true
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during change password for mobile number: {MobileNumber}", mobileNumber);
                return new Domain.Interfaces.AuthResult
                {
                    Success = false,
                    Errors = new List<string> { "An error occurred during change password" }
                };
            }
        }
    }
}
