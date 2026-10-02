import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Where a log line goes. Tests pass a collector; the app prints.
typedef DebugLogSink = void Function(String message);

void _printLog(String message) => debugPrint(message);

/// Prints requests and responses, but only in debug builds, and never a secret:
/// the `Authorization` header and any `password` / `token` body field are
/// replaced with [redacted]. Nothing else is filtered, so it stays useful while
/// developing without ever putting credentials in the logs.
class DebugLogInterceptor extends Interceptor {
  DebugLogInterceptor({DebugLogSink? log}) : _log = log ?? _printLog;

  /// What a secret is replaced with.
  static const String redacted = '***';

  static const Set<String> _sensitiveHeaders = {'authorization'};
  static const Set<String> _sensitiveBodyKeys = {'password', 'token'};

  final DebugLogSink _log;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      _log(
        '→ ${options.method} ${options.uri}\n'
        '  headers: ${redactHeaders(options.headers)}\n'
        '  body: ${redactBody(options.data)}',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      _log(
        '← ${response.statusCode} ${response.requestOptions.uri}\n'
        '  body: ${redactBody(response.data)}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      _log('✕ ${err.type.name} ${err.requestOptions.uri} — ${err.message}');
    }
    handler.next(err);
  }

  /// [headers] with any sensitive header masked.
  static Map<String, Object?> redactHeaders(Map<String, dynamic> headers) {
    return headers.map(
      (key, value) => MapEntry(
        key,
        _sensitiveHeaders.contains(key.toLowerCase()) ? redacted : value,
      ),
    );
  }

  /// [body] with any `password` / `token` field masked, at any depth.
  static Object? redactBody(Object? body) {
    if (body is Map) {
      return body.map(
        (key, value) => MapEntry(
          '$key',
          _sensitiveBodyKeys.contains('$key'.toLowerCase())
              ? redacted
              : redactBody(value),
        ),
      );
    }
    if (body is List) {
      return body.map(redactBody).toList();
    }
    return body;
  }
}
