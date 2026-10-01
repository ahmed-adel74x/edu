// The environment the app expects, for tests to reuse.
//
// Two pieces of real infrastructure are stubbed here: the translations the app
// loads from assets, and the preferences it keeps the appearance in. Nothing
// else about a test changes.

import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:test_edu/core/theme/app_theme.dart';
import 'package:test_edu/main.dart';

/// The shipped translation files, read once.
final Map<String, Map<String, dynamic>> testTranslations = {};

/// Call from `setUp`: load the translations and give preferences a memory-only
/// store.
Future<void> prepareAppEnvironment() async {
  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();
  for (final locale in appSupportedLocales) {
    final raw = await rootBundle.loadString(
      '$translationsPath/${locale.languageCode}.json',
    );
    testTranslations[locale.languageCode] =
        json.decode(raw) as Map<String, dynamic>;
  }
}

/// The app's translations, but from memory and already complete, so a screen is
/// painted on the first frame instead of after the asset bundle answers.
class _MemoryAssetLoader extends AssetLoader {
  const _MemoryAssetLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async =>
      testTranslations[locale.languageCode];
}

/// [testTranslations] behind an [AssetLoader]: pass it to `MyApp` (or use
/// [localizedApp]) so a test's first frame is already localized.
const AssetLoader memoryAssetLoader = _MemoryAssetLoader();

/// Wraps [child] in exactly the localization, sizing and theming the app gives
/// its screens — for the tests that pump a single screen instead of the whole
/// app. [locale] is what the app opens in; a screen can still switch it with
/// `context.setLocale`.
Widget localizedApp({
  required Widget child,
  Locale locale = appFallbackLocale,
  bool dark = false,
  ThemeData? theme,
}) {
  return EasyLocalization(
    supportedLocales: appSupportedLocales,
    path: translationsPath,
    fallbackLocale: appFallbackLocale,
    startLocale: locale,
    useOnlyLangCode: true,
    assetLoader: memoryAssetLoader,
    child: Builder(
      builder: (context) => ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        // The theme is built here, after ScreenUtil is initialized, because the
        // type scale resolves its sizes through it.
        builder: (context, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme ?? (dark ? AppTheme.dark() : AppTheme.light()),
          locale: context.locale,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          home: child,
        ),
      ),
    ),
  );
}
