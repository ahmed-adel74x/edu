import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/route_names.dart';
import 'auth_notifier.dart';

/// Switches from sign-up to login, replacing the current location so the two
/// never stack on top of each other.
void openLogin(BuildContext context) {
  context.pushReplacementNamed(RouteNames.login);
}

/// Switches from login to sign-up.
void openSignUp(BuildContext context) {
  context.pushReplacementNamed(RouteNames.signUp);
}

/// Enters the app after a successful login / sign-up: the first tab of the
/// signed-in role's shell.
void openMainShell(BuildContext context) {
  final role = AuthScope.of(context).role;
  // Signed out there is no shell to enter — the guard keeps the user on login.
  if (role == null) return;
  context.goNamed(homeNameFor(role));
}
