import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Centralized type scale. Sizes are resolved through ScreenUtil (`.sp`)
/// so text scales with screen size; these are getters, not consts.
abstract final class AppTextStyles {
  static TextStyle _base({
    required double size,
    required FontWeight weight,
    Color color = AppColors.ink,
    double? height,
    Color? decorationColor,
  }) {
    return GoogleFonts.tajawal(
      fontSize: size.sp,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }

  /// Big promo / hero numbers.
  static TextStyle get display =>
      _base(size: 26, weight: FontWeight.w800, height: 1.25);

  /// Section titles ("الدورات المتاحة").
  static TextStyle get sectionTitle =>
      _base(size: 18, weight: FontWeight.w700, height: 1.3);

  /// Card / list item titles.
  static TextStyle get cardTitle =>
      _base(size: 15.5, weight: FontWeight.w700, height: 1.35);

  /// Regular paragraph copy.
  static TextStyle get body =>
      _base(size: 13, weight: FontWeight.w500, color: AppColors.inkMuted, height: 1.5);

  /// Smaller supporting copy.
  static TextStyle get bodySmall =>
      _base(size: 11.5, weight: FontWeight.w500, color: AppColors.inkMuted, height: 1.4);

  /// Tiny uppercase-ish labels / eyebrow text.
  static TextStyle get label =>
      _base(size: 11, weight: FontWeight.w700, color: AppColors.inkFaint, height: 1.2);

  /// Button copy.
  static TextStyle get button =>
      _base(size: 13.5, weight: FontWeight.w700, color: AppColors.onPrimary);

  /// Price / emphasis numerals.
  static TextStyle get priceLarge =>
      _base(size: 20, weight: FontWeight.w800, color: AppColors.primary);

  // ---------------------------------------------------------------------------
  // Dashboard scale (home screen)
  // ---------------------------------------------------------------------------

  /// Big numeric readout on a stat tile ("١٢").
  static TextStyle get statValue =>
      _base(size: 26, weight: FontWeight.w800, height: 1.15);

  /// Caption of a stat tile ("ساعات الدراسة").
  static TextStyle get statLabel =>
      _base(size: 13, weight: FontWeight.w600, height: 1.35);

  /// Unit following a stat value ("ساعة", "دورات").
  static TextStyle get statUnit => _base(
        size: 12,
        weight: FontWeight.w600,
        color: AppColors.inkMuted,
        height: 1.2,
      );

  /// Inline text action ("عرض الكل").
  static TextStyle get linkAction => _base(
        size: 13,
        weight: FontWeight.w700,
        color: AppColors.primary,
        height: 1.2,
      );

  /// Caption for progress readouts ("نسبة الإنجاز").
  static TextStyle get metricLabel => _base(
        size: 11.5,
        weight: FontWeight.w600,
        color: AppColors.inkMuted,
        height: 1.3,
      );

  /// Axis labels under charts (weekday names).
  static TextStyle get axisLabel => _base(
        size: 10.5,
        weight: FontWeight.w600,
        color: AppColors.inkMuted,
        height: 1.2,
      );
}