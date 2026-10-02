/// One recent quiz attempt on the home dashboard.
///
/// A presentation view-model built by the screen from a [HomeQuiz]: the score
/// and the submission date arrive already localized, and the course line is
/// null when the backend sent no course name.
class RecentQuiz {
  const RecentQuiz({
    required this.title,
    required this.scoreLabel,
    required this.ratio,
    this.courseName,
    this.submittedAt,
  });

  /// The quiz's own title.
  final String title;

  /// The course it belongs to, or null when the backend sent none.
  final String? courseName;

  /// Localized score readout, e.g. '٪80'.
  final String scoreLabel;

  /// The score in the 0..1 range, used by the progress bar.
  final double ratio;

  /// Localized submission date of the readable timestamp, or null when the
  /// backend sent none that could be read.
  final String? submittedAt;
}
