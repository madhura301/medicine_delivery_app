import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaish/utils/storage.dart';

/// Builds an unsigned JWT with [claims] — only the payload matters here.
String _jwt(Map<String, dynamic> claims) {
  String part(Map<String, dynamic> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  return '${part({'alg': 'HS256', 'typ': 'JWT'})}.${part(claims)}.signature';
}

int _epochSeconds(DateTime t) => t.millisecondsSinceEpoch ~/ 1000;

void main() {
  group('StorageService.isTokenExpired', () {
    test('a token expiring in the future is not expired', () {
      final token = _jwt({
        'role': 'Chemist',
        'exp': _epochSeconds(DateTime.now().add(const Duration(days: 30))),
      });
      expect(StorageService.isTokenExpired(token), isFalse);
    });

    test('a token whose exp has passed is expired', () {
      final token = _jwt({
        'exp': _epochSeconds(DateTime.now().subtract(const Duration(hours: 1))),
      });
      expect(StorageService.isTokenExpired(token), isTrue);
    });

    test('a token about to expire counts as expired', () {
      final token = _jwt({
        'exp': _epochSeconds(DateTime.now().add(const Duration(seconds: 20))),
      });
      expect(StorageService.isTokenExpired(token), isTrue);
    });

    test('a token that cannot be decoded counts as expired', () {
      expect(StorageService.isTokenExpired('not-a-jwt'), isTrue);
      expect(StorageService.isTokenExpired('a.%%%.c'), isTrue);
    });

    test('a token without exp is left to the server', () {
      expect(StorageService.isTokenExpired(_jwt({'role': 'Customer'})), isFalse);
    });
  });

  group('StorageService.tokenExpiry', () {
    test('reads exp as a UTC time', () {
      final exp = DateTime.utc(2030, 1, 2, 3, 4, 5);
      expect(StorageService.tokenExpiry(_jwt({'exp': _epochSeconds(exp)})), exp);
    });
  });
}
