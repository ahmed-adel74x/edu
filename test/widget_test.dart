// Widget tests for the explore courses screen.
//
// The screen loads its courses asynchronously, so every test waits for
// [ExploreCoursesScreen.loadingDuration] before touching the list. Note that
// `pumpAndSettle` must not be used here: the shimmer placeholders of
// [CourseCardSkeleton] animate forever.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:test_edu/core/widgets/app_pill.dart';
import 'package:test_edu/core/widgets/app_search_field.dart';
import 'package:test_edu/core/widgets/category_chip_row.dart';
import 'package:test_edu/core/widgets/empty_state_view.dart';
import 'package:test_edu/core/widgets/promo_banner.dart';
import 'package:test_edu/features/explore_courses/data/models/course.dart';
import 'package:test_edu/features/explore_courses/presentation/screens/explore_courses_screen.dart';
import 'package:test_edu/features/explore_courses/presentation/widgets/course_card.dart';
import 'package:test_edu/features/explore_courses/presentation/widgets/course_card_skeleton.dart';
import 'package:test_edu/main.dart';

/// The text field rendered by [AppSearchField].
final Finder searchFieldFinder = find.descendant(
  of: find.byType(AppSearchField),
  matching: find.byType(TextField),
);

/// Advances the clock past [ExploreCoursesScreen.loadingDuration] so the
/// courses replace the `CourseCardSkeleton` placeholders.
Future<void> finishLoading(WidgetTester tester) async {
  await tester.pump(ExploreCoursesScreen.loadingDuration);
  await tester.pump();
}

/// Pumps the app on a tall surface so every course card gets laid out.
///
/// Pass `waitForCourses: false` to inspect the loading placeholders.
Future<void> pumpExploreScreen(
  WidgetTester tester, {
  bool waitForCourses = true,
}) async {
  tester.view.physicalSize = const Size(1200, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MyApp());
  await tester.pump();
  if (waitForCourses) {
    await finishLoading(tester);
  }
}

/// Types [query] into the search field and rebuilds the screen.
Future<void> search(WidgetTester tester, String query) async {
  await tester.enterText(searchFieldFinder, query);
  await tester.pump();
}

void main() {
  testWidgets('shows the header, the promo banner and every course', (
    WidgetTester tester,
  ) async {
    await pumpExploreScreen(tester);

    expect(find.text('استكشاف الدورات'), findsOneWidget);
    expect(find.text('الدورات المتاحة'), findsOneWidget);
    expect(find.byType(PromoBanner), findsOneWidget);
    expect(find.text('4 دورات'), findsOneWidget);
    expect(
      find.ancestor(of: find.text('4 دورات'), matching: find.byType(AppPill)),
      findsOneWidget,
    );
    expect(find.byType(CourseCard), findsNWidgets(Course.samples.length));
  });

  testWidgets('shows shimmering placeholders while the courses load', (
    WidgetTester tester,
  ) async {
    await pumpExploreScreen(tester, waitForCourses: false);

    expect(find.byType(CourseCardSkeleton), findsWidgets);
    expect(find.byType(CourseCard), findsNothing);

    await finishLoading(tester);

    expect(find.byType(CourseCardSkeleton), findsNothing);
    expect(find.byType(CourseCard), findsNWidgets(Course.samples.length));
  });

  testWidgets('filters the courses when a category chip is selected', (
    WidgetTester tester,
  ) async {
    await pumpExploreScreen(tester);

    expect(find.byType(CategoryChipRow), findsOneWidget);
    expect(find.text('الكل'), findsOneWidget);
    expect(find.text('لغات'), findsOneWidget);

    await tester.tap(find.text('لغات'));
    await tester.pump();

    expect(find.byType(CourseCard), findsOneWidget);
    expect(find.text('تجربة الشهادات المعتمدة'), findsOneWidget);
    expect(find.text('دورة واحدة'), findsOneWidget);

    await tester.tap(find.text('الكل'));
    await tester.pump();

    expect(find.byType(CourseCard), findsNWidgets(Course.samples.length));
    expect(find.text('4 دورات'), findsOneWidget);
  });

  testWidgets('searches the courses by instructor and by title', (
    WidgetTester tester,
  ) async {
    await pumpExploreScreen(tester);

    await search(tester, 'سارة');

    expect(find.byType(CourseCard), findsOneWidget);
    expect(find.text('تطوير تطبيقات الموبايل'), findsOneWidget);

    await search(tester, 'الشهادات');

    expect(find.byType(CourseCard), findsOneWidget);
    expect(find.text('تجربة الشهادات المعتمدة'), findsOneWidget);

    await search(tester, '');

    expect(find.byType(CourseCard), findsNWidgets(Course.samples.length));
  });

  testWidgets('shows the empty state when nothing matches', (
    WidgetTester tester,
  ) async {
    await pumpExploreScreen(tester);

    await search(tester, 'دورة غير موجودة');

    expect(find.byType(CourseCard), findsNothing);
    expect(find.byType(EmptyStateView), findsOneWidget);
    expect(find.text('لا توجد دورات مطابقة'), findsOneWidget);
    expect(find.text('لا توجد دورات'), findsOneWidget);
    expect(
      find.text('جرّب تعديل كلمة البحث أو اختيار تصنيف آخر.'),
      findsOneWidget,
    );
  });
}
