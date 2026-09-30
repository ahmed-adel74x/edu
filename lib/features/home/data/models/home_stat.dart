import 'package:flutter/widgets.dart';

/// One tile of the home dashboard summary grid (registered courses,
/// study hours, completed courses, earned certificates…).
class HomeStat {
  const HomeStat({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });

  final String label;

  /// Already formatted for display (the dashboard uses Arabic-Indic digits).
  final String value;

  /// Unit shown next to [value] ("دورات", "ساعة", "شهادة").
  final String unit;

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
}
