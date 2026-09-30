abstract final class ExploreCoursesStrings {
  // Top bar
  static const screenTitle = 'استكشاف الدورات';

  // Search
  static const searchHint = 'ابحث عن دورة، محاضر، أو تصنيف...';

  // Section header
  static const sectionTitle = 'الدورات المتاحة';
  static const noCourses = 'لا توجد دورات';
  static const oneCourse = 'دورة واحدة';
  static const twoCourses = 'دورتان';
  static String countLabel(int count) => '$count دورات';

  // Course card
  // Note: the default enroll-button label lives on the Course model
  // itself (data layer), not here, since it's per-course content.
  static const totalPrice = 'السعر الكلي';

  // Empty state (overrides the generic core wording with course-specific copy)
  static const emptyTitle = 'لا توجد دورات مطابقة';
  static const emptyMessage = 'جرّب تعديل كلمة البحث أو اختيار تصنيف آخر.';

  // Promo banner
  static const promoEyebrow = 'عرض الأسبوع';
  static const promoTitle = 'خصم 30% على جميع\nالدورات التقنية';
  static const promoSubtitle =
      'ارتقِ بمهاراتك المهنية اليوم مع شهادات معتمدة وتطبيق عملي حقيقي.';
  static const promoCode = 'TECH30';
  static const promoCountdown = 'ينتهي خلال 48 ساعة';
  static const promoActivateCta = 'تفعيل الخصم';
}