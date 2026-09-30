import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_icon_tile.dart';
import '../../../shared/widgets/app_pill.dart';
import '../constants/assignments_strings.dart';
import '../data/models/assignment.dart';
import '../data/models/assignment_status.dart';

/// One assignment of the list: the course it comes from, what it asks for,
/// where it stands, and the lines and actions that follow from that status.
class AssignmentCard extends StatelessWidget {
  const AssignmentCard({
    super.key,
    required this.assignment,
    this.onTap,
    this.onSubmit,
    this.onDownloadBrief,
    this.onViewSubmission,
    this.onPreviewAttachment,
    this.onResend,
  });

  final Assignment assignment;

  /// Opens the assignment; the shared [AppCard] adds its usual press feedback.
  final VoidCallback? onTap;

  /// The hand-in action of a pending assignment.
  final VoidCallback? onSubmit;

  /// Downloads the brief attached to a pending assignment.
  final VoidCallback? onDownloadBrief;

  /// Opens the submitted answer file and certificate of a graded assignment.
  final VoidCallback? onViewSubmission;

  /// Previews the attachment of an assignment that is under review.
  final VoidCallback? onPreviewAttachment;

  /// Resends the work of an assignment that is under review.
  final VoidCallback? onResend;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: AppRadius.md,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIconTile(
                icon: assignment.icon,
                color: assignment.iconColor,
                background: assignment.iconBackground,
              ),
              HGap.sm(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      assignment.course,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall,
                    ),
                    VGap.xxs(),
                    Text(
                      assignment.title,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardTitle,
                    ),
                    VGap.xxs(),
                    Text(
                      assignment.excerpt,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              HGap.xs(),
              // The pill keeps a hard cap and lets its label ellipsize, so a
              // long status text can never push the header row over.
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 150.w),
                child: _StatusPill(
                  status: assignment.status,
                  gradeLabel: assignment.gradeLabel,
                ),
              ),
            ],
          ),
          if (assignment.dueLabel != null || assignment.fileLabel != null) ...[
            VGap.sm(),
            const Divider(),
            VGap.sm(),
            _AssignmentMeta(assignment: assignment),
          ],
          if (assignment.instructorNote != null) ...[
            VGap.md(),
            _InstructorNote(assignment: assignment),
          ],
          if (assignment.status == AssignmentStatus.pending) ...[
            VGap.md(),
            _SubmitActions(
              onSubmit: onSubmit,
              onDownloadBrief: onDownloadBrief,
            ),
          ],
          if (assignment.status == AssignmentStatus.graded) ...[
            VGap.md(),
            Row(
              children: [
                // Both ends hug their content but can give way, so a long
                // action label or a narrow phone never overflows the row.
                Flexible(
                  child: _CardActionButton(
                    label: AssignmentsStrings.viewSubmissionCta,
                    icon: Icons.visibility_rounded,
                    onPressed: onViewSubmission,
                  ),
                ),
                HGap.sm(),
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: _SubmissionLine(assignment: assignment),
                  ),
                ),
              ],
            ),
          ],
          if (assignment.status == AssignmentStatus.submitted) ...[
            VGap.sm(),
            _SubmissionLine(assignment: assignment),
            VGap.md(),
            Row(
              children: [
                Flexible(child: _ResendLink(onTap: onResend)),
                HGap.sm(),
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: _CardActionButton(
                      label: AssignmentsStrings.previewCta,
                      icon: Icons.visibility_rounded,
                      onPressed: onPreviewAttachment,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Status chip of a card: the pending and under-review buckets stay neutral, a
/// graded one takes the mint success treatment and prints the awarded score.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, this.gradeLabel});

  final AssignmentStatus status;
  final String? gradeLabel;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case AssignmentStatus.graded:
        return AppPill(
          color: AppColors.tintMint,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 13.sp,
                color: AppColors.accent,
              ),
              HGap.xxs(),
              Flexible(
                child: _PillLabel(
                  text: gradeLabel ?? AssignmentsStrings.gradedBadge,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        );
      case AssignmentStatus.pending:
        return AppPill(
          color: AppColors.surfaceMuted,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _WaitingDot(),
              HGap.xxs(),
              const Flexible(
                child: _PillLabel(
                  text: AssignmentsStrings.pendingBadge,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        );
      case AssignmentStatus.submitted:
        return AppPill(
          color: AppColors.surfaceMuted,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 13.sp,
                color: AppColors.inkFaint,
              ),
              HGap.xxs(),
              const Flexible(
                child: _PillLabel(
                  text: AssignmentsStrings.underReviewBadge,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        );
    }
  }
}

class _PillLabel extends StatelessWidget {
  const _PillLabel({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.bodySmall.copyWith(
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }
}

/// Amber clock dot that marks an assignment as still waiting.
class _WaitingDot extends StatelessWidget {
  const _WaitingDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 15.w,
      height: 15.w,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.warning,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.schedule_rounded,
        size: 10.sp,
        color: AppColors.onPrimary,
      ),
    );
  }
}

/// Deadline and attachment of an assignment, grouped on the muted panel that
/// sits under the card's divider.
class _AssignmentMeta extends StatelessWidget {
  const _AssignmentMeta({required this.assignment});

  final Assignment assignment;

  @override
  Widget build(BuildContext context) {
    final hasDue = assignment.dueLabel != null;
    final hasFile = assignment.fileLabel != null;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasDue)
            _MetaLine(
              icon: Icons.schedule_rounded,
              text: assignment.dueLabel!,
              color: assignment.isDueSoon ? AppColors.error : AppColors.inkMuted,
            ),
          if (hasDue && hasFile) VGap.xs(),
          if (hasFile)
            _MetaLine(
              icon: Icons.description_outlined,
              text: assignment.fileLabel!,
              color: AppColors.inkMuted,
            ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15.sp, color: color),
        HGap.xxs(),
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

/// The two actions of a pending assignment: hand the work in, or download the
/// brief. The hand-in button is the screen's one pink surface, so it reads as
/// the step the learner is expected to take next.
class _SubmitActions extends StatelessWidget {
  const _SubmitActions({this.onSubmit, this.onDownloadBrief});

  final VoidCallback? onSubmit;
  final VoidCallback? onDownloadBrief;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _CardActionButton(
            label: AssignmentsStrings.briefCta,
            icon: Icons.download_rounded,
            onPressed: onDownloadBrief,
          ),
        ),
        HGap.xs(),
        Expanded(
          flex: 3,
          child: _CardActionButton(
            label: AssignmentsStrings.submitCta,
            icon: Icons.cloud_upload_rounded,
            onPressed: onSubmit,
            isPrimary: true,
            iconFirst: true,
          ),
        ),
      ],
    );
  }
}

/// A card-level action: the pink hand-in treatment or the lavender secondary
/// one, with the glyph at the start or the end of the label.
class _CardActionButton extends StatelessWidget {
  const _CardActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
    this.iconFirst = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  /// Paints the pink hand-in treatment instead of the lavender one.
  final bool isPrimary;

  /// Puts the glyph at the start of the label (the right, in RTL).
  final bool iconFirst;

  @override
  Widget build(BuildContext context) {
    final foreground = isPrimary ? AppColors.onPrimary : AppColors.primary;
    final glyph = Icon(icon, size: 16.sp, color: foreground);
    final caption = Flexible(
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor:
            isPrimary ? AppColors.uploadAccent : AppColors.surfaceTint,
        foregroundColor: foreground,
        minimumSize: Size(0, 42.h),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: iconFirst
            ? [glyph, HGap.xxs(), caption]
            : [caption, HGap.xxs(), glyph],
      ),
    );
  }
}

/// Instructor feedback of a graded assignment: who graded it and the note
/// itself, on the tinted panel that marks it as the grader's voice.
class _InstructorNote extends StatelessWidget {
  const _InstructorNote({required this.assignment});

  final Assignment assignment;

  @override
  Widget build(BuildContext context) {
    final name = assignment.instructorName;
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (name != null) ...[
            Text(
              '${AssignmentsStrings.instructorNotesPrefix} $name',
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            VGap.xs(),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InstructorAvatar(initials: assignment.instructorInitials),
              HGap.xs(),
              Expanded(
                child: Text(
                  assignment.instructorNote!,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.bodySmall.copyWith(height: 1.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Round avatar of the instructor, built from initials exactly like the
/// instructor block of the course details page.
class _InstructorAvatar extends StatelessWidget {
  const _InstructorAvatar({this.initials});

  final String? initials;

  static const double _size = 36;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size.w,
      height: _size.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 2),
      ),
      child: Text(
        initials ?? '',
        maxLines: 1,
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.onPrimary,
          fontSize: 13.sp,
        ),
      ),
    );
  }
}

/// Green line of a handed-in assignment: when it was submitted, or the file
/// that went in along with its time.
class _SubmissionLine extends StatelessWidget {
  const _SubmissionLine({required this.assignment});

  final Assignment assignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle_rounded,
          size: 15.sp,
          color: AppColors.accent,
        ),
        HGap.xxs(),
        Flexible(
          child: Text(
            assignment.submittedLabel!,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        ),
        if (assignment.submittedAtLabel != null) ...[
          HGap.xxs(),
          Text(
            assignment.submittedAtLabel!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.inkFaint,
            ),
          ),
        ],
      ],
    );
  }
}

/// Inline secondary action of an assignment that is still under review.
class _ResendLink extends StatelessWidget {
  const _ResendLink({this.onTap});

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
              AssignmentsStrings.resendCta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.linkAction.copyWith(
                color: AppColors.inkMuted,
              ),
            ),
          ),
          HGap.xxs(),
          Icon(
            Icons.refresh_rounded,
            size: 16.sp,
            color: AppColors.inkMuted,
          ),
        ],
      ),
    );
  }
}
