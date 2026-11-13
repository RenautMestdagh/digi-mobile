import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('nl')];

  /// No description provided for @email.
  ///
  /// In nl, this message translates to:
  /// **'E-mailadres'**
  String get email;

  /// No description provided for @emailMissing.
  ///
  /// In nl, this message translates to:
  /// **'Vul je e-mailadres in'**
  String get emailMissing;

  /// No description provided for @password.
  ///
  /// In nl, this message translates to:
  /// **'Wachtwoord'**
  String get password;

  /// No description provided for @passwordMissing.
  ///
  /// In nl, this message translates to:
  /// **'Vul je wachtwoord in'**
  String get passwordMissing;

  /// No description provided for @showPassword.
  ///
  /// In nl, this message translates to:
  /// **'Wachtwoord tonen'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In nl, this message translates to:
  /// **'Wachtwoord verbergen'**
  String get hidePassword;

  /// No description provided for @logIn.
  ///
  /// In nl, this message translates to:
  /// **'Inloggen'**
  String get logIn;

  /// No description provided for @loginRejected.
  ///
  /// In nl, this message translates to:
  /// **'Dit e-mailadres en wachtwoord kent DIGI niet'**
  String get loginRejected;

  /// No description provided for @forgotPassword.
  ///
  /// In nl, this message translates to:
  /// **'Wachtwoord vergeten?'**
  String get forgotPassword;

  /// No description provided for @codeTitle.
  ///
  /// In nl, this message translates to:
  /// **'Verificatiecode'**
  String get codeTitle;

  /// No description provided for @codeExplanation.
  ///
  /// In nl, this message translates to:
  /// **'DIGI heeft je een e-mail gestuurd met een code van 6 cijfers.'**
  String get codeExplanation;

  /// No description provided for @code.
  ///
  /// In nl, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @codeInvalid.
  ///
  /// In nl, this message translates to:
  /// **'Vul de 6 cijfers uit de e-mail in'**
  String get codeInvalid;

  /// No description provided for @codeRejected.
  ///
  /// In nl, this message translates to:
  /// **'Deze code klopt niet'**
  String get codeRejected;

  /// No description provided for @confirm.
  ///
  /// In nl, this message translates to:
  /// **'Bevestigen'**
  String get confirm;

  /// No description provided for @resetTitle.
  ///
  /// In nl, this message translates to:
  /// **'Wachtwoord vergeten'**
  String get resetTitle;

  /// No description provided for @resetExplanation.
  ///
  /// In nl, this message translates to:
  /// **'DIGI stuurt je een e-mail om een nieuw wachtwoord te kiezen.'**
  String get resetExplanation;

  /// No description provided for @resetSend.
  ///
  /// In nl, this message translates to:
  /// **'Versturen'**
  String get resetSend;

  /// No description provided for @resetSent.
  ///
  /// In nl, this message translates to:
  /// **'Kijk in je mailbox om een nieuw wachtwoord te kiezen'**
  String get resetSent;

  /// No description provided for @resetRejected.
  ///
  /// In nl, this message translates to:
  /// **'DIGI kon geen e-mail sturen naar dit adres'**
  String get resetRejected;

  /// No description provided for @logOut.
  ///
  /// In nl, this message translates to:
  /// **'Uitloggen'**
  String get logOut;

  /// No description provided for @noProducts.
  ///
  /// In nl, this message translates to:
  /// **'Er staan geen producten op je account'**
  String get noProducts;

  /// No description provided for @noConnection.
  ///
  /// In nl, this message translates to:
  /// **'DIGI is niet bereikbaar. Controleer je internetverbinding.'**
  String get noConnection;

  /// No description provided for @unexpectedResponse.
  ///
  /// In nl, this message translates to:
  /// **'DIGI gaf een onverwacht antwoord. Probeer het later opnieuw.'**
  String get unexpectedResponse;

  /// No description provided for @sessionExpired.
  ///
  /// In nl, this message translates to:
  /// **'Je sessie is verlopen. Log opnieuw in.'**
  String get sessionExpired;

  /// No description provided for @tryAgain.
  ///
  /// In nl, this message translates to:
  /// **'Opnieuw proberen'**
  String get tryAgain;

  /// No description provided for @used.
  ///
  /// In nl, this message translates to:
  /// **'{percent} gebruikt'**
  String used(String percent);
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'nl':
      return SNl();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
