import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors_extension.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_type_scale.dart';

/// Soft mint info strip with an icon tile, a bold [label] and a [text] body.
class AuthInfoBanner extends StatelessWidget {
  const AuthInfoBanner({
    super.key,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.label,
    required this.text,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.tintMint.withOpacity(0.35),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.colors.tintMint),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 20.sp, color: iconColor),
          ),
          HGap.sm(),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: label,
                    style: context.texts.bodySmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: context.colors.accent,
                    ),
                  ),
                  TextSpan(text: text, style: context.texts.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
