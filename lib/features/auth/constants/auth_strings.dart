import 'package:easy_localization/easy_localization.dart';

abstract final class AuthStrings {
  // Shared chrome
  static String get help => 'auth.common.help'.tr();
  static String get back => 'auth.common.back'.tr();
  static String get continueWith => 'auth.common.continueWith'.tr();
  static String get quickSignUpWith => 'auth.common.quickSignUpWith'.tr();
  static String get google => 'auth.common.google'.tr();
  static String get apple => 'auth.common.apple'.tr();
  static String get passwordHint => 'auth.common.passwordHint'.tr();
  static String get emailOrPhoneLabel => 'auth.common.emailOrPhoneLabel'.tr();
  static String get emailOrPhoneHint => 'auth.common.emailOrPhoneHint'.tr();
  static String get passwordLabel => 'auth.common.passwordLabel'.tr();

  // Mock sign-in: which role the next session belongs to
  static String get roleSelectorLabel => 'auth.roles.label'.tr();
  static String get roleStudent => 'auth.roles.student'.tr();
  static String get roleTeacher => 'auth.roles.teacher'.tr();
  static String get roleParent => 'auth.roles.parent'.tr();

  // Login
  static String get loginTitle => 'auth.login.title'.tr();
  static String get loginBadge => 'auth.login.badge'.tr();
  static String get loginTag => 'auth.login.tag'.tr();
  static String get loginHeroTitle => 'auth.login.heroTitle'.tr();
  static String get loginHeroSubtitle => 'auth.login.heroSubtitle'.tr();
  static String get forgotPassword => 'auth.login.forgotPassword'.tr();
  static String get rememberDevice => 'auth.login.rememberDevice'.tr();
  static String get loginCta => 'auth.login.cta'.tr();
  static String get dailyWisdomLabel => 'auth.login.wisdomLabel'.tr();
  static String get dailyWisdomText => 'auth.login.wisdomText'.tr();
  static String get noAccount => 'auth.login.noAccount'.tr();
  static String get createAccountLink => 'auth.login.createAccountLink'.tr();

  // Sign up
  static String get signUpTitle => 'auth.signUp.title'.tr();
  static String get studentsBadge => 'auth.signUp.studentsBadge'.tr();
  static String get academicTag => 'auth.signUp.academicTag'.tr();
  static String get signUpHeroTitle => 'auth.signUp.heroTitle'.tr();
  static String get signUpHeroSubtitle => 'auth.signUp.heroSubtitle'.tr();
  static String get fullNameLabel => 'auth.signUp.fullNameLabel'.tr();
  static String get fullNameHint => 'auth.signUp.fullNameHint'.tr();
  static String get confirmPasswordLabel =>
      'auth.signUp.confirmPasswordLabel'.tr();
  static String get termsPrefix => 'auth.signUp.termsPrefix'.tr();
  static String get termsLink => 'auth.signUp.termsLink'.tr();
  static String get termsAnd => 'auth.signUp.termsAnd'.tr();
  static String get privacyLink => 'auth.signUp.privacyLink'.tr();
  static String get termsSuffix => 'auth.signUp.termsSuffix'.tr();
  static String get signUpCta => 'auth.signUp.cta'.tr();
  static String get certificatesLabel => 'auth.signUp.certificatesLabel'.tr();
  static String get certificatesText => 'auth.signUp.certificatesText'.tr();
  static String get haveAccount => 'auth.signUp.haveAccount'.tr();
  static String get loginLink => 'auth.signUp.loginLink'.tr();

  // Validation
  static String get fullNameRequired => 'auth.validation.fullNameRequired'.tr();
  static String get fullNameTooShort => 'auth.validation.fullNameTooShort'.tr();
  static String get emailOrPhoneRequired =>
      'auth.validation.emailOrPhoneRequired'.tr();
  static String get emailOrPhoneInvalid =>
      'auth.validation.emailOrPhoneInvalid'.tr();
  static String get passwordRequired => 'auth.validation.passwordRequired'.tr();
  static String get passwordTooShort => 'auth.validation.passwordTooShort'.tr();
  static String get confirmPasswordRequired =>
      'auth.validation.confirmPasswordRequired'.tr();
  static String get passwordsMismatch =>
      'auth.validation.passwordsMismatch'.tr();
  static String get termsRequired => 'auth.validation.termsRequired'.tr();
}
