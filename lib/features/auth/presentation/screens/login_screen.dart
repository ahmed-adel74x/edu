import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_pill.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../constants/auth_strings.dart';
import '../../utils/auth_validators.dart';
import '../auth_route.dart';
import '../widgets/auth_checkbox_row.dart';
import '../widgets/auth_hero_card.dart';
import '../widgets/auth_info_banner.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_switch_prompt.dart';
import '../widgets/or_divider.dart';
import '../widgets/social_buttons_row.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberDevice = true;
  bool _submitting = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    // Simulated request; wire this to a real repository call when the
    // backend is connected.
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _submitting = false);
    openMainShell(context);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: AuthStrings.loginTitle,
      footer: [
        const AuthInfoBanner(
          icon: Icons.lightbulb_outline_rounded,
          iconBackground: AppColors.accent,
          iconColor: AppColors.onPrimary,
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
            color: AppColors.surface,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded, size: 15.sp, color: AppColors.star),
                HGap.xxs(),
                Text(
                  AuthStrings.loginBadge,
                  style: AppTextStyles.label.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          topEnd: Text(AuthStrings.loginTag, style: AppTextStyles.bodySmall),
          title: AuthStrings.loginHeroTitle,
          subtitle: AuthStrings.loginHeroSubtitle,
        ),
        VGap.xl(),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: AuthValidators.password,
                labelAction: InkWell(
                  onTap: () {}, // TODO: forgot-password flow
                  child: Text(
                    AuthStrings.forgotPassword,
                    style: AppTextStyles.linkAction,
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
          child: Text(AuthStrings.rememberDevice, style: AppTextStyles.body),
        ),
        VGap.lg(),
        AppPrimaryButton(
          label: AuthStrings.loginCta,
          isLoading: _submitting,
          onPressed: _submit,
        ),
        VGap.lg(),
        const OrDivider(label: AuthStrings.continueWith),
        VGap.md(),
        const SocialButtonsRow(),
      ],
    );
  }
}
