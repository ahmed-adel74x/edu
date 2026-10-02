import '../../../../core/network/failure.dart';
import '../../../../core/network/result.dart';
import '../../../../shared/models/user.dart';
import '../../../../shared/models/user_role.dart';
import '../data_sources/auth_local_data_source.dart';
import '../data_sources/auth_remote_data_source.dart';

/// The auth feature's repository: the one seam between the cubits and the data
/// sources. It returns a [Result] and never throws.
class AuthRepository {
  AuthRepository({required this.remote, required this.local});

  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;

  /// Signs a student in and keeps the session.
  ///
  /// The app only serves students: any other (or unknown) role is rejected —
  /// the just-issued token is released and the session is not kept.
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final session = await remote.login(email: email, password: password);
      if (session.user.role != UserRole.student) {
        await _releaseSession(session);
        return const Error(
          ForbiddenFailure(
            message: 'This app is for students only.',
            errorCode: FailureCodes.unsupportedRole,
          ),
        );
      }
      await local.saveSession(token: session.token, user: session.user);
      return Success(session.user);
    } catch (error) {
      return Error(toFailure(error));
    }
  }

  /// Signs out. The server call is best-effort: the local session is cleared
  /// even if it fails (network, 401 or 403).
  Future<void> logout() async {
    try {
      await remote.logout();
    } catch (_) {
      // Ignored on purpose — the device must end up signed out regardless.
    }
    await local.clearSession();
  }

  /// The session the device already holds, or null. Never touches the network.
  Future<User?> restore() async {
    final session = await local.readSession();
    return session?.user;
  }

  /// Forgets the local session without a server call (used when the backend
  /// itself says the session is over).
  Future<void> clearSession() => local.clearSession();

  /// Best effort: authorize a logout with the just-issued token, then clear it.
  Future<void> _releaseSession(LoginResult session) async {
    try {
      await local.saveSession(token: session.token, user: session.user);
      await remote.logout();
    } catch (_) {
      // Ignored on purpose.
    } finally {
      await local.clearSession();
    }
  }
}
