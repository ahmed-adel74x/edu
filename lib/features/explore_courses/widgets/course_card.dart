import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_edu/features/explore_courses/constants/explore_courses_strings.dart';

import '../data/models/course.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_pill.dart';

class CourseCard extends StatefulWidget {
  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.onEnroll,
  });

  final Course course;
  final VoidCallback? onTap;
  final VoidCallback? onEnroll;

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool isFavorite = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 18,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardImage(
                course: course,
                isFavorite: isFavorite,
                onFavoriteTap: () {
                  setState(() => isFavorite = !isFavorite);
                },
              ),
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            course.title,
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.cardTitle,
                          ),
                        ),
                        HGap.xs(),
                        _RatingPill(
                          rating: course.rating,
                          reviews: course.reviews,
                        ),
                      ],
                    ),
                    VGap.sm(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              course.instructor,
                              style: AppTextStyles.bodySmall,
                            ),
                            HGap.xs(),
                            CircleAvatar(
                              radius: 12.r,
                              backgroundColor: AppColors.surfaceTint,
                              child: Text(
                                course.avatar,
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 14.sp,
                              color: AppColors.inkFaint,
                            ),
                            HGap.xxs(),
                            Text(
                              course.duration,
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    VGap.md(),
                    const Divider(height: 1),
                    VGap.md(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Both ends hug their content but can give way, so a
                        // long price or action label never overflows the row.
                        Flexible(
                          child: Column(
                            // Start (not end): the caption has to sit *above*
                            // the amount, i.e. flush with the leading edge of
                            // the price row — the row is wider than the number
                            // because the currency rides next to it.
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ExploreCoursesStrings.totalPrice,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.label,
                              ),
                              VGap.xxs(),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Flexible(
                                    child: Text(
                                      course.price,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.priceLarge,
                                    ),
                                  ),
                                  HGap.xxs(),
                                  Text(
                                    AppStrings.currencySar,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        HGap.sm(),
                        Flexible(
                          child: FilledButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.arrow_back_rounded, size: 16.sp),
                            label: Text(
                              course.buttonLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({
    required this.course,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  final Course course;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 168.h,
          width: double.infinity,
          child: Image.asset(course.image, fit: BoxFit.cover),
        ),
        // Subtle bottom scrim so the badge always stays legible over any photo.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 56.h,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppColors.scrim.withOpacity(0.55)],
              ),
            ),
          ),
        ),
        Positioned(
          top: AppSpacing.sm,
          left: AppSpacing.sm,
          child: _FavoriteButton(isFavorite: isFavorite, onTap: onFavoriteTap),
        ),
        Positioned(
          right: AppSpacing.sm,
          bottom: AppSpacing.sm,
          child: AppPill(
            color: AppColors.accent,
            child: Text(
              course.badge,
              style: AppTextStyles.label.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.isFavorite, required this.onTap});

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: AppColors.scrim.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Icon(
            isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            key: ValueKey(isFavorite),
            color: Colors.white,
            size: 18.sp,
          ),
        ),
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.rating, required this.reviews});

  final String rating;
  final String reviews;

  @override
  Widget build(BuildContext context) {
    return AppPill(
      color: AppColors.surfaceMuted,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 15.sp, color: AppColors.star),
          HGap.xxs(),
          Text(
            rating,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          Text(' ($reviews)', style: AppTextStyles.label),
        ],
      ),
    );
  }
}
