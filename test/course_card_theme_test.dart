// Bug guard: the Explore course card is the catalogue's only card that paints
// its own surface — every other card goes through the shared `AppCard` — so a
// hardcoded light fill could hide there while the rest of the screen darkened.
//
// The card is built on its own, inside the app's localization and theme, and
// read back through the widgets it paints with (not through its source).
//
// `pumpAndSettle` is safe here: a lone card has no looping animation. The
// loading skeleton, which shimmers forever, is pumped by hand and only once.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:test_edu/core/theme/app_colors_extension.dart';
import 'package:test_edu/features/explore_courses/student/explore_courses_screen.dart';
import 'package:test_edu/features/explore_courses/widgets/course_card.dart';
import 'package:test_edu/features/explore_courses/widgets/course_card_skeleton.dart';
import 'package:test_edu/main.dart';

import 'helpers/app_test_harness.dart';

/// A canvas the card is designed for (iPhone-ish), and the catalogue's own data.
const canvas = Size(390, 844);
final course = ExploreCoursesScreen.courses.first;

const light = AppColorsExtension.light;
const dark = AppColorsExtension.dark;

/// Builds one widget in the app's localization + theme, on a phone canvas.
Future<void> pumpIn(
  WidgetTester tester, {
  required Widget child,
  required Locale locale,
  required bool dark,
}) async {
  tester.view.physicalSize = canvas;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    localizedApp(
      child: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
      locale: locale,
      dark: dark,
    ),
  );
  await tester.pump();
}

Future<void> pumpCard(
  WidgetTester tester, {
  required Locale locale,
  required bool dark,
}) => pumpIn(
  tester,
  child: CourseCard(course: course),
  locale: locale,
  dark: dark,
);

/// The card's own fill: the decoration on the container it is built around.
BoxDecoration cardSurface(WidgetTester tester) {
  // The root container comes before the badges, the scrim and the favourite
  // button, so it is the first one inside the card.
  final card = tester.widget<Container>(
    find
        .descendant(
          of: find.byType(CourseCard),
          matching: find.byType(Container),
        )
        .first,
  );
  return card.decoration! as BoxDecoration;
}

/// Every fill the subtree paints, one entry per painted box.
List<Color> paintedFills(WidgetTester tester, Finder root) {
  final fills = <Color>[];

  for (final box in tester.widgetList<DecoratedBox>(
    find.descendant(of: root, matching: find.byType(DecoratedBox)),
  )) {
    final decoration = box.decoration;
    if (decoration is BoxDecoration && decoration.color != null) {
      fills.add(decoration.color!);
    }
  }
  for (final box in tester.widgetList<ColoredBox>(
    find.descendant(of: root, matching: find.byType(ColoredBox)),
  )) {
    fills.add(box.color);
  }

  return fills;
}

/// The colour the cover badge's label is painted in.
Color? badgeInk(WidgetTester tester) =>
    tester.widget<Text>(find.text(course.badge)).style!.color;

void main() {
  setUp(prepareAppEnvironment);

  for (final locale in appSupportedLocales) {
    testWidgets(
      'the course card sits on the dark surface in ${locale.languageCode}',
      (tester) async {
        await pumpCard(tester, locale: locale, dark: true);

        final surface = cardSurface(tester);
        expect(surface.color, dark.surface, reason: 'card fill');
        expect(surface.color, isNot(Colors.white), reason: 'not a white card');
        expect(surface.border!.top.color, dark.border, reason: 'card outline');
        expect(
          surface.boxShadow!.single.color,
          dark.shadow,
          reason: 'card shadow',
        );

        final fills = paintedFills(tester, find.byType(CourseCard));
        expect(fills, isNotEmpty);
        expect(
          fills,
          isNot(contains(Colors.white)),
          reason: 'nothing inside the card may stay white in the dark theme',
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('the dark surface survives the favourite state', (tester) async {
    await pumpCard(tester, locale: const Locale('ar'), dark: true);

    await tester.tap(find.byIcon(Icons.bookmark_border_rounded));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
    expect(cardSurface(tester).color, dark.surface);
    expect(
      paintedFills(tester, find.byType(CourseCard)),
      isNot(contains(Colors.white)),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the loading skeleton paints no white in the dark theme', (
    tester,
  ) async {
    await pumpIn(
      tester,
      child: const CourseCardSkeleton(),
      locale: const Locale('ar'),
      dark: true,
    );

    final fills = paintedFills(tester, find.byType(CourseCardSkeleton));
    expect(fills, isNotEmpty);
    expect(fills, isNot(contains(Colors.white)));
    expect(fills.every((fill) => fill == dark.surface), isTrue);
  });

  testWidgets('the cover badge flips its ink with the theme', (tester) async {
    // On the light palette the badge is the shipped white-on-accent.
    await pumpCard(tester, locale: const Locale('ar'), dark: false);
    expect(badgeInk(tester), Colors.white);

    // On the dark palette the accent is lifted to a light mint, so white would
    // disappear: the ink flips to the deep navy the palette pairs with it.
    //
    // `MaterialApp` animates between themes, so the second pump has to settle
    // before the palette in force is the dark one.
    await pumpCard(tester, locale: const Locale('ar'), dark: true);
    await tester.pumpAndSettle();
    expect(badgeInk(tester), dark.onPrimary);
    expect(badgeInk(tester), isNot(Colors.white));
  });

  testWidgets('the light card is unchanged: still the shipped white', (
    tester,
  ) async {
    await pumpCard(tester, locale: const Locale('en'), dark: false);

    // The light palette's surface is the constant the screens were designed
    // against, so the card cannot have moved.
    expect(light.surface, Colors.white);
    expect(cardSurface(tester).color, light.surface);
    expect(cardSurface(tester).color, Colors.white);
    expect(
      paintedFills(tester, find.byType(CourseCard)),
      contains(Colors.white),
    );
  });
}
