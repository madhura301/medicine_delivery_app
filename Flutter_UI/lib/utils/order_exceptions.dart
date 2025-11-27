// lib/utils/order_exceptions.dart

enum OrderErrorType {
  fileTooBig,
  invalidFileType,
  cameraPermissionDenied,
  microphonePermissionDenied,
  locationPermissionDenied,
  networkError,
  validationError,
  uploadFailed,
  unknownError,
}

class OrderException implements Exception {
  final OrderErrorType type;
  final String message;
  final dynamic originalError;
  
  OrderException(
    this.type,
    this.message, {
    this.originalError,
  });
  
  String getUserFriendlyMessage() {
    switch (type) {
      case OrderErrorType.fileTooBig:
        return 'File size exceeds 10 MB limit. Please select a smaller file.';
      case OrderErrorType.invalidFileType:
        return 'Invalid file type. Please upload PDF, JPG, or PNG files only.';
      case OrderErrorType.cameraPermissionDenied:
        return 'Camera permission is required. Please enable it in device settings.';
      case OrderErrorType.microphonePermissionDenied:
        return 'Microphone permission is required. Please enable it in device settings.';
      case OrderErrorType.locationPermissionDenied:
        return 'Location permission is required to detect your address.';
      case OrderErrorType.networkError:
        return 'Network error occurred. Please check your internet connection.';
      case OrderErrorType.validationError:
        return message;
      case OrderErrorType.uploadFailed:
        return 'Failed to upload order. Please try again.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
  
  @override
  String toString() => 'OrderException: ${type.name} - $message';
}

class OrderValidationException extends OrderException {
  OrderValidationException(String message)
      : super(OrderErrorType.validationError, message);
}

class OrderNetworkException extends OrderException {
  OrderNetworkException(String message, {dynamic originalError})
      : super(
          OrderErrorType.networkError,
          message,
          originalError: originalError,
        );
}

class OrderPermissionException extends OrderException {
  OrderPermissionException(OrderErrorType type, String message)
      : super(type, message);
}