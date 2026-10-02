import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors_extension.dart';
import '../../core/theme/app_dimensions.dart';
import 'empty_state_view.dart';

/// Placeholder body for a tab that exists in a role's shell but has no screen
/// yet: a centered panel built from the shared [EmptyStateView].
///
/// One widget covers every role's stand-in tabs, so a shell only has to say
/// which tab it stands in for. Pass [action] for the rare stand-in that needs a
/// button (e.g. the temporary sign-out on Profile); without one the layout is
/// exactly the bare panel it has always been.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    super.key,
    required this.icon,
    this.title,
    this.message,
    this.action,
  });

  final IconData icon;

  /// Defaults to the shared "coming soon" copy.
  final String? title;

  /// Defaults to the shared "still building this" hint.
  final String? message;

  /// An optional call to action under the panel.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final panel = EmptyStateView(
      icon: icon,
      title: title ?? AppStrings.comingSoonTitle,
      message: message ?? AppStrings.comingSoonMessage,
    );

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Center(
          child: action == null
              ? panel
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [panel, VGap.lg(), action!],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

