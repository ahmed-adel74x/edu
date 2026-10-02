import 'package:flutter_test/flutter_test.dart';
import 'package:test_edu/core/network/interceptors/language_interceptor.dart';

import '../../helpers/fake_http_adapter.dart';

void main() {
  test('the app-wide holder defaults to Arabic', () {
    expect(LocaleHolder.instance.languageCode, 'ar');
  });

  test('sends the active language and follows changes', () async {
    final holder = LocaleHolder();
    final adapter = FakeHttpAdapter((_) => jsonResponse({'status': true}));
    final dio = dioWith(adapter)
      ..interceptors.add(LanguageInterceptor(localeHolder: holder));

    await dio.get('/x');
    expect(adapter.lastRequest!.headers['Accept-Language'], 'ar');

    holder.languageCode = 'en';
    await dio.get('/x');
    expect(adapter.lastRequest!.headers['Accept-Language'], 'en');
  });

  test('ignores an empty language code', () {
    final holder = LocaleHolder('en')..languageCode = '';
    expect(holder.languageCode, 'en');
  });
}
