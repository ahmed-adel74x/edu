// Widget tests for the home dashboard: the payload it renders, the states it can
// be in (loading, failure, success), the shell integration and the shared bottom
// navigation.
//
// Two sizing facts drive how these tests are written:
//   * every dimension comes from `flutter_screenutil` (design canvas 375x812),
//     so they pump on a *phone-sized* surface — a much larger surface would
//     rescale every `.w`/`.sp` value;
//   * the widget tester renders text with the 1em-per-glyph test font, i.e.
//     Arabic strings are about twice as wide as they are with Tajawal. The
//     dashboard is therefore asserted section by section (it is taller than a
//     phone), and the suite never *paints* the explore tab: that screen is
//     outside this file's scope and keeps its own tests.
//
// The payload is served by a fake repository (see `helpers/home_test_harness`),
// so nothing here touches the network.

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:test_edu/core/network/failure.dart';
import 'package:test_edu/core/network/result.dart';
import 'package:test_edu/core/theme/app_colors_extension.dart';
import 'package:test_edu/core/utils/failure_message.dart';
import 'package:test_edu/core/utils/number_format.dart';
import 'package:test_edu/features/auth/constants/auth_strings.dart';
import 'package:test_edu/features/auth/cubit/auth_cubit.dart';
import 'package:test_edu/features/home/constants/home_strings.dart';
import 'package:test_edu/features/home/cubit/home_cubit.dart';
import 'package:test_edu/features/home/cubit/home_state.dart';
import 'package:test_edu/features/home/data/models/home_summary.dart';
import 'package:test_edu/features/home/student/home_screen.dart';
import 'package:test_edu/features/home/student/widgets/attendance_activity_card.dart';
import 'package:test_edu/features/home/student/widgets/compact_course_tile.dart';
import 'package:test_edu/features/home/student/widgets/continue_course_card.dart';
import 'package:test_edu/features/home/student/widgets/recent_chat_tile.dart';
import 'package:test_edu/features/home/student/widgets/recent_quiz_card.dart';
import 'package:test_edu/features/home/student/widgets/stat_tile_grid.dart';
import 'package:test_edu/features/home/student/widgets/upcoming_task_card.dart';
import 'package:test_edu/features/home/student/widgets/welcome_hero_card.dart';
import 'package:test_edu/main.dart';
import 'package:test_edu/navigation/app_bottom_nav_bar.dart';
import 'package:test_edu/navigation/student_shell.dart';
import 'package:test_edu/shared/widgets/empty_state_view.dart';

import 'helpers/app_test_harness.dart';
import 'helpers/auth_test_harness.dart';
import 'helpers/home_test_harness.dart';

/// A common phone canvas (iPhone 14-ish), in logical pixels.
const Size phoneSize = Size(390, 844);

/// A small phone canvas (iPhone SE-ish), used for the overflow check.
const Size smallPhoneSize = Size(320, 568);

/// The session the dashboard reads its greeting from, seeded per test.
late AuthCubit session;

void useCanvas(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Pumps just the home screen, inside the app's localization + theme setup and
/// under a signed-in session.
Future<void> pumpHomeScreen(
  WidgetTester tester, {
  Size size = phoneSize,
  Locale locale = appFallbackLocale,
}) async {
  useCanvas(tester, size);
  await tester.pumpWidget(
    localizedApp(
      locale: locale,
      child: BlocProvider<AuthCubit>.value(
        value: session,
        child: const HomeScreen(),
      ),
    ),
  );
  // The first frame shows the loader; the payload lands on the frame after it
  // (the repository's future resolves between the two pumps).
  await tester.pump();
  await tester.pump();
}

/// Pumps the whole app (shell + tabs), letting the explore tab's simulated fetch
/// finish so no timer is left pending at teardown.
///
/// The session is injected as a signed-in student: the app itself starts signed
/// out and would open login instead of the shell.
Future<void> pumpApp(WidgetTester tester, {Size size = phoneSize}) async {
  useCanvas(tester, size);
  await tester.pumpWidget(MyApp(auth: session, assetLoader: memoryAssetLoader));
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
Future<void> reveal(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(target, 200, scrollable: homeScrollable());
}

/// Runs [action] against the dashboard's own cubit, the way the pull-to-refresh
/// gesture and the retry button do. The cubit lives below [HomeScreen] (the
/// screen builds its own provider), so it is read from a descendant.
Future<void> onHomeCubit(
  WidgetTester tester,
  Future<void> Function(HomeCubit cubit) action,
) async {
  final cubit = tester.element(find.byType(Scaffold).first).read<HomeCubit>();
  await action(cubit);
  await tester.pump();
}

/// The dashboard cubit's current state, read from a descendant of [HomeScreen].
HomeState homeState(WidgetTester tester) =>
    tester.element(find.byType(Scaffold).first).read<HomeCubit>().state;

/// A context inside the dashboard, in the language in force — for reading the
/// format-helpers' output.
///
/// It is anchored on the screen, not on a section: a `ListView` disposes the
/// children that scroll out of view, so anything below the fold (the attendance
/// card, for one) would have no context of its own once `reveal` has scrolled.
BuildContext contentContext(WidgetTester tester) =>
    tester.element(find.byType(HomeScreen));

/// The fill of every bar the attendance chart painted, in order. The chart
/// paints exactly one [DecoratedBox] per month — its bars — and nothing else.
List<Color?> attendanceBarFills(WidgetTester tester) => tester
    .widgetList<DecoratedBox>(
      find.descendant(
        of: find.byType(AttendanceActivityChart),
        matching: find.byType(DecoratedBox),
      ),
    )
    .map((box) => (box.decoration as BoxDecoration).color)
    .toList();

void main() {
  setUp(() async {
    await prepareAppEnvironment();
    session = signedInAuthCubit();
  });

  testWidgets('shows the loader until the payload arrives', (tester) async {
    final repository = FakeHomeRepository();
    when(() => repository.getHome()).thenAnswer(
      (_) => Completer<Result<HomeSummary>>().future,
    );
    registerTestHome(repository: repository);

    useCanvas(tester, phoneSize);
    await tester.pumpWidget(
      localizedApp(
        child: BlocProvider<AuthCubit>.value(
          value: session,
          child: const HomeScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(WelcomeHeroCard), findsNothing);
  });

  testWidgets('shows the greeting, the stat tiles and the courses', (
    tester,
  ) async {
    await pumpHomeScreen(tester);

    expect(find.text(HomeStrings.welcomeTitle(testUserName)), findsOneWidget);
    expect(find.text(HomeStrings.browseNew), findsOneWidget);
    expect(find.byType(WelcomeHeroCard), findsOneWidget);
    expect(find.byType(StatTileGrid), findsOneWidget);

    for (final label in [
      HomeStrings.statEnrolledCourses,
      HomeStrings.statStudyHours,
      HomeStrings.statCompletedCourses,
      HomeStrings.statCertificates,
    ]) {
      expect(find.text(label), findsOneWidget);
    }

    expect(find.text(HomeStrings.continueLearningTitle), findsOneWidget);
    expect(find.text(HomeStrings.seeAll), findsOneWidget);

    await reveal(tester, find.text(featuredCourseTitle));
    expect(find.byType(ContinueCourseCard), findsOneWidget);
    expect(find.text(featuredCourseInstructor), findsOneWidget);
    expect(find.text(HomeStrings.progressLabel), findsOneWidget);
    expect(find.text(HomeStrings.continueLessonCta), findsOneWidget);

    final context = contentContext(tester);
    expect(
      find.text(HomeStrings.remainingLectures(formatNumber(context, 5))),
      findsOneWidget,
    );

    await reveal(tester, find.text(nextCourseTitle));
    expect(find.byType(CompactCourseTile), findsOneWidget);
    expect(find.text(nextCourseInstructor), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets("counts are printed in the language's own digits", (
    tester,
  ) async {
    await pumpHomeScreen(tester);
    final context = contentContext(tester);
    final tiles = find.byType(StatTileGrid);

    for (final value in [
      formatNumber(context, 3),
      formatDecimal(context, 12.5),
      formatNumber(context, 7),
      formatNumber(context, 1),
    ]) {
      expect(
        find.descendant(of: tiles, matching: find.text(value)),
        findsOneWidget,
      );
    }

    // Arabic reads Arabic-Indic ("٣"), never Western ("3").
    expect(find.text('٣'), findsOneWidget);
    expect(find.text('3'), findsNothing);
  });

  testWidgets('shows the upcoming tasks with their deadlines', (tester) async {
    await pumpHomeScreen(tester);

    final context = contentContext(tester);

    await reveal(tester, find.text(firstTaskTitle));

    expect(find.text(HomeStrings.upcomingTitle), findsOneWidget);
    expect(
      find.text(HomeStrings.upcomingBadge(formatNumber(context, 2))),
      findsOneWidget,
    );

    // The lecture is the card's secondary line.
    expect(find.text(featuredCourseLecture), findsOneWidget);
    expect(find.text(HomeStrings.assignmentAction), findsAtLeastNWidgets(1));

    // The parseable deadline is localized, not echoed raw.
    expect(find.text(HomeStrings.dueDate('2026-10-04 21:00:00')), findsNothing);

    await reveal(tester, find.text(secondTaskTitle));

    // The deadline the backend wrote as prose falls back to the raw string
    // rather than vanishing.
    expect(find.text(HomeStrings.dueDate('not a date')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('charts one bar per month and highlights the current one', (
    tester,
  ) async {
    await pumpHomeScreen(tester);
    await reveal(tester, find.byType(AttendanceActivityChart));
    await tester.pumpAndSettle(); // the bars' grow-in finishes

    // One bar per month the backend sent, reading the *lectures* series: the
    // percentage as a 0..1 ratio, a month that held no lectures flat at zero,
    // and only the last month marked as the one in progress.
    final chart = tester.widget<AttendanceActivityChart>(
      find.byType(AttendanceActivityChart),
    );
    expect(chart.bars, hasLength(attendanceMonths.length));
    expect(chart.bars.map((bar) => bar.ratio).toList(), [0.9, 0.0, 0.425, 1.0]);
    expect(chart.bars.map((bar) => bar.isActive).toList(), [
      true,
      false,
      true,
      true,
    ]);
    expect(chart.bars.map((bar) => bar.isCurrent).toList(), [
      false,
      false,
      false,
      true,
    ]);

    const palette = AppColorsExtension.light;
    expect(attendanceBarFills(tester), [
      palette.primary, // January: lectures attended, brand blue
      palette.borderStrong, // February: no lectures held, neutral
      palette.primary, // March
      palette.accent, // the current month, highlighted
    ]);
    expect(tester.takeException(), isNull);
  });

  for (final locale in appSupportedLocales) {
    testWidgets(
      'names the months in ${locale.languageCode}, never the server copy',
      (tester) async {
        await pumpHomeScreen(tester, locale: locale);
        await reveal(tester, find.byType(AttendanceActivityChart));

        // The same rule the screen follows: the label is the month *number*,
        // rendered in the language in force. The year is irrelevant to a
        // month's name, so any one of them does.
        final monthName = DateFormat.MMM(locale.toLanguageTag());
        for (final month in attendanceMonths) {
          expect(
            find.text(monthName.format(DateTime(2026, month))),
            findsOneWidget,
            reason: 'month $month in ${locale.languageCode}',
          );
        }

        // The API's own `month_name` is English: it must never reach the learner
        // — not even in English, which reads the short form instead.
        expect(find.text('January'), findsNothing);
        expect(find.text('September'), findsNothing);
      },
    );
  }

  testWidgets('the attendance subtitle counts the payload\'s own lectures', (
    tester,
  ) async {
    await pumpHomeScreen(tester);
    await reveal(tester, find.byType(AttendanceActivityCard));
    expect(
      find.text(
        HomeStrings.attendanceSubtitle(
          formatNumber(contentContext(tester), attendanceAttendedLectures),
          formatNumber(contentContext(tester), attendanceTotalLectures),
        ),
      ),
      findsOneWidget,
    );

    // The same payload in English: the numbers follow the language, not the
    // server's formatting.
    await pumpHomeScreen(tester, locale: const Locale('en'));
    await reveal(tester, find.byType(AttendanceActivityCard));
    expect(
      find.text(
        HomeStrings.attendanceSubtitle(
          formatNumber(contentContext(tester), attendanceAttendedLectures),
          formatNumber(contentContext(tester), attendanceTotalLectures),
        ),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a chart that held no lectures keeps the card and says so', (
    tester,
  ) async {
    registerTestHome(
      repository: fakeHomeRepository(summary: unattendedHomeSummary()),
    );
    await pumpHomeScreen(tester);
    await reveal(tester, find.byType(AttendanceActivityCard));

    expect(find.text(HomeStrings.attendanceTitle), findsOneWidget);
    expect(find.text(HomeStrings.emptyAttendanceTitle), findsOneWidget);
    expect(find.text(HomeStrings.emptyAttendanceMessage), findsOneWidget);
    expect(find.byType(AttendanceActivityChart), findsNothing);

    // "attended 0 out of 0" would be noise, so the subtitle is left out.
    final context = contentContext(tester);
    expect(
      find.text(
        HomeStrings.attendanceSubtitle(
          formatNumber(context, 0),
          formatNumber(context, 0),
        ),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a full year of attendance fits a narrow phone', (tester) async {
    registerTestHome(
      repository: fakeHomeRepository(summary: fullYearAttendanceHomeSummary()),
    );
    await pumpHomeScreen(tester, size: smallPhoneSize);
    await reveal(tester, find.byType(AttendanceActivityChart));

    // Twelve bars, twelve labels, on a 320-wide canvas: an overflow would be
    // thrown as a rendering exception.
    expect(attendanceBarFills(tester), hasLength(12));
    expect(tester.takeException(), isNull);
  });

  for (final locale in appSupportedLocales) {
    testWidgets(
      'shows the recent quizzes and chats in ${locale.languageCode}',
      (tester) async {
        await pumpHomeScreen(tester, locale: locale);
        final context = contentContext(tester);

        // Recent quizzes: both attempts, the shared attempt id included — it is
        // not an identity, so it must not collapse the second card.
        await reveal(tester, find.text(HomeStrings.recentQuizzesTitle));
        expect(find.text(firstQuizTitle), findsOneWidget);
        expect(find.text(HomeStrings.quizScoreLabel), findsWidgets);
        expect(
          find.text(HomeStrings.percent(formatNumber(context, 80))),
          findsOneWidget,
        );

        // The second attempt's title is the scroll target; the two cards sit
        // next to each other, so both are laid out together.
        await reveal(tester, find.text(secondQuizTitle));
        expect(find.byType(RecentQuizCard), findsNWidgets(2));
        expect(find.text(secondQuizTitle), findsOneWidget);
        expect(find.text(firstQuizCourse), findsOneWidget);
        expect(
          find.text(HomeStrings.percent(formatNumber(context, 43))),
          findsOneWidget,
        );

        // Recent chats: both rooms, the latest message and its localized time.
        await reveal(tester, find.text(secondChatRoom));
        expect(find.byType(RecentChatTile), findsNWidgets(2));
        expect(find.text(firstChatRoom), findsOneWidget);
        expect(find.text(secondChatRoom), findsOneWidget);
        expect(find.text(lastChatMessage), findsOneWidget);
        expect(
          find.text(
            DateFormat.MMMd(
              locale.toLanguageTag(),
            ).add_Hm().format(DateTime.parse('2026-09-22T10:00:00')),
          ),
          findsOneWidget,
        );

        // The time of the last message never appears raw.
        expect(find.text(lastChatMessageAt), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('a quiz with no course name drops that line only', (
    tester,
  ) async {
    await pumpHomeScreen(tester);
    await reveal(tester, find.text(secondQuizTitle));

    // The second attempt has no course name, so the card shows its title, its
    // score and its date — and no course line at all.
    expect(find.text(firstQuizCourse), findsOneWidget);
    final second = tester.widget<RecentQuizCard>(
      find.byType(RecentQuizCard).last,
    );
    expect(second.quiz.courseName, isNull);
    expect(second.quiz.title, secondQuizTitle);
    expect(second.quiz.scoreLabel, isNotEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a quiz with an unreadable date keeps its score and title', (
    tester,
  ) async {
    await pumpHomeScreen(tester);
    await reveal(tester, find.text(secondQuizTitle));

    // `submitted_at` arrived as prose, so there is no date to localize: the
    // card omits the line rather than echoing the raw string.
    final second = tester.widget<RecentQuizCard>(
      find.byType(RecentQuizCard).last,
    );
    expect(second.quiz.submittedAt, isNull);
    expect(find.text(secondQuizTitle), findsOneWidget);
    expect(find.text('not a date'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the two new sections sit between assignments and attendance', (
    tester,
  ) async {
    await pumpHomeScreen(tester);
    // Both new headers are close enough to be on screen at once, so their
    // vertical order can be read directly.
    await reveal(tester, find.text(HomeStrings.recentChatsTitle));

    final quizzes = tester.getTopLeft(find.text(HomeStrings.recentQuizzesTitle));
    final chats = tester.getTopLeft(find.text(HomeStrings.recentChatsTitle));
    expect(quizzes.dy, lessThan(chats.dy), reason: 'quizzes before chats');

    // …and the attendance card is the last section of the dashboard.
    await reveal(tester, find.text(HomeStrings.attendanceTitle));
    expect(tester.getTopLeft(find.text(HomeStrings.attendanceTitle)).dy,
        greaterThan(chats.dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a chat with no last message says so instead', (tester) async {
    await pumpHomeScreen(tester);
    await reveal(tester, find.text(secondChatRoom));

    // The second room sent no last message: it shows the placeholder, and no
    // time that would have to be invented.
    final silent = tester.widget<RecentChatTile>(
      find.byType(RecentChatTile).last,
    );
    expect(silent.chat.roomName, secondChatRoom);
    expect(silent.chat.lastMessage, isNull);
    expect(silent.chat.lastMessageAt, isNull);
    expect(find.text(HomeStrings.chatNoMessages), findsOneWidget);

    // The avatar takes the first character of the room's own name.
    expect(silent.chat.initial, secondChatRoom.characters.first);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the new sections lay out on a narrow phone at 1.3x text', (
    tester,
  ) async {
    registerTestHome(
      repository: fakeHomeRepository(summary: fullYearAttendanceHomeSummary()),
    );
    await pumpHomeScreen(tester, size: smallPhoneSize);
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    // The scale is a global test value: it must not follow the suite into the
    // tests that run after this one.
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    // Walking down through both new sections at the smallest canvas the app
    // targets, with the largest text scale it supports.
    await reveal(tester, find.text(HomeStrings.recentQuizzesTitle));
    await reveal(tester, find.text(HomeStrings.recentChatsTitle));
    await reveal(tester, find.byType(AttendanceActivityChart));

    expect(find.byType(RecentChatTile), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a learner with nothing yet gets a section-level empty state', (
    tester,
  ) async {
    registerTestHome(repository: fakeHomeRepository(summary: emptyHomeSummary()));
    await pumpHomeScreen(tester);

    expect(find.byType(ContinueCourseCard), findsNothing);
    expect(find.byType(CompactCourseTile), findsNothing);
    expect(find.byType(UpcomingTaskCard), findsNothing);
    expect(find.byType(RecentQuizCard), findsNothing);
    expect(find.byType(RecentChatTile), findsNothing);

    // Every section reports its own emptiness, in its own words. They are
    // asserted one by one — a `ListView` builds only what is on screen, so a
    // single count across the whole dashboard would only see the first few.
    for (final section in [
      (HomeStrings.emptyCoursesTitle, HomeStrings.emptyCoursesMessage),
      (HomeStrings.emptyAssignmentsTitle, HomeStrings.emptyAssignmentsMessage),
      (HomeStrings.emptyQuizzesTitle, HomeStrings.emptyQuizzesMessage),
      (HomeStrings.emptyChatsTitle, HomeStrings.emptyChatsMessage),
      (HomeStrings.emptyAttendanceTitle, HomeStrings.emptyAttendanceMessage),
    ]) {
      await reveal(tester, find.text(section.$1));
      expect(find.text(section.$1), findsOneWidget, reason: section.$1);
      expect(find.text(section.$2), findsOneWidget, reason: section.$2);
      expect(find.byType(EmptyStateView), findsWidgets);
    }
    expect(find.textContaining('بانتظارك'), findsNothing);
    expect(find.byType(AttendanceActivityChart), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed load offers a retry that reloads', (tester) async {
    final repository = scriptedHomeRepository(
      (call) => call == 0
          ? const Error<HomeSummary>(NetworkFailure(message: 'offline'))
          : Success<HomeSummary>(sampleHomeSummary()),
    );
    registerTestHome(repository: repository);

    await pumpHomeScreen(tester);

    expect(find.text(FailureStrings.network), findsOneWidget);
    expect(find.text(HomeStrings.retry), findsOneWidget);
    expect(find.byType(StatTileGrid), findsNothing);

    await tester.tap(find.text(HomeStrings.retry));
    await tester.pump();

    expect(find.byType(StatTileGrid), findsOneWidget);
    expect(find.text(featuredCourseTitle), findsOneWidget);
    verify(() => repository.getHome()).called(2);
  });

  testWidgets('a blocked account is offered the only way out: signing out', (
    tester,
  ) async {
    registerTestHome(
      repository: fakeHomeRepository(
        failure: const ForbiddenFailure(
          message: 'pending',
          errorCode: FailureCodes.enrollmentPending,
          statusCode: 403,
        ),
      ),
    );

    await pumpHomeScreen(tester);

    expect(find.text(FailureStrings.enrollmentPending), findsOneWidget);
    expect(find.text(AuthStrings.logout), findsOneWidget);
    expect(find.text(HomeStrings.retry), findsNothing);

    await tester.tap(find.text(AuthStrings.logout));
    await tester.pump();

    expect(session.state.isAuthenticated, isFalse);
  });

  testWidgets('a failed refresh keeps the data and reports it once', (
    tester,
  ) async {
    registerTestHome(
      repository: scriptedHomeRepository(
        (call) => call == 0
            ? Success<HomeSummary>(sampleHomeSummary())
            : const Error<HomeSummary>(NetworkFailure(message: 'offline')),
      ),
    );

    await pumpHomeScreen(tester);
    await reveal(tester, find.text(featuredCourseTitle));

    await onHomeCubit(tester, (cubit) => cubit.refresh());
    await tester.pump();

    expect(find.text(FailureStrings.network), findsOneWidget);
    // The payload it already had is still on screen.
    expect(find.text(featuredCourseTitle), findsOneWidget);

    // The failure is one-shot: reporting it cleared it, so it can't be shown
    // again on a later rebuild.
    expect(homeState(tester).status, HomeStatus.success);
    expect(homeState(tester).refreshFailure, isNull);

    // Let the SnackBar's own timer run out, so nothing is left pending.
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('pull-to-refresh asks the cubit for a fresh payload', (
    tester,
  ) async {
    final repository = scriptedHomeRepository(
      (_) => Success<HomeSummary>(sampleHomeSummary()),
    );
    registerTestHome(repository: repository);

    await pumpHomeScreen(tester);
    // The dashboard is up, so the payload came from the repository.
    expect(homeState(tester).status, HomeStatus.success);

    // Pull the dashboard down, well past the indicator's own trigger distance
    // (a quarter of the viewport), then let its snap animation run: the
    // refresh itself starts when that animation finishes.
    await tester.fling(find.byType(ListView), const Offset(0, 320), 1200);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // Two calls in all — the load and the refresh. A single call can only be
    // verified once, so this counts both instead of one per `verify`.
    verify(() => repository.getHome()).called(2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lays out without overflow on a small phone', (tester) async {
    await pumpHomeScreen(tester, size: smallPhoneSize);

    // Walking the whole dashboard exercises every section; an overflow would
    // be thrown as a rendering exception.
    await reveal(tester, find.text(secondTaskTitle));

    expect(find.byType(UpcomingTaskCard), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the shell exposes one shared navigation bar for every tab', (
    tester,
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
