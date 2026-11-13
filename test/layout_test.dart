import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support.dart';

const _devices = {'phone': Size(360, 740), 'tablet': Size(1280, 800)};

void main() {
  for (final MapEntry(key: device, value: size) in _devices.entries) {
    for (final textScale in [1.0, 2.0]) {
      final on = 'on a $device with text at ${textScale}x';

      testWidgets('the login, code and password reset screens fit $on', (tester) async {
        // Arrange
        final digi = FakeDigi();
        await pumpApp(tester, digi, size: size, textScale: textScale);
        final login = tester.takeException();
        await tester.tap(find.text('Wachtwoord vergeten?'));
        await tester.pumpAndSettle();
        final reset = tester.takeException();
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        // Act
        await tester.enterText(find.widgetWithText(TextFormField, 'E-mailadres'), testEmail);
        await tester.enterText(find.widgetWithText(TextFormField, 'Wachtwoord'), testPassword);
        await tester.tap(find.widgetWithText(FilledButton, 'Inloggen'));
        await tester.pumpAndSettle();

        // Assert
        expect(login, isNull);
        expect(reset, isNull);
        expect(tester.takeException(), isNull);
        expect(find.text('Verificatiecode'), findsOneWidget);
      });

      testWidgets('the products fit $on', (tester) async {
        // Arrange
        final digi = FakeDigi();

        // Act
        await pumpApp(tester, digi, signedIn: true, size: size, textScale: textScale);

        // Assert
        expect(tester.takeException(), isNull);
        expect(tester.getSize(find.byType(Card).first).width, lessThanOrEqualTo(560));
      });

      testWidgets('the error with its retry button fits $on', (tester) async {
        // Arrange
        final digi = FakeDigi()..offline = true;

        // Act
        await pumpApp(tester, digi, signedIn: true, size: size, textScale: textScale);

        // Assert
        expect(tester.takeException(), isNull);
        expect(find.text('Opnieuw proberen'), findsOneWidget);
      });
    }
  }
}
