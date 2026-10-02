import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_edu/core/network/api_response.dart';
import 'package:test_edu/core/network/failure.dart';

/// A [DioException] carrying an optional response, as Dio would raise it.
DioException dioError(
  DioExceptionType type, {
  int? statusCode,
  Object? data,
  String? message,
}) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    type: type,
    message: message,
    response: statusCode == null && data == null
        ? null
        : Response(requestOptions: options, statusCode: statusCode, data: data),
  );
}

/// The backend's envelope as decoded JSON.
Map<String, dynamic> envelope({
  bool status = false,
  String? message,
  Object? data,
  Object? errors,
  String? errorCode,
}) => {
  'status': status,
  'message': message,
  'data': data,
  'errors': errors,
  'error_code': errorCode,
  'pagination': null,
};

void main() {
  group('toFailure — DioException', () {
    test('every timeout type maps to TimeoutFailure', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.transformTimeout,
      ]) {
        expect(toFailure(dioError(type)), isA<TimeoutFailure>(), reason: '$type');
      }
    });

    test('no connection maps to NetworkFailure', () {
      final failure = toFailure(dioError(DioExceptionType.connectionError));
      expect(failure, isA<NetworkFailure>());
      expect(failure.errorCode, isNull);
    });

    test('401 maps to UnauthorizedFailure', () {
      final failure = toFailure(
        dioError(
          DioExceptionType.badResponse,
          statusCode: 401,
          data: envelope(message: 'Unauthenticated'),
        ),
      );
      expect(failure, isA<UnauthorizedFailure>());
      expect(failure.statusCode, 401);
    });

    test('403 maps to ForbiddenFailure and keeps the error code', () {
      final failure = toFailure(
        dioError(
          DioExceptionType.badResponse,
          statusCode: 403,
          data: envelope(
            message: 'students only',
            errorCode: FailureCodes.studentOnly,
          ),
        ),
      );
      expect(failure, isA<ForbiddenFailure>());
      expect(failure.errorCode, FailureCodes.studentOnly);
    });

    test('409 maps to ConflictFailure and keeps the error code', () {
      final failure = toFailure(
        dioError(
          DioExceptionType.badResponse,
          statusCode: 409,
          data: envelope(errorCode: FailureCodes.enrollmentPending),
        ),
      );
      expect(failure, isA<ConflictFailure>());
      expect(failure.errorCode, FailureCodes.enrollmentPending);
    });

    test('422 with field errors maps to ValidationFailure', () {
      final failure = toFailure(
        dioError(
          DioExceptionType.badResponse,
          statusCode: 422,
          data: envelope(
            errorCode: FailureCodes.validationError,
            errors: {
              'email': ['required', 'invalid'],
              'password': ['too short'],
            },
          ),
        ),
      );
      expect(failure, isA<ValidationFailure>());
      expect((failure as ValidationFailure).fieldErrors, {
        'email': ['required', 'invalid'],
        'password': ['too short'],
      });
      expect(failure.errorCode, FailureCodes.validationError);
    });

    test('5xx maps to ServerFailure', () {
      expect(
        toFailure(dioError(DioExceptionType.badResponse, statusCode: 500)),
        isA<ServerFailure>(),
      );
      expect(
        toFailure(dioError(DioExceptionType.badResponse, statusCode: 503)),
        isA<ServerFailure>(),
      );
    });

    test('a body that is not an envelope still maps by status', () {
      final failure = toFailure(
        dioError(
          DioExceptionType.badResponse,
          statusCode: 502,
          data: '<html>bad gateway</html>',
        ),
      );
      expect(failure, isA<ServerFailure>());
      expect(failure.statusCode, 502);
    });

    test('a parsing error maps to UnknownFailure', () {
      expect(toFailure(const FormatException('not json')), isA<UnknownFailure>());
    });
  });

  group('toFailure — ApiResponse (HTTP 2xx, status false)', () {
    test('VALIDATION_ERROR becomes a ValidationFailure', () {
      final failure = toFailure(
        ApiResponse<dynamic>.fromJson(
          envelope(
            errorCode: FailureCodes.validationError,
            errors: {
              'name': ['required'],
            },
          ),
          statusCode: 200,
        ),
      );
      expect(failure, isA<ValidationFailure>());
      expect(failure.errorCode, FailureCodes.validationError);
      expect(failure.statusCode, 200);
      expect((failure as ValidationFailure).fieldErrors, {
        'name': ['required'],
      });
    });

    test('a failure with no code becomes an UnknownFailure', () {
      final failure = toFailure(
        ApiResponse<dynamic>.fromJson(
          envelope(message: 'odd'),
          statusCode: 200,
        ),
      );
      expect(failure, isA<UnknownFailure>());
      expect(failure.statusCode, 200);
    });

    test('STUDENT_SESSION_REVOKED is UnauthorizedFailure whatever the status', () {
      final failure = toFailure(
        ApiResponse<dynamic>.fromJson(
          envelope(errorCode: FailureCodes.studentSessionRevoked),
          statusCode: 200,
        ),
      );
      expect(failure, isA<UnauthorizedFailure>());
      expect(failure.errorCode, FailureCodes.studentSessionRevoked);
    });
  });

  test('an already-built Failure passes through unchanged', () {
    const original = NetworkFailure(message: 'offline');
    expect(toFailure(original), same(original));
  });
}
