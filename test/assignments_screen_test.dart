// Widget tests for the assignments screen.
//
// The screen keeps its search text and its status filter in local state, so
// each test pumps it on a phone-sized surface (ScreenUtil scales every size
// from the design size of 375x812) and then drives that state through the
// shared search field and filter bar.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:test_edu/core/constants/app_strings.dart';
import 'package:test_edu/navigation/app_bottom_nav_bar.dart';
import 'package:test_edu/navigation/student_shell.dart';
import 'package:test_edu/features/assignments/student/assignments_screen.dart';
import 'package:test_edu/features/assignments/widgets/assignment_card.dart';
import 'package:test_edu/features/home/student/home_screen.dart';
import 'package:test_edu/main.dart';

import 'helpers/app_test_harness.dart';
import 'helpers/auth_test_harness.dart';

/// Sizes the test surface like a phone: on a much larger canvas ScreenUtil
/// would scale every `.w`/`.sp` value past the screens' `maxWidth` column.
void useCanvas(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Pumps [AssignmentsScreen] on a `logicalSize`-sized phone.
Future<void> pumpAssignments(
  WidgetTester tester, {
  required Size logicalSize,
  double textScale = 1.0,
}) async {
  const dpr = 3.0;
  tester.view.devicePixelRatio = dpr;
  tester.view.physicalSize = Size(
    logicalSize.width * dpr,
    logicalSize.height * dpr,
  );
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(localizedApp(child: const AssignmentsScreen()));
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  setUp(prepareAppEnvironment);

  testWidgets('lays out without overflow on an iPhone-sized phone', (
    tester,
  ) async {
    await pumpAssignments(tester, logicalSize: const Size(393, 852));
    expect(tester.takeException(), isNull);
    expect(find.text('الواجبات والتكليفات'), findsOneWidget);
    expect(find.text('مستوى التميز'), findsOneWidget);
    expect(find.text('الكل (٤)'), findsOneWidget);
  });

  testWidgets('lays out without overflow on a narrow phone', (tester) async {
    await pumpAssignments(tester, logicalSize: const Size(320, 800));
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders every card on a tall surface', (tester) async {
    await pumpAssignments(tester, logicalSize: const Size(393, 3000));
    expect(tester.takeException(), isNull);
    expect(find.byType(AssignmentCard), findsNWidgets(4));
    expect(find.text('رفع الواجب'), findsOneWidget);
    expect(find.text('تحميل الشرح'), findsOneWidget);
  });

  testWidgets('shows the grader note and the per-status footers', (
    tester,
  ) async {
    await pumpAssignments(tester, logicalSize: const Size(393, 3000));
    expect(tester.takeException(), isNull);

    // Instructor feedback of the graded cards.
    expect(find.text('ملاحظات د. إبراهيم'), findsOneWidget);
    expect(find.text('ملاحظات د. منى'), findsOneWidget);

    // The graded footer pairs the answer-file action with the submission date.
    expect(find.text('عرض ملف الإجابة والشهادة'), findsNWidgets(2));
    expect(find.text('تم التسليم في: 2026-05-02'), findsOneWidget);

    // The under-review card shows the uploaded file, its time and its actions.
    expect(find.text('تم تسليم الملف: UI_CaseStudy_Final.fig'), findsOneWidget);
    expect(find.text('أمس، 08:30 م'), findsOneWidget);
    expect(find.text('معاينة المرفق'), findsOneWidget);
    expect(find.text('إعادة الإرسال'), findsOneWidget);

    // Design order: the answer-file button leads the row (right, in RTL) and
    // the submission date trails it, mirrored on the under-review card.
    expect(
      tester.getCenter(find.text('عرض ملف الإجابة والشهادة').first).dx >
          tester.getCenter(find.text('تم التسليم في: 2026-05-02')).dx,
      isTrue,
    );
    expect(
      tester.getCenter(find.text('إعادة الإرسال')).dx >
          tester.getCenter(find.text('معاينة المرفق')).dx,
      isTrue,
    );
  });

  testWidgets('every card action is wired without throwing', (tester) async {
    await pumpAssignments(tester, logicalSize: const Size(393, 3000));

    for (final label in [
      'رفع الواجب',
      'تحميل الشرح',
      'معاينة المرفق',
      'إعادة الإرسال',
    ]) {
      await tester.tap(find.text(label));
      await tester.pump(const Duration(milliseconds: 200));
    }
    await tester.tap(find.text('عرض ملف الإجابة والشهادة').first);
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the design order of the header and hero rows', (
    tester,
  ) async {
    await pumpAssignments(tester, logicalSize: const Size(393, 3000));

    // Hero: the star action sits on the far left, the level chip on the right.
    expect(
      tester.getCenter(find.byIcon(Icons.star_rounded)).dx <
          tester.getCenter(find.text('مستوى التميز')).dx,
      isTrue,
    );

    // Search row: the shared [AppSearchField] keeps the tune button at the
    // start of the row (the right, in RTL) like the explore screen.
    expect(
      tester.getCenter(find.byIcon(Icons.tune_rounded)).dx >
          tester.getCenter(find.byType(TextField)).dx,
      isTrue,
    );

    // The pink hand-in action is the left-hand button of the pair.
    expect(
      tester.getCenter(find.text('رفع الواجب')).dx <
          tester.getCenter(find.text('تحميل الشرح')).dx,
      isTrue,
    );

    // Filter bar: "الكل" opens the row on the right.
    expect(
      tester.getCenter(find.text('الكل (٤)')).dx >
          tester.getCenter(find.text('قيد الانتظار (١)')).dx,
      isTrue,
    );
  });

  testWidgets('filters by status and by search text', (tester) async {
    await pumpAssignments(tester, logicalSize: const Size(393, 2400));

    await tester.tap(find.text('قيد الانتظار (١)'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(AssignmentCard), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('الكل (٤)'));
    await tester.pump(const Duration(milliseconds: 300));
    // The list is scrollable, so assert the previously hidden card is back
    // rather than how many cards fit in the viewport.
    expect(find.text('تصميم شاشات تطبيق دراسي'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Binary');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(AssignmentCard), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens from the shared bottom navigation without disturbing '
      'the other tabs', (tester) async {
    useCanvas(tester, const Size(390, 844));
    await tester.pumpWidget(
      MyApp(auth: signedInAuthCubit(), assetLoader: memoryAssetLoader),
    );
    await tester.pump(const Duration(milliseconds: 600));

    NavigationBar navBar() =>
        tester.widget<NavigationBar>(find.byType(NavigationBar));

    // One shared bar, with the assignments item inserted after explore and the
    // existing items keeping their order.
    expect(find.byType(AppBottomNavBar), findsOneWidget);
    expect(
      navBar().destinations
          .cast<NavigationDestination>()
          .map((destination) => destination.label)
          .toList(),
      [
        AppStrings.navHome,
        AppStrings.navMyCourses,
        AppStrings.navExplore,
        AppStrings.navAssignments,
        AppStrings.navProfile,
      ],
    );
    expect(navBar().selectedIndex, StudentShell.homeIndex);
    expect(find.byType(HomeScreen), findsOneWidget);

    await tester.tap(find.text('الواجبات'));
    await tester.pump(const Duration(milliseconds: 600));

    expect(navBar().selectedIndex, StudentShell.assignmentsIndex);
    expect(find.byType(AssignmentsScreen), findsOneWidget);
    expect(find.text('مستوى التميز'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Back to the home tab: the shell keeps one bar and swaps the body.
    await tester.tap(find.text('الرئيسية'));
    await tester.pump(const Duration(milliseconds: 600));

    expect(navBar().selectedIndex, StudentShell.homeIndex);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('مستوى التميز'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the shared navigation bar clean at a large text scale', (
    tester,
  ) async {
    // The assignments tab made the bar five destinations wide, so the tightest
    // case for it is a narrow phone with the text scale pushed to 1.6.
    for (final width in [320.0, 360.0, 393.0]) {
      const scale = 1.6;
      final layoutLabel = 'bar $width @$scale';
      useCanvas(tester, Size(width, 852));
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(
        localizedApp(
          child: Scaffold(
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: StudentShell.assignmentsIndex,
              destinations: StudentShell.destinations,
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull, reason: layoutLabel);
    }
  });

  testWidgets('stays clean across phone sizes and text scales', (tester) async {
    for (final size in [
      const Size(320, 568),
      const Size(375, 667),
      const Size(393, 852),
      const Size(540, 960),
    ]) {
      for (final scale in [1.0, 1.6]) {
        final layoutLabel = 'layout ${size.width}x${size.height} @$scale';
        await pumpAssignments(tester, logicalSize: size, textScale: scale);
        expect(tester.takeException(), isNull, reason: layoutLabel);

        // Force the cards below the fold to lay out as well.
        await tester.scrollUntilVisible(
          find.text('تم التقييم: ٩٢/١٠٠'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pump();
        expect(tester.takeException(), isNull, reason: 'scrolled $layoutLabel');
      }
    }
  });
}
