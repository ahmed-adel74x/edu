// The home repository over the real data source: the network is answered by a
// fake adapter, so the whole path is exercised. It returns a Result and never
// throws.

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:test_edu/core/network/failure.dart';
import 'package:test_edu/core/network/result.dart';
import 'package:test_edu/features/home/data/data_sources/home_remote_data_source.dart';
import 'package:test_edu/features/home/data/models/home_summary.dart';
import 'package:test_edu/features/home/data/repositories/home_repository.dart';

import '../../../helpers/fake_http_adapter.dart';

/// The documented 200 body of `GET /student/home`.
Map<String, dynamic> homeBody(Map<String, dynamic> data) => {
  'status': true,
  'message': 'ok',
  'data': data,
};

void main() {
  HomeRepository repositoryWith(HttpClientAdapter adapter) => HomeRepository(
    remote: HomeRemoteDataSource(dio: dioWith(adapter)),
  );

  test('a served dashboard comes back as a Success', () async {
    final adapter = FakeHttpAdapter(
      (_) => jsonResponse(
        homeBody({
          'counts': {'enrolled_courses': 3},
          'enrolled_courses': [
            {'course_id': 11, 'title': 'أساسيات البرمجة'},
          ],
        }),
      ),
    );

    final result = await repositoryWith(adapter).getHome();

    expect(result, isA<Success<HomeSummary>>());
    final summary = (result as Success<HomeSummary>).data;
    expect(summary.counts.enrolledCourses, 3);
    expect(summary.enrolledCourses.single.title, 'أساسيات البرمجة');
  });

  test('an empty dashboard is a Success with empty blocks', () async {
    final adapter = FakeHttpAdapter((_) => jsonResponse(homeBody(const {})));

    final result = await repositoryWith(adapter).getHome();

    expect(result, isA<Success<HomeSummary>>());
    expect((result as Success<HomeSummary>).data.enrolledCourses, isEmpty);
  });

  test('a server error comes back as an Error, never thrown', () async {
    final adapter = FakeHttpAdapter(
      (_) => jsonResponse({
        'status': false,
        'message': 'boom',
      }, statusCode: 500),
    );

    final result = await repositoryWith(adapter).getHome();

    expect(result, isA<Error<HomeSummary>>());
    final failure = (result as Error<HomeSummary>).failure;
    expect(failure, isA<ServerFailure>());
    expect(failure.statusCode, 500);
  });

  test('a blocked account keeps the backend code on the Error', () async {
    final adapter = FakeHttpAdapter(
      (_) => jsonResponse({
        'status': false,
        'message': 'enrollment pending',
        'error_code': FailureCodes.enrollmentPending,
      }, statusCode: 403),
    );

    final result = await repositoryWith(adapter).getHome();

    expect(
      (result as Error<HomeSummary>).failure.errorCode,
      FailureCodes.enrollmentPending,
    );
  });

  test('an offline socket comes back as a NetworkFailure', () async {
    final adapter = FakeHttpAdapter(
      (_) => throw DioException.connectionError(
        requestOptions: RequestOptions(path: '/student/home'),
        reason: 'offline',
      ),
    );

    final result = await repositoryWith(adapter).getHome();

    expect((result as Error<HomeSummary>).failure, isA<NetworkFailure>());
  });
}
