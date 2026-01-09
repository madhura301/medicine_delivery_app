// ============================================================================
// FIXED: RoleEntityManager with Proper Delete Error Handling
// ============================================================================

import 'package:dio/dio.dart';
import '../utils/app_logger.dart';

class RoleEntityManager {
  final Dio _dio;

  RoleEntityManager(this._dio);

  // =========================================================================
  // CUSTOMER OPERATIONS
  // =========================================================================

  Future<Map<String, dynamic>?> getCustomerByUserId(String userId) async {
    try {
      AppLogger.info('Fetching customer for UserId: $userId');
      
      final response = await _dio.get('/Customers');
      
      if (response.statusCode == 200) {
        final customers = response.data as List;
        
        final customer = customers.firstWhere(
          (c) => c['userId'] == userId,
          orElse: () => null,
        );
        
        if (customer != null) {
          AppLogger.info('Customer found: ${customer['customerId']}');
          return customer;
        } else {
          AppLogger.warning('No customer found for UserId: $userId');
          return null;
        }
      }
    } on DioException catch (e) {
      AppLogger.error('Error fetching customers: ${e.response?.data}');
      rethrow;
    }
    return null;
  }

  Future<Map<String, dynamic>?> updateCustomerByUserId(
    String userId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final customer = await getCustomerByUserId(userId);
      
      if (customer == null) {
        AppLogger.error('Customer not found for UserId: $userId');
        throw Exception('Customer not found');
      }
      
      final customerId = customer['customerId'];
      
      AppLogger.info('Updating customer: $customerId');
      
      final response = await _dio.put(
        '/Customers/$customerId',
        data: updateData,
      );
      
      if (response.statusCode == 200) {
        AppLogger.info('Customer updated successfully');
        return response.data;
      }
    } on DioException catch (e) {
      AppLogger.error('Error updating customer: ${e.response?.data}');
      rethrow;
    }
    return null;
  }

  Future<bool> deleteCustomerByUserId(String userId) async {
    try {
      AppLogger.info('=== DELETE CUSTOMER START ===');
      AppLogger.info('UserId: $userId');
      
      // Step 1: Get customer to find CustomerId
      final customer = await getCustomerByUserId(userId);
      
      if (customer == null) {
        AppLogger.error('Customer not found for UserId: $userId');
        throw Exception('Customer not found');
      }
      
      final customerId = customer['customerId'];
      AppLogger.info('CustomerId: $customerId');
      
      // Step 2: Delete using CustomerId
      AppLogger.info('Calling DELETE /Customers/$customerId');
      
      final response = await _dio.delete('/Customers/$customerId');
      
      AppLogger.info('Delete response status: ${response.statusCode}');
      AppLogger.info('Delete response data: ${response.data}');
      
      // Backend returns 204 No Content on successful delete
      if (response.statusCode == 204) {
        AppLogger.info('✅ Customer deleted successfully');
        return true;
      } else {
        AppLogger.warning('⚠️ Unexpected status code: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      AppLogger.error('❌ DioException during delete');
      AppLogger.error('Status Code: ${e.response?.statusCode}');
      AppLogger.error('Response Data: ${e.response?.data}');
      AppLogger.error('Error Message: ${e.message}');
      
      // Handle specific error cases
      if (e.response?.statusCode == 404) {
        throw Exception('Customer not found');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Permission denied: You do not have permission to delete this customer');
      } else if (e.response?.statusCode == 500) {
        final errorMsg = e.response?.data?['error'] ?? 'Server error occurred';
        throw Exception('Server error: $errorMsg');
      } else {
        throw Exception('Failed to delete customer: ${e.message}');
      }
    } catch (e) {
      AppLogger.error('❌ Unexpected error during delete: $e');
      rethrow;
    }
  }

  // =========================================================================
  // CUSTOMER SUPPORT OPERATIONS
  // =========================================================================

  Future<Map<String, dynamic>?> getCustomerSupportByUserId(String userId) async {
    try {
      AppLogger.info('Fetching CustomerSupport for UserId: $userId');
      
      final response = await _dio.get('/CustomerSupports');
      
      if (response.statusCode == 200) {
        final supports = response.data as List;
        
        final support = supports.firstWhere(
          (s) => s['userId'] == userId,
          orElse: () => null,
        );
        
        if (support != null) {
          AppLogger.info('CustomerSupport found: ${support['customerSupportId']}');
          return support;
        } else {
          AppLogger.warning('No CustomerSupport found for UserId: $userId');
          return null;
        }
      }
    } on DioException catch (e) {
      AppLogger.error('Error fetching CustomerSupports: ${e.response?.data}');
      rethrow;
    }
    return null;
  }

  Future<Map<String, dynamic>?> updateCustomerSupportByUserId(
    String userId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final support = await getCustomerSupportByUserId(userId);
      
      if (support == null) {
        throw Exception('CustomerSupport not found');
      }
      
      final supportId = support['customerSupportId'];
      
      AppLogger.info('Updating CustomerSupport: $supportId');
      
      final response = await _dio.put(
        '/CustomerSupports/$supportId',
        data: updateData,
      );
      
      if (response.statusCode == 200) {
        AppLogger.info('CustomerSupport updated successfully');
        return response.data;
      }
    } on DioException catch (e) {
      AppLogger.error('Error updating CustomerSupport: ${e.response?.data}');
      rethrow;
    }
    return null;
  }
Future<bool> deleteCustomerSupportByUserId(String userId) async {
  try {
    AppLogger.info('=== DELETE CUSTOMER SUPPORT START ===');
    AppLogger.info('UserId: $userId');
    
    // Step 1: Fetch the CustomerSupport
    AppLogger.info('STEP 1: Fetching CustomerSupport...');
    final support = await getCustomerSupportByUserId(userId);
    
    if (support == null) {
      AppLogger.error('❌ STEP 1 FAILED: CustomerSupport not found for UserId: $userId');
      throw Exception('Customer support not found');
    }
    
    AppLogger.info('✅ STEP 1 SUCCESS: CustomerSupport found');
    
    // Step 2: Extract CustomerSupportId
    final supportId = support['customerSupportId'];
    if (supportId == null) {
      AppLogger.error('❌ STEP 2 FAILED: customerSupportId is null in response');
      AppLogger.error('Support object: $support');
      throw Exception('CustomerSupportId not found in response');
    }
    
    AppLogger.info('✅ STEP 2 SUCCESS: CustomerSupportId: $supportId');
    
    // Step 3: Make DELETE request
    AppLogger.info('STEP 3: Making DELETE request...');
    AppLogger.info('DELETE URL: /CustomerSupports/$supportId');
    
    final response = await _dio.delete('/CustomerSupports/$supportId');
    
    AppLogger.info('✅ STEP 3 COMPLETE: Delete response received');
    AppLogger.info('Response status: ${response.statusCode}');
    AppLogger.info('Response data: ${response.data}');
    
    // Step 4: Check response
    if (response.statusCode == 204 || response.statusCode == 200) {
      AppLogger.info('✅ STEP 4 SUCCESS: CustomerSupport deleted successfully');
      return true;
    } else {
      AppLogger.warning('⚠️ STEP 4 WARNING: Unexpected status code: ${response.statusCode}');
      throw Exception('Delete failed with status: ${response.statusCode}');
    }
    
  } on DioException catch (e) {
    AppLogger.error('❌ DioException during delete');
    AppLogger.error('Error Type: ${e.type}');
    AppLogger.error('Status Code: ${e.response?.statusCode}');
    AppLogger.error('Response Data: ${e.response?.data}');
    AppLogger.error('Error Message: ${e.message}');
    AppLogger.error('Request Path: ${e.requestOptions.path}');
    AppLogger.error('Request Method: ${e.requestOptions.method}');
    
    if (e.response?.statusCode == 404) {
      throw Exception('Customer support not found (404). It may have already been deleted.');
    } else if (e.response?.statusCode == 403) {
      throw Exception('Permission denied (403). You do not have permission to delete customer support users.');
    } else if (e.response?.statusCode == 401) {
      throw Exception('Unauthorized (401). Your session may have expired. Please log in again.');
    } else if (e.response?.statusCode == 500) {
      final errorMsg = e.response?.data?['error'] ?? e.response?.data ?? 'Server error occurred';
      throw Exception('Server error (500): $errorMsg');
    } else if (e.type == DioExceptionType.connectionTimeout) {
      throw Exception('Connection timeout. Please check your network connection.');
    } else if (e.type == DioExceptionType.receiveTimeout) {
      throw Exception('Server response timeout. Please try again.');
    } else if (e.type == DioExceptionType.connectionError) {
      throw Exception('Network connection error. Please check your internet connection.');
    } else {
      throw Exception('Failed to delete: ${e.message ?? "Unknown error (${e.response?.statusCode})"}');
    }
  } catch (e) {
    AppLogger.error('❌ Unexpected error during delete: $e');
    AppLogger.error('Error type: ${e.runtimeType}');
    rethrow;
  }
}
  // =========================================================================
  // MEDICAL STORE (CHEMIST) OPERATIONS
  // =========================================================================

  Future<Map<String, dynamic>?> getMedicalStoreByUserId(String userId) async {
    try {
      AppLogger.info('Fetching MedicalStore for UserId: $userId');
      
      final response = await _dio.get('/MedicalStores');
      
      if (response.statusCode == 200) {
        final stores = response.data as List;
        
        final store = stores.firstWhere(
          (s) => s['userId'] == userId,
          orElse: () => null,
        );
        
        if (store != null) {
          AppLogger.info('MedicalStore found: ${store['medicalStoreId']}');
          return store;
        } else {
          AppLogger.warning('No MedicalStore found for UserId: $userId');
          return null;
        }
      }
    } on DioException catch (e) {
      AppLogger.error('Error fetching MedicalStores: ${e.response?.data}');
      rethrow;
    }
    return null;
  }

  Future<Map<String, dynamic>?> updateMedicalStoreByUserId(
    String userId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final store = await getMedicalStoreByUserId(userId);
      
      if (store == null) {
        throw Exception('MedicalStore not found');
      }
      
      final storeId = store['medicalStoreId'];
      
      AppLogger.info('Updating MedicalStore: $storeId');
      
      final response = await _dio.put(
        '/MedicalStores/$storeId',
        data: updateData,
      );
      
      if (response.statusCode == 200) {
        AppLogger.info('MedicalStore updated successfully');
        return response.data;
      }
    } on DioException catch (e) {
      AppLogger.error('Error updating MedicalStore: ${e.response?.data}');
      rethrow;
    }
    return null;
  }

  Future<bool> deleteMedicalStoreByUserId(String userId) async {
    try {
      AppLogger.info('=== DELETE MEDICAL STORE START ===');
      AppLogger.info('UserId: $userId');
      
      final store = await getMedicalStoreByUserId(userId);
      
      if (store == null) {
        AppLogger.error('MedicalStore not found for UserId: $userId');
        throw Exception('Medical store not found');
      }
      
      final storeId = store['medicalStoreId'];
      AppLogger.info('MedicalStoreId: $storeId');
      
      AppLogger.info('Calling DELETE /MedicalStores/$storeId');
      
      final response = await _dio.delete('/MedicalStores/$storeId');
      
      AppLogger.info('Delete response status: ${response.statusCode}');
      
      if (response.statusCode == 204) {
        AppLogger.info('✅ MedicalStore deleted successfully');
        return true;
      } else {
        AppLogger.warning('⚠️ Unexpected status code: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      AppLogger.error('❌ DioException during delete');
      AppLogger.error('Status Code: ${e.response?.statusCode}');
      AppLogger.error('Response Data: ${e.response?.data}');
      
      if (e.response?.statusCode == 404) {
        throw Exception('Medical store not found');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Permission denied');
      } else if (e.response?.statusCode == 500) {
        final errorMsg = e.response?.data?['error'] ?? 'Server error occurred';
        throw Exception('Server error: $errorMsg');
      } else {
        throw Exception('Failed to delete: ${e.message}');
      }
    }
  }

  // =========================================================================
  // GENERIC OPERATIONS
  // =========================================================================

  Future<Map<String, dynamic>?> getByUserId(
    String entityType,
    String userId, {
    String userIdField = 'userId',
    String? idField,
  }) async {
    try {
      AppLogger.info('Fetching $entityType for UserId: $userId');
      
      final response = await _dio.get('/$entityType');
      
      if (response.statusCode == 200) {
        final entities = response.data as List;
        
        final entity = entities.firstWhere(
          (e) => e[userIdField] == userId,
          orElse: () => null,
        );
        
        if (entity != null) {
          final id = idField != null ? entity[idField] : entity['id'];
          AppLogger.info('$entityType found: $id');
          return entity;
        } else {
          AppLogger.warning('No $entityType found for UserId: $userId');
          return null;
        }
      }
    } on DioException catch (e) {
      AppLogger.error('Error fetching $entityType: ${e.response?.data}');
      rethrow;
    }
    return null;
  }

  Future<Map<String, dynamic>?> updateByUserId(
    String entityType,
    String userId,
    Map<String, dynamic> updateData, {
    String userIdField = 'userId',
    String? idField,
  }) async {
    try {
      final entity = await getByUserId(
        entityType,
        userId,
        userIdField: userIdField,
        idField: idField,
      );
      
      if (entity == null) {
        throw Exception('$entityType not found');
      }
      
      final id = idField != null ? entity[idField] : entity['id'];
      
      AppLogger.info('Updating $entityType: $id');
      
      final response = await _dio.put(
        '/$entityType/$id',
        data: updateData,
      );
      
      if (response.statusCode == 200) {
        AppLogger.info('$entityType updated successfully');
        return response.data;
      }
    } on DioException catch (e) {
      AppLogger.error('Error updating $entityType: ${e.response?.data}');
      rethrow;
    }
    return null;
  }

  Future<bool> deleteByUserId(
    String entityType,
    String userId, {
    String userIdField = 'userId',
    String? idField,
  }) async {
    try {
      AppLogger.info('=== DELETE $entityType START ===');
      AppLogger.info('UserId: $userId');
      
      final entity = await getByUserId(
        entityType,
        userId,
        userIdField: userIdField,
        idField: idField,
      );
      
      if (entity == null) {
        AppLogger.error('$entityType not found for UserId: $userId');
        throw Exception('$entityType not found');
      }
      
      final id = idField != null ? entity[idField] : entity['id'];
      AppLogger.info('${entityType}Id: $id');
      
      AppLogger.info('Calling DELETE /$entityType/$id');
      
      final response = await _dio.delete('/$entityType/$id');
      
      AppLogger.info('Delete response status: ${response.statusCode}');
      AppLogger.info('Delete response data: ${response.data}');
      
      if (response.statusCode == 204) {
        AppLogger.info('✅ $entityType deleted successfully');
        return true;
      } else {
        AppLogger.warning('⚠️ Unexpected status code: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      AppLogger.error('❌ DioException during delete $entityType');
      AppLogger.error('Status Code: ${e.response?.statusCode}');
      AppLogger.error('Response Data: ${e.response?.data}');
      AppLogger.error('Error Message: ${e.message}');
      
      if (e.response?.statusCode == 404) {
        throw Exception('$entityType not found');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Permission denied');
      } else if (e.response?.statusCode == 500) {
        final errorMsg = e.response?.data?['error'] ?? 'Server error occurred';
        throw Exception('Server error: $errorMsg');
      } else {
        throw Exception('Failed to delete $entityType: ${e.message}');
      }
    } catch (e) {
      AppLogger.error('❌ Unexpected error during delete: $e');
      rethrow;
    }
  }
}