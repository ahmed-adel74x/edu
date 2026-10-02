/// The backend the app talks to.
///
/// The base URL is baked in at build time and can be overridden without editing
/// code: `flutter run --dart-define=API_BASE_URL=https://...`.
abstract final class ApiConfig {
  /// Where every request is rooted. Overridable with
  /// `--dart-define=API_BASE_URL=...`.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://app.wakp.net/api/mobile/hr',
  );

  /// How long to wait for the connection to be established.
  static const Duration connectTimeout = Duration(seconds: 15);

  /// How long to wait for the response after the request has been sent.
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// How long to wait while the request body is being sent.
  static const Duration sendTimeout = Duration(seconds: 30);
}
