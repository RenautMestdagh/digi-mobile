import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';

import 'data/cookie_jar.dart';
import 'data/digi_client.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final client = DigiClient(http.Client(), await CookieJar.open());

  runApp(DigiApp(client: client));
}

class DigiApp extends StatefulWidget {
  const DigiApp({super.key, required this.client});

  final DigiClient client;

  @override
  State<DigiApp> createState() => _DigiAppState();
}

class _DigiAppState extends State<DigiApp> {
  final _navigator = GlobalKey<NavigatorState>();

  Widget _login() => LoginScreen(client: widget.client, onSignedIn: () => _replaceWith(_home()));

  Widget _home() => HomeScreen(client: widget.client, onSignedOut: () => _replaceWith(_login()));

  void _replaceWith(Widget screen) {
    unawaited(
      _navigator.currentState!.pushAndRemoveUntil(MaterialPageRoute<void>(builder: (_) => screen), (_) => false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigator,
      title: 'DIGI Mobile',
      theme: appTheme(Brightness.light),
      darkTheme: appTheme(Brightness.dark),
      localizationsDelegates: const [S.delegate, ...GlobalMaterialLocalizations.delegates],
      supportedLocales: S.supportedLocales,
      home: widget.client.signedIn ? _home() : _login(),
    );
  }
}
