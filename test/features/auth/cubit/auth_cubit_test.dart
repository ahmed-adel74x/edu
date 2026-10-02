// The global session cubit: restore, sign-in/out and session-ending events.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:test_edu/core/network/interceptors/auth_interceptor.dart';
import 'package:test_edu/features/auth/cubit/auth_cubit.dart';
import 'package:test_edu/features/auth/cubit/auth_state.dart';
import 'package:test_edu/shared/models/user.dart';
import 'package:test_edu/shared/models/user_role.dart';

import '../../../helpers/auth_test_harness.dart';

void main() {
  late FakeAuthRepository repository;
  late User user;

  setUp(() {
    repository = fakeAuthRepository();
    user = testUser(UserRole.student);
  });

  AuthCubit buildCubit({SessionEvents? events}) => AuthCubit(
    repository: repository,
    sessionEvents: events ?? SessionEvents(),
  );

  test('starts unauthenticated', () {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    expect(cubit.state.status, AuthStatus.unauthenticated);
    expect(cubit.state.role, isNull);
  });

  blocTest<AuthCubit, AuthState>(
    'restore finds a cached session',
    setUp: () => when(() => repository.restore()).thenAnswer((_) async => user),
    build: buildCubit,
    act: (cubit) => cubit.restore(),
    expect: () => [AuthState(status: AuthStatus.authenticated, user: user)],
  );

  blocTest<AuthCubit, AuthState>(
    'restore without a cached session stays signed out',
    build: buildCubit,
    act: (cubit) => cubit.restore(),
    // The state is already unauthenticated; the first emit of an equal state is
    // still delivered (bloc's documented behaviour).
    expect: () => [const AuthState()],
    verify: (cubit) => expect(cubit.state.status, AuthStatus.unauthenticated),
  );

  blocTest<AuthCubit, AuthState>(
    'onLoggedIn stores the user',
    build: buildCubit,
    act: (cubit) => cubit.onLoggedIn(user),
    expect: () => [AuthState(status: AuthStatus.authenticated, user: user)],
  );

  blocTest<AuthCubit, AuthState>(
    'logout asks the repository and ends signed out',
    build: buildCubit,
    act: (cubit) async {
      cubit.onLoggedIn(user);
      await cubit.logout();
    },
    expect: () => [
      AuthState(status: AuthStatus.authenticated, user: user),
      const AuthState(),
    ],
    verify: (_) => verify(() => repository.logout()).called(1),
  );

  blocTest<AuthCubit, AuthState>(
    'debugSignInAs opens a mock teacher preview',
    build: buildCubit,
    act: (cubit) => cubit.debugSignInAs(UserRole.teacher),
    verify: (cubit) {
      expect(cubit.state.status, AuthStatus.authenticated);
      expect(cubit.state.role, UserRole.teacher);
    },
  );

  group('session events', () {
    late SessionEvents events;

    setUp(() => events = SessionEvents());
    tearDown(() => events.dispose());

    blocTest<AuthCubit, AuthState>(
      'expired clears the cache without a server call and reports it',
      build: () => buildCubit(events: events),
      act: (cubit) async {
        events.notify(SessionEvent.sessionExpired);
        await Future<void>.delayed(const Duration(milliseconds: 20));
      },
      expect: () => [
        const AuthState(sessionEndedReason: SessionEndReason.expired),
      ],
      verify: (_) {
        verify(() => repository.clearSession()).called(1);
        verifyNever(() => repository.logout());
      },
    );

    blocTest<AuthCubit, AuthState>(
      'revoked reports the revoked reason',
      build: () => buildCubit(events: events),
      act: (cubit) async {
        events.notify(SessionEvent.sessionRevoked);
        await Future<void>.delayed(const Duration(milliseconds: 20));
      },
      expect: () => [
        const AuthState(sessionEndedReason: SessionEndReason.revoked),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'clearing the reason is a no-op once it is consumed',
      build: () => buildCubit(events: events),
      act: (cubit) async {
        events.notify(SessionEvent.sessionExpired);
        await Future<void>.delayed(const Duration(milliseconds: 20));
        cubit.clearSessionEndedReason();
      },
      expect: () => [
        const AuthState(sessionEndedReason: SessionEndReason.expired),
        const AuthState(),
      ],
    );
  });
}
