using Microsoft.AspNetCore.Identity;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Domain.Interfaces;
using MedicineDelivery.Infrastructure.Data;
using AutoMapper;

namespace MedicineDelivery.Infrastructure.Services
{
    public class CustomerSupportService : ICustomerSupportService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public CustomerSupportService(
            UserManager<ApplicationUser> userManager,
            IUnitOfWork unitOfWork,
            IMapper mapper)
        {
            _userManager = userManager;
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        public async Task<CustomerSupportRegistrationResult> RegisterCustomerSupportAsync(CustomerSupportRegistrationDto registrationDto)
        {
            try
            {
                // Check if customer support with this email already exists
                var existingCustomerSupport = await _unitOfWork.CustomerSupports.FirstOrDefaultAsync(cs => cs.EmailId == registrationDto.EmailId);
                if (existingCustomerSupport != null)
                {
                    return new CustomerSupportRegistrationResult
                    {
                        Success = false,
                        Errors = new List<string> { "Customer support with this email already exists" }
                    };
                }

                // Check if user with this mobile number already exists
                var existingUser = await _userManager.FindByNameAsync(registrationDto.MobileNumber);
                if (existingUser != null)
                {
                    return new CustomerSupportRegistrationResult
                    {
                        Success = false,
                        Errors = new List<string> { "User with this mobile number already exists" }
                    };
                }

                // Validate ServiceRegionId if provided
                if (registrationDto.ServiceRegionId.HasValue)
                {
                    var region = await _unitOfWork.ServiceRegions.GetByIdAsync(registrationDto.ServiceRegionId.Value);
                    if (region == null)
                    {
                        return new CustomerSupportRegistrationResult
                        {
                            Success = false,
                            Errors = new List<string> { $"Service region with ID '{registrationDto.ServiceRegionId.Value}' not found." }
                        };
                    }
                }

                // Begin transaction to ensure atomicity
                await _unitOfWork.BeginTransactionAsync();
                
                ApplicationUser? identityUser = null;
                try
                {
                    // Generate random password
                    var generatedPassword = GenerateRandomPassword();

                    // Create Identity user
                    identityUser = new ApplicationUser
                    {
                        UserName = registrationDto.MobileNumber,
                        Email = registrationDto.EmailId,
                        PhoneNumber = registrationDto.MobileNumber,
                        FirstName = registrationDto.CustomerSupportFirstName,
                        LastName = registrationDto.CustomerSupportLastName,
                        EmailConfirmed = true
                    };

                    var userResult = await _userManager.CreateAsync(identityUser, generatedPassword);
                    if (!userResult.Succeeded)
                    {
                        await _unitOfWork.RollbackTransactionAsync();
                        return new CustomerSupportRegistrationResult
                        {
                            Success = false,
                            Errors = userResult.Errors.Select(e => e.Description).ToList()
                        };
                    }

                    // Add to CustomerSupport Identity role
                    await _userManager.AddToRoleAsync(identityUser, "CustomerSupport");

                    // Create customer support
                    var customerSupport = new CustomerSupport
                    {
                        CustomerSupportId = Guid.NewGuid(),
                        CustomerSupportFirstName = registrationDto.CustomerSupportFirstName,
                        CustomerSupportLastName = registrationDto.CustomerSupportLastName,
                        CustomerSupportMiddleName = registrationDto.CustomerSupportMiddleName,
                        Address = registrationDto.Address,
                        City = registrationDto.City,
                        State = registrationDto.State,
                        MobileNumber = registrationDto.MobileNumber,
                        EmailId = registrationDto.EmailId,
                        AlternativeMobileNumber = registrationDto.AlternativeMobileNumber,
                        EmployeeId = registrationDto.EmployeeId,
                        UserId = identityUser.Id,
                        ServiceRegionId = registrationDto.ServiceRegionId,
                        CreatedOn = DateTime.UtcNow,
                        IsActive = true,
                        IsDeleted = false
                    };

                    await _unitOfWork.CustomerSupports.AddAsync(customerSupport);
                    await _unitOfWork.SaveChangesAsync();
                    await _unitOfWork.CommitTransactionAsync();

                    // Create response
                    var response = new CustomerSupportResponseDto
                    {
                        CustomerSupportId = customerSupport.CustomerSupportId,
                        CustomerSupportFirstName = customerSupport.CustomerSupportFirstName,
                        CustomerSupportLastName = customerSupport.CustomerSupportLastName,
                        CustomerSupportMiddleName = customerSupport.CustomerSupportMiddleName,
                        Address = customerSupport.Address,
                        City = customerSupport.City,
                        State = customerSupport.State,
                        MobileNumber = customerSupport.MobileNumber,
                        EmailId = customerSupport.EmailId,
                        AlternativeMobileNumber = customerSupport.AlternativeMobileNumber,
                        EmployeeId = customerSupport.EmployeeId,
                        IsActive = customerSupport.IsActive,
                        IsDeleted = customerSupport.IsDeleted,
                        CreatedOn = customerSupport.CreatedOn,
                        CreatedBy = customerSupport.CreatedBy,
                        UpdatedOn = customerSupport.UpdatedOn,
                        UpdatedBy = customerSupport.UpdatedBy,
                        UserId = customerSupport.UserId,
                        ServiceRegionId = customerSupport.ServiceRegionId,
                        Password = generatedPassword
                    };

                    return new CustomerSupportRegistrationResult
                    {
                        Success = true,
                        CustomerSupport = response
                    };
                }
                catch (Exception)
                {
                    // Rollback the transaction
                    await _unitOfWork.RollbackTransactionAsync();
                    
                    // Clean up the Identity user if it was created
                    if (identityUser != null)
                    {
                        try
                        {
                            await _userManager.DeleteAsync(identityUser);
                        }
                        catch (Exception ex)
                        {
                            // Log the cleanup failure but don't throw - the main transaction is already rolled back
                            // This could be logged to a proper logging system
                            Console.WriteLine($"Failed to cleanup Identity user {identityUser.Id}: {ex.Message}");
                        }
                    }
                    
                    throw; // Re-throw the original exception
                }
            }
            catch (Exception ex)
            {
                return new CustomerSupportRegistrationResult
                {
                    Success = false,
                    Errors = new List<string> { $"An error occurred: {ex.Message}" }
                };
            }
        }

        public async Task<CustomerSupportDto?> GetCustomerSupportByIdAsync(Guid id)
        {
            var customerSupport = await _unitOfWork.CustomerSupports.FirstOrDefaultAsync(cs => cs.CustomerSupportId == id);
            return customerSupport != null ? _mapper.Map<CustomerSupportDto>(customerSupport) : null;
        }

        public async Task<CustomerSupportDto?> GetCustomerSupportByEmailAsync(string email)
        {
            var customerSupport = await _unitOfWork.CustomerSupports.FirstOrDefaultAsync(cs => cs.EmailId == email);
            return customerSupport != null ? _mapper.Map<CustomerSupportDto>(customerSupport) : null;
        }

        public async Task<List<CustomerSupportDto>> GetAllCustomerSupportsAsync()
        {
            var customerSupports = await _unitOfWork.CustomerSupports.GetAllAsync();
            return _mapper.Map<List<CustomerSupportDto>>(customerSupports);
        }

        public async Task<CustomerSupportDto?> UpdateCustomerSupportAsync(Guid id, CustomerSupportRegistrationDto updateDto)
        {
            var customerSupport = await _unitOfWork.CustomerSupports.FirstOrDefaultAsync(cs => cs.CustomerSupportId == id);
            if (customerSupport == null)
                return null;

            // Validate ServiceRegionId if provided
            if (updateDto.ServiceRegionId.HasValue)
            {
                var region = await _unitOfWork.ServiceRegions.GetByIdAsync(updateDto.ServiceRegionId.Value);
                if (region == null)
                {
                    throw new KeyNotFoundException($"Service region with ID '{updateDto.ServiceRegionId.Value}' not found.");
                }
            }

            customerSupport.CustomerSupportFirstName = updateDto.CustomerSupportFirstName;
            customerSupport.CustomerSupportLastName = updateDto.CustomerSupportLastName;
            customerSupport.CustomerSupportMiddleName = updateDto.CustomerSupportMiddleName;
            customerSupport.Address = updateDto.Address;
            customerSupport.City = updateDto.City;
            customerSupport.State = updateDto.State;
            customerSupport.MobileNumber = updateDto.MobileNumber;
            customerSupport.AlternativeMobileNumber = updateDto.AlternativeMobileNumber;
            customerSupport.EmployeeId = updateDto.EmployeeId;
            customerSupport.ServiceRegionId = updateDto.ServiceRegionId;
            customerSupport.UpdatedOn = DateTime.UtcNow;

            _unitOfWork.CustomerSupports.Update(customerSupport);
            await _unitOfWork.SaveChangesAsync();
            return _mapper.Map<CustomerSupportDto>(customerSupport);
        }

        public async Task<bool> DeleteCustomerSupportAsync(Guid id)
        {
            var customerSupport = await _unitOfWork.CustomerSupports.FirstOrDefaultAsync(cs => cs.CustomerSupportId == id);
            if (customerSupport == null)
                return false;

            customerSupport.IsActive = false;
            customerSupport.IsDeleted = true;
            customerSupport.UpdatedOn = DateTime.UtcNow;

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
            
            //return new string(password.ToArray());
            return "Password@123";
        }
    }
}
