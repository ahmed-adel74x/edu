import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/user_role.dart';
import '../constants/auth_strings.dart';

/// Picks which of the three roles the next session belongs to.
///
/// It only exists while auth is mocked: once a real account signs in, the role
/// comes from the user and the selector goes away. The row follows the app's
/// chip language (brand blue once chosen, surface + hairline border otherwise)
/// so the auth screens stay visually unchanged apart from this one control.
class RoleSelector extends StatelessWidget {
  const RoleSelector({
    super.key,
    required this.selected,
    required this.onSelected,
    this.label = AuthStrings.roleSelectorLabel,
  });

  final UserRole selected;
  final ValueChanged<UserRole> onSelected;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppTextStyles.label),
        VGap.xs(),
        Row(
          children: [
            for (final role in UserRole.values) ...[
              if (role != UserRole.values.first) HGap.xs(),
              Expanded(
                child: _RoleChip(
                  role: role,
                  isSelected: role == selected,
                  onTap: () => onSelected(role),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// One option of the [RoleSelector]: the role's icon above its name.
class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  final UserRole role;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected ? AppColors.onPrimary : AppColors.inkMuted;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xxs,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(_iconFor(role), size: 20.sp, color: foreground),
            VGap.xxs(),
            Text(
              _labelFor(role),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _iconFor(UserRole role) => switch (role) {
        UserRole.student => Icons.school_rounded,
        UserRole.teacher => Icons.co_present_rounded,
        UserRole.parent => Icons.family_restroom_rounded,
      };

  static String _labelFor(UserRole role) => switch (role) {
        UserRole.student => AuthStrings.roleStudent,
        UserRole.teacher => AuthStrings.roleTeacher,
        UserRole.parent => AuthStrings.roleParent,
      };
}
