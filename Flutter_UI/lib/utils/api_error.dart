import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

/// Turns API failures into short, accurate messages for the UI.
///
/// Before this helper every `catch (e)` in the app fell back to
/// "Network error", which also swallowed backend validation errors and
/// client-side bugs. Use it from any catch block or non-2xx branch:
///
/// ```dart
/// } catch (e) {
///   _errorMessage = ApiErrorMessage.fromException(e);
/// }
/// // or, for package:http responses:
/// _errorMessage = ApiErrorMessage.fromHttpResponse(response);
/// ```
///
/// Understands every error shape the backend produces:
///  * ASP.NET `ValidationProblemDetails`: `{ errors: { State: ["..."] } }`
///  * service results: `{ errors: ["..."] }` or `{ errors: [{ description }] }`
///  * middleware / simple bodies: `{ message }`, `{ error }`, `{ detail }`, `{ title }`
class ApiErrorMessage {
  ApiErrorMessage._();

  static const String network =
      'No internet connection. Please check your network and try again.';
  static const String timeout = 'The request timed out. Please try again.';
  static const String server = 'Server error. Please try again later.';
  static const String unexpected = 'Something went wrong. Please try again.';
  static const String sessionExpired =
      'Your session has expired. Please log in again.';
  static const String invalidInput = 'Please check the details you entered.';

  /// Maximum number of validation lines shown at once, to keep messages small.
  static const int _maxLines = 3;

  /// Message for a non-2xx `package:http` response.
  static String fromHttpResponse(http.Response response, {String? fallback}) {
    dynamic body;
    try {
      body = response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (_) {
      body = response.body;
    }
    return fromStatus(response.statusCode, body, fallback: fallback);
  }

  /// Message for a thrown error: Dio/HTTP transport failures, timeouts,
  /// malformed responses, or a plain programming error.
  static String fromException(Object error, {String? fallback}) {
    if (error is DioException) {
      final res = error.response;
      if (res != null) {
        return fromStatus(res.statusCode, res.data, fallback: fallback);
      }
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return timeout;
        case DioExceptionType.connectionError:
          return network;
        case DioExceptionType.badCertificate:
          return 'Secure connection failed. Please try again.';
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        case DioExceptionType.badResponse:
        case DioExceptionType.unknown:
          if (error.error is SocketException) return network;
          if (error.error is TimeoutException) return timeout;
          return fallback ?? unexpected;
      }
    }
    if (error is SocketException || error is http.ClientException) {
      return network;
    }
    if (error is TimeoutException) return timeout;
    if (error is FormatException) {
      return 'Unexpected response from server. Please try again.';
    }
    return fallback ?? unexpected;
  }

  /// Message for an HTTP status plus its (decoded) body.
  static String fromStatus(int? statusCode, dynamic body, {String? fallback}) {
    if (statusCode != null && statusCode >= 500) return server;
    final parsed = fromBody(body);
    if (parsed != null) return parsed;
    switch (statusCode) {
      case 400:
      case 422:
        return fallback ?? invalidInput;
      case 401:
        return sessionExpired;
      case 403:
        return 'You do not have permission to do this.';
      case 404:
        return fallback ?? 'The requested item was not found.';
      case 409:
        return fallback ?? 'This record already exists.';
      default:
        return fallback ?? unexpected;
    }
  }

  /// Extracts a user-facing message from a decoded response body, or null
  /// when the body carries nothing readable.
  static String? fromBody(dynamic body) {
    if (body == null) return null;
    if (body is String) {
      final text = body.trim();
      if (text.isEmpty || text.startsWith('<')) return null; // HTML page
      try {
        return fromBody(jsonDecode(text));
      } catch (_) {
        return text.length > 200 ? null : text;
      }
    }
    if (body is! Map) return null;

    final lines = <String>[];
    final errors = body['errors'];
    if (errors is Map) {
      errors.forEach((field, fieldErrors) {
        final items = fieldErrors is List ? fieldErrors : [fieldErrors];
        for (final item in items) {
          final text = item?.toString().trim() ?? '';
          if (text.isNotEmpty) lines.add(_humanize(field.toString(), text));
        }
      });
    } else if (errors is List) {
      for (final item in errors) {
        final text = item is Map
            ? (item['description'] ?? item['message'] ?? item['errorMessage'])
                ?.toString()
            : item?.toString();
        if (text != null && text.trim().isNotEmpty) lines.add(text.trim());
      }
    } else if (errors is String && errors.trim().isNotEmpty) {
      lines.add(errors.trim());
    }

    if (lines.isEmpty) {
      for (final key in const ['message', 'detail', 'error', 'title']) {
        final value = body[key];
        if (value is String && value.trim().isNotEmpty) {
          lines.add(value.trim());
          break;
        }
      }
    }
    if (lines.isEmpty) return null;

    final unique = lines.toSet().toList();
    if (unique.length <= _maxLines) return unique.join('\n');
    final more = unique.length - _maxLines;
    return '${unique.take(_maxLines).join('\n')}\n(+$more more)';
  }

  static final RegExp _requiredPattern =
      RegExp(r'^The (.+?) field is required\.?$', caseSensitive: false);
  static final RegExp _fieldPattern =
      RegExp(r'\bThe (.+?) field\b', caseSensitive: false);

  /// Rewrites ASP.NET model-state text into a short, readable line, e.g.
  /// `Addresses[0].State` + "The State field is required." -> "State is required."
  static String _humanize(String field, String message) {
    final name = _fieldLabel(field);
    if (message.contains('JSON') || message.contains('could not be converted')) {
      return name.isEmpty ? 'Some values are invalid.' : 'Invalid value for $name.';
    }
    final required = _requiredPattern.firstMatch(message);
    if (required != null) return '${_fieldLabel(required.group(1)!)} is required.';
    var text = message.replaceAllMapped(
        _fieldPattern, (m) => _fieldLabel(m.group(1)!));
    if (name.isNotEmpty &&
        !text.toLowerCase().contains(name.toLowerCase()) &&
        !text.toLowerCase().contains(field.toLowerCase())) {
      text = '$name: $text';
    }
    return text;
  }

  /// `$.addresses[0].postalCode` -> `Postal Code`
  static String _fieldLabel(String field) {
    var name = field.trim();
    if (name.startsWith(r'$')) name = name.substring(1);
    name = name.split('.').last.replaceAll(RegExp(r'\[\d+\]'), '');
    if (name.isEmpty) return '';
    final spaced = name
        .replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .replaceAll('_', ' ');
    return spaced[0].toUpperCase() + spaced.substring(1);
  }
}
