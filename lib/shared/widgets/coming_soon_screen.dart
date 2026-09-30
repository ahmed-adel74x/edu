import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import 'empty_state_view.dart';

/// Placeholder body for a tab that exists in a role's shell but has no screen
/// yet: a centered panel built from the shared [EmptyStateView].
///
/// One widget covers every role's stand-in tabs, so a shell only has to say
/// which tab it stands in for.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    super.key,
    required this.icon,
    this.title = AppStrings.comingSoonTitle,
    this.message = AppStrings.comingSoonMessage,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: EmptyStateView(icon: icon, title: title, message: message),
        ),
      ),
    );
  }
}
