import 'package:flutter/material.dart';

import '../../../core/navigation/main_shell.dart';
import 'screens/login_screen.dart';
import 'screens/sign_up_screen.dart';

/// Switches from sign-up to login (replaces the current screen so the two
/// never stack on top of each other).
void openLogin(BuildContext context) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
  );
}

/// Switches from login to sign-up.
void openSignUp(BuildContext context) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute<void>(builder: (_) => const SignUpScreen()),
  );
}

/// Enters the app after a successful login / sign-up and clears the auth
/// stack so "back" can't return to it.
void openMainShell(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => const MainShell()),
    (route) => false,
  );
}
