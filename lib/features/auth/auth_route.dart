import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/route_names.dart';

/// Switches from sign-up to login, replacing the current location so the two
/// never stack on top of each other.
void openLogin(BuildContext context) {
  context.pushReplacementNamed(RouteNames.login);
}

/// Switches from login to sign-up.
void openSignUp(BuildContext context) {
  context.pushReplacementNamed(RouteNames.signUp);
}

