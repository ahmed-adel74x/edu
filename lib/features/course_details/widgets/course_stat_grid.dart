import 'package:flutter/material.dart';

import '../../../core/theme/app_colors_extension.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_type_scale.dart';
import '../../../shared/widgets/app_icon_tile.dart';
import '../data/models/course_details.dart';

/// Two-column grid of the course summary tiles (عدد الدروس، مدة الدورة،
/// المستوى، الاعتماد). The tiles of a row share the height of the tallest one,
/// so a caption or a value that wraps to two lines doesn't break the grid.
class CourseStatGrid extends StatelessWidget {
  const CourseStatGrid({super.key, required this.stats});

  final List<CourseDetailStat> stats;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < stats.length; i += 2) {
      final trailing = i + 1 < stats.length ? stats[i + 1] : null;
      if (rows.isNotEmpty) rows.add(VGap.sm());
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: CourseStatTile(stat: stats[i])),
              HGap.sm(),
              Expanded(
                child: trailing == null
                    ? const SizedBox.shrink()
                    : CourseStatTile(stat: trailing),
              ),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

/// A single summary tile: caption on top, value next to its tinted icon —
/// aligned to the start (right) edge like the rest of the app.
class CourseStatTile extends StatelessWidget {
  const CourseStatTile({super.key, required this.stat});

  final CourseDetailStat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            stat.label,
            textAlign: TextAlign.start,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.texts.metricLabel,
          ),
          VGap.xs(),
          Row(
            children: [
              AppIconTile(
                icon: stat.icon,
                color: stat.iconColor,
                background: stat.iconBackground,
                size: 36,
                iconSize: 18,
                radius: AppRadius.pill,
              ),
              HGap.xs(),
              Expanded(
                child: Text(
                  stat.value,
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.statLabel.copyWith(
                    fontWeight: FontWeight.w800,
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
