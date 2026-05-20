import 'package:dio/dio.dart';

import 'app_logger.dart';

/// Resolves a `userId` to its role-specific entity (Customer, CustomerSupport,
/// or MedicalStore) and deletes it via the matching backend endpoint.
///
/// Used by admin user management to delete a user's role-specific record after
/// (or in lieu of) removing the underlying account.
///
/// All methods throw a descriptive [Exception] on failure (404 → not found,
/// 403 → permission denied, etc.) so the UI can display the message directly.
class RoleEntityManager {
  final Dio _dio;

  RoleEntityManager(this._dio);

  /// DELETE /Customers/{customerId} after looking up by [userId].
  Future<bool> deleteCustomerByUserId(String userId) =>
      _deleteByUserId(
        entityName: 'Customer',
        listEndpoint: '/Customers',
        deleteEndpointBuilder: (id) => '/Customers/$id',
        userId: userId,
        idField: 'customerId',
      );

  /// DELETE /CustomerSupports/{customerSupportId} after looking up by [userId].
  Future<bool> deleteCustomerSupportByUserId(String userId) =>
      _deleteByUserId(
        entityName: 'CustomerSupport',
        listEndpoint: '/CustomerSupports',
        deleteEndpointBuilder: (id) => '/CustomerSupports/$id',
        userId: userId,
        idField: 'customerSupportId',
      );

  /// DELETE /MedicalStores/{medicalStoreId} after looking up by [userId].
  Future<bool> deleteMedicalStoreByUserId(String userId) =>
      _deleteByUserId(
        entityName: 'MedicalStore',
        listEndpoint: '/MedicalStores',
        deleteEndpointBuilder: (id) => '/MedicalStores/$id',
        userId: userId,
        idField: 'medicalStoreId',
      );

  Future<bool> _deleteByUserId({
    required String entityName,
    required String listEndpoint,
    required String Function(dynamic id) deleteEndpointBuilder,
    required String userId,
    required String idField,
  }) async {
    try {
      AppLogger.info('Deleting $entityName for userId=$userId');

      // Fetch list and find the entity matching userId.
      final listResp = await _dio.get(listEndpoint);
      if (listResp.statusCode != 200) {
        throw Exception('Failed to load $entityName list');
      }
      final entity = (listResp.data as List).firstWhere(
        (e) => e['userId'] == userId,
        orElse: () => null,
      );
      if (entity == null) {
        throw Exception('$entityName not found');
      }

      final id = entity[idField];
      if (id == null) {
        throw Exception('$entityName missing $idField');
      }

      final deleteResp = await _dio.delete(deleteEndpointBuilder(id));
      if (deleteResp.statusCode == 204 || deleteResp.statusCode == 200) {
        AppLogger.info('$entityName $id deleted');
        return true;
      }

      AppLogger.warning(
          '$entityName delete returned unexpected ${deleteResp.statusCode}');
      return false;
    } on DioException catch (e) {
      AppLogger.error(
          '$entityName delete failed: ${e.response?.statusCode} ${e.response?.data}');
      throw _humanizeError(entityName, e);
    }
  }

  Exception _humanizeError(String entityName, DioException e) {
    switch (e.response?.statusCode) {
      case 404:
        return Exception(
            '$entityName not found (404). It may have already been deleted.');
      case 403:
        return Exception(
            'Permission denied (403). You do not have permission to delete $entityName.');
      case 401:
        return Exception(
            'Unauthorized (401). Your session may have expired. Please log in again.');
      case 500:
        final msg = e.response?.data?['error'] ??
            e.response?.data ??
            'Server error occurred';
        return Exception('Server error (500): $msg');
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(
            'Network timeout. Please check your connection and try again.');
      case DioExceptionType.connectionError:
        return Exception(
            'Network connection error. Please check your internet connection.');
      default:
        return Exception(
            'Failed to delete $entityName: ${e.message ?? "unknown error"}');
    }
  }
}
