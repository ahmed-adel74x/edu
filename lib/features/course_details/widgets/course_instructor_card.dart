import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_pill.dart';
import '../constants/course_details_strings.dart';
import '../data/models/course_details.dart';

/// The instructor block ("مرشدك المبدع"): avatar, name and headline, a short
/// bio, then the learner count and rating readouts.
class CourseInstructorCard extends StatelessWidget {
  const CourseInstructorCard({super.key, required this.instructor});

  final CourseInstructor instructor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  CourseDetailsStrings.instructorSectionTitle,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.linkAction,
                ),
              ),
              HGap.xs(),
              Flexible(
                child: AppPill(
                  color: AppColors.tintLavender,
                  child: Text(
                    CourseDetailsStrings.instructorProfileBadge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          VGap.md(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InstructorAvatar(initials: instructor.initials),
              HGap.sm(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      instructor.name,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardTitle,
                    ),
                    VGap.xxs(),
                    Text(
                      instructor.headline,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          VGap.sm(),
          Text(
            instructor.bio,
            textAlign: TextAlign.right,
            style: AppTextStyles.body,
          ),
          VGap.md(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _InstructorMetric(
                icon: Icons.star_rounded,
                iconColor: AppColors.star,
                value: instructor.rating,
              ),
              HGap.lg(),
              _InstructorMetric(
                icon: Icons.groups_rounded,
                iconColor: AppColors.inkMuted,
                value: '${instructor.students} '
                    '${CourseDetailsStrings.studentsLabel}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Round avatar built from the instructor's initials, with the small brand
/// badge that sits on its bottom-trailing corner.
class _InstructorAvatar extends StatelessWidget {
  const _InstructorAvatar({required this.initials});

  final String initials;

  static const double _size = 60;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size.w,
      height: _size.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: _size.w,
            height: _size.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 2),
            ),
            child: Text(
              initials,
              style: AppTextStyles.cardTitle.copyWith(
                color: AppColors.onPrimary,
                fontSize: 20.sp,
              ),
            ),
          ),
          Positioned(
            right: -2.w,
            bottom: -2.w,
            child: Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
              child: Icon(
                Icons.workspace_premium_rounded,
                size: 11.sp,
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One rating / learner-count readout under the bio.
class _InstructorMetric extends StatelessWidget {
  const _InstructorMetric({
    required this.icon,
    required this.iconColor,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.sp, color: iconColor),
        HGap.xxs(),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.statLabel.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}
