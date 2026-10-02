// Tests for the auth foundation: the router's guard and the three role shells.
//
// The guard is a pure function of the current role and the location, so its
// rules are asserted directly. The flows that need a tree — signing in, landing
// in the right shell, refusing another role's deep link — pump the whole app.
// Where the login form is not the subject, the session is seeded by registering a
// session cubit already signed in instead of walking through it.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:test_edu/core/constants/app_strings.dart';
import 'package:test_edu/core/network/result.dart';
import 'package:test_edu/core/routes/app_router.dart';
import 'package:test_edu/core/routes/route_names.dart';
import 'package:test_edu/features/assignments/student/assignments_screen.dart';
import 'package:test_edu/features/auth/constants/auth_strings.dart';
import 'package:test_edu/features/auth/cubit/auth_cubit.dart';
import 'package:test_edu/features/auth/screens/login_screen.dart';
import 'package:test_edu/features/auth/screens/sign_up_screen.dart';
import 'package:test_edu/features/home/student/home_screen.dart';
import 'package:test_edu/main.dart';
import 'package:test_edu/navigation/app_bottom_nav_bar.dart';
import 'package:test_edu/navigation/parent_shell.dart';
import 'package:test_edu/navigation/teacher_shell.dart';
import 'package:test_edu/shared/models/user_role.dart';
import 'package:test_edu/shared/widgets/app_primary_button.dart';
import 'package:test_edu/shared/widgets/app_text_field.dart';

import 'helpers/app_test_harness.dart';
import 'helpers/auth_test_harness.dart';

/// A common phone canvas (iPhone 14-ish), in logical pixels. Every dimension
/// comes from `flutter_screenutil` (design canvas 375x812), so the surface has
/// to stay phone-sized.
const Size phoneSize = Size(390, 844);

/// Pumps the app over [auth], then lets the explore tab's simulated fetch finish
/// so that no timer is left pending at teardown.
Future<void> pumpApp(WidgetTester tester, AuthCubit auth) async {
  tester.view.physicalSize = phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MyApp(auth: auth, assetLoader: memoryAssetLoader));
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

/// The labels of the single bottom bar, in bar order (RTL: first is right-most).
List<String?> barLabels(WidgetTester tester) => tester
    .widget<NavigationBar>(find.byType(NavigationBar))
    .destinations
    .cast<NavigationDestination>()
    .map((destination) => destination.label)
    .toList();

/// The bar's selected index.
int selectedTab(WidgetTester tester) =>
    tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;

/// Walks the login form: fills both fields, picks the [roleLabel] account and
/// submits.
Future<void> signInThroughLogin(
  WidgetTester tester, {
  required String roleLabel,
}) async {
  await tester.enterText(find.byType(TextField).first, 'name@example.com');
  await tester.enterText(find.byType(TextField).last, '12345678');
  await tester.pump();

  await tester.ensureVisible(find.text(roleLabel));
  await tester.pump();
  await tester.tap(find.text(roleLabel));
  await tester.pump();

  final submit = find.widgetWithText(AppPrimaryButton, AuthStrings.loginCta);
  await tester.ensureVisible(submit);
  await tester.pump();
  await tester.tap(submit);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  setUp(prepareAppEnvironment);

  group('the router guard', () {
    test('sends a signed-out session to login', () {
      expect(
        redirectFor(role: null, location: RoutePaths.root),
        RoutePaths.login,
      );
      expect(
        redirectFor(role: null, location: RoutePaths.studentHome),
        RoutePaths.login,
      );
      expect(
        redirectFor(role: null, location: RoutePaths.teacherAssignments),
        RoutePaths.login,
      );
      expect(
        redirectFor(role: null, location: RoutePaths.courseDetails),
        RoutePaths.login,
      );
    });

    test('leaves the auth screens alone while signed out', () {
      expect(redirectFor(role: null, location: RoutePaths.login), isNull);
      expect(redirectFor(role: null, location: RoutePaths.signUp), isNull);
    });

    test(
      'moves a signed-in session off auth and the root to its first tab',
      () {
        for (final role in UserRole.values) {
          final home = homePathFor(role);
          expect(redirectFor(role: role, location: RoutePaths.login), home);
          expect(redirectFor(role: role, location: RoutePaths.signUp), home);
          expect(redirectFor(role: role, location: RoutePaths.root), home);
          expect(redirectFor(role: role, location: home), isNull);
        }
      },
    );

    test('lets a role open its own pages', () {
      expect(
        redirectFor(
          role: UserRole.student,
          location: RoutePaths.studentAssignments,
        ),
        isNull,
      );
      expect(
        redirectFor(
          role: UserRole.teacher,
          location: RoutePaths.teacherStudents,
        ),
        isNull,
      );
      expect(
        redirectFor(role: UserRole.parent, location: RoutePaths.parentChildren),
        isNull,
      );
    });

    test('refuses pages owned by another role, back to its own first tab', () {
      expect(
        redirectFor(role: UserRole.student, location: RoutePaths.teacherHome),
        RoutePaths.studentHome,
      );
      expect(
        redirectFor(
          role: UserRole.teacher,
          location: RoutePaths.studentAssignments,
        ),
        RoutePaths.teacherHome,
      );
      expect(
        redirectFor(role: UserRole.parent, location: RoutePaths.studentExplore),
        RoutePaths.parentHome,
      );
      expect(
        redirectFor(
          role: UserRole.teacher,
          location: RoutePaths.parentProgress,
        ),
        RoutePaths.teacherHome,
      );
    });

    test('keeps the shared pages reachable for every role', () {
      for (final role in UserRole.values) {
        expect(
          redirectFor(role: role, location: RoutePaths.courseDetails),
          isNull,
        );
      }
    });

    test('reads the role a location belongs to', () {
      expect(roleForLocation(RoutePaths.studentExplore), UserRole.student);
      expect(roleForLocation(RoutePaths.teacherRoot), UserRole.teacher);
      expect(roleForLocation(RoutePaths.parentChildren), UserRole.parent);
      expect(roleForLocation(RoutePaths.login), isNull);
      expect(roleForLocation(RoutePaths.courseDetails), isNull);
    });
  });

  group('the app', () {
    testWidgets('opens login instead of a shell while signed out', (
      tester,
    ) async {
      await pumpApp(tester, registerTestAuth(repository: fakeAuthRepository()));

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(AppBottomNavBar), findsNothing);
      expect(find.byType(HomeScreen), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('signs a student in and opens the student shell', (
      tester,
    ) async {
      final repository = fakeAuthRepository(
        loginResult: Success(testUser(UserRole.student)),
      );
      final auth = registerTestAuth(repository: repository);
      await pumpApp(tester, auth);

      await signInThroughLogin(tester, roleLabel: AuthStrings.roleStudent);

      expect(auth.state.role, UserRole.student);
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(barLabels(tester), [
        AppStrings.navHome,
        AppStrings.navMyCourses,
        AppStrings.navExplore,
        AppStrings.navAssignments,
        AppStrings.navProfile,
      ]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the debug selector previews the teacher shell', (
      tester,
    ) async {
      final auth = registerTestAuth(repository: fakeAuthRepository());
      await pumpApp(tester, auth);

      await signInThroughLogin(tester, roleLabel: AuthStrings.roleTeacher);

      expect(auth.state.role, UserRole.teacher);
      expect(find.byType(TeacherShell), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
      expect(barLabels(tester), [
        AppStrings.navHome,
        AppStrings.navMyCourses,
        AppStrings.navAssignments,
        AppStrings.navStudents,
        AppStrings.navProfile,
      ]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('opens the parent shell for a parent session', (tester) async {
      await pumpApp(tester, signedInAuthCubit(UserRole.parent));

      expect(find.byType(ParentShell), findsOneWidget);
      expect(barLabels(tester), [
        AppStrings.navHome,
        AppStrings.navChildren,
        AppStrings.navProgress,
        AppStrings.navAssignments,
        AppStrings.navProfile,
      ]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('switches a placeholder tab and back', (tester) async {
      await pumpApp(tester, signedInAuthCubit(UserRole.teacher));

      await tester.tap(find.text(AppStrings.navStudents));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(selectedTab(tester), TeacherShell.studentsIndex);

      await tester.tap(find.text(AppStrings.navHome));
      await tester.pump();
      expect(selectedTab(tester), TeacherShell.homeIndex);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a deep link into another role is refused', (tester) async {
      await pumpApp(tester, signedInAuthCubit());

      await tester.tap(find.text(AppStrings.navAssignments));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(AssignmentsScreen), findsOneWidget);

      GoRouter.of(tester.element(find.byType(AppBottomNavBar)))
          .go(RoutePaths.teacherStudents);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(TeacherShell), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('sign-up renders, with the same three role choices', (
      tester,
    ) async {
      await pumpApp(tester, registerTestAuth(repository: fakeAuthRepository()));

      final createAccount = find.text(AuthStrings.createAccountLink);
      await tester.ensureVisible(createAccount);
      await tester.pump();
      await tester.tap(createAccount);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(SignUpScreen), findsOneWidget);
      expect(find.text(AuthStrings.signUpCta), findsOneWidget);
      for (final label in [
        AuthStrings.roleStudent,
        AuthStrings.roleTeacher,
        AuthStrings.roleParent,
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      // Name, identifier, password, confirmation.
      expect(find.byType(AppTextField), findsNWidgets(4));
      expect(tester.takeException(), isNull);
    });

    testWidgets('signing out returns to login', (tester) async {
      final auth = signedInAuthCubit();
      await pumpApp(tester, auth);
      expect(find.byType(HomeScreen), findsOneWidget);

      await auth.logout();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(AppBottomNavBar), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the temporary Profile tab signs out', (tester) async {
      final auth = signedInAuthCubit();
      await pumpApp(tester, auth);

      await tester.tap(find.text(AppStrings.navProfile));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text(AuthStrings.logout), findsOneWidget);

      await tester.tap(find.widgetWithText(AppPrimaryButton, AuthStrings.logout));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
