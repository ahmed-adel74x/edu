import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_type_scale.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_icon_tile.dart';
import '../../../../shared/widgets/app_pill.dart';
import '../../data/models/home_task.dart';

/// An upcoming exam or assignment: what it is, when it's due, and how far
/// along it is, with one action to open it.
class UpcomingTaskCard extends StatelessWidget {
  const UpcomingTaskCard({super.key, required this.task, this.onAction});

  final HomeTask task;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: AppRadius.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIconTile(
                icon: task.icon,
                color: task.iconColor,
                background: task.iconBackground,
              ),
              HGap.sm(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      task.title,
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.cardTitle,
                    ),
                    if (task.meta != null) ...[
                      VGap.xxs(),
                      Text(
                        task.meta!,
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.bodySmall,
                      ),
                    ],
                    if (task.statusNote != null) ...[
                      VGap.xxs(),
                      Text(
                        task.statusNote!,
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colors.accent,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (task.progressBadge != null) ...[
                HGap.xs(),
                AppPill(
                  color: context.colors.tintLavender,
                  child: Text(
                    task.progressBadge!,
                    style: context.texts.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          VGap.md(),
          Row(
            children: [
              // Keeps the action at the trailing edge even when the card has
              // no countdown to show.
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: task.countdown == null
                      ? const SizedBox.shrink()
                      : _CountdownLabel(text: task.countdown!),
                ),
              ),
              _TaskActionButton(label: task.actionLabel, onPressed: onAction),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountdownLabel extends StatelessWidget {
  const _CountdownLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule_rounded, size: 15.sp, color: context.colors.error),
        HGap.xxs(),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.texts.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.error,
            ),
          ),
        ),
      ],
    );
  }
}

class _TaskActionButton extends StatelessWidget {
  const _TaskActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: context.colors.surfaceTint,
        foregroundColor: context.colors.primary,
        minimumSize: Size(0, 38.h),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      child: Text(
        label,
        style: context.texts.bodySmall.copyWith(
          fontWeight: FontWeight.w700,
          color: context.colors.primary,
        ),
      ),
    );
  }
}
