import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pharmaish/utils/api_error.dart';

void main() {
  group('ApiErrorMessage.fromBody', () {
    test('humanizes ASP.NET model-state errors', () {
      final body = {
        'title': 'One or more validation errors occurred.',
        'status': 400,
        'errors': {
          'State': ['The State field is required.'],
          r'$.addresses[0].postalCode': [
            'The JSON value could not be converted to System.String.'
          ],
        },
      };
      expect(ApiErrorMessage.fromBody(body),
          'State is required.\nInvalid value for Postal Code.');
    });

    test('joins list errors and reads Identity error objects', () {
      expect(
          ApiErrorMessage.fromBody({
            'errors': ['Mobile number already registered.']
          }),
          'Mobile number already registered.');
      expect(
          ApiErrorMessage.fromBody({
            'errors': [
              {'code': 'PasswordTooShort', 'description': 'Password too short.'}
            ]
          }),
          'Password too short.');
    });

    test('falls back to message / error / title keys', () {
      expect(ApiErrorMessage.fromBody({'message': 'Order not found'}),
          'Order not found');
      expect(ApiErrorMessage.fromBody({'error': 'PaymentIncomplete'}),
          'PaymentIncomplete');
      expect(ApiErrorMessage.fromBody({'foo': 'bar'}), isNull);
      expect(ApiErrorMessage.fromBody('<html>Bad Gateway</html>'), isNull);
    });

    test('caps long validation lists', () {
      final body = {
        'errors': {
          'A': ['The A field is required.'],
          'B': ['The B field is required.'],
          'C': ['The C field is required.'],
          'D': ['The D field is required.'],
        }
      };
      expect(ApiErrorMessage.fromBody(body),
          'A is required.\nB is required.\nC is required.\n(+1 more)');
    });
  });

  group('ApiErrorMessage.fromHttpResponse', () {
    test('parses a 400 body and hides 500 details', () {
      final bad = http.Response(
          jsonEncode({
            'errors': {
              'City': ['The City field is required.']
            }
          }),
          400);
      expect(ApiErrorMessage.fromHttpResponse(bad), 'City is required.');

      final boom = http.Response(
          jsonEncode({'error': 'x', 'message': 'NullReferenceException'}), 500);
      expect(ApiErrorMessage.fromHttpResponse(boom), ApiErrorMessage.server);
    });

    test('uses fallback when the body is empty', () {
      expect(
          ApiErrorMessage.fromHttpResponse(http.Response('', 409),
              fallback: 'Already exists.'),
          'Already exists.');
      expect(ApiErrorMessage.fromHttpResponse(http.Response('', 401)),
          ApiErrorMessage.sessionExpired);
    });
  });

  group('ApiErrorMessage.fromException', () {
    test('distinguishes transport failures from bugs', () {
      expect(ApiErrorMessage.fromException(const SocketException('x')),
          ApiErrorMessage.network);
      expect(ApiErrorMessage.fromException(http.ClientException('x')),
          ApiErrorMessage.network);
      expect(ApiErrorMessage.fromException(const FormatException('x')),
          'Unexpected response from server. Please try again.');
      // A null-check / programming error must NOT be reported as network.
      expect(ApiErrorMessage.fromException(TypeError()),
          ApiErrorMessage.unexpected);
    });

    test('reads the body out of a DioException', () {
      final options = RequestOptions(path: '/x');
      final e = DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: options,
          statusCode: 400,
          data: {
            'errors': {
              'State': ['The State field is required.']
            }
          },
        ),
      );
      expect(ApiErrorMessage.fromException(e), 'State is required.');

      final offline = DioException(
          requestOptions: options, type: DioExceptionType.connectionError);
      expect(ApiErrorMessage.fromException(offline), ApiErrorMessage.network);
    });
  });
}
