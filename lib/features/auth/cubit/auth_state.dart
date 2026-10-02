import 'package:equatable/equatable.dart';

import '../../../shared/models/user.dart';
import '../../../shared/models/user_role.dart';

/// Whether the app currently holds a session.
enum AuthStatus { unauthenticated, authenticated }

/// Why a session ended on its own, so the login screen can explain it once.
enum SessionEndReason { expired, revoked }

/// The app's global session state.
class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.user,
    this.sessionEndedReason,
  });

  final AuthStatus status;

  /// The signed-in account, or null while signed out.
  final User? user;

  /// Set for exactly one read when the backend ended the session; the login
  /// screen consumes it via `AuthCubit.clearSessionEndedReason`.
  final SessionEndReason? sessionEndedReason;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// The role the router guards with, or null while signed out (or unknown).
  UserRole? get role => user?.role;

  /// The same state with the one-shot [sessionEndedReason] cleared.
  AuthState consumeSessionEndedReason() =>
      AuthState(status: status, user: user);

  @override
  List<Object?> get props => [status, user, sessionEndedReason];
}
