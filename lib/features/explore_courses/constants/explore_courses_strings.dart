import 'package:easy_localization/easy_localization.dart';

abstract final class ExploreCoursesStrings {
  // Top bar
  static String get screenTitle => 'explore.screenTitle'.tr();

  // Search
  static String get searchHint => 'explore.searchHint'.tr();

  // Section header
  static String get sectionTitle => 'explore.sectionTitle'.tr();
  static String get noCourses => 'explore.noCourses'.tr();
  static String get oneCourse => 'explore.oneCourse'.tr();
  static String get twoCourses => 'explore.twoCourses'.tr();
  static String countLabel(int count) => count == 0
      ? noCourses
      : count == 1
      ? oneCourse
      : count == 2
      ? twoCourses
      : 'explore.count'.tr(namedArgs: {'count': '$count'});

  // Course card
  // Note: the default enroll-button label lives on the Course model
  // itself (data layer), not here, since it's per-course content.
  static String get totalPrice => 'explore.totalPrice'.tr();

  // Empty state (overrides the generic core wording with course-specific copy)
  static String get emptyTitle => 'explore.emptyTitle'.tr();
  static String get emptyMessage => 'explore.emptyMessage'.tr();

  // Promo banner
  static String get promoEyebrow => 'explore.promoEyebrow'.tr();
  static String get promoTitle => 'explore.promoTitle'.tr();
  static String get promoSubtitle => 'explore.promoSubtitle'.tr();
  static String get promoCode => 'explore.promoCode'.tr();
  static String get promoCountdown => 'explore.promoCountdown'.tr();
  static String get promoActivateCta => 'explore.promoActivateCta'.tr();
}
