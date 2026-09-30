/// A single readout of the assignments progress strip ("المتبقية — ٢ مهام").
class AssignmentSummary {
  const AssignmentSummary({
    required this.label,
    required this.value,
    this.unit,
  });

  /// Caption above the readout ("المتبقية").
  final String label;

  /// Bold readout ("٢", "٪96").
  final String value;

  /// Smaller word following the value ("مهام", "مكتملة"). Left out when the
  /// readout is a single token, like the rating percentage.
  final String? unit;
}
