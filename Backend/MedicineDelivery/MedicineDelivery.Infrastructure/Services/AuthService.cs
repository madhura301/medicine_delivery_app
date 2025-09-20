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

            var domainUser = await _unitOfWork.Users.FirstOrDefaultAsync(u => u.Id == user.Id);
            if (domainUser == null)
            {
                return new AuthResult
                {
                    Success = false,
                    Errors = new List<string> { "User not found" }
                };
            }

            var tokenResult = await GenerateJwtTokenAsync(domainUser, stayLoggedIn);
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

            var tokenResult = await GenerateJwtTokenAsync(domainUser, false);
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

        public async Task<TokenResult> GenerateJwtTokenAsync(User user, bool stayLoggedIn = false)
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
                
                // Debug: Log the roles found
                Console.WriteLine($"User {user.Id} has Identity roles: {string.Join(", ", roles)}");
                
                // If no roles from Identity, try to get from domain UserRole table
                if (!roles.Any())
                {
                    Console.WriteLine("No Identity roles found, checking domain UserRole table...");
                    var domainUserRoles = await _unitOfWork.UserRoles.GetAllAsync();
                    var userDomainRoles = domainUserRoles.Where(ur => ur.UserId == user.Id && ur.IsActive);
                    
                    if (userDomainRoles.Any())
                    {
                        // Get role names from role IDs
                        var allRoles = await _unitOfWork.Roles.GetAllAsync();
                        var userRoleIds = userDomainRoles.Select(ur => ur.RoleId).ToList();
                        var userRoleNames = allRoles.Where(r => userRoleIds.Contains(r.Id) && r.IsActive).Select(r => r.Name).ToList();
                        roles = userRoleNames;
                        primaryRole = roles.FirstOrDefault() ?? "";
                        Console.WriteLine($"User {user.Id} has domain roles: {string.Join(", ", roles)}");
                    }
                }
            }

            // Get entity-specific ID based on role
            entityId = await GetEntityIdByRole(user.Id, primaryRole);
            
            // Debug: Log the entity ID found
            Console.WriteLine($"User {user.Id} with role {primaryRole} has entityId: {entityId}");

            var claims = new List<Claim>
            {
                new(ClaimTypes.NameIdentifier, user.Id),
                new(ClaimTypes.Email, user.Email),
                new(ClaimTypes.Name, user.Email),
                new("firstName", user.FirstName),
                new("lastName", user.LastName),
                new("role", primaryRole),
                new("entityId", entityId)
            };

            // Add all role claims
            foreach (var role in roles)
            {
                claims.Add(new Claim(ClaimTypes.Role, role));
            }

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));
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
                Console.WriteLine($"GetEntityIdByRole: userId={userId}, role={role}");
                
                switch (role.ToLower())
                {
                    case "customer":
                        var customer = await _unitOfWork.Customers.FirstOrDefaultAsync(c => c.UserId == userId);
                        Console.WriteLine($"Customer found: {customer?.CustomerId}");
                        return customer?.CustomerId.ToString() ?? "";
                    
                    case "manager":
                        var manager = await _unitOfWork.Managers.FirstOrDefaultAsync(m => m.UserId == userId);
                        Console.WriteLine($"Manager found: {manager?.ManagerId}");
                        return manager?.ManagerId.ToString() ?? "";
                    
                    case "customersupport":
                        var customerSupport = await _unitOfWork.CustomerSupports.FirstOrDefaultAsync(cs => cs.UserId == userId);
                        Console.WriteLine($"CustomerSupport found: {customerSupport?.CustomerSupportId}");
                        return customerSupport?.CustomerSupportId.ToString() ?? "";
                    
                    case "chemist":
                        var medicalStore = await _unitOfWork.MedicalStores.FirstOrDefaultAsync(ms => ms.UserId == userId);
                        Console.WriteLine($"MedicalStore found: {medicalStore?.MedicalStoreId}");
                        return medicalStore?.MedicalStoreId.ToString() ?? "";
                    
                    case "admin":
                    default:
                        Console.WriteLine($"Using userId as entityId for role: {role}");
                        return userId; // For admin, use userId as entityId
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error in GetEntityIdByRole: {ex.Message}");
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
