import 'package:flutter/material.dart';

/// Centralized color palette. Every color used in the app should come
/// from here — never hardcode a hex value inside a screen or widget.
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF0037B0);
  static const primaryDark = Color(0xFF002478);
  static const secondary = Color(0xFF1D4ED8);
  static const accent = Color(0xFF00857A);

  // Surfaces
  static const background = Color(0xFFF7F7FB);
  static const surface = Colors.white;
  static const surfaceMuted = Color(0xFFF2F3FA);
  static const surfaceTint = Color(0xFFEDEFFF);

  // Text
  static const ink = Color(0xFF10162B);
  static const inkMuted = Color(0xFF5B6072);
  static const inkFaint = Color(0xFF9A9EAE);
  static const onPrimary = Colors.white;

  // Borders / dividers
  static const border = Color(0xFFE7E8F2);
  static const borderStrong = Color(0xFFD7D9EA);

  // Status
  static const success = Color(0xFF1D9A6C);
  static const warning = Color(0xFFF5A524);
  static const error = Color(0xFFE23D3D);
  static const star = Color(0xFFFFB020);

  // Overlays
  static const scrim = Color(0x66101021);
  static const shadow = Color(0x14131B2E);

  /// Restrained two-stop gradient for the hero/promo surface —
  /// deliberately not the original 3-color blend, for a calmer premium look.
  static const promoGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [primaryDark, secondary],
  );

  // ---------------------------------------------------------------------------
  // Dashboard accents (home screen)
  //
  // Soft icon-tile tints, each paired with one of the brand inks above so a
  // tile always reads as "brand color on its tint": lavender/primary,
  // peach/warningDeep, mint/accent and blush/error.
  // ---------------------------------------------------------------------------
  static const tintLavender = Color(0xFFE7E9FC);
  static const tintPeach = Color(0xFFFCE7D0);
  static const tintMint = Color(0xFFCCEDE4);
  static const tintBlush = Color(0xFFFCE0E2);

  /// Deeper amber used for icon inks on a [tintPeach] surface, where the
  /// regular [warning] reads too light.
  static const warningDeep = Color(0xFFB8730E);

  /// Airy welcome-card surface: lavender washing into a soft mint.
  static const heroGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFFEDEFFC), Color(0xFFE3F3EE)],
  );

  // ---------------------------------------------------------------------------
  // Assignment accents (assignments screen)
  //
  // The "hand in" call to action is the app's one pink surface: it reads as an
  // urgent action next to the blue brand surfaces without adding a second
  // brand color.
  // ---------------------------------------------------------------------------
  static const uploadAccent = Color(0xFFF4407F);

  /// Progress fill, anchored at the trailing (right, in RTL) edge where the
  /// bar starts growing: teal into brand blue.
  static const progressGradient = LinearGradient(
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
    colors: [accent, primary],
  );

  static const authBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE3EEFF), background],
  );
}
