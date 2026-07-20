using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using MedicineDelivery.Infrastructure.Data;
using MedicineDelivery.Domain.Interfaces;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Domain.Enums;

namespace MedicineDelivery.API.Services
{
    public class AuthService : Domain.Interfaces.IAuthService
    {
        private readonly UserManager<Domain.Entities.ApplicationUser> _userManager;
        private readonly SignInManager<Domain.Entities.ApplicationUser> _signInManager;
        private readonly IConfiguration _configuration;
        private readonly ILogger<AuthService> _logger;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ISmsService _smsService;

        public AuthService(
            UserManager<Domain.Entities.ApplicationUser> userManager,
            SignInManager<Domain.Entities.ApplicationUser> signInManager,
            IConfiguration configuration,
            ILogger<AuthService> logger,
            IUnitOfWork unitOfWork,
            ISmsService smsService)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _configuration = configuration;
            _logger = logger;
            _unitOfWork = unitOfWork;
            _smsService = smsService;
        }

        public async Task<Domain.Interfaces.AuthResult> LoginAsync(string mobileNumber, string password, bool stayLoggedIn = false)
        {
            _logger.LogInformation("Attempting login for mobile number: {MobileNumber}", mobileNumber);
            
            try
            {
                // Primary lookup is by username (mobile is the username for most roles).
                // Fall back to a phone-number lookup so accounts registered through paths
                // that store the email as the username can still log in with their mobile.
                var user = await _userManager.FindByNameAsync(mobileNumber)
                    ?? await _userManager.Users.FirstOrDefaultAsync(u => u.PhoneNumber == mobileNumber);
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
                // Reject duplicate mobile numbers up front (matched on username or phone number)
                // so the same mobile cannot be registered twice across roles.
                var existingUser = await _userManager.FindByNameAsync(request.MobileNumber)
                    ?? await _userManager.Users.FirstOrDefaultAsync(u => u.PhoneNumber == request.MobileNumber);
                if (existingUser != null)
                {
                    _logger.LogWarning("Registration failed - mobile number already exists: {MobileNumber}", request.MobileNumber);
                    return new Domain.Interfaces.AuthResult
                    {
                        Success = false,
                        Errors = new List<string> { "A user with this mobile number already exists" }
                    };
                }

                var user = new Domain.Entities.ApplicationUser
                {
                    UserName = request.MobileNumber,
                    Email = request.Email,
                    FirstName = request.FirstName,
                    LastName = request.LastName,
                    PhoneNumber = request.MobileNumber
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

        public async Task<Domain.Interfaces.AuthResult> SendForgotPasswordOtpAsync(string phoneNumber)
        {
            _logger.LogInformation("Send forgot-password OTP request for phone: {PhoneNumber}", phoneNumber);

            try
            {
                // Always return the same response shape to prevent phone number enumeration.
                var user = await _userManager.FindByNameAsync(phoneNumber);
                if (user == null)
                {
                    _logger.LogWarning("SendForgotPasswordOtp - no user found for phone: {PhoneNumber}", phoneNumber);
                    // Return success so callers cannot infer whether the number is registered.
                    return new Domain.Interfaces.AuthResult { Success = true };
                }

                var expiryMinutes = int.Parse(_configuration["OtpSettings:ExpiryMinutes"] ?? "5");

                // Invalidate any existing unused OTPs for this phone + purpose
                var existing = await _unitOfWork.UserOtps
                    .FindAsync(o => o.PhoneNumber == phoneNumber
                                    && o.Purpose == OtpPurpose.ForgotPassword
                                    && !o.IsUsed
                                    && o.ExpiresAt > DateTime.UtcNow);

                foreach (var old in existing)
                {
                    old.IsUsed = true;
                    _unitOfWork.UserOtps.Update(old);
                }

                // Generate a 6-digit crypto-random OTP
                var otpCode = GenerateOtpCode();

                var otpRecord = new UserOtp
                {
                    PhoneNumber = phoneNumber,
                    OtpCodeHash = ComputeSha256(otpCode),
                    Purpose = OtpPurpose.ForgotPassword,
                    CreatedAt = DateTime.UtcNow,
                    ExpiresAt = DateTime.UtcNow.AddMinutes(expiryMinutes),
                    IsUsed = false,
                    AttemptCount = 0
                };

                await _unitOfWork.UserOtps.AddAsync(otpRecord);
                await _unitOfWork.SaveChangesAsync();

                await _smsService.SendOtpAsync(phoneNumber, otpCode, user.FirstName);

                _logger.LogInformation("Forgot-password OTP sent for phone: {PhoneNumber}", phoneNumber);
                return new Domain.Interfaces.AuthResult { Success = true };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending forgot-password OTP for phone: {PhoneNumber}", phoneNumber);
                return new Domain.Interfaces.AuthResult
                {
                    Success = false,
                    Errors = new List<string> { "An error occurred. Please try again." }
                };
            }
        }

        public async Task<Domain.Interfaces.AuthResult> VerifyOtpAndResetPasswordAsync(string phoneNumber, string otpCode, string newPassword)
        {
            _logger.LogInformation("Verify OTP and reset password for phone: {PhoneNumber}", phoneNumber);

            try
            {
                var maxAttempts = int.Parse(_configuration["OtpSettings:MaxAttempts"] ?? "5");

                var otpRecord = await _unitOfWork.UserOtps
                    .FirstOrDefaultAsync(o => o.PhoneNumber == phoneNumber
                                              && o.Purpose == OtpPurpose.ForgotPassword
                                              && !o.IsUsed
                                              && o.ExpiresAt > DateTime.UtcNow);

                if (otpRecord == null)
                {
                    _logger.LogWarning("VerifyOtpAndResetPassword - no valid OTP found for phone: {PhoneNumber}", phoneNumber);
                    return new Domain.Interfaces.AuthResult
                    {
                        Success = false,
                        Errors = new List<string> { "OTP is invalid or has expired. Please request a new one." }
                    };
                }

                otpRecord.AttemptCount++;

                if (otpRecord.AttemptCount > maxAttempts)
                {
                    otpRecord.IsUsed = true; // block further attempts on this OTP
                    _unitOfWork.UserOtps.Update(otpRecord);
                    await _unitOfWork.SaveChangesAsync();

                    _logger.LogWarning("VerifyOtpAndResetPassword - max attempts exceeded for phone: {PhoneNumber}", phoneNumber);
                    return new Domain.Interfaces.AuthResult
                    {
                        Success = false,
                        Errors = new List<string> { "Too many failed attempts. Please request a new OTP." }
                    };
                }

                if (ComputeSha256(otpCode) != otpRecord.OtpCodeHash)
                {
                    _unitOfWork.UserOtps.Update(otpRecord);
                    await _unitOfWork.SaveChangesAsync();

                    _logger.LogWarning("VerifyOtpAndResetPassword - invalid OTP for phone: {PhoneNumber}", phoneNumber);
                    return new Domain.Interfaces.AuthResult
                    {
                        Success = false,
                        Errors = new List<string> { "Invalid OTP. Please try again." }
                    };
                }

                // OTP is valid — mark as used before touching the password
                otpRecord.IsUsed = true;
                _unitOfWork.UserOtps.Update(otpRecord);
                await _unitOfWork.SaveChangesAsync();

                var user = await _userManager.FindByNameAsync(phoneNumber);
                if (user == null)
                {
                    _logger.LogWarning("VerifyOtpAndResetPassword - user disappeared for phone: {PhoneNumber}", phoneNumber);
                    return new Domain.Interfaces.AuthResult
                    {
                        Success = false,
                        Errors = new List<string> { "User not found." }
                    };
                }

                // Remove old password and set the new one
                await _userManager.RemovePasswordAsync(user);
                var result = await _userManager.AddPasswordAsync(user, newPassword);

                if (!result.Succeeded)
                {
                    _logger.LogWarning("VerifyOtpAndResetPassword - password reset failed for phone: {PhoneNumber}. Errors: {Errors}",
                        phoneNumber, string.Join(", ", result.Errors.Select(e => e.Description)));
                    return new Domain.Interfaces.AuthResult
                    {
                        Success = false,
                        Errors = result.Errors.Select(e => e.Description).ToList()
                    };
                }

                _logger.LogInformation("Password reset successful for phone: {PhoneNumber}", phoneNumber);
                return new Domain.Interfaces.AuthResult { Success = true };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error verifying OTP and resetting password for phone: {PhoneNumber}", phoneNumber);
                return new Domain.Interfaces.AuthResult
                {
                    Success = false,
                    Errors = new List<string> { "An error occurred. Please try again." }
                };
            }
        }

        private static string GenerateOtpCode()
        {
            // Crypto-random 6-digit number: 100000–999999
            var bytes = new byte[4];
            RandomNumberGenerator.Fill(bytes);
            var value = Math.Abs(BitConverter.ToInt32(bytes, 0)) % 900000 + 100000;
            return value.ToString();
        }

        private static string ComputeSha256(string input)
        {
            var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(input));
            return Convert.ToHexString(bytes).ToLowerInvariant();
        }
    }
}
