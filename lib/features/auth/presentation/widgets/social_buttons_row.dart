import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../constants/auth_strings.dart';

/// Google + Apple quick-auth buttons, side by side.
class SocialButtonsRow extends StatelessWidget {
  const SocialButtonsRow({super.key, this.onGoogleTap, this.onAppleTap});

  final VoidCallback? onGoogleTap;
  final VoidCallback? onAppleTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            label: AuthStrings.google,
            // TODO: swap for the official Google "G" asset.
            icon: Icons.g_mobiledata_rounded,
            onTap: onGoogleTap,
          ),
        ),
        HGap.sm(),
        Expanded(
          child: _SocialButton(
            label: AuthStrings.apple,
            icon: Icons.apple,
            onTap: onAppleTap,
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.md);
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap ?? () {},
        child: SizedBox(
          height: 52.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24.sp, color: AppColors.ink),
              HGap.xs(),
              Text(
                label,
                style: AppTextStyles.cardTitle.copyWith(fontSize: 14.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
