/// One bar of the weekly attendance chart.
class WeeklyActivityDay {
  const WeeklyActivityDay({
    required this.label,
    required this.ratio,
    this.isActive = false,
    this.isToday = false,
  });

  /// Weekday name shown under the bar.
  final String label;

  /// Bar height in the 0..1 range, relative to the tallest bar.
  final double ratio;

  /// Days the learner was active are drawn in the brand blue.
  final bool isActive;

  /// Today's bar is highlighted in the teal accent.
  final bool isToday;
}
