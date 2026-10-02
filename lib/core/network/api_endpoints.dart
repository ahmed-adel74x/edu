/// The paths the app calls, relative to the API base URL.
///
/// These are appended to [ApiConfig.baseUrl] by Dio, so they are plain strings a
/// data source can pass straight to `dio.get` / `dio.post`. Only the endpoints
/// there is real documentation for are listed; a feature adds its own as the
/// paths are confirmed.
abstract final class ApiEndpoints {
  // Student session
  static const String studentLogin = '/student/login';
  static const String studentLogout = '/student/logout';
  static const String studentProfile = '/student/profile';

  // Student home
  static const String studentHome = '/student/home';
}
