import 'package:go_router/go_router.dart';

import '../../navigation/parent_shell.dart';
import 'route_names.dart';

/// The parent's tabbed area: five branches behind [ParentShell].
///
/// Every tab is a stand-in page for now, so the five branches are built from one
/// list — the tab's branch index doubles as its [ParentShell] tab index, and the
/// order here must match [ParentShell.tabs]. Real screens replace the
/// placeholders one tab at a time.
StatefulShellRoute parentShellRoute() {
  const tabRoutes = [
    (path: RoutePaths.parentHome, name: RouteNames.parentHome),
    (path: RoutePaths.parentChildren, name: RouteNames.parentChildren),
    (path: RoutePaths.parentProgress, name: RouteNames.parentProgress),
    (path: RoutePaths.parentAssignments, name: RouteNames.parentAssignments),
    (path: RoutePaths.parentProfile, name: RouteNames.parentProfile),
  ];

  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        ParentShell(navigationShell: navigationShell),
    branches: [
      for (var index = 0; index < tabRoutes.length; index++)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: tabRoutes[index].path,
              name: tabRoutes[index].name,
              builder: (context, state) => ParentShell.placeholder(index),
            ),
          ],
        ),
    ],
  );
}
