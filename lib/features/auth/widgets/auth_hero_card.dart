import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors_extension.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_type_scale.dart';

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
        gradient: context.colors.heroGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow,
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Faint cap watermark on the trailing edge.
          PositionedDirectional(
            end: -AppSpacing.md,
            bottom: -AppSpacing.md,
            child: Icon(
              Icons.school_rounded,
              size: 96.sp,
              color: context.colors.primary.withOpacity(0.06),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // A [Wrap] rather than a [Row]: a badge keeps its own width, and
                // one that no longer fits (a wide glyph set, a large text scale)
                // drops to its own line instead of overflowing the card. When
                // both fit, `spaceBetween` pins them to the two edges exactly
                // like the row did.
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.xs,
                  children: [topStart, topEnd],
                ),
                VGap.sm(),
                Text(title, style: context.texts.display),
                VGap.xs(),
                Text(subtitle, style: context.texts.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
