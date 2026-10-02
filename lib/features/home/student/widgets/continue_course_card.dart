import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_type_scale.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_progress_bar.dart';
import '../../constants/home_strings.dart';
import '../../data/models/enrolled_course.dart';
import 'course_thumbnail.dart';

/// The featured "continue learning" card: course info, completion progress and
/// one primary call to action.
class ContinueCourseCard extends StatelessWidget {
  const ContinueCourseCard({
    super.key,
    required this.course,
    this.onContinue,
    this.onTap,
  });

  final EnrolledCourse course;
  final VoidCallback? onContinue;

  /// Opens the course details page; the card itself stays visually identical
  /// (the shared [AppCard] only adds its usual press feedback).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CourseThumbnail(
                coverPath: course.coverPath,
                size: 88,
                showPlayOverlay: true,
              ),
              HGap.sm(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (course.instructor != null) ...[
                      _InstructorLine(name: course.instructor!),
                      VGap.xs(),
                    ],
                    Text(
                      course.title,
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.cardTitle,
                    ),
                    if (course.remainingLessons != null) ...[
                      VGap.xxs(),
                      Text(
                        course.remainingLessons!,
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          VGap.md(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(HomeStrings.progressLabel, style: context.texts.metricLabel),
              Text(
                course.progressLabel,
                style: context.texts.metricLabel.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colors.ink,
                ),
              ),
            ],
          ),
          VGap.xs(),
          AppProgressBar(value: course.progress),
          VGap.md(),
          FilledButton.icon(
            onPressed: onContinue,
            icon: Icon(Icons.play_arrow_rounded, size: 18.sp),
            label: Text(HomeStrings.continueLessonCta),
            style: FilledButton.styleFrom(
              minimumSize: Size.fromHeight(46.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructorLine extends StatelessWidget {
  const _InstructorLine({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            name,
            textAlign: TextAlign.start,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.texts.bodySmall,
          ),
        ),
        HGap.xxs(),
        Icon(
          Icons.person_outline_rounded,
          size: 14.sp,
          color: context.colors.inkFaint,
        ),
      ],
    );
  }
}
