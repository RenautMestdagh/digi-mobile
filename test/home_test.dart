import 'package:digi_mobile/screens/home_screen.dart';
import 'package:digi_mobile/screens/login_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support.dart';

/// Tall enough to show every product of the fixtures at once.
const _tall = Size(400, 2400);

void main() {
  testWidgets('it shows the usage of every product', (tester) async {
    // Arrange
    final digi = FakeDigi();

    // Act
    await pumpApp(tester, digi, signedIn: true, size: _tall);

    // Assert
    expect(find.text('Mobile 15 GB + 15 GB'), findsOneWidget);
    expect(find.text('0400000000'), findsOneWidget);
    expect(find.text('Mobile 5 GB'), findsOneWidget);
    expect(find.text('Data'), findsNWidgets(2));
    expect(find.text('30.00 GB'), findsNWidgets(2));
    expect(find.text('6.05 GB'), findsNWidgets(2));
    expect(find.text('20% gebruikt'), findsNWidgets(2));
    expect(find.text('Bellen'), findsNWidgets(2));
    expect(find.text('Onbeperkt'), findsNWidgets(2));
    expect(find.text('18 min'), findsNWidgets(2));
    expect(find.text("Te betalen sms'en: SMS 0 x €0.07 = €0"), findsNWidgets(2));
    expect(find.text('Jouw verbruik wordt op 30/11/2026 geüpdatet.'), findsNWidgets(2));
    expect(find.textContaining('Kijk hier of er andere'), findsNothing);
  });

  testWidgets('it shows the usage as a share of the data limit', (tester) async {
    // Arrange
    final digi = FakeDigi();

    // Act
    await pumpApp(tester, digi, signedIn: true, size: _tall);

    // Assert
    final bar = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator).first);
    expect(bar.value, closeTo(6.05 / 30, 0.0001));
    expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
  });

  testWidgets('it shows the products in the language of the app', (tester) async {
    // Arrange
    final digi = FakeDigi();

    // Act
    await pumpApp(tester, digi, signedIn: true);

    // Assert
    expect(digi.requestsTo('/nl/my-digi/my-products'), hasLength(1));
    expect(digi.requestsTo('/nl/my-digi/my-products/mobile'), hasLength(2));
  });

  testWidgets('it shows a product whose usage could not be loaded next to the others', (tester) async {
    // Arrange
    final digi = FakeDigi()..failingNumbers.add('0400000001');

    // Act
    await pumpApp(tester, digi, signedIn: true, size: _tall);

    // Assert
    expect(find.text('Mobile 5 GB'), findsOneWidget);
    expect(find.text('DIGI gaf een onverwacht antwoord. Probeer het later opnieuw.'), findsOneWidget);
    expect(find.text('20% gebruikt'), findsOneWidget);
  });

  testWidgets('it keeps the session and offers to try again when Digi can not be reached', (tester) async {
    // Arrange
    final digi = FakeDigi()..offline = true;
    await pumpApp(tester, digi, signedIn: true);
    expect(find.text('DIGI is niet bereikbaar. Controleer je internetverbinding.'), findsOneWidget);

    // Act
    digi.offline = false;
    await tester.tap(find.text('Opnieuw proberen'));
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Mobile 15 GB + 15 GB'), findsOneWidget);
    expect(await storedCookies(), contains('fake-session'));
  });

  testWidgets('it loads the products again when pulled down', (tester) async {
    // Arrange
    final digi = FakeDigi();
    await pumpApp(tester, digi, signedIn: true);

    // Act
    await tester.fling(find.text('Mobile 15 GB + 15 GB'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    // Assert
    expect(digi.requestsTo('/nl/my-digi/my-products'), hasLength(2));
  });

  testWidgets('it returns to the login when the session has expired', (tester) async {
    // Arrange
    final digi = FakeDigi()..sessionValid = false;

    // Act
    await pumpApp(tester, digi, signedIn: true);

    // Assert
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Je sessie is verlopen. Log opnieuw in.'), findsOneWidget);
    expect(await storedCookies(), isEmpty);
  });

  testWidgets('it logs out at Digi and forgets the session', (tester) async {
    // Arrange
    final digi = FakeDigi();
    await pumpApp(tester, digi, signedIn: true);

    // Act
    await tester.tap(find.byTooltip('Uitloggen'));
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(digi.requestsTo('/api/auth/signout').single.bodyFields['csrfToken'], 'fake-csrf');
    expect(await storedCookies(), isEmpty);
  });

  testWidgets('it forgets the session on logout even when Digi can not be reached', (tester) async {
    // Arrange
    final digi = FakeDigi();
    await pumpApp(tester, digi, signedIn: true);
    digi.offline = true;

    // Act
    await tester.tap(find.byTooltip('Uitloggen'));
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(await storedCookies(), isEmpty);
  });
}
