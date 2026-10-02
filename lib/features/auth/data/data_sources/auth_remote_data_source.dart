import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/failure.dart';
import '../../../../shared/models/user.dart';

/// A login that succeeded: the Sanctum token and the account it belongs to.
typedef LoginResult = ({String token, User user});

/// Talks to the student session endpoints.
///
/// It parses the shared envelope and, on any failure — a non-2xx, an HTTP 2xx
/// whose `status` is false, or a body that isn't the envelope — throws a
/// [Failure] built by the foundation's single `toFailure`. Nothing raw escapes.
class AuthRemoteDataSource {
  AuthRemoteDataSource({required this.dio});

  final Dio dio;

  /// Signs a student in. The backend rejects bad credentials with 401, an
  /// already-open session with 409 and bad input with 422.
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        ApiEndpoints.studentLogin,
        data: {'email': email, 'password': password},
      );
      final body = ApiResponse<Map<String, dynamic>>.fromJson(
        _bodyOf(response.data),
        statusCode: response.statusCode,
      );
      if (body.isFailure) throw toFailure(body);

      final data = body.data ?? const <String, dynamic>{};
      final profile = data['profile'];
      return (
        token: data['token']?.toString() ?? '',
        user: User.fromJson(
          profile is Map
              ? profile.map((key, item) => MapEntry(key.toString(), item))
              : const <String, dynamic>{},
        ),
      );
    } catch (error) {
      throw toFailure(error);
    }
  }

  /// Ends the session on the server. The backend answers 401 when the token is
  /// already dead and 403 when the student is not allowed to sign out.
  Future<void> logout() async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        ApiEndpoints.studentLogout,
      );
      final body = ApiResponse<Map<String, dynamic>>.fromJson(
        _bodyOf(response.data),
        statusCode: response.statusCode,
      );
      if (body.isFailure) throw toFailure(body);
    } catch (error) {
      throw toFailure(error);
    }
  }

  static Map<String, dynamic> _bodyOf(Map<String, dynamic>? data) =>
      data ?? const <String, dynamic>{};
}
