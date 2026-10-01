import 'package:easy_localization/easy_localization.dart';

/// Shared copy: the app's identity, the shell's navigation and the strings the
/// shared widgets fall back to.
///
/// Every entry resolves a key from `assets/translations`, so a screen keeps
/// calling the name it always has (`AppStrings.navHome`) and still follows the
/// language the user picked.
abstract final class AppStrings {
  // App identity
  static String get appName => 'common.appName'.tr();
  static String get appTitle => 'common.appTitle'.tr();

  // Bottom navigation
  static String get navHome => 'nav.home'.tr();
  static String get navMyCourses => 'nav.myCourses'.tr();
  static String get navExplore => 'nav.explore'.tr();
  static String get navAssignments => 'nav.assignments'.tr();
  static String get navProfile => 'nav.profile'.tr();

  // Bottom navigation — the roles that don't have the student's tabs
  static String get navStudents => 'nav.students'.tr();
  static String get navChildren => 'nav.children'.tr();
  static String get navProgress => 'nav.progress'.tr();

  // Generic chrome / tooltips
  static String get notifications => 'common.notifications'.tr();
  static String get filterResults => 'common.filterResults'.tr();

  // Generic empty-state fallback (used when a feature doesn't override it)
  static String get emptyStateTitle => 'common.emptyState.title'.tr();
  static String get emptyStateMessage => 'common.emptyState.message'.tr();

  // Tabs that live in the shell but don't have a screen yet
  static String get comingSoonTitle => 'common.comingSoon.title'.tr();
  static String get comingSoonMessage => 'common.comingSoon.message'.tr();

  // Currency
  static String get currencySar => 'common.currencySar'.tr();
}
