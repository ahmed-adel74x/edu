import 'package:easy_localization/easy_localization.dart';

/// Copy for the course details page. Per-course content (title, description,
/// units, lessons…) lives on the sample data in the screen, exactly like the
/// home and explore screens keep their content next to the screen.
abstract final class CourseDetailsStrings {
  // Top bar
  static String get screenTitle => 'courseDetails.screenTitle'.tr();

  // Overview
  static String get instructorSectionTitle =>
      'courseDetails.instructorSectionTitle'.tr();
  static String get instructorProfileBadge =>
      'courseDetails.instructorProfileBadge'.tr();
  static String get studentsLabel => 'courseDetails.studentsLabel'.tr();

  // Curriculum
  static String get curriculumTitle => 'courseDetails.curriculumTitle'.tr();
  static String get nowBadge => 'courseDetails.nowBadge'.tr();

  // Bottom action bar
  static String get enrolledLabel => 'courseDetails.enrolledLabel'.tr();
  static String get progressLabel => 'courseDetails.progressLabel'.tr();
  static String get continueCta => 'courseDetails.continueCta'.tr();
}
