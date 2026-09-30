import 'package:flutter/widgets.dart';

import 'assignment_status.dart';

/// One assignment of the learner's list: which course it belongs to, what it
/// asks for, where it stands and — depending on that status — its deadline,
/// attached brief or awarded score.
class Assignment {
  const Assignment({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.course,
    required this.title,
    required this.excerpt,
    required this.status,
    this.dueLabel,
    this.isDueSoon = false,
    this.fileLabel,
    this.gradeLabel,
    this.submittedLabel,
    this.submittedAtLabel,
    this.instructorName,
    this.instructorInitials,
    this.instructorNote,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  /// Course the assignment belongs to ("برمجة الويب المقدمة").
  final String course;

  final String title;

  /// One-line summary of what the assignment asks for.
  final String excerpt;

  final AssignmentStatus status;

  /// Deadline line of a pending assignment ("موعد التسليم: 2026-06-10").
  final String? dueLabel;

  /// Paints [dueLabel] in the urgent error tone.
  final bool isDueSoon;

  /// Attached brief ("ملف التكليف (2.4 MB) · PDF").
  final String? fileLabel;

  /// Score of a graded assignment ("تم التقييم: ٩٨/١٠٠").
  final String? gradeLabel;

  /// Green submission line of a handed-in assignment: when it was submitted,
  /// or which file was uploaded.
  final String? submittedLabel;

  /// Time that follows [submittedLabel], e.g. yesterday at 08:30 PM.
  final String? submittedAtLabel;

  /// Instructor who graded the work and left [instructorNote].
  final String? instructorName;

  /// Initials of [instructorName], rendered on the round avatar.
  final String? instructorInitials;

  /// The grader's feedback, shown in the tinted panel of a graded card.
  final String? instructorNote;
}
