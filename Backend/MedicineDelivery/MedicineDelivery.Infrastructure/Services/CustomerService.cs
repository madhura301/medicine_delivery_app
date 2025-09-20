using Microsoft.AspNetCore.Identity;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Domain.Interfaces;
using MedicineDelivery.Infrastructure.Data;
using AutoMapper;

namespace MedicineDelivery.Infrastructure.Services
{
    public class CustomerService : ICustomerService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public CustomerService(
            UserManager<ApplicationUser> userManager,
            IUnitOfWork unitOfWork,
            IMapper mapper)
        {
            _userManager = userManager;
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        public async Task<CustomerRegistrationResult> RegisterCustomerAsync(CustomerRegistrationDto registrationDto)
        {
            try
            {
                // Check if customer with this mobile number already exists
                var existingCustomer = await _unitOfWork.Customers.FirstOrDefaultAsync(c => c.MobileNumber == registrationDto.MobileNumber);
                if (existingCustomer != null)
                {
                    return new CustomerRegistrationResult
                    {
                        Success = false,
                        Errors = new List<string> { "Customer with this mobile number already exists" }
                    };
                }

                // Check if user with this mobile number already exists (using mobile as username)
                var existingUser = await _userManager.FindByNameAsync(registrationDto.MobileNumber);
                if (existingUser != null)
                {
                    return new CustomerRegistrationResult
                    {
                        Success = false,
                        Errors = new List<string> { "User with this mobile number already exists" }
                    };
                }

                // Create Identity user using mobile number as username
                var identityUser = new ApplicationUser
                {
                    UserName = registrationDto.MobileNumber,
                    Email = registrationDto.EmailId ?? $"{registrationDto.MobileNumber}@customer.local",
                    FirstName = registrationDto.CustomerFirstName,
                    LastName = registrationDto.CustomerLastName,
                    PhoneNumber = registrationDto.MobileNumber,
                    EmailConfirmed = true
                };

                var userResult = await _userManager.CreateAsync(identityUser, registrationDto.Password);
                if (!userResult.Succeeded)
                {
                    return new CustomerRegistrationResult
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

                // Assign Customer role to the user
                var customerRole = await _unitOfWork.Roles.FirstOrDefaultAsync(r => r.Name == "Customer");
                if (customerRole != null)
                {
                    var userRole = new UserRole
                    {
                        UserId = domainUser.Id,
                        RoleId = customerRole.Id,
                        AssignedAt = DateTime.UtcNow,
                        IsActive = true
                    };
                    await _unitOfWork.UserRoles.AddAsync(userRole);
                }

                // Create customer
                var customer = new Customer
                {
                    CustomerId = Guid.NewGuid(),
                    CustomerFirstName = registrationDto.CustomerFirstName,
                    CustomerLastName = registrationDto.CustomerLastName,
                    CustomerMiddleName = registrationDto.CustomerMiddleName,
                    MobileNumber = registrationDto.MobileNumber,
                    AlternativeMobileNumber = registrationDto.AlternativeMobileNumber,
                    EmailId = registrationDto.EmailId,
                    Address = registrationDto.Address,
                    City = registrationDto.City,
                    State = registrationDto.State,
                    PostalCode = registrationDto.PostalCode,
                    DateOfBirth = registrationDto.DateOfBirth,
                    Gender = registrationDto.Gender,
                    UserId = identityUser.Id,
                    CreatedOn = DateTime.UtcNow,
                    IsActive = true
                };

                await _unitOfWork.Customers.AddAsync(customer);
                await _unitOfWork.SaveChangesAsync();

                // Create response
                var response = new CustomerResponseDto
                {
                    CustomerId = customer.CustomerId,
                    CustomerFirstName = customer.CustomerFirstName,
                    CustomerLastName = customer.CustomerLastName,
                    CustomerMiddleName = customer.CustomerMiddleName,
                    MobileNumber = customer.MobileNumber,
                    AlternativeMobileNumber = customer.AlternativeMobileNumber,
                    EmailId = customer.EmailId,
                    Address = customer.Address,
                    City = customer.City,
                    State = customer.State,
                    PostalCode = customer.PostalCode,
                    DateOfBirth = customer.DateOfBirth,
                    Gender = customer.Gender,
                    CustomerPhoto = customer.CustomerPhoto,
                    IsActive = customer.IsActive,
                    CreatedOn = customer.CreatedOn,
                    UpdatedOn = customer.UpdatedOn,
                    UserId = customer.UserId
                };

                return new CustomerRegistrationResult
                {
                    Success = true,
                    Customer = response
                };
            }
            catch (Exception ex)
            {
                return new CustomerRegistrationResult
                {
                    Success = false,
                    Errors = new List<string> { $"An error occurred: {ex.Message}" }
                };
            }
        }

        public async Task<CustomerDto?> GetCustomerByIdAsync(Guid id)
        {
            var customer = await _unitOfWork.Customers.FirstOrDefaultAsync(c => c.CustomerId == id);
            return customer != null ? _mapper.Map<CustomerDto>(customer) : null;
        }

        public async Task<CustomerDto?> GetCustomerByMobileNumberAsync(string mobileNumber)
        {
            var customer = await _unitOfWork.Customers.FirstOrDefaultAsync(c => c.MobileNumber == mobileNumber);
            return customer != null ? _mapper.Map<CustomerDto>(customer) : null;
        }

        public async Task<CustomerDto?> GetCustomerByUserIdAsync(string userId)
        {
            var customer = await _unitOfWork.Customers.FirstOrDefaultAsync(c => c.UserId == userId);
            return customer != null ? _mapper.Map<CustomerDto>(customer) : null;
        }

        public async Task<List<CustomerDto>> GetAllCustomersAsync()
        {
            var customers = await _unitOfWork.Customers.GetAllAsync();
            return _mapper.Map<List<CustomerDto>>(customers);
        }

        public async Task<CustomerDto?> UpdateCustomerAsync(Guid id, UpdateCustomerDto updateDto)
        {
            var customer = await _unitOfWork.Customers.FirstOrDefaultAsync(c => c.CustomerId == id);
            if (customer == null)
                return null;

            customer.CustomerFirstName = updateDto.CustomerFirstName;
            customer.CustomerLastName = updateDto.CustomerLastName;
            customer.CustomerMiddleName = updateDto.CustomerMiddleName;
            customer.MobileNumber = updateDto.MobileNumber;
            customer.AlternativeMobileNumber = updateDto.AlternativeMobileNumber;
            customer.EmailId = updateDto.EmailId;
            customer.Address = updateDto.Address;
            customer.City = updateDto.City;
            customer.State = updateDto.State;
            customer.PostalCode = updateDto.PostalCode;
            customer.DateOfBirth = updateDto.DateOfBirth;
            customer.Gender = updateDto.Gender;
            customer.CustomerPhoto = updateDto.CustomerPhoto;
            customer.IsActive = updateDto.IsActive;
            customer.UpdatedOn = DateTime.UtcNow;

            await _unitOfWork.SaveChangesAsync();
            return _mapper.Map<CustomerDto>(customer);
        }

        public async Task<bool> DeleteCustomerAsync(Guid id)
        {
            var customer = await _unitOfWork.Customers.FirstOrDefaultAsync(c => c.CustomerId == id);
            if (customer == null)
                return false;

            customer.IsActive = false;
            customer.UpdatedOn = DateTime.UtcNow;

            await _unitOfWork.SaveChangesAsync();
            return true;
        }
    }
}
