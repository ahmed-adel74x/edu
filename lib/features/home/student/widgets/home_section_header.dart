import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_type_scale.dart';

/// Title row of a home section: a marker at the start of the title (a plain
/// brand dot by default, or [icon] for sections that read better with one)
/// plus an optional trailing widget — an inline link or a count badge.
class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.iconColor,
    this.trailing,
  });

  final String title;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon == null)
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: context.colors.primary,
              shape: BoxShape.circle,
            ),
          )
        else
          Icon(icon, size: 20.sp, color: iconColor ?? context.colors.primary),
        HGap.xs(),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.texts.sectionTitle,
          ),
        ),
        if (trailing != null) ...[HGap.sm(), trailing!],
      ],
    );
  }
}
