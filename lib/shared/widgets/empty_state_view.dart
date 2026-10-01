import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors_extension.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_type_scale.dart';

/// Generic "no results" view. The default title/message are deliberately
/// generic (from [AppStrings]) — a feature that wants more specific
/// copy ("لا توجد دورات مطابقة" instead of "لا توجد نتائج") passes its
/// own strings instead of this widget hardcoding them.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    this.icon = Icons.search_off_rounded,
    this.title,
    this.message,
  });

  final IconData icon;

  /// Defaults to the shared "nothing to show" copy.
  final String? title;

  /// Defaults to the shared "adjust your search" hint.
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: context.colors.surfaceTint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: context.colors.primary, size: 30.sp),
          ),
          VGap.md(),
          Text(
            title ?? AppStrings.emptyStateTitle,
            style: context.texts.cardTitle,
          ),
          VGap.xxs(),
          Text(
            message ?? AppStrings.emptyStateMessage,
            textAlign: TextAlign.center,
            style: context.texts.body,
          ),
        ],
      ),
    );
  }
}
