using AutoMapper;
using MediatR;
using Microsoft.AspNetCore.Identity;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Domain.Interfaces;

namespace MedicineDelivery.Application.Features.Users.Queries.GetUsers
{
    public class GetUsersQueryHandler : IRequestHandler<GetUsersQuery, List<UserDto>>
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IMapper _mapper;
        private readonly IUnitOfWork _unitOfWork;

        public GetUsersQueryHandler(UserManager<ApplicationUser> userManager, IMapper mapper, IUnitOfWork unitOfWork)
        {
            _userManager = userManager;
            _mapper = mapper;
            _unitOfWork = unitOfWork;
        }

        public async Task<List<UserDto>> Handle(GetUsersQuery request, CancellationToken cancellationToken)
        {
            var users = _userManager.Users.ToList();
            var userDtos = new List<UserDto>();

            foreach (var user in users)
            {
                // Get user roles
                var roles = await _userManager.GetRolesAsync(user);
                var roleName = roles.FirstOrDefault() ?? string.Empty;

                // Try to get MiddleName and DateOfBirth from related entities
                string? middleName = null;
                DateTime? dateOfBirth = null;
                string? mobileNumber = user.PhoneNumber;

                // Check Customer entity
                var customer = await _unitOfWork.Customers.FirstOrDefaultAsync(c => c.UserId == user.Id);
                if (customer != null)
                {
                    middleName = customer.CustomerMiddleName;
                    dateOfBirth = customer.DateOfBirth;
                    if (string.IsNullOrEmpty(mobileNumber))
                    {
                        mobileNumber = customer.MobileNumber;
                    }
                }
                else
                {
                    // Check MedicalStore entity
                    var medicalStore = await _unitOfWork.MedicalStores.FirstOrDefaultAsync(ms => ms.UserId == user.Id);
                    if (medicalStore != null)
                    {
                        middleName = medicalStore.OwnerMiddleName;
                        if (string.IsNullOrEmpty(mobileNumber))
                        {
                            mobileNumber = medicalStore.MobileNumber;
                        }
                    }
                    else
                    {
                        // Check CustomerSupport entity
                        var customerSupport = await _unitOfWork.CustomerSupports.FirstOrDefaultAsync(cs => cs.UserId == user.Id);
                        if (customerSupport != null)
                        {
                            middleName = customerSupport.CustomerSupportMiddleName;
                            if (string.IsNullOrEmpty(mobileNumber))
                            {
                                mobileNumber = customerSupport.MobileNumber;
                            }
                        }
                        else
                        {
                            // Check Manager entity
                            var manager = await _unitOfWork.Managers.FirstOrDefaultAsync(m => m.UserId == user.Id);
                            if (manager != null)
                            {
                                middleName = manager.ManagerMiddleName;
                                if (string.IsNullOrEmpty(mobileNumber))
                                {
                                    mobileNumber = manager.MobileNumber;
                                }
                            }
                        }
                    }
                }

                var userDto = new UserDto
                {
                    Id = user.Id,
                    Email = user.Email ?? string.Empty,
                    FirstName = user.FirstName ?? string.Empty,
                    LastName = user.LastName ?? string.Empty,
                    MiddleName = middleName,
                    MobileNumber = mobileNumber,
                    DateOfBirth = dateOfBirth,
                    RoleName = roleName,
                    IsActive = user.IsActive,
                    CreatedAt = user.CreatedAt,
                    LastLoginAt = user.LastLoginAt
                };

                userDtos.Add(userDto);
            }

            return userDtos;
        }
    }
}
