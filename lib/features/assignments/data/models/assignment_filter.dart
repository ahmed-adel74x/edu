import 'assignment_status.dart';

/// One entry of the assignments filter bar.
class AssignmentFilter {
  const AssignmentFilter({
    required this.label,
    required this.status,
    this.count,
  });

  /// Chip caption ("قيد الانتظار").
  final String label;

  /// Bucket the chip shows; `null` keeps every assignment.
  final AssignmentStatus? status;

  /// How many assignments the bucket holds, rendered as "(١)". The design
  /// leaves it out of the graded chip, so it is optional.
  final int? count;
}
