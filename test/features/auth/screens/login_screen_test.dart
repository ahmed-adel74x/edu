// The login screen against the fake repository: a 422 lands under its own input
// and a 409 shows the app's own localized copy.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:test_edu/core/network/failure.dart';
import 'package:test_edu/core/network/result.dart';
import 'package:test_edu/features/auth/constants/auth_strings.dart';
import 'package:test_edu/features/auth/screens/login_screen.dart';
import 'package:test_edu/main.dart';
import 'package:test_edu/shared/models/user.dart';
import 'package:test_edu/shared/widgets/app_primary_button.dart';

import '../../../helpers/app_test_harness.dart';
import '../../../helpers/auth_test_harness.dart';

const Size phoneSize = Size(390, 844);

Future<void> pumpLogin(WidgetTester tester, Result<User> loginResult) async {
  tester.view.physicalSize = phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final auth = registerTestAuth(
    repository: fakeAuthRepository(loginResult: loginResult),
  );
  await tester.pumpWidget(MyApp(auth: auth, assetLoader: memoryAssetLoader));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> submitForm(
  WidgetTester tester, {
  String email = 'name@example.com',
  String password = '123456',
}) async {
  await tester.enterText(find.byType(TextField).first, email);
  await tester.enterText(find.byType(TextField).last, password);
  await tester.pump();

  final submit = find.widgetWithText(AppPrimaryButton, AuthStrings.loginCta);
  await tester.ensureVisible(submit);
  await tester.pump();
  await tester.tap(submit);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

Result<User> get alreadyLoggedIn => const Error(
  ConflictFailure(
    message: 'signed in elsewhere',
    errorCode: FailureCodes.studentAlreadyLoggedIn,
  ),
);

void main() {
  setUp(prepareAppEnvironment);

  testWidgets('a 422 shows the message under its own input, not a banner', (
    tester,
  ) async {
    await pumpLogin(
      tester,
      const Error(
        ValidationFailure(
          message: 'invalid',
          errorCode: FailureCodes.validationError,
          fieldErrors: {
            'email': ['This email is already registered'],
          },
        ),
      ),
    );

    await submitForm(tester);
    await tester.pump();

    expect(find.text('This email is already registered'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
    // Validation is rendered per field, never as a generic banner.
    expect(find.text(translated('ar', ['errors', 'validation'])), findsNothing);
  });

  testWidgets('a 409 shows the Arabic copy', (tester) async {
    await pumpLogin(tester, alreadyLoggedIn);

    await submitForm(tester);

    expect(
      find.text(translated('ar', ['errors', 'alreadyLoggedIn'])),
      findsOneWidget,
    );
  });

  testWidgets('the same 409 shows the English copy after a locale switch', (
    tester,
  ) async {
    await pumpLogin(tester, alreadyLoggedIn);

    await tester
        .element(find.byType(LoginScreen))
        .setLocale(const Locale('en'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await submitForm(tester);

    expect(
      find.text(translated('en', ['errors', 'alreadyLoggedIn'])),
      findsOneWidget,
    );
  });
}
