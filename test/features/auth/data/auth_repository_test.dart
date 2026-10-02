// The repository over the real data sources: the network is answered by a fake
// adapter and secure storage by an in-memory fake, so the whole path is exercised.

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:test_edu/core/network/failure.dart';
import 'package:test_edu/core/network/result.dart';
import 'package:test_edu/core/storage/token_storage.dart';
import 'package:test_edu/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:test_edu/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:test_edu/features/auth/data/repositories/auth_repository.dart';
import 'package:test_edu/shared/models/user.dart';
import 'package:test_edu/shared/models/user_role.dart';

import '../../../helpers/fake_http_adapter.dart';
import '../../../helpers/fake_secure_storage.dart';

Map<String, dynamic> loginBody(String role) => {
  'status': true,
  'message': 'ok',
  'data': {
    'token': 'token-123',
    'profile': {
      'user_id': '1',
      'name': 'Ahmed',
      'email': 'ahmed@example.com',
      'role': role,
    },
  },
};

User cachedUser() => const User(
  userId: '1',
  name: 'Ahmed',
  email: 'ahmed@example.com',
  role: UserRole.student,
);

void main() {
  late FakeSecureStorage storage;
  late TokenStorage tokenStorage;
  late AuthLocalDataSource local;

  setUp(() {
    storage = FakeSecureStorage();
    tokenStorage = TokenStorage(storage: storage);
    local = AuthLocalDataSource(tokenStorage: tokenStorage, storage: storage);
  });

  AuthRepository repositoryWith(HttpClientAdapter adapter) => AuthRepository(
    remote: AuthRemoteDataSource(dio: dioWith(adapter)),
    local: local,
  );

  test('a successful login keeps the session', () async {
    final adapter = FakeHttpAdapter((_) => jsonResponse(loginBody('student')));

    final result = await repositoryWith(
      adapter,
    ).login(email: 'a@b.c', password: '123456');

    expect(result, isA<Success<User>>());
    expect((result as Success<User>).data.role, UserRole.student);
    expect(await tokenStorage.read(), 'token-123');
    expect(await local.readSession(), isNotNull);
  });

  test('a non-student role is rejected, released and not kept', () async {
    final paths = <String>[];
    final adapter = FakeHttpAdapter((request) {
      paths.add(request.path);
      if (request.path.endsWith('/logout')) {
        return jsonResponse({'status': true, 'message': '', 'data': null});
      }
      return jsonResponse(loginBody('teacher'));
    });

    final result = await repositoryWith(
      adapter,
    ).login(email: 'a@b.c', password: '123456');

    expect(result, isA<Error<User>>());
    expect(
      (result as Error<User>).failure.errorCode,
      FailureCodes.unsupportedRole,
    );
    // The just-issued token was released again, and nothing stays on the device.
    expect(paths, contains('/student/logout'));
    expect(await tokenStorage.read(), isNull);
    expect(storage.data, isEmpty);
  });

  test('an unknown role is rejected too', () async {
    final adapter = FakeHttpAdapter((request) {
      if (request.path.endsWith('/logout')) {
        return jsonResponse({'status': true, 'message': '', 'data': null});
      }
      return jsonResponse(loginBody('admin'));
    });

    final result = await repositoryWith(
      adapter,
    ).login(email: 'a@b.c', password: '123456');

    expect(result, isA<Error<User>>());
    expect(
      (result as Error<User>).failure.errorCode,
      FailureCodes.unsupportedRole,
    );
  });

  test('logout clears the local session even when the server fails', () async {
    await local.saveSession(token: 'token-123', user: cachedUser());
    final adapter = FakeHttpAdapter(
      (_) => jsonResponse({'status': false, 'message': 'boom'}, statusCode: 500),
    );

    await repositoryWith(adapter).logout();

    expect(await tokenStorage.read(), isNull);
    expect(storage.data, isEmpty);
  });

  test('logout clears the local session on a dead token (401)', () async {
    await local.saveSession(token: 'token-123', user: cachedUser());
    final adapter = FakeHttpAdapter(
      (_) => jsonResponse({
        'status': false,
        'message': 'unauthenticated',
        'error_code': FailureCodes.unauthenticated,
      }, statusCode: 401),
    );

    await repositoryWith(adapter).logout();

    expect(await tokenStorage.read(), isNull);
    expect(storage.data, isEmpty);
  });

  test('logout clears the local session on a network error', () async {
    await local.saveSession(token: 'token-123', user: cachedUser());
    final adapter = FakeHttpAdapter(
      (_) => throw DioException.connectionError(
        requestOptions: RequestOptions(path: '/student/logout'),
        reason: 'offline',
      ),
    );

    await repositoryWith(adapter).logout();

    expect(await tokenStorage.read(), isNull);
    expect(storage.data, isEmpty);
  });

  test('restore reads the cache without touching the network', () async {
    await local.saveSession(token: 'token-123', user: cachedUser());
    final adapter = FakeHttpAdapter(
      (_) => throw StateError('no request expected'),
    );

    final user = await repositoryWith(adapter).restore();

    expect(user?.role, UserRole.student);
  });

  test('restore is null when nothing is cached', () async {
    final adapter = FakeHttpAdapter(
      (_) => throw StateError('no request expected'),
    );

    expect(await repositoryWith(adapter).restore(), isNull);
  });
}
