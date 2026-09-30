/// Copy for the assignments screen. Per-item content (assignment titles,
/// deadlines, instructor notes…) lives on the sample data in the screen,
/// exactly like the home and explore screens keep their content next to the
/// screen.
abstract final class AssignmentsStrings {
  // Top bar
  static const screenTitle = 'الواجبات والتكليفات';

  // Progress hero
  static const levelBadge = 'مستوى التميز';
  static const streakBadge = '٣ أيام متتالية 🔥';
  static const heroTitle = 'واجباتك الملحّة تنتظرك يا بطل!';
  static const heroSubtitle =
      'أنجز مهامك الدراسية في موعدها لتحصد نقاط خبرة، وأصبح الأفضل في لوحة الصدارة.';
  static const pointsTooltip = 'نقاط الخبرة';

  // Search + status filters
  static const searchHint = 'ابحث باسم واجب أو المحاضرة...';
  static const filterAll = 'الكل';
  static const filterPending = 'قيد الانتظار';
  static const filterSubmitted = 'تم التسليم';
  static const filterGraded = 'تم التقييم';

  // Assignment card: status pill
  static const pendingBadge = 'قيد الانتظار';
  static const underReviewBadge = 'قيد المراجعة';
  static const gradedBadge = 'تم التقييم';

  // Assignment card: instructor feedback
  static const instructorNotesPrefix = 'ملاحظات';

  // Assignment card: actions
  static const submitCta = 'رفع الواجب';
  static const briefCta = 'تحميل الشرح';
  static const viewSubmissionCta = 'عرض ملف الإجابة والشهادة';
  static const previewCta = 'معاينة المرفق';
  static const resendCta = 'إعادة الإرسال';

  // Filtered-to-nothing fallback
  static const emptyTitle = 'لا توجد واجبات مطابقة';
  static const emptyMessage = 'جرّب تعديل كلمة البحث أو حالة الواجب.';
}
