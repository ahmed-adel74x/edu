import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_edu/features/course_details/presentation/screens/course_details_screen.dart';
import 'package:test_edu/features/home/presentation/screens/home_screen.dart';
import 'package:test_edu/features/home/presentation/widgets/compact_course_tile.dart';
import 'package:test_edu/features/home/presentation/widgets/continue_course_card.dart';
import 'package:test_edu/features/explore_courses/presentation/widgets/course_card.dart';
import 'package:test_edu/main.dart';

/// Finder scoped to the details page (the list behind it stays in the tree).
Finder inDetails(String text) => find.descendant(
  of: find.byType(CourseDetailsScreen),
  matching: find.text(text),
);

Future<void> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MyApp());
  await tester.pump();
}

void main() {
  testWidgets('home: continue card opens the tapped course, back returns', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.byType(HomeScreen), findsOneWidget);

    await tester.tap(find.byType(ContinueCourseCard));
    await tester.pumpAndSettle();

    expect(find.byType(CourseDetailsScreen), findsOneWidget);
    expect(inDetails('تجربة للدورات (المحاضرات)'), findsOneWidget);
    expect(inDetails('أحمد سعيد - Ahmed Teacher3'), findsOneWidget);
    expect(inDetails('٪65'), findsOneWidget);

    await tester.tap(find.byTooltip('رجوع'));
    await tester.pumpAndSettle();

    expect(find.byType(CourseDetailsScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('home: compact tile opens its own course', (tester) async {
    await pumpApp(tester);

    await tester.ensureVisible(find.byType(CompactCourseTile));
    await tester.tap(find.byType(CompactCourseTile));
    await tester.pumpAndSettle();

    expect(inDetails('أساسيات وتطوير الويب'), findsOneWidget);
    expect(inDetails('المدرب: janaaaa'), findsOneWidget);
  });

  testWidgets('explore: card opens the course it represents', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('استكشاف'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump();

    expect(find.byType(CourseCard), findsWidgets);

    await tester.ensureVisible(find.byType(CourseCard).at(1));
    await tester.pump();
    await tester.tap(find.byType(CourseCard).at(1));
    await tester.pumpAndSettle();

    expect(find.byType(CourseDetailsScreen), findsOneWidget);
    expect(inDetails('تطوير تطبيقات الموبايل'), findsOneWidget);
    expect(inDetails('سارة علي'), findsOneWidget);
    expect(inDetails('36 ساعة'), findsOneWidget);
    expect(inDetails('تطوير تطبيقات'), findsOneWidget);
  });
}
