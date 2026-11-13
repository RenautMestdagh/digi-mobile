import 'dart:convert';

import 'package:digi_mobile/screens/code_screen.dart';
import 'package:digi_mobile/screens/home_screen.dart';
import 'package:digi_mobile/screens/login_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support.dart';

Future<void> logIn(WidgetTester tester, {String password = testPassword}) async {
  await tester.enterText(find.widgetWithText(TextFormField, 'E-mailadres'), testEmail);
  await tester.enterText(find.widgetWithText(TextFormField, 'Wachtwoord'), password);
  await tester.tap(find.widgetWithText(FilledButton, 'Inloggen'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('it logs in with the emailed code and shows the products', (tester) async {
    // Arrange
    final digi = FakeDigi();
    await pumpApp(tester, digi);

    // Act
    await logIn(tester);
    await tester.enterText(find.widgetWithText(TextFormField, 'Code'), testCode);
    await tester.tap(find.widgetWithText(FilledButton, 'Bevestigen'));
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Mobile 15 GB + 15 GB'), findsOneWidget);
    expect(
      digi.requestsTo('/en/login').where((request) => request.method == 'POST').map((r) => r.headers['Next-Action']),
      [logInAction, confirmAction],
    );
    expect(jsonDecode(digi.requestsTo('/v1/oauth2/send_code').single.body), {'lang': 'nl'});
    expect(await storedCookies(), contains('fake-session'));
  });

  testWidgets('it leaves the app instead of returning to the login when going back from the products', (tester) async {
    // Arrange
    final digi = FakeDigi();
    await pumpApp(tester, digi);
    await logIn(tester);
    await tester.enterText(find.widgetWithText(TextFormField, 'Code'), testCode);
    await tester.tap(find.widgetWithText(FilledButton, 'Bevestigen'));
    await tester.pumpAndSettle();

    // Act
    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // Assert
    expect(handled, isFalse);
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(CodeScreen), findsNothing);
  });

  testWidgets('it goes straight to the code after the email and password', (tester) async {
    // Arrange
    final digi = FakeDigi();
    await pumpApp(tester, digi);

    // Act
    await logIn(tester);

    // Assert
    expect(find.byType(CodeScreen), findsOneWidget);
    expect(find.text('DIGI heeft je een e-mail gestuurd met een code van 6 cijfers.'), findsOneWidget);
  });

  testWidgets('it tells the user when the password is wrong', (tester) async {
    // Arrange
    final digi = FakeDigi();
    await pumpApp(tester, digi);

    // Act
    await logIn(tester, password: 'Wrong-Password-1');

    // Assert
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Dit e-mailadres en wachtwoord kent DIGI niet'), findsOneWidget);
    expect(digi.requestsTo('/v1/oauth2/send_code'), isEmpty);
  });

  testWidgets('it tells the user when the code is wrong', (tester) async {
    // Arrange
    final digi = FakeDigi();
    await pumpApp(tester, digi);
    await logIn(tester);

    // Act
    await tester.enterText(find.widgetWithText(TextFormField, 'Code'), '654321');
    await tester.tap(find.widgetWithText(FilledButton, 'Bevestigen'));
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(CodeScreen), findsOneWidget);
    expect(find.text('Deze code klopt niet'), findsOneWidget);
    expect(await storedCookies(), isNot(contains('fake-session')));
  });

  testWidgets('it asks for the email and password before calling Digi', (tester) async {
    // Arrange
    final digi = FakeDigi();
    await pumpApp(tester, digi);

    // Act
    await tester.tap(find.widgetWithText(FilledButton, 'Inloggen'));
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Vul je e-mailadres in'), findsOneWidget);
    expect(find.text('Vul je wachtwoord in'), findsOneWidget);
    expect(digi.requests, isEmpty);
  });

  testWidgets('it tells the user when Digi can not be reached while logging in', (tester) async {
    // Arrange
    final digi = FakeDigi()..offline = true;
    await pumpApp(tester, digi);

    // Act
    await logIn(tester);

    // Assert
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('DIGI is niet bereikbaar. Controleer je internetverbinding.'), findsOneWidget);
  });

  testWidgets('it requests a password reset email', (tester) async {
    // Arrange
    final digi = FakeDigi();
    await pumpApp(tester, digi);
    await tester.tap(find.text('Wachtwoord vergeten?'));
    await tester.pumpAndSettle();

    // Act
    await tester.enterText(find.widgetWithText(TextFormField, 'E-mailadres'), testEmail);
    await tester.tap(find.widgetWithText(FilledButton, 'Versturen'));
    await tester.pumpAndSettle();

    // Assert
    expect(jsonDecode(digi.requestsTo('/v1/auth/lost-password').single.body), {'lang': 'nl', 'email': testEmail});
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Kijk in je mailbox om een nieuw wachtwoord te kiezen'), findsOneWidget);
  });

  testWidgets('it tells the user when Digi can not send a reset email to the address', (tester) async {
    // Arrange
    final digi = FakeDigi();
    await pumpApp(tester, digi);
    await tester.tap(find.text('Wachtwoord vergeten?'));
    await tester.pumpAndSettle();

    // Act
    await tester.enterText(find.widgetWithText(TextFormField, 'E-mailadres'), 'unknown@dynamate.be');
    await tester.tap(find.widgetWithText(FilledButton, 'Versturen'));
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('DIGI kon geen e-mail sturen naar dit adres'), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Wachtwoord vergeten'), findsOneWidget);
  });
}
