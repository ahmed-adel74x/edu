import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors_extension.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_type_scale.dart';
import '../../../core/utils/number_format.dart';
import '../data/models/assignment_filter.dart';
import '../data/models/assignment_status.dart';

/// Horizontal row of status filters for the assignments list.
///
/// It mirrors [CategoryChipRow] of the explore screen — same pill, same
/// selected/unselected colors — but each chip can also carry the number of
/// assignments in its bucket.
class AssignmentFilterBar extends StatelessWidget {
  const AssignmentFilterBar({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  final List<AssignmentFilter> filters;

  /// Selected bucket; `null` stands for the "show everything" chip.
  final AssignmentStatus? selected;

  final ValueChanged<AssignmentStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => HGap.xs(),
        itemBuilder: (context, index) {
          final filter = filters[index];
          return _FilterChip(
            filter: filter,
            isSelected: filter.status == selected,
            onTap: () => onSelected(filter.status),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.filter,
    required this.isSelected,
    required this.onTap,
  });

  final AssignmentFilter filter;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final labelColor = isSelected
        ? context.colors.onPrimary
        : context.colors.inkMuted;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4.h),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primary
              : context.colors.surfaceTint,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        alignment: Alignment.center,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: filter.label,
                style: context.texts.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: labelColor,
                ),
              ),
              if (filter.count != null)
                TextSpan(
                  text: ' (${_formatCount(context, filter.count!)})',
                  style: context.texts.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? labelColor.withValues(alpha: 0.75)
                        : context.colors.inkFaint,
                  ),
                ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// Renders a count in the digits of the active language ("٤" in Arabic, "4" in
/// English), through the app's shared number helper.
String _formatCount(BuildContext context, int value) =>
    formatNumber(context, value);
