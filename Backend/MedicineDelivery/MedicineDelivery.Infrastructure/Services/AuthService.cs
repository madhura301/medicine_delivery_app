using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Domain.Interfaces;
using MedicineDelivery.Infrastructure.Data;

namespace MedicineDelivery.Infrastructure.Services
{
    public class TokenResult
    {
        public string Token { get; set; } = string.Empty;
        public DateTime ExpiresAt { get; set; }
        public string Role { get; set; } = string.Empty;
        public string UserId { get; set; } = string.Empty;
        public string EntityId { get; set; } = string.Empty;
    }

    public class AuthService : IAuthService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly SignInManager<ApplicationUser> _signInManager;
        private readonly IConfiguration _configuration;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ILogger<AuthService> _logger;

        public AuthService(
            UserManager<ApplicationUser> userManager,
            SignInManager<ApplicationUser> signInManager,
            IConfiguration configuration,
            IUnitOfWork unitOfWork,
            ILogger<AuthService> logger)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _configuration = configuration;
            _unitOfWork = unitOfWork;
            _logger = logger;
        }

        public async Task<AuthResult> LoginAsync(string mobileNumber, string password, bool stayLoggedIn = false)
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

            // User validation is now handled by Identity directly

            var tokenResult = await GenerateJwtTokenAsync(user, stayLoggedIn);
            return new AuthResult
            {
                Success = true,
                Token = tokenResult.Token,
                ExpiresAt = tokenResult.ExpiresAt,
                Role = tokenResult.Role,
                UserId = tokenResult.UserId,
                EntityId = tokenResult.EntityId
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

            var tokenResult = await GenerateJwtTokenAsync(user, false);
            return new AuthResult
            {
                Success = true,
                Token = tokenResult.Token,
                ExpiresAt = tokenResult.ExpiresAt,
                Role = tokenResult.Role,
                UserId = tokenResult.UserId,
                EntityId = tokenResult.EntityId
            };
        }

        public async Task<TokenResult> GenerateJwtTokenAsync(Domain.Entities.ApplicationUser user, bool stayLoggedIn = false)
        {
            var jwtSettings = _configuration.GetSection("JwtSettings");
            var secretKey = jwtSettings["SecretKey"];
            var issuer = jwtSettings["Issuer"];
            var audience = jwtSettings["Audience"];

            // Get user roles and determine primary role
            var identityUser = await _userManager.FindByIdAsync(user.Id);
            var roles = new List<string>();
            var primaryRole = "";
            var entityId = "";

            if (identityUser != null)
            {
                roles = (await _userManager.GetRolesAsync(identityUser)).ToList();
                primaryRole = roles.FirstOrDefault() ?? "";
                
                _logger.LogDebug("User {UserId} has Identity roles: {Roles}", user.Id, string.Join(", ", roles));
                
                // All roles are now managed through Identity
            }

            // Get entity-specific ID based on role
            entityId = await GetEntityIdByRole(user.Id, primaryRole);
            
            _logger.LogDebug("User {UserId} with role {Role} has EntityId: {EntityId}", user.Id, primaryRole, entityId);

            var claims = new List<Claim>
            {
                new(ClaimTypes.NameIdentifier, user.Id),
                new(ClaimTypes.Email, user.Email ?? string.Empty),
                new(ClaimTypes.Name, user.Email ?? string.Empty),
                new("firstName", user.FirstName ?? string.Empty),
                new("lastName", user.LastName ?? string.Empty),
                new("role", primaryRole),
                new("entityId", entityId)
            };

            // Add all role claims
            foreach (var role in roles)
            {
                claims.Add(new Claim(ClaimTypes.Role, role));
            }

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey ?? string.Empty));
            var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            // Set token expiry based on StayLoggedIn
            var expiresAt = stayLoggedIn ? DateTime.UtcNow.AddDays(30) : DateTime.UtcNow.AddHours(1);

            var token = new JwtSecurityToken(
                issuer: issuer,
                audience: audience,
                claims: claims,
                expires: expiresAt,
                signingCredentials: credentials
            );

            return new TokenResult
            {
                Token = new JwtSecurityTokenHandler().WriteToken(token),
                ExpiresAt = expiresAt,
                Role = primaryRole,
                UserId = user.Id,
                EntityId = entityId
            };
        }

        private async Task<string> GetEntityIdByRole(string userId, string role)
        {
            try
            {
                _logger.LogDebug("GetEntityIdByRole: UserId={UserId}, Role={Role}", userId, role);
                
                switch (role.ToLower())
                {
                    case "customer":
                        var customer = await _unitOfWork.Customers.FirstOrDefaultAsync(c => c.UserId == userId);
                        _logger.LogDebug("Customer found for User {UserId}: {CustomerId}", userId, customer?.CustomerId);
                        return customer?.CustomerId.ToString() ?? "";
                    
                    case "manager":
                        var manager = await _unitOfWork.Managers.FirstOrDefaultAsync(m => m.UserId == userId);
                        _logger.LogDebug("Manager found for User {UserId}: {ManagerId}", userId, manager?.ManagerId);
                        return manager?.ManagerId.ToString() ?? "";
                    
                    case "customersupport":
                        var customerSupport = await _unitOfWork.CustomerSupports.FirstOrDefaultAsync(cs => cs.UserId == userId);
                        _logger.LogDebug("CustomerSupport found for User {UserId}: {CustomerSupportId}", userId, customerSupport?.CustomerSupportId);
                        return customerSupport?.CustomerSupportId.ToString() ?? "";
                    
                    case "chemist":
                        var medicalStore = await _unitOfWork.MedicalStores.FirstOrDefaultAsync(ms => ms.UserId == userId);
                        _logger.LogDebug("MedicalStore found for User {UserId}: {MedicalStoreId}", userId, medicalStore?.MedicalStoreId);
                        return medicalStore?.MedicalStoreId.ToString() ?? "";
                    
                    case "admin":
                    default:
                        _logger.LogDebug("Using UserId as EntityId for User {UserId} with role: {Role}", userId, role);
                        return userId; // For admin, use userId as entityId
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetEntityIdByRole for User {UserId} with role {Role}", userId, role);
                return userId; // Fallback to userId if any error occurs
            }
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

                return true;
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Token validation failed");
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
