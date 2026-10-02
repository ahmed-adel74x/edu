/// One bar of the attendance-activity chart.
///
/// A presentation view-model built by the screen from one month of the API's
/// `attendance_chart`: the label is already localized, and the bar reads the
/// *lectures* series (the courses series is parsed but not charted).
class AttendanceBar {
  const AttendanceBar({
    required this.label,
    required this.ratio,
    this.isActive = false,
    this.isCurrent = false,
  });

  /// Short month name in the app's language, shown under the bar.
  final String label;

  /// Bar height in the 0..1 range, from the month's lecture percentage.
  final double ratio;

  /// A month the learner attended any lecture is drawn in the brand blue.
  final bool isActive;

  /// The current month — the last one the backend sent — is highlighted in the
  /// teal accent.
  final bool isCurrent;
}
