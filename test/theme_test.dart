// Tests for the theme layer: the light palette is the one the app shipped with,
// the dark palette is a real counterpart, ThemeNotifier switches and persists,
// and both themes build.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:test_edu/core/theme/app_colors.dart';
import 'package:test_edu/core/theme/app_colors_extension.dart';
import 'package:test_edu/core/theme/app_theme.dart';
import 'package:test_edu/core/theme/theme_notifier.dart';
import 'package:test_edu/shared/widgets/coming_soon_screen.dart';

import 'helpers/app_test_harness.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('the light palette is exactly the colors the app shipped with', () {
    const light = AppColorsExtension.light;

    expect(light.primary, AppColors.primary);
    expect(light.primaryDark, AppColors.primaryDark);
    expect(light.secondary, AppColors.secondary);
    expect(light.accent, AppColors.accent);
    expect(light.background, AppColors.background);
    expect(light.surface, AppColors.surface);
    expect(light.surfaceMuted, AppColors.surfaceMuted);
    expect(light.surfaceTint, AppColors.surfaceTint);
    expect(light.ink, AppColors.ink);
    expect(light.inkMuted, AppColors.inkMuted);
    expect(light.inkFaint, AppColors.inkFaint);
    expect(light.onPrimary, AppColors.onPrimary);
    expect(light.border, AppColors.border);
    expect(light.borderStrong, AppColors.borderStrong);
    expect(light.success, AppColors.success);
    expect(light.warning, AppColors.warning);
    expect(light.warningDeep, AppColors.warningDeep);
    expect(light.error, AppColors.error);
    expect(light.star, AppColors.star);
    expect(light.scrim, AppColors.scrim);
    expect(light.shadow, AppColors.shadow);
    expect(light.tintLavender, AppColors.tintLavender);
    expect(light.tintPeach, AppColors.tintPeach);
    expect(light.tintMint, AppColors.tintMint);
    expect(light.tintBlush, AppColors.tintBlush);
    expect(light.uploadAccent, AppColors.uploadAccent);
  });

  test('the gradients the app used are rebuilt from the palette', () {
    const light = AppColorsExtension.light;
    expect(light.promoGradient.colors, [
      AppColors.primaryDark,
      AppColors.secondary,
    ]);
    expect(light.heroGradient.colors, [
      const Color(0xFFEDEFFC),
      const Color(0xFFE3F3EE),
    ]);
    expect(light.progressGradient.colors, [
      AppColors.accent,
      AppColors.primary,
    ]);
    expect(light.authBackgroundGradient.colors, [
      const Color(0xFFE3EEFF),
      AppColors.background,
    ]);
  });

  test('the dark palette stands on its own, not as an inversion', () {
    const light = AppColorsExtension.light;
    const dark = AppColorsExtension.dark;

    // Surfaces go dark and ink goes light…
    expect(dark.background.computeLuminance(), lessThan(0.1));
    expect(dark.surface.computeLuminance(), lessThan(0.15));
    expect(dark.ink.computeLuminance(), greaterThan(0.6));

    // …while the brand keeps its hue instead of turning grey.
    expect(dark.primary, isNot(light.primary));
    expect(dark.primary.b, greaterThan(dark.primary.r));
    expect(dark.accent.g, greaterThan(dark.accent.r));

    // Every surface must differ, so a missed field can't slip through.
    expect(dark.surface, isNot(light.surface));
    expect(dark.surfaceTint, isNot(light.surfaceTint));
    expect(dark.border, isNot(light.border));
    expect(dark.tintMint, isNot(light.tintMint));
  });

  test('ThemeNotifier switches the mode and persists it', () async {
    final notifier = ThemeNotifier();
    expect(notifier.mode, ThemeMode.system);
    expect(notifier.followsSystem, isTrue);

    await notifier.useDark();
    expect(notifier.mode, ThemeMode.dark);
    expect(notifier.isDark, isTrue);
    expect(ThemeNotifier.fromName('dark'), ThemeMode.dark);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(ThemeNotifier.prefsKey), ThemeMode.dark.name);
    expect(await ThemeNotifier.loadSaved(), ThemeMode.dark);

    await notifier.useLight();
    expect(await ThemeNotifier.loadSaved(), ThemeMode.light);

    await notifier.useSystem();
    expect(await ThemeNotifier.loadSaved(), ThemeMode.system);
    // An unknown stored value falls back to following the system.
    expect(ThemeNotifier.fromName('sepia'), ThemeMode.system);
    expect(ThemeNotifier.fromName(null), ThemeMode.system);
  });

  testWidgets('a screen paints with the dark palette', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        dark: true,
        child: const ComingSoonScreen(icon: Icons.home_rounded),
      ),
    );
    await tester.pumpAndSettle();

    // The panel's own surface comes from the theme extension, so a dark build
    // must not fall back to the light values.
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, AppColorsExtension.dark.background);

    final context = tester.element(find.byType(ComingSoonScreen));
    expect(context.colors.ink, AppColorsExtension.dark.ink);
    expect(context.colors.ink, isNot(AppColorsExtension.light.ink));
    expect(tester.takeException(), isNull);
  });

  testWidgets('light and dark themes build and carry their palette', (
    tester,
  ) async {
    ThemeData? light;
    ThemeData? dark;

    await tester.pumpWidget(
      localizedApp(
        child: Builder(
          builder: (context) {
            // Built here, where ScreenUtil is already initialized.
            light = AppTheme.light();
            dark = AppTheme.dark();
            return const SizedBox();
          },
        ),
      ),
    );
    // Locales resolve before the home builder runs, so let the frame land.
    await tester.pumpAndSettle();

    expect(light!.brightness, Brightness.light);
    expect(dark!.brightness, Brightness.dark);
    expect(light!.extension<AppColorsExtension>()?.primary, AppColors.primary);
    expect(
      dark!.extension<AppColorsExtension>()?.primary,
      AppColorsExtension.dark.primary,
    );
    expect(light!.scaffoldBackgroundColor, AppColorsExtension.light.background);
    expect(dark!.scaffoldBackgroundColor, AppColorsExtension.dark.background);
    expect(tester.takeException(), isNull);
  });
}
