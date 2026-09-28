import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_text_styles.dart';

/// Builds the app's [ThemeData]. Call this only after ScreenUtil has been
/// initialized (it relies on the responsive text styles / radii above).
abstract final class AppTheme {
  static ThemeData data() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,
      fontFamily: AppTextStyles.body.fontFamily,

      textTheme: TextTheme(
        headlineSmall: AppTextStyles.display,
        titleLarge: AppTextStyles.sectionTitle,
        titleMedium: AppTextStyles.cardTitle,
        bodyMedium: AppTextStyles.body,
        bodySmall: AppTextStyles.bodySmall,
        labelSmall: AppTextStyles.label,
        labelLarge: AppTextStyles.button,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.ink,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          textStyle: AppTextStyles.button,
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
          backgroundColor: AppColors.surfaceTint,
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceMuted,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.inkFaint),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceTint,
        selectedColor: AppColors.primary,
        showCheckmark: false,
        labelStyle: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
        secondaryLabelStyle: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.onPrimary,
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
        backgroundColor: AppColors.surface,
        elevation: 0,
        indicatorColor: AppColors.primary,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.primary : AppColors.inkFaint,
            fontSize: 11,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.onPrimary : AppColors.inkFaint,
            size: 22,
          );
        }),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
