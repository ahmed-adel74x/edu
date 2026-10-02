import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_type_scale.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_icon_tile.dart';
import '../../../../shared/widgets/app_progress_bar.dart';
import '../../constants/home_strings.dart';
import '../../data/models/recent_quiz.dart';

/// One recent quiz attempt: what it was, which course it belongs to, when it
/// was submitted and how it scored.
///
/// The score is shown as a plain readout and a bar — never as pass or fail:
/// no pass mark is documented, so the card must not imply a verdict.
class RecentQuizCard extends StatelessWidget {
  const RecentQuizCard({super.key, required this.quiz});

  final RecentQuiz quiz;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: AppRadius.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIconTile(
                icon: Icons.quiz_outlined,
                color: context.colors.primary,
                background: context.colors.tintLavender,
              ),
              HGap.sm(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      quiz.title,
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.cardTitle,
                    ),
                    if (quiz.courseName != null) ...[
                      VGap.xxs(),
                      Text(
                        quiz.courseName!,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              // The attempt carries no route of its own yet, so the card is not
              // tappable: it stays a plain surface until one exists.
              // TODO(quizzes): open the quiz attempt once its route exists.
            ],
          ),
          if (quiz.submittedAt != null) ...[
            VGap.sm(),
            Row(
              children: [
                Icon(
                  Icons.event_available_rounded,
                  size: 15.sp,
                  color: context.colors.inkFaint,
                ),
                HGap.xxs(),
                Expanded(
                  child: Text(
                    quiz.submittedAt!,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.bodySmall,
                  ),
                ),
              ],
            ),
          ],
          VGap.md(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(HomeStrings.quizScoreLabel, style: context.texts.metricLabel),
              Text(
                quiz.scoreLabel,
                style: context.texts.metricLabel.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colors.ink,
                ),
              ),
            ],
          ),
          VGap.xs(),
          AppProgressBar(value: quiz.ratio),
        ],
      ),
    );
  }
}
