// Navigation tests for the course details page.
//
// The page is reached from three places: the continue card and the compact tile
// of the home dashboard, and a course card of the explore list. Each test opens
// it from one of them and checks the copy that the tapped course handed over.
//
// Two sizing facts drive how these tests are written:
//   * every screen sizes itself with `flutter_screenutil` (design canvas
//     375x812), so the surface stays phone-sized — a wider canvas would
//     rescale the screens past their `maxWidth` column. The sections below the
//     fold are reached by scrolling;
//   * the shell keeps every tab alive, so the explore tab's simulated fetch is
//     left to finish before teardown, and no timer outlives its test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:test_edu/core/constants/app_strings.dart';
import 'package:test_edu/core/utils/number_format.dart';
import 'package:test_edu/features/course_details/student/course_details_screen.dart';
import 'package:test_edu/features/explore_courses/student/explore_courses_screen.dart';
import 'package:test_edu/features/explore_courses/widgets/course_card.dart';
import 'package:test_edu/features/home/constants/home_strings.dart';
import 'package:test_edu/features/home/student/home_screen.dart';
import 'package:test_edu/features/home/student/widgets/compact_course_tile.dart';
import 'package:test_edu/features/home/student/widgets/continue_course_card.dart';
import 'package:test_edu/main.dart';

import 'helpers/app_test_harness.dart';
import 'helpers/auth_test_harness.dart';

/// A common phone canvas (iPhone 14-ish), in logical pixels.
const Size phoneSize = Size(390, 844);

/// Finder scoped to the details page (the list behind it stays in the tree).
Finder inDetails(String text) => find.descendant(
  of: find.byType(CourseDetailsScreen),
  matching: find.text(text),
);

/// The details page's own context, for the copy it renders in the locale's
/// digits (the app counts with Arabic-Indic numerals in Arabic).
BuildContext detailsContext(WidgetTester tester) =>
    tester.element(find.byType(CourseDetailsScreen));

/// Pumps the app on a phone canvas, letting the explore tab's simulated fetch
/// finish so that no timer is left pending at teardown.
Future<void> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MyApp(auth: signedInAuthCubit(), assetLoader: memoryAssetLoader),
  );
  await tester.pump();
  await tester.pump(ExploreCoursesScreen.loadingDuration);
  await tester.pump();
}

/// The home dashboard's scrollable (the shell keeps every tab alive).
Finder homeScrollable() => find
    .descendant(of: find.byType(HomeScreen), matching: find.byType(Scrollable))
    .first;

/// The explore list's scrollable (the chip row adds a horizontal one inside it,
/// so the outer sliver view comes first).
Finder exploreScrollable() => find
    .descendant(
      of: find.byType(ExploreCoursesScreen),
      matching: find.byType(Scrollable),
    )
    .first;

/// Scrolls [scrollable] until [target] can be tapped, then taps it.
Future<void> scrollAndTap(
  WidgetTester tester,
  Finder target,
  Finder scrollable,
) async {
  await tester.scrollUntilVisible(target, 200, scrollable: scrollable);
  await tester.pump();
  await tester.ensureVisible(target);
  await tester.pump();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

/// The details page's back affordance: the arrow that points back in RTL.
Finder detailsBackButton() => find.descendant(
  of: find.byType(CourseDetailsScreen),
  matching: find.byIcon(Icons.arrow_forward_rounded),
);

void main() {
  setUp(prepareAppEnvironment);

  testWidgets('home: continue card opens the tapped course, back returns', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.byType(HomeScreen), findsOneWidget);

    await scrollAndTap(
      tester,
      find.byType(ContinueCourseCard),
      homeScrollable(),
    );

    expect(find.byType(CourseDetailsScreen), findsOneWidget);
    expect(inDetails('تجربة للدورات (المحاضرات)'), findsOneWidget);
    expect(inDetails('أحمد سعيد - Ahmed Teacher3'), findsOneWidget);
    // The 65% the continue card showed, handed over as-is — in the digits of the
    // locale the app opened in, which for Arabic are Arabic-Indic.
    expect(
      inDetails(HomeStrings.percent(formatNumber(detailsContext(tester), 65))),
      findsOneWidget,
    );

    await tester.tap(detailsBackButton());
    await tester.pumpAndSettle();

    expect(find.byType(CourseDetailsScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('home: compact tile opens its own course', (tester) async {
    await pumpApp(tester);

    await scrollAndTap(
      tester,
      find.byType(CompactCourseTile),
      homeScrollable(),
    );

    expect(find.byType(CourseDetailsScreen), findsOneWidget);
    expect(inDetails('أساسيات وتطوير الويب'), findsOneWidget);
    expect(inDetails('المدرب: janaaaa'), findsOneWidget);
  });

  testWidgets('explore: card opens the course it represents', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text(AppStrings.navExplore));
    await tester.pump();

    // The second course of the catalogue, which sits below the fold. It is
    // addressed by its title rather than by index: an index finder throws
    // while the list has not built that far.
    final secondCard = find.ancestor(
      of: find.descendant(
        of: find.byType(ExploreCoursesScreen),
        matching: find.text(ExploreCoursesScreen.courses[1].title),
      ),
      matching: find.byType(CourseCard),
    );
    await scrollAndTap(tester, secondCard, exploreScrollable());

    expect(find.byType(CourseDetailsScreen), findsOneWidget);
    expect(inDetails('تطوير تطبيقات الموبايل'), findsOneWidget);
    expect(inDetails('سارة علي'), findsOneWidget);
    expect(inDetails('36 ساعة'), findsOneWidget);
    expect(inDetails('تطوير تطبيقات'), findsOneWidget);
  });
}
