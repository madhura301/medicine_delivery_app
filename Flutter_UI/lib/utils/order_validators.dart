// lib/utils/order_validators.dart

import 'dart:io';

class OrderValidators {
  // File size limit: 10 MB
  static const int maxFileSizeBytes = 10 * 1024 * 1024;
  
  // Voice recording limits
  static const int minRecordingDurationSeconds = 1;
  static const int maxRecordingDurationSeconds = 120; // 2 minutes
  
  // Text limits
  static const int maxTextLength = 5000;
  static const int minTextLength = 1;
  
  // Image dimensions
  static const int minImageWidth = 800;
  static const int minImageHeight = 600;
  
  // Supported extensions
  static const List<String> supportedImageExtensions = ['jpg', 'jpeg', 'png'];
  static const List<String> supportedDocumentExtensions = ['pdf'];
  static const List<String> supportedAudioExtensions = ['m4a', 'mp4', 'aac', 'wav'];
  
  /// Validate file size
  static bool isFileSizeValid(int sizeInBytes) {
    return sizeInBytes <= maxFileSizeBytes;
  }
  
  /// Get file size in MB
  static double getFileSizeInMB(int sizeInBytes) {
    return sizeInBytes / (1024 * 1024);
  }
  
  /// Validate file extension
  static bool isFileExtensionValid(String extension, {bool isAudio = false}) {
    final ext = extension.toLowerCase().replaceAll('.', '');
    
    if (isAudio) {
      return supportedAudioExtensions.contains(ext);
    }
    
    return supportedImageExtensions.contains(ext) ||
           supportedDocumentExtensions.contains(ext);
  }
  
  /// Validate complete file
  static Future<FileValidationResult> validateFile(
    File file, {
    bool isAudio = false,
  }) async {
    try {
      // Check if file exists
      if (!await file.exists()) {
        return FileValidationResult(
          isValid: false,
          errorMessage: 'File does not exist',
        );
      }
      
      // Get file size
      final fileSize = await file.length();
      
      // Check size
      if (!isFileSizeValid(fileSize)) {
        return FileValidationResult(
          isValid: false,
          errorMessage: 'File size (${getFileSizeInMB(fileSize).toStringAsFixed(2)} MB) '
              'exceeds maximum allowed size (10 MB)',
        );
      }
      
      // Get extension
      final extension = file.path.split('.').last;
      
      // Check extension
      if (!isFileExtensionValid(extension, isAudio: isAudio)) {
        return FileValidationResult(
          isValid: false,
          errorMessage: 'Unsupported file type: .$extension',
        );
      }
      
      return FileValidationResult(isValid: true);
      
    } catch (e) {
      return FileValidationResult(
        isValid: false,
        errorMessage: 'Error validating file: $e',
      );
    }
  }
  
  /// Validate text input
  static TextValidationResult validateText(String text) {
    final trimmedText = text.trim();
    
    if (trimmedText.isEmpty) {
      return TextValidationResult(
        isValid: false,
        errorMessage: 'Please enter medicine names',
      );
    }
    
    if (trimmedText.length < minTextLength) {
      return TextValidationResult(
        isValid: false,
        errorMessage: 'Text is too short',
      );
    }
    
    if (trimmedText.length > maxTextLength) {
      return TextValidationResult(
        isValid: false,
        errorMessage: 'Text exceeds maximum length of $maxTextLength characters',
      );
    }
    
    return TextValidationResult(isValid: true);
  }
  
  /// Validate recording duration
  static RecordingValidationResult validateRecordingDuration(Duration duration) {
    final seconds = duration.inSeconds;
    
    if (seconds < minRecordingDurationSeconds) {
      return RecordingValidationResult(
        isValid: false,
        errorMessage: 'Recording is too short (minimum $minRecordingDurationSeconds second)',
      );
    }
    
    if (seconds > maxRecordingDurationSeconds) {
      return RecordingValidationResult(
        isValid: false,
        errorMessage: 'Recording exceeds maximum duration of $maxRecordingDurationSeconds seconds',
      );
    }
    
    return RecordingValidationResult(isValid: true);
  }
  
  /// Validate pincode (Indian)
  static bool isPincodeValid(String pincode) {
    final regex = RegExp(r'^\d{6}$');
    return regex.hasMatch(pincode);
  }
  
  /// Validate phone number (Indian)
  static bool isPhoneNumberValid(String phone) {
    final regex = RegExp(r'^[6-9]\d{9}$');
    return regex.hasMatch(phone.replaceAll(RegExp(r'[^\d]'), ''));
  }
}

class FileValidationResult {
  final bool isValid;
  final String? errorMessage;
  
  FileValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}

class TextValidationResult {
  final bool isValid;
  final String? errorMessage;
  
  TextValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}

class RecordingValidationResult {
  final bool isValid;
  final String? errorMessage;
  
  RecordingValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}