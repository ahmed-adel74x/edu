import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors_extension.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_type_scale.dart';
import '../../../shared/widgets/app_pill.dart';
import '../constants/assignments_strings.dart';
import '../data/models/assignment_summary.dart';

/// Progress hero of the assignments screen: the excellence level and streak on
/// top, the nudge to finish on time underneath and the learner's workload as a
/// three-cell readout, all on the brand gradient.
class AssignmentsProgressHero extends StatelessWidget {
  const AssignmentsProgressHero({
    super.key,
    required this.summary,
    this.onPointsTap,
  });

  /// The three readouts at the bottom of the card.
  final List<AssignmentSummary> summary;

  /// Invoked by the star action in the corner; the screen wires it.
  final VoidCallback? onPointsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: context.colors.promoGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow,
            blurRadius: 18,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Both labels keep a flexible width so the row survives narrow
              // phones and large text scales without overflowing.
              Expanded(
                child: Row(
                  children: [
                    Flexible(child: const _LevelBadge()),
                    HGap.xs(),
                    Flexible(
                      child: Text(
                        AssignmentsStrings.streakBadge,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colors.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              HGap.sm(),
              _PointsButton(onTap: onPointsTap),
            ],
          ),
          VGap.md(),
          Text(
            AssignmentsStrings.heroTitle,
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.texts.sectionTitle.copyWith(
              color: context.colors.onPrimary,
            ),
          ),
          VGap.xs(),
          Text(
            AssignmentsStrings.heroSubtitle,
            textAlign: TextAlign.start,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: context.texts.bodySmall.copyWith(
              color: context.colors.onPrimary.withValues(alpha: 0.82),
            ),
          ),
          VGap.md(),
          _SummaryStrip(summary: summary),
        ],
      ),
    );
  }
}

/// Translucent level chip that opens the hero.
class _LevelBadge extends StatelessWidget {
  const _LevelBadge();

  @override
  Widget build(BuildContext context) {
    return AppPill(
      color: context.colors.onPrimary.withValues(alpha: 0.18),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bolt_rounded,
            size: 14.sp,
            color: context.colors.onPrimary,
          ),
          HGap.xxs(),
          Flexible(
            child: Text(
              AssignmentsStrings.levelBadge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.texts.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Star action pinned to the far corner of the hero.
class _PointsButton extends StatelessWidget {
  const _PointsButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: AssignmentsStrings.pointsTooltip,
      style: IconButton.styleFrom(
        backgroundColor: context.colors.onPrimary.withValues(alpha: 0.18),
        foregroundColor: context.colors.onPrimary,
        fixedSize: Size(42.w, 42.w),
        shape: const CircleBorder(),
      ),
      icon: Icon(Icons.star_rounded, size: 22.sp),
    );
  }
}

/// The workload readout: one cell per [AssignmentSummary], split by hairlines.
class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.summary});

  final List<AssignmentSummary> summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.onPrimary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          for (var i = 0; i < summary.length; i++) ...[
            if (i > 0) const _StripDivider(),
            Expanded(child: _SummaryCell(item: summary[i])),
          ],
        ],
      ),
    );
  }
}

class _StripDivider extends StatelessWidget {
  const _StripDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32.h,
      color: context.colors.onPrimary.withValues(alpha: 0.2),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({required this.item});

  final AssignmentSummary item;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          item.label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.texts.bodySmall.copyWith(
            color: context.colors.onPrimary.withValues(alpha: 0.78),
          ),
        ),
        VGap.xxs(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Text(
                item.value,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.texts.cardTitle.copyWith(
                  color: context.colors.onPrimary,
                ),
              ),
            ),
            if (item.unit != null) ...[
              HGap.xxs(),
              Flexible(
                child: Text(
                  item.unit!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
