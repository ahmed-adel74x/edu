import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../constants/assignments_strings.dart';
import '../../data/models/assignment.dart';
import '../../data/models/assignment_filter.dart';
import '../../data/models/assignment_status.dart';
import '../../data/models/assignment_summary.dart';
import '../widgets/assignment_card.dart';
import '../widgets/assignment_filter_bar.dart';
import '../widgets/assignments_progress_hero.dart';

/// Assignments & tasks tab: the learner's progress summary, the search and
/// status filters, and the assignment cards that are still pending, already
/// submitted or graded.
class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  /// Sample content — wire these to a repository call when the backend is
  /// connected, exactly like the explore screen keeps its course list.
  static const List<AssignmentSummary> summary = [
    AssignmentSummary(label: 'المتبقية', value: '٢', unit: 'مهام'),
    AssignmentSummary(label: 'تم تسليمها', value: '٥', unit: 'مكتملة'),
    AssignmentSummary(label: 'معدل التقييم', value: '٪96'),
  ];

  static const List<Assignment> assignments = [
    Assignment(
      icon: Icons.assignment_rounded,
      iconColor: AppColors.primary,
      iconBackground: AppColors.surfaceTint,
      course: 'برمجة الويب المقدمة',
      title: 'تطبيقات الواجهة الأولى',
      excerpt: 'تصميم نموذج تسجيل تفاعلي مع التحقق من المدخلات…',
      status: AssignmentStatus.pending,
      dueLabel: 'موعد التسليم: 2026-06-10',
      isDueSoon: true,
      fileLabel: 'ملف التكليف (2.4 MB) · PDF',
    ),
    Assignment(
      icon: Icons.verified_rounded,
      iconColor: AppColors.accent,
      iconBackground: AppColors.tintMint,
      course: 'هياكل البيانات والخوارزميات',
      title: 'متقدم Binary Search',
      excerpt: 'تنفيذ خوارزمية البحث الثنائي وتحليل تعقيدها الزمني…',
      status: AssignmentStatus.graded,
      gradeLabel: 'تم التقييم: ٩٨/١٠٠',
      submittedLabel: 'تم التسليم في: 2026-05-02',
      instructorName: 'د. إبراهيم',
      instructorInitials: 'إ',
      instructorNote:
          'تقييم ممتاز وتطبيق واضح جدًا لتنظيم الجدول والخيارات، والحالات '
          'المشابهة كانت احترافية ومطابقة للأصل.',
    ),
    Assignment(
      icon: Icons.edit_rounded,
      iconColor: AppColors.primary,
      iconBackground: AppColors.surfaceTint,
      course: 'تصميم واجهات المستخدم UI/UX',
      title: 'تصميم شاشات تطبيق دراسي',
      excerpt: 'بناء الـ Wireframes وتجهيز نماذج التفاعل…',
      status: AssignmentStatus.submitted,
      submittedLabel: 'تم تسليم الملف: UI_CaseStudy_Final.fig',
      submittedAtLabel: 'أمس، 08:30 م',
    ),
    Assignment(
      icon: Icons.insights_rounded,
      iconColor: AppColors.accent,
      iconBackground: AppColors.tintMint,
      course: 'أساسيات وتطوير الويب',
      title: 'تحليل بيانات المتجر الإلكتروني',
      excerpt: 'تحليل نتائج الحملة وإعداد تقرير مرئي مختصر…',
      status: AssignmentStatus.graded,
      gradeLabel: 'تم التقييم: ٩٢/١٠٠',
      submittedLabel: 'تم التسليم في: 2026-05-28',
      instructorName: 'د. منى',
      instructorInitials: 'م',
      instructorNote:
          'تقرير منظم ومختصر، مع ربط واضح بين الأرقام والنتائج والتوصيات.',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  AssignmentStatus? _status;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filter-bar entries built from the sample list, so the counts on the chips
  /// can never drift from the cards underneath them.
  List<AssignmentFilter> get _filters {
    int countOf(AssignmentStatus status) =>
        assignments.where((item) => item.status == status).length;

    return [
      AssignmentFilter(
        label: AssignmentsStrings.filterAll,
        status: null,
        count: assignments.length,
      ),
      AssignmentFilter(
        label: AssignmentsStrings.filterPending,
        status: AssignmentStatus.pending,
        count: countOf(AssignmentStatus.pending),
      ),
      AssignmentFilter(
        label: AssignmentsStrings.filterSubmitted,
        status: AssignmentStatus.submitted,
        count: countOf(AssignmentStatus.submitted),
      ),
      // The graded chip carries no count, like the design.
      const AssignmentFilter(
        label: AssignmentsStrings.filterGraded,
        status: AssignmentStatus.graded,
      ),
    ];
  }

  List<Assignment> get _visibleAssignments {
    final query = _query.trim().toLowerCase();
    return assignments.where((item) {
      if (_status != null && item.status != _status) return false;
      if (query.isEmpty) return true;
      return item.title.toLowerCase().contains(query) ||
          item.course.toLowerCase().contains(query) ||
          item.excerpt.toLowerCase().contains(query);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleAssignments;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
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
                  const _TopBar(),
                  VGap.md(),
                  const AssignmentsProgressHero(
                    summary: summary,
                    onPointsTap: _noop,
                  ),
                  VGap.md(),
                  AppSearchField(
                    controller: _searchController,
                    hintText: AssignmentsStrings.searchHint,
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  VGap.md(),
                  AssignmentFilterBar(
                    filters: _filters,
                    selected: _status,
                    onSelected: (status) => setState(() => _status = status),
                  ),
                  VGap.md(),
                  if (visible.isEmpty)
                    const EmptyStateView(
                      icon: Icons.assignment_rounded,
                      title: AssignmentsStrings.emptyTitle,
                      message: AssignmentsStrings.emptyMessage,
                    )
                  else
                    for (final assignment in visible) ...[
                      AssignmentCard(
                        assignment: assignment,
                        onSubmit: _noop,
                        onDownloadBrief: _noop,
                        onViewSubmission: _noop,
                        onPreviewAttachment: _noop,
                        onResend: _noop,
                      ),
                      VGap.md(),
                    ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Actions that don't lead anywhere yet — wired to a no-op exactly like the
  /// home and explore screens wire theirs.
  static void _noop() {}
}

/// Page header: the academy name above the screen title, the notifications
/// bell and the learner's avatar — laid out right-to-left like the rest of
/// the app's headers.
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                AppStrings.appName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.label,
              ),
              Text(
                AssignmentsStrings.screenTitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.cardTitle,
              ),
            ],
          ),
        ),
        HGap.sm(),
        const _NotificationBell(),
        HGap.sm(),
        const _ProfileAvatar(),
      ],
    );
  }
}

/// Bell action with a small unread dot on its corner.
class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: () {},
          tooltip: AppStrings.notifications,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.ink,
            fixedSize: Size(44.w, 44.w),
            shape: const CircleBorder(),
            side: const BorderSide(color: AppColors.border),
          ),
          icon: Icon(Icons.notifications_none_rounded, size: 20.sp),
        ),
        Positioned(
          top: 6.h,
          right: 8.w,
          child: Container(
            width: 9.w,
            height: 9.w,
            decoration: BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(Icons.person_rounded, size: 22.sp, color: AppColors.inkFaint),
    );
  }
}