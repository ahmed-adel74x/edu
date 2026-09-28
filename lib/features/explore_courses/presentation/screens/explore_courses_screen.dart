import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_edu/core/widgets/promo_banner.dart';
import 'package:test_edu/features/explore_courses/constants/explore_courses_strings.dart';

import '../../data/models/course.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/category_chip_row.dart';
import '../../../course_details/data/models/course_details.dart';
import '../../../course_details/presentation/course_details_route.dart';
import '../widgets/course_card.dart';
import '../widgets/course_card_skeleton.dart';
import '../../../../core/widgets/empty_state_view.dart';

class ExploreCoursesScreen extends StatefulWidget {
  const ExploreCoursesScreen({super.key});

  static Duration? get loadingDuration => null;

  @override
  State<ExploreCoursesScreen> createState() => _ExploreCoursesScreenState();
}

class _ExploreCoursesScreenState extends State<ExploreCoursesScreen> {
  static const String allCategory = 'الكل';

  static const List<String> categories = [
    allCategory,
    'إدارة أعمال',
    'لغات',
    'علوم وتكنولوجيا',
    'برمجة وتطوير',
  ];

  static const List<Course> courses = [
    Course(
      image: 'assets/courses/course_1.png',
      title: 'تجربة للدورات (المحاضرات)',
      instructor: 'أحمد سعيد',
      rating: '4.8',
      reviews: '120',
      duration: '30 ساعة',
      price: '100',
      badge: 'مسار تأسيسي',
      avatar: 'أ',
      category: 'إدارة أعمال',
    ),
    Course(
      image: 'assets/courses/course_2.jpeg',
      title: 'تطوير تطبيقات الموبايل',
      instructor: 'سارة علي',
      rating: '4.9',
      reviews: '86',
      duration: '36 ساعة',
      price: '500',
      badge: 'تطوير تطبيقات',
      avatar: 'س',
      category: 'برمجة وتطوير',
    ),
    Course(
      image: 'assets/courses/course_3.jpeg',
      title: 'هندسة البرمجيات والذكاء الاصطناعي',
      instructor: 'عمر خالد',
      rating: '5.0',
      reviews: '64',
      duration: '42 ساعة',
      price: '250',
      badge: 'الأكثر طلبًا',
      avatar: 'ع',
      category: 'علوم وتكنولوجيا',
    ),
    Course(
      image: 'assets/courses/course_4.jpeg',
      title: 'تجربة الشهادات المعتمدة',
      instructor: 'مشعل اعتماد',
      rating: '4.7',
      reviews: '52',
      duration: '24 ساعة',
      price: '400',
      badge: 'شهادة معتمدة',
      avatar: 'م',
      category: 'لغات',
      buttonLabel: 'سجل الآن',
    ),
  ];

  final TextEditingController searchController = TextEditingController();
  String query = '';
  String selectedCategory = allCategory;
  bool _loading = true;

  List<Course> get visibleCourses {
    final normalizedQuery = query.trim().toLowerCase();
    return courses.where((course) {
      final matchesCategory =
          selectedCategory == allCategory || course.category == selectedCategory;
      if (!matchesCategory) return false;
      if (normalizedQuery.isEmpty) return true;
      return course.title.toLowerCase().contains(normalizedQuery) ||
          course.instructor.toLowerCase().contains(normalizedQuery) ||
          course.badge.toLowerCase().contains(normalizedQuery) ||
          course.category.toLowerCase().contains(normalizedQuery);
    }).toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    // Brief simulated fetch so the skeleton loading state is demonstrated;
    // wire this to a real repository call when the backend is connected.
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  /// Opens the details page of the course the learner tapped, handing it that
  /// course's own copy (cover, title, instructor, rating, duration…).
  void _openCourseDetails(Course course) {
    openCourseDetails(
      context,
      CourseDetails.fromCourse(
        image: course.image,
        title: course.title,
        instructor: course.instructor,
        rating: course.rating,
        duration: course.duration,
        badge: course.badge,
        ctaLabel: course.buttonLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredCourses = visibleCourses;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: CustomScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const _TopBar(),
                        VGap.lg(),
                        AppSearchField(
                          controller: searchController,
                          hintText: ExploreCoursesStrings.searchHint,
                          onChanged: (value) => setState(() => query = value),
                          onFilterTap: () {},
                        ),
                        VGap.md(),
                        CategoryChipRow(
                          categories: categories,
                          selected: selectedCategory,
                          onSelected: (category) =>
                              setState(() => selectedCategory = category),
                        ),
                        VGap.lg(),
                        const PromoBanner(
                          eyebrow: ExploreCoursesStrings.promoEyebrow,
                          title: ExploreCoursesStrings.promoTitle,
                          subtitle: ExploreCoursesStrings.promoSubtitle,
                          code: ExploreCoursesStrings.promoCode,
                          countdown: ExploreCoursesStrings.promoCountdown,
                          ctaLabel: ExploreCoursesStrings.promoActivateCta,
                        ),
                        VGap.xl(),
                        _SectionHeader(
                          courseCount: filteredCourses.length,
                          loading: _loading,
                        ),
                        VGap.sm(),
                      ]),
                    ),
                  ),
                  if (_loading)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: EdgeInsets.only(bottom: AppSpacing.md),
                            child: const CourseCardSkeleton(),
                          ),
                          childCount: 3,
                        ),
                      ),
                    )
                  else if (filteredCourses.isEmpty)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      sliver: const SliverToBoxAdapter(
                        child: EmptyStateView(
                          title: ExploreCoursesStrings.emptyTitle,
                          message: ExploreCoursesStrings.emptyMessage,
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final course = filteredCourses[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index == filteredCourses.length - 1
                                    ? AppSpacing.xl
                                    : AppSpacing.md,
                              ),
                              child: CourseCard(
                                course: course,
                                onTap: () => _openCourseDetails(course),
                              ),
                            );
                          },
                          childCount: filteredCourses.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        // The bottom navigation bar lives in the shared shell
        // (`core/navigation/main_shell.dart`) so the home and explore screens
        // show the exact same bar.
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.courseCount, required this.loading});

  final int courseCount;
  final bool loading;

  String get _countLabel {
    switch (courseCount) {
      case 0:
        return ExploreCoursesStrings.noCourses;
      case 1:
        return ExploreCoursesStrings.oneCourse;
      case 2:
        return ExploreCoursesStrings.twoCourses;
      default:
        return ExploreCoursesStrings.countLabel(courseCount);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4.w,
              height: 22.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            HGap.xs(),
            Text(ExploreCoursesStrings.sectionTitle, style: AppTextStyles.sectionTitle),
          ],
        ),
        if (!loading)
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceTint,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(_countLabel, style: AppTextStyles.bodySmall),
          ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: AppColors.surfaceTint,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(Icons.school_rounded, color: AppColors.primary, size: 20.sp),
        ),
        HGap.sm(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.appName, style: AppTextStyles.label),
            Text(ExploreCoursesStrings.screenTitle, style: AppTextStyles.cardTitle),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          tooltip: AppStrings.notifications,
          icon: Icon(Icons.notifications_none_rounded, size: 20.sp),
        ),
      ],
    );
  }
}