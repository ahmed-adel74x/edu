import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/coming_soon_screen.dart';
import '../constants/auth_strings.dart';
import '../cubit/auth_cubit.dart';

/// TEMPORARY: the stand-in Profile tab, with a real sign-out button so a session
/// can be ended from the UI before the Profile screen exists.
///
/// TODO: replace this with the real Profile screen; the sign-out button goes
/// with it.
class ProfileLogoutPlaceholder extends StatelessWidget {
  const ProfileLogoutPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return ComingSoonScreen(
      icon: Icons.person_rounded,
      title: AppStrings.navProfile,
      action: AppPrimaryButton(
        label: AuthStrings.logout,
        icon: Icons.logout_rounded,
        onPressed: () => context.read<AuthCubit>().logout(),
      ),
    );
  }
}
