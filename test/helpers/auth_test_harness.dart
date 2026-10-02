// Auth wiring for tests.
//
// The real repository is swapped for a mocktail mock, and the session cubit
// (plus the login cubit the login screen pulls from the locator) is registered,
// so the whole app can be pumped exactly as `main()` would.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:test_edu/core/di/injection.dart';
import 'package:test_edu/core/network/failure.dart';
import 'package:test_edu/core/network/interceptors/auth_interceptor.dart';
import 'package:test_edu/core/network/result.dart';
import 'package:test_edu/features/auth/cubit/auth_cubit.dart';
import 'package:test_edu/features/auth/cubit/login_cubit.dart';
import 'package:test_edu/features/auth/data/repositories/auth_repository.dart';
import 'package:test_edu/shared/models/user.dart';
import 'package:test_edu/shared/models/user_role.dart';

import 'app_test_harness.dart';
import 'home_test_harness.dart';

/// A stand-in [AuthRepository]; stub only the calls a test exercises.
class FakeAuthRepository extends Mock implements AuthRepository {}

/// The name [testUser] gives a session unless a test asks for another — what the
/// dashboard's greeting is asserted against.
const String testUserName = 'Test User';

/// A [User] for [role], carrying every field the app reads.
User testUser(UserRole role, {String name = testUserName}) => User(
  userId: 'user-${role.name}',
  studentId: role == UserRole.student ? 'student-1' : '',
  studentCode: role == UserRole.student ? 'S-123' : '',
  name: name,
  email: '${role.name}@test.local',
  mobile: '0500000000',
  role: role,
);

/// A [FakeAuthRepository] with the calls most tests touch already stubbed.
///
/// [cache] is what `restore()` finds; [loginResult] is what `login()` returns.
FakeAuthRepository fakeAuthRepository({
  User? cache,
  Result<User>? loginResult,
}) {
  final repository = FakeAuthRepository();
  when(() => repository.restore()).thenAnswer((_) async => cache);
  when(() => repository.logout()).thenAnswer((_) async {});
  when(() => repository.clearSession()).thenAnswer((_) async {});
  when(
    () => repository.login(
      email: any(named: 'email'),
      password: any(named: 'password'),
    ),
  ).thenAnswer((_) async => loginResult ?? const Error(UnknownFailure()));
  return repository;
}

/// Registers the auth graph in the locator and returns the session cubit.
///
/// [signedIn] seeds the session without a login. The dashboard's own graph is
/// registered alongside it, because a session that lands in the student shell
/// builds the home screen. The container is reset and the cubit closed at
/// teardown.
AuthCubit registerTestAuth({
  required AuthRepository repository,
  User? signedIn,
  SessionEvents? sessionEvents,
}) {
  final events = sessionEvents ?? SessionEvents();
  final cubit = AuthCubit(repository: repository, sessionEvents: events);
  if (signedIn != null) cubit.onLoggedIn(signedIn);

  // The dashboard behind the student shell reads its payload from the locator.
  registerTestHome();

  getIt
    ..registerSingleton<AuthRepository>(repository)
    ..registerSingleton<AuthCubit>(cubit)
    ..registerFactory<LoginCubit>(
      () => LoginCubit(repository: repository, authCubit: cubit),
    );

  addTearDown(() async {
    await cubit.close();
    await events.dispose();
    await resetInjection();
  });
  return cubit;
}

/// A session cubit that starts already signed in as [role] — for tests that only
/// need the app to open inside a role's shell.
AuthCubit signedInAuthCubit([UserRole role = UserRole.student]) =>
    registerTestAuth(repository: fakeAuthRepository(), signedIn: testUser(role));

/// A translation string read straight from the shipped assets, so a test and the
/// app can't disagree about the wording.
String translated(String language, List<Object> path) {
  Object? node = testTranslations[language];
  for (final step in path) {
    node = (node as Map)[step];
  }
  return node as String;
}
