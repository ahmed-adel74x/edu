// The remote data source against a fake adapter: the documented login payload
// parses, and every documented failure maps to the right Failure.

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:test_edu/core/network/failure.dart';
import 'package:test_edu/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:test_edu/shared/models/user_role.dart';

import '../../../helpers/fake_http_adapter.dart';

/// The documented 200 body of `POST /student/login`.
Map<String, dynamic> loginBody({String role = 'student'}) => {
  'status': true,
  'message': 'Logged in',
  'data': {
    'token': 'token-123',
    'profile': {
      'user_id': '42',
      'student_id': 'S-9',
      'student_code': 'CODE-9',
      'name': 'Ahmed',
      'email': 'ahmed@example.com',
      'mobile': '0500000000',
      'gender': 'male',
      'role': role,
      'address': 'Riyadh',
      'image': 'image.png',
      'cover': 'cover.png',
      'academic': {
        'system': 'general',
        'stage': 'secondary',
        'grade': '3',
        'class': 'A',
      },
    },
  },
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
  AuthRemoteDataSource dataSource(HttpClientAdapter adapter) =>
      AuthRemoteDataSource(dio: dioWith(adapter));

  group('login', () {
    test('parses the token and the full profile', () async {
      final adapter = FakeHttpAdapter((_) => jsonResponse(loginBody()));

      final result = await dataSource(
        adapter,
      ).login(email: 'ahmed@example.com', password: '123456');

      expect(result.token, 'token-123');
      final user = result.user;
      expect(user.userId, '42');
      expect(user.studentId, 'S-9');
      expect(user.studentCode, 'CODE-9');
      expect(user.name, 'Ahmed');
      expect(user.email, 'ahmed@example.com');
      expect(user.mobile, '0500000000');
      expect(user.gender, 'male');
      expect(user.address, 'Riyadh');
      expect(user.image, 'image.png');
      expect(user.cover, 'cover.png');
      expect(user.role, UserRole.student);
      expect(user.academic.system, 'general');
      expect(user.academic.stage, 'secondary');
      expect(user.academic.grade, '3');
      expect(user.academic.className, 'A');
    });

    test('posts the credentials to the student login path', () async {
      final adapter = FakeHttpAdapter((_) => jsonResponse(loginBody()));

      await dataSource(
        adapter,
      ).login(email: 'ahmed@example.com', password: 'secret');

      expect(adapter.lastRequest!.path, '/student/login');
      expect(adapter.lastRequest!.data, {
        'email': 'ahmed@example.com',
        'password': 'secret',
      });
    });

    test('leaves the nullable fields null when the profile omits them', () async {
      final adapter = FakeHttpAdapter(
        (_) => jsonResponse({
          'status': true,
          'message': 'ok',
          'data': {
            'token': 'token-123',
            'profile': {
              'user_id': '1',
              'name': 'Min',
              'email': 'min@example.com',
              'role': 'student',
            },
          },
        }),
      );

      final user = (await dataSource(
        adapter,
      ).login(email: 'min@example.com', password: '123456')).user;

      expect(user.userId, '1');
      expect(user.mobile, '');
      expect(user.gender, isNull);
      expect(user.address, isNull);
      expect(user.image, isNull);
      expect(user.cover, isNull);
      expect(user.academic.system, isNull);
      expect(user.academic.className, isNull);
    });

    test('401 maps to UnauthorizedFailure with no error code', () async {
      final adapter = FakeHttpAdapter(
        (_) => jsonResponse({
          'status': false,
          'message': 'Invalid credentials',
          'data': null,
        }, statusCode: 401),
      );

      final failure = await failureOf(
        () => dataSource(adapter).login(email: 'a@b.c', password: '123456'),
      );

      expect(failure, isA<UnauthorizedFailure>());
      expect(failure.errorCode, isNull);
      expect(failure.statusCode, 401);
    });

    test('409 keeps STUDENT_ALREADY_LOGGED_IN', () async {
      final adapter = FakeHttpAdapter(
        (_) => jsonResponse({
          'status': false,
          'message': 'already signed in elsewhere',
          'error_code': FailureCodes.studentAlreadyLoggedIn,
        }, statusCode: 409),
      );

      final failure = await failureOf(
        () => dataSource(adapter).login(email: 'a@b.c', password: '123456'),
      );

      expect(failure, isA<ConflictFailure>());
      expect(failure.errorCode, FailureCodes.studentAlreadyLoggedIn);
    });

    test('422 maps to ValidationFailure with per-field messages', () async {
      final adapter = FakeHttpAdapter(
        (_) => jsonResponse({
          'status': false,
          'message': 'invalid',
          'error_code': FailureCodes.validationError,
          'errors': {
            'email': ['The email field is required.'],
            'password': ['The password must be at least 6 characters.'],
          },
        }, statusCode: 422),
      );

      final failure = await failureOf(
        () => dataSource(adapter).login(email: 'a@b.c', password: '123456'),
      );

      expect(failure, isA<ValidationFailure>());
      expect((failure as ValidationFailure).fieldErrors, {
        'email': ['The email field is required.'],
        'password': ['The password must be at least 6 characters.'],
      });
    });
  });

  group('logout', () {
    test('posts to the student logout path', () async {
      final adapter = FakeHttpAdapter(
        (_) => jsonResponse({'status': true, 'message': '', 'data': null}),
      );

      await dataSource(adapter).logout();

      expect(adapter.lastRequest!.path, '/student/logout');
    });

    test('401 UNAUTHENTICATED keeps the code', () async {
      final adapter = FakeHttpAdapter(
        (_) => jsonResponse({
          'status': false,
          'message': 'unauthenticated',
          'error_code': FailureCodes.unauthenticated,
        }, statusCode: 401),
      );

      final failure = await failureOf(() => dataSource(adapter).logout());

      expect(failure, isA<UnauthorizedFailure>());
      expect(failure.errorCode, FailureCodes.unauthenticated);
    });

    test('403 ENROLLMENT_PENDING keeps the code', () async {
      final adapter = FakeHttpAdapter(
        (_) => jsonResponse({
          'status': false,
          'message': 'enrollment pending',
          'error_code': FailureCodes.enrollmentPending,
          'data': {'enrollment_status': 'pending'},
        }, statusCode: 403),
      );

      final failure = await failureOf(() => dataSource(adapter).logout());

      expect(failure, isA<ForbiddenFailure>());
      expect(failure.errorCode, FailureCodes.enrollmentPending);
    });
  });
}
