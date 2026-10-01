import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors_extension.dart';
import '../../../core/theme/app_dimensions.dart';

/// Placeholder shown while course data is loading. Mirrors [CourseCard]'s
/// proportions so the layout doesn't jump once real content arrives.
///
/// The fills below are opaque *masks*: [Shimmer] paints its theme-aware gradient
/// through `BlendMode.srcIn`, so only their alpha reaches the screen — the
/// theme's surface keeps that alpha opaque in both themes.
class CourseCardSkeleton extends StatelessWidget {
  const CourseCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.colors.surfaceMuted,
      highlightColor: context.colors.surfaceTint,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 168.h,
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(height: 16.h, color: context.colors.surface),
                  VGap.sm(),
                  Container(
                    height: 12.h,
                    width: 120.w,
                    color: context.colors.surface,
                  ),
                  VGap.md(),
                  Container(height: 36.h, color: context.colors.surface),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
