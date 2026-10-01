// Tests for localization: the language switch, the reading direction that comes
// with it, and the parity of the two translation files.

import 'dart:convert';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

import 'package:test_edu/core/constants/app_strings.dart';
import 'package:test_edu/main.dart';
import 'package:test_edu/shared/widgets/coming_soon_screen.dart';

import 'helpers/app_test_harness.dart';

void main() {
  setUp(prepareAppEnvironment);

  testWidgets('switching language flips direction and loads the other JSON', (
    tester,
  ) async {
    // The page reports the direction it is laid out in on every build, so the
    // assertion never holds a stale context. (`ui.TextDirection`, because
    // easy_localization also exports intl's same-named class.)
    ui.TextDirection? direction;
    VoidCallback? switchToEnglish;

    await tester.pumpWidget(
      localizedApp(
        child: Builder(
          builder: (context) {
            direction = Directionality.of(context);
            switchToEnglish = () => context.setLocale(const Locale('en'));
            return const ComingSoonScreen(icon: Icons.home_rounded);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Arabic is what the app opens in.
    expect(direction, ui.TextDirection.rtl);
    expect(AppStrings.navHome, 'الرئيسية');
    expect(AppStrings.comingSoonTitle, 'قريبًا');
    expect(find.text('قريبًا'), findsOneWidget);

    switchToEnglish!();
    await tester.pumpAndSettle();

    expect(direction, ui.TextDirection.ltr);
    expect(AppStrings.navHome, 'Home');
    expect(AppStrings.comingSoonTitle, 'Coming soon');
    expect(find.text('Coming soon'), findsOneWidget);
    expect(find.text('قريبًا'), findsNothing);
  });

  test('ar.json and en.json define exactly the same keys', () async {
    final ar = flatKeys(await loadTranslations('ar'));
    final en = flatKeys(await loadTranslations('en'));
    expect(en, ar);
  });
}

/// The translations the app ships, straight from the asset bundle.
Future<Map<String, dynamic>> loadTranslations(String languageCode) async {
  final raw = await rootBundle.loadString(
    '$translationsPath/$languageCode.json',
  );
  return json.decode(raw) as Map<String, dynamic>;
}

/// Every leaf key of a translation file, as `a.b.c` dotted paths, sorted.
List<String> flatKeys(Map<String, dynamic> map, [String prefix = '']) {
  final keys = <String>[];
  map.forEach((key, value) {
    final path = prefix.isEmpty ? key : '$prefix.$key';
    if (value is Map<String, dynamic>) {
      keys.addAll(flatKeys(value, path));
    } else {
      keys.add(path);
    }
  });
  keys.sort();
  return keys;
}
