import 'package:flutter_test/flutter_test.dart';
import 'package:test_edu/core/network/api_response.dart';

void main() {
  group('ApiResponse.fromJson', () {
    test('reads a successful envelope', () {
      final response = ApiResponse<Map<String, dynamic>>.fromJson({
        'status': true,
        'message': 'done',
        'data': {'id': 1},
        'errors': null,
        'error_code': null,
        'pagination': null,
      }, statusCode: 200);

      expect(response.status, isTrue);
      expect(response.isSuccess, isTrue);
      expect(response.isFailure, isFalse);
      expect(response.message, 'done');
      expect(response.data, {'id': 1});
      expect(response.errorCode, isNull);
      expect(response.errors, isNull);
      expect(response.pagination, isNull);
      expect(response.statusCode, 200);
      expect(response.fieldErrors, isEmpty);
    });

    test('an HTTP 2xx carrying status false is a failure', () {
      final response = ApiResponse<Map<String, dynamic>>.fromJson({
        'status': false,
        'message': 'invalid',
        'data': null,
        'error_code': 'VALIDATION_ERROR',
        'errors': {'email': ['The email field is required.']},
      }, statusCode: 200);

      expect(response.isFailure, isTrue);
      expect(response.isSuccess, isFalse);
      expect(response.errorCode, 'VALIDATION_ERROR');
      expect(response.data, isNull);
      expect(response.fieldErrors, {
        'email': ['The email field is required.'],
      });
    });

    test('tolerates missing and non-object fields', () {
      final response = ApiResponse<dynamic>.fromJson(<String, dynamic>{});

      expect(response.status, isFalse);
      expect(response.message, '');
      expect(response.data, isNull);
      expect(response.errors, isNull);
      expect(response.errorCode, isNull);
      expect(response.pagination, isNull);
      expect(response.statusCode, isNull);
      expect(response.fieldErrors, isEmpty);
    });

    test('reads a pagination block when present', () {
      final response = ApiResponse<List<dynamic>>.fromJson({
        'status': true,
        'message': '',
        'data': [1, 2, 3],
        'pagination': {
          'current_page': 1,
          'last_page': 3,
          'per_page': 10,
          'total': 30,
        },
      });

      expect(response.data, [1, 2, 3]);
      expect(response.pagination, isNotNull);
      expect(response.pagination!['total'], 30);
    });

    test('coerces a single error message into a list', () {
      final response = ApiResponse<dynamic>.fromJson({
        'status': false,
        'errors': {'name': 'required'},
      });

      expect(response.fieldErrors, {
        'name': ['required'],
      });
    });
  });
}
