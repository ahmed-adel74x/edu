import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_type_scale.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_icon_tile.dart';
import '../../data/models/home_stat.dart';

/// Two-column grid of [StatTile]s. The tiles of a row share the height of the
/// tallest one, so a caption that wraps to two lines doesn't break the grid
/// rhythm.
class StatTileGrid extends StatelessWidget {
  const StatTileGrid({super.key, required this.stats});

  final List<HomeStat> stats;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < stats.length; i += 2) {
      final trailing = i + 1 < stats.length ? stats[i + 1] : null;
      if (rows.isNotEmpty) rows.add(VGap.md());
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: StatTile(stat: stats[i])),
              HGap.md(),
              Expanded(
                child: trailing == null
                    ? const SizedBox.shrink()
                    : StatTile(stat: trailing),
              ),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

/// A single dashboard summary tile: caption and icon on top, the value at the
/// bottom — aligned to the start (right) edge like the rest of the app.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.stat});

  final HomeStat stat;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: AppRadius.md,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  stat.label,
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.statLabel,
                ),
              ),
              HGap.xs(),
              AppIconTile(
                icon: stat.icon,
                color: stat.iconColor,
                background: stat.iconBackground,
              ),
            ],
          ),
          VGap.md(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(stat.value, style: context.texts.statValue),
              HGap.xxs(),
              Text(stat.unit, style: context.texts.statUnit),
            ],
          ),
        ],
      ),
    );
  }
}
