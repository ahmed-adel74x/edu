import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_pill.dart';

/// Course-discount promo banner. Lives in this feature (not `core/`)
/// because its content — a percentage off courses — only ever makes
/// sense here; every string is supplied by the caller, so there's
/// nothing feature-specific hiding inside a "shared" widget.
class PromoBanner extends StatelessWidget {
  const PromoBanner({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.code,
    required this.countdown,
    required this.ctaLabel,
    this.onActivate,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final String code;
  final String countdown;
  final String ctaLabel;
  final VoidCallback? onActivate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: AppColors.promoGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppPill(
                color: Colors.white.withOpacity(0.16),
                child: Text(
                  eyebrow,
                  style: AppTextStyles.label.copyWith(color: Colors.white),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 13.sp,
                    color: Colors.white70,
                  ),
                  HGap.xxs(),
                  Text(
                    countdown,
                    style: AppTextStyles.label.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          VGap.md(),
          Text(
            title,
            textAlign: TextAlign.right,
            style: AppTextStyles.display.copyWith(color: Colors.white),
          ),
          VGap.xs(),
          Text(
            subtitle,
            textAlign: TextAlign.right,
            style: AppTextStyles.body.copyWith(
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          VGap.lg(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_offer_rounded,
                    size: 15.sp,
                    color: Colors.white,
                  ),
                  HGap.xxs(),
                  Text(
                    code,
                    style: AppTextStyles.cardTitle.copyWith(
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                ),
                child: Text(
                  ctaLabel,
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
