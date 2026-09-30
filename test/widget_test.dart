// Widget tests for the explore courses screen.
//
// Four facts about the app drive how these tests are written:
//   * every dimension comes from `flutter_screenutil` (design canvas
//     375x812), so the surface stays phone-sized — a wider canvas would
//     rescale the screen past its `maxWidth` column;
//   * the shell keeps every tab alive, so the tests open the explore tab and
//     scope their finders to [ExploreCoursesScreen]: the assignments tab
//     brings a search field of its own;
//   * the list is taller than a phone, so anything below the fold is reached
//     with [reveal];
//   * the screen loads its courses asynchronously, so every test waits for
//     [ExploreCoursesScreen.loadingDuration] before touching the list. Note
//     that `pumpAndSettle` must not be used here: the shimmer placeholders of
//     [CourseCardSkeleton] animate forever.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:test_edu/core/constants/app_strings.dart';
import 'package:test_edu/core/widgets/app_pill.dart';
import 'package:test_edu/core/widgets/app_search_field.dart';
import 'package:test_edu/core/widgets/category_chip_row.dart';
import 'package:test_edu/core/widgets/empty_state_view.dart';
import 'package:test_edu/core/widgets/promo_banner.dart';
import 'package:test_edu/features/explore_courses/constants/explore_courses_strings.dart';
import 'package:test_edu/features/explore_courses/presentation/screens/explore_courses_screen.dart';
import 'package:test_edu/features/explore_courses/presentation/widgets/course_card.dart';
import 'package:test_edu/features/explore_courses/presentation/widgets/course_card_skeleton.dart';
import 'package:test_edu/main.dart';

/// A common phone canvas (iPhone 14-ish), in logical pixels.
const Size phoneSize = Size(390, 844);

/// The text field rendered by the explore screen's [AppSearchField].
///
/// Scoped to the screen because the shell keeps every tab alive: the
/// assignments tab contributes a search field of its own to the same tree.
final Finder searchFieldFinder = find.descendant(
  of: find.byType(ExploreCoursesScreen),
  matching: find.descendant(
    of: find.byType(AppSearchField),
    matching: find.byType(TextField),
  ),
);

/// The explore list's scrollable. The chip row adds a horizontal one inside
/// it, so the outer sliver view comes first.
Finder exploreScrollable() => find
    .descendant(
      of: find.byType(ExploreCoursesScreen),
      matching: find.byType(Scrollable),
    )
    .first;

/// The explore screen's card for [title]; the home tab may show the same
/// course, hence the scoping.
Finder courseTile(String title) => find.descendant(
      of: find.byType(ExploreCoursesScreen),
      matching: find.text(title),
    );

/// Advances the clock past [ExploreCoursesScreen.loadingDuration] so the
/// courses replace the `CourseCardSkeleton` placeholders.
Future<void> finishLoading(WidgetTester tester) async {
  await tester.pump(ExploreCoursesScreen.loadingDuration);
  await tester.pump();
}

/// Scrolls the explore list until [target] has been laid out. [delta] is
/// positive towards the end of the list, negative back towards its top.
Future<void> reveal(
  WidgetTester tester,
  Finder target, {
  double delta = 200,
}) async {
  await tester.scrollUntilVisible(target, delta, scrollable: exploreScrollable());
  await tester.pump();
}

/// Scrolls back to the search field: the sliver drops it once it leaves the
/// viewport, so it has to be brought back before typing again.
Future<void> backToSearchField(WidgetTester tester) async {
  if (searchFieldFinder.evaluate().isEmpty) {
    await reveal(tester, searchFieldFinder, delta: -200);
  }
}

/// Pumps the app on a phone canvas and opens the explore tab, where the
/// assertions below belong.
///
/// Pass `waitForCourses: false` to inspect the loading placeholders.
Future<void> pumpExploreScreen(
  WidgetTester tester, {
  bool waitForCourses = true,
}) async {
  tester.view.physicalSize = phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MyApp());
  await tester.pump();

  await tester.tap(find.text(AppStrings.navExplore));
  await tester.pump();

  if (waitForCourses) {
    await finishLoading(tester);
  } else {
    // Let the tab-switch animation run out without settling the never-ending
    // skeleton shimmer.
    await tester.pump(const Duration(milliseconds: 300));
  }
}

/// Types [query] into the search field and rebuilds the screen.
Future<void> search(WidgetTester tester, String query) async {
  await backToSearchField(tester);
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

    // Every course of the catalogue is rendered: walk the list from its top
    // to its bottom, one card at a time.
    for (final course in ExploreCoursesScreen.courses) {
      await reveal(tester, courseTile(course.title));
      expect(courseTile(course.title), findsOneWidget);
    }

    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the total-price caption right above the amount', (
    WidgetTester tester,
  ) async {
    await pumpExploreScreen(tester);

    final firstCourse = ExploreCoursesScreen.courses.first;
    await reveal(tester, courseTile(firstCourse.title));

    // The price block of the first card, read from the laid-out widgets: the
    // caption, the amount and the currency unit that rides next to it.
    final card = find.ancestor(
      of: courseTile(firstCourse.title),
      matching: find.byType(CourseCard),
    );
    Rect rectOf(String text) =>
        tester.getRect(find.descendant(of: card, matching: find.text(text)));

    final caption = rectOf(ExploreCoursesStrings.totalPrice);
    final amount = rectOf(firstCourse.price);
    final currency = rectOf(AppStrings.currencySar);

    // The app lays out RTL, so the leading edge of a price block is its right
    // one; the edge is read from the tree instead of being assumed.
    final cardDirection = Directionality.of(
      tester.element(find.byType(CourseCard).first),
    );
    double leadingEdge(Rect rect) =>
        cardDirection == TextDirection.rtl ? rect.right : rect.left;

    // The caption is the line above the amount...
    expect(caption.bottom, lessThanOrEqualTo(amount.top));
    // ...the amount leads the currency unit that shares its line...
    expect(leadingEdge(currency), lessThan(leadingEdge(amount)));
    // ...and the caption starts exactly where the amount starts. Aligning the
    // block to its trailing edge instead parks the caption above the currency,
    // because the line is wider than the number on its own.
    expect(
      leadingEdge(caption),
      moreOrLessEquals(leadingEdge(amount), epsilon: 0.5),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('shows shimmering placeholders while the courses load', (
    WidgetTester tester,
  ) async {
    await pumpExploreScreen(tester, waitForCourses: false);

    expect(find.byType(CourseCardSkeleton), findsWidgets);
    expect(find.byType(CourseCard), findsNothing);

    await finishLoading(tester);

    expect(find.byType(CourseCardSkeleton), findsNothing);
    expect(find.text('4 دورات'), findsOneWidget);

    // The catalogue replaces the placeholders, starting with its first card.
    await reveal(tester, courseTile(ExploreCoursesScreen.courses.first.title));
    expect(
      courseTile(ExploreCoursesScreen.courses.first.title),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
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

    expect(find.text('دورة واحدة'), findsOneWidget);
    await reveal(tester, courseTile('تجربة الشهادات المعتمدة'));
    expect(courseTile('تجربة الشهادات المعتمدة'), findsOneWidget);
    expect(find.byType(CourseCard), findsOneWidget);

    // Back to the full catalogue.
    await reveal(tester, find.text('الكل'), delta: -200);
    await tester.tap(find.text('الكل'));
    await tester.pump();

    expect(find.text('4 دورات'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('searches the courses by instructor and by title', (
    WidgetTester tester,
  ) async {
    await pumpExploreScreen(tester);

    await search(tester, 'سارة');
    expect(find.text('دورة واحدة'), findsOneWidget);
    await reveal(tester, courseTile('تطوير تطبيقات الموبايل'));
    expect(courseTile('تطوير تطبيقات الموبايل'), findsOneWidget);
    expect(find.byType(CourseCard), findsOneWidget);

    await search(tester, 'الشهادات');
    expect(find.text('دورة واحدة'), findsOneWidget);
    await reveal(tester, courseTile('تجربة الشهادات المعتمدة'));
    expect(courseTile('تجربة الشهادات المعتمدة'), findsOneWidget);

    await search(tester, '');
    expect(find.text('4 دورات'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the empty state when nothing matches', (
    WidgetTester tester,
  ) async {
    await pumpExploreScreen(tester);

    await search(tester, 'دورة غير موجودة');

    await reveal(tester, find.byType(EmptyStateView));
    expect(find.byType(CourseCard), findsNothing);
    expect(find.byType(EmptyStateView), findsOneWidget);
    expect(find.text('لا توجد دورات مطابقة'), findsOneWidget);
    expect(find.text('لا توجد دورات'), findsOneWidget);
    expect(
      find.text('جرّب تعديل كلمة البحث أو اختيار تصنيف آخر.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
