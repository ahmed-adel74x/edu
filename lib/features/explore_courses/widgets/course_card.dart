import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_edu/features/explore_courses/constants/explore_courses_strings.dart';

import '../data/models/course.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors_extension.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_type_scale.dart';
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
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: context.colors.border),
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
                            textAlign: TextAlign.start,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.texts.cardTitle,
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
                              style: context.texts.bodySmall,
                            ),
                            HGap.xs(),
                            CircleAvatar(
                              radius: 12.r,
                              backgroundColor: context.colors.surfaceTint,
                              child: Text(
                                course.avatar,
                                style: context.texts.label.copyWith(
                                  color: context.colors.primary,
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
                              color: context.colors.inkFaint,
                            ),
                            HGap.xxs(),
                            Text(
                              course.duration,
                              style: context.texts.bodySmall,
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
                                style: context.texts.label,
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
                                      style: context.texts.priceLarge,
                                    ),
                                  ),
                                  HGap.xxs(),
                                  Text(
                                    AppStrings.currencySar,
                                    style: context.texts.bodySmall.copyWith(
                                      color: context.colors.primary,
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
        PositionedDirectional(
          start: 0,
          end: 0,
          bottom: 0,
          height: 56.h,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  context.colors.scrim.withOpacity(0.55),
                ],
              ),
            ),
          ),
        ),
        PositionedDirectional(
          top: AppSpacing.sm,
          start: AppSpacing.sm,
          child: _FavoriteButton(isFavorite: isFavorite, onTap: onFavoriteTap),
        ),
        PositionedDirectional(
          end: AppSpacing.sm,
          bottom: AppSpacing.sm,
          child: AppPill(
            color: context.colors.accent,
            child: Text(
              course.badge,
              style: context.texts.label.copyWith(
                color: context.colors.onPrimary,
              ),
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
          color: context.colors.scrim.withOpacity(0.4),
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
      color: context.colors.surfaceMuted,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 15.sp, color: context.colors.star),
          HGap.xxs(),
          Text(
            rating,
            style: context.texts.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.ink,
            ),
          ),
          Text(' ($reviews)', style: context.texts.label),
        ],
      ),
    );
  }
}
