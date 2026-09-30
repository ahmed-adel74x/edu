import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../constants/auth_strings.dart';

/// Shared frame of the login and sign-up screens: soft gradient background,
/// top bar (back / title / help), scrolling [children], and a [footer] that
/// sticks to the bottom when the content is short.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.children,
    this.footer = const [],
  });

  final String title;
  final List<Widget> children;
  final List<Widget> footer;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: AppColors.authBackgroundGradient,
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: CustomScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      sliver: SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _AuthTopBar(title: title),
                            VGap.lg(),
                            ...children,
                            const Spacer(),
                            VGap.lg(),
                            ...footer,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthTopBar extends StatelessWidget {
  const _AuthTopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // IconButton(
        //   onPressed: () => Navigator.of(context).maybePop(),
        //   tooltip: AuthStrings.back,
        //   icon: Icon(Icons.chevron_right_rounded, size: 24.sp),
        //   style: IconButton.styleFrom(
        //     backgroundColor: AppColors.surface,
        //     foregroundColor: AppColors.ink,
        //     fixedSize: Size(44.w, 44.w),
        //     shape: const CircleBorder(
        //       side: BorderSide(color: AppColors.border),
        //     ),
        //   ),
        // ),
        // HGap.sm(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.appName, style: AppTextStyles.label),
            Text(title, style: AppTextStyles.sectionTitle),
          ],
        ),
        const Spacer(),
        Material(
          color: AppColors.surfaceTint,
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () {}, // TODO: open help / support
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Text(AuthStrings.help, style: AppTextStyles.linkAction),
            ),
          ),
        ),
      ],
    );
  }
}
