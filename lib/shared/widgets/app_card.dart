import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors_extension.dart';
import '../../core/theme/app_dimensions.dart';

/// The standard content surface for the app.
///
/// It reuses the exact card treatment already used by the course cards: the
/// theme's surface fill, a hairline [AppColorsExtension.border] outline, the
/// shared [AppColorsExtension.shadow] and a corner radius from [AppRadius]. Pass
/// [onTap] to get the same subtle "press to shrink" feedback the tappable course
/// cards have.
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.radius,
    this.color,
    this.onTap,
    this.showBorder = true,
  });

  final Widget child;

  /// Defaults to [AppSpacing.md] on every side.
  final EdgeInsetsGeometry? padding;

  /// Defaults to [AppRadius.lg].
  final double? radius;

  /// Defaults to the theme's surface.
  final Color? color;

  final VoidCallback? onTap;
  final bool showBorder;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final card = Container(
      clipBehavior: Clip.antiAlias,
      padding: widget.padding ?? EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: widget.color ?? context.colors.surface,
        borderRadius: BorderRadius.circular(widget.radius ?? AppRadius.lg),
        border: widget.showBorder
            ? Border.all(color: context.colors.border)
            : null,
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow,
            blurRadius: 18,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: widget.child,
    );

    if (widget.onTap == null) return card;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: card,
      ),
    );
  }
}