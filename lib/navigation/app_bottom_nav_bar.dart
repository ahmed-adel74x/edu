import 'package:flutter/material.dart';

/// The bottom navigation bar every role's shell shows.
///
/// It is deliberately a thin wrapper around Material's [NavigationBar]: the
/// bar's look (height, white surface, primary pill indicator, 22px icons, 11px
/// labels, active/inactive colors) all comes from the shared
/// `NavigationBarThemeData` in `AppTheme`, so every role renders
/// pixel-for-pixel the same bar. Which tabs it holds is the caller's business —
/// each role's shell declares its own list.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.destinations,
    required this.onDestinationSelected,
  });

  /// The selected destination's index in [destinations].
  final int currentIndex;

  /// Destinations, in the order they appear in the bar (RTL: first is the
  /// right-most one).
  final List<NavigationDestination> destinations;

  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations,
    );
  }
}
