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

using Microsoft.Extensions.Logging;
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
        private readonly IFileStorageService _fileStorageService;
        private readonly ApplicationDbContext _context;
        private readonly ILogger<OrderService> _logger;
        private readonly ISmsService _smsService;
        /// <summary>M-08: upper bound for order input files (prescription image / voice note) and bills.</summary>
        private const long MaxOrderInputFileBytes = 10 * 1024 * 1024; // 10 MB

        private static readonly string[] AllowedImageExtensions = { ".jpg", ".jpeg", ".png", ".gif", ".bmp" };
        private static readonly string[] AllowedVoiceExtensions = { ".mp3", ".wav", ".m4a", ".aac", ".ogg" };
        private static readonly string[] AllowedPdfExtensions = { ".pdf" };

        public OrderService(IUnitOfWork unitOfWork, IMapper mapper, IFileStorageService fileStorageService, ApplicationDbContext context, ILogger<OrderService> logger, ISmsService smsService)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _fileStorageService = fileStorageService;
            _context = context;
            _logger = logger;
            _smsService = smsService;
        }

        public async Task<OrderDto> CreateOrderAsync(CreateOrderDto createDto, CancellationToken cancellationToken = default)
        {
            ArgumentNullException.ThrowIfNull(createDto);

            cancellationToken.ThrowIfCancellationRequested();

            _logger.LogInformation(
                "CreateOrderAsync ENTRY: Customer={CustomerId}, Address={CustomerAddressId}, OrderType={OrderType}, InputType={OrderInputType}, HasInputText={HasInputText}, InputFile={InputFileName} ({InputFileLength} bytes)",
                createDto.CustomerId, createDto.CustomerAddressId, createDto.OrderType, createDto.OrderInputType,
                !string.IsNullOrWhiteSpace(createDto.OrderInputText),
                createDto.OrderInputFile?.FileName ?? "(none)", createDto.OrderInputFile?.Length ?? 0);

            if (createDto.CustomerId == Guid.Empty)
            {
                _logger.LogWarning("CreateOrderAsync failed: CustomerId is empty");
                throw new ArgumentException("CustomerId is required.", nameof(createDto.CustomerId));
            }

            if (createDto.CustomerAddressId == Guid.Empty)
            {
                _logger.LogWarning("CreateOrderAsync failed: CustomerAddressId is empty");
                throw new ArgumentException("CustomerAddressId is required.", nameof(createDto.CustomerAddressId));
            }

            if (!Enum.IsDefined(typeof(OrderType), createDto.OrderType))
            {
                _logger.LogWarning("CreateOrderAsync failed: Invalid OrderType {OrderType} for Customer {CustomerId}", createDto.OrderType, createDto.CustomerId);
                throw new ArgumentException("Invalid order type provided.", nameof(createDto.OrderType));
            }

            if (!Enum.IsDefined(typeof(OrderInputType), createDto.OrderInputType))
            {
                _logger.LogWarning("CreateOrderAsync failed: Invalid OrderInputType {OrderInputType} for Customer {CustomerId}", createDto.OrderInputType, createDto.CustomerId);
                throw new ArgumentException("Invalid order input type provided.", nameof(createDto.OrderInputType));
            }

            _logger.LogInformation("CreateOrderAsync STEP 1/7: Basic input validation passed. Looking up customer {CustomerId}.", createDto.CustomerId);

            // Ensure the customer exists and is active
            var customer = await _unitOfWork.Customers.FirstOrDefaultAsync(c => c.CustomerId == createDto.CustomerId && c.IsActive);
            if (customer == null)
            {
                _logger.LogWarning("CreateOrderAsync failed: Customer {CustomerId} not found or inactive", createDto.CustomerId);
                throw new KeyNotFoundException("Customer not found or inactive.");
            }

            _logger.LogInformation("CreateOrderAsync STEP 2/7: Customer found (Mobile={CustomerMobile}). Looking up address {CustomerAddressId}.", customer.MobileNumber, createDto.CustomerAddressId);

            // Ensure the address exists for the customer
            var address = await _unitOfWork.CustomerAddresses.FirstOrDefaultAsync(ca =>
                ca.Id == createDto.CustomerAddressId &&
                ca.CustomerId == createDto.CustomerId &&
                ca.IsActive);

            if (address == null)
            {
                _logger.LogWarning("CreateOrderAsync failed: Address {CustomerAddressId} not found or inactive for Customer {CustomerId}", createDto.CustomerAddressId, createDto.CustomerId);
                throw new KeyNotFoundException("Customer address not found or inactive.");
            }

            _logger.LogInformation(
                "CreateOrderAsync STEP 3/7: Address found. PostalCode={PostalCode}, HasCoordinates={HasCoordinates}. Running serviceability check.",
                string.IsNullOrWhiteSpace(address.PostalCode) ? "(none)" : address.PostalCode,
                address.Latitude.HasValue && address.Longitude.HasValue);
            _logger.LogDebug("CreateOrderAsync: Address coordinates Latitude={Latitude}, Longitude={Longitude}", address.Latitude, address.Longitude);

            // The delivery area must be fully serviceable — an eligible chemist within 5 km, plus a
            // customer support agent and a delivery partner covering the pin code. If any is missing,
            // no order is created (throws ServiceAreaUnavailableException -> HTTP 400).
            await EnsureOrderAreaIsServiceableAsync(address, cancellationToken);

            _logger.LogInformation("CreateOrderAsync STEP 4/7: Serviceability check passed. Validating {OrderInputType} input payload.", createDto.OrderInputType);

            // Validate input data based on the order input type
            switch (createDto.OrderInputType)
            {
                case OrderInputType.Text when string.IsNullOrWhiteSpace(createDto.OrderInputText):
                    _logger.LogWarning("CreateOrderAsync failed: Order input text is empty for Text order, Customer {CustomerId}", createDto.CustomerId);
                    throw new ArgumentException("Order input text is required when order input type is text.", nameof(createDto.OrderInputText));
                case OrderInputType.Image when createDto.OrderInputFile == null || createDto.OrderInputFile.Length == 0:
                    _logger.LogWarning("CreateOrderAsync failed: Image file missing for Image order, Customer {CustomerId}", createDto.CustomerId);
                    throw new ArgumentException("An image file is required when order input type is image.", nameof(createDto.OrderInputFile));
                case OrderInputType.Voice when createDto.OrderInputFile == null || createDto.OrderInputFile.Length == 0:
                    _logger.LogWarning("CreateOrderAsync failed: Voice file missing for Voice order, Customer {CustomerId}", createDto.CustomerId);
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

            // OTP value is intentionally NOT logged (it is the delivery-verification secret).
            _logger.LogInformation("CreateOrderAsync STEP 5/7: Order entity built. OrderNumber={OrderNumber}, InitialStatus={OrderStatus}, AssignTo={AssignTo}.", order.OrderNumber, order.OrderStatus, order.AssignTo);

            if (createDto.OrderInputType is OrderInputType.Image or OrderInputType.Voice)
            {
                if (createDto.OrderInputFile == null || createDto.OrderInputFile.Length == 0)
                {
                    _logger.LogWarning("CreateOrderAsync failed: Order input file is required for image or voice orders, Customer {CustomerId}", createDto.CustomerId);
                    throw new ArgumentException("An order input file is required for image or voice orders.", nameof(createDto.OrderInputFile));
                }

                _logger.LogInformation("CreateOrderAsync: Validating and uploading input file {InputFileName} ({InputFileLength} bytes) for {OrderInputType} order.", createDto.OrderInputFile.FileName, createDto.OrderInputFile.Length, createDto.OrderInputType);
                ValidateOrderInputFile(createDto.OrderInputType, createDto.OrderInputFile);
                order.OrderInputFileLocation = await SaveOrderInputFileAsync(createDto.OrderInputFile, createDto.OrderInputType, cancellationToken);
                _logger.LogInformation("CreateOrderAsync: Input file uploaded to {OrderInputFileLocation}.", order.OrderInputFileLocation);
            }
            else
            {
                order.OrderInputFileLocation = null;
                _logger.LogDebug("CreateOrderAsync: Text order — no input file to upload.");
            }

            _logger.LogInformation("CreateOrderAsync STEP 6/7: Persisting order to database.");

            await _unitOfWork.Orders.AddAsync(order);
            await _unitOfWork.SaveChangesAsync();

            _logger.LogInformation("Order {OrderId} created successfully for Customer {CustomerId} with OrderNumber {OrderNumber}", order.OrderId, order.CustomerId, order.OrderNumber);

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

            _logger.LogInformation("CreateOrderAsync STEP 7/7: Order {OrderId} persisted with initial assignment history. Running auto-assignment to nearest chemist.", order.OrderId);

            await AssignOrderToNearestChemist(order.OrderId);

            _logger.LogInformation(
                "CreateOrderAsync EXIT: Order {OrderId} (OrderNumber={OrderNumber}) complete. FinalStatus={OrderStatus}, MedicalStoreId={MedicalStoreId}, CustomerSupportId={CustomerSupportId}, ManagerId={ManagerId}.",
                order.OrderId, order.OrderNumber, order.OrderStatus, order.MedicalStoreId, order.CustomerSupportId, order.ManagerId);

            return _mapper.Map<OrderDto>(order);
        }

        /// <summary>
        /// Verifies that the delivery address's area can be fully served before an order is created:
        /// <list type="bullet">
        /// <item>an <b>eligible chemist</b> (active payout + paid activation) within a 5 km radius when the
        /// address has coordinates, otherwise an eligible chemist in the same postal code;</item>
        /// <item>a <b>customer support</b> agent whose <see cref="RegionType.CustomerSupport"/> region covers the pin code;</item>
        /// <item>a <b>delivery partner</b> whose <see cref="RegionType.DeliveryBoy"/> region covers the pin code.</item>
        /// </list>
        /// Throws <see cref="ServiceAreaUnavailableException"/> listing every missing role if any is unavailable.
        /// </summary>
        private async Task EnsureOrderAreaIsServiceableAsync(CustomerAddress address, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            var postalCode = address.PostalCode?.Trim() ?? string.Empty;
            var missingRoles = new List<string>();

            _logger.LogInformation("EnsureOrderAreaIsServiceableAsync ENTRY: PostalCode={PostalCode}, HasCoordinates={HasCoordinates}.",
                string.IsNullOrWhiteSpace(postalCode) ? "(none)" : postalCode, address.Latitude.HasValue && address.Longitude.HasValue);

            // --- Chemist: eligible store within 5 km (geo) or, without coordinates, in the same pin code ---
            var chemistAvailable = await IsChemistAvailableForAddressAsync(address, postalCode);
            if (!chemistAvailable)
                missingRoles.Add("chemist");

            _logger.LogInformation("EnsureOrderAreaIsServiceableAsync: Chemist availability = {ChemistAvailable}.", chemistAvailable);

            // Customer support and delivery partner are matched purely by pin code -> region. Without a
            // postal code neither can be resolved, so both count as unavailable.
            var customerSupportAvailable = false;
            var deliveryAvailable = false;

            if (!string.IsNullOrWhiteSpace(postalCode))
            {
                // --- Customer support: any active agent in a CustomerSupport region covering this pin ---
                var customerSupportRegionIds = (await _unitOfWork.ServiceRegions.FindAsync(
                        r => r.RegionType == RegionType.CustomerSupport))
                    .Select(r => r.Id)
                    .ToHashSet();

                var customerSupportPinRegionIds = (await _unitOfWork.ServiceRegionPinCodes.FindAsync(
                        rpc => rpc.PinCode == postalCode))
                    .Where(rpc => customerSupportRegionIds.Contains(rpc.ServiceRegionId))
                    .Select(rpc => rpc.ServiceRegionId)
                    .ToHashSet();

                if (customerSupportPinRegionIds.Count > 0)
                {
                    customerSupportAvailable = await _unitOfWork.CustomerSupports.AnyAsync(
                        cs => cs.ServiceRegionId.HasValue &&
                              customerSupportPinRegionIds.Contains(cs.ServiceRegionId.Value) &&
                              cs.IsActive &&
                              !cs.IsDeleted);
                }

                _logger.LogInformation("EnsureOrderAreaIsServiceableAsync: CustomerSupport regions covering {PostalCode} = {CustomerSupportRegionCount}; active agent available = {CustomerSupportAvailable}.",
                    postalCode, customerSupportPinRegionIds.Count, customerSupportAvailable);

                // --- Delivery partner: any active delivery boy in a DeliveryBoy region covering this pin ---
                var deliveryRegionIds = (await _unitOfWork.ServiceRegions.FindAsync(
                        r => r.RegionType == RegionType.DeliveryBoy))
                    .Select(r => r.Id)
                    .ToHashSet();

                var deliveryPinRegionIds = (await _unitOfWork.ServiceRegionPinCodes.FindAsync(
                        rpc => rpc.PinCode == postalCode))
                    .Where(rpc => deliveryRegionIds.Contains(rpc.ServiceRegionId))
                    .Select(rpc => rpc.ServiceRegionId)
                    .ToHashSet();

                if (deliveryPinRegionIds.Count > 0)
                {
                    deliveryAvailable = await _unitOfWork.Deliveries.AnyAsync(
                        d => d.ServiceRegionId.HasValue &&
                             deliveryPinRegionIds.Contains(d.ServiceRegionId.Value) &&
                             d.IsActive &&
                             !d.IsDeleted);
                }

                _logger.LogInformation("EnsureOrderAreaIsServiceableAsync: DeliveryBoy regions covering {PostalCode} = {DeliveryRegionCount}; active delivery partner available = {DeliveryAvailable}.",
                    postalCode, deliveryPinRegionIds.Count, deliveryAvailable);
            }
            else
            {
                _logger.LogWarning("EnsureOrderAreaIsServiceableAsync: Address has no postal code — customer support and delivery partner cannot be resolved and both count as unavailable.");
            }

            if (!customerSupportAvailable)
                missingRoles.Add("customer support");

            if (!deliveryAvailable)
                missingRoles.Add("delivery partner");

            if (missingRoles.Count > 0)
            {
                _logger.LogWarning(
                    "CreateOrderAsync blocked: area not serviceable for pincode {PostalCode}. Missing: {MissingRoles}",
                    string.IsNullOrWhiteSpace(postalCode) ? "(none)" : postalCode,
                    string.Join(", ", missingRoles));
                throw new ServiceAreaUnavailableException(postalCode, missingRoles);
            }

            _logger.LogInformation("EnsureOrderAreaIsServiceableAsync EXIT: Area is fully serviceable for pincode {PostalCode} (chemist + customer support + delivery partner all available).",
                string.IsNullOrWhiteSpace(postalCode) ? "(none)" : postalCode);
        }

        /// <summary>
        /// Determines whether an eligible chemist (active payout + paid activation) can serve the address:
        /// within a 5 km radius when the address has coordinates, otherwise present in the same postal code.
        /// </summary>
        private async Task<bool> IsChemistAvailableForAddressAsync(CustomerAddress address, string postalCode)
        {
            if (address.Latitude.HasValue && address.Longitude.HasValue)
            {
                _logger.LogDebug("IsChemistAvailableForAddressAsync: Using GEO path (address has coordinates).");

                var storesWithCoords = await _unitOfWork.MedicalStores.FindAsync(ms =>
                    ms.IsActive &&
                    !ms.IsDeleted &&
                    ms.Latitude.HasValue &&
                    ms.Longitude.HasValue);

                var storesWithCoordsList = storesWithCoords.ToList();
                var eligibleStores = await FilterEligibleStoresAsync(storesWithCoordsList);

                var nearestWithinRange = eligibleStores
                    .Select(ms => new
                    {
                        ms.MedicalStoreId,
                        DistanceKm = CalculateHaversineDistance(
                            (double)address.Latitude.Value,
                            (double)address.Longitude.Value,
                            (double)ms.Latitude!.Value,
                            (double)ms.Longitude!.Value)
                    })
                    .OrderBy(x => x.DistanceKm)
                    .FirstOrDefault();

                var available = nearestWithinRange != null && nearestWithinRange.DistanceKm <= 5.0;
                _logger.LogInformation(
                    "IsChemistAvailableForAddressAsync (GEO): active-with-coords stores={StoreCount}, eligible (payout+activation)={EligibleCount}, nearestEligibleKm={NearestKm}, within5km={Available}.",
                    storesWithCoordsList.Count, eligibleStores.Count,
                    nearestWithinRange == null ? "(none)" : nearestWithinRange.DistanceKm.ToString("F2"), available);

                return available;
            }

            // No coordinates — fall back to postal-code match, consistent with AssignOrderToNearestChemist.
            _logger.LogDebug("IsChemistAvailableForAddressAsync: Using POSTAL-CODE path (address has no coordinates).");
            if (string.IsNullOrWhiteSpace(postalCode))
            {
                _logger.LogInformation("IsChemistAvailableForAddressAsync (POSTAL): No postal code and no coordinates — no chemist can be matched.");
                return false;
            }

            var storesInPostalCode = await _unitOfWork.MedicalStores.FindAsync(ms =>
                ms.PostalCode == postalCode &&
                ms.IsActive &&
                !ms.IsDeleted);

            var storesInPostalCodeList = storesInPostalCode.ToList();
            var eligibleInPostalCode = await FilterEligibleStoresAsync(storesInPostalCodeList);
            _logger.LogInformation(
                "IsChemistAvailableForAddressAsync (POSTAL {PostalCode}): active stores in pincode={StoreCount}, eligible (payout+activation)={EligibleCount}, available={Available}.",
                postalCode, storesInPostalCodeList.Count, eligibleInPostalCode.Count, eligibleInPostalCode.Count > 0);
            return eligibleInPostalCode.Count > 0;
        }

        public async Task AssignOrderToNearestChemist(int orderId)
        {
            _logger.LogInformation("AssignOrderToNearestChemist ENTRY: Order {OrderId}.", orderId);

            // Find the order by OrderId
            var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId);
            if (order == null)
            {
                _logger.LogWarning("AssignOrderToNearestChemist failed: Order {OrderId} not found", orderId);
                throw new KeyNotFoundException($"Order with OrderId '{orderId}' not found.");
            }

            // Get the customer address for this order
            var address = await _unitOfWork.CustomerAddresses.FirstOrDefaultAsync(ca =>
                ca.Id == order.CustomerAddressId &&
                ca.CustomerId == order.CustomerId &&
                ca.IsActive);

            if (address == null)
            {
                _logger.LogWarning("AssignOrderToNearestChemist failed: Customer address not found or inactive for Order {OrderId}", orderId);
                throw new KeyNotFoundException("Customer address not found or inactive for this order.");
            }

            // Find nearest active medical store using NetTopologySuite if customer address has coordinates
            if (address.Latitude.HasValue && address.Longitude.HasValue)
            {
                _logger.LogInformation("AssignOrderToNearestChemist: Order {OrderId} using GEO assignment (address has coordinates).", orderId);

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

                // Only chemists that have completed payout onboarding AND paid the activation fee may receive orders.
                var eligibleStores = await FilterEligibleStoresAsync(medicalStores);

                _logger.LogInformation("AssignOrderToNearestChemist (GEO): Order {OrderId} has {EligibleCount} eligible chemist(s) with coordinates to choose from.", orderId, eligibleStores.Count);

                var nearestStore = eligibleStores
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

                    _logger.LogInformation("Order {OrderId} assigned to nearest chemist {MedicalStoreId}", order.OrderId, nearestStore.MedicalStoreId);
                }
                else
                {
                    // No eligible chemist (active payout + paid activation) with coordinates — hand off to customer support.
                    _logger.LogInformation("Order {OrderId}: No eligible medical store with coordinates found, assigning to customer support", orderId);
                    await AssignRejectOrderToCustomerSupport(orderId);
                }
            }
            else
            {
                // No lat/long available — fall back to postal code based assignment
                _logger.LogInformation("Order {OrderId}: Address missing coordinates, falling back to postal code based assignment", orderId);

                if (string.IsNullOrWhiteSpace(address.PostalCode))
                {
                    _logger.LogWarning("AssignOrderToNearestChemist failed: Customer address missing both coordinates and postal code for Order {OrderId}", orderId);
                    throw new InvalidOperationException("Customer address does not have coordinates or postal code required for assigning a chemist.");
                }

                var postalCode = address.PostalCode.Trim();

                // Find all active medical stores in the same postal code
                var storesInPostalCode = await _unitOfWork.MedicalStores.FindAsync(ms =>
                    ms.PostalCode == postalCode &&
                    ms.IsActive &&
                    !ms.IsDeleted);

                // Only chemists that have completed payout onboarding AND paid the activation fee may receive orders.
                var storesInPostalCodeList = await FilterEligibleStoresAsync(storesInPostalCode);

                _logger.LogInformation("AssignOrderToNearestChemist (POSTAL {PostalCode}): Order {OrderId} has {EligibleCount} eligible chemist(s) in pincode to choose from.", postalCode, orderId, storesInPostalCodeList.Count);

                if (storesInPostalCodeList.Count > 0)
                {
                    // Case 1: Chemists found — assign to the one with the fewest active (not completed/delivered) orders
                    var storeOrderCounts = new List<(MedicalStore Store, int ActiveOrderCount)>();

                    foreach (var store in storesInPostalCodeList)
                    {
                        var activeOrderCount = (await _unitOfWork.Orders.FindAsync(
                            o => o.MedicalStoreId == store.MedicalStoreId &&
                                 o.OrderStatus != OrderStatus.Completed &&
                                 o.OrderStatus != OrderStatus.RejectedByChemist)).Count();

                        storeOrderCounts.Add((store, activeOrderCount));
                    }

                    var selectedStore = storeOrderCounts
                        .OrderBy(x => x.ActiveOrderCount)
                        .ThenBy(x => x.Store.CreatedOn) // tie-breaker: oldest store first
                        .First()
                        .Store;

                    // Assign order to the selected store
                    order.MedicalStoreId = selectedStore.MedicalStoreId;
                    order.AssignTo = AssignTo.Chemist;
                    order.AssignedByType = AssignedByType.System;
                    order.OrderStatus = OrderStatus.AssignedToChemist;
                    order.UpdatedOn = DateTime.UtcNow;

                    var assignmentHistory = new OrderAssignmentHistory
                    {
                        OrderId = order.OrderId,
                        CustomerId = order.CustomerId,
                        MedicalStoreId = selectedStore.MedicalStoreId,
                        AssignedByType = AssignedByType.System,
                        AssignTo = AssignTo.Chemist,
                        AssignedOn = DateTime.UtcNow,
                        Status = AssignmentStatus.Assigned
                    };

                    _unitOfWork.Orders.Update(order);
                    await _unitOfWork.OrderAssignmentHistories.AddAsync(assignmentHistory);
                    await _unitOfWork.SaveChangesAsync();

                    _logger.LogInformation("Order {OrderId} assigned to chemist {MedicalStoreId} (postal code match, least active orders)", order.OrderId, selectedStore.MedicalStoreId);
                }
                else
                {
                    // Case 2: No eligible chemist in this postal code — assign to customer support
                    _logger.LogInformation("Order {OrderId}: No eligible chemists found in postal code {PostalCode}, assigning to customer support", orderId, postalCode);
                    await AssignRejectOrderToCustomerSupport(orderId);
                }
            }
        }

        /// <summary>
        /// Filters the given medical stores to those eligible to receive orders: the store must have
        /// a payout account with <see cref="ChemistPayoutStatus.Active"/> onboarding AND at least one
        /// activation payment with <see cref="ChemistActivationStatus.Paid"/> status.
        /// </summary>
        private async Task<List<MedicalStore>> FilterEligibleStoresAsync(IEnumerable<MedicalStore> stores)
        {
            var storeList = stores as ICollection<MedicalStore> ?? stores.ToList();
            var eligible = new List<MedicalStore>();
            var rejectedNoPayout = 0;
            var rejectedNoActivation = 0;

            _logger.LogDebug("FilterEligibleStoresAsync ENTRY: evaluating {CandidateCount} candidate store(s) for payout + activation eligibility.", storeList.Count);

            foreach (var store in storeList)
            {
                var hasActivePayout = await _unitOfWork.ChemistPayoutAccounts.AnyAsync(
                    pa => pa.MedicalStoreId == store.MedicalStoreId &&
                          pa.OnboardingStatus == ChemistPayoutStatus.Active);

                if (!hasActivePayout)
                {
                    rejectedNoPayout++;
                    _logger.LogDebug("FilterEligibleStoresAsync: Store {MedicalStoreId} EXCLUDED — no ACTIVE payout account.", store.MedicalStoreId);
                    continue;
                }

                var hasPaidActivation = await _unitOfWork.ChemistActivationPayments.AnyAsync(
                    ap => ap.MedicalStoreId == store.MedicalStoreId &&
                          ap.Status == ChemistActivationStatus.Paid);

                if (hasPaidActivation)
                {
                    eligible.Add(store);
                    _logger.LogDebug("FilterEligibleStoresAsync: Store {MedicalStoreId} ELIGIBLE (active payout + paid activation).", store.MedicalStoreId);
                }
                else
                {
                    rejectedNoActivation++;
                    _logger.LogDebug("FilterEligibleStoresAsync: Store {MedicalStoreId} EXCLUDED — activation fee not PAID.", store.MedicalStoreId);
                }
            }

            _logger.LogInformation(
                "FilterEligibleStoresAsync EXIT: {CandidateCount} candidate(s) -> {EligibleCount} eligible. Excluded: {NoPayout} without active payout, {NoActivation} without paid activation.",
                storeList.Count, eligible.Count, rejectedNoPayout, rejectedNoActivation);

            return eligible;
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
                .Include(o => o.Manager)
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
                        AssignTo.Manager => order.Manager != null
                            ? $"{order.Manager.ManagerFirstName} {order.Manager.ManagerLastName}".Trim()
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

            if (orderDto != null)
            {
                await EnrichAssigneeNamesAsync(new[] { orderDto }, cancellationToken);
            }

            return orderDto;
        }

        public async Task<IEnumerable<OrderDto>> GetOrdersByCustomerIdAsync(Guid customerId, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            if (customerId == Guid.Empty)
            {
                _logger.LogWarning("GetOrdersByCustomerIdAsync failed: CustomerId is empty");
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
                _logger.LogWarning("GetActiveOrdersByCustomerIdAsync failed: CustomerId is empty");
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
                _logger.LogWarning("GetActiveOrdersByMedicalStoreIdAsync failed: MedicalStoreId is empty");
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
                _logger.LogWarning("GetAcceptedOrdersByMedicalStoreIdAsync failed: MedicalStoreId is empty");
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
                _logger.LogWarning("GetRejectedOrdersByMedicalStoreIdAsync failed: MedicalStoreId is empty");
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
                _logger.LogWarning("GetAllOrdersByMedicalStoreIdAsync failed: MedicalStoreId is empty");
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
                _logger.LogWarning("AcceptOrderByChemistAsync failed: Order {OrderId} not found", orderId);
                throw new KeyNotFoundException("Order not found.");
            }

            if (order.OrderStatus != OrderStatus.AssignedToChemist)
            {
                _logger.LogWarning("AcceptOrderByChemistAsync failed: Order {OrderId} has invalid status {OrderStatus}, expected {ExpectedStatus}", orderId, order.OrderStatus, OrderStatus.AssignedToChemist);
                throw new InvalidOperationException($"Order can only be accepted when its status is {OrderStatus.AssignedToChemist}. Current status is {order.OrderStatus}.");
            }

            order.OrderStatus = OrderStatus.AcceptedByChemist;
            order.UpdatedOn = DateTime.UtcNow;

            _unitOfWork.Orders.Update(order);
            await _unitOfWork.SaveChangesAsync();

            _logger.LogInformation("Order {OrderId} accepted by chemist {MedicalStoreId}", orderId, order.MedicalStoreId);

            return _mapper.Map<OrderDto>(order);
        }

        public async Task<OrderDto> RejectOrderByChemistAsync(int orderId, RejectOrderDto rejectDto, CancellationToken cancellationToken = default)
        {
            ArgumentNullException.ThrowIfNull(rejectDto);
            cancellationToken.ThrowIfCancellationRequested();

            if (string.IsNullOrWhiteSpace(rejectDto.RejectNote))
            {
                _logger.LogWarning("RejectOrderByChemistAsync failed: Reject note is empty for Order {OrderId}", orderId);
                throw new ArgumentException("Reject note is required.", nameof(rejectDto.RejectNote));
            }

            var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId);
            if (order == null)
            {
                _logger.LogWarning("RejectOrderByChemistAsync failed: Order {OrderId} not found", orderId);
                throw new KeyNotFoundException("Order not found.");
            }

            if (order.OrderStatus != OrderStatus.AssignedToChemist)
            {
                _logger.LogWarning("RejectOrderByChemistAsync failed: Order {OrderId} has invalid status {OrderStatus}, expected {ExpectedStatus}", orderId, order.OrderStatus, OrderStatus.AssignedToChemist);
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
                _logger.LogWarning("RejectOrderByChemistAsync failed: No active assignment found for Order {OrderId}", orderId);
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

            _logger.LogInformation("Order {OrderId} rejected by chemist {MedicalStoreId}", orderId, order.MedicalStoreId);

            return _mapper.Map<OrderDto>(order);
        }

        /// <summary>
        /// Cancels an order and records the mandatory cancellation reason. Intended for customer support,
        /// manager and admin (authorized via the CancelOrders permission at the API layer). An order that is
        /// already cancelled, or already completed, cannot be cancelled.
        /// </summary>
        public async Task<OrderDto> CancelOrderAsync(int orderId, CancelOrderDto cancelDto, CancellationToken cancellationToken = default)
        {
            ArgumentNullException.ThrowIfNull(cancelDto);
            cancellationToken.ThrowIfCancellationRequested();

            if (string.IsNullOrWhiteSpace(cancelDto.CancellationReason))
            {
                _logger.LogWarning("CancelOrderAsync failed: Cancellation reason is empty for Order {OrderId}", orderId);
                throw new ArgumentException("Cancellation reason is required.", nameof(cancelDto.CancellationReason));
            }

            var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId);
            if (order == null)
            {
                _logger.LogWarning("CancelOrderAsync failed: Order {OrderId} not found", orderId);
                throw new KeyNotFoundException("Order not found.");
            }

            if (order.OrderStatus == OrderStatus.Cancelled)
            {
                _logger.LogWarning("CancelOrderAsync failed: Order {OrderId} is already cancelled", orderId);
                throw new InvalidOperationException("Order is already cancelled.");
            }

            if (order.OrderStatus == OrderStatus.Completed)
            {
                _logger.LogWarning("CancelOrderAsync failed: Order {OrderId} is completed and cannot be cancelled", orderId);
                throw new InvalidOperationException("A completed order cannot be cancelled.");
            }

            order.OrderStatus = OrderStatus.Cancelled;
            order.CancellationReason = cancelDto.CancellationReason.Trim();
            order.UpdatedOn = DateTime.UtcNow;

            _unitOfWork.Orders.Update(order);
            await _unitOfWork.SaveChangesAsync();

            _logger.LogInformation("Order {OrderId} cancelled. Reason: {CancellationReason}", orderId, order.CancellationReason);

            return _mapper.Map<OrderDto>(order);
        }

        public async Task AssignRejectOrderToCustomerSupport(int orderId, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            _logger.LogInformation("AssignRejectOrderToCustomerSupport ENTRY: Order {OrderId} (no eligible chemist / rejected — routing to customer support, escalating to manager if none).", orderId);

            // Get the order
            var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId);
            if (order == null)
            {
                _logger.LogWarning("AssignRejectOrderToCustomerSupport failed: Order {OrderId} not found", orderId);
                throw new KeyNotFoundException("Order not found.");
            }

            // Get the customer address to find the postal code
            var customerAddress = await _unitOfWork.CustomerAddresses.FirstOrDefaultAsync(ca => ca.Id == order.CustomerAddressId);
            if (customerAddress == null)
            {
                _logger.LogWarning("AssignRejectOrderToCustomerSupport failed: Customer address not found for Order {OrderId}", orderId);
                throw new KeyNotFoundException("Customer address not found for this order.");
            }

            if (string.IsNullOrWhiteSpace(customerAddress.PostalCode))
            {
                _logger.LogWarning("AssignRejectOrderToCustomerSupport failed: Customer address missing postal code for Order {OrderId}", orderId);
                throw new InvalidOperationException("Customer address does not have a postal code.");
            }

            var postalCode = customerAddress.PostalCode.Trim();

            // Find the CustomerSupport region serving this postal code. A pin code can be mapped to
            // regions of different types (e.g. CustomerSupport and DeliveryBoy), so the region type
            // must be part of the lookup — not validated after arbitrarily picking the first mapping.
            var customerSupportRegionIds = (await _unitOfWork.ServiceRegions.FindAsync(
                    r => r.RegionType == Domain.Enums.RegionType.CustomerSupport))
                .Select(r => r.Id)
                .ToHashSet();

            var regionPinCode = await _unitOfWork.ServiceRegionPinCodes.FirstOrDefaultAsync(
                rpc => rpc.PinCode == postalCode && customerSupportRegionIds.Contains(rpc.ServiceRegionId));

            if (regionPinCode == null)
            {
                // No customer support serves this pin code — escalate to a manager instead.
                _logger.LogInformation("AssignRejectOrderToCustomerSupport: No customer support region for postal code {PostalCode}, Order {OrderId}. Escalating to a manager.", postalCode, orderId);
                await AssignOrderToManagerAsync(order, cancellationToken);
                return;
            }

            // Get all CustomerSupports assigned to this region
            var customerSupports = await _unitOfWork.CustomerSupports.FindAsync(
                cs => cs.ServiceRegionId == regionPinCode.ServiceRegionId &&
                      cs.IsActive &&
                      !cs.IsDeleted);

            if (customerSupports == null || !customerSupports.Any())
            {
                // A region exists but has no active customer support agent — escalate to a manager.
                _logger.LogInformation("AssignRejectOrderToCustomerSupport: No active customer support for region {ServiceRegionId}, Order {OrderId}. Escalating to a manager.", regionPinCode.ServiceRegionId, orderId);
                await AssignOrderToManagerAsync(order, cancellationToken);
                return;
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

            _logger.LogInformation("Order {OrderId} assigned to customer support {CustomerSupportId}", orderId, selectedCustomerSupport.CustomerSupportId);
        }

        /// <summary>
        /// Escalates an order to a manager when no customer support serves the customer's pin code.
        /// The manager then re-assigns the order to a chemist (via <see cref="AssignOrderToMedicalStoreAsync"/>),
        /// after which the normal flow resumes. The manager with the fewest orders currently in
        /// <see cref="OrderStatus.AssignedToManager"/> status is chosen; the oldest manager wins ties.
        /// </summary>
        private async Task AssignOrderToManagerAsync(Order order, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            var managers = await _unitOfWork.Managers.FindAsync(m => m.IsActive && !m.IsDeleted);

            if (managers == null || !managers.Any())
            {
                _logger.LogError("AssignOrderToManagerAsync failed: No active manager available to escalate Order {OrderId}", order.OrderId);
                throw new InvalidOperationException("No active manager is available to handle this order.");
            }

            // Choose the least-loaded manager (fewest orders currently awaiting manager action).
            var managerOrderCounts = new List<(Manager Manager, int OrderCount)>();

            foreach (var manager in managers)
            {
                var orderCount = (await _unitOfWork.Orders.FindAsync(
                    o => o.ManagerId == manager.ManagerId &&
                         o.OrderStatus == OrderStatus.AssignedToManager)).Count();

                managerOrderCounts.Add((manager, orderCount));
            }

            var selectedManager = managerOrderCounts
                .OrderBy(x => x.OrderCount)
                .ThenBy(x => x.Manager.CreatedOn) // If tied, use the one created first
                .First()
                .Manager;

            order.ManagerId = selectedManager.ManagerId;
            order.AssignTo = AssignTo.Manager;
            order.AssignedByType = AssignedByType.System;
            order.OrderStatus = OrderStatus.AssignedToManager;
            order.UpdatedOn = DateTime.UtcNow;

            var assignmentHistory = new OrderAssignmentHistory
            {
                OrderId = order.OrderId,
                CustomerId = order.CustomerId,
                MedicalStoreId = order.MedicalStoreId,
                ManagerId = selectedManager.ManagerId,
                AssignedByType = AssignedByType.System,
                AssignTo = AssignTo.Manager,
                AssignedOn = DateTime.UtcNow,
                Status = AssignmentStatus.Assigned
            };

            _unitOfWork.Orders.Update(order);
            await _unitOfWork.OrderAssignmentHistories.AddAsync(assignmentHistory);
            await _unitOfWork.SaveChangesAsync();

            _logger.LogInformation("Order {OrderId} escalated to manager {ManagerId}", order.OrderId, selectedManager.ManagerId);
        }

        public async Task<IEnumerable<OrderDto>> AssignedToManagerByManagerIdAsync(Guid managerId, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            if (managerId == Guid.Empty)
            {
                _logger.LogWarning("AssignedToManagerByManagerIdAsync failed: ManagerId is empty");
                throw new ArgumentException("ManagerId is required.", nameof(managerId));
            }

            var orders = await _unitOfWork.Orders.FindAsync(o =>
                o.ManagerId == managerId &&
                o.OrderStatus == OrderStatus.AssignedToManager);

            var dtos = _mapper.Map<List<OrderDto>>(orders);
            await EnrichAssigneeNamesAsync(dtos, cancellationToken);
            return dtos;
        }

        public async Task<IEnumerable<OrderDto>> GetAllOrdersByManagerIdAsync(Guid managerId, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            if (managerId == Guid.Empty)
            {
                _logger.LogWarning("GetAllOrdersByManagerIdAsync failed: ManagerId is empty");
                throw new ArgumentException("ManagerId is required.", nameof(managerId));
            }

            var orders = await _unitOfWork.Orders.FindAsync(o => o.ManagerId == managerId);

            var dtos = _mapper.Map<List<OrderDto>>(orders);
            await EnrichAssigneeNamesAsync(dtos, cancellationToken);
            return dtos;
        }

        public async Task<OrderDto> CompleteOrderAsync(int orderId, CompleteOrderDto completeDto, CancellationToken cancellationToken = default)
        {
            ArgumentNullException.ThrowIfNull(completeDto);
            cancellationToken.ThrowIfCancellationRequested();

            if (string.IsNullOrWhiteSpace(completeDto.OTP))
            {
                _logger.LogWarning("CompleteOrderAsync failed: OTP is empty for Order {OrderId}", orderId);
                throw new ArgumentException("OTP is required.", nameof(completeDto.OTP));
            }

            var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId);
            if (order == null)
            {
                _logger.LogWarning("CompleteOrderAsync failed: Order {OrderId} not found", orderId);
                throw new KeyNotFoundException("Order not found.");
            }

            if (order.OrderStatus != OrderStatus.OutForDelivery)
            {
                _logger.LogWarning("CompleteOrderAsync failed: Order {OrderId} has invalid status {OrderStatus}, expected {ExpectedStatus}", orderId, order.OrderStatus, OrderStatus.OutForDelivery);
                throw new InvalidOperationException($"Order can only be completed when its status is {OrderStatus.OutForDelivery}. Current status is {order.OrderStatus}.");
            }

            // Check payment status before allowing completion
            if (order.OrderPaymentStatus != OrderPaymentStatus.FullyPaid)
            {
                var payments = await _unitOfWork.Payments.FindAsync(p => p.OrderId == orderId && p.PaymentStatus == PaymentStatus.Success);
                var totalPaid = payments.Sum(p => p.Amount);
                
                _logger.LogWarning("CompleteOrderAsync failed: Order {OrderId} payment incomplete. TotalAmount={TotalAmount}, TotalPaid={TotalPaid}", orderId, order.TotalAmount ?? 0, totalPaid);
                throw new PaymentIncompleteException(
                    orderId, 
                    order.TotalAmount ?? 0, 
                    totalPaid);
            }

            if (string.IsNullOrWhiteSpace(order.OTP))
            {
                _logger.LogWarning("CompleteOrderAsync failed: Order {OrderId} does not have an OTP set", orderId);
                throw new InvalidOperationException("Order does not have an OTP set.");
            }

            if (order.OTP.Trim() != completeDto.OTP.Trim())
            {
                _logger.LogWarning("CompleteOrderAsync failed: Invalid OTP provided for Order {OrderId}", orderId);
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

            _logger.LogInformation("Order {OrderId} completed successfully for Customer {CustomerId}", orderId, order.CustomerId);

            await SendOrderDeliveredSmsAsync(order);

            return _mapper.Map<OrderDto>(order);
        }

        /// <summary>
        /// Sends the order-delivered confirmation SMS to the customer once the delivery boy
        /// verifies the order OTP. Best-effort: failures are logged but never block order completion.
        /// </summary>
        private async Task SendOrderDeliveredSmsAsync(Order order)
        {
            try
            {
                var customer = await _unitOfWork.Customers.FirstOrDefaultAsync(c => c.CustomerId == order.CustomerId);
                if (customer == null || string.IsNullOrWhiteSpace(customer.MobileNumber))
                {
                    _logger.LogWarning("Skipping order-delivered SMS for Order {OrderId}: customer or mobile number missing.", order.OrderId);
                    return;
                }

                var storeName = string.Empty;
                if (order.MedicalStoreId.HasValue)
                {
                    var store = await _unitOfWork.MedicalStores.FirstOrDefaultAsync(s => s.MedicalStoreId == order.MedicalStoreId.Value);
                    storeName = store?.MedicalName ?? string.Empty;
                }

                await _smsService.SendOrderDeliveredAsync(
                    customer.MobileNumber,
                    customer.CustomerFirstName,
                    order.OrderNumber ?? order.OrderId.ToString(),
                    storeName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send order-delivered SMS for Order {OrderId}.", order.OrderId);
            }
        }

        public async Task<OrderDto> AssignOrderToMedicalStoreAsync(AssignOrderDto assignDto, CancellationToken cancellationToken = default)
        {
            ArgumentNullException.ThrowIfNull(assignDto);
            cancellationToken.ThrowIfCancellationRequested();

            if (assignDto.MedicalStoreId == Guid.Empty)
            {
                _logger.LogWarning("AssignOrderToMedicalStoreAsync failed: MedicalStoreId is empty for Order {OrderId}", assignDto.OrderId);
                throw new ArgumentException("MedicalStoreId is required.", nameof(assignDto.MedicalStoreId));
            }

            // Find order by OrderNumber
            var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderId == assignDto.OrderId);
            if (order == null)
            {
                _logger.LogWarning("AssignOrderToMedicalStoreAsync failed: Order {OrderId} not found", assignDto.OrderId);
                throw new KeyNotFoundException($"Order with OrderNumber '{assignDto.OrderId}' not found.");
            }

            // Validate medical store exists and is active
            var medicalStore = await _unitOfWork.MedicalStores.FirstOrDefaultAsync(ms => 
                ms.MedicalStoreId == assignDto.MedicalStoreId && 
                ms.IsActive && 
                !ms.IsDeleted);
            
            if (medicalStore == null)
            {
                _logger.LogWarning("AssignOrderToMedicalStoreAsync failed: MedicalStore {MedicalStoreId} not found, inactive, or deleted", assignDto.MedicalStoreId);
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

            _logger.LogInformation("Order {OrderId} assigned to medical store {MedicalStoreId}", order.OrderId, assignDto.MedicalStoreId);

            return _mapper.Map<OrderDto>(order);
        }

        private void ValidateOrderInputFile(OrderInputType inputType, IFormFile file)
        {
            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            if (string.IsNullOrEmpty(extension))
            {
                _logger.LogWarning("ValidateOrderInputFile failed: Uploaded file has no extension");
                throw new ArgumentException("The uploaded file must have an extension.", nameof(file));
            }

            var allowedExtensions = inputType == OrderInputType.Image
                ? AllowedImageExtensions
                : AllowedVoiceExtensions;

            if (!allowedExtensions.Contains(extension))
            {
                _logger.LogWarning("ValidateOrderInputFile failed: File type {Extension} not supported for {InputType} orders", extension, inputType);
                throw new ArgumentException($"File type '{extension}' is not supported for {inputType} orders.", nameof(file));
            }

            // M-08: cap the size — an unbounded upload is a cheap storage/bandwidth DoS.
            if (file.Length > MaxOrderInputFileBytes)
            {
                _logger.LogWarning("ValidateOrderInputFile failed: File {FileName} is {Size} bytes, exceeding the {Max} byte limit", file.FileName, file.Length, MaxOrderInputFileBytes);
                throw new ArgumentException($"The file exceeds the maximum allowed size of {MaxOrderInputFileBytes / (1024 * 1024)} MB.", nameof(file));
            }

            // M-08: the extension is attacker-controlled, so confirm the content actually matches it.
            if (!FileSignatureValidator.Matches(file, extension))
            {
                _logger.LogWarning("ValidateOrderInputFile failed: File {FileName} content does not match its {Extension} extension", file.FileName, extension);
                throw new ArgumentException($"The file content does not match its '{extension}' extension.", nameof(file));
            }

            _logger.LogDebug("ValidateOrderInputFile: File '{FileName}' with extension {Extension} is valid for {InputType} orders.", file.FileName, extension, inputType);
        }

        private async Task<string> SaveOrderInputFileAsync(IFormFile file, OrderInputType inputType, CancellationToken cancellationToken)
        {
            var folderName = inputType switch
            {
                OrderInputType.Image => "Images",
                OrderInputType.Voice => "Voice",
                _ => throw new InvalidOperationException("Unsupported order input type for file upload.")
            };

            var fileExtension = Path.GetExtension(file.FileName);
            var uniqueFileName = $"{Guid.NewGuid():N}{fileExtension}";
            var relativePath = Path.Combine("Files", "Orders", folderName, uniqueFileName).Replace("\\", "/");

            _logger.LogInformation("SaveOrderInputFileAsync: Uploading {InputType} file '{OriginalFileName}' ({FileLength} bytes) to storage path {RelativePath}.", inputType, file.FileName, file.Length, relativePath);

            using var stream = file.OpenReadStream();
            await _fileStorageService.UploadAsync(stream, relativePath, cancellationToken);

            _logger.LogInformation("SaveOrderInputFileAsync: Upload complete for {RelativePath}.", relativePath);

            return relativePath;
        }

        /// <summary>
        /// Generates a random 10-character order number containing uppercase letters and numbers.
        /// </summary>
        private string GenerateOrderNumber()
        {
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            var random = new Random();
            var orderNumber = new string(Enumerable.Repeat(chars, 10)
                .Select(s => s[random.Next(s.Length)]).ToArray());
            _logger.LogDebug("GenerateOrderNumber: Generated OrderNumber={OrderNumber}.", orderNumber);
            return orderNumber;
        }

        /// <summary>
        /// Generates a random 4-digit OTP.
        /// </summary>
        private string GenerateOTP()
        {
            var random = new Random();
            var otp = random.Next(1000, 9999).ToString();
            // The OTP value is the delivery-verification secret and is deliberately never logged.
            _logger.LogDebug("GenerateOTP: Generated a {OtpLength}-digit delivery OTP (value redacted).", otp.Length);
            return otp;
        }

        public async Task<OrderDto> UploadOrderBillAsync(UploadOrderBillDto uploadDto, CancellationToken cancellationToken = default)
        {
            ArgumentNullException.ThrowIfNull(uploadDto);
            cancellationToken.ThrowIfCancellationRequested();

            if (uploadDto.BillFile == null || uploadDto.BillFile.Length == 0)
            {
                _logger.LogWarning("UploadOrderBillAsync failed: Bill file is missing for Order {OrderId}", uploadDto.OrderId);
                throw new ArgumentException("Bill file is required.", nameof(uploadDto.BillFile));
            }

            // Validate file type: PDF or image
            var extension = Path.GetExtension(uploadDto.BillFile.FileName).ToLowerInvariant();
            if (string.IsNullOrEmpty(extension) || !(AllowedPdfExtensions.Contains(extension) || AllowedImageExtensions.Contains(extension)))
            {
                _logger.LogWarning("UploadOrderBillAsync failed: Unsupported file type uploaded for Order {OrderId}, extension: {Extension}", uploadDto.OrderId, extension);
                throw new ArgumentException("Only PDF or image files (jpg, jpeg, png, gif, bmp) are allowed for order bills.", nameof(uploadDto.BillFile));
            }

            // Find the order
            var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderId == uploadDto.OrderId);
            if (order == null)
            {
                _logger.LogWarning("UploadOrderBillAsync failed: Order {OrderId} not found", uploadDto.OrderId);
                throw new KeyNotFoundException($"Order with OrderId '{uploadDto.OrderId}' not found.");
            }

            // Save the PDF file
            var fileExtension = Path.GetExtension(uploadDto.BillFile.FileName);
            var uniqueFileName = $"{Guid.NewGuid():N}{fileExtension}";
            var fileLocation = Path.Combine("Files", "Orders", "Bills", uniqueFileName).Replace("\\", "/");

            using (var stream = uploadDto.BillFile.OpenReadStream())
            {
                await _fileStorageService.UploadAsync(stream, fileLocation, cancellationToken);
            }

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

            _logger.LogInformation("Bill uploaded for Order {OrderId}, amount: {OrderAmount}", order.OrderId, uploadDto.OrderAmount);

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
                _logger.LogWarning("AssignOrderToDeliveryAsync failed: Order {OrderId} not found", assignDto.OrderId);
                throw new KeyNotFoundException($"Order with OrderId '{assignDto.OrderId}' not found.");
            }

            // Validate delivery exists and is active
            var delivery = await _unitOfWork.Deliveries.GetByIdAsync(assignDto.DeliveryId);
            if (delivery == null || delivery.IsDeleted || !delivery.IsActive)
            {
                _logger.LogWarning("AssignOrderToDeliveryAsync failed: Active delivery {DeliveryId} not found for Order {OrderId}", assignDto.DeliveryId, assignDto.OrderId);
                throw new KeyNotFoundException($"Active delivery with ID '{assignDto.DeliveryId}' not found.");
            }

            // Validate order is in a state that can be assigned to delivery
            if (order.OrderStatus != OrderStatus.BillUploaded && order.OrderStatus != OrderStatus.Paid)
            {
                _logger.LogWarning("AssignOrderToDeliveryAsync failed: Order {OrderId} has invalid status {OrderStatus}, expected {ExpectedStatus1} or {ExpectedStatus2}", assignDto.OrderId, order.OrderStatus, OrderStatus.BillUploaded, OrderStatus.Paid);
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

            _logger.LogInformation("Order {OrderId} assigned to delivery {DeliveryId}", order.OrderId, assignDto.DeliveryId);

            return _mapper.Map<OrderDto>(order);
        }

        public async Task<IEnumerable<OrderDto>> GetAllOrdersAsync(CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            var orders = await _unitOfWork.Orders.GetAllAsync();
            var dtos = _mapper.Map<List<OrderDto>>(orders);
            await EnrichAssigneeNamesAsync(dtos, cancellationToken);
            return dtos;
        }

        /// <summary>
        /// Fills the display names on order DTOs — customer, chemist store, support agent, manager
        /// and delivery partner — using one batched lookup per party rather than a query per order.
        /// Called by the staff-facing endpoints so a console can render an order list without
        /// downloading every roster to resolve ids itself.
        /// </summary>
        private async Task EnrichAssigneeNamesAsync(IReadOnlyCollection<OrderDto> dtos, CancellationToken cancellationToken = default)
        {
            if (dtos.Count == 0)
            {
                return;
            }

            cancellationToken.ThrowIfCancellationRequested();

            var customerIds = dtos.Select(d => d.CustomerId).Where(id => id != Guid.Empty).Distinct().ToList();
            if (customerIds.Count > 0)
            {
                var customers = await _unitOfWork.Customers.FindAsync(c => customerIds.Contains(c.CustomerId));
                var nameById = customers.ToDictionary(
                    c => c.CustomerId,
                    c => $"{c.CustomerFirstName} {c.CustomerLastName}".Trim());

                foreach (var dto in dtos)
                {
                    if (nameById.TryGetValue(dto.CustomerId, out var name) && !string.IsNullOrWhiteSpace(name))
                    {
                        dto.CustomerName = name;
                    }
                }
            }

            var medicalStoreIds = dtos.Where(d => d.MedicalStoreId.HasValue).Select(d => d.MedicalStoreId!.Value).Distinct().ToList();
            if (medicalStoreIds.Count > 0)
            {
                var stores = await _unitOfWork.MedicalStores.FindAsync(ms => medicalStoreIds.Contains(ms.MedicalStoreId));
                var nameById = stores.ToDictionary(ms => ms.MedicalStoreId, ms => ms.MedicalName);

                foreach (var dto in dtos)
                {
                    if (dto.MedicalStoreId.HasValue && nameById.TryGetValue(dto.MedicalStoreId.Value, out var name))
                    {
                        dto.MedicalStoreName = name;
                    }
                }
            }

            var customerSupportIds = dtos.Where(d => d.CustomerSupportId.HasValue).Select(d => d.CustomerSupportId!.Value).Distinct().ToList();
            if (customerSupportIds.Count > 0)
            {
                var customerSupports = await _unitOfWork.CustomerSupports.FindAsync(cs => customerSupportIds.Contains(cs.CustomerSupportId));
                var nameById = customerSupports.ToDictionary(
                    cs => cs.CustomerSupportId,
                    cs => $"{cs.CustomerSupportFirstName} {cs.CustomerSupportLastName}".Trim());

                foreach (var dto in dtos)
                {
                    if (dto.CustomerSupportId.HasValue && nameById.TryGetValue(dto.CustomerSupportId.Value, out var name) && !string.IsNullOrWhiteSpace(name))
                    {
                        dto.CustomerSupportName = name;
                    }
                }
            }

            var managerIds = dtos.Where(d => d.ManagerId.HasValue).Select(d => d.ManagerId!.Value).Distinct().ToList();
            if (managerIds.Count > 0)
            {
                var managers = await _unitOfWork.Managers.FindAsync(m => managerIds.Contains(m.ManagerId));
                var nameById = managers.ToDictionary(
                    m => m.ManagerId,
                    m => $"{m.ManagerFirstName} {m.ManagerLastName}".Trim());

                foreach (var dto in dtos)
                {
                    if (dto.ManagerId.HasValue && nameById.TryGetValue(dto.ManagerId.Value, out var name) && !string.IsNullOrWhiteSpace(name))
                    {
                        dto.ManagerName = name;
                    }
                }
            }

            var deliveryIds = dtos.Where(d => d.DeliveryId.HasValue).Select(d => d.DeliveryId!.Value).Distinct().ToList();
            if (deliveryIds.Count > 0)
            {
                var deliveries = await _unitOfWork.Deliveries.FindAsync(d => deliveryIds.Contains(d.Id));
                var nameById = deliveries.ToDictionary(
                    d => d.Id,
                    d => $"{d.FirstName ?? string.Empty} {d.LastName ?? string.Empty}".Trim());

                foreach (var dto in dtos)
                {
                    if (dto.DeliveryId.HasValue && nameById.TryGetValue(dto.DeliveryId.Value, out var name) && !string.IsNullOrWhiteSpace(name))
                    {
                        dto.DeliveryBoyName = name;
                    }
                }
            }
        }

        public async Task<IEnumerable<MedicalStoreBasicDto>> GetMedicalStoresByOrderCityAsync(int orderId, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            // Get the order
            var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId);
            if (order == null)
            {
                _logger.LogWarning("GetMedicalStoresByOrderCityAsync failed: Order {OrderId} not found", orderId);
                throw new KeyNotFoundException("Order not found.");
            }

            // Get the customer address to find the city
            var customerAddress = await _unitOfWork.CustomerAddresses.FirstOrDefaultAsync(ca => ca.Id == order.CustomerAddressId);
            if (customerAddress == null)
            {
                _logger.LogWarning("GetMedicalStoresByOrderCityAsync failed: Customer address not found for Order {OrderId}", orderId);
                throw new KeyNotFoundException("Customer address not found for this order.");
            }

            if (string.IsNullOrWhiteSpace(customerAddress.City))
            {
                _logger.LogWarning("GetMedicalStoresByOrderCityAsync failed: Customer address missing city for Order {OrderId}", orderId);
                throw new InvalidOperationException("Customer address does not have a city.");
            }

            // Find all active MedicalStores in the same city.
            // Compare with ToLower() rather than string.Equals(StringComparison): EF Core cannot
            // translate the StringComparison overload, and the whole query threw at runtime.
            var city = customerAddress.City.Trim().ToLower();
            var medicalStores = await _unitOfWork.MedicalStores.FindAsync(
                ms => ms.City != null &&
                      ms.City.Trim().ToLower() == city &&
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
                _logger.LogWarning("AssignedToCustomerSupportByCustomerSupportIdAsync failed: CustomerSupportId is empty");
                throw new ArgumentException("CustomerSupportId is required.", nameof(customerSupportId));
            }

            var orders = await _unitOfWork.Orders.FindAsync(o =>
                o.CustomerSupportId == customerSupportId &&
                o.OrderStatus == OrderStatus.AssignedToCustomerSupport);

            var dtos = _mapper.Map<List<OrderDto>>(orders);
            await EnrichAssigneeNamesAsync(dtos, cancellationToken);
            return dtos;
        }

        public async Task<IEnumerable<OrderDto>> GetAllOrdersByCustomerSupportIdAsync(Guid customerSupportId, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            if (customerSupportId == Guid.Empty)
            {
                _logger.LogWarning("GetAllOrdersByCustomerSupportIdAsync failed: CustomerSupportId is empty");
                throw new ArgumentException("CustomerSupportId is required.", nameof(customerSupportId));
            }

            var orders = await _unitOfWork.Orders.FindAsync(o => o.CustomerSupportId == customerSupportId);

            var dtos = _mapper.Map<List<OrderDto>>(orders);
            await EnrichAssigneeNamesAsync(dtos, cancellationToken);
            return dtos;
        }

        public async Task<IEnumerable<DeliveryDto>> GetEligibleDeliveryBoysByOrderIdAsync(int orderId, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            // Find the order
            var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId);
            if (order == null)
            {
                _logger.LogWarning("GetEligibleDeliveryBoysByOrderIdAsync failed: Order {OrderId} not found", orderId);
                throw new KeyNotFoundException($"Order with ID '{orderId}' not found.");
            }

            // Get customer address to find postal code
            var customerAddress = await _unitOfWork.CustomerAddresses.GetByIdAsync(order.CustomerAddressId);
            if (customerAddress == null)
            {
                _logger.LogWarning("GetEligibleDeliveryBoysByOrderIdAsync failed: Customer address not found for Order {OrderId}", orderId);
                throw new KeyNotFoundException("Customer address not found for this order.");
            }

            if (string.IsNullOrWhiteSpace(customerAddress.PostalCode))
            {
                _logger.LogWarning("GetEligibleDeliveryBoysByOrderIdAsync failed: Customer address missing postal code for Order {OrderId}", orderId);
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

            var orders = (await _unitOfWork.Orders.FindAsync(o => o.DeliveryId == deliveryId)).ToList();
            var dtos = _mapper.Map<List<OrderDto>>(orders);

            // Delivery boys can't read customer records directly (CustomerRead is
            // scoped to their own record), so resolve the customer name here and
            // embed it in the order payload.
            var customerIds = orders.Select(o => o.CustomerId).Distinct().ToList();
            if (customerIds.Count > 0)
            {
                var customers = await _unitOfWork.Customers.FindAsync(c => customerIds.Contains(c.CustomerId));
                var nameByCustomerId = customers.ToDictionary(
                    c => c.CustomerId,
                    c => $"{c.CustomerFirstName} {c.CustomerLastName}".Trim());

                foreach (var dto in dtos)
                {
                    if (nameByCustomerId.TryGetValue(dto.CustomerId, out var name) && !string.IsNullOrWhiteSpace(name))
                    {
                        dto.CustomerName = name;
                    }
                }
            }

            return dtos;
        }

        public async Task<IEnumerable<MedicalStoreBasicDto>> GetMedicalStoresByOrderPinCodeAsync(int orderId, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            // Find the order
            var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId);
            if (order == null)
            {
                _logger.LogWarning("GetMedicalStoresByOrderPinCodeAsync failed: Order {OrderId} not found", orderId);
                throw new KeyNotFoundException($"Order with ID '{orderId}' not found.");
            }

            // Get customer address to find postal code
            var customerAddress = await _unitOfWork.CustomerAddresses.GetByIdAsync(order.CustomerAddressId);
            if (customerAddress == null)
            {
                _logger.LogWarning("GetMedicalStoresByOrderPinCodeAsync failed: Customer address not found for Order {OrderId}", orderId);
                throw new KeyNotFoundException("Customer address not found for this order.");
            }

            if (string.IsNullOrWhiteSpace(customerAddress.PostalCode))
            {
                _logger.LogWarning("GetMedicalStoresByOrderPinCodeAsync failed: Customer address missing postal code for Order {OrderId}", orderId);
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

        public async Task<NearbyChemistResponseDto> GetNearbyChemistsByOrderNumberAsync(string orderNumber, CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();

            var order = await _unitOfWork.Orders.FirstOrDefaultAsync(o => o.OrderNumber == orderNumber);
            if (order == null)
            {
                _logger.LogWarning("GetNearbyChemistsByOrderNumberAsync failed: Order with number '{OrderNumber}' not found", orderNumber);
                throw new KeyNotFoundException($"Order with number '{orderNumber}' not found.");
            }

            var customerAddress = await _unitOfWork.CustomerAddresses.GetByIdAsync(order.CustomerAddressId);
            if (customerAddress == null)
            {
                _logger.LogWarning("GetNearbyChemistsByOrderNumberAsync failed: Customer address not found for Order {OrderNumber}", orderNumber);
                throw new KeyNotFoundException("Customer address not found for this order.");
            }

            var allActiveStores = await _unitOfWork.MedicalStores.FindAsync(
                ms => ms.IsActive && !ms.IsDeleted);

            var result = new List<NearbyChemistDto>();

            // Step 1: Find chemists within 5KM radius using Haversine formula
            if (customerAddress.Latitude.HasValue && customerAddress.Longitude.HasValue)
            {
                foreach (var store in allActiveStores)
                {
                    if (!store.Latitude.HasValue || !store.Longitude.HasValue)
                        continue;

                    var distance = CalculateHaversineDistance(
                        (double)customerAddress.Latitude.Value,
                        (double)customerAddress.Longitude.Value,
                        (double)store.Latitude.Value,
                        (double)store.Longitude.Value);

                    if (distance <= 5.0)
                    {
                        result.Add(MapToNearbyChemistDto(store, ChemistMatchType.Distance, Math.Round(distance, 2)));
                    }
                }
            }

            // Step 2: If fewer than 3 chemists found by distance, also search by postal code
            if (result.Count < 3 && !string.IsNullOrWhiteSpace(customerAddress.PostalCode))
            {
                var postalCode = customerAddress.PostalCode.Trim();
                var existingStoreIds = result.Select(c => c.MedicalStoreId).ToHashSet();

                foreach (var store in allActiveStores)
                {
                    if (existingStoreIds.Contains(store.MedicalStoreId))
                        continue;

                    if (store.PostalCode.Trim() == postalCode)
                    {
                        double? distance = null;
                        if (customerAddress.Latitude.HasValue && customerAddress.Longitude.HasValue
                            && store.Latitude.HasValue && store.Longitude.HasValue)
                        {
                            distance = Math.Round(CalculateHaversineDistance(
                                (double)customerAddress.Latitude.Value,
                                (double)customerAddress.Longitude.Value,
                                (double)store.Latitude.Value,
                                (double)store.Longitude.Value), 2);
                        }

                        result.Add(MapToNearbyChemistDto(store, ChemistMatchType.PostalCode, distance));
                    }
                }
            }

            // Sort: distance-matched first (low to high), then postal code matched
            result = result
                .OrderBy(c => c.MatchType)
                .ThenBy(c => c.DistanceInKm ?? double.MaxValue)
                .ToList();

            return new NearbyChemistResponseDto
            {
                OrderNumber = orderNumber,
                TotalChemists = result.Count,
                Chemists = result
            };
        }

        private static double CalculateHaversineDistance(double lat1, double lon1, double lat2, double lon2)
        {
            const double earthRadiusKm = 6371.0;

            var dLat = DegreesToRadians(lat2 - lat1);
            var dLon = DegreesToRadians(lon2 - lon1);

            var a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2) +
                    Math.Cos(DegreesToRadians(lat1)) * Math.Cos(DegreesToRadians(lat2)) *
                    Math.Sin(dLon / 2) * Math.Sin(dLon / 2);

            var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
            return earthRadiusKm * c;
        }

        private static double DegreesToRadians(double degrees)
        {
            return degrees * Math.PI / 180.0;
        }

        private static NearbyChemistDto MapToNearbyChemistDto(MedicalStore store, ChemistMatchType matchType, double? distanceInKm)
        {
            return new NearbyChemistDto
            {
                MedicalStoreId = store.MedicalStoreId,
                MedicalName = store.MedicalName,
                AddressLine1 = store.AddressLine1,
                AddressLine2 = store.AddressLine2,
                City = store.City,
                State = store.State,
                PostalCode = store.PostalCode,
                Latitude = store.Latitude,
                Longitude = store.Longitude,
                MobileNumber = store.MobileNumber,
                MatchType = matchType,
                DistanceInKm = distanceInKm
            };
        }
    }
}
