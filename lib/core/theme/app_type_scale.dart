import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors_extension.dart';

/// The app's type scale, resolved against the palette of the theme in force.
///
/// Sizes come from ScreenUtil (`.sp`) so text scales with the screen, colors
/// from [AppColorsExtension]. It is an instance built from a palette rather
/// than a set of static getters, because a style has to be painted with the
/// colors of the theme it ends up in — a style with a baked-in color cannot
/// follow a dark theme. Reach for it as `context.texts.body`.
class AppTypeScale {
  const AppTypeScale(this.colors);

  /// The scale for the theme currently in [context].
  static AppTypeScale of(BuildContext context) => AppTypeScale(context.colors);

  /// The palette this scale paints with.
  final AppColorsExtension colors;

  TextStyle _base({
    required double size,
    required FontWeight weight,
    required Color color,
    double? height,
  }) {
    return GoogleFonts.tajawal(
      fontSize: size.sp,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }

  /// Big promo / hero numbers.
  TextStyle get display =>
      _base(size: 26, weight: FontWeight.w800, color: colors.ink, height: 1.25);

  /// Section titles ("الدورات المتاحة").
  TextStyle get sectionTitle =>
      _base(size: 18, weight: FontWeight.w700, color: colors.ink, height: 1.3);

  /// Card / list item titles.
  TextStyle get cardTitle => _base(
    size: 15.5,
    weight: FontWeight.w700,
    color: colors.ink,
    height: 1.35,
  );

  /// Regular paragraph copy.
  TextStyle get body => _base(
    size: 13,
    weight: FontWeight.w500,
    color: colors.inkMuted,
    height: 1.5,
  );

  /// Smaller supporting copy.
  TextStyle get bodySmall => _base(
    size: 11.5,
    weight: FontWeight.w500,
    color: colors.inkMuted,
    height: 1.4,
  );

  /// Tiny uppercase-ish labels / eyebrow text.
  TextStyle get label => _base(
    size: 11,
    weight: FontWeight.w700,
    color: colors.inkFaint,
    height: 1.2,
  );

  /// Button copy.
  TextStyle get button =>
      _base(size: 13.5, weight: FontWeight.w700, color: colors.onPrimary);

  /// Price / emphasis numerals.
  TextStyle get priceLarge =>
      _base(size: 20, weight: FontWeight.w800, color: colors.primary);

  // ---------------------------------------------------------------------------
  // Dashboard scale (home screen)
  // ---------------------------------------------------------------------------

  /// Big numeric readout on a stat tile ("١٢").
  TextStyle get statValue =>
      _base(size: 26, weight: FontWeight.w800, color: colors.ink, height: 1.15);

  /// Caption of a stat tile ("ساعات الدراسة").
  TextStyle get statLabel =>
      _base(size: 13, weight: FontWeight.w600, color: colors.ink, height: 1.35);

  /// Unit following a stat value ("ساعة", "دورات").
  TextStyle get statUnit => _base(
    size: 12,
    weight: FontWeight.w600,
    color: colors.inkMuted,
    height: 1.2,
  );

  /// Inline text action ("عرض الكل").
  TextStyle get linkAction => _base(
    size: 13,
    weight: FontWeight.w700,
    color: colors.primary,
    height: 1.2,
  );

  /// Caption for progress readouts ("نسبة الإنجاز").
  TextStyle get metricLabel => _base(
    size: 11.5,
    weight: FontWeight.w600,
    color: colors.inkMuted,
    height: 1.3,
  );

  /// Axis labels under charts (weekday names).
  TextStyle get axisLabel => _base(
    size: 10.5,
    weight: FontWeight.w600,
    color: colors.inkMuted,
    height: 1.2,
  );
}

/// `context.texts.cardTitle` — the type scale of the theme in force.
extension AppTypeScaleContext on BuildContext {
  AppTypeScale get texts => AppTypeScale.of(this);
}
