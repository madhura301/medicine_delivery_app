import 'package:dio/dio.dart';
import 'package:pharmaish/core/services/dio_client.dart';

/// Backend API for service-region administration.
///
/// Throws [DioException] on transport/HTTP errors. Callers must handle
/// status-code-specific UX (e.g. 403 → permission denied banner).
class RegionService {
  RegionService._();

  static Dio get _dio => DioClient.instance;

  /// GET /ServiceRegions
  static Future<List<Map<String, dynamic>>> getRegions() async {
    final response = await _dio.get('/ServiceRegions');
    final data = response.data;
    if (data is! List) return <Map<String, dynamic>>[];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// GET /ServiceRegions/{regionId}/pincodes
  static Future<List<String>> getRegionPincodes(int regionId) async {
    final response = await _dio.get('/ServiceRegions/$regionId/pincodes');
    final data = response.data;
    if (data is! List) return <String>[];
    return data.map((e) => e.toString()).toList();
  }

  /// POST /ServiceRegions
  static Future<void> createRegion({
    required String name,
    required String city,
    required String regionName,
    required int regionType,
    required List<String> pinCodes,
  }) async {
    await _dio.post('/ServiceRegions', data: {
      'name': name,
      'city': city,
      'regionName': regionName,
      'regionType': regionType,
      'pinCodes': pinCodes,
    });
  }

  /// PUT /ServiceRegions/{regionId}
  static Future<void> updateRegion({
    required int regionId,
    required String name,
    required String city,
    required String regionName,
  }) async {
    await _dio.put('/ServiceRegions/$regionId', data: {
      'name': name,
      'city': city,
      'regionName': regionName,
    });
  }

  /// POST /ServiceRegions/add-pincode
  static Future<void> addPincodeToRegion({
    required int regionId,
    required String pinCode,
  }) async {
    await _dio.post('/ServiceRegions/add-pincode', data: {
      'ServiceRegionId': regionId,
      'PinCode': pinCode,
    });
  }

  /// POST /ServiceRegions/remove-pincode
  static Future<void> removePincodeFromRegion({
    required int regionId,
    required String pinCode,
  }) async {
    await _dio.post('/ServiceRegions/remove-pincode', data: {
      'ServiceRegionId': regionId,
      'PinCode': pinCode,
    });
  }

  /// GET /CustomerSupports — filtered to active and non-deleted only.
  static Future<List<Map<String, dynamic>>> getActiveCustomerSupports() async {
    final response = await _dio.get('/CustomerSupports');
    final data = response.data;
    if (data is! List) return <Map<String, dynamic>>[];
    return data
        .map((e) => Map<String, dynamic>.from(e as Map))
        .where((cs) => (cs['isActive'] ?? false) && !(cs['isDeleted'] ?? false))
        .toList();
  }

  /// GET /Deliveries
  static Future<List<Map<String, dynamic>>> getDeliveryBoys() async {
    final response = await _dio.get('/Deliveries');
    final data = response.data;
    if (data is! List) return <Map<String, dynamic>>[];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// POST /ServiceRegions/assign — assign customer support to a region.
  /// Pass [regionId] = null to unassign.
  static Future<void> assignCustomerSupportToRegion({
    required int? regionId,
    required String customerSupportId,
  }) async {
    await _dio.post('/ServiceRegions/assign', data: {
      'ServiceRegionId': regionId,
      'CustomerSupportId': customerSupportId,
    });
  }

  /// GET /ServiceRegions/by-pincode/{pincode} — find a region serving the given pincode.
  /// Throws [DioException] with status 404 when no region matches.
  static Future<Map<String, dynamic>> lookupRegionByPincode(
      String pincode) async {
    final response = await _dio.get('/ServiceRegions/by-pincode/$pincode');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// DELETE /CustomerSupportRegions/{regionId} — delete a service region.
  /// NOTE: endpoint path is `/CustomerSupportRegions/...` (legacy), not
  /// `/ServiceRegions/...`. Preserve as-is until backend confirms.
  static Future<void> deleteRegion(int regionId) async {
    await _dio.delete('/CustomerSupportRegions/$regionId');
  }

  /// POST /ServiceRegions/assign-delivery — set delivery boy's service region.
  /// Pass [serviceRegionId] = null to unassign.
  ///
  /// [deliveryId] is the integer `id` of the Delivery record (DeliveryDto.id),
  /// not the delivery boy's user GUID.
  static Future<void> setDeliveryBoyServiceRegion({
    required int deliveryId,
    required int? serviceRegionId,
  }) async {
    await _dio.post('/ServiceRegions/assign-delivery', data: {
      'ServiceRegionId': serviceRegionId,
      'DeliveryId': deliveryId,
    });
  }
}
