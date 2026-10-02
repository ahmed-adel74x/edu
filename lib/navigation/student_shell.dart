import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_strings.dart';
import '../features/auth/widgets/profile_logout_placeholder.dart';
import '../shared/widgets/coming_soon_screen.dart';
import 'app_shell_scaffold.dart';
import 'nav_tab.dart';

/// The student's shell: five tabs behind one shared bottom bar.
///
/// The tabs are branches of a [StatefulShellRoute], so each one keeps its own
/// navigation stack, scroll offsets, filters and search text while only the
/// selected tab is painted.
class StudentShell extends StatelessWidget {
  const StudentShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  // Tab order, in the order they appear in the bar (RTL: first is right-most).
  static const int homeIndex = 0;
  static const int myCoursesIndex = 1;
  static const int exploreIndex = 2;
  static const int assignmentsIndex = 3;
  static const int profileIndex = 4;

  /// The student's tabs, in [homeIndex] … [profileIndex] order. The branch order
  /// in `student_routes.dart` matches this list.
  static List<NavTab> get tabs => [
    NavTab(
      label: AppStrings.navHome,
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    NavTab(
      label: AppStrings.navMyCourses,
      icon: Icons.bookmark_border_rounded,
      selectedIcon: Icons.bookmark_rounded,
    ),
    NavTab(
      label: AppStrings.navExplore,
      icon: Icons.explore_outlined,
      selectedIcon: Icons.explore_rounded,
    ),
    NavTab(
      label: AppStrings.navAssignments,
      icon: Icons.assignment_outlined,
      selectedIcon: Icons.assignment_rounded,
    ),
    NavTab(
      label: AppStrings.navProfile,
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  /// The bar's destinations, in tab order: the shell renders them, and hands
  /// them to anything that stands the bar up on its own (previews, tests).
  static List<NavigationDestination> get destinations => [
    for (final tab in tabs) tab.toDestination(),
  ];

  /// The stand-in page for tab [index], while that tab has no screen yet.
  ///
  /// Profile is the exception: it carries the temporary sign-out button.
  static Widget placeholder(int index) => index == profileIndex
      ? const ProfileLogoutPlaceholder()
      : ComingSoonScreen(
          icon: tabs[index].selectedIcon,
          title: tabs[index].label,
        );

  @override
  Widget build(BuildContext context) => AppShellScaffold(
    navigationShell: navigationShell,
    destinations: destinations,
  );
}
