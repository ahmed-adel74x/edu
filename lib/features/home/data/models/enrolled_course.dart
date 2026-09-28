/// A course the learner is already enrolled in, as shown by the
/// "continue learning" cards.
class EnrolledCourse {
  const EnrolledCourse({
    required this.image,
    required this.title,
    required this.instructor,
    required this.progress,
    required this.progressLabel,
    this.remainingLessons,
  });

  final String image;
  final String title;

  /// Full instructor line, e.g. 'أحمد سعيد - Ahmed Teacher3' or
  /// 'المدرب: janaaaa'.
  final String instructor;

  /// Completion in the 0..1 range, used by the progress bar.
  final double progress;

  /// Pre-formatted readout, e.g. '٪65'.
  final String progressLabel;

  /// e.g. '٥ دروس متبقية لإنهاء المادة'. Only the featured card shows it.
  final String? remainingLessons;
}
