import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_type_scale.dart';
import '../../../../core/utils/number_format.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../constants/home_strings.dart';
import '../../data/models/attendance_bar.dart';

/// Attendance summary: the section's copy on top, then one bar per month the
/// backend sent, growing in once when the card is built.
///
/// The months are the app's own (derived from the API's month *number*); only
/// the counts are the payload's. A card with nothing to chart — no months at
/// all, or only months that held no lectures — keeps its title and says so
/// instead of drawing an empty chart.
class AttendanceActivityCard extends StatelessWidget {
  const AttendanceActivityCard({
    super.key,
    required this.bars,
    required this.attendedLectures,
    required this.totalLectures,
  });

  /// One entry per month, January first, exactly as the backend serves them.
  final List<AttendanceBar> bars;

  /// Lectures attended across [bars] — the subtitle's numerator.
  final int attendedLectures;

  /// Lectures held across [bars] — the subtitle's denominator.
  final int totalLectures;

  bool get _hasData => bars.isNotEmpty && totalLectures > 0;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            HomeStrings.attendanceTitle,
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.texts.sectionTitle,
          ),
          if (_hasData) ...[
            VGap.xxs(),
            Text(
              HomeStrings.attendanceSubtitle(
                formatNumber(context, attendedLectures),
                formatNumber(context, totalLectures),
              ),
              textAlign: TextAlign.start,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.texts.bodySmall,
            ),
            VGap.lg(),
            AttendanceActivityChart(bars: bars),
          ] else
            // Nothing attended yet: reporting "0 out of 0" would be noise, so
            // the title stands alone and the section says what will fill it.
            EmptyStateView(
              icon: Icons.calendar_month_rounded,
              title: HomeStrings.emptyAttendanceTitle,
              message: HomeStrings.emptyAttendanceMessage,
            ),
        ],
      ),
    );
  }
}

/// One bottom-aligned bar per month. A month the learner attended lectures
/// takes the brand blue, a month that held none stays in a neutral tint and the
/// current month is highlighted in the teal accent, so the month in progress is
/// findable at a glance.
class AttendanceActivityChart extends StatelessWidget {
  const AttendanceActivityChart({super.key, required this.bars});

  final List<AttendanceBar> bars;

  /// Height of a full (ratio == 1) bar.
  static const double maxBarHeight = 96;

  /// Height of the shortest bar, so a month with little attendance is still
  /// visible — and a month that held no lectures at all is still a bar.
  static const double minBarHeight = 12;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, progress, _) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < bars.length; i++) ...[
              if (i > 0) HGap.xxs(),
              Expanded(child: _ActivityBar(bar: bars[i], progress: progress)),
            ],
          ],
        );
      },
    );
  }
}

class _ActivityBar extends StatelessWidget {
  const _ActivityBar({required this.bar, required this.progress});

  final AttendanceBar bar;

  /// Animation driver: 0 hides the bars, 1 shows them at full height.
  final double progress;

  @override
  Widget build(BuildContext context) {
    final ratio = bar.ratio.clamp(0.0, 1.0);
    final height =
        (AttendanceActivityChart.minBarHeight +
            (AttendanceActivityChart.maxBarHeight -
                    AttendanceActivityChart.minBarHeight) *
                ratio) *
        progress;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height.h,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _color(context),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.pill),
                bottom: Radius.circular(AppRadius.xs),
              ),
            ),
          ),
        ),
        VGap.xs(),
        // A year is up to twelve bars on a narrow phone, so the month name
        // shrinks to whatever width its bar got rather than overflowing or
        // being cut off — in either language.
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            bar.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: context.texts.axisLabel,
          ),
        ),
      ],
    );
  }

  Color _color(BuildContext context) {
    if (bar.isCurrent) return context.colors.accent;
    if (bar.isActive) return context.colors.primary;
    return context.colors.borderStrong;
  }
}
