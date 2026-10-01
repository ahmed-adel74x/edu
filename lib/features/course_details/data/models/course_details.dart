import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors_extension.dart';

/// What a lesson row is currently showing in the curriculum list.
enum LessonStatus {
  /// Watched/listened to already — gets a mint check tile.
  completed,

  /// The lesson the learner is inside right now — highlighted row.
  playing,

  /// Not unlocked yet — renders a lock tile and a muted title.
  locked,

  /// Available but untouched.
  available,
}

/// The kind of content a lesson holds; drives the leading icon and the
/// trailing affordance (play button vs. quiz tile).
enum LessonKind { video, quiz, reading }

/// One row of the curriculum list.
class CourseLesson {
  const CourseLesson({
    required this.title,
    required this.meta,
    this.status = LessonStatus.available,
    this.kind = LessonKind.video,
  });

  final String title;

  /// Pre-formatted line under the title, e.g. '10 دقائق • فيديو تعليمي'.
  final String meta;

  final LessonStatus status;
  final LessonKind kind;

  bool get isLocked => status == LessonStatus.locked;
}

/// A collapsible unit of the curriculum (الوحدة 1، الوحدة 2…).
class CourseUnit {
  const CourseUnit({
    required this.order,
    required this.title,
    required this.meta,
    required this.lessons,
    this.initiallyExpanded = false,
  });

  /// 1-based index shown in the round badge.
  final int order;

  final String title;

  /// e.g. '3 دروس • 45 دقيقة'.
  final String meta;

  final List<CourseLesson> lessons;

  final bool initiallyExpanded;
}

/// The instructor block ("مرشدك المبدع").
class CourseInstructor {
  const CourseInstructor({
    required this.name,
    required this.headline,
    required this.bio,
    required this.students,
    required this.rating,
    required this.initials,
  });

  final String name;

  /// Short tagline next to the name, e.g. 'صديق الطلاب المفضل'.
  final String headline;

  final String bio;

  /// Pre-formatted learner count, e.g. '50k+'.
  final String students;

  /// Pre-formatted rating, e.g. '4.9'.
  final String rating;

  /// Fallback avatar content when there is no photo asset.
  final String initials;
}

/// One tile of the course summary grid (lessons, duration, level, certificate).
class CourseDetailStat {
  const CourseDetailStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  /// Copy of the tile with the display [value] swapped — used when a real
  /// per-course figure (a duration, a lesson count) replaces the placeholder.
  CourseDetailStat withValue(String value) => CourseDetailStat(
    label: label,
    value: value,
    icon: icon,
    iconColor: iconColor,
    iconBackground: iconBackground,
  );
}

/// Everything the course details page needs to render.
class CourseDetails {
  const CourseDetails({
    required this.image,
    required this.title,
    required this.description,
    required this.coverBadge,
    required this.rating,
    required this.stats,
    required this.instructor,
    required this.units,
    required this.curriculumMeta,
    required this.isEnrolled,
    required this.progress,
    required this.progressLabel,
    this.nextLessonLabel,
  });

  final String image;
  final String title;
  final String description;

  /// Pill on the cover, e.g. 'المنهاج الدراسي - معتمد'.
  final String coverBadge;

  /// Pre-formatted rating shown on the cover, e.g. '4.9'.
  final String rating;

  final List<CourseDetailStat> stats;
  final CourseInstructor instructor;
  final List<CourseUnit> units;

  /// e.g. '3 وحدات • 15 درس'.
  final String curriculumMeta;

  final bool isEnrolled;

  /// Completion in the 0..1 range.
  final double progress;
  final String progressLabel;

  /// Bottom CTA label, e.g. 'متابعة الدورة (الدرس 2)'.
  final String? nextLessonLabel;

  /// Builds the details page of a course picked from a list (home, explore…).
  ///
  /// Everything those models already carry — cover, title, instructor, rating,
  /// duration, badge, progress — comes from the tapped course; the curriculum,
  /// the bio and the remaining summary tiles fall back to the shared
  /// [CourseDetailsDefaults] until per-course content is served by a backend.
  ///
  /// [colors] is the palette of the theme in force: the placeholder summary
  /// tiles are painted with it, so the page has no light-only color left when
  /// the dark theme is on.
  factory CourseDetails.fromCourse({
    required AppColorsExtension colors,
    required String image,
    required String title,
    required String instructor,
    String? rating,
    String? duration,
    String? badge,
    String? ctaLabel,
    bool isEnrolled = false,
    double progress = 0,
    String? progressLabel,
  }) {
    final completion = progress.clamp(0.0, 1.0);
    final courseRating = rating ?? CourseDetailsDefaults.rating;
    final durationStat = CourseDetailsDefaults.durationStat(colors);

    return CourseDetails(
      image: image,
      title: title,
      description: CourseDetailsDefaults.description,
      coverBadge: badge ?? CourseDetailsDefaults.coverBadge,
      rating: courseRating,
      stats: [
        CourseDetailsDefaults.lessonsStat(colors),
        duration == null ? durationStat : durationStat.withValue(duration),
        CourseDetailsDefaults.levelStat(colors),
        CourseDetailsDefaults.certificateStat(colors),
      ],
      instructor: CourseInstructor(
        name: instructor,
        headline: CourseDetailsDefaults.instructorHeadline,
        bio: CourseDetailsDefaults.instructorBio,
        students: CourseDetailsDefaults.instructorStudents,
        rating: courseRating,
        initials: _initialOf(instructor),
      ),
      units: CourseDetailsDefaults.units,
      curriculumMeta: CourseDetailsDefaults.curriculumMeta,
      isEnrolled: isEnrolled,
      progress: completion,
      progressLabel: progressLabel ?? '${(completion * 100).round()}%',
      nextLessonLabel: ctaLabel,
    );
  }

  static String _initialOf(String name) {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '؟' : trimmed.substring(0, 1);
  }
}

/// Placeholder content for everything the list models don't carry yet — the
/// curriculum, the instructor bio, the cover badge and the summary tiles that
/// have no data behind them. Kept in one place so real repository data can
/// replace it in a single edit.
///
/// The summary tiles are functions of the palette rather than constants: their
/// icon tints belong to the theme in force, so the page can't keep a light-only
/// color in the dark theme.
abstract final class CourseDetailsDefaults {
  static const rating = '4.9';
  static const coverBadge = 'المنهاج الدراسي - معتمد';
  static const curriculumMeta = '3 وحدات • 15 درس';
  static const description =
      'رحلة تطبيقية مكثفة تبدأ معك خطوة بخطوة من تهيئة بيئة العمل وحتى إتقان '
      'المهارات المتقدمة ونشر التطبيقات الجاهزة.';
  static const instructorHeadline = 'صديق الطلاب المفضل';
  static const instructorBio =
      'شغوف بتبسيط العلوم البرمجية وتطوير التطبيقات، بخبرة تزيد عن 8 سنوات '
      'في التعليم التفاعلي.';
  static const instructorStudents = '50k+';

  static CourseDetailStat lessonsStat(AppColorsExtension colors) =>
      CourseDetailStat(
        label: 'عدد الدروس',
        value: '15 درس',
        icon: Icons.smart_display_rounded,
        iconColor: colors.accent,
        iconBackground: colors.tintMint,
      );

  static CourseDetailStat durationStat(AppColorsExtension colors) =>
      CourseDetailStat(
        label: 'مدة الدورة',
        value: '30 ساعة',
        icon: Icons.schedule_rounded,
        iconColor: colors.primary,
        iconBackground: colors.tintLavender,
      );

  static CourseDetailStat levelStat(AppColorsExtension colors) =>
      CourseDetailStat(
        label: 'المستوى',
        value: 'متوسط',
        icon: Icons.trending_up_rounded,
        iconColor: colors.primary,
        iconBackground: colors.tintLavender,
      );

  static CourseDetailStat certificateStat(AppColorsExtension colors) =>
      CourseDetailStat(
        label: 'الاعتماد',
        value: 'شهاده إنعام',
        icon: Icons.workspace_premium_rounded,
        iconColor: colors.warningDeep,
        iconBackground: colors.tintPeach,
      );

  static const units = <CourseUnit>[
    CourseUnit(
      order: 1,
      title: 'الوحدة 1: تجربة للدورات وتجهيز البيئة',
      meta: '3 دروس • 45 دقيقة',
      initiallyExpanded: true,
      lessons: [
        CourseLesson(
          title: 'مقدمة عن الدورة وأهداف التعلم',
          meta: '10 دقائق • فيديو تعليمي',
          status: LessonStatus.completed,
        ),
        CourseLesson(
          title: 'تجربة للدورات (المحاضرات)',
          meta: '15 دقيقة • جاري الاستماع',
          status: LessonStatus.playing,
        ),
        CourseLesson(
          title: 'تطبيق عملي واختبار تجريبي',
          meta: '20 دقيقة • تقييم قصير',
          status: LessonStatus.locked,
          kind: LessonKind.quiz,
        ),
      ],
    ),
    CourseUnit(
      order: 2,
      title: 'الوحدة 2: المفاهيم المتقدمة وبناء المشروع',
      meta: '4 دروس • ساعتان',
      lessons: [
        CourseLesson(
          title: 'المفاهيم المتقدمة في البرمجة الكائنية',
          meta: '25 دقيقة • فيديو تعليمي',
        ),
        CourseLesson(
          title: 'إدارة الحالة وربط الواجهات بالبيانات',
          meta: '30 دقيقة • فيديو تعليمي',
        ),
        CourseLesson(
          title: 'نشر التطبيق على المتاجر',
          meta: '20 دقيقة • فيديو تعليمي',
        ),
        CourseLesson(
          title: 'ورشة عملية: بناء المشروع الأول',
          meta: '45 دقيقة • مشروع عملي',
          kind: LessonKind.quiz,
        ),
      ],
    ),
    CourseUnit(
      order: 3,
      title: 'الوحدة 3: الاختبار النهائي واستلام الشهادة',
      meta: 'مشروع متكامل • شهادة إتمام',
      lessons: [
        CourseLesson(
          title: 'الاختبار النهائي الشامل',
          meta: '30 دقيقة • تقييم نهائي',
          status: LessonStatus.locked,
          kind: LessonKind.quiz,
        ),
        CourseLesson(
          title: 'تسليم المشروع المتكامل',
          meta: 'مشروع عملي • مراجعة المبدع',
          status: LessonStatus.locked,
        ),
        CourseLesson(
          title: 'استلام الشهادة وتوثيق الإنجاز',
          meta: '10 دقائق • شهادة إتمام',
          status: LessonStatus.locked,
          kind: LessonKind.reading,
        ),
      ],
    ),
  ];
}
