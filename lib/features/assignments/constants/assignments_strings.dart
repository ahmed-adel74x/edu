import 'package:easy_localization/easy_localization.dart';

/// Copy for the assignments screen. Per-item content (assignment titles,
/// deadlines, instructor notes…) lives on the sample data in the screen,
/// exactly like the home and explore screens keep their content next to the
/// screen.
abstract final class AssignmentsStrings {
  // Top bar
  static String get screenTitle => 'assignments.screenTitle'.tr();

  // Progress hero
  static String get levelBadge => 'assignments.levelBadge'.tr();
  static String get streakBadge => 'assignments.streakBadge'.tr();
  static String get heroTitle => 'assignments.heroTitle'.tr();
  static String get heroSubtitle => 'assignments.heroSubtitle'.tr();
  static String get pointsTooltip => 'assignments.pointsTooltip'.tr();

  // Search + status filters
  static String get searchHint => 'assignments.searchHint'.tr();
  static String get filterAll => 'assignments.filterAll'.tr();
  static String get filterPending => 'assignments.filterPending'.tr();
  static String get filterSubmitted => 'assignments.filterSubmitted'.tr();
  static String get filterGraded => 'assignments.filterGraded'.tr();

  // Assignment card: status pill
  static String get pendingBadge => 'assignments.pendingBadge'.tr();
  static String get underReviewBadge => 'assignments.underReviewBadge'.tr();
  static String get gradedBadge => 'assignments.gradedBadge'.tr();

  // Assignment card: instructor feedback
  static String get instructorNotesPrefix =>
      'assignments.instructorNotesPrefix'.tr();

  // Assignment card: actions
  static String get submitCta => 'assignments.submitCta'.tr();
  static String get briefCta => 'assignments.briefCta'.tr();
  static String get viewSubmissionCta => 'assignments.viewSubmissionCta'.tr();
  static String get previewCta => 'assignments.previewCta'.tr();
  static String get resendCta => 'assignments.resendCta'.tr();

  // Filtered-to-nothing fallback
  static String get emptyTitle => 'assignments.emptyTitle'.tr();
  static String get emptyMessage => 'assignments.emptyMessage'.tr();
}
