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
        private readonly ICustomerAddressService _customerAddressService;

        public CustomerService(
            UserManager<ApplicationUser> userManager,
            IUnitOfWork unitOfWork,
            IMapper mapper,
            ICustomerAddressService customerAddressService)
        {
            _userManager = userManager;
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _customerAddressService = customerAddressService;
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
                    DateOfBirth = DateTime.Parse(registrationDto.DateOfBirth.ToString()).ToUniversalTime(),
                    Gender = registrationDto.Gender,
                    UserId = identityUser.Id,
                    CreatedOn = DateTime.UtcNow,
                    IsActive = true
                };

                await _unitOfWork.Customers.AddAsync(customer);
                await _unitOfWork.SaveChangesAsync();

                // Create addresses if provided
                if (registrationDto.Addresses != null && registrationDto.Addresses.Any())
                {
                    foreach (var addressDto in registrationDto.Addresses)
                    {
                        var createAddressDto = new CreateCustomerAddressDto
                        {
                            CustomerId = customer.CustomerId,
                            Address = addressDto.Address,
                            City = addressDto.City,
                            State = addressDto.State,
                            PostalCode = addressDto.PostalCode,
                            IsDefault = addressDto.IsDefault
                        };
                        await _customerAddressService.CreateCustomerAddressAsync(createAddressDto);
                    }
                }

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
                    DateOfBirth = customer.DateOfBirth,
                    Gender = customer.Gender,
                    CustomerPhoto = customer.CustomerPhoto,
                    IsActive = customer.IsActive,
                    CreatedOn = customer.CreatedOn,
                    UpdatedOn = customer.UpdatedOn,
                    UserId = customer.UserId,
                    Addresses = await _customerAddressService.GetCustomerAddressesByCustomerIdAsync(customer.CustomerId)
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
            if (customer == null) return null;

            var customerDto = _mapper.Map<CustomerDto>(customer);
            customerDto.Addresses = await _customerAddressService.GetCustomerAddressesByCustomerIdAsync(id);
            return customerDto;
        }

        public async Task<CustomerDto?> GetCustomerByMobileNumberAsync(string mobileNumber)
        {
            var customer = await _unitOfWork.Customers.FirstOrDefaultAsync(c => c.MobileNumber == mobileNumber);
            if (customer == null) return null;

            var customerDto = _mapper.Map<CustomerDto>(customer);
            customerDto.Addresses = await _customerAddressService.GetCustomerAddressesByCustomerIdAsync(customer.CustomerId);
            return customerDto;
        }

        public async Task<CustomerDto?> GetCustomerByUserIdAsync(string userId)
        {
            var customer = await _unitOfWork.Customers.FirstOrDefaultAsync(c => c.UserId == userId);
            if (customer == null) return null;

            var customerDto = _mapper.Map<CustomerDto>(customer);
            customerDto.Addresses = await _customerAddressService.GetCustomerAddressesByCustomerIdAsync(customer.CustomerId);
            return customerDto;
        }

        public async Task<List<CustomerDto>> GetAllCustomersAsync()
        {
            var customers = await _unitOfWork.Customers.GetAllAsync();
            var customerDtos = _mapper.Map<List<CustomerDto>>(customers);
            
            // Load addresses for each customer
            foreach (var customerDto in customerDtos)
            {
                customerDto.Addresses = await _customerAddressService.GetCustomerAddressesByCustomerIdAsync(customerDto.CustomerId);
            }
            
            return customerDtos;
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
            customer.DateOfBirth = DateTime.Parse(updateDto.DateOfBirth.ToString()).ToUniversalTime();
            customer.Gender = updateDto.Gender;
            customer.CustomerPhoto = updateDto.CustomerPhoto;
            customer.IsActive = updateDto.IsActive;
            customer.UpdatedOn = DateTime.UtcNow;

            await _unitOfWork.SaveChangesAsync();

            // Handle address updates if provided
            if (updateDto.Addresses != null && updateDto.Addresses.Any())
            {
                // For simplicity, we'll delete existing addresses and create new ones
                // In a real scenario, you might want more sophisticated update logic
                var existingAddresses = await _customerAddressService.GetCustomerAddressesByCustomerIdAsync(id);
                foreach (var existingAddress in existingAddresses)
                {
                    await _customerAddressService.DeleteCustomerAddressAsync(existingAddress.Id);
                }

                // Create new addresses
                foreach (var addressDto in updateDto.Addresses)
                {
                    var createAddressDto = new CreateCustomerAddressDto
                    {
                        CustomerId = id,
                        Address = addressDto.Address,
                        City = addressDto.City,
                        State = addressDto.State,
                        PostalCode = addressDto.PostalCode,
                        IsDefault = addressDto.IsDefault
                    };
                    await _customerAddressService.CreateCustomerAddressAsync(createAddressDto);
                }
            }

            var customerDto = _mapper.Map<CustomerDto>(customer);
            customerDto.Addresses = await _customerAddressService.GetCustomerAddressesByCustomerIdAsync(id);
            return customerDto;
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
