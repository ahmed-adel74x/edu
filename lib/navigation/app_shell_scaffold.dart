import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_bottom_nav_bar.dart';

/// The chrome every role's shell shares: one [Scaffold], the shell body as its
/// content and a single [AppBottomNavBar].
///
/// The three roles declare only their tabs and their routes; the bar's wiring
/// (select a branch, and re-tap the selected tab to pop it back to its root)
/// lives here so it can't drift between roles. The reading direction comes from
/// the locale, so the bar lays itself out right-to-left in Arabic and
/// left-to-right in English without anyone declaring it.
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
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        destinations: destinations,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
