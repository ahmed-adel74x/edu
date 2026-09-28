import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

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
        Text(question, style: AppTextStyles.body),
        HGap.xs(),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.xs),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Text(
              actionLabel,
              style: AppTextStyles.linkAction.copyWith(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
