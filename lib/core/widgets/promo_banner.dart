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
              // Both labels keep a flexible width and ellipsize, so a long
              // eyebrow or countdown can never push the row over.
              Flexible(
                child: AppPill(
                  color: Colors.white.withOpacity(0.16),
                  child: Text(
                    eyebrow,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(color: Colors.white),
                  ),
                ),
              ),
              HGap.sm(),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 13.sp,
                      color: Colors.white70,
                    ),
                    HGap.xxs(),
                    Flexible(
                      child: Text(
                        countdown,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            AppTextStyles.label.copyWith(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
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
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_offer_rounded,
                      size: 15.sp,
                      color: Colors.white,
                    ),
                    HGap.xxs(),
                    Flexible(
                      child: Text(
                        code,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.cardTitle.copyWith(
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              HGap.sm(),
              Flexible(
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                  child: Text(
                    ctaLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.primary,
                    ),
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
