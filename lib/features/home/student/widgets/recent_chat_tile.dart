import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_type_scale.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../constants/home_strings.dart';
import '../../data/models/recent_chat.dart';

/// One recent chat room: who it is with, what was said last and when.
///
/// The chat room carries no route of its own yet, so the tile is not tappable:
/// it stays a plain surface until one exists, and shows no unread badge or
/// presence dot — neither is in the payload.
// TODO(chat): make the tile open the room once its route exists.
class RecentChatTile extends StatelessWidget {
  const RecentChatTile({super.key, required this.chat});

  final RecentChat chat;

  @override
  Widget build(BuildContext context) {
    final hasMessage = chat.lastMessage != null;

    return AppCard(
      radius: AppRadius.md,
      child: Row(
        children: [
          _ChatAvatar(initial: chat.initial),
          HGap.sm(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    // The name yields to the time at the end of the line, which
                    // stays whole — the same shape the upcoming card uses for
                    // its own trailing badge.
                    Expanded(
                      child: Text(
                        chat.roomName,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.cardTitle,
                      ),
                    ),
                    if (chat.lastMessageAt != null) ...[
                      HGap.xs(),
                      Text(
                        chat.lastMessageAt!,
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.metricLabel,
                      ),
                    ],
                  ],
                ),
                VGap.xxs(),
                Text(
                  chat.lastMessage ?? HomeStrings.chatNoMessages,
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.bodySmall.copyWith(
                    // A room with no message yet reads as a quieter line than
                    // one that has something to say.
                    color: hasMessage ? null : context.colors.inkFaint,
                    fontStyle: hasMessage ? null : FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The room's avatar: the first character of its name on a tinted circle.
///
/// The character is measured in a text run rather than taken as a code unit, so
/// an emoji or an Arabic letter still yields exactly one glyph to show.
class _ChatAvatar extends StatelessWidget {
  const _ChatAvatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.colors.surfaceTint,
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        maxLines: 1,
        textAlign: TextAlign.center,
        style: context.texts.statLabel.copyWith(
          fontWeight: FontWeight.w700,
          color: context.colors.primary,
        ),
      ),
    );
  }
}
