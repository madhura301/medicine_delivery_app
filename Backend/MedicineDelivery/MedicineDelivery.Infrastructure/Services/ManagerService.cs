using Microsoft.AspNetCore.Identity;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Domain.Interfaces;
using MedicineDelivery.Infrastructure.Data;
using AutoMapper;

namespace MedicineDelivery.Infrastructure.Services
{
    public class ManagerService : IManagerService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public ManagerService(
            UserManager<ApplicationUser> userManager,
            IUnitOfWork unitOfWork,
            IMapper mapper)
        {
            _userManager = userManager;
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        public async Task<ManagerRegistrationResult> RegisterManagerAsync(ManagerRegistrationDto registrationDto)
        {
            try
            {
                // Check if manager with this email already exists
                var existingManager = await _unitOfWork.Managers.FirstOrDefaultAsync(m => m.EmailId == registrationDto.EmailId);
                if (existingManager != null)
                {
                    return new ManagerRegistrationResult
                    {
                        Success = false,
                        Errors = new List<string> { "Manager with this email already exists" }
                    };
                }

                // Check if user with this mobile number already exists
                var existingUser = await _userManager.FindByNameAsync(registrationDto.MobileNumber);
                if (existingUser != null)
                {
                    return new ManagerRegistrationResult
                    {
                        Success = false,
                        Errors = new List<string> { "User with this mobile number already exists" }
                    };
                }

                // Generate random password
                var generatedPassword = GenerateRandomPassword();

                // Create Identity user
                var identityUser = new ApplicationUser
                {
                    UserName = registrationDto.MobileNumber,
                    Email = registrationDto.EmailId,
                    PhoneNumber = registrationDto.MobileNumber,
                    FirstName = registrationDto.ManagerFirstName,
                    LastName = registrationDto.ManagerLastName,
                    EmailConfirmed = true
                };

                var userResult = await _userManager.CreateAsync(identityUser, generatedPassword);
                if (!userResult.Succeeded)
                {
                    return new ManagerRegistrationResult
                    {
                        Success = false,
                        Errors = userResult.Errors.Select(e => e.Description).ToList()
                    };
                }

                // Create domain user
                var domainUser = new User
                {
                    Id = identityUser.Id,
                    Email = identityUser.Email,
                    FirstName = identityUser.FirstName ?? string.Empty,
                    LastName = identityUser.LastName ?? string.Empty,
                    CreatedAt = DateTime.UtcNow,
                    IsActive = true
                };

                await _unitOfWork.Users.AddAsync(domainUser);

                // Assign Manager role to the user
                var managerRole = await _unitOfWork.Roles.FirstOrDefaultAsync(r => r.Name == "Manager");
                if (managerRole != null)
                {
                    var userRole = new UserRole
                    {
                        UserId = domainUser.Id,
                        RoleId = managerRole.Id,
                        AssignedAt = DateTime.UtcNow,
                        IsActive = true
                    };
                    await _unitOfWork.UserRoles.AddAsync(userRole);
                }

                // Create manager
                var manager = new Manager
                {
                    ManagerId = Guid.NewGuid(),
                    ManagerFirstName = registrationDto.ManagerFirstName,
                    ManagerLastName = registrationDto.ManagerLastName,
                    ManagerMiddleName = registrationDto.ManagerMiddleName,
                    Address = registrationDto.Address,
                    City = registrationDto.City,
                    State = registrationDto.State,
                    MobileNumber = registrationDto.MobileNumber,
                    EmailId = registrationDto.EmailId,
                    AlternativeMobileNumber = registrationDto.AlternativeMobileNumber,
                    UserId = identityUser.Id,
                    CreatedOn = DateTime.UtcNow,
                    IsActive = true,
                    IsDeleted = false
                };

                await _unitOfWork.Managers.AddAsync(manager);
                await _unitOfWork.SaveChangesAsync();

                // Create response
                var response = new ManagerResponseDto
                {
                    ManagerId = manager.ManagerId,
                    ManagerFirstName = manager.ManagerFirstName,
                    ManagerLastName = manager.ManagerLastName,
                    ManagerMiddleName = manager.ManagerMiddleName,
                    Address = manager.Address,
                    City = manager.City,
                    State = manager.State,
                    MobileNumber = manager.MobileNumber,
                    EmailId = manager.EmailId,
                    AlternativeMobileNumber = manager.AlternativeMobileNumber,
                    IsActive = manager.IsActive,
                    IsDeleted = manager.IsDeleted,
                    CreatedOn = manager.CreatedOn,
                    CreatedBy = manager.CreatedBy,
                    UpdatedOn = manager.UpdatedOn,
                    UpdatedBy = manager.UpdatedBy,
                    UserId = manager.UserId,
                    Password = generatedPassword
                };

                return new ManagerRegistrationResult
                {
                    Success = true,
                    Manager = response
                };
            }
            catch (Exception ex)
            {
                return new ManagerRegistrationResult
                {
                    Success = false,
                    Errors = new List<string> { $"An error occurred: {ex.Message}" }
                };
            }
        }

        public async Task<ManagerDto?> GetManagerByIdAsync(Guid id)
        {
            var manager = await _unitOfWork.Managers.FirstOrDefaultAsync(m => m.ManagerId == id);
            return manager != null ? _mapper.Map<ManagerDto>(manager) : null;
        }

        public async Task<ManagerDto?> GetManagerByEmailAsync(string email)
        {
            var manager = await _unitOfWork.Managers.FirstOrDefaultAsync(m => m.EmailId == email);
            return manager != null ? _mapper.Map<ManagerDto>(manager) : null;
        }

        public async Task<List<ManagerDto>> GetAllManagersAsync()
        {
            var managers = await _unitOfWork.Managers.GetAllAsync();
            return _mapper.Map<List<ManagerDto>>(managers);
        }

        public async Task<ManagerDto?> UpdateManagerAsync(Guid id, ManagerRegistrationDto updateDto)
        {
            var manager = await _unitOfWork.Managers.FirstOrDefaultAsync(m => m.ManagerId == id);
            if (manager == null)
                return null;

            manager.ManagerFirstName = updateDto.ManagerFirstName;
            manager.ManagerLastName = updateDto.ManagerLastName;
            manager.ManagerMiddleName = updateDto.ManagerMiddleName;
            manager.Address = updateDto.Address;
            manager.City = updateDto.City;
            manager.State = updateDto.State;
            manager.MobileNumber = updateDto.MobileNumber;
            manager.AlternativeMobileNumber = updateDto.AlternativeMobileNumber;
            manager.UpdatedOn = DateTime.UtcNow;

            await _unitOfWork.SaveChangesAsync();
            return _mapper.Map<ManagerDto>(manager);
        }

        public async Task<bool> DeleteManagerAsync(Guid id)
        {
            var manager = await _unitOfWork.Managers.FirstOrDefaultAsync(m => m.ManagerId == id);
            if (manager == null)
                return false;

            manager.IsActive = false;
            manager.IsDeleted = true;
            manager.UpdatedOn = DateTime.UtcNow;

            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        private string GenerateRandomPassword()
        {
            const string capitalLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
            const string smallLetters = "abcdefghijklmnopqrstuvwxyz";
            const string numbers = "0123456789";
            const string specialChars = "!@#$%^&*";
            const string allChars = capitalLetters + smallLetters + numbers + specialChars;
            
            var random = new Random();
            var password = new List<char>();
            
            // Ensure minimum requirements
            password.Add(capitalLetters[random.Next(capitalLetters.Length)]); // 1st capital
            password.Add(capitalLetters[random.Next(capitalLetters.Length)]); // 2nd capital
            password.Add(smallLetters[random.Next(smallLetters.Length)]);     // 1st small
            password.Add(smallLetters[random.Next(smallLetters.Length)]);     // 2nd small
            password.Add(numbers[random.Next(numbers.Length)]);               // 1st number
            password.Add(numbers[random.Next(numbers.Length)]);               // 2nd number
            password.Add(specialChars[random.Next(specialChars.Length)]);     // 1st special
            
            // Fill remaining length (total 12 characters)
            for (int i = 7; i < 12; i++)
            {
                password.Add(allChars[random.Next(allChars.Length)]);
            }
            
            // Shuffle the password to randomize positions
            for (int i = password.Count - 1; i > 0; i--)
            {
                int j = random.Next(i + 1);
                (password[i], password[j]) = (password[j], password[i]);
            }
            
            return new string(password.ToArray());
        }
    }
}
