// Widget tests for the home dashboard and the shared bottom navigation.
//
// Two sizing facts drive how these tests are written:
//   * every dimension comes from `flutter_screenutil` (design canvas
//     375x812), so they pump on a *phone-sized* surface — a much larger
//     surface would rescale every `.w`/`.sp` value;
//   * the widget tester renders text with the 1em-per-glyph test font, i.e.
//     Arabic strings are about twice as wide as they are with Tajawal. The
//     dashboard is therefore asserted section by section (it is taller than
//     a phone), and the suite never *paints* the explore tab: that screen is
//     outside this file's scope and keeps its own tests.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:test_edu/core/theme/app_theme.dart';
import 'package:test_edu/features/auth/auth_notifier.dart';
import 'package:test_edu/navigation/app_bottom_nav_bar.dart';
import 'package:test_edu/navigation/student_shell.dart';
import 'package:test_edu/features/home/constants/home_strings.dart';
import 'package:test_edu/features/home/student/home_screen.dart';
import 'package:test_edu/features/home/student/widgets/stat_tile_grid.dart';
import 'package:test_edu/features/home/student/widgets/weekly_activity_card.dart';
import 'package:test_edu/main.dart';

/// A common phone canvas (iPhone 14-ish), in logical pixels.
const Size phoneSize = Size(390, 844);

/// A small phone canvas (iPhone SE-ish), used for the overflow check.
const Size smallPhoneSize = Size(320, 568);

void useCanvas(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Pumps just the home screen, with the same `ScreenUtilInit` + theme setup
/// the app itself uses.
Future<void> pumpHomeScreen(WidgetTester tester, {Size size = phoneSize}) async {
  useCanvas(tester, size);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.data(),
        home: const HomeScreen(),
      ),
    ),
  );
  await tester.pump();
}

/// Pumps the whole app (shell + tabs) and lets the explore tab's simulated
/// fetch finish, so no timer is left pending at teardown.
///
/// The session is injected as a signed-in student: the app itself starts signed
/// out and would open login instead of the shell.
Future<void> pumpApp(WidgetTester tester, {Size size = phoneSize}) async {
  useCanvas(tester, size);
  await tester.pumpWidget(MyApp(auth: AuthNotifier.signedIn()));
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

/// The home screen's scrollable (the shell keeps every tab alive, so the tree
/// can hold more than one scrollable).
Finder homeScrollable() => find.descendant(
      of: find.byType(HomeScreen),
      matching: find.byType(Scrollable),
    );

/// Scrolls the dashboard until [target] is on screen.

void main() {
  testWidgets('shows the greeting and the summary tiles', (
    WidgetTester tester,
  ) async {
    await pumpHomeScreen(tester);

    expect(find.text(HomeStrings.welcomeTitle), findsOneWidget);
    expect(find.text(HomeStrings.streakBadge), findsOneWidget);
    expect(find.text(HomeStrings.browseNew), findsOneWidget);

    // Every tile of the grid is driven by the screen's sample stats.
    for (final stat in HomeScreen.stats) {
      expect(find.text(stat.label), findsOneWidget);
      expect(find.text(stat.value), findsOneWidget);
    }
    expect(find.byType(StatTile), findsNWidgets(HomeScreen.stats.length));

    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the courses to continue', (WidgetTester tester) async {
    await pumpHomeScreen(tester);

    expect(find.text(HomeStrings.continueLearningTitle), findsOneWidget);
    expect(find.text(HomeStrings.seeAll), findsOneWidget);

    await reveal(tester, find.text(HomeScreen.featuredCourse.title));
    expect(find.text(HomeScreen.featuredCourse.instructor), findsOneWidget);
    expect(
      find.text(HomeScreen.featuredCourse.remainingLessons!),
      findsOneWidget,
    );
    expect(find.text(HomeStrings.progressLabel), findsOneWidget);
    expect(find.text(HomeScreen.featuredCourse.progressLabel), findsOneWidget);
    expect(find.text(HomeStrings.continueLessonCta), findsOneWidget);

    await reveal(tester, find.text(HomeScreen.nextCourse.title));
    expect(find.text(HomeScreen.nextCourse.instructor), findsOneWidget);
    expect(find.text(HomeScreen.nextCourse.progressLabel), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the upcoming tasks and the weekly activity chart', (
    WidgetTester tester,
  ) async {
    await pumpHomeScreen(tester);

    await reveal(tester, find.text(HomeScreen.tasks.first.title));
    expect(find.text(HomeStrings.upcomingTitle), findsOneWidget);
    expect(find.text(HomeStrings.upcomingBadge), findsOneWidget);
    expect(find.text(HomeScreen.tasks.first.meta!), findsOneWidget);
    expect(find.text(HomeScreen.tasks.first.countdown!), findsOneWidget);
    expect(find.text(HomeScreen.tasks.first.progressBadge!), findsOneWidget);
    expect(find.text(HomeScreen.tasks.first.actionLabel), findsOneWidget);

    await reveal(tester, find.text(HomeScreen.tasks.last.title));
    expect(find.text(HomeScreen.tasks.last.statusNote!), findsOneWidget);
    expect(find.text(HomeScreen.tasks.last.actionLabel), findsOneWidget);

    await reveal(tester, find.byType(WeeklyActivityChart));
    expect(find.text(HomeStrings.weeklyTitle), findsOneWidget);
    expect(find.text(HomeStrings.weeklyRangePill), findsOneWidget);
    for (final day in HomeScreen.week) {
      expect(find.text(day.label), findsOneWidget);
    }

    expect(tester.takeException(), isNull);
  });

  testWidgets('lays out without overflow on a small phone', (
    WidgetTester tester,
  ) async {
    await pumpHomeScreen(tester, size: smallPhoneSize);

    // Walking the whole dashboard exercises every section; an overflow would
    // be thrown as a rendering exception.
    await reveal(tester, find.byType(WeeklyActivityChart));

    expect(find.byType(WeeklyActivityChart), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the shell exposes one shared navigation bar for every tab', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    expect(find.byType(AppBottomNavBar), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);

    NavigationBar navBar() =>
        tester.widget<NavigationBar>(find.byType(NavigationBar));

    expect(navBar().selectedIndex, StudentShell.homeIndex);

    await tester.tap(find.text('دوراتي'));
    await tester.pump();
    expect(navBar().selectedIndex, StudentShell.myCoursesIndex);

    await tester.tap(find.text('الرئيسية'));
    await tester.pump();
    expect(navBar().selectedIndex, StudentShell.homeIndex);
    expect(find.byType(AppBottomNavBar), findsOneWidget);
  });
}

Future<void> reveal(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(target, 200, scrollable: homeScrollable());
}
