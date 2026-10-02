// The sign-up screen has no flow yet: submitting must not sign anyone in and
// must say so, in the app's own localized copy.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:test_edu/features/auth/constants/auth_strings.dart';
import 'package:test_edu/features/auth/screens/sign_up_screen.dart';
import 'package:test_edu/main.dart';
import 'package:test_edu/shared/widgets/app_primary_button.dart';

import '../../../helpers/app_test_harness.dart';
import '../../../helpers/auth_test_harness.dart';

const Size phoneSize = Size(390, 844);

void main() {
  setUp(prepareAppEnvironment);

  testWidgets('submitting says it is unavailable and signs nobody in', (
    tester,
  ) async {
    tester.view.physicalSize = phoneSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final auth = registerTestAuth(repository: fakeAuthRepository());
    await tester.pumpWidget(MyApp(auth: auth, assetLoader: memoryAssetLoader));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Open sign-up from login.
    final createAccount = find.text(AuthStrings.createAccountLink);
    await tester.ensureVisible(createAccount);
    await tester.pump();
    await tester.tap(createAccount);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(SignUpScreen), findsOneWidget);

    // Name, identifier, password, confirmation.
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Ahmed Student');
    await tester.enterText(fields.at(1), 'ahmed@example.com');
    await tester.enterText(fields.at(2), '12345678');
    await tester.enterText(fields.at(3), '12345678');
    await tester.pump();

    final terms = find.byType(Checkbox);
    await tester.ensureVisible(terms);
    await tester.pump();
    await tester.tap(terms);
    await tester.pump();

    final submit = find.widgetWithText(AppPrimaryButton, AuthStrings.signUpCta);
    await tester.ensureVisible(submit);
    await tester.pump();
    await tester.tap(submit);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      find.text(translated('ar', ['auth', 'common', 'notAvailable'])),
      findsOneWidget,
    );
    // Still on sign-up, and the session was never started.
    expect(find.byType(SignUpScreen), findsOneWidget);
    expect(auth.state.isAuthenticated, isFalse);
  });
}
