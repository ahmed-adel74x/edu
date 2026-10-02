/// A course the learner is already enrolled in, as shown by the
/// "continue learning" cards.
///
/// A presentation view-model built by the screen from a [HomeCourse]: the cover
/// is whatever the API sent (rendered as a network image only when it is an
/// absolute URL), and the progress readout is already localized.
class EnrolledCourse {
  const EnrolledCourse({
    required this.coverPath,
    required this.title,
    required this.instructor,
    required this.progress,
    required this.progressLabel,
    this.remainingLessons,
  });

  /// The cover path exactly as the API sent it, or null.
  final String? coverPath;

  final String title;

  /// Teacher name, or null when the API sent none.
  final String? instructor;

  /// Completion in the 0..1 range, used by the progress bar.
  final double progress;

  /// Pre-formatted, localized readout, e.g. '٪65'.
  final String progressLabel;

  /// Localized "N lectures remaining" line. Only the featured card shows it.
  final String? remainingLessons;
}
