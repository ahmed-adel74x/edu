import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Answers every request with a canned body, over no socket.
///
/// [respond] receives the [RequestOptions] the interceptors already produced, so
/// a test can both drive the status code and then assert on headers/body through
/// [lastRequest]. A fake adapter is used instead of a mocking package.
class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter(this.respond);

  final ResponseBody Function(RequestOptions options) respond;

  /// The last request Dio handed to the adapter — interceptors included.
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

/// A JSON [ResponseBody] with the usual content type and [statusCode].
ResponseBody jsonResponse(Object? body, {int statusCode = 200}) =>
    ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

/// A [Dio] rooted at a fake host and backed by [adapter].
Dio dioWith(HttpClientAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  dio.httpClientAdapter = adapter;
  return dio;
}
