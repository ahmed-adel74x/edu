import 'package:flutter/material.dart';

import '../../features/explore_courses/presentation/screens/explore_courses_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../widgets/empty_state_view.dart';
import 'app_bottom_nav_bar.dart';

/// Hosts the app's tabs behind one shared [AppBottomNavBar].
///
/// Screens no longer own a navigation bar of their own; they are pure tab
/// bodies. An [IndexedStack] keeps every tab alive (scroll offsets, filters,
/// search text) while only the selected one is painted, which matches the
/// instant switching Material's `NavigationBar` is designed for.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = AppBottomNavBar.homeIndex});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;

  void _select(int index) {
    if (index != _index) setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    // The app is RTL, but the shell sits above the screens (which declare
    // their own directionality), so it declares it here as well to keep the
    // shared navigation bar laid out right-to-left.
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            HomeScreen(
              onSeeAllCourses: () => _select(AppBottomNavBar.exploreIndex),
            ),
            const _ComingSoonScreen(icon: Icons.bookmark_rounded),
            const ExploreCoursesScreen(),
            const _ComingSoonScreen(icon: Icons.person_rounded),
          ],
        ),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: _index,
          onDestinationSelected: _select,
        ),
      ),
    );
  }
}

/// Placeholder for a tab that exists in the bar but has no screen yet.
class _ComingSoonScreen extends StatelessWidget {
  const _ComingSoonScreen({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: EmptyStateView(
            icon: icon,
            title: AppStrings.comingSoonTitle,
            message: AppStrings.comingSoonMessage,
          ),
        ),
      ),
    );
  }
}
