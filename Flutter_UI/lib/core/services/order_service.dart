// lib/core/services/order_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:pharmaish/shared/models/order_model.dart';
import 'package:pharmaish/shared/models/order_enums.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/constants.dart';
import 'package:pharmaish/utils/order_exceptions.dart';
import 'package:pharmaish/utils/order_validators.dart';
import 'package:pharmaish/config/environment_config.dart';
import 'package:pharmaish/utils/storage.dart';

class OrderService {
  final Dio _dio;

  OrderService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: EnvironmentConfig.apiBaseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            responseType: ResponseType.json,
            headers: {
              'Content-Type': 'multipart/form-data',
            },
          ),
        ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token
          final token = await StorageService.getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // ADD THIS - Log full URL
          AppLogger.info('🌐 FULL URL: ${options.baseUrl}${options.path}');
          AppLogger.info(
              'Order API Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.info('Order API Response: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (error, handler) {
          AppLogger.error('Order API Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  static Future<Map<String, dynamic>?> getCustomerFromMobileNumber({
    required String mobileNumber,
  }) async {
    try {
      final token = await StorageService.getAuthToken();
      AppLogger.info('Fetching customer by mobile number: $mobileNumber' +
          ' Token: $token');

      // If no token, user is not logged in - return null immediately
      if (token == null) {
        AppLogger.warning('No auth token found - user not logged in');
        return null;
      }

      final response = await http.get(
        Uri.parse(
            '${AppConstants.apiBaseUrl}/Customers/by-mobile/$mobileNumber'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      AppLogger.info(
          'Customers/by-mobile API response status: ${response.statusCode}');

      // Check status code BEFORE parsing JSON
      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.apiResponse(
          response.statusCode,
          '${AppConstants.apiBaseUrl}/Customers/by-mobile/$mobileNumber',
          response.body,
        );

        final responseData = jsonDecode(response.body);
        return responseData; // this is Map<String, dynamic>
      } else if (response.statusCode == 401) {
        // Unauthorized - token expired or invalid
        AppLogger.warning('Unauthorized access - token may be expired');
        // Optionally clear storage here
        await StorageService.clearAll();
        return null;
      } else {
        // Other error status codes
        AppLogger.warning(
            'API returned error status: ${response.statusCode}, Body: ${response.body}');
        return null;
      }
    } catch (e) {
      AppLogger.error('Customers/by-mobile API error : $e');
      return null;
    }
  }

  // static Future<Map<String, dynamic>?> getCustomerFromMobileNumber({
  //   required String mobileNumber,
  // }) async {
  //   try {
  //     final token = await StorageService.getAuthToken();
  //     AppLogger.info('Fetching customer by mobile number: $mobileNumber' +
  //         ' Token: $token');
  //     if (token == null) return null;

  //     final response = await http.get(
  //       Uri.parse(
  //           '${AppConstants.apiBaseUrl}/Customers/by-mobile/$mobileNumber'),
  //       headers: {
  //         'Accept': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );

  //     AppLogger.apiResponse(
  //       response.statusCode,
  //       '${AppConstants.apiBaseUrl}/Customers/by-mobile/$mobileNumber',
  //       response.body,
  //     );

  //     AppLogger.info(
  //         'Customers/by-mobile API response status: ${response.statusCode}');

  //     final responseData = jsonDecode(response.body);

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       return responseData; // this is Map<String, dynamic>
  //     }

  //     return null;
  //   } catch (e) {
  //     AppLogger.error('Customers/by-mobile API error : $e');
  //     return null;
  //   }
  // }

  /// Create a new order
  Future<OrderModel> createOrder(CreateOrderRequest request) async {
    try {
      AppLogger.info('Creating order: $request');

      // Validate request
      await _validateOrderRequest(request);

      // Prepare form data
      //final formData = FormData.fromMap(request.toFormData());
      // Create form data manually
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

      // Add file if present
      if (request.orderInputFile != null) {
        final file = request.orderInputFile!;
        final fileName = path.basename(file.path);

        formData.files.add(
          MapEntry(
            'OrderInputFile',
            await MultipartFile.fromFile(
              file.path,
              filename: fileName,
            ),
          ),
        );

        AppLogger.info('Added file to request: $fileName');
      }

      AppLogger.info('Form data fields: ${formData.fields}');
      AppLogger.info('📋 Form Data Debug:');
      AppLogger.info('OrderType index: ${request.orderType.index}');
      AppLogger.info('OrderType type: ${request.orderType.index.runtimeType}');
      AppLogger.info('OrderInputType index: ${request.orderInputType.index}');
      AppLogger.info(
          'OrderInputType type: ${request.orderInputType.index.runtimeType}');

      // Send request
      final response = await _dio.post(
        '/Orders',
        data: formData,
        options: Options(responseType: ResponseType.json),
        onSendProgress: (sent, total) {
          final progress = (sent / total * 100).toInt();
          AppLogger.info('Upload progress: $progress%');
        },
      );

      AppLogger.apiRequest(
        'POST',
        '/Orders',
        request.toFormData(),
      );
      if (response.statusCode == 201) {
        AppLogger.info('Order created successfully');
        return OrderModel.fromJson(response.data);
      }
      // //For detailed debugging
      // if (response.statusCode == 201) {
      //   AppLogger.info('✅ Order created successfully');

      //   if (response.data is Map<String, dynamic>) {
      //     final data = response.data as Map<String, dynamic>;

      //     AppLogger.info('');
      //     AppLogger.info('🎯 SUSPECT FIELDS TYPE CHECK:');
      //     AppLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      //     // Check the three suspect fields
      //     final suspects = ['shippingPincode', 'status', 'completionOtp'];

      //     for (final field in suspects) {
      //       if (data.containsKey(field)) {
      //         final value = data[field];
      //         final type = value.runtimeType;
      //         final isInt = value is int;
      //         final isString = value is String;

      //         AppLogger.info('');
      //         AppLogger.info('Field: $field');
      //         AppLogger.info('  Value: $value');
      //         AppLogger.info('  Type: $type');
      //         AppLogger.info('  Is int? $isInt ${isInt ? "⚠️ PROBLEM!" : ""}');
      //         AppLogger.info(
      //             '  Is String? $isString ${isString ? "✅ OK" : ""}');

      //         if (isInt) {
      //           AppLogger.error(
      //               '🚨 FOUND IT! $field is an INT but model expects STRING');
      //         }
      //       } else {
      //         AppLogger.info('Field: $field - NOT PRESENT in response');
      //       }
      //     }

      //     AppLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      //   }

      //   // Now try to parse with detailed error catching
      //   try {
      //     final order = OrderModel.fromJson(response.data);
      //     AppLogger.info('✅ Successfully parsed OrderModel');
      //     return order;
      //   } catch (e, stackTrace) {
      //     AppLogger.error('❌ FAILED to parse OrderModel');
      //     AppLogger.error('Error: $e');
      //     AppLogger.error('StackTrace: $stackTrace');
      //     rethrow;
      //   }
      // } 
      else {
        throw OrderNetworkException(
          'Unexpected status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Dio error creating order: ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      AppLogger.error('Error creating order: $e');
      throw OrderException(
        OrderErrorType.unknownError,
        'Failed to create order: $e',
        originalError: e,
      );
    }
  }

  /// Validate order request before submission
  Future<void> _validateOrderRequest(CreateOrderRequest request) async {
    // Validate based on input type
    switch (request.orderInputType) {
      case OrderInputType.image:
        if (request.orderInputFile == null) {
          throw OrderValidationException('File is required for image orders');
        }

        final validationResult = await OrderValidators.validateFile(
          request.orderInputFile!,
          isAudio: false,
        );

        if (!validationResult.isValid) {
          throw OrderValidationException(
            validationResult.errorMessage ?? 'Invalid file',
          );
        }
        break;

      case OrderInputType.voice:
        if (request.orderInputFile == null) {
          throw OrderValidationException(
              'Audio file is required for voice orders');
        }

        final validationResult = await OrderValidators.validateFile(
          request.orderInputFile!,
          isAudio: true,
        );

        if (!validationResult.isValid) {
          throw OrderValidationException(
            validationResult.errorMessage ?? 'Invalid audio file',
          );
        }
        break;

      case OrderInputType.text:
        if (request.orderInputText == null || request.orderInputText!.isEmpty) {
          throw OrderValidationException('Text is required for text orders');
        }

        final validationResult = OrderValidators.validateText(
          request.orderInputText!,
        );

        if (!validationResult.isValid) {
          throw OrderValidationException(
            validationResult.errorMessage ?? 'Invalid text',
          );
        }
        break;
    }

    // Validate address ID
    if (request.customerAddressId.isEmpty) {
      throw OrderValidationException('Delivery address is required');
    }
  }

  /// Handle Dio errors
  OrderException _handleDioError(DioException error) {
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

        if (statusCode == 400) {
          return OrderValidationException(message);
        } else if (statusCode == 401) {
          return OrderNetworkException('Unauthorized. Please login again.');
        } else if (statusCode == 404) {
          return OrderNetworkException('Order endpoint not found.');
        } else {
          return OrderNetworkException(
            'Server error ($statusCode): $message',
            originalError: error,
          );
        }

      case DioExceptionType.cancel:
        return OrderNetworkException('Request was cancelled.');

      default:
        return OrderNetworkException(
          'Network error occurred. Please try again.',
          originalError: error,
        );
    }
  }

  /// Get order by ID
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final response = await _dio.get('/api/Orders/$orderId');
      return OrderModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get customer orders
  Future<List<OrderModel>> getCustomerOrders(String customerId) async {
    try {
      final response = await _dio.get('/api/Orders/customer/$customerId');
      final List<dynamic> data = response.data;
      return data.map((json) => OrderModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
}
