import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_pill.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../constants/course_details_strings.dart';
import '../../data/models/course_details.dart';
import '../widgets/course_curriculum_section.dart';
import '../widgets/course_instructor_card.dart';
import '../widgets/course_stat_grid.dart';

/// Full course page: cover, overview summary, instructor, curriculum and a
/// sticky action bar at the bottom.
class CourseDetailsScreen extends StatelessWidget {
  const CourseDetailsScreen({super.key, required this.course, this.onContinue});

  /// Invoked by the bottom bar's primary action. The screen doesn't know how
  /// to open the player yet, so the caller wires it.
  final VoidCallback? onContinue;

  /// Preview course used when the screen is shown without a picked course
  /// (design previews / tests). Cards opened from the lists build their own
  /// instance through [CourseDetails.fromCourse].
  static final CourseDetails sample = CourseDetails.fromCourse(
    image: 'assets/courses/course_1.png',
    title: 'تجربة للدورات (المحاضرات)',
    instructor: 'أحمد سعيد',
    rating: '4.9',
    duration: '30 ساعة',
    badge: 'المنهاج الدراسي - معتمد',
    ctaLabel: 'متابعة الدورة (الدرس 2)',
    isEnrolled: true,
    progress: 0.25,
    progressLabel: '25%',
  );

  final CourseDetails course;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                children: [
                  const _TopBar(title: CourseDetailsStrings.screenTitle),
                  VGap.md(),
                  _CoverSection(course: course),
                  VGap.md(),
                  _OverviewSection(course: course),
                  VGap.md(),
                  CourseInstructorCard(instructor: course.instructor),
                  VGap.xl(),
                  _CurriculumSection(course: course),
                  VGap.xl(),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: _BottomActionBar(
          course: course,
          onContinue: onContinue,
        ),
      ),
    );
  }
}

/// Back affordance + centered page title + profile avatar.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _ProfileAvatar(),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.sectionTitle,
          ),
        ),

        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          style: IconButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.ink,
            fixedSize: Size(40.w, 40.w),
            shape: const CircleBorder(),
          ),
          icon: Icon(Icons.arrow_forward_rounded, size: 22.sp),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(Icons.person_rounded, size: 20.sp, color: AppColors.primary),
    );
  }
}

/// Cover image with the rating chip and the accredited-curriculum badge
/// layered on it, plus a soft bottom scrim that keeps both legible.
class _CoverSection extends StatelessWidget {
  const _CoverSection({required this.course});

  final CourseDetails course;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Stack(
          children: [
            SizedBox(
              height: 168.h,
              width: double.infinity,
              child: Image.asset(course.image, fit: BoxFit.cover),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 72.h,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.scrim.withValues(alpha: 0.45),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.sm,
              right: AppSpacing.sm,
              bottom: AppSpacing.sm,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(child: _CoverBadge(label: course.coverBadge)),
                  HGap.sm(),
                  _CoverRating(rating: course.rating),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Frosted white chip carrying the course rating on the cover.
class _CoverRating extends StatelessWidget {
  const _CoverRating({required this.rating});

  final String rating;

  @override
  Widget build(BuildContext context) {
    return AppPill(
      color: AppColors.surface,
      horizontalPadding: AppSpacing.sm,
      verticalPadding: 6.h,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 15.sp, color: AppColors.star),
          HGap.xxs(),
          Flexible(
            child: Text(
              rating,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// White chip announcing the accredited curriculum ("المنهاج الدراسي - معتمد").
class _CoverBadge extends StatelessWidget {
  const _CoverBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return AppPill(
      color: AppColors.surface.withValues(alpha: 0.95),
      horizontalPadding: AppSpacing.sm,
      verticalPadding: 6.h,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.settings_rounded, size: 13.sp, color: AppColors.ink),
          HGap.xxs(),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label.copyWith(color: AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

/// Course title, description and the summary stat grid.
class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.course});

  final CourseDetails course;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            course.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.display,
          ),
          VGap.sm(),
          Text(
            course.description,
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
          VGap.lg(),
          CourseStatGrid(stats: course.stats),
        ],
      ),
    );
  }
}

/// Curriculum header plus the collapsible units.
class _CurriculumSection extends StatelessWidget {
  const _CurriculumSection({required this.course});

  final CourseDetails course;

  @override
  Widget build(BuildContext context) {
    return CourseCurriculumSection(
      units: course.units,
      meta: course.curriculumMeta,
    );
  }
}

/// Sticky bottom bar: enrollment state and progress on the start side, the
/// main resume action on the other.
class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.course, this.onContinue});

  final CourseDetails course;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.vertical(top: Radius.circular(AppRadius.lg));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, -6.h),
          ),
        ],
      ),
      // Clipped so the hairline and the surface follow the rounded top corners.
      child: ClipRRect(
        borderRadius: radius,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 1,
              width: double.infinity,
              child: const ColoredBox(color: AppColors.border),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final progress = _ProgressBlock(course: course);
                    final action = _PrimaryAction(
                      course: course,
                      onTap: onContinue,
                    );

                    // On very narrow phones the two blocks would squeeze each
                    // other, so the action takes the full width under the
                    // progress readout.
                    if (constraints.maxWidth < 300) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [progress, VGap.sm(), action],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: progress),
                        HGap.md(),
                        Expanded(flex: 2, child: action),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "مسجل بالفعل" + the completion readout and bar.
class _ProgressBlock extends StatelessWidget {
  const _ProgressBlock({required this.course});

  final CourseDetails course;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (course.isEnrolled) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              HGap.xxs(),
              Flexible(
                child: Text(
                  CourseDetailsStrings.enrolledLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label.copyWith(color: AppColors.success),
                ),
              ),
            ],
          ),
          VGap.xs(),
        ],
        Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CourseDetailsStrings.progressLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.metricLabel,
                ),
                Text(
                  course.progressLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.metricLabel.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
            HGap.xs(),
            Expanded(child: AppProgressBar(value: course.progress, height: 6)),
          ],
        ),
      ],
    );
  }
}

/// The single primary call to action of the page.
class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.course, this.onTap});

  final CourseDetails course;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        minimumSize: Size.fromHeight(48.h),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              size: 18.sp,
              color: AppColors.primary,
            ),
          ),
          HGap.xs(),
          Flexible(
            child: Text(
              course.nextLessonLabel ?? CourseDetailsStrings.continueCta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.button,
            ),
          ),
        ],
      ),
    );
  }
}
