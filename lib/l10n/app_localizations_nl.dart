// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class SNl extends S {
  SNl([String locale = 'nl']) : super(locale);

  @override
  String get email => 'E-mailadres';

  @override
  String get emailMissing => 'Vul je e-mailadres in';

  @override
  String get password => 'Wachtwoord';

  @override
  String get passwordMissing => 'Vul je wachtwoord in';

  @override
  String get showPassword => 'Wachtwoord tonen';

  @override
  String get hidePassword => 'Wachtwoord verbergen';

  @override
  String get logIn => 'Inloggen';

  @override
  String get loginRejected => 'Dit e-mailadres en wachtwoord kent DIGI niet';

  @override
  String get forgotPassword => 'Wachtwoord vergeten?';

  @override
  String get codeTitle => 'Verificatiecode';

  @override
  String get codeExplanation => 'DIGI heeft je een e-mail gestuurd met een code van 6 cijfers.';

  @override
  String get code => 'Code';

  @override
  String get codeInvalid => 'Vul de 6 cijfers uit de e-mail in';

  @override
  String get codeRejected => 'Deze code klopt niet';

  @override
  String get confirm => 'Bevestigen';

  @override
  String get resetTitle => 'Wachtwoord vergeten';

  @override
  String get resetExplanation => 'DIGI stuurt je een e-mail om een nieuw wachtwoord te kiezen.';

  @override
  String get resetSend => 'Versturen';

  @override
  String get resetSent => 'Kijk in je mailbox om een nieuw wachtwoord te kiezen';

  @override
  String get resetRejected => 'DIGI kon geen e-mail sturen naar dit adres';

  @override
  String get logOut => 'Uitloggen';

  @override
  String get noProducts => 'Er staan geen producten op je account';

  @override
  String get noConnection => 'DIGI is niet bereikbaar. Controleer je internetverbinding.';

  @override
  String get unexpectedResponse => 'DIGI gaf een onverwacht antwoord. Probeer het later opnieuw.';

  @override
  String get sessionExpired => 'Je sessie is verlopen. Log opnieuw in.';

  @override
  String get tryAgain => 'Opnieuw proberen';

  @override
  String used(String percent) {
    return '$percent gebruikt';
  }
}
