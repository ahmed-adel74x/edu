import 'package:flutter/material.dart';

import '../../../core/theme/app_colors_extension.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_type_scale.dart';
import '../../../shared/widgets/app_pill.dart';
import '../constants/home_strings.dart';
import '../data/models/enrolled_course.dart';
import '../data/models/home_stat.dart';
import '../data/models/home_task.dart';
import '../data/models/weekly_activity.dart';
import '../../course_details/data/models/course_details.dart';
import '../../course_details/course_details_route.dart';
import 'widgets/compact_course_tile.dart';
import 'widgets/continue_course_card.dart';
import 'widgets/home_section_header.dart';
import 'widgets/stat_tile_grid.dart';
import 'widgets/upcoming_task_card.dart';
import 'widgets/weekly_activity_card.dart';
import 'widgets/welcome_hero_card.dart';

/// Learner dashboard: greeting, progress summary, the courses to pick up
/// again, what is due next and this week's activity.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onSeeAllCourses});

  /// Invoked by the "browse new" / "see all" actions. The shell wires it to
  /// the explore tab, so the dashboard can hand the learner over to it.
  final VoidCallback? onSeeAllCourses;

  // Sample content — wire these to a repository call when the backend is
  // connected, exactly like the explore screen keeps its course list.
  static List<HomeStat> stats(AppColorsExtension colors) => [
    HomeStat(
      label: 'الدورات المسجلة',
      value: '٣',
      unit: 'دورات',
      icon: Icons.menu_book_rounded,
      iconColor: colors.primary,
      iconBackground: colors.tintLavender,
    ),
    HomeStat(
      label: 'ساعات الدراسة',
      value: '١٢',
      unit: 'ساعة',
      icon: Icons.schedule_rounded,
      iconColor: colors.warningDeep,
      iconBackground: colors.tintPeach,
    ),
    HomeStat(
      label: 'الدورات المكتملة',
      value: '٧',
      unit: 'دورة',
      icon: Icons.check_circle_rounded,
      iconColor: colors.accent,
      iconBackground: colors.tintMint,
    ),
    HomeStat(
      label: 'الشهادات المكتسبة',
      value: '١',
      unit: 'شهادة',
      icon: Icons.workspace_premium_rounded,
      iconColor: colors.primary,
      iconBackground: colors.tintLavender,
    ),
  ];

  static const EnrolledCourse featuredCourse = EnrolledCourse(
    image: 'assets/courses/course_5.jpeg',
    title: 'تجربة للدورات (المحاضرات)',
    instructor: 'أحمد سعيد - Ahmed Teacher3',
    progress: 0.65,
    progressLabel: '٪65',
    remainingLessons: '٥ دروس متبقية لإنهاء المادة',
  );

  static const EnrolledCourse nextCourse = EnrolledCourse(
    image: 'assets/courses/course_2.jpeg',
    title: 'أساسيات وتطوير الويب',
    instructor: 'المدرب: janaaaa',
    progress: 0.30,
    progressLabel: '٪30',
  );

  static List<HomeTask> tasks(AppColorsExtension colors) => [
    HomeTask(
      icon: Icons.fact_check_rounded,
      iconColor: colors.error,
      iconBackground: colors.tintBlush,
      title: 'اختبار دورة جديدة',
      meta: 'تاريخ التسليم: غدًا، ٠٩:٠٠ م',
      progressBadge: '٪43',
      countdown: 'متبقي ٢٤ ساعة فقط',
      actionLabel: 'التفاصيل',
    ),
    HomeTask(
      icon: Icons.edit_note_rounded,
      iconColor: colors.accent,
      iconBackground: colors.tintMint,
      title: 'واجب المحاضرة ٣',
      statusNote: 'قيد التسليم للمراجعة',
      actionLabel: 'عرض',
    ),
  ];

  static const List<WeeklyActivityDay> week = [
    WeeklyActivityDay(label: 'السبت', ratio: 0.35),
    WeeklyActivityDay(label: 'الأحد', ratio: 0.72, isActive: true),
    WeeklyActivityDay(label: 'الاثنين', ratio: 0.20),
    WeeklyActivityDay(label: 'الثلاثاء', ratio: 0.50, isActive: true),
    WeeklyActivityDay(label: 'اليوم', ratio: 1, isActive: true, isToday: true),
    WeeklyActivityDay(label: 'الخميس', ratio: 0.18),
    WeeklyActivityDay(label: 'الجمعة', ratio: 0.42),
  ];

  /// Opens the details page of a course card the learner tapped, passing the
  /// course's own copy plus its saved progress.
  void _openCourseDetails(BuildContext context, EnrolledCourse course) {
    openCourseDetails(
      context,
      CourseDetails.fromCourse(
        colors: context.colors,
        image: course.image,
        title: course.title,
        instructor: course.instructor,
        isEnrolled: true,
        progress: course.progress,
        progressLabel: course.progressLabel,
        ctaLabel: HomeStrings.continueLessonCta,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                // The course cards open the course details page; the actions
                // that still lead nowhere are wired to no-ops, exactly like
                // the explore screen does.
                WelcomeHeroCard(
                  onBrowseNew: onSeeAllCourses,
                  onCurriculumTap: onSeeAllCourses,
                ),
                VGap.md(),
                StatTileGrid(stats: stats(context.colors)),
                VGap.xl(),
                HomeSectionHeader(
                  title: HomeStrings.continueLearningTitle,
                  trailing: _SeeAllLink(onTap: onSeeAllCourses),
                ),
                VGap.md(),
                ContinueCourseCard(
                  course: featuredCourse,
                  onContinue: () {},
                  onTap: () => _openCourseDetails(context, featuredCourse),
                ),
                VGap.md(),
                CompactCourseTile(
                  course: nextCourse,
                  onTap: () => _openCourseDetails(context, nextCourse),
                ),
                VGap.xl(),
                HomeSectionHeader(
                  title: HomeStrings.upcomingTitle,
                  icon: Icons.assignment_turned_in_rounded,
                  iconColor: context.colors.warningDeep,
                  trailing: const _PendingBadge(),
                ),
                VGap.md(),
                for (final task in tasks(context.colors)) ...[
                  UpcomingTaskCard(task: task, onAction: () {}),
                  VGap.md(),
                ],
                VGap.sm(),
                const WeeklyActivityCard(days: week),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
  const _PendingBadge();

  @override
  Widget build(BuildContext context) {
    return AppPill(
      color: context.colors.tintBlush,
      child: Text(
        HomeStrings.upcomingBadge,
        style: context.texts.bodySmall.copyWith(
          fontWeight: FontWeight.w700,
          color: context.colors.error,
        ),
      ),
    );
  }
}
