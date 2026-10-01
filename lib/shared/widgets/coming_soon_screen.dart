import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors_extension.dart';
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
    this.title,
    this.message,
  });

  final IconData icon;

  /// Defaults to the shared "coming soon" copy.
  final String? title;

  /// Defaults to the shared "still building this" hint.
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Center(
          child: EmptyStateView(
            icon: icon,
            title: title ?? AppStrings.comingSoonTitle,
            message: message ?? AppStrings.comingSoonMessage,
          ),
        ),
      ),
    );
  }
}
