import 'package:flutter/widgets.dart';

/// An upcoming exam or assignment on the home dashboard.
class HomeTask {
  const HomeTask({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.actionLabel,
    this.meta,
    this.progressBadge,
    this.countdown,
    this.statusNote,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  final String title;

  /// Label of the card's action button ("التفاصيل", "عرض").
  final String actionLabel;

  /// Secondary line, e.g. the submission date.
  final String? meta;

  /// Small badge pinned to the opposite corner of the icon, e.g. '٪43'.
  final String? progressBadge;

  /// Urgent line shown in the brand error tone ("متبقي ٢٤ ساعة فقط").
  final String? countdown;

  /// Calm status line ("قيد التسليم للمراجعة").
  final String? statusNote;
}
