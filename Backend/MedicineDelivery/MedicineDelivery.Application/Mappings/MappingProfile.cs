using AutoMapper;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Domain.Entities;

namespace MedicineDelivery.Application.Mappings
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            // User mappings
            CreateMap<User, UserDto>();
            CreateMap<CreateUserDto, User>();
            CreateMap<UpdateUserDto, User>();

            // Permission mappings
            CreateMap<Permission, PermissionDto>();

            // Product mappings
            CreateMap<Product, ProductDto>();
            CreateMap<CreateProductDto, Product>();
            CreateMap<UpdateProductDto, Product>();

            // Order mappings
            CreateMap<Order, OrderDto>();
            CreateMap<OrderItem, OrderItemDto>();
            CreateMap<CreateOrderDto, Order>();
            CreateMap<CreateOrderItemDto, OrderItem>();
            CreateMap<UpdateOrderDto, Order>();

            // MedicalStore mappings
            CreateMap<MedicalStore, MedicalStoreDto>();
            CreateMap<MedicalStoreRegistrationDto, MedicalStore>();

            // CustomerSupport mappings
            CreateMap<CustomerSupport, CustomerSupportDto>();
            CreateMap<CustomerSupportRegistrationDto, CustomerSupport>();

            // Manager mappings
            CreateMap<Manager, ManagerDto>();
            CreateMap<ManagerRegistrationDto, Manager>();

            // Customer mappings
            CreateMap<Customer, CustomerDto>()
                .ForMember(dest => dest.Addresses, opt => opt.Ignore()); // Addresses will be loaded separately
            CreateMap<CreateCustomerDto, Customer>();
            CreateMap<UpdateCustomerDto, Customer>();

            // CustomerAddress mappings
            CreateMap<CustomerAddress, CustomerAddressDto>();
            CreateMap<CreateCustomerAddressDto, CustomerAddress>();
            CreateMap<UpdateCustomerAddressDto, CustomerAddress>();
        }
    }
}
