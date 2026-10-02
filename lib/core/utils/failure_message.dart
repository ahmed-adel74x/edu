import 'package:easy_localization/easy_localization.dart';

import '../network/failure.dart';

/// The app's own copy for a failure — never the server's text.
///
/// One getter per message, each resolving a key from the `errors` section of the
/// translation files, so every screen shows the same wording in either language.
abstract final class FailureStrings {
  static String get network => 'errors.network'.tr();
  static String get timeout => 'errors.timeout'.tr();
  static String get server => 'errors.server'.tr();
  static String get unknown => 'errors.unknown'.tr();
  static String get validation => 'errors.validation'.tr();

  /// A rejected sign-in (401 with no backend code).
  static String get wrongCredentials => 'errors.wrongCredentials'.tr();

  static String get alreadyLoggedIn => 'errors.alreadyLoggedIn'.tr();
  static String get enrollmentPending => 'errors.enrollmentPending'.tr();
  static String get enrollmentRejected => 'errors.enrollmentRejected'.tr();
  static String get studentOnly => 'errors.studentOnly'.tr();
  static String get unsupportedRole => 'errors.unsupportedRole'.tr();
  static String get sessionEnded => 'errors.sessionEnded'.tr();
}

/// The one place a [Failure] becomes a localized message a screen can show.
///
/// Known backend codes win (they are more specific than an HTTP status); an
/// unknown code falls back to the server's own message, which already follows
/// `Accept-Language`. A 422 is expected to be rendered per field by the screen;
/// [failureMessage] only gives the generic fallback for it.
String failureMessage(Failure failure) {
  final coded = _codedMessage(failure.errorCode);
  if (coded != null) return coded;

  return switch (failure) {
    NetworkFailure() => FailureStrings.network,
    TimeoutFailure() => FailureStrings.timeout,
    ServerFailure() => FailureStrings.server,
    UnauthorizedFailure() => FailureStrings.wrongCredentials,
    ValidationFailure() => FailureStrings.validation,
    ForbiddenFailure() ||
    ConflictFailure() ||
    UnknownFailure() => _serverOr(failure, FailureStrings.unknown),
  };
}

String? _codedMessage(String? code) => switch (code) {
  FailureCodes.validationError => FailureStrings.validation,
  FailureCodes.enrollmentPending => FailureStrings.enrollmentPending,
  FailureCodes.enrollmentRejected => FailureStrings.enrollmentRejected,
  FailureCodes.studentOnly => FailureStrings.studentOnly,
  FailureCodes.unsupportedRole => FailureStrings.unsupportedRole,
  FailureCodes.studentAlreadyLoggedIn => FailureStrings.alreadyLoggedIn,
  FailureCodes.studentSessionRevoked => FailureStrings.sessionEnded,
  FailureCodes.unauthenticated => FailureStrings.sessionEnded,
  _ => null,
};

String _serverOr(Failure failure, String fallback) =>
    failure.message.trim().isEmpty ? fallback : failure.message;
