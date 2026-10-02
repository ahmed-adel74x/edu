// Home dashboard wiring for tests.
//
// The dashboard reads its payload from a `HomeRepository` and the learner's
// name from the session, so a test needs both. The repository is swapped for a
// mocktail mock, the cubit factory the screen pulls from the locator is
// registered, and the sample payload below is the one the dashboard's tests
// describe.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:test_edu/core/di/injection.dart';
import 'package:test_edu/core/network/failure.dart';
import 'package:test_edu/core/network/result.dart';
import 'package:test_edu/features/home/cubit/home_cubit.dart';
import 'package:test_edu/features/home/data/models/home_summary.dart';
import 'package:test_edu/features/home/data/repositories/home_repository.dart';

/// A stand-in [HomeRepository]; stub `getHome()` per test.
class FakeHomeRepository extends Mock implements HomeRepository {}

/// The literals of [sampleHomeSummary], so a test asserts on them by name
/// instead of repeating them (and can't drift from what the fixture serves).
const String featuredCourseTitle = 'تجربة للدورات (المحاضرات)';
const String featuredCourseInstructor = 'أحمد سعيد - Ahmed Teacher3';
const String featuredCourseLecture = 'المحاضرة ٣: إدارة الحالة';
const String nextCourseTitle = 'أساسيات وتطوير الويب';
const String nextCourseInstructor = 'المدرب: janaaaa';
const String firstTaskTitle = 'اختبار دورة جديدة';
const String secondTaskTitle = 'واجب المحاضرة ٣';
const String firstQuizTitle = 'اختبار الوحدة الأولى';
const String secondQuizTitle = 'اختبار الوحدة الثانية';
const String firstQuizCourse = 'أساسيات البرمجة';
const String firstQuizSubmittedAt = '2026-09-21 21:04:45';
const String firstChatRoom = 'مجموعة الدورة';
const String secondChatRoom = 'نادي البرمجة';
const String lastChatMessage = 'بالتوفيق!';
const String lastChatMessageAt = '2026-09-22 10:00:00';

/// The literals of [sampleHomeSummary]'s attendance chart: the months it shows
/// (the last one is the current month) and the lecture totals across them.
const List<int> attendanceMonths = [1, 2, 3, 9];
const int attendanceAttendedLectures = 45;
const int attendanceTotalLectures = 56;

/// One `attendance_chart` entry, as the API documents it: the month *number*,
/// the server's English `month_name` (which the app never displays), and the
/// two nested series. Percentages are `num`, never assumed whole.
Map<String, dynamic> attendanceMonthJson({
  required int month,
  required String monthName,
  required int total,
  required int attended,
  required num percentage,
}) => {
  'month': month,
  'month_name': monthName,
  'lectures': {'total': total, 'attended': attended, 'percentage': percentage},
  'courses': {'total': 0, 'attended': 0, 'percentage': 0},
};

/// A representative `GET /student/home` body: two courses, two assignments and
/// the counts, plus the blocks no dashboard section reads yet.
///
/// It deliberately keeps the backend's documented quirks in view: `study_hours`
/// is fractional, one course has no cover, the second assignment has neither a
/// lecture nor a due date, and two quizzes repeat the same `attempt_id`. The
/// attendance chart spans four months — one that held no lectures at all, one
/// whose percentage is fractional, and the current month last.
HomeSummary sampleHomeSummary() => HomeSummary.fromJson(sampleHomeJson());

/// The raw body behind [sampleHomeSummary], so a test can vary one block of it
/// (the attendance chart) without repeating the rest.
Map<String, dynamic> sampleHomeJson() => {
  'counts': {
    'enrolled_courses': 3,
    'study_hours': 12.5,
    'completed_courses': 7,
    'certificates': 1,
  },
  'enrolled_courses': [
    {
      'course_id': 11,
      'title': featuredCourseTitle,
      'teacher_name': featuredCourseInstructor,
      'progress_percentage': 65,
      'completed_lectures': 13,
      'total_lectures': 20,
      'remaining_lectures': 5,
      'cover_path': null,
    },
    {
      'course_id': 12,
      'title': nextCourseTitle,
      'teacher_name': nextCourseInstructor,
      'progress_percentage': 30,
      'completed_lectures': 6,
      'total_lectures': 20,
      'remaining_lectures': 14,
      'cover_path': 'https://cdn.example.test/course-12.png',
    },
  ],
  'upcoming_assignments': [
    {
      'homework_id': 21,
      'assignment_title': firstTaskTitle,
      'lecture_title': featuredCourseLecture,
      'due_date': '2026-10-04 21:00:00',
    },
    {
      'homework_id': 22,
      'assignment_title': secondTaskTitle,
      'lecture_title': '',
      'due_date': 'not a date',
    },
  ],
  'recent_quizzes': [
    {
      'attempt_id': 7,
      'quiz_title': firstQuizTitle,
      'course_name': firstQuizCourse,
      'score_percent': 80,
      'submitted_at': firstQuizSubmittedAt,
    },
    {
      // The same attempt id on purpose: it is not usable as a list key.
      'attempt_id': 7,
      'quiz_title': secondQuizTitle,
      'course_name': null,
      'score_percent': 42.5,
      'submitted_at': 'not a date',
    },
  ],
  'recent_chats': [
    {
      'room_id': 3,
      'room_name': firstChatRoom,
      'last_message': {'text': lastChatMessage, 'created_at': lastChatMessageAt},
    },
    // A room nothing has been said in yet: no last message at all.
    {'room_id': 4, 'room_name': secondChatRoom, 'last_message': null},
  ],
  'attendance_chart': [
    attendanceMonthJson(
      month: 1,
      monthName: 'January',
      total: 20,
      attended: 18,
      percentage: 90.0,
    ),
    // A month that held no lectures: the lowest, inactive bar.
    attendanceMonthJson(
      month: 2,
      monthName: 'February',
      total: 0,
      attended: 0,
      percentage: 0,
    ),
    attendanceMonthJson(
      month: 3,
      monthName: 'March',
      total: 16,
      attended: 7,
      percentage: 42.5,
    ),
    // The current month, last as the backend serves it.
    attendanceMonthJson(
      month: 9,
      monthName: 'September',
      total: 20,
      attended: 20,
      percentage: 100,
    ),
  ],
};

/// The payload of a learner who has nothing yet: every block empty.
HomeSummary emptyHomeSummary() => const HomeSummary();

/// The sample dashboard, but with a full year of attendance months (January to
/// December, the current month last) — the widest chart a phone has to fit.
HomeSummary fullYearAttendanceHomeSummary() => HomeSummary.fromJson({
  ...sampleHomeJson(),
  'attendance_chart': [
    for (var month = 1; month <= 12; month++)
      attendanceMonthJson(
        month: month,
        monthName: 'Month $month',
        total: 16,
        attended: 12,
        percentage: 75,
      ),
  ],
});

/// The sample dashboard, but no month of its attendance chart held a lecture
/// (`total` is 0 everywhere): the card keeps its title and shows its own empty
/// copy instead of a chart.
HomeSummary unattendedHomeSummary() => HomeSummary.fromJson({
  ...sampleHomeJson(),
  'attendance_chart': [
    attendanceMonthJson(
      month: 1,
      monthName: 'January',
      total: 0,
      attended: 0,
      percentage: 0,
    ),
    attendanceMonthJson(
      month: 2,
      monthName: 'February',
      total: 0,
      attended: 0,
      percentage: 0,
    ),
  ],
});

/// A [FakeHomeRepository] that always answers the same way.
///
/// Pass [summary] for a success (defaults to [sampleHomeSummary]); pass
/// [failure] to fail every call instead.
FakeHomeRepository fakeHomeRepository({
  HomeSummary? summary,
  Failure? failure,
}) {
  final repository = FakeHomeRepository();
  when(() => repository.getHome()).thenAnswer(
    (_) async => failure != null
        ? Error<HomeSummary>(failure)
        : Success<HomeSummary>(summary ?? sampleHomeSummary()),
  );
  return repository;
}

/// A [FakeHomeRepository] whose `getHome()` answer is chosen per call (the
/// `call` index starts at 0) — for the tests that need a first call to succeed
/// and a later one to fail, or the reverse.
FakeHomeRepository scriptedHomeRepository(
  Result<HomeSummary> Function(int call) answer,
) {
  final repository = FakeHomeRepository();
  var calls = 0;
  when(() => repository.getHome()).thenAnswer((_) async => answer(calls++));
  return repository;
}

/// Registers the home graph in the locator: [repository] (or a default fake)
/// behind the screen's own [HomeCubit] factory. The container is reset at
/// teardown, exactly like the auth harness does for the session.
///
/// A test that seeds a session first has already got the default graph (the
/// session harness registers it, because the student shell builds the
/// dashboard), so an earlier registration is replaced rather than rejected.
HomeRepository registerTestHome({HomeRepository? repository}) {
  final home = repository ?? fakeHomeRepository();

  if (getIt.isRegistered<HomeRepository>()) {
    getIt.unregister<HomeRepository>();
  }
  if (getIt.isRegistered<HomeCubit>()) {
    getIt.unregister<HomeCubit>();
  }

  getIt
    ..registerLazySingleton<HomeRepository>(() => home)
    ..registerFactory<HomeCubit>(() => HomeCubit(repository: getIt()));

  addTearDown(resetInjection);
  return home;
}
