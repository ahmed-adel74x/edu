import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/failure.dart';
import '../models/home_summary.dart';

/// Talks to the student dashboard endpoint.
///
/// It parses the shared envelope and, on any failure — a non-2xx, an HTTP 2xx
/// whose `status` is false, or a body that isn't the envelope — throws a
/// [Failure] built by the foundation's single `toFailure`. Nothing raw escapes.
/// The `Authorization` header is added by the app's interceptor, not here.
class HomeRemoteDataSource {
  HomeRemoteDataSource({required this.dio});

  final Dio dio;

  /// Reads `GET /student/home`. The backend rejects a missing/expired session
  /// with 401, and a student who may not see the dashboard with 403
  /// (`ENROLLMENT_PENDING`, `ENROLLMENT_REJECTED`, `STUDENT_ONLY`).
  Future<HomeSummary> fetchHome() async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        ApiEndpoints.studentHome,
      );
      final body = ApiResponse<Map<String, dynamic>>.fromJson(
        _bodyOf(response.data),
        statusCode: response.statusCode,
      );
      if (body.isFailure) throw toFailure(body);

      return HomeSummary.fromJson(body.data ?? const <String, dynamic>{});
    } catch (error) {
      throw toFailure(error);
    }
  }

  static Map<String, dynamic> _bodyOf(Map<String, dynamic>? data) =>
      data ?? const <String, dynamic>{};
}