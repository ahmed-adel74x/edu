import 'package:dio/dio.dart';

/// The language the app is currently showing.
///
/// A tiny holder rather than a `BuildContext`: the root widget writes the active
/// locale here and [LanguageInterceptor] reads it, so the header follows
/// `context.setLocale` without the network layer ever touching the widget tree.
class LocaleHolder {
  LocaleHolder([this._languageCode = 'ar']);

  /// The app-wide instance the root widget updates and the interceptor reads.
  static final LocaleHolder instance = LocaleHolder();

  String _languageCode;

  /// A language code such as `ar` or `en`.
  String get languageCode => _languageCode;

  set languageCode(String value) {
    if (value.isNotEmpty) _languageCode = value;
  }
}

/// Sends the active language as `Accept-Language` on every request.
class LanguageInterceptor extends Interceptor {
  LanguageInterceptor({required this.localeHolder});

  final LocaleHolder localeHolder;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept-Language'] = localeHolder.languageCode;
    handler.next(options);
  }
}
