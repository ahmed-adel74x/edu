import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/di/injection.dart';
import '../../../core/network/failure.dart';
import '../../../core/theme/app_colors_extension.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_type_scale.dart';
import '../../../core/utils/failure_message.dart';
import '../../../shared/models/user_role.dart';
import '../../../shared/widgets/app_pill.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../auth_route.dart';
import '../constants/auth_strings.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';
import '../utils/auth_feedback.dart';
import '../utils/auth_validators.dart';
import '../widgets/auth_checkbox_row.dart';
import '../widgets/auth_hero_card.dart';
import '../widgets/auth_info_banner.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_switch_prompt.dart';
import '../widgets/or_divider.dart';
import '../widgets/role_selector.dart';
import '../widgets/social_buttons_row.dart';

/// The sign-in screen.
///
/// It provides its own [LoginCubit] (a fresh one per visit) and hands the
/// submission to it; the router is what moves the user on, once the global
/// [AuthCubit] reports a session. The debug-only role selector swaps a student's
/// real login for a mock preview of the teacher / parent shells.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginCubit>(
      create: (_) => getIt<LoginCubit>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// Which role this session belongs to. Only the debug selector changes it; in
  /// a release build it stays [UserRole.student] and the selector is gone.
  UserRole _role = UserRole.student;
  bool _rememberDevice = true;

  @override
  void initState() {
    super.initState();
    // A session that just ended is explained once, as login appears.
    WidgetsBinding.instance.addPostFrameCallback((_) => _showSessionEndedOnce());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSessionEndedOnce() {
    if (!mounted) return;
    final auth = context.read<AuthCubit>();
    if (auth.state.sessionEndedReason == null) return;
    showAuthMessage(context, FailureStrings.sessionEnded);
    auth.clearSessionEndedReason();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_role != UserRole.student) {
      // Debug preview: no request, no token.
      context.read<AuthCubit>().debugSignInAs(_role);
      return;
    }

    await context.read<LoginCubit>().submit(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  /// A 422's per-field message wins over the client rule, so the server's text
  /// lands under the matching input instead of a generic banner.
  String? _emailValidator(String? value) {
    final server = context.read<LoginCubit>().state.fieldErrors['email'];
    return (server != null && server.isNotEmpty)
        ? server.first
        : AuthValidators.email(value);
  }

  String? _passwordValidator(String? value) {
    final server = context.read<LoginCubit>().state.fieldErrors['password'];
    return (server != null && server.isNotEmpty)
        ? server.first
        : AuthValidators.loginPassword(value);
  }

  void _onLoginFailure(BuildContext context, LoginState state) {
    final failure = state.failure;
    if (failure == null) return;
    if (failure is ValidationFailure) {
      // Put the server's messages under the inputs, not in a banner.
      _formKey.currentState?.validate();
      return;
    }
    showAuthMessage(context, failureMessage(failure));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listenWhen: (previous, current) =>
          current.status == LoginStatus.failure &&
          previous.status != LoginStatus.failure,
      listener: _onLoginFailure,
      child: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, state) {
          final isLoading = state.isLoading;
          return AuthScaffold(
            title: AuthStrings.loginTitle,
            footer: [
              AuthInfoBanner(
                icon: Icons.lightbulb_outline_rounded,
                iconBackground: context.colors.accent,
                iconColor: context.colors.onPrimary,
                label: AuthStrings.dailyWisdomLabel,
                text: AuthStrings.dailyWisdomText,
              ),
              VGap.md(),
              AuthSwitchPrompt(
                question: AuthStrings.noAccount,
                actionLabel: AuthStrings.createAccountLink,
                onTap: () => openSignUp(context),
              ),
            ],
            children: [
              AuthHeroCard(
                topStart: AppPill(
                  color: context.colors.surface,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 15.sp,
                        color: context.colors.star,
                      ),
                      HGap.xxs(),
                      // Shrinkable: the badge is a sentence, so on a narrow
                      // surface (or a wide glyph set) it wraps inside the pill
                      // instead of pushing past the card's edge.
                      Flexible(
                        child: Text(
                          AuthStrings.loginBadge,
                          style: context.texts.label.copyWith(
                            color: context.colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                topEnd: Text(AuthStrings.loginTag, style: context.texts.bodySmall),
                title: AuthStrings.loginHeroTitle,
                subtitle: AuthStrings.loginHeroSubtitle,
              ),
              VGap.xl(),
              // Debug-only: preview another role's shell. Not in release builds.
              if (kDebugMode) ...[
                RoleSelector(
                  label:
                      '${AuthStrings.roleSelectorLabel} '
                      '(${AuthStrings.roleDevOnly})',
                  selected: _role,
                  onSelected: (role) => setState(() => _role = role),
                ),
                VGap.lg(),
              ],
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      controller: _emailController,
                      label: AuthStrings.emailOrPhoneLabel,
                      hint: AuthStrings.emailOrPhoneHint,
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _emailValidator,
                      enabled: !isLoading,
                    ),
                    VGap.md(),
                    AppTextField(
                      controller: _passwordController,
                      label: AuthStrings.passwordLabel,
                      hint: AuthStrings.passwordHint,
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: _passwordValidator,
                      enabled: !isLoading,
                      labelAction: InkWell(
                        onTap: () => showNotAvailableMessage(context),
                        child: Text(
                          AuthStrings.forgotPassword,
                          style: context.texts.linkAction,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              VGap.md(),
              AuthCheckboxRow(
                value: _rememberDevice,
                onChanged: (v) => setState(() => _rememberDevice = v),
                child: Text(AuthStrings.rememberDevice, style: context.texts.body),
              ),
              VGap.lg(),
              AppPrimaryButton(
                label: AuthStrings.loginCta,
                isLoading: isLoading,
                onPressed: _submit,
              ),
              VGap.lg(),
              OrDivider(label: AuthStrings.continueWith),
              VGap.md(),
              const SocialButtonsRow(),
            ],
          );
        },
      ),
    );
  }
}
