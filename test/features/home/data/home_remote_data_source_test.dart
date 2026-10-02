// The home data source against a fake adapter: the documented dashboard payload
// parses (with its quirks), and every documented failure maps to the right
// Failure.

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:test_edu/core/network/failure.dart';
import 'package:test_edu/features/home/data/data_sources/home_remote_data_source.dart';

import '../../../helpers/fake_http_adapter.dart';

/// The documented 200 body of `GET /student/home`.
Map<String, dynamic> homeBody(Map<String, dynamic> data) => {
  'status': true,
  'message': 'ok',
  'data': data,
  'errors': null,
  'error_code': null,
  'pagination': null,
};

/// Runs [action] and returns the [Failure] it threw.
Future<Failure> failureOf(Future<void> Function() action) async {
  try {
    await action();
  } on Failure catch (failure) {
    return failure;
  }
  fail('expected the data source to throw a Failure');
}

void main() {
  HomeRemoteDataSource dataSource(HttpClientAdapter adapter) =>
      HomeRemoteDataSource(dio: dioWith(adapter));

  test('reads the student home path', () async {
    final adapter = FakeHttpAdapter((_) => jsonResponse(homeBody(const {})));

    await dataSource(adapter).fetchHome();

    expect(adapter.lastRequest!.path, '/student/home');
  });

  test('parses the documented blocks', () async {
    final adapter = FakeHttpAdapter(
      (_) => jsonResponse(
        homeBody({
          'counts': {
            'enrolled_courses': 3,
            'study_hours': 12.5,
            'completed_courses': 7,
            'certificates': 1,
          },
          'enrolled_courses': [
            {
              'course_id': 11,
              'title': 'أساسيات البرمجة',
              'cover_path': 'https://cdn.example.test/c.png',
              'teacher_name': 'أحمد',
              'progress_percentage': 65,
              'completed_lectures': 13,
              'total_lectures': 20,
              'remaining_lectures': 5,
            },
          ],
          'upcoming_assignments': [
            {
              'homework_id': 21,
              'assignment_title': 'واجب المحاضرة ٣',
              'lecture_title': 'المحاضرة ٣',
              'due_date': '2026-10-04 21:00:00',
            },
          ],
          'recent_quizzes': [
            {
              'attempt_id': 7,
              'quiz_title': 'اختبار الوحدة الأولى',
              'course_name': 'أساسيات البرمجة',
              'score_percent': 80,
              'submitted_at': '2026-09-21 21:04:45',
            },
          ],
        }),
      ),
    );

    final summary = await dataSource(adapter).fetchHome();

    expect(summary.counts.enrolledCourses, 3);
    expect(summary.counts.studyHours, 12.5);
    expect(summary.counts.completedCourses, 7);
    expect(summary.counts.certificates, 1);

    final course = summary.enrolledCourses.single;
    expect(course.courseId, 11);
    expect(course.title, 'أساسيات البرمجة');
    expect(course.coverPath, 'https://cdn.example.test/c.png');
    expect(course.teacherName, 'أحمد');
    expect(course.progressPercentage, 65);
    expect(course.remainingLectures, 5);

    final assignment = summary.upcomingAssignments.single;
    expect(assignment.homeworkId, 21);
    expect(assignment.assignmentTitle, 'واجب المحاضرة ٣');
    expect(assignment.dueDateAt, DateTime.parse('2026-10-04T21:00:00'));

    final quiz = summary.recentQuizzes.single;
    expect(quiz.submittedAtAt, DateTime.parse('2026-09-21T21:04:45'));
  });

  test('reads numbers as num and never assumes int', () async {
    final adapter = FakeHttpAdapter(
      (_) => jsonResponse(
        homeBody({
          'counts': {'study_hours': '4.25', 'enrolled_courses': '2'},
          'enrolled_courses': [
            {'progress_percentage': 33.5, 'remaining_lectures': '4'},
          ],
        }),
      ),
    );

    final summary = await dataSource(adapter).fetchHome();

    expect(summary.counts.studyHours, 4.25);
    expect(summary.counts.enrolledCourses, 2);
    expect(summary.enrolledCourses.single.progressPercentage, 33.5);
    expect(summary.enrolledCourses.single.remainingLectures, 4);
  });

  test(
    'tolerates a missing data block, a missing key and a null value',
    () async {
      final adapter = FakeHttpAdapter(
        (_) => jsonResponse(
          homeBody({
            'enrolled_courses': [
              // No cover, no teacher: both stay null rather than throwing.
              {'title': 'بدون غلاف', 'cover_path': null, 'teacher_name': null},
            ],
          }),
        ),
      );

      final summary = await dataSource(adapter).fetchHome();

      expect(summary.counts.enrolledCourses, 0);
      expect(summary.recentQuizzes, isEmpty);
      expect(summary.upcomingAssignments, isEmpty);
      expect(summary.recentChats, isEmpty);
      expect(summary.attendanceChart, isEmpty);
      expect(summary.enrolledCourses.single.coverPath, isNull);
      expect(summary.enrolledCourses.single.teacherName, isNull);
    },
  );

  test('keeps every item when the payload repeats an attempt id', () async {
    final adapter = FakeHttpAdapter(
      (_) => jsonResponse(
        homeBody({
          'recent_quizzes': [
            {'attempt_id': 7, 'quiz_title': 'الأول'},
            {'attempt_id': 7, 'quiz_title': 'الثاني'},
          ],
        }),
      ),
    );

    final summary = await dataSource(adapter).fetchHome();

    expect(summary.recentQuizzes.map((quiz) => quiz.quizTitle), [
      'الأول',
      'الثاني',
    ]);
  });

  test(
    'an unparseable date leaves the raw string and a null DateTime',
    () async {
      final adapter = FakeHttpAdapter(
        (_) => jsonResponse(
          homeBody({
            'upcoming_assignments': [
              {'assignment_title': 'واجب', 'due_date': 'غدًا'},
            ],
          }),
        ),
      );

      final assignment = (await dataSource(adapter).fetchHome())
          .upcomingAssignments
          .single;

      expect(assignment.dueDate, 'غدًا');
      expect(assignment.dueDateAt, isNull);
    },
  );

  test('403 ENROLLMENT_PENDING keeps the backend code', () async {
    final adapter = FakeHttpAdapter(
      (_) => jsonResponse({
        'status': false,
        'message': 'enrollment pending',
        'error_code': FailureCodes.enrollmentPending,
      }, statusCode: 403),
    );

    final failure = await failureOf(() => dataSource(adapter).fetchHome());

    expect(failure, isA<ForbiddenFailure>());
    expect(failure.errorCode, FailureCodes.enrollmentPending);
    expect(failure.statusCode, 403);
  });

  test('401 maps to UnauthorizedFailure', () async {
    final adapter = FakeHttpAdapter(
      (_) => jsonResponse({
        'status': false,
        'message': 'unauthenticated',
      }, statusCode: 401),
    );

    final failure = await failureOf(() => dataSource(adapter).fetchHome());

    expect(failure, isA<UnauthorizedFailure>());
    expect(failure.statusCode, 401);
  });

  test('a 200 whose status is false is a failure too', () async {
    final adapter = FakeHttpAdapter(
      (_) => jsonResponse({'status': false, 'message': 'no dashboard'}),
    );

    final failure = await failureOf(() => dataSource(adapter).fetchHome());

    expect(failure, isA<UnknownFailure>());
    expect(failure.message, 'no dashboard');
  });

  test('an offline socket maps to NetworkFailure', () async {
    final adapter = FakeHttpAdapter(
      (_) => throw DioException.connectionError(
        requestOptions: RequestOptions(path: '/student/home'),
        reason: 'offline',
      ),
    );

    final failure = await failureOf(() => dataSource(adapter).fetchHome());

    expect(failure, isA<NetworkFailure>());
  });
}

