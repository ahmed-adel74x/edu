import '../constants/auth_strings.dart';

/// Form validators shared by the login and sign-up screens.
abstract final class AuthValidators {
  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
  static final _phoneRegex = RegExp(r'^05\d{8}$');

  static String? fullName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return AuthStrings.fullNameRequired;
    if (v.length < 3) return AuthStrings.fullNameTooShort;
    return null;
  }

  static String? emailOrPhone(String? value) {
    final v = (value ?? '').trim().replaceAll(' ', '');
    if (v.isEmpty) return AuthStrings.emailOrPhoneRequired;
    if (_emailRegex.hasMatch(v) || _phoneRegex.hasMatch(v)) return null;
    return AuthStrings.emailOrPhoneInvalid;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return AuthStrings.passwordRequired;
    if (v.length < 8) return AuthStrings.passwordTooShort;
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final v = value ?? '';
    if (v.isEmpty) return AuthStrings.confirmPasswordRequired;
    if (v != password) return AuthStrings.passwordsMismatch;
    return null;
  }
}
