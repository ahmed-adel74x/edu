import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';

/// Generic "no results" view. The default title/message are deliberately
/// generic (from [AppStrings]) — a feature that wants more specific
/// copy ("لا توجد دورات مطابقة" instead of "لا توجد نتائج") passes its
/// own strings instead of this widget hardcoding them.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    this.icon = Icons.search_off_rounded,
    this.title = AppStrings.emptyStateTitle,
    this.message = AppStrings.emptyStateMessage,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: const BoxDecoration(
              color: AppColors.surfaceTint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 30.sp),
          ),
          VGap.md(),
          Text(title, style: AppTextStyles.cardTitle),
          VGap.xxs(),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}