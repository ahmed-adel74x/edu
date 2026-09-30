import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon_tile.dart';
import '../../constants/course_details_strings.dart';
import '../../data/models/course_details.dart';

/// "منهج الدورة" — the units of the course with their lessons. Units expand and
/// collapse in place; the learner's current unit starts open.
class CourseCurriculumSection extends StatefulWidget {
  const CourseCurriculumSection({
    super.key,
    required this.units,
    required this.meta,
  });

  final List<CourseUnit> units;

  /// e.g. '3 وحدات • 15 درس'.
  final String meta;

  @override
  State<CourseCurriculumSection> createState() =>
      _CourseCurriculumSectionState();
}

class _CourseCurriculumSectionState extends State<CourseCurriculumSection> {
  /// Orders of the units currently open on screen.
  late final Set<int> _expanded = {
    for (final unit in widget.units)
      if (unit.initiallyExpanded) unit.order,
  };

  void _toggle(int order) {
    setState(() {
      if (!_expanded.remove(order)) _expanded.add(order);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.format_list_bulleted_rounded,
              size: 20.sp,
              color: AppColors.primary,
            ),
            HGap.xs(),
            Expanded(
              child: Text(
                CourseDetailsStrings.curriculumTitle,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.sectionTitle,
              ),
            ),
            HGap.sm(),
            Flexible(
              child: Text(
                widget.meta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall,
              ),
            ),
          ],
        ),
        VGap.md(),
        for (final unit in widget.units) ...[
          _CurriculumUnit(
            unit: unit,
            expanded: _expanded.contains(unit.order),
            onToggle: () => _toggle(unit.order),
          ),
          VGap.sm(),
        ],
      ],
    );
  }
}

/// One unit: a flat tinted header (number badge, title, meta, chevron) that
/// reveals its lessons when tapped.
class _CurriculumUnit extends StatelessWidget {
  const _CurriculumUnit({
    required this.unit,
    required this.expanded,
    required this.onToggle,
  });

  final CourseUnit unit;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.md),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onToggle,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  _UnitBadge(order: unit.order, active: expanded),
                  HGap.sm(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          unit.title,
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.cardTitle,
                        ),
                        VGap.xxs(),
                        Text(
                          unit.meta,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  HGap.xs(),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22.sp,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (unit.lessons.isNotEmpty)
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: expanded
                ? Padding(
                    padding: EdgeInsets.only(top: AppSpacing.xs),
                    child: _LessonList(lessons: unit.lessons),
                  )
                : const SizedBox(width: double.infinity),
          ),
      ],
    );
  }
}

/// Round unit number: filled with the brand color while the unit is open,
/// a soft tint when it is closed.
class _UnitBadge extends StatelessWidget {
  const _UnitBadge({required this.order, required this.active});

  final int order;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.w,
      height: 30.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.surfaceTint,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$order',
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w700,
          color: active ? AppColors.onPrimary : AppColors.inkMuted,
        ),
      ),
    );
  }
}


/// The white panel holding a unit's lesson rows.
class _LessonList extends StatelessWidget {
  const _LessonList({required this.lessons});

  final List<CourseLesson> lessons;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        children: [
          for (var i = 0; i < lessons.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            _LessonRow(lesson: lessons[i]),
          ],
        ],
      ),
    );
  }
}

/// A single lesson line: status on the leading edge, title/meta in the middle
/// and the content-kind affordance on the trailing edge.
class _LessonRow extends StatelessWidget {
  const _LessonRow({required this.lesson});

  final CourseLesson lesson;

  @override
  Widget build(BuildContext context) {
    final isCurrent = lesson.status == LessonStatus.playing;
    final muted = lesson.isLocked;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.surfaceTint : null,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          _statusTile(lesson.status),
          HGap.sm(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        lesson.title,
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.cardTitle.copyWith(
                          color: muted ? AppColors.inkFaint : AppColors.ink,
                        ),
                      ),
                    ),
                    if (isCurrent) ...[HGap.xs(), const _NowBadge()],
                  ],
                ),
                VGap.xxs(),
                Text(
                  lesson.meta,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          HGap.sm(),
          _kindTile(lesson),
        ],
      ),
    );
  }
}

/// "الآن" — marks the lesson the learner is currently inside.
class _NowBadge extends StatelessWidget {
  const _NowBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        CourseDetailsStrings.nowBadge,
        style: AppTextStyles.label.copyWith(color: AppColors.onPrimary),
      ),
    );
  }
}

/// Leading circle: watched, listening now, available or still locked.
Widget _statusTile(LessonStatus status) {
  switch (status) {
    case LessonStatus.completed:
      return AppIconTile(
        icon: Icons.check_rounded,
        color: AppColors.accent,
        background: AppColors.tintMint,
        size: 40,
        iconSize: 20,
        radius: AppRadius.pill,
      );
    case LessonStatus.playing:
      return AppIconTile(
        icon: Icons.graphic_eq_rounded,
        color: AppColors.accent,
        background: AppColors.tintMint,
        size: 40,
        iconSize: 20,
        radius: AppRadius.pill,
      );
    case LessonStatus.locked:
      return AppIconTile(
        icon: Icons.lock_outline_rounded,
        color: AppColors.inkFaint,
        background: AppColors.surfaceMuted,
        size: 40,
        iconSize: 18,
        radius: AppRadius.pill,
      );
    case LessonStatus.available:
      return AppIconTile(
        icon: Icons.play_arrow_rounded,
        color: AppColors.primary,
        background: AppColors.tintLavender,
        size: 40,
        iconSize: 20,
        radius: AppRadius.pill,
      );
  }
}

/// Trailing circle: the lesson type, or the play button of the lesson the
/// learner can resume right now.
Widget _kindTile(CourseLesson lesson) {
  if (lesson.status == LessonStatus.playing) {
    return AppIconTile(
      icon: Icons.play_arrow_rounded,
      color: AppColors.onPrimary,
      background: AppColors.primary,
      size: 38,
      iconSize: 22,
      radius: AppRadius.pill,
    );
  }

  switch (lesson.kind) {
    case LessonKind.video:
      return AppIconTile(
        icon: Icons.play_arrow_rounded,
        color: AppColors.accent,
        background: AppColors.tintMint,
        size: 36,
        iconSize: 20,
        radius: AppRadius.pill,
      );
    case LessonKind.quiz:
      return AppIconTile(
        icon: Icons.rule_rounded,
        color: AppColors.primary,
        background: AppColors.tintLavender,
        size: 36,
        iconSize: 18,
        radius: AppRadius.pill,
      );
    case LessonKind.reading:
      return AppIconTile(
        icon: Icons.menu_book_rounded,
        color: AppColors.warningDeep,
        background: AppColors.tintPeach,
        size: 36,
        iconSize: 18,
        radius: AppRadius.pill,
      );
  }
}
