import '../../shared/models/user_role.dart';

/// The names and locations of the app's routes, in one place.
///
/// Code navigates by *name* (`context.goNamed(RouteNames.studentHome)`), while
/// the *path* is the deep-linkable location a push notification or a web URL can
/// open. Keeping both here means a route is declared once and never spelled out
/// as a string literal at a call site.
abstract final class RouteNames {
  // Auth
  static const login = 'login';
  static const signUp = 'sign-up';

  // Shared
  static const courseDetails = 'course-details';

  // Student shell
  static const studentHome = 'student-home';
  static const studentMyCourses = 'student-my-courses';
  static const studentExplore = 'student-explore';
  static const studentAssignments = 'student-assignments';
  static const studentProfile = 'student-profile';

  // Teacher shell
  static const teacherHome = 'teacher-home';
  static const teacherMyCourses = 'teacher-my-courses';
  static const teacherAssignments = 'teacher-assignments';
  static const teacherStudents = 'teacher-students';
  static const teacherProfile = 'teacher-profile';

  // Parent shell
  static const parentHome = 'parent-home';
  static const parentChildren = 'parent-children';
  static const parentProgress = 'parent-progress';
  static const parentAssignments = 'parent-assignments';
  static const parentProfile = 'parent-profile';
}

/// The URI of every route in [RouteNames], e.g. `/login`.
///
/// Each role's pages live under their own segment (`/student/…`, `/teacher/…`,
/// `/parent/…`), which is what the router's guard uses to tell whose page a deep
/// link is pointing at.
abstract final class RoutePaths {
  /// The root: never a page of its own, only a pointer at the signed-in role's
  /// first tab (or at login while signed out).
  static const root = '/';

  // Auth
  static const login = '/login';
  static const signUp = '/sign-up';

  // Shared
  static const courseDetails = '/course-details';

  // Student shell
  static const studentRoot = '/student';
  static const studentHome = '$studentRoot/home';
  static const studentMyCourses = '$studentRoot/my-courses';
  static const studentExplore = '$studentRoot/explore';
  static const studentAssignments = '$studentRoot/assignments';
  static const studentProfile = '$studentRoot/profile';

  // Teacher shell
  static const teacherRoot = '/teacher';
  static const teacherHome = '$teacherRoot/home';
  static const teacherMyCourses = '$teacherRoot/my-courses';
  static const teacherAssignments = '$teacherRoot/assignments';
  static const teacherStudents = '$teacherRoot/students';
  static const teacherProfile = '$teacherRoot/profile';

  // Parent shell
  static const parentRoot = '/parent';
  static const parentHome = '$parentRoot/home';
  static const parentChildren = '$parentRoot/children';
  static const parentProgress = '$parentRoot/progress';
  static const parentAssignments = '$parentRoot/assignments';
  static const parentProfile = '$parentRoot/profile';
}

/// The path segment each role's pages live under.
const _roleRoots = <UserRole, String>{
  UserRole.student: RoutePaths.studentRoot,
  UserRole.teacher: RoutePaths.teacherRoot,
  UserRole.parent: RoutePaths.parentRoot,
};

/// The first tab of [role]'s shell — where a signed-in session belongs.
String homePathFor(UserRole role) => switch (role) {
      UserRole.student => RoutePaths.studentHome,
      UserRole.teacher => RoutePaths.teacherHome,
      UserRole.parent => RoutePaths.parentHome,
    };

/// [homePathFor] as a route name, for code that navigates by name.
String homeNameFor(UserRole role) => switch (role) {
      UserRole.student => RouteNames.studentHome,
      UserRole.teacher => RouteNames.teacherHome,
      UserRole.parent => RouteNames.parentHome,
    };

/// True for the two screens that only make sense while signed out.
bool isAuthLocation(String location) =>
    location == RoutePaths.login || location == RoutePaths.signUp;

/// The role whose shell owns [location], or null when the location is either
/// shared by every role (auth, course details) or unknown.
UserRole? roleForLocation(String location) {
  for (final entry in _roleRoots.entries) {
    final root = entry.value;
    if (location == root || location.startsWith('$root/')) return entry.key;
  }
  return null;
}
