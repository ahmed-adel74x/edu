import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_progress_bar.dart';
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
          CourseThumbnail(image: course.image, size: 72, radius: AppRadius.sm),
          HGap.sm(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  course.title,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle,
                ),
                VGap.xxs(),
                Text(
                  course.instructor,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall,
                ),
                VGap.sm(),
                Row(
                  children: [
                    Text(
                      course.progressLabel,
                      style: AppTextStyles.metricLabel.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
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
              backgroundColor: AppColors.surfaceTint,
              foregroundColor: AppColors.primary,
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
