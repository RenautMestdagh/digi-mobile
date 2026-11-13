// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get email => 'Email address';

  @override
  String get emailMissing => 'Enter your email address';

  @override
  String get password => 'Password';

  @override
  String get passwordMissing => 'Enter your password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get logIn => 'Log in';

  @override
  String get loginRejected => 'DIGI doesn\'t know this email address and password';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get codeTitle => 'Verification code';

  @override
  String get codeExplanation => 'DIGI has emailed you a 6-digit code.';

  @override
  String get code => 'Code';

  @override
  String get codeInvalid => 'Enter the 6 digits from the email';

  @override
  String get codeRejected => 'This code is not correct';

  @override
  String get confirm => 'Confirm';

  @override
  String get resetTitle => 'Forgot password';

  @override
  String get resetExplanation => 'DIGI will email you a link to choose a new password.';

  @override
  String get resetSend => 'Send';

  @override
  String get resetSent => 'Check your mailbox to choose a new password';

  @override
  String get resetRejected => 'DIGI couldn\'t send an email to this address';

  @override
  String get logOut => 'Log out';

  @override
  String get noProducts => 'There are no products on your account';

  @override
  String get noConnection => 'DIGI can\'t be reached. Check your internet connection.';

  @override
  String get unexpectedResponse => 'DIGI gave an unexpected answer. Try again later.';

  @override
  String get sessionExpired => 'Your session has expired. Please log in again.';

  @override
  String get tryAgain => 'Try again';

  @override
  String used(String percent) {
    return '$percent used';
  }
}
