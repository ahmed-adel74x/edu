import 'package:flutter/material.dart';

import '../../../core/theme/app_colors_extension.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_type_scale.dart';
import '../../../shared/models/user_role.dart';
import '../../../shared/widgets/app_pill.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../constants/auth_strings.dart';
import '../utils/auth_feedback.dart';
import '../utils/auth_validators.dart';
import '../auth_route.dart';
import '../widgets/auth_checkbox_row.dart';
import '../widgets/auth_hero_card.dart';
import '../widgets/auth_info_banner.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_switch_prompt.dart';
import '../widgets/or_divider.dart';
import '../widgets/role_selector.dart';
import '../widgets/social_buttons_row.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  /// Which role this mock session belongs to; the real app takes it from the
  /// new account instead.
  UserRole _role = UserRole.student;
  bool _acceptedTerms = false;
  bool _showTermsError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final formValid = _formKey.currentState?.validate() ?? false;
    setState(() => _showTermsError = !_acceptedTerms);
    if (!formValid || !_acceptedTerms) return;

    // Sign-up has no backend yet: it signs nobody in and says so.
    showNotAvailableMessage(context);
  }

  @override
  Widget build(BuildContext context) {
    final linkStyle = context.texts.body.copyWith(
      color: context.colors.primary,
      fontWeight: FontWeight.w700,
    );

    return AuthScaffold(
      title: AuthStrings.signUpTitle,
      footer: [
        AuthSwitchPrompt(
          question: AuthStrings.haveAccount,
          actionLabel: AuthStrings.loginLink,
          onTap: () => openLogin(context),
        ),
      ],
      children: [
        AuthHeroCard(
          topStart: AppPill(
            color: context.colors.tintPeach,
            child: Text(
              AuthStrings.academicTag,
              style: context.texts.label.copyWith(
                color: context.colors.warningDeep,
              ),
            ),
          ),
          topEnd: AppPill(
            color: context.colors.surfaceTint,
            child: Text(
              AuthStrings.studentsBadge,
              style: context.texts.label.copyWith(
                color: context.colors.primary,
              ),
            ),
          ),
          title: AuthStrings.signUpHeroTitle,
          subtitle: AuthStrings.signUpHeroSubtitle,
        ),
        VGap.lg(),
        RoleSelector(
          selected: _role,
          onSelected: (role) => setState(() => _role = role),
        ),
        VGap.lg(),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _nameController,
                label: AuthStrings.fullNameLabel,
                hint: AuthStrings.fullNameHint,
                prefixIcon: Icons.person_outline_rounded,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                validator: AuthValidators.fullName,
              ),
              VGap.md(),
              AppTextField(
                controller: _identifierController,
                label: AuthStrings.emailOrPhoneLabel,
                hint: AuthStrings.emailOrPhoneHint,
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: AuthValidators.emailOrPhone,
              ),
              VGap.md(),
              AppTextField(
                controller: _passwordController,
                label: AuthStrings.passwordLabel,
                hint: AuthStrings.passwordHint,
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: true,
                textInputAction: TextInputAction.next,
                validator: AuthValidators.password,
              ),
              VGap.md(),
              AppTextField(
                controller: _confirmController,
                label: AuthStrings.confirmPasswordLabel,
                hint: AuthStrings.passwordHint,
                prefixIcon: Icons.verified_user_outlined,
                isPassword: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: (v) =>
                    AuthValidators.confirmPassword(v, _passwordController.text),
              ),
            ],
          ),
        ),
        VGap.md(),
        AuthCheckboxRow(
          value: _acceptedTerms,
          onChanged: (v) => setState(() {
            _acceptedTerms = v;
            if (v) _showTermsError = false;
          }),
          // TODO: make the two links open the terms / privacy pages.
          child: Text.rich(
            TextSpan(
              style: context.texts.body,
              children: [
                TextSpan(text: AuthStrings.termsPrefix),
                TextSpan(text: AuthStrings.termsLink, style: linkStyle),
                TextSpan(text: AuthStrings.termsAnd),
                TextSpan(text: AuthStrings.privacyLink, style: linkStyle),
                TextSpan(text: AuthStrings.termsSuffix),
              ],
            ),
          ),
        ),
        if (_showTermsError) ...[
          VGap.xxs(),
          Text(
            AuthStrings.termsRequired,
            style: context.texts.bodySmall.copyWith(
              color: context.colors.error,
            ),
          ),
        ],
        VGap.lg(),
        AppPrimaryButton(
          label: AuthStrings.signUpCta,
          onPressed: _submit,
        ),
        VGap.lg(),
        OrDivider(label: AuthStrings.quickSignUpWith),
        VGap.md(),
        const SocialButtonsRow(),
        VGap.lg(),
        AuthInfoBanner(
          icon: Icons.verified_user_outlined,
          iconBackground: context.colors.tintMint,
          iconColor: context.colors.accent,
          label: AuthStrings.certificatesLabel,
          text: AuthStrings.certificatesText,
        ),
      ],
    );
  }
}
