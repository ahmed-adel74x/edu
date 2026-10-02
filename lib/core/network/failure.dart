import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import 'api_response.dart';

/// The `error_code` values the backend is known to send.
///
/// They ride on every [Failure] as [Failure.errorCode] so a feature can branch on
/// the backend's own code even when several codes share an HTTP status.
abstract final class FailureCodes {
  static const String validationError = 'VALIDATION_ERROR';
  static const String enrollmentPending = 'ENROLLMENT_PENDING';
  static const String enrollmentRejected = 'ENROLLMENT_REJECTED';
  static const String studentOnly = 'STUDENT_ONLY';
  static const String studentSessionRevoked = 'STUDENT_SESSION_REVOKED';
  static const String studentAlreadyLoggedIn = 'STUDENT_ALREADY_LOGGED_IN';

  /// The backend rejected the token (sent by logout).
  static const String unauthenticated = 'UNAUTHENTICATED';

  /// A signed-in account whose role this app does not serve. Raised by the app,
  /// not the backend, so it never appears on the wire.
  static const String unsupportedRole = 'UNSUPPORTED_ROLE';
}

/// Something that went wrong, in one shape for the whole app.
///
/// [message] is the raw server/technical text (never shown as-is — the UI owns
/// its own copy), [errorCode] is the backend's `error_code` when it sent one, and
/// [statusCode] is the HTTP status when there was one. Failures are value-equal
/// (via [Equatable]) and throwable, so a data source can `throw` one and a
/// repository can catch it.
sealed class Failure extends Equatable implements Exception {
  const Failure({required this.message, this.errorCode, this.statusCode});

  final String message;
  final String? errorCode;
  final int? statusCode;

  @override
  List<Object?> get props => [message, errorCode, statusCode];
}

/// No connection at all.
final class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection',
    super.errorCode,
    super.statusCode,
  });
}

/// The connection or the response took too long.
final class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'The request timed out',
    super.errorCode,
    super.statusCode,
  });
}

/// The backend rejected the input (HTTP 422, or `VALIDATION_ERROR`).
final class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message = 'Validation failed',
    super.errorCode,
    super.statusCode,
    this.fieldErrors = const {},
  });

  /// The `errors` object the backend sent, keyed by field.
  final Map<String, List<String>> fieldErrors;

  @override
  List<Object?> get props => [...super.props, ..._fieldErrorProps()];

  /// [fieldErrors] flattened, so two failures with the same field messages are
  /// equal (a nested `Map` would otherwise compare by identity).
  List<String> _fieldErrorProps() {
    final keys = fieldErrors.keys.toList()..sort();
    return [for (final key in keys) '$key=${fieldErrors[key]!.join('|')}'];
  }
}

/// The session is missing, wrong, or over (HTTP 401).
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'Unauthorized',
    super.errorCode,
    super.statusCode,
  });
}

/// Authenticated, but not allowed to do this (HTTP 403).
final class ForbiddenFailure extends Failure {
  const ForbiddenFailure({
    super.message = 'Forbidden',
    super.errorCode,
    super.statusCode,
  });
}

/// The call conflicts with the current state (HTTP 409).
final class ConflictFailure extends Failure {
  const ConflictFailure({
    super.message = 'Conflict',
    super.errorCode,
    super.statusCode,
  });
}

/// The backend failed (HTTP 5xx).
final class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Server error',
    super.errorCode,
    super.statusCode,
  });
}

/// Anything else, including a body that could not be read as an envelope.
final class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Something went wrong',
    super.errorCode,
    super.statusCode,
  });
}

/// The only place that turns an error into a [Failure].
///
/// Feed it whatever a request threw: a [DioException], a non-success
/// [ApiResponse] (an HTTP 2xx whose `status` is false), an already-built
/// [Failure], or a parsing error. Nothing else in the app maps errors.
Failure toFailure(Object error) {
  if (error is Failure) return error;
  if (error is DioException) return _failureFromDio(error);
  if (error is ApiResponse) {
    return _failureFromEnvelope(
      statusCode: error.statusCode,
      errorCode: error.errorCode,
      message: error.message,
      fieldErrors: error.fieldErrors,
    );
  }
  return UnknownFailure(message: error.toString());
}

Failure _failureFromDio(DioException error) {
  final response = error.response;
  final envelope = _envelopeOf(response?.data, response?.statusCode);

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return TimeoutFailure(
        message: error.message ?? 'The request timed out',
        errorCode: envelope?.errorCode,
        statusCode: response?.statusCode,
      );
    case DioExceptionType.connectionError:
    case DioExceptionType.badCertificate:
      return NetworkFailure(
        message: error.message ?? 'No internet connection',
        errorCode: envelope?.errorCode,
        statusCode: response?.statusCode,
      );
    case DioExceptionType.cancel:
      return UnknownFailure(
        message: error.message ?? 'The request was cancelled',
        errorCode: envelope?.errorCode,
        statusCode: response?.statusCode,
      );
    case DioExceptionType.badResponse:
    case DioExceptionType.unknown:
      // A badResponse always carries a response; `unknown` does not when it is a
      // socket error, which is a connection problem rather than a server one.
      if (response == null) {
        return NetworkFailure(
          message: error.message ?? 'No internet connection',
        );
      }
      return _failureFromEnvelope(
        statusCode: response.statusCode,
        errorCode: envelope?.errorCode,
        message: envelope?.message ?? error.message ?? '',
        fieldErrors: envelope?.fieldErrors ?? const {},
      );
  }
}

ApiResponse? _envelopeOf(Object? data, int? statusCode) =>
    data is Map<String, dynamic>
        ? ApiResponse.fromJson(data, statusCode: statusCode)
        : null;

Failure _failureFromEnvelope({
  required int? statusCode,
  required String? errorCode,
  required String message,
  required Map<String, List<String>> fieldErrors,
}) {
  // The backend's own codes win, whatever HTTP status carried them.
  if (errorCode == FailureCodes.studentSessionRevoked) {
    return UnauthorizedFailure(
      message: message,
      errorCode: errorCode,
      statusCode: statusCode,
    );
  }
  if (errorCode == FailureCodes.validationError) {
    return ValidationFailure(
      message: message,
      errorCode: errorCode,
      statusCode: statusCode,
      fieldErrors: fieldErrors,
    );
  }

  return switch (statusCode) {
    401 => UnauthorizedFailure(
      message: message,
      errorCode: errorCode,
      statusCode: statusCode,
    ),
    403 => ForbiddenFailure(
      message: message,
      errorCode: errorCode,
      statusCode: statusCode,
    ),
    409 => ConflictFailure(
      message: message,
      errorCode: errorCode,
      statusCode: statusCode,
    ),
    422 => ValidationFailure(
      message: message,
      errorCode: errorCode,
      statusCode: statusCode,
      fieldErrors: fieldErrors,
    ),
    final code when code != null && code >= 500 => ServerFailure(
      message: message,
      errorCode: errorCode,
      statusCode: statusCode,
    ),
    _ => UnknownFailure(
      message: message,
      errorCode: errorCode,
      statusCode: statusCode,
    ),
  };
}
