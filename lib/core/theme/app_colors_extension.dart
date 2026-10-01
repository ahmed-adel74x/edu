import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Every semantic color the app paints with, resolved per theme.
///
/// Screens read it from the theme (`context.colors`) instead of reaching for a
/// constant, so one build of a widget looks right in both themes. [light] holds
/// exactly the values the app shipped with — still declared in [AppColors] so
/// the two can't drift — and [dark] is its counterpart on dark surfaces.
///
/// Gradients are not stored: each one is built from the flat colors above so a
/// theme only has to define its own palette.
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.primary,
    required this.primaryDark,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceTint,
    required this.ink,
    required this.inkMuted,
    required this.inkFaint,
    required this.onPrimary,
    required this.border,
    required this.borderStrong,
    required this.success,
    required this.warning,
    required this.warningDeep,
    required this.error,
    required this.star,
    required this.scrim,
    required this.shadow,
    required this.tintLavender,
    required this.tintPeach,
    required this.tintMint,
    required this.tintBlush,
    required this.uploadAccent,
    required this.heroGradientStart,
    required this.heroGradientEnd,
    required this.authGradientTop,
  });

  // Brand
  final Color primary;
  final Color primaryDark;
  final Color secondary;
  final Color accent;

  // Surfaces
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceTint;

  // Text and its counterparts
  final Color ink;
  final Color inkMuted;
  final Color inkFaint;
  final Color onPrimary;

  // Borders / dividers
  final Color border;
  final Color borderStrong;

  // Status
  final Color success;
  final Color warning;
  final Color warningDeep;
  final Color error;
  final Color star;

  // Overlays
  final Color scrim;
  final Color shadow;

  // Soft surfaces the dashboard sits on
  final Color tintLavender;
  final Color tintPeach;
  final Color tintMint;
  final Color tintBlush;

  /// The one pink surface of the app (the student's "hand in" action).
  final Color uploadAccent;

  // Gradient stops that are neither a text nor a surface color on their own.
  final Color heroGradientStart;
  final Color heroGradientEnd;
  final Color authGradientTop;

  // ---------------------------------------------------------------------------
  // Gradients — derived, so they follow the palette of the theme in force.
  // ---------------------------------------------------------------------------

  /// Hero / primary-CTA surface. Deliberately a restrained two-stop blend:
  /// brand ink into the secondary blue.
  LinearGradient get promoGradient => LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [primaryDark, secondary],
  );

  /// Airy welcome-card surface: lavender washing into a soft mint.
  LinearGradient get heroGradient => LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [heroGradientStart, heroGradientEnd],
  );

  /// Progress fill, anchored at the edge the bar starts growing from.
  LinearGradient get progressGradient => LinearGradient(
    begin: AlignmentDirectional.centerStart,
    end: AlignmentDirectional.centerEnd,
    colors: [accent, primary],
  );

  LinearGradient get authBackgroundGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [authGradientTop, background],
  );

  /// The palette the app shipped with — still declared in [AppColors], so the
  /// light theme can't drift from the values the screens were designed against.
  static const light = AppColorsExtension(
    primary: AppColors.primary,
    primaryDark: AppColors.primaryDark,
    secondary: AppColors.secondary,
    accent: AppColors.accent,
    background: AppColors.background,
    surface: AppColors.surface,
    surfaceMuted: AppColors.surfaceMuted,
    surfaceTint: AppColors.surfaceTint,
    ink: AppColors.ink,
    inkMuted: AppColors.inkMuted,
    inkFaint: AppColors.inkFaint,
    onPrimary: AppColors.onPrimary,
    border: AppColors.border,
    borderStrong: AppColors.borderStrong,
    success: AppColors.success,
    warning: AppColors.warning,
    warningDeep: AppColors.warningDeep,
    error: AppColors.error,
    star: AppColors.star,
    scrim: AppColors.scrim,
    shadow: AppColors.shadow,
    tintLavender: AppColors.tintLavender,
    tintPeach: AppColors.tintPeach,
    tintMint: AppColors.tintMint,
    tintBlush: AppColors.tintBlush,
    uploadAccent: AppColors.uploadAccent,
    heroGradientStart: Color(0xFFEDEFFC),
    heroGradientEnd: Color(0xFFE3F3EE),
    authGradientTop: Color(0xFFE3EEFF),
  );

  /// The dark counterpart: the same blue-and-teal identity on a navy base
  /// rather than an inverted light theme.
  ///
  /// The brand blue is raised to a luminous tone, because on dark surfaces it
  /// is mostly used as *ink* (icons, links, selected tabs, progress) — and
  /// where it is still a fill (chips, the CTA) the text that sits on it flips to
  /// a deep navy, mirroring the light theme's white-on-brand pairing. Surfaces
  /// are navy, not grey, so the brand stays present; the teal/amber/pink accents
  /// are lifted the same way to keep their meaning readable.
  static const dark = AppColorsExtension(
    primary: Color(0xFF7C9BFF),
    primaryDark: Color(0xFF6D8DFF),
    secondary: Color(0xFF9DB8FF),
    accent: Color(0xFF4FD1B5),
    background: Color(0xFF0C1020),
    surface: Color(0xFF141A2E),
    surfaceMuted: Color(0xFF1B2237),
    surfaceTint: Color(0xFF232B47),
    ink: Color(0xFFEEF1FA),
    inkMuted: Color(0xFFA9B0C6),
    inkFaint: Color(0xFF7E86A0),
    onPrimary: Color(0xFF0A1024),
    border: Color(0xFF262E48),
    borderStrong: Color(0xFF333C5C),
    success: Color(0xFF35C08C),
    warning: Color(0xFFFFB84D),
    warningDeep: Color(0xFFF0B45E),
    error: Color(0xFFFF6B6B),
    star: Color(0xFFFFC44D),
    scrim: Color(0x99000000),
    shadow: Color(0x40000000),
    tintLavender: Color(0xFF1E2743),
    tintPeach: Color(0xFF3A2E18),
    tintMint: Color(0xFF14332C),
    tintBlush: Color(0xFF3A2027),
    uploadAccent: Color(0xFFFF6FA5),
    heroGradientStart: Color(0xFF18203A),
    heroGradientEnd: Color(0xFF14312C),
    authGradientTop: Color(0xFF101830),
  );

  @override
  AppColorsExtension copyWith({
    Color? primary,
    Color? primaryDark,
    Color? secondary,
    Color? accent,
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? surfaceTint,
    Color? ink,
    Color? inkMuted,
    Color? inkFaint,
    Color? onPrimary,
    Color? border,
    Color? borderStrong,
    Color? success,
    Color? warning,
    Color? warningDeep,
    Color? error,
    Color? star,
    Color? scrim,
    Color? shadow,
    Color? tintLavender,
    Color? tintPeach,
    Color? tintMint,
    Color? tintBlush,
    Color? uploadAccent,
    Color? heroGradientStart,
    Color? heroGradientEnd,
    Color? authGradientTop,
  }) {
    return AppColorsExtension(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceTint: surfaceTint ?? this.surfaceTint,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      inkFaint: inkFaint ?? this.inkFaint,
      onPrimary: onPrimary ?? this.onPrimary,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      warningDeep: warningDeep ?? this.warningDeep,
      error: error ?? this.error,
      star: star ?? this.star,
      scrim: scrim ?? this.scrim,
      shadow: shadow ?? this.shadow,
      tintLavender: tintLavender ?? this.tintLavender,
      tintPeach: tintPeach ?? this.tintPeach,
      tintMint: tintMint ?? this.tintMint,
      tintBlush: tintBlush ?? this.tintBlush,
      uploadAccent: uploadAccent ?? this.uploadAccent,
      heroGradientStart: heroGradientStart ?? this.heroGradientStart,
      heroGradientEnd: heroGradientEnd ?? this.heroGradientEnd,
      authGradientTop: authGradientTop ?? this.authGradientTop,
    );
  }

  @override
  AppColorsExtension lerp(AppColorsExtension? other, double t) {
    if (other == null || identical(other, this)) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColorsExtension(
      primary: mix(primary, other.primary),
      primaryDark: mix(primaryDark, other.primaryDark),
      secondary: mix(secondary, other.secondary),
      accent: mix(accent, other.accent),
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      surfaceMuted: mix(surfaceMuted, other.surfaceMuted),
      surfaceTint: mix(surfaceTint, other.surfaceTint),
      ink: mix(ink, other.ink),
      inkMuted: mix(inkMuted, other.inkMuted),
      inkFaint: mix(inkFaint, other.inkFaint),
      onPrimary: mix(onPrimary, other.onPrimary),
      border: mix(border, other.border),
      borderStrong: mix(borderStrong, other.borderStrong),
      success: mix(success, other.success),
      warning: mix(warning, other.warning),
      warningDeep: mix(warningDeep, other.warningDeep),
      error: mix(error, other.error),
      star: mix(star, other.star),
      scrim: mix(scrim, other.scrim),
      shadow: mix(shadow, other.shadow),
      tintLavender: mix(tintLavender, other.tintLavender),
      tintPeach: mix(tintPeach, other.tintPeach),
      tintMint: mix(tintMint, other.tintMint),
      tintBlush: mix(tintBlush, other.tintBlush),
      uploadAccent: mix(uploadAccent, other.uploadAccent),
      heroGradientStart: mix(heroGradientStart, other.heroGradientStart),
      heroGradientEnd: mix(heroGradientEnd, other.heroGradientEnd),
      authGradientTop: mix(authGradientTop, other.authGradientTop),
    );
  }
}

/// `context.colors.ink` — the palette of the theme in force.
///
/// Falls back to [AppColorsExtension.light] for a tree without the app's theme
/// (a bare `MaterialApp` in a test, a preview).
extension AppColorsContext on BuildContext {
  AppColorsExtension get colors =>
      Theme.of(this).extension<AppColorsExtension>() ??
      AppColorsExtension.light;
}
