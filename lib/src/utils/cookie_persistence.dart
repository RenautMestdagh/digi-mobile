import 'package:shared_preferences/shared_preferences.dart';

import 'cookie_utils.dart';

Future<void> saveCookieToSharedPreferences(String key, dynamic cookieValue) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> cookieData = [
    'value:${cookieValue['value']}',
    'expiration:${cookieValue['expiration'] ?? ''}'
  ];
  await prefs.setStringList(key, cookieData);
}


Future<void> removeCookieFromSharedPreferences(String name) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(name);
}

Future<void> loadCookiesFromSharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  final allCookies = prefs.getKeys();

  for (var key in allCookies) {
    try {
      final cookieData = prefs.getStringList(key);
      if (cookieData == null || cookieData.isEmpty) {
        print('Warning: No data for key "$key".');
        continue;
      }

      // Convert list to a map by splitting each entry
      Map<String, String> cookieMap = {};
      for (var item in cookieData) {
        final keyValue = item.split(':');
        if (keyValue.length < 2) continue;  // Ignore invalid entries
        String subKey = keyValue[0].trim();
        String subValue = keyValue.sublist(1).join(':').trim();  // Handle colons in values
        cookieMap[subKey] = subValue;
      }

      // Extract values safely
      String value = cookieMap['value'] ?? '';
      DateTime? expiration = cookieMap['expiration']?.isNotEmpty == true
          ? DateTime.tryParse(cookieMap['expiration']!)
          : null;

      if (value.isEmpty) {
        print('Warning: Missing value in cookie for key "$key".');
        continue;
      }

      // Save or update cookie safely
      saveOrUpdateCookie(key, value, expiration, save: false);

    } catch (e) {
      print('Error processing cookie for key "$key": $e');
    }
  }

  // Always add cookie with key cmp_level and value 15 and expiration 1 year from now
  DateTime expiration = DateTime.now().add(const Duration(days: 365));
  saveOrUpdateCookie('cmp_level', '15', expiration);
}

