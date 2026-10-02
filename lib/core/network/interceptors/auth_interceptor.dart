import 'dart:async';

import 'package:dio/dio.dart';

import '../../storage/token_storage.dart';
import '../failure.dart';

/// What ended the session, as told by [SessionEvents].
enum SessionEvent {
  /// A request carried a token and the backend still answered 401.
  sessionExpired,

  /// The backend said the student's session was revoked
  /// (`STUDENT_SESSION_REVOKED`), whatever the HTTP status was.
  sessionRevoked,
}

/// The app's session-ending event stream.
///
/// The network layer emits here; a future `AuthCubit` listens and signs the user
/// out. A plain class over a broadcast stream, so there is exactly one place that
/// knows both sides of a session ending.
class SessionEvents {
  final StreamController<SessionEvent> _controller =
      StreamController<SessionEvent>.broadcast();

  /// Every session-ending event. Broadcast, so it can have any number of
  /// listeners.
  Stream<SessionEvent> get stream => _controller.stream;

  /// Called by the network layer. It never logs or clears anything itself.
  void notify(SessionEvent event) {
    if (!_controller.isClosed) _controller.add(event);
  }

  Future<void> dispose() => _controller.close();
}

/// Attaches the stored token to every request and turns a *session* 401 into a
/// [SessionEvent].
///
/// A 401 only means "session expired" when the request actually carried a token:
/// a 401 on the login request is wrong credentials and must change nothing.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.tokenStorage, required this.sessionEvents});

  /// Set on a request that got an `Authorization` header, so a later 401 can
  /// tell "our token was rejected" from "there was no token at all".
  static const String attachedTokenFlag = 'auth.attachedToken';

  final TokenStorage tokenStorage;
  final SessionEvents sessionEvents;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStorage.read();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      options.extra[attachedTokenFlag] = true;
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // A revoked session is a failure even on an HTTP 2xx, so it has to be caught
    // here as well as in onError.
    if (_errorCodeOf(response.data) == FailureCodes.studentSessionRevoked) {
      _endSession(SessionEvent.sessionRevoked);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final code = _errorCodeOf(err.response?.data);
    final carriedToken = err.requestOptions.extra[attachedTokenFlag] == true;

    if (code == FailureCodes.studentSessionRevoked) {
      _endSession(SessionEvent.sessionRevoked);
    } else if (err.response?.statusCode == 401 && carriedToken) {
      _endSession(SessionEvent.sessionExpired);
    }

    handler.next(err);
  }

  /// Forgets the token and tells the app the session is over.
  void _endSession(SessionEvent event) {
    unawaited(tokenStorage.clear());
    sessionEvents.notify(event);
  }

  /// `error_code` from an envelope-shaped body, if it has one.
  static String? _errorCodeOf(Object? data) {
    if (data is Map) {
      final code = data['error_code'];
      if (code is String && code.isNotEmpty) return code;
    }
    return null;
  }
}
