import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors_extension.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_type_scale.dart';

/// Labelled form field used by the auth screens (and reusable elsewhere).
///
/// Set [isPassword] to get an obscured field with a show/hide eye toggle.
/// [labelAction] sits on the opposite end of the label row (e.g. "forgot
/// password?").
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.isPassword = false,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.labelAction,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final bool isPassword;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? labelAction;

  /// When false the field is locked (used while a submission is in flight).
  final bool enabled;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure = widget.isPassword;

  OutlineInputBorder _border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            // The label may shrink: the longest labels here are sentences, and a
            // wide glyph set (or a large text scale) would overflow the row.
            Flexible(child: Text(widget.label, style: context.texts.statLabel)),
            const Spacer(),
            if (widget.labelAction != null) widget.labelAction!,
          ],
        ),
        VGap.xs(),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscure,
          enabled: widget.enabled,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onFieldSubmitted,
          validator: widget.validator,
          style: context.texts.cardTitle.copyWith(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: widget.hint,
            filled: true,
            fillColor: context.colors.surface,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            prefixIcon: Icon(
              widget.prefixIcon,
              size: 20.sp,
              color: context.colors.inkFaint,
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: context.colors.inkFaint,
                    ),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20.sp,
                    ),
                  )
                : null,
            errorStyle: context.texts.bodySmall.copyWith(
              color: context.colors.error,
            ),
            border: _border(context.colors.border),
            enabledBorder: _border(context.colors.border),
            focusedBorder: _border(context.colors.primary, 1.4),
            errorBorder: _border(context.colors.error),
            focusedErrorBorder: _border(context.colors.error, 1.4),
          ),
        ),
      ],
    );
  }
}
