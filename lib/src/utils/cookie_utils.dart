import 'package:intl/intl.dart';

import 'cookie_persistence.dart';

final Map<String, dynamic> cookieStore = {};

void handleCookies(Map<String, List<String>> headers) {
  final setCookieHeaders = headers['set-cookie'];

  if (setCookieHeaders == null) return;

  for (var cookie in setCookieHeaders) {
    final cookieParts = RegExp(r'([^=\s]+)=([^;]*)').firstMatch(cookie);
    if (cookieParts == null) continue;

    final name = cookieParts.group(1);
    final value = cookieParts.group(2) ?? '';

    final expiresMatch = RegExp(r'Expires=([a-zA-Z,0-9:\s\-]+);').firstMatch(cookie);
    final maxAgeMatch = RegExp(r'\s*Max-Age\s*=\s*(\d+)').firstMatch(cookie);

    DateTime? expiration;

    if (maxAgeMatch != null) {
      expiration = DateTime.now().add(Duration(seconds: int.tryParse(maxAgeMatch.group(1)!)!));
    } else if (expiresMatch != null) {
      expiration = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", "en_US").parseUtc(expiresMatch.group(1)!);
    }

    if (expiration == null || expiration.isAfter(DateTime.now())) {
      // Save the cookie to both in-memory store and shared preferences.
      saveOrUpdateCookie(name!, value, expiration);
    } else {
      // Remove the expired cookie from both in-memory store and shared preferences.
      _removeCookie(name!);
    }
  }
}

String? getCookie(String cookieName) {
  final cookie = cookieStore[cookieName];
  if (cookie == null) return null;

  final expiration = DateTime.tryParse(cookie['expiration'] ?? '');
  if (expiration != null && expiration.isBefore(DateTime.now())) {
    // Remove expired cookie from both in-memory store and shared preferences.
    _removeCookie(cookieName);
    return null;
  }

  return cookie['value'];
}

String getAllCookies() {
  final validCookies = <String>[];

  // Iterate over all cookies in memory and use getCookie to check validity
  cookieStore.keys.forEach((cookieName) {
    final cookieValue = getCookie(cookieName);  // This handles removal of expired cookies
    if (cookieValue != null) {
      validCookies.add('$cookieName=${Uri.encodeComponent(cookieValue)}');
    }
  });

  // Return the valid cookies as a string
  return validCookies.join('; ');
}



// Load cookies from shared preferences when the app starts.
void loadCookiesFromPreferences() {
  loadCookiesFromSharedPreferences();
}

void saveOrUpdateCookie(String name, String value, DateTime? expiration, {bool save = true}) {
  cookieStore[name] = {
    'value': Uri.decodeComponent(value),
    'expiration': expiration?.toIso8601String(),
  };

  // Save to shared preferences for persistence.
  if(save)
    saveCookieToSharedPreferences(name, cookieStore[name]!);
}

void _removeCookie(String name) {
  cookieStore.remove(name);

  // Also remove from shared preferences if it exists.
  removeCookieFromSharedPreferences(name);
}
