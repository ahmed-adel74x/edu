import 'package:go_router/go_router.dart';

import '../../navigation/teacher_shell.dart';
import 'route_names.dart';

/// The teacher's tabbed area: five branches behind [TeacherShell].
///
/// Every tab is a stand-in page for now, so the five branches are built from one
/// list — the tab's branch index doubles as its [TeacherShell] tab index, and the
/// order here must match [TeacherShell.tabs]. Real screens replace the
/// placeholders one tab at a time.
StatefulShellRoute teacherShellRoute() {
  const tabRoutes = [
    (path: RoutePaths.teacherHome, name: RouteNames.teacherHome),
    (path: RoutePaths.teacherMyCourses, name: RouteNames.teacherMyCourses),
    (path: RoutePaths.teacherAssignments, name: RouteNames.teacherAssignments),
    (path: RoutePaths.teacherStudents, name: RouteNames.teacherStudents),
    (path: RoutePaths.teacherProfile, name: RouteNames.teacherProfile),
  ];

  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        TeacherShell(navigationShell: navigationShell),
    branches: [
      for (var index = 0; index < tabRoutes.length; index++)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: tabRoutes[index].path,
              name: tabRoutes[index].name,
              builder: (context, state) => TeacherShell.placeholder(index),
            ),
          ],
        ),
    ],
  );
}
