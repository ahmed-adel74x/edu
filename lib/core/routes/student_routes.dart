import 'package:go_router/go_router.dart';

import '../../features/assignments/student/assignments_screen.dart';
import '../../features/explore_courses/student/explore_courses_screen.dart';
import '../../features/home/student/home_screen.dart';
import '../../navigation/student_shell.dart';
import 'route_names.dart';

/// The student's tabbed area: five branches behind [StudentShell].
///
/// A [StatefulShellRoute.indexedStack] keeps every branch alive, so switching
/// tabs preserves each tab's navigation stack, scroll offsets, filters and
/// search text — the behaviour the single shell had before the roles were split.
///
/// Branch order must match [StudentShell.tabs].
StatefulShellRoute studentShellRoute() {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        StudentShell(navigationShell: navigationShell),
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: RoutePaths.studentHome,
            name: RouteNames.studentHome,
            // The dashboard's "browse new" action switches to the explore tab.
            builder: (context, state) => HomeScreen(
              onSeeAllCourses: () => context.goNamed(RouteNames.studentExplore),
            ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: RoutePaths.studentMyCourses,
            name: RouteNames.studentMyCourses,
            builder: (context, state) =>
                StudentShell.placeholder(StudentShell.myCoursesIndex),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: RoutePaths.studentExplore,
            name: RouteNames.studentExplore,
            builder: (context, state) => const ExploreCoursesScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: RoutePaths.studentAssignments,
            name: RouteNames.studentAssignments,
            builder: (context, state) => const AssignmentsScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: RoutePaths.studentProfile,
            name: RouteNames.studentProfile,
            builder: (context, state) =>
                StudentShell.placeholder(StudentShell.profileIndex),
          ),
        ],
      ),
    ],
  );
}
