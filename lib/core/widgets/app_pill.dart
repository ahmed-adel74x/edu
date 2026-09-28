import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_dimensions.dart';

/// A small rounded pill used for badges, tags and rating chips.
/// Consolidates what used to be several one-off DecoratedBox blocks.
class AppPill extends StatelessWidget {
  const AppPill({
    super.key,
    required this.child,
    this.color,
    this.horizontalPadding,
    this.verticalPadding,
  });

  final Widget child;
  final Color? color;
  final double? horizontalPadding;
  final double? verticalPadding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding ?? AppSpacing.xs,
          vertical: verticalPadding ?? 4.h,
        ),
        child: child,
      ),
    );
  }
}
