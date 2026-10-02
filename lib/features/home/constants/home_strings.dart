import 'package:easy_localization/easy_localization.dart';

/// Copy for the home dashboard. Per-item content (course titles, teacher names,
/// assignment deadlines…) comes from the API; only the labels and the static
/// chrome of the welcome header live here.
abstract final class HomeStrings {
  // Welcome hero
  static String welcomeTitle(String name) =>
      'home.welcomeTitle'.tr(namedArgs: {'name': name});
  static String get welcomeSubtitle => 'home.welcomeSubtitle'.tr();
  static String get browseNew => 'home.browseNew'.tr();
  static String get curriculumBadge => 'home.curriculumBadge'.tr();

  // Section headers
  static String get continueLearningTitle => 'home.continueLearningTitle'.tr();
  static String get seeAll => 'home.seeAll'.tr();
  static String get upcomingTitle => 'home.upcomingTitle'.tr();

  /// The upcoming section's trailing count badge, e.g. "٢ بانتظارك".
  static String upcomingBadge(String count) =>
      'home.upcomingBadge'.tr(namedArgs: {'count': count});

  // Stat tiles
  static String get statEnrolledCourses => 'home.stats.enrolledCourses'.tr();
  static String get statStudyHours => 'home.stats.studyHours'.tr();
  static String get statCompletedCourses => 'home.stats.completedCourses'.tr();
  static String get statCertificates => 'home.stats.certificates'.tr();
  static String get statCoursesUnit => 'home.stats.coursesUnit'.tr();
  static String get statHoursUnit => 'home.stats.hoursUnit'.tr();
  static String get statCourseUnit => 'home.stats.courseUnit'.tr();
  static String get statCertificateUnit => 'home.stats.certificateUnit'.tr();

  // Continue-learning cards
  static String get progressLabel => 'home.progressLabel'.tr();
  static String get continueLessonCta => 'home.continueLessonCta'.tr();

  /// Already-localized percent readout, e.g. "٪65".
  static String percent(String value) =>
      'home.percent'.tr(namedArgs: {'value': value});

  /// Localized "N lectures remaining" line under the featured course.
  static String remainingLectures(String count) =>
      'home.remainingLectures'.tr(namedArgs: {'count': count});

  // Upcoming assignment cards
  static String get assignmentAction => 'home.assignmentAction'.tr();

  /// Localized deadline line for an upcoming assignment.
  static String dueDate(String date) =>
      'home.dueDate'.tr(namedArgs: {'date': date});

  // Attendance activity card
  static String get attendanceTitle => 'home.attendance.title'.tr();

  /// The card's own readout of the payload, e.g. "حضرت ٤٥ من ٥٦ محاضرة". Both
  /// figures arrive already formatted in the language's digits.
  static String attendanceSubtitle(String attended, String total) =>
      'home.attendance.subtitle'.tr(
        namedArgs: {'attended': attended, 'total': total},
      );

  // Recent quiz cards
  static String get recentQuizzesTitle => 'home.recentQuizzes.title'.tr();

  /// Caption above a quiz card's score readout.
  static String get quizScoreLabel => 'home.recentQuizzes.scoreLabel'.tr();

  // Recent chat tiles
  static String get recentChatsTitle => 'home.recentChats.title'.tr();

  /// Stands in for the last message when the room has none.
  static String get chatNoMessages => 'home.recentChats.noMessages'.tr();

  // Empty states (per section)
  static String get emptyCoursesTitle => 'home.emptyCourses.title'.tr();
  static String get emptyCoursesMessage => 'home.emptyCourses.message'.tr();
  static String get emptyAssignmentsTitle => 'home.emptyAssignments.title'.tr();
  static String get emptyAssignmentsMessage =>
      'home.emptyAssignments.message'.tr();
  static String get emptyAttendanceTitle => 'home.emptyAttendance.title'.tr();
  static String get emptyAttendanceMessage =>
      'home.emptyAttendance.message'.tr();
  static String get emptyQuizzesTitle => 'home.recentQuizzes.emptyTitle'.tr();
  static String get emptyQuizzesMessage =>
      'home.recentQuizzes.emptyMessage'.tr();
  static String get emptyChatsTitle => 'home.recentChats.emptyTitle'.tr();
  static String get emptyChatsMessage => 'home.recentChats.emptyMessage'.tr();

  // Failure state
  static String get retry => 'home.retry'.tr();
}
