// The login cubit: the four outcomes plus the double-submit guard.

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:test_edu/core/network/failure.dart';
import 'package:test_edu/core/network/interceptors/auth_interceptor.dart';
import 'package:test_edu/core/network/result.dart';
import 'package:test_edu/features/auth/cubit/auth_cubit.dart';
import 'package:test_edu/features/auth/cubit/login_cubit.dart';
import 'package:test_edu/features/auth/cubit/login_state.dart';
import 'package:test_edu/shared/models/user.dart';
import 'package:test_edu/shared/models/user_role.dart';

import '../../../helpers/auth_test_harness.dart';

void main() {
  late FakeAuthRepository repository;
  late AuthCubit authCubit;
  late User user;

  setUp(() {
    repository = fakeAuthRepository();
    authCubit = AuthCubit(
      repository: repository,
      sessionEvents: SessionEvents(),
    );
    user = testUser(UserRole.student);
  });

  tearDown(() => authCubit.close());

  LoginCubit buildCubit() =>
      LoginCubit(repository: repository, authCubit: authCubit);

  void stubLogin(Result<User> result) {
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => result);
  }

  blocTest<LoginCubit, LoginState>(
    'a successful login reports success and signs the session in',
    setUp: () => stubLogin(Success(user)),
    build: buildCubit,
    act: (cubit) => cubit.submit(email: 'a@b.c', password: '123456'),
    expect: () => [
      const LoginState(status: LoginStatus.loading),
      const LoginState(status: LoginStatus.success),
    ],
    verify: (_) => expect(authCubit.state.user, user),
  );

  blocTest<LoginCubit, LoginState>(
    'a 401 becomes a failure state',
    setUp: () => stubLogin(const Error(UnauthorizedFailure(message: 'bad'))),
    build: buildCubit,
    act: (cubit) => cubit.submit(email: 'a@b.c', password: '123456'),
    expect: () => [
      const LoginState(status: LoginStatus.loading),
      const LoginState(
        status: LoginStatus.failure,
        failure: UnauthorizedFailure(message: 'bad'),
      ),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'a 409 becomes a failure state keeping the code',
    setUp: () => stubLogin(
      const Error(
        ConflictFailure(
          message: 'elsewhere',
          errorCode: FailureCodes.studentAlreadyLoggedIn,
        ),
      ),
    ),
    build: buildCubit,
    act: (cubit) => cubit.submit(email: 'a@b.c', password: '123456'),
    expect: () => [
      const LoginState(status: LoginStatus.loading),
      const LoginState(
        status: LoginStatus.failure,
        failure: ConflictFailure(
          message: 'elsewhere',
          errorCode: FailureCodes.studentAlreadyLoggedIn,
        ),
      ),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'a 422 keeps the per-field errors',
    setUp: () => stubLogin(
      const Error(
        ValidationFailure(
          message: 'invalid',
          errorCode: FailureCodes.validationError,
          fieldErrors: {
            'email': ['required'],
            'password': ['too short'],
          },
        ),
      ),
    ),
    build: buildCubit,
    act: (cubit) => cubit.submit(email: 'a@b.c', password: '123456'),
    expect: () => [
      const LoginState(status: LoginStatus.loading),
      const LoginState(
        status: LoginStatus.failure,
        failure: ValidationFailure(
          message: 'invalid',
          errorCode: FailureCodes.validationError,
          fieldErrors: {
            'email': ['required'],
            'password': ['too short'],
          },
        ),
      ),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'a second submit while loading is ignored',
    setUp: () {
      final pending = Completer<Result<User>>();
      when(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) => pending.future);
      // Resolve on the next microtask, after both submits have been fired.
      scheduleMicrotask(() => pending.complete(Success(user)));
    },
    build: buildCubit,
    act: (cubit) async {
      final first = cubit.submit(email: 'a@b.c', password: '123456');
      final second = cubit.submit(email: 'a@b.c', password: '123456');
      await first;
      await second;
    },
    expect: () => [
      const LoginState(status: LoginStatus.loading),
      const LoginState(status: LoginStatus.success),
    ],
    verify: (_) => verify(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).called(1),
  );
}
