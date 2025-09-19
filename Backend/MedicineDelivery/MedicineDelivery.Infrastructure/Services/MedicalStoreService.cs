using Microsoft.AspNetCore.Identity;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Domain.Interfaces;
using MedicineDelivery.Infrastructure.Data;
using AutoMapper;

namespace MedicineDelivery.Infrastructure.Services
{
    public class MedicalStoreService : IMedicalStoreService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public MedicalStoreService(
            UserManager<ApplicationUser> userManager,
            IUnitOfWork unitOfWork,
            IMapper mapper)
        {
            _userManager = userManager;
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        public async Task<MedicalStoreRegistrationResult> RegisterMedicalStoreAsync(MedicalStoreRegistrationDto registrationDto)
        {
            try
            {
                // Check if medical store with this email already exists
                var existingMedicalStore = await _unitOfWork.MedicalStores.FirstOrDefaultAsync(ms => ms.EmailId == registrationDto.EmailId);
                if (existingMedicalStore != null)
                {
                    return new MedicalStoreRegistrationResult
                    {
                        Success = false,
                        Errors = new List<string> { "Medical store with this email already exists" }
                    };
                }

                // Check if user with this email already exists
                var existingUser = await _userManager.FindByEmailAsync(registrationDto.EmailId);
                if (existingUser != null)
                {
                    return new MedicalStoreRegistrationResult
                    {
                        Success = false,
                        Errors = new List<string> { "User with this email already exists" }
                    };
                }

                // Generate random password
                var generatedPassword = GenerateRandomPassword();

                // Create Identity user
                var identityUser = new ApplicationUser
                {
                    UserName = registrationDto.EmailId,
                    Email = registrationDto.EmailId,
                    FirstName = registrationDto.OwnerFirstName,
                    LastName = registrationDto.OwnerLastName,
                    EmailConfirmed = true
                };

                var userResult = await _userManager.CreateAsync(identityUser, generatedPassword);
                if (!userResult.Succeeded)
                {
                    return new MedicalStoreRegistrationResult
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

                // Assign Chemist role to the user
                var chemistRole = await _unitOfWork.Roles.FirstOrDefaultAsync(r => r.Name == "Chemist");
                if (chemistRole != null)
                {
                    var userRole = new UserRole
                    {
                        UserId = domainUser.Id,
                        RoleId = chemistRole.Id,
                        AssignedAt = DateTime.UtcNow,
                        IsActive = true
                    };
                    await _unitOfWork.UserRoles.AddAsync(userRole);
                }

                // Create medical store
                var medicalStore = new MedicalStore
                {
                    MedicalStoreId = Guid.NewGuid(),
                    MedicalName = registrationDto.MedicalName,
                    OwnerFirstName = registrationDto.OwnerFirstName,
                    OwnerLastName = registrationDto.OwnerLastName,
                    OwnerMiddleName = registrationDto.OwnerMiddleName,
                    AddressLine1 = registrationDto.AddressLine1,
                    AddressLine2 = registrationDto.AddressLine2,
                    City = registrationDto.City,
                    State = registrationDto.State,
                    PostalCode = registrationDto.PostalCode,
                    Latitude = registrationDto.Latitude,
                    Longitude = registrationDto.Longitude,
                    MobileNumber = registrationDto.MobileNumber,
                    EmailId = registrationDto.EmailId,
                    AlternativeMobileNumber = registrationDto.AlternativeMobileNumber,
                    RegistrationStatus = registrationDto.RegistrationStatus,
                    GSTIN = registrationDto.GSTIN,
                    PAN = registrationDto.PAN,
                    FSSAINo = registrationDto.FSSAINo,
                    DLNo = registrationDto.DLNo,
                    PharmacistFirstName = registrationDto.PharmacistFirstName,
                    PharmacistLastName = registrationDto.PharmacistLastName,
                    PharmacistRegistrationNumber = registrationDto.PharmacistRegistrationNumber,
                    PharmacistMobileNumber = registrationDto.PharmacistMobileNumber,
                    UserId = identityUser.Id,
                    CreatedOn = DateTime.UtcNow,
                    IsActive = true,
                    IsDeleted = false
                };

                await _unitOfWork.MedicalStores.AddAsync(medicalStore);
                await _unitOfWork.SaveChangesAsync();

                // Create response
                var response = new MedicalStoreResponseDto
                {
                    MedicalStoreId = medicalStore.MedicalStoreId,
                    MedicalName = medicalStore.MedicalName,
                    OwnerFirstName = medicalStore.OwnerFirstName,
                    OwnerLastName = medicalStore.OwnerLastName,
                    OwnerMiddleName = medicalStore.OwnerMiddleName,
                    AddressLine1 = medicalStore.AddressLine1,
                    AddressLine2 = medicalStore.AddressLine2,
                    City = medicalStore.City,
                    State = medicalStore.State,
                    PostalCode = medicalStore.PostalCode,
                    Latitude = medicalStore.Latitude,
                    Longitude = medicalStore.Longitude,
                    MobileNumber = medicalStore.MobileNumber,
                    EmailId = medicalStore.EmailId,
                    AlternativeMobileNumber = medicalStore.AlternativeMobileNumber,
                    RegistrationStatus = medicalStore.RegistrationStatus,
                    GSTIN = medicalStore.GSTIN,
                    PAN = medicalStore.PAN,
                    FSSAINo = medicalStore.FSSAINo,
                    DLNo = medicalStore.DLNo,
                    PharmacistFirstName = medicalStore.PharmacistFirstName,
                    PharmacistLastName = medicalStore.PharmacistLastName,
                    PharmacistRegistrationNumber = medicalStore.PharmacistRegistrationNumber,
                    PharmacistMobileNumber = medicalStore.PharmacistMobileNumber,
                    IsActive = medicalStore.IsActive,
                    IsDeleted = medicalStore.IsDeleted,
                    CreatedOn = medicalStore.CreatedOn,
                    CreatedBy = medicalStore.CreatedBy,
                    UpdatedOn = medicalStore.UpdatedOn,
                    UpdatedBy = medicalStore.UpdatedBy,
                    UserId = medicalStore.UserId,
                    GeneratedPassword = generatedPassword
                };

                return new MedicalStoreRegistrationResult
                {
                    Success = true,
                    MedicalStore = response
                };
            }
            catch (Exception ex)
            {
                return new MedicalStoreRegistrationResult
                {
                    Success = false,
                    Errors = new List<string> { $"An error occurred: {ex.Message}" }
                };
            }
        }

        public async Task<MedicalStoreDto?> GetMedicalStoreByIdAsync(Guid id)
        {
            var medicalStore = await _unitOfWork.MedicalStores.FirstOrDefaultAsync(ms => ms.MedicalStoreId == id);
            return medicalStore != null ? _mapper.Map<MedicalStoreDto>(medicalStore) : null;
        }

        public async Task<MedicalStoreDto?> GetMedicalStoreByEmailAsync(string email)
        {
            var medicalStore = await _unitOfWork.MedicalStores.FirstOrDefaultAsync(ms => ms.EmailId == email);
            return medicalStore != null ? _mapper.Map<MedicalStoreDto>(medicalStore) : null;
        }

        public async Task<List<MedicalStoreDto>> GetAllMedicalStoresAsync()
        {
            var medicalStores = await _unitOfWork.MedicalStores.GetAllAsync();
            return _mapper.Map<List<MedicalStoreDto>>(medicalStores);
        }

        public async Task<MedicalStoreDto?> UpdateMedicalStoreAsync(Guid id, MedicalStoreRegistrationDto updateDto)
        {
            var medicalStore = await _unitOfWork.MedicalStores.FirstOrDefaultAsync(ms => ms.MedicalStoreId == id);
            if (medicalStore == null)
                return null;

            medicalStore.MedicalName = updateDto.MedicalName;
            medicalStore.OwnerFirstName = updateDto.OwnerFirstName;
            medicalStore.OwnerLastName = updateDto.OwnerLastName;
            medicalStore.OwnerMiddleName = updateDto.OwnerMiddleName;
            medicalStore.AddressLine1 = updateDto.AddressLine1;
            medicalStore.AddressLine2 = updateDto.AddressLine2;
            medicalStore.City = updateDto.City;
            medicalStore.State = updateDto.State;
            medicalStore.PostalCode = updateDto.PostalCode;
            medicalStore.Latitude = updateDto.Latitude;
            medicalStore.Longitude = updateDto.Longitude;
            medicalStore.MobileNumber = updateDto.MobileNumber;
            medicalStore.AlternativeMobileNumber = updateDto.AlternativeMobileNumber;
            medicalStore.RegistrationStatus = updateDto.RegistrationStatus;
            medicalStore.GSTIN = updateDto.GSTIN;
            medicalStore.PAN = updateDto.PAN;
            medicalStore.FSSAINo = updateDto.FSSAINo;
            medicalStore.DLNo = updateDto.DLNo;
            medicalStore.PharmacistFirstName = updateDto.PharmacistFirstName;
            medicalStore.PharmacistLastName = updateDto.PharmacistLastName;
            medicalStore.PharmacistRegistrationNumber = updateDto.PharmacistRegistrationNumber;
            medicalStore.PharmacistMobileNumber = updateDto.PharmacistMobileNumber;
            medicalStore.UpdatedOn = DateTime.UtcNow;

            await _unitOfWork.SaveChangesAsync();
            return _mapper.Map<MedicalStoreDto>(medicalStore);
        }

        public async Task<bool> DeleteMedicalStoreAsync(Guid id)
        {
            var medicalStore = await _unitOfWork.MedicalStores.FirstOrDefaultAsync(ms => ms.MedicalStoreId == id);
            if (medicalStore == null)
                return false;

            medicalStore.IsActive = false;
            medicalStore.IsDeleted = true;
            medicalStore.UpdatedOn = DateTime.UtcNow;

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
