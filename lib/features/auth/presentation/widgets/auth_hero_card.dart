import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Welcome card at the top of the auth screens. [topStart] / [topEnd] are the
/// two small badges on the first row (right / left in RTL).
class AuthHeroCard extends StatelessWidget {
  const AuthHeroCard({
    super.key,
    required this.topStart,
    required this.topEnd,
    required this.title,
    required this.subtitle,
  });

  final Widget topStart;
  final Widget topEnd;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Faint cap watermark on the trailing (left) edge.
          Positioned(
            left: -AppSpacing.md,
            bottom: -AppSpacing.md,
            child: Icon(
              Icons.school_rounded,
              size: 96.sp,
              color: AppColors.primary.withOpacity(0.06),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [topStart, topEnd],
                ),
                VGap.sm(),
                Text(title, style: AppTextStyles.display),
                VGap.xs(),
                Text(subtitle, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
