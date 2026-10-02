/// The envelope every endpoint answers with:
///
/// `{ status: bool, message: String, data: any|null, errors: object|null,
/// error_code: String|null, pagination: object|null }`.
///
/// It carries only what the server sent — no colors, no formatting. A response
/// is a success only when [status] says so: an HTTP 2xx with `status == false`
/// is a failure, so callers must check [isSuccess] and hand a failure to
/// `toFailure` rather than trusting the transport.
class ApiResponse<T> {
  const ApiResponse({
    required this.status,
    required this.message,
    this.data,
    this.errors,
    this.errorCode,
    this.pagination,
    this.statusCode,
  });

  /// Reads the envelope. [statusCode] is the HTTP status the transport saw, kept
  /// so a failure can report it; it is not part of the JSON body.
  factory ApiResponse.fromJson(Map<String, dynamic> json, {int? statusCode}) {
    return ApiResponse<T>(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] as T?,
      errors: _asStringKeyedMap(json['errors']),
      errorCode: json['error_code']?.toString(),
      pagination: _asStringKeyedMap(json['pagination']),
      statusCode: statusCode,
    );
  }

  /// Whether the backend itself says the call succeeded. A 2xx carrying `false`
  /// here is still a failure.
  final bool status;

  /// The backend's message. A *success* message is server copy and is never
  /// shown to the user; a failure's message travels on the `Failure` instead.
  final String message;

  /// The payload, or null when the call failed.
  final T? data;

  /// The backend's `errors` object, as sent.
  final Map<String, dynamic>? errors;

  /// The backend's `error_code`, when it sent one.
  final String? errorCode;

  /// The pagination block, when the endpoint paginates.
  final Map<String, dynamic>? pagination;

  /// The HTTP status that carried this envelope, when known.
  final int? statusCode;

  bool get isSuccess => status;

  bool get isFailure => !status;

  /// [errors] coerced to per-field messages: `{ field: [message, ...] }`.
  Map<String, List<String>> get fieldErrors => _fieldErrorsOf(errors);

  static Map<String, List<String>> _fieldErrorsOf(Object? errors) {
    if (errors is! Map) return const {};
    final result = <String, List<String>>{};
    errors.forEach((key, value) {
      result[key.toString()] = switch (value) {
        final List<dynamic> messages =>
          messages.map((message) => message.toString()).toList(),
        null => const <String>[],
        _ => <String>[value.toString()],
      };
    });
    return result;
  }

  static Map<String, dynamic>? _asStringKeyedMap(Object? value) =>
      value is Map ? value.map((key, item) => MapEntry(key.toString(), item)) : null;
}
