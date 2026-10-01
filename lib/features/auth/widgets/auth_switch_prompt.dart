import 'package:flutter/material.dart';

import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_type_scale.dart';

/// "Don't have an account? Create one" / "Already have one? Log in" line.
class AuthSwitchPrompt extends StatelessWidget {
  const AuthSwitchPrompt({
    super.key,
    required this.question,
    required this.actionLabel,
    required this.onTap,
  });

  final String question;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Both sides may shrink: a long question (or a wide glyph set) wraps
        // instead of overflowing the row.
        Flexible(
          child: Text(
            question,
            style: context.texts.body,
            textAlign: TextAlign.center,
          ),
        ),
        HGap.xs(),
        Flexible(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Text(
                actionLabel,
                style: context.texts.linkAction.copyWith(fontSize: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
