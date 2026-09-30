import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

/// Full-width gradient call-to-action button with a trailing arrow and an
/// optional loading state.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_back_rounded,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.md);
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.promoGradient,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 18,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: isLoading ? null : onPressed,
          child: SizedBox(
            height: 54.h,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: AppColors.onPrimary,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: AppTextStyles.button.copyWith(fontSize: 15.sp),
                        ),
                        HGap.xs(),
                        Icon(icon, size: 18.sp, color: AppColors.onPrimary),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
