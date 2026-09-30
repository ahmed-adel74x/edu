import 'package:flutter/material.dart';

/// One bottom-navigation tab of a role's shell.
///
/// Declared once per tab so the bar entry and the stand-in page that opens
/// while the real screen is still being built can't drift apart, and so each
/// role owns its own tab list (labels and icons differ per role).
class NavTab {
  const NavTab({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  /// The bar's label, reused as the title of the tab's stand-in page.
  final String label;

  /// Outline icon, shown while the tab is not selected.
  final IconData icon;

  /// Filled icon, shown while the tab is selected — and on its stand-in page.
  final IconData selectedIcon;

  NavigationDestination toDestination() => NavigationDestination(
        icon: Icon(icon),
        selectedIcon: Icon(selectedIcon),
        label: label,
      );
}
