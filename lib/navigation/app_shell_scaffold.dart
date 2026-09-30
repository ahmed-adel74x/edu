import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_bottom_nav_bar.dart';

/// The chrome every role's shell shares: right-to-left, one [Scaffold], the
/// shell body as its content and a single [AppBottomNavBar].
///
/// The three roles declare only their tabs and their routes; the bar's wiring
/// (select a branch, and re-tap the selected tab to pop it back to its root)
/// lives here so it can't drift between roles.
class AppShellScaffold extends StatelessWidget {
  const AppShellScaffold({
    super.key,
    required this.navigationShell,
    required this.destinations,
  });

  final StatefulNavigationShell navigationShell;

  /// The bar's destinations, in tab order — the shell's own list.
  final List<NavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
    // The app is RTL, but the shell sits above the screens (which declare their
    // own directionality), so it declares it here as well to keep the shared
    // navigation bar laid out right-to-left.
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: navigationShell.currentIndex,
          destinations: destinations,
          onDestinationSelected: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
        ),
      ),
    );
  }
}
