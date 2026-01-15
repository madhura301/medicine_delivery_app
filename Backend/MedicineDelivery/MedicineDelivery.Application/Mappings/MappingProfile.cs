using AutoMapper;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Domain.Entities;

namespace MedicineDelivery.Application.Mappings
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            // User mappings removed - using ApplicationUser directly

            // Permission mappings
            CreateMap<Permission, PermissionDto>();

            // Product mappings
            CreateMap<Product, ProductDto>();
            CreateMap<CreateProductDto, Product>();
            CreateMap<UpdateProductDto, Product>();

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

            // Order mappings
            CreateMap<Order, OrderDto>()
                .ForMember(dest => dest.AssignmentHistory, opt => opt.Ignore()); // Will be mapped manually
            CreateMap<OrderAssignmentHistory, OrderAssignmentHistoryDto>();
            CreateMap<OrderAssignmentHistory, OrderAssignmentHistoryExtendedDto>()
                .IncludeBase<OrderAssignmentHistory, OrderAssignmentHistoryDto>();
            CreateMap<Payment, PaymentDto>();
            CreateMap<CreateOrderDto, Order>();

            // Delivery mappings
            CreateMap<Delivery, DeliveryDto>();

            // CustomerSupportRegion mappings
            CreateMap<CustomerSupportRegion, CustomerSupportRegionDto>()
                .ForMember(dest => dest.PinCodes, opt => opt.Ignore()); // PinCodes loaded separately

            // Consent mappings
            CreateMap<Consent, ConsentDto>();
            CreateMap<CreateConsentDto, Consent>();
            CreateMap<UpdateConsentDto, Consent>();

            // ConsentLog mappings
            CreateMap<ConsentLog, ConsentLogDto>()
                .ForMember(dest => dest.Consent, opt => opt.Ignore()); // Consent loaded separately
        }
    }
}
