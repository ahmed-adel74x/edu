import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_pill.dart';
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
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.sectionTitle,
                    ),
                    VGap.xxs(),
                    Text(
                      HomeStrings.weeklySubtitle,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall,
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
      color: AppColors.surfaceTint,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.w,
            height: 7.w,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          HGap.xxs(),
          Text(
            HomeStrings.weeklyRangePill,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.inkMuted,
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
              Expanded(child: _ActivityBar(day: days[i], progress: progress)),
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
            (WeeklyActivityChart.maxBarHeight - WeeklyActivityChart.minBarHeight) *
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
              color: _color(),
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
          style: AppTextStyles.axisLabel,
        ),
      ],
    );
  }

  Color _color() {
    if (day.isToday) return AppColors.accent;
    if (day.isActive) return AppColors.primary;
    return AppColors.borderStrong;
  }
}
