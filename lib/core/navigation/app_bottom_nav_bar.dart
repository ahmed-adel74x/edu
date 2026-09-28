import 'package:flutter/material.dart';

import '../constants/app_strings.dart';

/// The single bottom navigation bar of the app.
///
/// It is deliberately a thin wrapper around Material's [NavigationBar]: the
/// bar's look (height, white surface, primary pill indicator, 22px icons,
/// 11px labels, active/inactive colors) all comes from the shared
/// `NavigationBarThemeData` in `AppTheme`, so every screen that shows it
/// renders pixel-for-pixel the same bar.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  /// Destinations, in the order they appear in the bar (RTL: first is the
  /// right-most one).
  static const int homeIndex = 0;
  static const int myCoursesIndex = 1;
  static const int exploreIndex = 2;
  static const int profileIndex = 3;

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: AppStrings.navHome,
        ),
        NavigationDestination(
          icon: Icon(Icons.bookmark_border_rounded),
          selectedIcon: Icon(Icons.bookmark_rounded),
          label: AppStrings.navMyCourses,
        ),
        NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore_rounded),
          label: AppStrings.navExplore,
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: AppStrings.navProfile,
        ),
      ],
    );
  }
}
