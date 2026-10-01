// The three locked screens (Home, Explore, Course Details) must build in every
// combination of language and theme, and the longer English copy must still fit
// their layouts.
//
// Sizing: every screen sizes itself through `flutter_screenutil` (design canvas
// 375x812), so the canvases here stay phone-sized.
//
// The explore screen's simulated fetch is advanced by
// [ExploreCoursesScreen.loadingDuration]; `pumpAndSettle` must not be used
// because the loading skeletons animate forever.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:test_edu/core/theme/app_colors_extension.dart';
import 'package:test_edu/features/course_details/constants/course_details_strings.dart';
import 'package:test_edu/features/course_details/student/course_details_screen.dart';
import 'package:test_edu/features/course_details/widgets/course_stat_grid.dart';
import 'package:test_edu/features/explore_courses/constants/explore_courses_strings.dart';
import 'package:test_edu/features/explore_courses/student/explore_courses_screen.dart';
import 'package:test_edu/features/home/constants/home_strings.dart';
import 'package:test_edu/features/home/student/home_screen.dart';
import 'package:test_edu/main.dart';
import 'package:test_edu/shared/widgets/app_icon_tile.dart';

import 'helpers/app_test_harness.dart';

/// A common phone canvas (iPhone 14-ish), and a narrow one for English copy.
const phoneSize = Size(390, 844);
const smallPhoneSize = Size(320, 640);

void useCanvas(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Pumps one screen in the given language and theme.
Future<void> pumpScreen(
  WidgetTester tester, {
  required Widget screen,
  required Locale locale,
  required bool dark,
  Size size = phoneSize,
}) async {
  useCanvas(tester, size);
  await tester.pumpWidget(
    localizedApp(child: screen, locale: locale, dark: dark),
  );
  await tester.pump();
  await tester.pump(ExploreCoursesScreen.loadingDuration);
  await tester.pump();
}

/// Drags the screen's own scrollable through everything below the fold, so a
/// layout that only breaks further down is caught as well.
Future<void> walkThrough(WidgetTester tester, {int steps = 10}) async {
  for (var step = 0; step < steps; step++) {
    await tester.drag(
      find.byType(Scrollable).first,
      const Offset(0, -320),
      warnIfMissed: false,
    );
    await tester.pump();
    expect(tester.takeException(), isNull, reason: 'scroll step $step');
  }
}

void main() {
  setUp(prepareAppEnvironment);

  for (final locale in appSupportedLocales) {
    for (final dark in [false, true]) {
      final combination = '${locale.languageCode}/${dark ? 'dark' : 'light'}';

      testWidgets('home builds in $combination', (tester) async {
        await pumpScreen(
          tester,
          screen: const HomeScreen(),
          locale: locale,
          dark: dark,
        );

        expect(find.text(HomeStrings.welcomeTitle), findsOneWidget);
        expect(find.text(HomeStrings.continueLearningTitle), findsOneWidget);
        await walkThrough(tester);
      });

      testWidgets('explore builds in $combination', (tester) async {
        await pumpScreen(
          tester,
          screen: const ExploreCoursesScreen(),
          locale: locale,
          dark: dark,
        );

        expect(find.text(ExploreCoursesStrings.screenTitle), findsOneWidget);
        expect(find.text(ExploreCoursesStrings.sectionTitle), findsOneWidget);
        await walkThrough(tester);
      });

      testWidgets('course details builds in $combination', (tester) async {
        await pumpScreen(
          tester,
          screen: CourseDetailsScreen(
            course: CourseDetailsScreen.sample(AppColorsExtension.light),
          ),
          locale: locale,
          dark: dark,
        );

        expect(find.text(CourseDetailsStrings.screenTitle), findsOneWidget);
        await walkThrough(tester);
      });
    }
  }

  testWidgets('the English copy fits on a narrow phone', (tester) async {
    const locale = Locale('en');

    await pumpScreen(
      tester,
      screen: const HomeScreen(),
      locale: locale,
      dark: false,
      size: smallPhoneSize,
    );
    await walkThrough(tester, steps: 14);

    await pumpScreen(
      tester,
      screen: const ExploreCoursesScreen(),
      locale: locale,
      dark: false,
      size: smallPhoneSize,
    );
    // The catalogue plus everything under it.
    await walkThrough(tester, steps: 18);

    await pumpScreen(
      tester,
      screen: CourseDetailsScreen(
        course: CourseDetailsScreen.sample(AppColorsExtension.light),
      ),
      locale: locale,
      dark: false,
      size: smallPhoneSize,
    );
    await walkThrough(tester, steps: 18);
  });

  testWidgets(
    'course details carries no light-only color into the dark theme',
    (tester) async {
      const dark = AppColorsExtension.dark;
      const light = AppColorsExtension.light;

      await pumpScreen(
        tester,
        screen: CourseDetailsScreen(course: CourseDetailsScreen.sample(dark)),
        locale: const Locale('ar'),
        dark: true,
      );

      // The placeholder summary tiles are the model's own colors: in the dark
      // theme every one of them must come from the dark palette.
      final tiles = tester
          .widgetList<AppIconTile>(
            find.descendant(
              of: find.byType(CourseStatGrid),
              matching: find.byType(AppIconTile),
            ),
          )
          .toList();
      expect(tiles, isNotEmpty);

      final darkTints = {dark.tintMint, dark.tintLavender, dark.tintPeach};
      final lightTints = {light.tintMint, light.tintLavender, light.tintPeach};
      final darkInks = {dark.accent, dark.primary, dark.warningDeep};

      for (final tile in tiles) {
        expect(darkTints, contains(tile.background));
        expect(lightTints, isNot(contains(tile.background)));
        expect(darkInks, contains(tile.color));
      }
      expect(tester.takeException(), isNull);
    },
  );
}
