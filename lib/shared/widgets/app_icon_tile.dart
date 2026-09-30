import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_dimensions.dart';

/// Rounded square holding a single icon, used for the dashboard summaries
/// (stats, upcoming tasks…) so every icon tile in the app is the same size
/// and shape.
class AppIconTile extends StatelessWidget {
  const AppIconTile({
    super.key,
    required this.icon,
    required this.color,
    required this.background,
    this.size = 44,
    this.iconSize = 22,
    this.radius,
  });

  final IconData icon;

  /// Ink of the glyph.
  final Color color;

  /// Tint behind the glyph.
  final Color background;

  final double size;
  final double iconSize;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius ?? AppRadius.sm),
      ),
      child: Icon(icon, color: color, size: iconSize.sp),
    );
  }
}
