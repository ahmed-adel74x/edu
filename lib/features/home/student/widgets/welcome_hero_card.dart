import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_type_scale.dart';
import '../../constants/home_strings.dart';

/// Greeting card at the top of the home screen: the "browse new" link, the
/// welcome copy and a preview of the interactive curriculum.
class WelcomeHeroCard extends StatelessWidget {
  const WelcomeHeroCard({
    super.key,
    required this.name,
    this.onBrowseNew,
    this.onCurriculumTap,
  });

  /// The signed-in student's name, shown in the greeting.
  final String name;

  final VoidCallback? onBrowseNew;
  final VoidCallback? onCurriculumTap;

  static const String previewImage = 'assets/courses/course_3.jpeg';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: context.colors.heroGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow,
            blurRadius: 18,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The "browse new" link keeps the trailing spot it held opposite the
          // (now removed) streak badge, so the header reads in the same order on
          // narrow phones as on wide ones.
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: _BrowseNewLink(onTap: onBrowseNew),
          ),
          VGap.md(),
          Text(HomeStrings.welcomeTitle(name), style: context.texts.display),
          VGap.xs(),
          Text(HomeStrings.welcomeSubtitle, style: context.texts.body),
          VGap.lg(),
          _CurriculumPreview(image: previewImage, onTap: onCurriculumTap),
        ],
      ),
    );
  }
}

class _BrowseNewLink extends StatelessWidget {
  const _BrowseNewLink({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              HomeStrings.browseNew,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.texts.linkAction,
            ),
          ),
          HGap.xxs(),
          Icon(
            Icons.arrow_back_rounded,
            size: 16.sp,
            color: context.colors.primary,
          ),
        ],
      ),
    );
  }
}

/// Interactive-curriculum teaser: the product preview shot with a chip that
/// sits on it, plus a light wash so the chip stays legible on any image.
class _CurriculumPreview extends StatelessWidget {
  const _CurriculumPreview({required this.image, required this.onTap});

  final String image;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 148.h,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          // Frames the shot so it reads as a product preview window, like the
          // reference's browser mock.
          border: Border.all(color: context.colors.borderStrong),
          boxShadow: [
            BoxShadow(
              color: context.colors.shadow,
              blurRadius: 14,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              image,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
            // Faint bottom fade only: enough to seat the chip that sits on the
            // shot without washing the image out.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0, 0.5],
                  colors: [
                    Colors.white.withValues(alpha: 0.32),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
            PositionedDirectional(
              start: AppSpacing.sm,
              end: AppSpacing.sm,
              bottom: AppSpacing.sm,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: const _CurriculumChip(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurriculumChip extends StatelessWidget {
  const _CurriculumChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6.h),
      decoration: BoxDecoration(
        color: context.colors.scrim.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.settings_rounded, size: 15.sp, color: Colors.white),
          HGap.xxs(),
          Flexible(
            child: Text(
              HomeStrings.curriculumBadge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.texts.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
