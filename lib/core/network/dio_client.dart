import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../storage/token_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/debug_log_interceptor.dart';
import 'interceptors/language_interceptor.dart';

/// Builds the app's single [Dio].
///
/// JSON in, JSON out, the configured timeouts, and the three interceptors in the
/// order a request runs through them: language first (the header is the same for
/// every call), then auth (the token), then the debug logger, which therefore
/// sees — and redacts — the finished request.
Dio buildDioClient({
  required TokenStorage tokenStorage,
  required SessionEvents sessionEvents,
  required LocaleHolder localeHolder,
  String baseUrl = ApiConfig.baseUrl,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      responseType: ResponseType.json,
      contentType: Headers.jsonContentType,
      headers: {'Accept': Headers.jsonContentType},
    ),
  );

  dio.interceptors.addAll([
    LanguageInterceptor(localeHolder: localeHolder),
    AuthInterceptor(tokenStorage: tokenStorage, sessionEvents: sessionEvents),
    if (kDebugMode) DebugLogInterceptor(),
  ]);

  return dio;
}
