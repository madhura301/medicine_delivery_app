using AutoMapper;
using MedicineDelivery.Application.DTOs;
using MedicineDelivery.Application.Interfaces;
using MedicineDelivery.Domain.Entities;
using MedicineDelivery.Domain.Enums;
using MedicineDelivery.Domain.Exceptions;
using MedicineDelivery.Domain.Interfaces;
using MedicineDelivery.Infrastructure.Data;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Hosting;
using NetTopologySuite;
using NetTopologySuite.Geometries;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace MedicineDelivery.Infrastructure.Services
{
    public class OrderService : IOrderService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly IHostEnvironment _hostEnvironment;
        private readonly ApplicationDbContext _context;
        private static readonly string[] AllowedImageExtensions = { ".jpg", ".jpeg", ".png", ".gif", ".bmp" };
        private static readonly string[] AllowedVoiceExtensions = { ".mp3", ".wav", ".m4a", ".aac", ".ogg" };
        private static readonly string[] AllowedPdfExtensions = { ".pdf" };

        public OrderService(IUnitOfWork unitOfWork, IMapper mapper, IHostEnvironment hostEnvironment, ApplicationDbContext context)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _hostEnvironment = hostEnvironment;
            _context = context;
        }

        public async Task<OrderDto> CreateOrderAsync(CreateOrderDto createDto, CancellationToken cancellationToken = default)
        {
            ArgumentNullException.ThrowIfNull(createDto);

            cancellationToken.ThrowIfCancellationRequested();

            if (createDto.CustomerId == Guid.Empty)
            {
                throw new ArgumentException("CustomerId is required.", nameof(createDto.CustomerId));
            }

            if (createDto.CustomerAddressId == Guid.Empty)
            {
                throw new ArgumentException("CustomerAddressId is required.", nameof(createDto.CustomerAddressId));
            }

            if (!Enum.IsDefined(typeof(OrderType), createDto.OrderType))
            {
                throw new ArgumentException("Invalid order type provided.", nameof(createDto.OrderType));
            }

            if (!Enum.IsDefined(typeof(OrderInputType), createDto.OrderInputType))
            {
                throw new ArgumentException("Invalid order input type provided.", nameof(createDto.OrderInputType));
            }

            // Ensure the customer exists and is active
            var customer = await _unitOfWork.Customers.FirstOrDefaultAsync(c => c.CustomerId == createDto.CustomerId && c.IsActive);
            if (customer == null)
            {
                throw new KeyNotFoundException("Customer not found or inactive.");
            }

            // Ensure the address exists for the customer
            var address = await _unitOfWork.CustomerAddresses.FirstOrDefaultAsync(ca =>
                ca.Id == createDto.CustomerAddressId &&
                ca.CustomerId == createDto.CustomerId &&
                ca.IsActive);

            if (address == null)
            {
                throw new KeyNotFoundException("Customer address not found or inactive.");
            }

            // Validate input data based on the order input type
            switch (createDto.OrderInputType)
            {
                case OrderInputType.Text when string.IsNullOrWhiteSpace(createDto.OrderInputText):
                    throw new ArgumentException("Order input text is required when order input type is text.", nameof(createDto.OrderInputText));
                case OrderInputType.Image when createDto.OrderInputFile == null || createDto.OrderInputFile.Length == 0:
                    throw new ArgumentException("An image file is required when order input type is image.", nameof(createDto.OrderInputFile));
                case OrderInputType.Voice when createDto.OrderInputFile == null || createDto.OrderInputFile.Length == 0:
                    throw new ArgumentException("A voice file is required when order input type is voice.", nameof(createDto.OrderInputFile));
            }

            var order = new Order
            {
                CustomerId = createDto.CustomerId,
                CustomerAddressId = createDto.CustomerAddressId,
                OrderType = createDto.OrderType,
                OrderInputType = createDto.OrderInputType,
                AssignTo = AssignTo.Customer,
                OrderInputText = createDto.OrderInputType == OrderInputType.Text
                    ? string.IsNullOrWhiteSpace(createDto.OrderInputText) ? null : createDto.OrderInputText.Trim()
                    : null,
                AssignedByType = AssignedByType.System,
                OrderStatus = OrderStatus.PendingPayment,
                OrderNumber = GenerateOrderNumber(),
                OTP = GenerateOTP(),
                CreatedOn = DateTime.UtcNow,
                UpdatedOn = null
            };

            if (createDto.OrderInputType is OrderInputType.Image or OrderInputType.Voice)
            {
                if (createDto.OrderInputFile == null || createDto.OrderInputFile.Length == 0)
                {
                    throw new ArgumentException("An order input file is required for image or voice orders.", nameof(createDto.OrderInputFile));
                }

                ValidateOrderInputFile(createDto.OrderInputType, createDto.OrderInputFile);
                order.OrderInputFileLocation = await SaveOrderInputFileAsync(createDto.OrderInputFile, createDto.OrderInputType, cancellationToken);
            }
            else
            {
                order.OrderInputFileLocation = null;
            }

           

            await _unitOfWork.Orders.AddAsync(order);
            await _unitOfWork.SaveChangesAsync();

            // Create initial assignment history entry
            var assignmentHistory = new OrderAssignmentHistory
            {
                OrderId = order.OrderId,
                CustomerId = order.CustomerId,
                MedicalStoreId = null, // No medical store assigned initially
                AssignedByType = AssignedByType.System,
                AssignTo = AssignTo.Customer, // Order is initially assigned to Customer
                AssignedOn = DateTime.UtcNow,
                Status = AssignmentStatus.Assigned
            };

            await _unitOfWork.OrderAssignmentHistories.AddAsync(assignmentHistory);
            await _unitOfWork.SaveChangesAsync();

            await AssignOrderToNearestChemist(order.OrderId);

            return _mapper.Map<OrderDto>(order);
        }

        public async Task AssignOrderToNearestChemist(int orderId)
        {
            // Find the order by OrderId
            var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId);
            if (order == null)
            {
                throw new KeyNotFoundException($"Order with OrderId '{orderId}' not found.");
            }

            // Get the customer address for this order
            var address = await _unitOfWork.CustomerAddresses.FirstOrDefaultAsync(ca =>
                ca.Id == order.CustomerAddressId &&
                ca.CustomerId == order.CustomerId &&
                ca.IsActive);

            if (address == null)
            {
                throw new KeyNotFoundException("Customer address not found or inactive for this order.");
            }

            // Find nearest active medical store using NetTopologySuite if customer address has coordinates
            if (address.Latitude.HasValue && address.Longitude.HasValue)
            {
                var geometryFactory = NtsGeometryServices.Instance.CreateGeometryFactory(srid: 4326);
                var customerPoint = geometryFactory.CreatePoint(new Coordinate(
                    x: (double)address.Longitude.Value, // longitude = X
                    y: (double)address.Latitude.Value   // latitude  = Y
                ));

                var medicalStores = await _unitOfWork.MedicalStores.FindAsync(ms =>
                    ms.IsActive &&
                    !ms.IsDeleted &&
                    ms.Latitude.HasValue &&
                    ms.Longitude.HasValue);

                var nearestStore = medicalStores
                    .Select(ms => new
                    {
                        Store = ms,
                        Point = geometryFactory.CreatePoint(new Coordinate(
                            x: (double)ms.Longitude!.Value,
                            y: (double)ms.Latitude!.Value))
                    })
                    .OrderBy(x => x.Point.Distance(customerPoint))
                    .FirstOrDefault()
                    ?.Store;

                if (nearestStore != null)
                {
                    // Update order assignment
                    order.MedicalStoreId = nearestStore.MedicalStoreId;
                    order.AssignTo = AssignTo.Chemist;
                    order.AssignedByType = AssignedByType.System;
                    order.OrderStatus = OrderStatus.AssignedToChemist;
                    order.UpdatedOn = DateTime.UtcNow;

                    // Create assignment history entry
                    var assignmentHistory = new OrderAssignmentHistory
                    {
                        OrderId = order.OrderId,
                        CustomerId = order.CustomerId,
                        MedicalStoreId = nearestStore.MedicalStoreId,
                        AssignedByType = AssignedByType.System,
                        AssignTo = AssignTo.Chemist,
                        AssignedOn = DateTime.UtcNow,
                        Status = AssignmentStatus.Assigned
                    };

                    _unitOfWork.Orders.Update(order);
                    await _unitOfWork.OrderAssignmentHistories.AddAsync(assignmentHistory);
                    await _unitOfWork.SaveChangesAsync();
                }
                else
                {
                    throw new InvalidOperationException("No active medical store with coordinates found to assign the order.");
                }
            }
            else
            {
                throw new InvalidOperationException("Customer address does not have coordinates (latitude/longitude) required for finding nearest chemist.");
            }
        }

        public async Task<OrderDto?> GetOrderByIdAsync(int orderId, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            var order = await _context.Orders
                .Include(o => o.AssignmentHistory)
                    .ThenInclude(ah => ah.Customer)
                .Include(o => o.AssignmentHistory)
                    .ThenInclude(ah => ah.MedicalStore)
                .Include(o => o.AssignmentHistory)
                    .ThenInclude(ah => ah.CustomerSupport)
                .Include(o => o.Payments)
                .Include(o => o.CustomerSupport)
                .FirstOrDefaultAsync(o => o.OrderId == orderId, cancellationToken);
            
            if (order == null)
            {
                return null;
            }

            // Load all Deliveries referenced in assignment history
            var deliveryIds = order.AssignmentHistory?
                .Where(ah => ah.DeliveryId.HasValue)
                .Select(ah => ah.DeliveryId!.Value)
                .Distinct()
                .ToList() ?? new List<int>();

            var deliveries = deliveryIds.Any()
                ? await _context.Deliveries
                    .Where(d => deliveryIds.Contains(d.Id))
                    .ToListAsync(cancellationToken)
                : new List<Delivery>();

            var deliveriesDict = deliveries.ToDictionary(d => d.Id, d => d);

            var orderDto = _mapper.Map<OrderDto>(order);
            
            // Map assignment history to extended DTO with AssigneeName
            if (order.AssignmentHistory != null && orderDto != null)
            {
                var extendedHistory = new List<OrderAssignmentHistoryExtendedDto>();
                
                foreach (var history in order.AssignmentHistory)
                {
                    var extended = _mapper.Map<OrderAssignmentHistoryExtendedDto>(history);
                    extended.AssignTo = history.AssignTo.ToString();
                    extended.AssignmentStatus = history.Status.ToString();
                    
                    // Populate AssigneeName based on AssignTo
                    extended.AssigneeName = history.AssignTo switch
                    {
                        AssignTo.Customer => history.Customer != null 
                            ? $"{history.Customer.CustomerFirstName} {history.Customer.CustomerLastName}".Trim()
                            : string.Empty,
                        AssignTo.Chemist => history.MedicalStore != null 
                            ? history.MedicalStore.MedicalName
                            : string.Empty,
                        AssignTo.CustomerSupport => order.CustomerSupport != null 
                            ? $"{order.CustomerSupport.CustomerSupportFirstName} {order.CustomerSupport.CustomerSupportLastName}".Trim()
                            : string.Empty,
                        AssignTo.Delivery => history.DeliveryId.HasValue && deliveriesDict.TryGetValue(history.DeliveryId.Value, out var delivery)
                            ? $"{delivery.FirstName ?? string.Empty} {delivery.LastName ?? string.Empty}".Trim()
                            : string.Empty,
                        _ => string.Empty
                    };
                    
                    extendedHistory.Add(extended);
                }
                
                orderDto.AssignmentHistory = extendedHistory;
            }
            
            return orderDto;
        }

        public async Task<IEnumerable<OrderDto>> GetOrdersByCustomerIdAsync(Guid customerId, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            if (customerId == Guid.Empty)
            {
                throw new ArgumentException("CustomerId is required.", nameof(customerId));
            }

            var orders = await _unitOfWork.Orders.FindAsync(o => o.CustomerId == customerId);
            return _mapper.Map<IEnumerable<OrderDto>>(orders);
        }

        public async Task<IEnumerable<OrderDto>> GetActiveOrdersByCustomerIdAsync(Guid customerId, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            if (customerId == Guid.Empty)
            {
                throw new ArgumentException("CustomerId is required.", nameof(customerId));
            }

            var orders = await _unitOfWork.Orders.FindAsync(o => 
                o.CustomerId == customerId && 
                o.OrderStatus != OrderStatus.Completed);
            
            return _mapper.Map<IEnumerable<OrderDto>>(orders);
        }

        public async Task<IEnumerable<OrderDto>> GetActiveOrdersByMedicalStoreIdAsync(Guid medicalStoreId, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            if (medicalStoreId == Guid.Empty)
            {
                throw new ArgumentException("MedicalStoreId is required.", nameof(medicalStoreId));
            }

            var orders = await _unitOfWork.Orders.FindAsync(o => 
                o.MedicalStoreId == medicalStoreId && 
                o.OrderStatus == OrderStatus.AssignedToChemist);
            
            return _mapper.Map<IEnumerable<OrderDto>>(orders);
        }

        public async Task<IEnumerable<OrderDto>> GetAcceptedOrdersByMedicalStoreIdAsync(Guid medicalStoreId, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            if (medicalStoreId == Guid.Empty)
            {
                throw new ArgumentException("MedicalStoreId is required.", nameof(medicalStoreId));
            }

            var orders = await _unitOfWork.Orders.FindAsync(o => 
                o.MedicalStoreId == medicalStoreId && 
                o.OrderStatus == OrderStatus.AcceptedByChemist);
            
            return _mapper.Map<IEnumerable<OrderDto>>(orders);
        }

        public async Task<IEnumerable<OrderDto>> GetRejectedOrdersByMedicalStoreIdAsync(Guid medicalStoreId, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            if (medicalStoreId == Guid.Empty)
            {
                throw new ArgumentException("MedicalStoreId is required.", nameof(medicalStoreId));
            }

            var orders = await _unitOfWork.Orders.FindAsync(o => 
                o.MedicalStoreId == medicalStoreId && 
                o.OrderStatus == OrderStatus.RejectedByChemist);
            
            return _mapper.Map<IEnumerable<OrderDto>>(orders);
        }

        public async Task<IEnumerable<OrderDto>> GetAllOrdersByMedicalStoreIdAsync(Guid medicalStoreId, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            if (medicalStoreId == Guid.Empty)
            {
                throw new ArgumentException("MedicalStoreId is required.", nameof(medicalStoreId));
            }

            var orders = await _unitOfWork.Orders.FindAsync(o => o.MedicalStoreId == medicalStoreId);
            
            return _mapper.Map<IEnumerable<OrderDto>>(orders);
        }

        public async Task<OrderDto> AcceptOrderByChemistAsync(int orderId, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId);
            if (order == null)
            {
                throw new KeyNotFoundException("Order not found.");
            }

            if (order.OrderStatus != OrderStatus.AssignedToChemist)
            {
                throw new InvalidOperationException($"Order can only be accepted when its status is {OrderStatus.AssignedToChemist}. Current status is {order.OrderStatus}.");
            }

            order.OrderStatus = OrderStatus.AcceptedByChemist;
            order.UpdatedOn = DateTime.UtcNow;

            _unitOfWork.Orders.Update(order);
            await _unitOfWork.SaveChangesAsync();

            return _mapper.Map<OrderDto>(order);
        }

        public async Task<OrderDto> RejectOrderByChemistAsync(int orderId, RejectOrderDto rejectDto, CancellationToken cancellationToken = default)
        {
            ArgumentNullException.ThrowIfNull(rejectDto);
            cancellationToken.ThrowIfCancellationRequested();

            if (string.IsNullOrWhiteSpace(rejectDto.RejectNote))
            {
                throw new ArgumentException("Reject note is required.", nameof(rejectDto.RejectNote));
            }

            var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId);
            if (order == null)
            {
                throw new KeyNotFoundException("Order not found.");
            }

            if (order.OrderStatus != OrderStatus.AssignedToChemist)
            {
                throw new InvalidOperationException($"Order can only be rejected when its status is {OrderStatus.AssignedToChemist}. Current status is {order.OrderStatus}.");
            }

            // Find the latest assignment history with Assigned status for this order
            var assignmentHistories = await _unitOfWork.OrderAssignmentHistories.FindAsync(
                ah => ah.OrderId == orderId && ah.Status == AssignmentStatus.Assigned);
            
            var latestAssignment = assignmentHistories
                .OrderByDescending(ah => ah.AssignedOn)
                .FirstOrDefault();

            if (latestAssignment == null)
            {
                throw new InvalidOperationException("No active assignment found for this order.");
            }

            // Update the assignment history
            latestAssignment.Status = AssignmentStatus.Rejected;
            latestAssignment.RejectNote = rejectDto.RejectNote.Trim();
            latestAssignment.UpdatedOn = DateTime.UtcNow;

            // Update the order status
            order.OrderStatus = OrderStatus.RejectedByChemist;
            order.UpdatedOn = DateTime.UtcNow;

            _unitOfWork.OrderAssignmentHistories.Update(latestAssignment);
            _unitOfWork.Orders.Update(order);
            await _unitOfWork.SaveChangesAsync();

            return _mapper.Map<OrderDto>(order);
        }

        public async Task AssignRejectOrderToCustomerSupport(int orderId, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            // Get the order
            var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId);
            if (order == null)
            {
                throw new KeyNotFoundException("Order not found.");
            }

            // Get the customer address to find the postal code
            var customerAddress = await _unitOfWork.CustomerAddresses.FirstOrDefaultAsync(ca => ca.Id == order.CustomerAddressId);
            if (customerAddress == null)
            {
                throw new KeyNotFoundException("Customer address not found for this order.");
            }

            if (string.IsNullOrWhiteSpace(customerAddress.PostalCode))
            {
                throw new InvalidOperationException("Customer address does not have a postal code.");
            }

            // Find the ServiceRegion by postal code (only CustomerSupport type regions)
            var regionPinCode = await _unitOfWork.ServiceRegionPinCodes.FirstOrDefaultAsync(
                rpc => rpc.PinCode == customerAddress.PostalCode.Trim());
            
            if (regionPinCode == null)
            {
                throw new KeyNotFoundException($"No service region found for postal code: {customerAddress.PostalCode}");
            }

            // Verify the region is a CustomerSupport type region
            var region = await _unitOfWork.ServiceRegions.GetByIdAsync(regionPinCode.ServiceRegionId);
            if (region == null || region.RegionType != Domain.Enums.RegionType.CustomerSupport)
            {
                throw new KeyNotFoundException($"No customer support region found for postal code: {customerAddress.PostalCode}");
            }

            // Get all CustomerSupports assigned to this region
            var customerSupports = await _unitOfWork.CustomerSupports.FindAsync(
                cs => cs.ServiceRegionId == regionPinCode.ServiceRegionId && 
                      cs.IsActive && 
                      !cs.IsDeleted);

            if (customerSupports == null || !customerSupports.Any())
            {
                throw new InvalidOperationException($"No active customer supports found for region ID: {regionPinCode.ServiceRegionId}");
            }

            // Find the CustomerSupport with the least orders in AssignedToCustomerSupport status
            var customerSupportOrderCounts = new List<(CustomerSupport CustomerSupport, int OrderCount)>();

            foreach (var customerSupport in customerSupports)
            {
                var orderCount = (await _unitOfWork.Orders.FindAsync(
                    o => o.CustomerSupportId == customerSupport.CustomerSupportId && 
                         o.OrderStatus == OrderStatus.AssignedToCustomerSupport)).Count();
                
                customerSupportOrderCounts.Add((customerSupport, orderCount));
            }

            // Get the CustomerSupport with the minimum order count
            var selectedCustomerSupport = customerSupportOrderCounts
                .OrderBy(x => x.OrderCount)
                .ThenBy(x => x.CustomerSupport.CreatedOn) // If tied, use the one created first
                .First()
                .CustomerSupport;

            // Assign the order to the selected CustomerSupport
            order.CustomerSupportId = selectedCustomerSupport.CustomerSupportId;
            order.AssignTo = AssignTo.CustomerSupport;
            order.AssignedByType = AssignedByType.System;
            order.OrderStatus = OrderStatus.AssignedToCustomerSupport;
            order.UpdatedOn = DateTime.UtcNow;

            // Create assignment history entry
            var assignmentHistory = new OrderAssignmentHistory
            {
                OrderId = order.OrderId,
                CustomerId = order.CustomerId,
                MedicalStoreId = order.MedicalStoreId,
                AssignedByType = AssignedByType.System,
                AssignTo = AssignTo.CustomerSupport,
                AssignedOn = DateTime.UtcNow,
                Status = AssignmentStatus.Assigned
            };

            _unitOfWork.Orders.Update(order);
            await _unitOfWork.OrderAssignmentHistories.AddAsync(assignmentHistory);
            await _unitOfWork.SaveChangesAsync();
        }

        public async Task<OrderDto> CompleteOrderAsync(int orderId, CompleteOrderDto completeDto, CancellationToken cancellationToken = default)
        {
            ArgumentNullException.ThrowIfNull(completeDto);
            cancellationToken.ThrowIfCancellationRequested();

            if (string.IsNullOrWhiteSpace(completeDto.OTP))
            {
                throw new ArgumentException("OTP is required.", nameof(completeDto.OTP));
            }

            var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId);
            if (order == null)
            {
                throw new KeyNotFoundException("Order not found.");
            }

            if (order.OrderStatus != OrderStatus.OutForDelivery)
            {
                throw new InvalidOperationException($"Order can only be completed when its status is {OrderStatus.OutForDelivery}. Current status is {order.OrderStatus}.");
            }

            // Check payment status before allowing completion
            if (order.OrderPaymentStatus != OrderPaymentStatus.FullyPaid)
            {
                var payments = await _unitOfWork.Payments.FindAsync(p => p.OrderId == orderId && p.PaymentStatus == PaymentStatus.Success);
                var totalPaid = payments.Sum(p => p.Amount);
                
                throw new PaymentIncompleteException(
                    orderId, 
                    order.TotalAmount ?? 0, 
                    totalPaid);
            }

            if (string.IsNullOrWhiteSpace(order.OTP))
            {
                throw new InvalidOperationException("Order does not have an OTP set.");
            }

            if (order.OTP.Trim() != completeDto.OTP.Trim())
            {
                throw new ArgumentException("Invalid OTP. The provided OTP does not match the order's OTP.");
            }

            order.AssignTo = AssignTo.Customer;
            order.AssignedByType = AssignedByType.System;
            order.OrderStatus = OrderStatus.Completed;
            order.UpdatedOn = DateTime.UtcNow;

            // Create assignment history entry
            var assignmentHistory = new OrderAssignmentHistory
            {
                OrderId = order.OrderId,
                CustomerId = order.CustomerId,
                MedicalStoreId = order.MedicalStoreId,
                AssignedByType = AssignedByType.System,
                AssignTo = AssignTo.Customer,
                AssignedOn = DateTime.UtcNow,
                Status = AssignmentStatus.Assigned
            };

            _unitOfWork.Orders.Update(order);
            await _unitOfWork.OrderAssignmentHistories.AddAsync(assignmentHistory);
            await _unitOfWork.SaveChangesAsync();

            return _mapper.Map<OrderDto>(order);
        }

        public async Task<OrderDto> AssignOrderToMedicalStoreAsync(AssignOrderDto assignDto, CancellationToken cancellationToken = default)
        {
            ArgumentNullException.ThrowIfNull(assignDto);
            cancellationToken.ThrowIfCancellationRequested();

            if (assignDto.MedicalStoreId == Guid.Empty)
            {
                throw new ArgumentException("MedicalStoreId is required.", nameof(assignDto.MedicalStoreId));
            }

            // Find order by OrderNumber
            var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderId == assignDto.OrderId);
            if (order == null)
            {
                throw new KeyNotFoundException($"Order with OrderNumber '{assignDto.OrderId}' not found.");
            }

            // Validate medical store exists and is active
            var medicalStore = await _unitOfWork.MedicalStores.FirstOrDefaultAsync(ms => 
                ms.MedicalStoreId == assignDto.MedicalStoreId && 
                ms.IsActive && 
                !ms.IsDeleted);
            
            if (medicalStore == null)
            {
                throw new KeyNotFoundException("Medical store not found, inactive, or deleted.");
            }

            // Update order assignment
            order.MedicalStoreId = assignDto.MedicalStoreId;
            order.AssignTo = AssignTo.Chemist;
            order.AssignedByType = AssignedByType.System;
            order.OrderStatus = OrderStatus.AssignedToChemist;
            order.UpdatedOn = DateTime.UtcNow;

            // Create assignment history entry
            var assignmentHistory = new OrderAssignmentHistory
            {
                OrderId = order.OrderId,
                CustomerId = order.CustomerId,
                MedicalStoreId = assignDto.MedicalStoreId,
                AssignedByType = AssignedByType.System,
                AssignTo = AssignTo.Chemist,
                AssignedOn = DateTime.UtcNow,
                Status = AssignmentStatus.Assigned
            };

            _unitOfWork.Orders.Update(order);
            await _unitOfWork.OrderAssignmentHistories.AddAsync(assignmentHistory);
            await _unitOfWork.SaveChangesAsync();

            return _mapper.Map<OrderDto>(order);
        }

        private void ValidateOrderInputFile(OrderInputType inputType, IFormFile file)
        {
            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            if (string.IsNullOrEmpty(extension))
            {
                throw new ArgumentException("The uploaded file must have an extension.", nameof(file));
            }

            var allowedExtensions = inputType == OrderInputType.Image
                ? AllowedImageExtensions
                : AllowedVoiceExtensions;

            if (!allowedExtensions.Contains(extension))
            {
                throw new ArgumentException($"File type '{extension}' is not supported for {inputType} orders.", nameof(file));
            }
        }

        private async Task<string> SaveOrderInputFileAsync(IFormFile file, OrderInputType inputType, CancellationToken cancellationToken)
        {
            var folderName = inputType switch
            {
                OrderInputType.Image => "Images",
                OrderInputType.Voice => "Voice",
                _ => throw new InvalidOperationException("Unsupported order input type for file upload.")
            };

            var basePath = Path.Combine(_hostEnvironment.ContentRootPath, "Files", "Orders", folderName);
            Directory.CreateDirectory(basePath);

            var fileExtension = Path.GetExtension(file.FileName);
            var uniqueFileName = $"{Guid.NewGuid():N}{fileExtension}";
            var filePath = Path.Combine(basePath, uniqueFileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream, cancellationToken);
            }

            return Path.Combine("Files", "Orders", folderName, uniqueFileName).Replace("\\", "/");
        }

        /// <summary>
        /// Generates a random 10-character order number containing uppercase letters and numbers.
        /// </summary>
        private string GenerateOrderNumber()
        {
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            var random = new Random();
            return new string(Enumerable.Repeat(chars, 10)
                .Select(s => s[random.Next(s.Length)]).ToArray());
        }

        /// <summary>
        /// Generates a random 4-digit OTP.
        /// </summary>
        private string GenerateOTP()
        {
            var random = new Random();
            return random.Next(1000, 9999).ToString();
        }

        public async Task<OrderDto> UploadOrderBillAsync(UploadOrderBillDto uploadDto, CancellationToken cancellationToken = default)
        {
            ArgumentNullException.ThrowIfNull(uploadDto);
            cancellationToken.ThrowIfCancellationRequested();

            if (uploadDto.BillFile == null || uploadDto.BillFile.Length == 0)
            {
                throw new ArgumentException("Bill file is required.", nameof(uploadDto.BillFile));
            }

            // Validate PDF file
            var extension = Path.GetExtension(uploadDto.BillFile.FileName).ToLowerInvariant();
            if (string.IsNullOrEmpty(extension) || !AllowedPdfExtensions.Contains(extension))
            {
                throw new ArgumentException("Only PDF files are allowed for order bills.", nameof(uploadDto.BillFile));
            }

            // Find the order
            var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderId == uploadDto.OrderId);
            if (order == null)
            {
                throw new KeyNotFoundException($"Order with OrderId '{uploadDto.OrderId}' not found.");
            }

            // Save the PDF file
            var basePath = Path.Combine(_hostEnvironment.ContentRootPath, "Files", "Orders", "Bills");
            Directory.CreateDirectory(basePath);

            var fileExtension = Path.GetExtension(uploadDto.BillFile.FileName);
            var uniqueFileName = $"{Guid.NewGuid():N}{fileExtension}";
            var filePath = Path.Combine(basePath, uniqueFileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await uploadDto.BillFile.CopyToAsync(stream, cancellationToken);
            }

            var fileLocation = Path.Combine("Files", "Orders", "Bills", uniqueFileName).Replace("\\", "/");

            // Update order with bill file location and amount
            order.OrderBillFileLocation = fileLocation;
            order.TotalAmount = uploadDto.OrderAmount;
            order.OrderStatus = OrderStatus.BillUploaded;
            order.UpdatedOn = DateTime.UtcNow;

            // Create assignment history entry
            var assignmentHistory = new OrderAssignmentHistory
            {
                OrderId = order.OrderId,
                CustomerId = order.CustomerId,
                MedicalStoreId = order.MedicalStoreId,
                AssignedByType = AssignedByType.System,
                AssignTo = AssignTo.Chemist,
                AssignedOn = DateTime.UtcNow,
                Status = AssignmentStatus.Assigned
            };

            _unitOfWork.Orders.Update(order);
            await _unitOfWork.OrderAssignmentHistories.AddAsync(assignmentHistory);
            await _unitOfWork.SaveChangesAsync();

            return _mapper.Map<OrderDto>(order);
        }

        public async Task<OrderDto> AssignOrderToDeliveryAsync(AssignOrderToDeliveryDto assignDto, CancellationToken cancellationToken = default)
        {
            ArgumentNullException.ThrowIfNull(assignDto);
            cancellationToken.ThrowIfCancellationRequested();

            // Find the order
            var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderId == assignDto.OrderId);
            if (order == null)
            {
                throw new KeyNotFoundException($"Order with OrderId '{assignDto.OrderId}' not found.");
            }

            // Validate delivery exists and is active
            var delivery = await _unitOfWork.Deliveries.GetByIdAsync(assignDto.DeliveryId);
            if (delivery == null || delivery.IsDeleted || !delivery.IsActive)
            {
                throw new KeyNotFoundException($"Active delivery with ID '{assignDto.DeliveryId}' not found.");
            }

            // Validate order is in a state that can be assigned to delivery
            if (order.OrderStatus != OrderStatus.BillUploaded && order.OrderStatus != OrderStatus.Paid)
            {
                throw new InvalidOperationException($"Order can only be assigned to delivery when status is {OrderStatus.BillUploaded} or {OrderStatus.Paid}. Current status is {order.OrderStatus}.");
            }

            // Update order
            order.DeliveryId = assignDto.DeliveryId;
            order.AssignTo = AssignTo.Delivery;
            order.OrderStatus = OrderStatus.OutForDelivery;
            order.UpdatedOn = DateTime.UtcNow;

            // Create assignment history entry
            var assignmentHistory = new OrderAssignmentHistory
            {
                OrderId = order.OrderId,
                CustomerId = order.CustomerId,
                MedicalStoreId = order.MedicalStoreId,
                DeliveryId = assignDto.DeliveryId,
                AssignedByType = AssignedByType.System,
                AssignTo = AssignTo.Delivery,
                AssignedOn = DateTime.UtcNow,
                Status = AssignmentStatus.Assigned
            };

            _unitOfWork.Orders.Update(order);
            await _unitOfWork.OrderAssignmentHistories.AddAsync(assignmentHistory);
            await _unitOfWork.SaveChangesAsync();

            return _mapper.Map<OrderDto>(order);
        }

        public async Task<IEnumerable<OrderDto>> GetAllOrdersAsync(CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            var orders = await _unitOfWork.Orders.GetAllAsync();
            return _mapper.Map<IEnumerable<OrderDto>>(orders);
        }

        public async Task<IEnumerable<MedicalStoreBasicDto>> GetMedicalStoresByOrderCityAsync(int orderId, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            // Get the order
            var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId);
            if (order == null)
            {
                throw new KeyNotFoundException("Order not found.");
            }

            // Get the customer address to find the city
            var customerAddress = await _unitOfWork.CustomerAddresses.FirstOrDefaultAsync(ca => ca.Id == order.CustomerAddressId);
            if (customerAddress == null)
            {
                throw new KeyNotFoundException("Customer address not found for this order.");
            }

            if (string.IsNullOrWhiteSpace(customerAddress.City))
            {
                throw new InvalidOperationException("Customer address does not have a city.");
            }

            // Find all active MedicalStores in the same city
            var medicalStores = await _unitOfWork.MedicalStores.FindAsync(
                ms => ms.City.Equals(customerAddress.City.Trim(), StringComparison.OrdinalIgnoreCase) &&
                      ms.IsActive &&
                      !ms.IsDeleted);

            // Map to basic DTO with only ID and Name
            return medicalStores.Select(ms => new MedicalStoreBasicDto
            {
                MedicalStoreId = ms.MedicalStoreId,
                MedicalName = ms.MedicalName
            }).ToList();
        }

        public async Task<IEnumerable<OrderDto>> AssignedToCustomerSupportByCustomerSupportIdAsync(Guid customerSupportId, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            if (customerSupportId == Guid.Empty)
            {
                throw new ArgumentException("CustomerSupportId is required.", nameof(customerSupportId));
            }

            var orders = await _unitOfWork.Orders.FindAsync(o => 
                o.CustomerSupportId == customerSupportId && 
                o.OrderStatus == OrderStatus.AssignedToCustomerSupport);
            
            return _mapper.Map<IEnumerable<OrderDto>>(orders);
        }

        public async Task<IEnumerable<OrderDto>> GetAllOrdersByCustomerSupportIdAsync(Guid customerSupportId, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            if (customerSupportId == Guid.Empty)
            {
                throw new ArgumentException("CustomerSupportId is required.", nameof(customerSupportId));
            }

            var orders = await _unitOfWork.Orders.FindAsync(o => o.CustomerSupportId == customerSupportId);
            
            return _mapper.Map<IEnumerable<OrderDto>>(orders);
        }

        public async Task<IEnumerable<DeliveryDto>> GetEligibleDeliveryBoysByOrderIdAsync(int orderId, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            // Find the order
            var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId);
            if (order == null)
            {
                throw new KeyNotFoundException($"Order with ID '{orderId}' not found.");
            }

            // Get customer address to find postal code
            var customerAddress = await _unitOfWork.CustomerAddresses.GetByIdAsync(order.CustomerAddressId);
            if (customerAddress == null)
            {
                throw new KeyNotFoundException("Customer address not found for this order.");
            }

            if (string.IsNullOrWhiteSpace(customerAddress.PostalCode))
            {
                throw new InvalidOperationException("Customer address does not have a postal code.");
            }

            var postalCode = customerAddress.PostalCode.Trim();

            // Find ServiceRegionPinCodes matching the postal code
            var regionPinCodes = await _unitOfWork.ServiceRegionPinCodes.FindAsync(
                srpc => srpc.PinCode == postalCode);

            if (!regionPinCodes.Any())
            {
                return Enumerable.Empty<DeliveryDto>();
            }

            // Get the region IDs and filter to DeliveryBoy regions only
            var regionIds = regionPinCodes.Select(rpc => rpc.ServiceRegionId).Distinct().ToList();
            var deliveryRegions = await _unitOfWork.ServiceRegions.FindAsync(
                sr => regionIds.Contains(sr.Id) && sr.RegionType == RegionType.DeliveryBoy);

            var deliveryRegionIds = deliveryRegions.Select(sr => sr.Id).ToList();
            if (!deliveryRegionIds.Any())
            {
                return Enumerable.Empty<DeliveryDto>();
            }

            // Find all active, non-deleted delivery boys in those regions
            var deliveries = await _unitOfWork.Deliveries.FindAsync(
                d => d.ServiceRegionId.HasValue &&
                     deliveryRegionIds.Contains(d.ServiceRegionId.Value) &&
                     d.IsActive &&
                     !d.IsDeleted);

            return _mapper.Map<IEnumerable<DeliveryDto>>(deliveries);
        }

        public async Task<IEnumerable<OrderDto>> GetOrdersByDeliveryIdAsync(int deliveryId, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            var orders = await _unitOfWork.Orders.FindAsync(o => o.DeliveryId == deliveryId);
            return _mapper.Map<IEnumerable<OrderDto>>(orders);
        }

        public async Task<IEnumerable<MedicalStoreBasicDto>> GetMedicalStoresByOrderPinCodeAsync(int orderId, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            // Find the order
            var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId);
            if (order == null)
            {
                throw new KeyNotFoundException($"Order with ID '{orderId}' not found.");
            }

            // Get customer address to find postal code
            var customerAddress = await _unitOfWork.CustomerAddresses.GetByIdAsync(order.CustomerAddressId);
            if (customerAddress == null)
            {
                throw new KeyNotFoundException("Customer address not found for this order.");
            }

            if (string.IsNullOrWhiteSpace(customerAddress.PostalCode))
            {
                throw new InvalidOperationException("Customer address does not have a postal code.");
            }

            var postalCode = customerAddress.PostalCode.Trim();

            // Find all active MedicalStores with the same postal code
            var medicalStores = await _unitOfWork.MedicalStores.FindAsync(
                ms => ms.PostalCode == postalCode &&
                      ms.IsActive &&
                      !ms.IsDeleted);

            return medicalStores.Select(ms => new MedicalStoreBasicDto
            {
                MedicalStoreId = ms.MedicalStoreId,
                MedicalName = ms.MedicalName
            }).ToList();
        }
    }
}


