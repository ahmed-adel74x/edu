import 'package:easy_localization/easy_localization.dart';

/// Copy for the home dashboard. Per-item content (course titles, task
/// deadlines…) lives on the sample data in the screen, exactly like the
/// explore screen keeps its course content next to the screen.
abstract final class HomeStrings {
  // Welcome hero
  static String get userName => 'home.userName'.tr();
  static String get welcomeTitle =>
      'home.welcomeTitle'.tr(namedArgs: {'name': userName});
  static String get welcomeSubtitle => 'home.welcomeSubtitle'.tr();
  static String get streakBadge => 'home.streakBadge'.tr();
  static String get browseNew => 'home.browseNew'.tr();
  static String get curriculumBadge => 'home.curriculumBadge'.tr();

  // Section headers
  static String get continueLearningTitle => 'home.continueLearningTitle'.tr();
  static String get seeAll => 'home.seeAll'.tr();
  static String get upcomingTitle => 'home.upcomingTitle'.tr();
  static String get upcomingBadge => 'home.upcomingBadge'.tr();

  // Continue-learning cards
  static String get progressLabel => 'home.progressLabel'.tr();
  static String get continueLessonCta => 'home.continueLessonCta'.tr();

  // Weekly activity card
  static String get weeklyTitle => 'home.weeklyTitle'.tr();
  static String get weeklySubtitle => 'home.weeklySubtitle'.tr();
  static String get weeklyRangePill => 'home.weeklyRangePill'.tr();
}
