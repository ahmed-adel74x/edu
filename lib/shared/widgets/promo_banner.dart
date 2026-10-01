import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors_extension.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_type_scale.dart';
import 'app_pill.dart';

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
        gradient: context.colors.promoGradient,
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withOpacity(0.25),
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
                  color: context.colors.onPrimary.withValues(alpha: 0.16),
                  child: Text(
                    eyebrow,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.label.copyWith(
                      color: context.colors.onPrimary,
                    ),
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
                      color: context.colors.onPrimary.withValues(alpha: 0.7),
                    ),
                    HGap.xxs(),
                    Flexible(
                      child: Text(
                        countdown,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.label.copyWith(
                          color: context.colors.onPrimary.withValues(
                            alpha: 0.7,
                          ),
                        ),
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
            textAlign: TextAlign.start,
            style: context.texts.display.copyWith(
              color: context.colors.onPrimary,
            ),
          ),
          VGap.xs(),
          Text(
            subtitle,
            textAlign: TextAlign.start,
            style: context.texts.body.copyWith(
              color: context.colors.onPrimary.withValues(alpha: 0.85),
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
                      color: context.colors.onPrimary,
                    ),
                    HGap.xxs(),
                    Flexible(
                      child: Text(
                        code,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.cardTitle.copyWith(
                          color: context.colors.onPrimary,
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
                    backgroundColor: context.colors.onPrimary,
                    foregroundColor: context.colors.primary,
                  ),
                  child: Text(
                    ctaLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.button.copyWith(
                      color: context.colors.primary,
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
