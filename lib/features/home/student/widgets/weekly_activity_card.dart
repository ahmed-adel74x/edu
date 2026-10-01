import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_type_scale.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_pill.dart';
import '../../constants/home_strings.dart';
import '../../data/models/weekly_activity.dart';

/// Weekly attendance summary: the section's copy on top and a bar per weekday
/// underneath, growing in once when the card is built.
class WeeklyActivityCard extends StatelessWidget {
  const WeeklyActivityCard({super.key, required this.days});

  final List<WeeklyActivityDay> days;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      HomeStrings.weeklyTitle,
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.sectionTitle,
                    ),
                    VGap.xxs(),
                    Text(
                      HomeStrings.weeklySubtitle,
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.bodySmall,
                    ),
                  ],
                ),
              ),
              HGap.sm(),
              const _RangePill(),
            ],
          ),
          VGap.lg(),
          WeeklyActivityChart(days: days),
        ],
      ),
    );
  }
}

class _RangePill extends StatelessWidget {
  const _RangePill();

  @override
  Widget build(BuildContext context) {
    return AppPill(
      color: context.colors.surfaceTint,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.w,
            height: 7.w,
            decoration: BoxDecoration(
              color: context.colors.success,
              shape: BoxShape.circle,
            ),
          ),
          HGap.xxs(),
          Text(
            HomeStrings.weeklyRangePill,
            style: context.texts.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// One bottom-aligned bar per weekday. Inactive days stay in a neutral tint,
/// active days take the brand blue and today is highlighted in the teal
/// accent, so the learner's own day is findable at a glance.
class WeeklyActivityChart extends StatelessWidget {
  const WeeklyActivityChart({super.key, required this.days});

  final List<WeeklyActivityDay> days;

  /// Height of a full (ratio == 1) bar.
  static const double maxBarHeight = 96;

  /// Height of the shortest bar, so a barely-used day is still visible.
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
            for (var i = 0; i < days.length; i++) ...[
              if (i > 0) HGap.xxs(),
              Expanded(
                child: _ActivityBar(day: days[i], progress: progress),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ActivityBar extends StatelessWidget {
  const _ActivityBar({required this.day, required this.progress});

  final WeeklyActivityDay day;

  /// Animation driver: 0 hides the bars, 1 shows them at full height.
  final double progress;

  @override
  Widget build(BuildContext context) {
    final ratio = day.ratio.clamp(0.0, 1.0);
    final height =
        (WeeklyActivityChart.minBarHeight +
            (WeeklyActivityChart.maxBarHeight -
                    WeeklyActivityChart.minBarHeight) *
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
        Text(
          day.label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.texts.axisLabel,
        ),
      ],
    );
  }

  Color _color(BuildContext context) {
    if (day.isToday) return context.colors.accent;
    if (day.isActive) return context.colors.primary;
    return context.colors.borderStrong;
  }
}
