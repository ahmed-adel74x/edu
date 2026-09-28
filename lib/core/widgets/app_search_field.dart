import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.hintText,
    this.onFilterTap,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;
  final String hintText;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: widget.onFilterTap,
          tooltip: AppStrings.filterResults,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surfaceTint,
            fixedSize: Size(46.w, 46.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          icon: Icon(Icons.tune_rounded, color: AppColors.primary, size: 20.sp),
        ),
        HGap.sm(),
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: _focused ? AppColors.primary : Colors.transparent,
                width: 1.4,
              ),
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              textAlign: TextAlign.right,
              textInputAction: TextInputAction.search,
              onChanged: widget.onChanged,
              onSubmitted: widget.onChanged,
              style: AppTextStyles.body.copyWith(color: AppColors.ink),
              decoration: InputDecoration(
                hintText: widget.hintText,
                suffixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
