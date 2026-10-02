import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/di/injection.dart';
import '../../../core/network/failure.dart';
import '../../../core/theme/app_colors_extension.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_type_scale.dart';
import '../../../core/utils/failure_message.dart';
import '../../../core/utils/number_format.dart';
import '../../../shared/widgets/app_pill.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../auth/constants/auth_strings.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../course_details/course_details_route.dart';
import '../../course_details/data/models/course_details.dart';
import '../constants/home_strings.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../data/models/attendance_bar.dart';
import '../data/models/enrolled_course.dart';
import '../data/models/home_stat.dart';
import '../data/models/home_summary.dart';
import '../data/models/home_task.dart';
import '../data/models/recent_chat.dart';
import '../data/models/recent_quiz.dart';
import 'widgets/attendance_activity_card.dart';
import 'widgets/compact_course_tile.dart';
import 'widgets/continue_course_card.dart';
import 'widgets/home_section_header.dart';
import 'widgets/recent_chat_tile.dart';
import 'widgets/recent_quiz_card.dart';
import 'widgets/stat_tile_grid.dart';
import 'widgets/upcoming_task_card.dart';
import 'widgets/welcome_hero_card.dart';

/// Learner dashboard: greeting, progress summary, the courses to pick up again,
/// what is due next, the latest quiz attempts and chats, and the attendance
/// activity month by month.
///
/// The screen owns a [HomeCubit] built from the locator — a factory, so every
/// new session gets a fresh one and never sees the previous user's data. The
/// welcome name comes from the global [AuthCubit], not from this payload.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onSeeAllCourses});

  /// Invoked by the "browse new" / "see all" actions. The shell wires it to
  /// the explore tab, so the dashboard can hand the learner over to it.
  final VoidCallback? onSeeAllCourses;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeCubit>(
      create: (_) => getIt<HomeCubit>()..load(),
      child: _HomeView(onSeeAllCourses: onSeeAllCourses),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView({this.onSeeAllCourses});

  final VoidCallback? onSeeAllCourses;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: BlocListener<HomeCubit, HomeState>(
              listenWhen: (previous, current) =>
                  current.refreshFailure != null &&
                  previous.refreshFailure != current.refreshFailure,
              listener: (context, state) {
                // A failed refresh keeps the data on screen and reports itself
                // once. Other failures replace the body instead.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(failureMessage(state.refreshFailure!)),
                  ),
                );
                context.read<HomeCubit>().consumeRefreshFailure();
              },
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) => switch (state.status) {
                  HomeStatus.loading => const _HomeLoader(),
                  HomeStatus.failure => _HomeFailure(
                    failure: state.failure ?? const UnknownFailure(),
                  ),
                  HomeStatus.success => _HomeContent(
                    summary: state.summary ?? const HomeSummary(),
                    onSeeAllCourses: onSeeAllCourses,
                  ),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The loaded dashboard: the static chrome (welcome header and section titles)
/// with each section filled from the payload.
class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.summary, this.onSeeAllCourses});

  final HomeSummary summary;
  final VoidCallback? onSeeAllCourses;

  @override
  Widget build(BuildContext context) {
    final name = context.watch<AuthCubit>().state.user?.name ?? '';
    final courses = summary.enrolledCourses;
    final assignments = summary.upcomingAssignments;
    final quizzes = summary.recentQuizzes;
    final chats = summary.recentChats;
    final attendance = _attendance(context, summary.attendanceChart);

    return RefreshIndicator(
      onRefresh: () => context.read<HomeCubit>().refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        children: [
          WelcomeHeroCard(
            name: name,
            onBrowseNew: onSeeAllCourses,
            onCurriculumTap: onSeeAllCourses,
          ),
          VGap.md(),
          StatTileGrid(stats: _stats(context, summary.counts)),
          VGap.xl(),
          HomeSectionHeader(
            title: HomeStrings.continueLearningTitle,
            trailing: _SeeAllLink(onTap: onSeeAllCourses),
          ),
          VGap.md(),
          ..._courseSection(context, courses),
          VGap.xl(),
          HomeSectionHeader(
            title: HomeStrings.upcomingTitle,
            icon: Icons.assignment_turned_in_rounded,
            iconColor: context.colors.warningDeep,
            trailing: assignments.isEmpty
                ? null
                : _PendingBadge(
                    label: HomeStrings.upcomingBadge(
                      formatNumber(context, assignments.length),
                    ),
                  ),
          ),
          VGap.md(),
          ..._assignmentSection(context, assignments),
          VGap.xl(),
          HomeSectionHeader(
            title: HomeStrings.recentQuizzesTitle,
            icon: Icons.quiz_outlined,
          ),
          VGap.md(),
          ..._quizSection(context, quizzes),
          VGap.xl(),
          HomeSectionHeader(
            title: HomeStrings.recentChatsTitle,
            icon: Icons.forum_outlined,
          ),
          VGap.md(),
          ..._chatSection(context, chats),
          VGap.xl(),
          AttendanceActivityCard(
            bars: attendance.bars,
            attendedLectures: attendance.attendedLectures,
            totalLectures: attendance.totalLectures,
          ),
        ],
      ),
    );
  }

  /// The four summary tiles, from [HomeCounts]. Icons and tints are the
  /// theme's; the figures are formatted in the language's own digits (study
  /// hours read without an ugly fractional tail).
  List<HomeStat> _stats(BuildContext context, HomeCounts counts) {
    final colors = context.colors;
    return [
      HomeStat(
        label: HomeStrings.statEnrolledCourses,
        value: formatNumber(context, counts.enrolledCourses),
        unit: HomeStrings.statCoursesUnit,
        icon: Icons.menu_book_rounded,
        iconColor: colors.primary,
        iconBackground: colors.tintLavender,
      ),
      HomeStat(
        label: HomeStrings.statStudyHours,
        value: formatDecimal(context, counts.studyHours),
        unit: HomeStrings.statHoursUnit,
        icon: Icons.schedule_rounded,
        iconColor: colors.warningDeep,
        iconBackground: colors.tintPeach,
      ),
      HomeStat(
        label: HomeStrings.statCompletedCourses,
        value: formatNumber(context, counts.completedCourses),
        unit: HomeStrings.statCourseUnit,
        icon: Icons.check_circle_rounded,
        iconColor: colors.accent,
        iconBackground: colors.tintMint,
      ),
      HomeStat(
        label: HomeStrings.statCertificates,
        value: formatNumber(context, counts.certificates),
        unit: HomeStrings.statCertificateUnit,
        icon: Icons.workspace_premium_rounded,
        iconColor: colors.primary,
        iconBackground: colors.tintLavender,
      ),
    ];
  }

  /// The first course is the featured card; the rest are compact rows. An empty
  /// list shows the section's own empty state.
  List<Widget> _courseSection(BuildContext context, List<HomeCourse> courses) {
    if (courses.isEmpty) {
      return [
        EmptyStateView(
          icon: Icons.menu_book_rounded,
          title: HomeStrings.emptyCoursesTitle,
          message: HomeStrings.emptyCoursesMessage,
        ),
      ];
    }
    final widgets = <Widget>[];
    for (var i = 0; i < courses.length; i++) {
      if (i > 0) widgets.add(VGap.md());
      final course = _enrolledOf(context, courses[i]);
      widgets.add(
        i == 0
            ? ContinueCourseCard(
                course: course,
                onContinue: () {},
                onTap: () => _openCourseDetails(context, course),
              )
            : CompactCourseTile(
                course: course,
                onTap: () => _openCourseDetails(context, course),
              ),
      );
    }
    return widgets;
  }

  List<Widget> _assignmentSection(
    BuildContext context,
    List<HomeAssignment> assignments,
  ) {
    if (assignments.isEmpty) {
      return [
        EmptyStateView(
          icon: Icons.assignment_turned_in_rounded,
          title: HomeStrings.emptyAssignmentsTitle,
          message: HomeStrings.emptyAssignmentsMessage,
        ),
      ];
    }
    return [
      for (var i = 0; i < assignments.length; i++) ...[
        if (i > 0) VGap.md(),
        UpcomingTaskCard(
          task: _taskOf(context, assignments[i]),
          onAction: () {
            // TODO(assignments): open the assignment once its route exists.
          },
        ),
      ],
    ];
  }

  /// One card per recent attempt. An attempt's id repeats across items — it is
  /// not usable as a key — so the list is keyed by its position.
  List<Widget> _quizSection(BuildContext context, List<HomeQuiz> quizzes) {
    if (quizzes.isEmpty) {
      return [
        EmptyStateView(
          icon: Icons.quiz_outlined,
          title: HomeStrings.emptyQuizzesTitle,
          message: HomeStrings.emptyQuizzesMessage,
        ),
      ];
    }
    return [
      for (var i = 0; i < quizzes.length; i++) ...[
        if (i > 0) VGap.md(),
        RecentQuizCard(quiz: _quizOf(context, quizzes[i])),
      ],
    ];
  }

  /// One tile per recent room, keyed by its position for the same reason.
  List<Widget> _chatSection(BuildContext context, List<HomeChat> chats) {
    if (chats.isEmpty) {
      return [
        EmptyStateView(
          icon: Icons.forum_outlined,
          title: HomeStrings.emptyChatsTitle,
          message: HomeStrings.emptyChatsMessage,
        ),
      ];
    }
    return [
      for (var i = 0; i < chats.length; i++) ...[
        if (i > 0) VGap.md(),
        RecentChatTile(chat: _chatOf(context, chats[i])),
      ],
    ];
  }

  /// Maps one API course to the "continue learning" cards' view-model.
  EnrolledCourse _enrolledOf(BuildContext context, HomeCourse course) =>
      EnrolledCourse(
        coverPath: course.coverPath,
        title: course.title,
        instructor: course.teacherName,
        progress: (course.progressPercentage / 100).clamp(0.0, 1.0),
        progressLabel: HomeStrings.percent(
          formatNumber(context, course.progressPercentage.round()),
        ),
        remainingLessons: HomeStrings.remainingLectures(
          formatNumber(context, course.remainingLectures),
        ),
      );

  /// Maps one API assignment to the upcoming card: the lecture is the secondary
  /// line, the deadline rides the card's schedule line.
  HomeTask _taskOf(BuildContext context, HomeAssignment assignment) => HomeTask(
    icon: Icons.fact_check_rounded,
    iconColor: context.colors.error,
    iconBackground: context.colors.tintBlush,
    title: assignment.assignmentTitle,
    meta: assignment.lectureTitle.isEmpty ? null : assignment.lectureTitle,
    countdown: _dueLabel(context, assignment),
    actionLabel: HomeStrings.assignmentAction,
  );

  /// A localized deadline line: the parsed date when it read, the raw string
  /// otherwise, and null when the backend sent neither.
  String? _dueLabel(BuildContext context, HomeAssignment assignment) {
    final parsed = assignment.dueDateAt;
    final date = parsed != null
        ? _formatDate(context, parsed)
        : assignment.dueDate;
    if (date.trim().isEmpty) return null;
    return HomeStrings.dueDate(date);
  }

  /// The attendance card's data, mapped from the API's monthly chart: one bar
  /// per month (the last one is the month in progress) plus the lecture totals
  /// its subtitle reads.
  ///
  /// Only the *lectures* series is charted — a bar is a month's lecture
  /// attendance. The courses series stays parsed but undisplayed. Every figure
  /// is the payload's number, turned into text here, in the app's language.
  ({List<AttendanceBar> bars, int attendedLectures, int totalLectures})
  _attendance(BuildContext context, List<AttendanceMonth> months) {
    final bars = <AttendanceBar>[];
    var attended = 0;
    var total = 0;

    for (var i = 0; i < months.length; i++) {
      final month = months[i];
      attended += month.lecturesAttended;
      total += month.lecturesTotal;
      bars.add(
        AttendanceBar(
          label: _monthLabel(context, month.month),
          // A month whose percentage is a fraction of a percent still gets the
          // minimum-height bar; one that held no lectures lands on 0.
          ratio: (month.lecturesPercentage / 100).clamp(0.0, 1.0),
          isActive: month.lecturesAttended > 0,
          // The backend serves January up to the current month, so the current
          // month is the last one.
          isCurrent: i == months.length - 1,
        ),
      );
    }

    return (bars: bars, attendedLectures: attended, totalLectures: total);
  }

  /// Maps one API attempt to the quiz card: the course is the secondary line,
  /// the submission date the trailing one, and the score the bar's value.
  RecentQuiz _quizOf(BuildContext context, HomeQuiz quiz) => RecentQuiz(
    title: quiz.quizTitle,
    courseName: quiz.courseName,
    submittedAt: quiz.submittedAtAt == null
        ? null
        : _formatDate(context, quiz.submittedAtAt!),
    scoreLabel: HomeStrings.percent(
      formatNumber(context, quiz.scorePercent.round()),
    ),
    // The documented range is 0..100; a value that isn't is still charted
    // inside the bar rather than throwing.
    ratio: (quiz.scorePercent / 100).clamp(0.0, 1.0),
  );

  /// Maps one API room to the chat tile. A room with no last message keeps both
  /// its message and its time null, so the tile shows the "no messages" line
  /// without inventing a timestamp.
  RecentChat _chatOf(BuildContext context, HomeChat chat) => RecentChat(
    roomName: chat.roomName,
    initial: _initialOf(chat.roomName),
    lastMessage: chat.lastMessageText,
    lastMessageAt: chat.lastMessageCreatedAtAt == null
        ? null
        : _messageTime(context, chat.lastMessageCreatedAtAt!),
  );

  /// The single character the room's avatar shows, or '' for a nameless room
  /// (the avatar then stays a plain circle).
  ///
  /// Characters are taken as whole grapheme clusters, so an emoji, an Arabic
  /// letter or a composite script still yields exactly one glyph.
  String _initialOf(String roomName) {
    final trimmed = roomName.trim();
    if (trimmed.isEmpty) return '';
    // `.characters` walks whole grapheme clusters, so an emoji or an Arabic
    // letter yields exactly one glyph (and `toUpperCase` leaves both alone).
    return trimmed.characters.first.toUpperCase();
  }

  void _openCourseDetails(BuildContext context, EnrolledCourse course) {
    openCourseDetails(
      context,
      CourseDetails.fromCourse(
        colors: context.colors,
        image: _detailsCover(course.coverPath),
        title: course.title,
        instructor: course.instructor ?? '',
        isEnrolled: true,
        progress: course.progress,
        progressLabel: course.progressLabel,
        ctaLabel: HomeStrings.continueLessonCta,
      ),
    );
  }
}

/// Simple full-body loader using the app's own brand color.
class _HomeLoader extends StatelessWidget {
  const _HomeLoader();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: context.colors.primary),
    );
  }
}

/// Full-body error state.
///
/// An access failure (enrollment pending/rejected, student-only) can't be
/// fixed from the dashboard, so it offers the only useful way out — signing
/// out; any other failure offers a retry.
class _HomeFailure extends StatelessWidget {
  const _HomeFailure({required this.failure});

  final Failure failure;

  /// The backend codes that mean "this account may not see the dashboard".
  static const Set<String> _blockedCodes = {
    FailureCodes.enrollmentPending,
    FailureCodes.enrollmentRejected,
    FailureCodes.studentOnly,
  };

  @override
  Widget build(BuildContext context) {
    final blocked = _blockedCodes.contains(failure.errorCode);
    return _StatusView(
      icon: blocked ? Icons.lock_outline_rounded : Icons.cloud_off_rounded,
      message: failureMessage(failure),
      actionLabel: blocked ? AuthStrings.logout : HomeStrings.retry,
      actionIcon: blocked ? Icons.logout_rounded : Icons.refresh_rounded,
      onAction: blocked
          ? () => context.read<AuthCubit>().logout()
          : () => context.read<HomeCubit>().load(),
    );
  }
}

/// A centered message with one call to action, for the states that own the
/// whole body.
class _StatusView extends StatelessWidget {
  const _StatusView({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
  });

  final IconData icon;
  final String message;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(icon, size: 44.sp, color: context.colors.primary),
          VGap.md(),
          Text(message, textAlign: TextAlign.center, style: context.texts.body),
          VGap.xl(),
          AppPrimaryButton(
            label: actionLabel,
            icon: actionIcon,
            onPressed: onAction,
          ),
        ],
      ),
    );
  }
}

/// A localized short month name for `month` (1–12).
///
/// The API sends only the month *number* — plus an English `month_name` that is
/// never displayed — so the label is derived here, in the language in force.
/// The year is a fixed reference: a month's name does not depend on it.
String _monthLabel(BuildContext context, int month) {
  const referenceYear = 2026;
  return DateFormat.MMM(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(DateTime(referenceYear, month));
}

/// A localized short date+time for a parsed deadline.
String _formatDate(BuildContext context, DateTime value) =>
    DateFormat.yMd(Localizations.localeOf(context).toLanguageTag())
        .add_Hm()
        .format(value);

/// A localized, compact date+time for a chat message — the same treatment the
/// deadline line gets, in the short month form so it fits the end of a tile.
String _messageTime(BuildContext context, DateTime value) =>
    DateFormat.MMMd(Localizations.localeOf(context).toLanguageTag())
        .add_Hm()
        .format(value);

/// The cover handed to the (locked, asset-only) course details page: its own
/// bundled asset when the API sent an asset path, otherwise the asset that page
/// itself ships with, so an undocumented cover format can never break it.
String _detailsCover(String? coverPath) =>
    (coverPath != null && coverPath.startsWith('assets/'))
    ? coverPath
    : _detailsFallbackCover;

/// The bundled cover the course details page falls back to (the asset it ships
/// with), used when the home cover can't be handed over as-is.
const String _detailsFallbackCover = 'assets/courses/course_1.png';

class _SeeAllLink extends StatelessWidget {
  const _SeeAllLink({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxs),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(HomeStrings.seeAll, style: context.texts.linkAction),
    );
  }
}

/// "٢ بانتظارك" — how much is waiting in the upcoming section.
class _PendingBadge extends StatelessWidget {
  const _PendingBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return AppPill(
      color: context.colors.tintBlush,
      child: Text(
        label,
        style: context.texts.bodySmall.copyWith(
          fontWeight: FontWeight.w700,
          color: context.colors.error,
        ),
      ),
    );
  }
}
