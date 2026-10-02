import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_type_scale.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_progress_bar.dart';
import '../../data/models/enrolled_course.dart';
import 'course_thumbnail.dart';

/// Compact "continue learning" row: a course the learner can resume with a
/// single tap on the trailing chevron.
class CompactCourseTile extends StatelessWidget {
  const CompactCourseTile({super.key, required this.course, this.onTap});

  final EnrolledCourse course;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          CourseThumbnail(
            coverPath: course.coverPath,
            size: 72,
            radius: AppRadius.sm,
          ),
          HGap.sm(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  course.title,
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.cardTitle,
                ),
                if (course.instructor != null) ...[
                  VGap.xxs(),
                  Text(
                    course.instructor!,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.bodySmall,
                  ),
                ],
                VGap.sm(),
                Row(
                  children: [
                    Text(
                      course.progressLabel,
                      style: context.texts.metricLabel.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.colors.primary,
                      ),
                    ),
                    HGap.xs(),
                    Expanded(
                      child: AppProgressBar(value: course.progress, height: 6),
                    ),
                  ],
                ),
              ],
            ),
          ),
          HGap.sm(),
          IconButton(
            onPressed: onTap,
            tooltip: course.title,
            style: IconButton.styleFrom(
              backgroundColor: context.colors.surfaceTint,
              foregroundColor: context.colors.primary,
              fixedSize: Size(44.w, 44.w),
              shape: const CircleBorder(),
            ),
            icon: Icon(Icons.chevron_left_rounded, size: 22.sp),
          ),
        ],
      ),
    );
  }
}
