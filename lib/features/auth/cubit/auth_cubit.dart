import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/interceptors/auth_interceptor.dart';
import '../../../shared/models/user.dart';
import '../../../shared/models/user_role.dart';
import '../data/repositories/auth_repository.dart';
import 'auth_state.dart';

/// The app's single session cubit.
///
/// One instance for the whole app: the router guards on it, the login feature
/// feeds it, and the temporary logout buttons drive it. It is the only thing
/// that listens to [SessionEvents].
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.repository, required this.sessionEvents})
    : super(const AuthState()) {
    _sessionSubscription = sessionEvents.stream.listen(_onSessionEvent);
  }

  final AuthRepository repository;
  final SessionEvents sessionEvents;

  late final StreamSubscription<SessionEvent> _sessionSubscription;

  /// Reads the cached session so the app can start directly in the right state.
  /// Called once from `main()`, before `runApp`.
  Future<void> restore() async {
    final user = await repository.restore();
    emit(
      user == null
          ? const AuthState()
          : AuthState(status: AuthStatus.authenticated, user: user),
    );
  }

  /// A login flow finished successfully.
  void onLoggedIn(User user) {
    emit(AuthState(status: AuthStatus.authenticated, user: user));
  }

  /// Signs out: asks the server (best effort) and always ends up signed out.
  Future<void> logout() async {
    await repository.logout();
    emit(const AuthState());
  }

  /// Debug-only: opens a role's shell with a mock account, no network, no token.
  void debugSignInAs(UserRole role) {
    if (!kDebugMode) return;
    emit(
      AuthState(status: AuthStatus.authenticated, user: _debugUser(role)),
    );
  }

  /// The login screen reads [AuthState.sessionEndedReason] once and clears it.
  void clearSessionEndedReason() {
    if (state.sessionEndedReason == null) return;
    emit(state.consumeSessionEndedReason());
  }

  @override
  Future<void> close() {
    unawaited(_sessionSubscription.cancel());
    return super.close();
  }

  void _onSessionEvent(SessionEvent event) {
    unawaited(_endSession(event));
  }

  /// The network layer says the session is over: forget it locally without a
  /// server call, and tell the app why.
  Future<void> _endSession(SessionEvent event) async {
    await repository.clearSession();
    emit(AuthState(sessionEndedReason: _reasonFor(event)));
  }

  static SessionEndReason _reasonFor(SessionEvent event) => switch (event) {
    SessionEvent.sessionExpired => SessionEndReason.expired,
    SessionEvent.sessionRevoked => SessionEndReason.revoked,
  };

  static User _debugUser(UserRole role) => User(
    userId: 'debug-${role.name}',
    name: switch (role) {
      UserRole.student => 'أحمد',
      UserRole.teacher => 'منى',
      UserRole.parent => 'والد أحمد',
    },
    email: '${role.name}@debug.local',
    role: role,
  );
}
