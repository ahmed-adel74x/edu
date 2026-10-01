import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_strings.dart';
import '../shared/widgets/coming_soon_screen.dart';
import 'app_shell_scaffold.dart';
import 'nav_tab.dart';

/// The teacher's shell: five tabs behind one shared bottom bar.
///
/// Tab state is preserved the same way as the student's, and every tab is a
/// stand-in page for now — the teacher screens arrive in later steps.
class TeacherShell extends StatelessWidget {
  const TeacherShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  // Tab order, in the order they appear in the bar (RTL: first is right-most).
  static const int homeIndex = 0;
  static const int myCoursesIndex = 1;
  static const int assignmentsIndex = 2;
  static const int studentsIndex = 3;
  static const int profileIndex = 4;

  /// The teacher's tabs, in [homeIndex] … [profileIndex] order. The branch order
  /// in `teacher_routes.dart` matches this list.
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
      label: AppStrings.navAssignments,
      icon: Icons.assignment_outlined,
      selectedIcon: Icons.assignment_rounded,
    ),
    NavTab(
      label: AppStrings.navStudents,
      icon: Icons.groups_outlined,
      selectedIcon: Icons.groups_rounded,
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
  static Widget placeholder(int index) => ComingSoonScreen(
    icon: tabs[index].selectedIcon,
    title: tabs[index].label,
  );

  @override
  Widget build(BuildContext context) => AppShellScaffold(
    navigationShell: navigationShell,
    destinations: destinations,
  );
}
