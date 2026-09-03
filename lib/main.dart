import 'package:flutter/material.dart';
import 'package:digi_mobile/src/screens/home_screen.dart';
import 'package:digi_mobile/src/utils/cookie_persistence.dart';
import 'package:digi_mobile/src/utils/cookie_utils.dart';
import 'src/screens/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: loadCookiesFromSharedPreferences(),  // Wait for cookies to load
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            title: 'DIGI Mobile',
            home: Scaffold(body: Center(child: CircularProgressIndicator())), // Show loading indicator while loading cookies
          );
        } else {
          // Once cookies are loaded, check for the session cookie and navigate accordingly
          return MaterialApp(
            title: 'DIGI Mobile',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: getCookie('__Secure-authjs.session-token') == null ? const LoginScreen() : const HomeScreen(),
          );
        }
      }
    );
  }
}
