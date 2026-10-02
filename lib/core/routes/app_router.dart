import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/cubit/auth_cubit.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/sign_up_screen.dart';
import '../../features/course_details/data/models/course_details.dart';
import '../../features/course_details/student/course_details_screen.dart';
import '../../shared/models/user_role.dart';
import 'parent_routes.dart';
import 'route_names.dart';
import 'student_routes.dart';
import 'teacher_routes.dart';

/// Builds the app's [GoRouter] around [auth].
///
/// It is created per `MyApp` instance and held in its state rather than in a
/// global, which is what go_router recommends: a router owns the current
/// location, so a global one would survive a hot restart and leak one test's
/// location into the next.
///
/// The table is one route per screen plus one `StatefulShellRoute` per role; the
/// guard in [redirectFor] decides which of them the session may see, and the
/// [GoRouterRefreshStream] re-runs that guard whenever the session cubit emits.
GoRouter createAppRouter({required AuthCubit auth}) {
  return GoRouter(
    initialLocation: RoutePaths.root,
    refreshListenable: GoRouterRefreshStream(auth.stream),
    redirect: (context, state) =>
        redirectFor(role: auth.state.role, location: state.matchedLocation),
    routes: [
      GoRoute(
        path: RoutePaths.root,
        // `/` is never a page of its own: it points at the role's first tab, or
        // at login while signed out. The guard above normally resolves it first;
        // this keeps the table consistent on its own.
        redirect: (context, state) =>
            redirectFor(role: auth.state.role, location: RoutePaths.root),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.signUp,
        name: RouteNames.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: RoutePaths.courseDetails,
        name: RouteNames.courseDetails,
        builder: (context, state) {
          // The page renders a whole [CourseDetails] the caller already holds,
          // so the model travels as `extra` until courses come from a repository
          // and an id in the path can be looked up instead.
          final course = state.extra;
          if (course is! CourseDetails) {
            throw StateError(
              'Route "${RouteNames.courseDetails}" needs a CourseDetails '
              'passed as `extra`.',
            );
          }
          return CourseDetailsScreen(course: course);
        },
      ),
      studentShellRoute(),
      teacherShellRoute(),
      parentShellRoute(),
    ],
  );
}

/// The router's single guard, written as a pure function of the current [role]
/// and [location] so its rules can be read and tested without building a router.
///
/// * Signed out: everything except the auth screens lands on login.
/// * Signed in: the auth screens and `/` land on the role's first tab.
/// * Signed in: a page owned by another role is refused and the session is sent
///   back to its own first tab, so a deep link (or a stale URL) can't cross
///   roles.
String? redirectFor({required UserRole? role, required String location}) {
  if (role == null) return isAuthLocation(location) ? null : RoutePaths.login;
  if (isAuthLocation(location) || location == RoutePaths.root) {
    return homePathFor(role);
  }
  final owner = roleForLocation(location);
  return owner == null || owner == role ? null : homePathFor(role);
}

/// Bridges a [Stream] to the [Listenable] `GoRouter.refreshListenable` wants: the
/// router re-runs its guard every time the session cubit emits. Small enough to
/// need no package (the classic go_router recipe).
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<Object?> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
