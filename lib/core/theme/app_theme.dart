import 'package:flutter/material.dart';

import 'app_colors_extension.dart';
import 'app_dimensions.dart';
import 'app_type_scale.dart';

/// Builds the app's [ThemeData]. Call these only after ScreenUtil has been
/// initialized (they rely on the responsive text styles / radii above).
///
/// Both themes are one builder run on a different [AppColorsExtension], so a
/// component can never end up styled for a single theme only.
abstract final class AppTheme {
  /// The theme the app was designed in.
  static ThemeData light() =>
      _build(AppColorsExtension.light, Brightness.light);

  /// Its dark counterpart.
  static ThemeData dark() => _build(AppColorsExtension.dark, Brightness.dark);

  static ThemeData _build(AppColorsExtension colors, Brightness brightness) {
    final text = AppTypeScale(colors);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: colors.primary,
      brightness: brightness,
      primary: colors.primary,
      secondary: colors.secondary,
      surface: colors.surface,
      error: colors.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      splashFactory: InkSparkle.splashFactory,
      fontFamily: text.body.fontFamily,

      // The palette travels with the theme, so `context.colors` always matches
      // the ThemeData in force.
      extensions: [colors],

      textTheme: TextTheme(
        headlineSmall: text.display,
        titleLarge: text.sectionTitle,
        titleMedium: text.cardTitle,
        bodyMedium: text.body,
        bodySmall: text.bodySmall,
        labelSmall: text.label,
        labelLarge: text.button,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: colors.ink,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          textStyle: text.button,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          minimumSize: const Size(0, 44),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          backgroundColor: colors.surfaceTint,
          foregroundColor: colors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceMuted,
        hintStyle: text.body.copyWith(color: colors.inkFaint),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: colors.primary, width: 1.4),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceTint,
        selectedColor: colors.primary,
        showCheckmark: false,
        labelStyle: text.bodySmall.copyWith(
          fontWeight: FontWeight.w700,
          color: colors.primary,
        ),
        secondaryLabelStyle: text.bodySmall.copyWith(
          fontWeight: FontWeight.w700,
          color: colors.onPrimary,
        ),
        side: BorderSide.none,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        shape: const StadiumBorder(),
      ),

      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: colors.surface,
        elevation: 0,
        indicatorColor: colors.primary,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return text.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            color: selected ? colors.primary : colors.inkFaint,
            fontSize: 11,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? colors.onPrimary : colors.inkFaint,
            size: 22,
          );
        }),
      ),

      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
