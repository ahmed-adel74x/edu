import 'package:flutter/material.dart';

import '../../../core/theme/app_colors_extension.dart';
import '../../../core/theme/app_type_scale.dart';
import '../constants/auth_strings.dart';

/// Shows a short message the app owns — never the server's own text.
///
/// The surface follows the theme, so it reads the same in either appearance and
/// either direction.
void showAuthMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: context.colors.ink,
        content: Text(
          message,
          style: context.texts.body.copyWith(color: context.colors.surface),
        ),
      ),
    );
}

/// For sign-up and forgot-password, which exist in the UI but have no flow yet.
void showNotAvailableMessage(BuildContext context) {
  showAuthMessage(context, AuthStrings.notAvailable);
}
