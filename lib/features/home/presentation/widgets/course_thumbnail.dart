import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Square course image used by the "continue learning" cards. The featured
/// card layers a play affordance on top of it.
class CourseThumbnail extends StatelessWidget {
  const CourseThumbnail({
    super.key,
    required this.image,
    this.size = 88,
    this.radius,
    this.showPlayOverlay = false,
  });

  final String image;

  /// Rendered as a square of `size.w`.
  final double size;

  /// Defaults to [AppRadius.md].
  final double? radius;

  final bool showPlayOverlay;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.w,
      height: size.w,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius ?? AppRadius.md),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(image, fit: BoxFit.cover),
            if (showPlayOverlay)
              Center(
                child: Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    color: AppColors.scrim.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
