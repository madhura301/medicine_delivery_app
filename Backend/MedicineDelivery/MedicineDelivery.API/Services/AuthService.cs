using Microsoft.AspNetCore.Identity;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Text;
using MedicineDelivery.Infrastructure.Data;
using MedicineDelivery.Domain.Interfaces;

namespace MedicineDelivery.API.Services
{
    public class AuthService : Domain.Interfaces.IAuthService
    {
        private readonly UserManager<Domain.Entities.ApplicationUser> _userManager;
        private readonly SignInManager<Domain.Entities.ApplicationUser> _signInManager;
        private readonly IConfiguration _configuration;
        private readonly ILogger<AuthService> _logger;
        private readonly IUnitOfWork _unitOfWork;

        public AuthService(
            UserManager<Domain.Entities.ApplicationUser> userManager,
            SignInManager<Domain.Entities.ApplicationUser> signInManager,
            IConfiguration configuration,
            ILogger<AuthService> logger,
            IUnitOfWork unitOfWork)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _configuration = configuration;
            _logger = logger;
            _unitOfWork = unitOfWork;
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
                var user = new Domain.Entities.ApplicationUser
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

        public async Task<string> GenerateJwtTokenAsync(Domain.Entities.ApplicationUser user)
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

                // Get entity-specific ID based on role and add as UserId claim
                var primaryRole = roles.FirstOrDefault() ?? "";
                var entityId = await GetEntityIdByRole(user.Id, primaryRole);
                if (!string.IsNullOrEmpty(entityId))
                {
                    claims.Add(new Claim("UserId", entityId));
                }

                _logger.LogDebug("JWT token generated with {ClaimCount} claims and {RoleCount} roles for user ID: {UserId}", 
                    claims.Count, roles.Count, user.Id);

                var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey ?? string.Empty));
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

        private async Task<string> GetEntityIdByRole(string userId, string role)
        {
            try
            {
                _logger.LogDebug("GetEntityIdByRole: userId={UserId}, role={Role}", userId, role);
                
                switch (role.ToLower())
                {
                    case "customer":
                        var customer = await _unitOfWork.Customers.FirstOrDefaultAsync(c => c.UserId == userId);
                        _logger.LogDebug("Customer found: {CustomerId}", customer?.CustomerId);
                        return customer?.CustomerId.ToString() ?? "";
                    
                    case "manager":
                        var manager = await _unitOfWork.Managers.FirstOrDefaultAsync(m => m.UserId == userId);
                        _logger.LogDebug("Manager found: {ManagerId}", manager?.ManagerId);
                        return manager?.ManagerId.ToString() ?? "";
                    
                    case "customersupport":
                        var customerSupport = await _unitOfWork.CustomerSupports.FirstOrDefaultAsync(cs => cs.UserId == userId);
                        _logger.LogDebug("CustomerSupport found: {CustomerSupportId}", customerSupport?.CustomerSupportId);
                        return customerSupport?.CustomerSupportId.ToString() ?? "";
                    
                    case "chemist":
                        var medicalStore = await _unitOfWork.MedicalStores.FirstOrDefaultAsync(ms => ms.UserId == userId);
                        _logger.LogDebug("MedicalStore found: {MedicalStoreId}", medicalStore?.MedicalStoreId);
                        return medicalStore?.MedicalStoreId.ToString() ?? "";
                    
                    case "deliveryboy":
                        var delivery = await _unitOfWork.Deliveries.FirstOrDefaultAsync(d => d.UserId == userId);
                        _logger.LogDebug("Delivery found: {DeliveryId}", delivery?.Id);
                        return delivery?.Id.ToString() ?? "";
                    
                    case "admin":
                    default:
                        _logger.LogDebug("Using empty string for role: {Role}", role);
                        return ""; // For admin or unknown roles, return empty string
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetEntityIdByRole for userId: {UserId}, role: {Role}", userId, role);
                return ""; // Fallback to empty string if any error occurs
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
                var key = Encoding.UTF8.GetBytes(secretKey ?? string.Empty);

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
