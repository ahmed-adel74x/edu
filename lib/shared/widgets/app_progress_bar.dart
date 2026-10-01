import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors_extension.dart';
import '../../core/theme/app_dimensions.dart';

/// Rounded, direction-aware progress bar.
///
/// The fill is anchored to the leading edge (the right side in RTL, matching
/// the reading order of the app) and grows in with a short ease so a progress
/// reveal never "pops".
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.gradient,
    this.trackColor,
  });

  /// Completion in the 0..1 range (clamped).
  final double value;

  /// Bar thickness in design pixels, resolved through `.h`.
  final double height;

  /// Defaults to the theme's progress gradient.
  final LinearGradient? gradient;

  /// Defaults to the theme's tinted surface.
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final progress = value.clamp(0.0, 1.0);
    return SizedBox(
      height: height.h,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: progress),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        builder: (context, animated, _) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: trackColor ?? context.colors.surfaceTint),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FractionallySizedBox(
                    widthFactor: animated,
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: gradient ?? context.colors.progressGradient,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
