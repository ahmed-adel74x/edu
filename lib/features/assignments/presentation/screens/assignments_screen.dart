import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../constants/assignments_strings.dart';

/// Assignments & tasks tab: the learner's progress summary, the search and
/// status filters, and the assignment cards that are still pending, already
/// submitted or graded.
class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                children: [
                  const _TopBar(),
                  VGap.md(),
                  // The progress hero, the search/filter row and the
                  // assignment cards are added in the next steps.
                  const EmptyStateView(
                    icon: Icons.assignment_rounded,
                    title: AppStrings.comingSoonTitle,
                    message: AppStrings.comingSoonMessage,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Page header: the academy name above the screen title, the notifications
/// bell and the learner's avatar — laid out right-to-left like the rest of
/// the app's headers.
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                AppStrings.appName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.label,
              ),
              Text(
                AssignmentsStrings.screenTitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.cardTitle,
              ),
            ],
          ),
        ),
        HGap.sm(),
        const _NotificationBell(),
        HGap.sm(),
        const _ProfileAvatar(),
      ],
    );
  }
}

/// Bell action with a small unread dot on its corner.
class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: () {},
          tooltip: AppStrings.notifications,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.ink,
            fixedSize: Size(44.w, 44.w),
            shape: const CircleBorder(),
            side: const BorderSide(color: AppColors.border),
          ),
          icon: Icon(Icons.notifications_none_rounded, size: 20.sp),
        ),
        Positioned(
          top: 6.h,
          right: 8.w,
          child: Container(
            width: 9.w,
            height: 9.w,
            decoration: BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(Icons.person_rounded, size: 22.sp, color: AppColors.inkFaint),
    );
  }
}