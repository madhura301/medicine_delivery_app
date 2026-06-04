import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:pharmaish/core/services/dio_client.dart';
import 'package:pharmaish/shared/models/order_enums.dart';
import 'package:pharmaish/shared/models/order_model.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/order_exceptions.dart';
import 'package:pharmaish/utils/order_validators.dart';

/// Backend API for orders.
///
/// All methods throw [DioException] on transport/HTTP failure. Callers
/// retain responsibility for status-code-specific UX (e.g. 401 → re-login).
class OrderService {
  OrderService._();

  static Dio get _dio => DioClient.instance;

  /// GET /Orders — full list (admin views).
  static Future<List<dynamic>> getAllOrders() async {
    final response = await _dio.get('/Orders');
    final data = response.data;
    if (data is List) return data;
    if (data is Map && data.containsKey('data')) return data['data'] as List;
    if (data is Map && data.containsKey('orders')) return data['orders'] as List;
    return <dynamic>[];
  }

  /// GET /Orders/{orderId} — raw JSON (caller parses with OrderModel.fromJson).
  static Future<Map<String, dynamic>> getOrderById(String orderId) async {
    final response = await _dio.get('/Orders/$orderId');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// GET /Orders/medicalstore/{storeId} — orders for a specific medical store.
  static Future<List<dynamic>> getOrdersForMedicalStore(String storeId) async {
    final response = await _dio.get('/Orders/medicalstore/$storeId');
    final data = response.data;
    if (data is List) return data;
    if (data is Map && data.containsKey('data')) return data['data'] as List;
    if (data is Map && data.containsKey('orders')) return data['orders'] as List;
    return <dynamic>[];
  }

  /// GET /Orders/customer/{customerId} — orders for a specific customer.
  static Future<List<dynamic>> getOrdersForCustomer(String customerId) async {
    final response = await _dio.get('/Orders/customer/$customerId');
    final data = response.data;
    if (data is List) return data;
    if (data is Map && data.containsKey('data')) return data['data'] as List;
    if (data is Map && data.containsKey('orders')) return data['orders'] as List;
    return <dynamic>[];
  }

  /// PUT /Orders/{orderId}/accept — chemist accepts an order.
  static Future<void> acceptOrder(String orderId) async {
    await _dio.put('/Orders/$orderId/accept');
  }

  /// PUT /Orders/{orderId}/reject — chemist rejects an order with a note.
  static Future<void> rejectOrder({
    required String orderId,
    required String rejectNote,
  }) async {
    await _dio.put('/Orders/$orderId/reject', data: {
      'RejectNote': rejectNote,
    });
  }

  /// POST /Orders/{orderId}/upload-bill — chemist uploads a bill (multipart).
  static Future<void> uploadBill({
    required String orderId,
    required FormData formData,
  }) async {
    await _dio.post(
      '/Orders/$orderId/upload-bill',
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );
  }

  /// POST /Orders/assign-to-delivery — chemist assigns an order to a delivery boy.
  static Future<void> assignToDelivery({
    required String orderId,
    required int deliveryId,
  }) async {
    await _dio.post('/Orders/assign-to-delivery', data: {
      'OrderId': orderId,
      'DeliveryId': deliveryId,
    });
  }

  /// PUT /Orders/{orderId}/complete — delivery boy completes delivery with OTP.
  static Future<void> completeDelivery({
    required String orderId,
    required String otp,
  }) async {
    await _dio.put('/Orders/$orderId/complete', data: {'OTP': otp});
  }

  /// POST /Orders — create a new order with prescription file/text/voice.
  ///
  /// Validates the request before sending. Throws
  /// [OrderValidationException] for client-side validation failures and
  /// [OrderNetworkException] / [OrderException] for transport / server errors.
  static Future<OrderModel> createOrder(CreateOrderRequest request) async {
    try {
      AppLogger.info('Creating order: $request');

      await _validateOrderRequest(request);

      final formData = FormData();
      formData.fields.add(MapEntry('CustomerId', request.customerId));
      formData.fields
          .add(MapEntry('CustomerAddressId', request.customerAddressId));
      formData.fields
          .add(MapEntry('OrderType', request.orderType.index.toString()));
      formData.fields.add(
          MapEntry('OrderInputType', request.orderInputType.index.toString()));

      if (request.orderInputText != null &&
          request.orderInputText!.isNotEmpty) {
        formData.fields
            .add(MapEntry('OrderInputText', request.orderInputText!));
      }

      if (request.orderInputFile != null) {
        final file = request.orderInputFile!;
        final fileName = path.basename(file.path);
        formData.files.add(
          MapEntry(
            'OrderInputFile',
            await MultipartFile.fromFile(file.path, filename: fileName),
          ),
        );
        AppLogger.info('Added file to request: $fileName');
      }

      final response = await _dio.post(
        '/Orders',
        data: formData,
        options: Options(responseType: ResponseType.json),
        onSendProgress: (sent, total) {
          final progress = (sent / total * 100).toInt();
          AppLogger.info('Upload progress: $progress%');
        },
      );

      AppLogger.apiRequest('POST', '/Orders', request.toFormData());
      if (response.statusCode == 201) {
        AppLogger.info('Request Shared with Nearby Licensed Pharmacies');
        return OrderModel.fromJson(response.data);
      }
      throw OrderNetworkException(
        'Unexpected status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      AppLogger.error('Dio error creating order: ${e.message}');
      throw _handleDioError(e);
    } on OrderException {
      rethrow;
    } catch (e) {
      AppLogger.error('Error creating order: $e');
      throw OrderException(
        OrderErrorType.unknownError,
        'Failed to create order: $e',
        originalError: e,
      );
    }
  }

  static Future<void> _validateOrderRequest(CreateOrderRequest request) async {
    switch (request.orderInputType) {
      case OrderInputType.image:
        if (request.orderInputFile == null) {
          throw OrderValidationException('File is required for image orders');
        }
        final result = await OrderValidators.validateFile(
          request.orderInputFile!,
          isAudio: false,
        );
        if (!result.isValid) {
          throw OrderValidationException(
              result.errorMessage ?? 'Invalid file');
        }
        break;
      case OrderInputType.voice:
        if (request.orderInputFile == null) {
          throw OrderValidationException(
              'Audio file is required for voice orders');
        }
        final result = await OrderValidators.validateFile(
          request.orderInputFile!,
          isAudio: true,
        );
        if (!result.isValid) {
          throw OrderValidationException(
              result.errorMessage ?? 'Invalid audio file');
        }
        break;
      case OrderInputType.text:
        if (request.orderInputText == null || request.orderInputText!.isEmpty) {
          throw OrderValidationException('Text is required for text orders');
        }
        final result = OrderValidators.validateText(request.orderInputText!);
        if (!result.isValid) {
          throw OrderValidationException(
              result.errorMessage ?? 'Invalid text');
        }
        break;
    }

    if (request.customerAddressId.isEmpty) {
      throw OrderValidationException('Delivery address is required');
    }
  }

  static OrderException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return OrderNetworkException(
          'Connection timeout. Please check your internet connection.',
          originalError: error,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ??
            error.response?.data?['error'] ??
            'Server error occurred';
        if (statusCode == 400) return OrderValidationException(message);
        if (statusCode == 401) {
          return OrderNetworkException('Unauthorized. Please login again.');
        }
        if (statusCode == 404) {
          return OrderNetworkException('Order endpoint not found.');
        }
        return OrderNetworkException(
          'Server error ($statusCode): $message',
          originalError: error,
        );
      case DioExceptionType.cancel:
        return OrderNetworkException('Request was cancelled.');
      default:
        return OrderNetworkException(
          'Network error occurred. Please try again.',
          originalError: error,
        );
    }
  }

}
